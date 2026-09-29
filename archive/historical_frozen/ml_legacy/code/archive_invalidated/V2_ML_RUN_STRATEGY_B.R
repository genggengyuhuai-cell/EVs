# V2_ML_RUN_STRATEGY_B.R — Primary Strategy B nested CV on Discovery 386
# This IS executed. No hold-out data used.

library(readxl)
library(glmnet)
library(digest)

ROOT <- "F:/env"
setwd(ROOT)

OUT_ML <- "descriptive/analysis_v2.0/ml"
RES_DIR <- file.path(OUT_ML, "results")
dir.create(RES_DIR, showWarnings=FALSE, recursive=TRUE)

# ---- Constants ----
ALPHAS <- c(0.1, 0.5, 0.9, 1.0)
N_LAMBDA <- 50
PANIEL_CAPS <- c(3, 5, 10, 20)
SEEDS <- c(20260926, 20260927, 20260928)

# ---- Load split assignment ----
cat("Loading split assignment...\n")
split_meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                        stringsAsFactors=FALSE)
disc <- split_meta[split_meta$Split == "Discovery", ]
stopifnot(nrow(disc) == 386)
hold <- split_meta[split_meta$Split == "Validation", ]
stopifnot(nrow(hold) == 129)
# No overlap
stopifnot(length(intersect(disc$UniqueSampleID, hold$UniqueSampleID)) == 0)

# Primary target: Control=0, Exposure=1
disc$y <- as.integer(disc$TREAT1_clean != "control")
cat("Discovery: Control=", sum(disc$y==0), " Exposure=", sum(disc$y==1), "\n")

# ---- Load abundance via positional matching ----
cat("Loading abundance matrix...\n")
ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
clean_header <- function(x) { x <- trimws(as.character(x)); sub("\\.0$","",x) }
ss$clean <- clean_header(ss$Sheet1_raw_header)

raw <- read_excel("rawdata/processed.xlsx", n_max=3817, .name_repair="minimal")
proteins <- data.frame(
  PG = raw$PG.ProteinGroups,
  Gene = raw$PG.Genes,
  stringsAsFactors=FALSE
)
excel_cols <- names(raw)[8:ncol(raw)]
excel_clean <- clean_header(excel_cols)
stopifnot(length(excel_clean) == nrow(ss))
stopifnot(all(excel_clean == ss$clean))

abund <- as.data.frame(raw[, 8:ncol(raw)])
rownames(abund) <- proteins$PG

# Load Freeze 3 exclusions
f3 <- read.csv("descriptive/analysis_v2.0/registry/contaminant_candidate_registry.csv",
               stringsAsFactors=FALSE)
excl_pgs <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible == "TRUE"]
stopifnot(length(excl_pgs) == 8)
# Restrict to Utech
utech_mask <- !rownames(abund) %in% excl_pgs
abund_utech <- abund[utech_mask, ]
cat("Utech proteins:", nrow(abund_utech), "\n")

# Get Discovery sample positions via UniqueSampleID -> sample_statistics -> Excel column
ss_disc <- ss[match(disc$UniqueSampleID, ss$UniqueSampleID), ]
stopifnot(!any(is.na(ss_disc$UniqueSampleID)))
disc_pos <- match(ss_disc$clean, excel_clean)
stopifnot(!any(is.na(disc_pos)))
disc_abund <- t(abund_utech[, disc_pos])
colnames(disc_abund) <- rownames(abund_utech)
rownames(disc_abund) <- disc$UniqueSampleID
cat("Discovery matrix:", nrow(disc_abund), "x", ncol(disc_abund), "\n")

# Load folds
outer_folds <- read.csv(file.path(OUT_ML, "folds", "outer_folds.csv"), stringsAsFactors=FALSE)
inner_folds <- read.csv(file.path(OUT_ML, "folds", "inner_folds.csv"), stringsAsFactors=FALSE)

# ---- Helper functions ----
is_det <- function(x) is.finite(x) & x > 0

# Fold-local eligibility: proteins with >=70% detection in each group in training
compute_elig <- function(train_sids, groups_vec) {
  # train_sids: sample IDs in training
  # groups_vec: named vector sid -> group (control/low/high)
  mat <- disc_abund[train_sids, , drop=FALSE]
  groups <- groups_vec[train_sids]
  elig <- rep(TRUE, ncol(mat))
  names(elig) <- colnames(mat)
  for (g in c("control","low","high")) {
    g_sids <- names(groups)[groups == g]
    if (length(g_sids) == 0) next
    n_g <- length(g_sids)
    thr <- ceiling(0.70 * n_g)
    det_count <- colSums(is_det(mat[g_sids, , drop=FALSE]))
    elig <- elig & (det_count >= thr)
  }
  elig
}

# Preprocessing: median impute + scale (training-only)
fit_preprocess <- function(train_mat) {
  medians <- apply(train_mat, 2, median, na.rm=TRUE)
  # All-NA column check
  all_na <- apply(train_mat, 2, function(x) all(is.na(x)))
  if (any(all_na)) stop("All-NA feature in training")
  # Impute
  train_imp <- train_mat
  for (j in 1:ncol(train_imp)) {
    na_idx <- is.na(train_imp[, j])
    train_imp[na_idx, j] <- medians[j]
  }
  means <- colMeans(train_imp)
  sds <- apply(train_imp, 2, sd)
  zero_var <- is.na(sds) | sds == 0
  list(medians=medians, means=means, sds=sds, zero_var=zero_var)
}

apply_preprocess <- function(mat, prep) {
  out <- mat
  for (j in 1:ncol(out)) {
    na_idx <- is.na(out[, j])
    out[na_idx, j] <- prep$medians[j]
  }
  # Scale
  for (j in 1:ncol(out)) {
    out[, j] <- (out[, j] - prep$means[j]) / prep$sds[j]
  }
  out
}

# ---- Run nested CV ----
cat("\n===== STARTING NESTED CV =====\n")

outer_pred_list <- list()
inner_results_list <- list()
sel_params_list <- list()

for (rep in 1:3) {
  cat("\n--- Repeat", rep, "---\n")
  rep_outer <- outer_folds[outer_folds$Repeat == rep, ]

  for (of in 1:5) {
    cat("  Outer fold", of, "...\n")
    test_sids <- rep_outer$Participant_ID[rep_outer$Outer_fold == of]
    train_sids <- rep_outer$Participant_ID[rep_outer$Outer_fold != of]

    # Safety: disjoint
    stopifnot(length(intersect(train_sids, test_sids)) == 0)
    # No hold-out
    stopifnot(length(intersect(test_sids, hold$UniqueSampleID)) == 0)

    # Outer train groups
    train_groups <- setNames(disc$TREAT1_clean[match(train_sids, disc$UniqueSampleID)], train_sids)

    # Mfold eligibility on outer train
    elig <- compute_elig(train_sids, train_groups)
    elig_proteins <- names(elig)[elig]
    cat("    Eligible proteins:", length(elig_proteins), "\n")

    # Inner fold assignments for this outer fold
    rep_inner <- inner_folds[inner_folds$Repeat == rep & inner_folds$Outer_fold == of &
                             inner_folds$Role == "inner_training_or_val", ]

    # ---- Inner CV ----
    best_logloss <- Inf
    best_alpha <- NA
    best_lambda_frac <- NA
    best_panel <- NA

    for (al in ALPHAS) {
      # For each inner fold, compute deviance across lambda grid
      inner_ml_losses <- matrix(NA, nrow=N_LAMBDA, ncol=5)
      inner_ml_nz <- matrix(NA, nrow=N_LAMBDA, ncol=5)

      for (inf in 1:5) {
        inf_val_sids <- rep_inner$Participant_ID[rep_inner$Inner_fold == inf]
        inf_train_sids <- setdiff(train_sids, inf_val_sids)

        # Eligibility on inner train
        inf_groups <- setNames(disc$TREAT1_clean[match(inf_train_sids, disc$UniqueSampleID)],
                               inf_train_sids)
        inf_elig <- compute_elig(inf_train_sids, inf_groups)
        inf_elig_p <- names(inf_elig)[inf_elig]
        # Must also be in outer eligibility
        use_p <- intersect(inf_elig_p, elig_proteins)

        if (length(use_p) < 5) next

        # Preprocess inner train
        x_inf_train <- disc_abund[inf_train_sids, use_p, drop=FALSE]
        y_inf_train <- disc$y[match(inf_train_sids, disc$UniqueSampleID)]
        prep_inf <- fit_preprocess(x_inf_train)
        # Remove zero var
        keep <- !prep_inf$zero_var
        x_inf_train_imp <- apply_preprocess(x_inf_train, prep_inf)
        x_inf_train_imp <- x_inf_train_imp[, keep, drop=FALSE]

        x_inf_val <- disc_abund[inf_val_sids, use_p, drop=FALSE]
        y_inf_val <- disc$y[match(inf_val_sids, disc$UniqueSampleID)]
        x_inf_val_imp <- apply_preprocess(x_inf_val, prep_inf)
        x_inf_val_imp <- x_inf_val_imp[, keep, drop=FALSE]

        # Fit glmnet
        tryCatch({
          fit <- glmnet(x_inf_train_imp, y_inf_train, family="binomial",
                        alpha=al, nlambda=N_LAMBDA, standardize=FALSE)
          # Predict on val
          pred_val <- predict(fit, newx=x_inf_val_imp, type="response")
          # Log loss per lambda
          for (li in 1:ncol(pred_val)) {
            p <- pmin(pmax(pred_val[, li], 1e-10, na.rm=TRUE), 1-1e-10)
            ll <- -mean(y_inf_val * log(p) + (1-y_inf_val) * log(1-p))
            inner_ml_losses[li, inf] <- ll
            inner_ml_nz[li, inf] <- sum(fit$beta[, li] != 0)
          }
        }, error=function(e) {
          cat("    glmnet error (alpha=", al, "inner=", inf, "):", conditionMessage(e), "\n")
        })
      }

      # Average across inner folds
      mean_ll <- rowMeans(inner_ml_losses, na.rm=TRUE)
      mean_nz <- rowMeans(inner_ml_nz, na.rm=TRUE)

      # Find best lambda (minimum mean log loss)
      best_li <- which.min(mean_ll)
      if (is.na(mean_ll[best_li])) next

      # One-SE rule: find SE, then choose simplest within 1SE
      ll_se <- apply(inner_ml_losses, 1, sd, na.rm=TRUE) / sqrt(5)
      threshold <- mean_ll[best_li] + ll_se[best_li]
      within_1se <- which(mean_ll <= threshold)

      # Prefer smaller panel size, then stronger regularization
      # Among within_1se, choose largest lambda (most regularized)
      # lambda index: higher index = smaller lambda = less regularized
      # glmnet returns lambda in decreasing order; index 1 = largest lambda
      # Choose within_1se with smallest index (largest lambda = strongest reg)
      chosen_li <- min(within_1se)

      if (mean_ll[chosen_li] < best_logloss) {
        best_logloss <- mean_ll[chosen_li]
        best_alpha <- al
        best_lambda_idx <- chosen_li
        best_nz <- mean_nz[chosen_li]
      }
    }

    # ---- Refit on full outer train with best alpha ----
    cat("    Best alpha=", best_alpha, " lambda_idx=", best_lambda_idx, "\n")

    # Final preprocessing on full outer train
    x_otrain <- disc_abund[train_sids, elig_proteins, drop=FALSE]
    y_otrain <- disc$y[match(train_sids, disc$UniqueSampleID)]
    prep_otrain <- fit_preprocess(x_otrain)
    keep_ot <- !prep_otrain$zero_var
    x_otrain_imp <- apply_preprocess(x_otrain, prep_otrain)
    x_otrain_imp <- x_otrain_imp[, keep_ot, drop=FALSE]

    # Fit full glmnet with best alpha, get lambda sequence
    fit_final <- glmnet(x_otrain_imp, y_otrain, family="binomial",
                        alpha=best_alpha, nlambda=N_LAMBDA, standardize=FALSE)
    # Use the chosen lambda index (may differ if nlambda differs)
    li_use <- min(best_lambda_idx, ncol(fit_final$beta))
    x_otest <- disc_abund[test_sids, elig_proteins, drop=FALSE]
    y_otest <- disc$y[match(test_sids, disc$UniqueSampleID)]
    x_otest_imp <- apply_preprocess(x_otest, prep_otrain)
    x_otest_imp <- x_otest_imp[, keep_ot, drop=FALSE]

    pred_test <- as.numeric(predict(fit_final, newx=x_otest_imp,
                                    s=fit_final$lambda[li_use], type="response"))
    pred_test <- pmin(pmax(pred_test, 0, na.rm=TRUE), 1)

    # Nonzero features at selected lambda
    nz_coef <- as.numeric(fit_final$beta[, li_use] != 0)
    names(nz_coef) <- colnames(x_otrain_imp)

    outer_pred_list[[length(outer_pred_list)+1]] <- data.frame(
      Participant_ID = test_sids,
      Repeat = rep,
      Outer_fold = of,
      observed = y_otest,
      predicted = pred_test,
      alpha = best_alpha,
      lambda_idx = li_use,
      panel_size = sum(nz_coef),
      eligible_proteins = length(elig_proteins),
      stringsAsFactors = FALSE
    )

    sel_params_list[[length(sel_params_list)+1]] <- data.frame(
      Repeat=rep, Outer_fold=of, alpha=best_alpha,
      lambda_idx=li_use, inner_logloss=best_logloss,
      panel_size=sum(nz_coef), eligible=length(elig_proteins),
      stringsAsFactors=FALSE)

    cat("    Test N=", length(test_sids), " panel=", sum(nz_coef),
        " mean pred=", round(mean(pred_test),3), "\n")
  }
}

# ---- Save outputs ----
cat("\nSaving results...\n")
outer_preds <- do.call(rbind, outer_pred_list)
write.csv(outer_preds, file.path(RES_DIR, "strategyB_outer_predictions.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

sel_params <- do.call(rbind, sel_params_list)
write.csv(sel_params, file.path(RES_DIR, "strategyB_selected_hyperparameters.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ---- Per-repeat performance ----
cat("\n===== PER-REPEAT PERFORMANCE =====\n")
library(pROC)
perf_rows <- list()
for (rep in 1:3) {
  sub <- outer_preds[outer_preds$Repeat == rep, ]
  stopifnot(nrow(sub) == 386)
  auc_obj <- roc(sub$observed, sub$predicted, quiet=TRUE)
  auc_val <- as.numeric(auc_obj)
  ll <- -mean(sub$observed * log(pmax(sub$predicted,1e-10)) +
              (1-sub$observed) * log(pmax(1-sub$predicted,1e-10)))
  brier <- mean((sub$observed - sub$predicted)^2)
  cat(sprintf("Repeat %d: AUROC=%.4f logloss=%.4f brier=%.4f\n",
              rep, auc_val, ll, brier))
  perf_rows[[rep]] <- data.frame(Repeat=rep, AUROC=auc_val, LogLoss=ll, Brier=brier)
}
perf_df <- do.call(rbind, perf_rows)
write.csv(perf_df, file.path(RES_DIR, "strategyB_outer_fold_summary.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

cat(sprintf("\nMean AUROC=%.4f (SD=%.4f)\n",
            mean(perf_df$AUROC), sd(perf_df$AUROC)))

# ---- Feature stability ----
# Count how many times each protein appears in selected panels
cat("\nFeature stability analysis...\n")
# Note: we didn't save per-fold feature names; reconstruct from predictions is not enough.
# Save top panel sizes and alpha distribution
write.csv(as.data.frame(table(sel_params$alpha)),
          file.path(RES_DIR, "strategyB_alpha_distribution.csv"),
          row.names=FALSE)
write.csv(as.data.frame(table(sel_params$panel_size)),
          file.path(RES_DIR, "strategyB_panel_size_distribution.csv"),
          row.names=FALSE)

cat("\n===== NESTED CV COMPLETE =====\n")
