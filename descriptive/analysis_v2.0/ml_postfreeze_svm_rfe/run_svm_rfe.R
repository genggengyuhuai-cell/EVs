# =============================================================================
# Post-freeze exploratory: linear SVM-RFE on the 85 locked D03 Discovery DEPs
#
# Analysis_status: POST_FREEZE_EXPLORATORY
# Input_universe: 85 locked D03 Discovery DEPs (identical to ml_v2.1 fixed-85)
# Frozen_models_modified: NO
# Existing_frozen_results_recomputed: NO
#
# Feature elimination is nested inside outer CV (no full-data RFE leakage).
# Outer folds reproduce ml_v2.1 run_v2_1_ml.R exactly (seeds 20260928/29/30,
# 5 folds x 3 repeats, stratified within High/Low).
# Inner CV: 5-fold stratified on outer train; tunes C and subset size.
# Kernel: linear (per spec; linear SVM weights are directly interpretable).
# =============================================================================

suppressPackageStartupMessages({
  library(e1071)
  library(pROC)
})

set.seed(20260928, kind = "Mersenne-Twister", normal.kind = "Inversion")

OUT_DIR <- "descriptive/analysis_v2.0/ml_postfreeze_svm_rfe"
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# -----------------------------------------------------------------------------
# 1. Load data (identical to run_v2_1_ml.R)
# -----------------------------------------------------------------------------
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors = FALSE, check.names = FALSE)
stopifnot(nrow(d03) == 85)
stopifnot(!any(duplicated(d03$PG.ProteinGroups)))
candidates <- d03$PG.ProteinGroups
gene_lookup <- setNames(d03$Gene_symbol.x, d03$PG.ProteinGroups)

expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names = 1, check.names = FALSE)

meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors = FALSE)
disc <- meta[meta$Split == "Discovery" & meta$TREAT1_clean %in% c("high", "low"), ]
common_samps <- intersect(disc$UniqueSampleID, colnames(expr))
disc <- disc[disc$UniqueSampleID %in% common_samps, ]
disc <- disc[match(common_samps, disc$UniqueSampleID), ]

X <- t(as.matrix(expr[intersect(candidates, rownames(expr)), disc$UniqueSampleID]))
y <- as.integer(disc$TREAT1_clean == "high")
cat("X:", nrow(X), "samples x", ncol(X), "proteins; y=1:", sum(y == 1), "y=0:", sum(y == 0), "\n")

# -----------------------------------------------------------------------------
# 2. Outer folds (exact reproduction of run_v2_1_ml.R lines 95-107)
# -----------------------------------------------------------------------------
N_OUTER <- 5; N_REPEAT <- 3
OUTER_SEEDS <- c(20260928, 20260929, 20260930)
folds_list <- list()
for (r in seq_len(N_REPEAT)) {
  set.seed(OUTER_SEEDS[r], kind = "Mersenne-Twister")
  idx_pos <- which(y == 1); idx_neg <- which(y == 0)
  fold_pos <- sample(rep(seq_len(N_OUTER), length.out = length(idx_pos)))
  fold_neg <- sample(rep(seq_len(N_OUTER), length.out = length(idx_neg)))
  fold_id <- integer(length(y))
  fold_id[idx_pos] <- fold_pos
  fold_id[idx_neg] <- fold_neg
  for (k in seq_len(N_OUTER)) {
    folds_list[[length(folds_list) + 1]] <- list(rep_id = r, fold = k, test = which(fold_id == k))
  }
}
cat("Outer folds:", length(folds_list), "\n")

# -----------------------------------------------------------------------------
# 3. Preprocessing (training-only; identical contract to run_v2_1_ml.R)
# -----------------------------------------------------------------------------
fit_preprocess <- function(Xtr) {
  imp <- apply(Xtr, 2, median, na.rm = TRUE)
  Xtr_imp <- Xtr
  for (j in seq_len(ncol(Xtr_imp))) Xtr_imp[is.na(Xtr_imp[, j]), j] <- imp[j]
  mu <- colMeans(Xtr_imp)
  sd_ <- apply(Xtr_imp, 2, sd)
  sd_[is.na(sd_)] <- 0
  list(imp = imp, mu = mu, sd = sd_)
}
apply_preprocess <- function(Xnew, pp) {
  Xout <- Xnew
  for (j in seq_len(ncol(Xout))) {
    Xout[is.na(Xout[, j]), j] <- pp$imp[j]
    Xout[, j] <- (Xout[, j] - pp$mu[j]) / ifelse(pp$sd[j] == 0, 1, pp$sd[j])
  }
  Xout
}

# -----------------------------------------------------------------------------
# 4. Linear SVM weight extraction + RFE ranking
# -----------------------------------------------------------------------------
# Linear SVM weights: w = sum over support vectors of (coef * y * x)
# e1071::svm with linear kernel returns coef (dual coefficients) and SV.
svm_linear_weights <- function(Xtr, ytr, C) {
  m <- e1071::svm(x = Xtr, y = as.factor(ytr), kernel = "linear",
                  type = "C-classification", cost = C,
                  probability = TRUE, scale = FALSE)
  # SV matrix
  SV <- m$SV
  # dual coef: rows = SV, column 1 (binary) = alpha_i * y_i
  dc <- as.numeric(m$coefs)
  # w = t(dc) %*% SV
  w <- as.numeric(crossprod(dc, SV))
  names(w) <- colnames(Xtr)
  list(model = m, w = w)
}

# RFE elimination order: returns feature names ordered from first-eliminated (worst)
# to last-eliminated (best). Uses w^2 criterion.
rfe_ranking <- function(Xtr, ytr, C, chunk = 10) {
  remaining <- colnames(Xtr)
  elim_order <- character(0)
  while (length(remaining) > 1) {
    fit <- svm_linear_weights(Xtr[, remaining, drop = FALSE], ytr, C)
    crit <- fit$w^2
    # eliminate the weakest chunk (at least 1)
    k <- min(max(1, floor(length(remaining) * 0.25)), length(remaining) - 1)
    o <- order(crit)
    doomed <- remaining[o[seq_len(k)]]
    elim_order <- c(elim_order, doomed)
    remaining <- setdiff(remaining, doomed)
  }
  elim_order <- c(elim_order, remaining)  # last remaining = best
  # reverse: best first
  ranking <- rev(elim_order)
  ranking
}

# -----------------------------------------------------------------------------
# 5. Inner CV: choose (C, subset size) for each outer train
# -----------------------------------------------------------------------------
C_GRID <- c(0.1, 1, 10)
SUBSET_GRID <- c(1, 2, 3, 5, 10, 15, 20, 30, 40, 60, 85)

inner_cv_auroc <- function(Xtr, ytr, C, subset_size, ranking, n_inner = 5) {
  # ranking: best-first feature order for this C
  feats <- ranking[seq_len(subset_size)]
  Xi <- Xtr[, feats, drop = FALSE]
  # stratified inner folds
  n <- nrow(Xi)
  pos <- which(ytr == 1); neg <- which(ytr == 0)
  set.seed(4242)
  fp <- sample(rep(seq_len(n_inner), length.out = length(pos)))
  fn <- sample(rep(seq_len(n_inner), length.out = length(neg)))
  fold_id <- integer(n)
  fold_id[pos] <- fp; fold_id[neg] <- fn
  aucs <- numeric(n_inner)
  for (k in seq_len(n_inner)) {
    te <- which(fold_id == k); tr <- setdiff(seq_len(n), te)
    m <- tryCatch(
      e1071::svm(x = Xi[tr, , drop = FALSE], y = as.factor(ytr[tr]),
                 kernel = "linear", type = "C-classification", cost = C,
                 probability = TRUE, scale = FALSE),
      error = function(e) NULL)
    if (is.null(m)) { aucs[k] <- NA; next }
    pp <- predict(m, Xi[te, , drop = FALSE], probability = TRUE)
    p <- as.numeric(attr(pp, "probabilities")[, "1"])
    if (length(unique(ytr[te])) < 2) { aucs[k] <- NA; next }
    aucs[k] <- as.numeric(pROC::roc(ytr[te], p, quiet = TRUE)$auc)
  }
  mean(aucs, na.rm = TRUE)
}

# -----------------------------------------------------------------------------
# 6. Outer CV loop
# -----------------------------------------------------------------------------
outer_metrics <- data.frame()
fold_selected <- data.frame()
feature_counts <- numeric(length(folds_list))

for (fi in seq_along(folds_list)) {
  fld <- folds_list[[fi]]
  te_idx <- fld$test
  tr_idx <- setdiff(seq_len(nrow(X)), te_idx)

  pp <- fit_preprocess(X[tr_idx, ])
  Xtr <- apply_preprocess(X[tr_idx, ], pp)
  Xte <- apply_preprocess(X[te_idx, ], pp)
  ytr <- y[tr_idx]; yte <- y[te_idx]

  # For each C, run RFE on outer train (full), then inner-CV score subset sizes.
  best_mean <- -Inf; best_C <- NA; best_size <- NA; best_sd <- NA
  cv_table <- data.frame()
  for (C in C_GRID) {
    rk <- rfe_ranking(Xtr, ytr, C)
    for (sz in SUBSET_GRID) {
      a <- inner_cv_auroc(Xtr, ytr, C, sz, rk)
      cv_table <- rbind(cv_table, data.frame(C = C, size = sz, inner_auc = a))
    }
  }
  # Pick best mean; 1-SE tie-break: smallest size within 1 SE of max
  agg <- aggregate(inner_auc ~ C + size, cv_table,
                  function(x) c(mean = mean(x, na.rm = TRUE), sd = sd(x, na.rm = TRUE)))
  agg$mean <- agg$inner_auc[, "mean"]
  agg$sd <- agg$inner_auc[, "sd"]
  agg$sd[is.na(agg$sd)] <- 0
  best_row <- agg[which.max(agg$mean), ]
  best_mean <- best_row$mean
  best_se <- best_row$sd / sqrt(5)  # 5 inner folds
  eligible <- agg[agg$mean >= (best_mean - best_se), ]
  chosen <- eligible[which.min(eligible$size), ]
  best_C <- chosen$C; best_size <- chosen$size

  # Final RFE on outer train with chosen C, take top best_size
  rk_final <- rfe_ranking(Xtr, ytr, best_C)
  selected_feats <- rk_final[seq_len(best_size)]
  feature_counts[fi] <- best_size

  # Train final linear SVM on selected features
  mfinal <- e1071::svm(x = Xtr[, selected_feats, drop = FALSE], y = as.factor(ytr),
                       kernel = "linear", type = "C-classification", cost = best_C,
                       probability = TRUE, scale = FALSE)
  pp_test <- predict(mfinal, Xte[, selected_feats, drop = FALSE], probability = TRUE)
  p_test <- as.numeric(attr(pp_test, "probabilities")[, "1"])

  # AUROC / AUPRC
  roc_obj <- pROC::roc(yte, p_test, quiet = TRUE)
  auroc <- as.numeric(roc_obj$auc)
  # AUPRC (trapezoid on precision-recall)
  ord <- order(p_test, decreasing = TRUE)
  yt <- yte[ord]; pt <- p_test[ord]
  cum_tp <- cumsum(yt == 1); cum_fp <- cumsum(yt == 0)
  prec <- cum_tp / pmax(1, cum_tp + cum_fp)
  rec <- cum_tp / max(1, sum(yte == 1))
  # trapz
  auprc <- sum(diff(rec) * (prec[-length(prec)] + prec[-1]) / 2)

  outer_metrics <- rbind(outer_metrics, data.frame(
    rep_id = fld$rep_id, fold = fld$fold,
    n_train = length(tr_idx), n_test = length(te_idx),
    chosen_C = best_C, chosen_subset_size = best_size,
    inner_best_auc = best_mean,
    auroc = auroc, auprc = auprc))

  for (feat in selected_feats) {
    fold_selected <- rbind(fold_selected, data.frame(
      rep_id = fld$rep_id, fold = fld$fold,
      PG = feat, gene = gene_lookup[feat],
      selected = 1, C = best_C))
  }
  cat(sprintf("fold %02d (rep=%d f=%d): C=%s size=%d innerAUC=%.3f AUROC=%.3f AUPRC=%.3f\n",
              fi, fld$rep_id, fld$fold, best_C, best_size, best_mean, auroc, auprc))
}

# -----------------------------------------------------------------------------
# 7. Feature stability across 15 outer folds
# -----------------------------------------------------------------------------
all_pg <- candidates
stab <- data.frame(
  PG = all_pg,
  gene = gene_lookup[all_pg],
  stringsAsFactors = FALSE)
sel_mat <- matrix(0, nrow = length(all_pg), ncol = length(folds_list),
                  dimnames = list(all_pg, paste0("r", seq_along(folds_list))))
for (i in seq_len(nrow(fold_selected))) {
  col <- which(fold_selected$rep_id[i] == sapply(folds_list, `[[`, "rep_id") &
               fold_selected$fold[i] == sapply(folds_list, `[[`, "fold"))
  sel_mat[fold_selected$PG[i], col] <- 1
}
stab$selection_count <- rowSums(sel_mat)
stab$selection_frequency <- stab$selection_count / length(folds_list)
stab <- stab[order(-stab$selection_frequency, stab$PG), ]

# -----------------------------------------------------------------------------
# 8. Write outputs
# -----------------------------------------------------------------------------
write.csv(outer_metrics, file.path(OUT_DIR, "svm_rfe_outer_metrics.csv"),
          row.names = FALSE, quote = TRUE)
write.csv(stab, file.path(OUT_DIR, "svm_rfe_feature_stability.csv"),
          row.names = FALSE, quote = TRUE)
write.csv(fold_selected, file.path(OUT_DIR, "svm_rfe_fold_selected_features.csv"),
          row.names = FALSE, quote = TRUE)

cat("\n=== SUMMARY ===\n")
cat("Outer folds:", nrow(outer_metrics), "\n")
cat("Selected feature count per fold: median=", median(feature_counts),
    " range=", min(feature_counts), "-", max(feature_counts), "\n")
cat("AUROC: mean=", mean(outer_metrics$auroc), " median=", median(outer_metrics$auroc),
    " range=", min(outer_metrics$auroc), "-", max(outer_metrics$auroc), "\n")
cat("AUPRC: mean=", mean(outer_metrics$auprc), " median=", median(outer_metrics$auprc),
    " range=", min(outer_metrics$auprc), "-", max(outer_metrics$auprc), "\n")
cat("Freq>=0.70:", sum(stab$selection_frequency >= 0.70), "\n")
cat("Freq>=0.80:", sum(stab$selection_frequency >= 0.80), "\n")
cat("Freq>=0.93:", sum(stab$selection_frequency >= 0.93), "\n")
cat("Top by frequency:\n")
print(head(stab[stab$selection_frequency > 0, ], 20))
