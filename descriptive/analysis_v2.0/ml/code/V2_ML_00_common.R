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
V2_ML_PANEL_CAPS <- c(3, 5, 10, 20)
V2_ML_BOOTSTRAP_N <- 2000

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

#' Generate 50 log-spaced lambda fractions
generate_lambda_fractions <- function(n_lambda=50) {
  # fractions from 1.0 down to 0.001 on log scale
  exp(seq(0, log(0.001), length.out=n_lambda))
}

# ---- Panel cap helpers ----

#' Apply panel cap: rank by |coef|, retain up to k, refit
#' (This is a placeholder signature; actual refit happens in nested CV)
apply_panel_cap <- function(coef_vector, k) {
  if (length(coef_vector) <= k) return(coef_vector)
  ord <- order(abs(coef_vector), decreasing=TRUE)
  keep <- ord[seq_len(k)]
  coef_vector[setdiff(seq_along(coef_vector), keep)] <- 0
  coef_vector
}

#' One-SE rule selection
#' candidates: data.frame with metric, se, alpha, lambda_frac, panel_size
#' Selects candidates within 1 SE of min metric, then smallest median panel size
apply_one_se_rule <- function(candidates) {
  best_idx <- which.min(candidates$metric)
  best_metric <- candidates$metric[best_idx]
  best_se <- candidates$se[best_idx]
  threshold <- best_metric + best_se
  eligible <- candidates$metric <= threshold
  # Among eligible, prefer smallest median panel size
  sub <- candidates[eligible, ]
  sub <- sub[order(sub$panel_size,
                   -sub$lambda_frac,   # stronger regularization = larger lambda fraction is smaller lambda; use -frac for stronger reg
                   -sub$alpha), ]
  sub[1, ]
}
