# V2_ML_00_common.R — Shared ML helpers, assertions, leakage guards
# Sourced by all ML scripts. Do not run as standalone.

# ---- Constants ----
V2_ML_SEEDS_OUTER <- c(20260926, 20260927, 20260928)
V2_ML_SEED_LOCK   <- 20260929
V2_ML_SEED_HOLDOUT <- 20260930
V2_ML_N_OUTER <- 5
V2_ML_N_INNER <- 5
V2_ML_N_REPEATS <- 3
V2_ML_ALPHAS <- c(0.1, 0.5, 0.9, 1.0)
V2_ML_N_LAMBDA <- 50
V2_ML_LAMBDA_MIN_RATIO <- 0.001
V2_ML_PANEL_CAPS <- c(3, 5, 10, 20)
V2_ML_BOOTSTRAP_N <- 2000
V2_ML_PANEL_REFIT_POLICY <- NA_character_

# ---- Active artifact contract ----
V2_ML_MODEL_DIR <- "descriptive/analysis_v2.0/ml/models"
V2_ML_MODEL_PATH <- file.path(V2_ML_MODEL_DIR, "strategyB_primary_model.rds")
V2_ML_MANIFEST_PATH <- file.path(V2_ML_MODEL_DIR, "strategyB_model_manifest.csv")
V2_ML_LOCK_PATH <- file.path(V2_ML_MODEL_DIR, "PRIMARY_MODEL_LOCK")
V2_ML_HOLDOUT_LOCK_PATH <- file.path(V2_ML_MODEL_DIR, "HOLDOUT_EVALUATION_LOCK")

# Forbidden feature-source paths (historical outcome-dependent results)
V2_ML_FORBIDDEN_PATHS <- c(
  "stage07", "Stage07", "256_DEP", "canonical_256",
  "D03", "d03_locked", "85_candidate", "locked_85",
  "D08", "D09", "D10",
  "limma_dose_analysis/results",
  "discovery_validation/results"
)

# ---- Input assertions ----
assert_sample_ids_unique <- function(ids) {
  if (any(duplicated(ids))) stop("Duplicate sample IDs: ",
    paste(ids[duplicated(ids)], collapse=", "))
  invisible(TRUE)
}

assert_protein_ids_unique <- function(ids) {
  if (any(duplicated(ids))) stop("Duplicate protein IDs: ",
    paste(ids[duplicated(ids)], collapse=", "))
  invisible(TRUE)
}

assert_split_assignment_complete <- function(meta, required_splits=c("Discovery","Validation")) {
  if (!"Split" %in% names(meta)) stop("Meta missing 'Split' column")
  if (!all(required_splits %in% unique(meta$Split))) stop("Missing split levels")
  if (any(is.na(meta$Split))) stop("NA in Split column")
  invisible(TRUE)
}

assert_group_levels <- function(groups, expected=c("control","low","high")) {
  g <- unique(groups)
  if (!all(g %in% expected)) stop("Unexpected group levels: ", paste(g, collapse=","))
  invisible(TRUE)
}

assert_environment_levels <- function(envs, expected=c("Humid-hot","High-altitude")) {
  e <- unique(envs)
  if (!all(e %in% expected)) stop("Unexpected environment levels: ", paste(e, collapse=","))
  invisible(TRUE)
}

# ---- Hard leakage guards ----

#' Assert that given sample IDs are all Discovery (no hold-out)
assert_discovery_only <- function(sample_ids, split_meta) {
  splits <- split_meta$Split[match(sample_ids, split_meta$UniqueSampleID)]
  if (any(is.na(splits))) stop("Sample IDs not found in split assignment")
  if (any(splits != "Discovery")) {
    bad <- sample_ids[splits != "Discovery"]
    stop("LEAKAGE: hold-out/non-Discovery samples in training: ",
         paste(head(bad,5), collapse=", "))
  }
  invisible(TRUE)
}

#' Assert that hold-out sample IDs are NOT in a given ID set
assert_no_holdout_samples <- function(training_ids, split_meta) {
  holdout_ids <- split_meta$UniqueSampleID[split_meta$Split == "Validation"]
  overlap <- intersect(training_ids, holdout_ids)
  if (length(overlap) > 0) {
    stop("LEAKAGE: hold-out samples found in training: ",
         paste(head(overlap,5), collapse=", "))
  }
  invisible(TRUE)
}

#' Assert that a file path is not a forbidden historical feature source
assert_no_forbidden_feature_source <- function(paths) {
  for (p in paths) {
    for (fp in V2_ML_FORBIDDEN_PATHS) {
      if (grepl(fp, p, fixed=TRUE)) {
        stop("LEAKAGE: forbidden historical feature source used: ", p,
             " (matched pattern: ", fp, ")")
      }
    }
  }
  invisible(TRUE)
}

#' Assert outer and inner fold assignments are disjoint
assert_fold_disjoint <- function(outer_train_ids, outer_test_ids) {
  overlap <- intersect(outer_train_ids, outer_test_ids)
  if (length(overlap) > 0) {
    stop("FOLD LEAKAGE: outer test IDs in outer train: ",
         paste(head(overlap,5), collapse=", "))
  }
  invisible(TRUE)
}

#' Assert that preprocessing parameters were derived from training only
#' (This is a structural assertion: callers must pass training-derived params
#'  and validation/test data must not have been used to fit params)
assert_training_derived_preprocessing <- function(imputer_median, scaler_mean, scaler_sd,
                                                    n_train) {
  if (length(imputer_median) != length(scaler_mean)) stop("Imputer and scaler feature mismatch")
  if (length(scaler_sd) != length(scaler_mean)) stop("Scaler mean/sd length mismatch")
  if (any(is.na(scaler_mean))) stop("NA in scaler mean")
  if (any(is.na(scaler_sd)) || any(is.infinite(scaler_sd))) stop("NA/Inf in scaler sd")
  if (n_train < 2) stop("Training set too small for preprocessing")
  invisible(TRUE)
}

# ---- Deterministic seed helper ----
set_ml_seed <- function(seed) {
  set.seed(seed, kind="Mersenne-Twister", normal.kind="Inversion")
  invisible(TRUE)
}

#' Derive deterministic inner seed from repeat_id and outer_fold
derive_inner_seed <- function(repeat_id, outer_fold, base_seeds=V2_ML_SEEDS_OUTER) {
  base <- base_seeds[repeat_id]
  # Deterministic hash-like combination
  as.integer((base + outer_fold * 7919) %% 2147483647)
}

# ---- Fold-local eligibility ----

#' Compute fold-local quantitative eligibility
#' @param abundance_mat matrix proteins x samples (log2, finite>0 = detected)
#' @param sample_groups named vector: sample_id -> group (control/low/high)
#' @param detection_rate numeric, minimum detection rate per group (0.70)
#' @return list with eligible logical vector, thresholds, group Ns
compute_fold_eligibility <- function(abundance_mat, sample_groups, detection_rate=0.70) {
  groups <- c("control","low","high")
  thresholds <- setNames(numeric(3), groups)
  n_by_group <- setNames(numeric(3), groups)
  pass_mat <- matrix(FALSE, nrow=nrow(abundance_mat), ncol=3,
                     dimnames=list(rownames(abundance_mat), groups))
  for (g in groups) {
    sids <- names(sample_groups)[sample_groups == g]
    sids <- intersect(sids, colnames(abundance_mat))
    n_g <- length(sids)
    n_by_group[g] <- n_g
    thr <- ceiling(detection_rate * n_g)
    thresholds[g] <- thr
    if (n_g > 0) {
      det_count <- rowSums(is.finite(abundance_mat[, sids, drop=FALSE]) &
                           abundance_mat[, sids, drop=FALSE] > 0, na.rm=TRUE)
      pass_mat[, g] <- det_count >= thr
    }
  }
  eligible <- pass_mat[, "control"] & pass_mat[, "low"] & pass_mat[, "high"]
  list(eligible=eligible, thresholds=thresholds, n_by_group=n_by_group,
       pass_matrix=pass_mat)
}

# ---- Median imputation (training-only) ----

fit_median_imputer <- function(train_mat) {
  # train_mat: proteins x samples
  medians <- apply(train_mat, 1, median, na.rm=TRUE)
  # Handle all-NA rows: spec says STOP (no rule defined)
  all_na <- apply(train_mat, 1, function(x) all(is.na(x)))
  if (any(all_na)) {
    stop("IMPTER ERROR: all-NA protein rows in training: ",
         paste(head(rownames(train_mat)[all_na],5), collapse=", "),
         ". No imputation rule defined for all-NA proteins.")
  }
  list(medians=medians, n_train=ncol(train_mat))
}

apply_median_imputer <- function(mat, imputer) {
  out <- mat
  for (j in seq_len(ncol(out))) {
    na_idx <- is.na(out[, j])
    out[na_idx, j] <- imputer$medians[na_idx]
  }
  out
}

# ---- Scaling (training-only) ----

fit_scaler <- function(train_mat) {
  means <- rowMeans(train_mat, na.rm=TRUE)
  sds <- apply(train_mat, 1, sd, na.rm=TRUE)
  # Zero-variance features
  zero_var <- is.na(sds) | sds == 0
  list(means=means, sds=sds, zero_var=zero_var, n_train=ncol(train_mat))
}

apply_scaler <- function(mat, scaler) {
  out <- mat
  for (i in seq_len(nrow(out))) {
    out[i, ] <- (out[i, ] - scaler$means[i]) / scaler$sds[i]
  }
  out
}

remove_zero_variance <- function(mat, scaler) {
  mat[!scaler$zero_var, , drop=FALSE]
}

# ---- Elastic Net lambda grid ----

#' Generate the frozen explicit lambda grid for one training split.
#' lambda_max must be computed from that split only.
generate_lambda_grid <- function(lambda_max,
                                 n_lambda=V2_ML_N_LAMBDA,
                                 min_ratio=V2_ML_LAMBDA_MIN_RATIO) {
  if (length(lambda_max) != 1L || !is.finite(lambda_max) || lambda_max <= 0) {
    stop("lambda_max must be one finite positive training-split value.")
  }
  if (n_lambda != 50L) stop("Frozen lambda grid requires exactly 50 values.")
  if (!isTRUE(all.equal(min_ratio, 0.001, tolerance=1e-12))) {
    stop("Frozen lambda minimum ratio must equal 0.001.")
  }
  grid <- exp(seq(log(lambda_max), log(lambda_max * min_ratio),
                  length.out=n_lambda))
  assert_lambda_grid(grid)
  grid
}

assert_lambda_grid <- function(lambda_grid, tolerance=1e-10) {
  if (length(lambda_grid) != 50L) stop("Lambda grid must contain exactly 50 values.")
  if (any(!is.finite(lambda_grid)) || any(lambda_grid <= 0)) {
    stop("Lambda grid contains non-finite or non-positive values.")
  }
  if (any(diff(lambda_grid) >= 0)) stop("Lambda grid must be strictly decreasing.")
  ratio <- min(lambda_grid) / max(lambda_grid)
  if (abs(ratio - 0.001) > tolerance) {
    stop(sprintf("Lambda min/max ratio is %.12g, expected 0.001.", ratio))
  }
  invisible(TRUE)
}

# Backward-compatible name for specification and synthetic QA only.
generate_lambda_fractions <- function(n_lambda=V2_ML_N_LAMBDA) {
  generate_lambda_grid(1, n_lambda=n_lambda)
}

# ---- Panel candidate contract ----

panel_candidate_ids <- function() {
  c(paste0("k", V2_ML_PANEL_CAPS), "untruncated")
}

assert_panel_refit_policy_resolved <- function() {
  if (is.na(V2_ML_PANEL_REFIT_POLICY) || !nzchar(V2_ML_PANEL_REFIT_POLICY)) {
    stop(
      paste(
        "SPECIFICATION_GAP_REQUIRES_INVESTIGATOR:",
        "the frozen specification does not define how coefficients are",
        "estimated after top-k feature selection. Freeze one rule before",
        "implementing or running capped panel candidates."
      ),
      call.=FALSE
    )
  }
  invisible(TRUE)
}

#' Deterministically identify top-k feature IDs without defining a refit model.
#' This helper is ranking only and must never be treated as a fitted candidate.
rank_panel_features <- function(coef_vector, k) {
  if (!k %in% V2_ML_PANEL_CAPS) stop("Unknown frozen panel cap: ", k)
  nz <- coef_vector[is.finite(coef_vector) & coef_vector != 0]
  if (!length(nz)) return(character(0))
  feature_id <- names(nz)
  if (is.null(feature_id) || any(!nzchar(feature_id))) {
    stop("Named coefficients are required for deterministic protein tie-breaking.")
  }
  ord <- order(-abs(nz), feature_id)
  feature_id[ord][seq_len(min(k, length(ord)))]
}

#' One-SE rule selection
#' candidates: data.frame with metric, se, alpha, lambda_frac, panel_size
#' Selects candidates within 1 SE of min metric, then smallest median panel size
apply_one_se_rule <- function(candidates) {
  required <- c("candidate_id", "metric", "se", "alpha", "lambda_frac",
                "panel_size")
  missing <- setdiff(required, names(candidates))
  if (length(missing)) stop("Candidate table missing: ", paste(missing, collapse=", "))
  best_idx <- which.min(candidates$metric)
  best_metric <- candidates$metric[best_idx]
  best_se <- candidates$se[best_idx]
  threshold <- best_metric + best_se
  eligible <- candidates$metric <= threshold
  # Among eligible, prefer smallest median panel size
  sub <- candidates[eligible, ]
  sub <- sub[order(sub$panel_size,
                   -sub$lambda_frac,
                   -sub$alpha,
                   sub$candidate_id), ]
  selected <- sub[1, , drop=FALSE]
  attr(selected, "minimum_candidate") <- candidates[best_idx, , drop=FALSE]
  attr(selected, "one_se_boundary") <- threshold
  attr(selected, "eligible_candidates") <- sub
  selected
}

# ---- Model-lock artifact verification ----

sha256_file <- function(path) {
  if (!file.exists(path)) stop("Required artifact missing: ", path)
  if (!requireNamespace("digest", quietly=TRUE)) stop("Package 'digest' is required.")
  digest::digest(file=path, algo="sha256")
}

read_manifest_value <- function(manifest, item) {
  hit <- manifest$value[manifest$item == item]
  if (length(hit) != 1L || is.na(hit) || !nzchar(hit)) {
    stop("Manifest must contain exactly one non-empty value for: ", item)
  }
  hit
}

assert_valid_primary_lock <- function(model_path=V2_ML_MODEL_PATH,
                                      manifest_path=V2_ML_MANIFEST_PATH,
                                      lock_path=V2_ML_LOCK_PATH) {
  required <- c(model_path, manifest_path, lock_path)
  missing <- required[!file.exists(required)]
  if (length(missing)) {
    stop("NO VALID PRIMARY_MODEL_LOCK: missing ", paste(missing, collapse=", "),
         call.=FALSE)
  }
  manifest <- read.csv(manifest_path, stringsAsFactors=FALSE)
  actual <- sha256_file(model_path)
  manifest_sha <- read_manifest_value(manifest, "model_sha256")
  lock_lines <- readLines(lock_path, warn=FALSE)
  lock_hit <- grep("^Model SHA-256:", lock_lines, value=TRUE)
  if (length(lock_hit) != 1L) stop("NO VALID PRIMARY_MODEL_LOCK: lock SHA missing.")
  lock_sha <- trimws(sub("^Model SHA-256:", "", lock_hit))
  if (!identical(actual, manifest_sha) || !identical(actual, lock_sha)) {
    stop("NO VALID PRIMARY_MODEL_LOCK: model SHA mismatch.", call.=FALSE)
  }
  invisible(TRUE)
}
