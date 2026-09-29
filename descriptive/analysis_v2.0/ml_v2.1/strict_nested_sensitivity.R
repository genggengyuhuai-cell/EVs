# =============================================================================
# strict_nested_sensitivity.R — v2.1 §7 strict whole-pipeline nested sensitivity
#
# For each of the 15 outer assessment splits (same seeds as fixed-85 run):
#   outer-train only -> fold-local feature universe -> fold-local High-vs-Low DE
#   -> LASSO (alpha=1) + Elastic Net (alpha<1) -> predict untouched outer test
#
# FORBIDDEN: fixed 85 list, D08, 29 replicated, 129 hold-out, pathway,
#            current ML importance, Boruta, XGBoost.
#
# Outputs to ./strict_nested/
# =============================================================================

suppressPackageStartupMessages({
  library(glmnet)
  library(pROC)
})

set.seed(20260928, kind="Mersenne-Twister", normal.kind="Inversion")

OUT_DIR  <- "descriptive/analysis_v2.0/ml_v2.1"
OUT2_DIR <- file.path(OUT_DIR, "strict_nested")
dir.create(OUT2_DIR, recursive=TRUE, showWarnings=FALSE)

# -----------------------------------------------------------------------------
# 1. Load data (same as fixed-85 run, but start from FULL 1434-protein universe)
# -----------------------------------------------------------------------------
cat("== 1. Loading full expression matrix (1434 proteins) ==\n")
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names=1, check.names=FALSE)
cat("  matrix:", nrow(expr), "proteins x", ncol(expr), "samples\n")

meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors=FALSE)
disc <- meta[meta$Split == "Discovery" & meta$TREAT1_clean %in% c("high","low"), ]
common_samps <- intersect(disc$UniqueSampleID, colnames(expr))
disc <- disc[match(common_samps, disc$UniqueSampleID), ]

# Full universe: ALL 1434 proteins, not just the 85
all_prots <- rownames(expr)
X <- t(as.matrix(expr[all_prots, disc$UniqueSampleID]))
cat("X (full universe):", nrow(X), "samples x", ncol(X), "proteins\n")
y <- as.integer(disc$TREAT1_clean == "high")
cat("y=1 (High):", sum(y==1), " y=0 (Low):", sum(y==0), "\n")

# -----------------------------------------------------------------------------
# 2. Reproduce the EXACT same 15 outer folds as the fixed-85 run
# -----------------------------------------------------------------------------
N_OUTER <- 5; N_REPEAT <- 3
OUTER_SEEDS <- c(20260928, 20260929, 20260930)
folds_list <- list()
for (r in seq_len(N_REPEAT)) {
  set.seed(OUTER_SEEDS[r], kind="Mersenne-Twister")
  idx_pos <- which(y == 1); idx_neg <- which(y == 0)
  fold_pos <- sample(rep(seq_len(N_OUTER), length.out=length(idx_pos)))
  fold_neg <- sample(rep(seq_len(N_OUTER), length.out=length(idx_neg)))
  fold_id <- integer(length(y))
  fold_id[idx_pos] <- fold_pos
  fold_id[idx_neg] <- fold_neg
  for (k in seq_len(N_OUTER)) {
    folds_list[[length(folds_list)+1]] <- list(rep_id=r, fold=k, test=which(fold_id==k))
  }
}
cat("Outer folds:", length(folds_list), "(must equal 15)\n")

# -----------------------------------------------------------------------------
# 3. Helpers
# -----------------------------------------------------------------------------
fit_pp <- function(Xtr) {
  imp <- apply(Xtr, 2, median, na.rm=TRUE)
  Xtr_i <- Xtr
  for (j in seq_len(ncol(Xtr_i))) Xtr_i[is.na(Xtr_i[,j]), j] <- imp[j]
  mu <- colMeans(Xtr_i); sd_ <- apply(Xtr_i, 2, sd); sd_[is.na(sd_)] <- 0
  list(imp=imp, mu=mu, sd=sd_)
}
apply_pp <- function(Xn, pp) {
  out <- Xn
  for (j in seq_len(ncol(out))) {
    out[is.na(out[,j]), j] <- pp$imp[j]
    out[,j] <- (out[,j] - pp$mu[j]) / ifelse(pp$sd[j]==0, 1, pp$sd[j])
  }
  out
}

# Fold-local DEP screen: per-protein linear model ~ group on training only,
# BH-FDR < 0.05, with 70% detection in BOTH High and Low groups.
fold_local_dep_screen <- function(Xtr, ytr, det_rate=0.70, fdr_thresh=0.05) {
  p <- ncol(Xtr)
  # 3a. Detection eligibility: finite & >0 in >=det_rate of each group
  hi <- Xtr[ytr==1, ]; lo <- Xtr[ytr==0, ]
  det_hi <- colMeans(is.finite(hi) & hi > 0, na.rm=TRUE)
  det_lo <- colMeans(is.finite(lo) & lo > 0, na.rm=TRUE)
  eligible <- (det_hi >= det_rate) & (det_lo >= det_rate)
  # 3b. Per-protein t-test on eligible proteins
  pvals <- rep(NA, p); log2fc <- rep(NA, p)
  for (j in which(eligible)) {
    a <- hi[,j]; b <- lo[,j]
    a <- a[is.finite(a)]; b <- b[is.finite(b)]
    if (length(a) < 5 || length(b) < 5) next
    tt <- tryCatch(t.test(a, b), error=function(e) NULL)
    if (is.null(tt)) next
    pvals[j] <- tt$p.value
    log2fc[j] <- mean(a, na.rm=TRUE) - mean(b, na.rm=TRUE)
  }
  padj <- p.adjust(pvals, method="BH")
  dep <- eligible & !is.na(padj) & padj < fdr_thresh
  list(eligible=eligible, pvals=pvals, padj=padj, log2fc=log2fc,
       dep=dep, n_eligible=sum(eligible), n_dep=sum(dep))
}

# AUPRC from predictions and binary labels
auprc <- function(ytrue, ypred) {
  ord <- order(ypred, decreasing=TRUE)
  y_sorted <- ytrue[ord]
  tp <- cumsum(y_sorted == 1); fp <- cumsum(y_sorted == 0)
  precision <- tp / (tp + fp)
  recall <- tp / sum(ytrue == 1)
  # Add (0,1) at start
  precision <- c(1, precision); recall <- c(0, recall)
  # Step-wise AUPRC
  dy <- diff(recall)
  sum(precision[-length(precision)] * dy) + sum(precision[-1] * dy) * 0  # trapezoid-ish
  # Use proper trapezoid
  sum(diff(recall) * (head(precision,-1) + tail(precision,-1)) / 2)
}

# -----------------------------------------------------------------------------
# 4. Outer loop
# -----------------------------------------------------------------------------
cat("\n== 2. Outer loop: 15 splits, fold-local DEP -> ML ==\n")

metrics_df <- data.frame()
universe_rows <- list()
dep_rows <- list()
lasso_feat_rows <- list()
en_feat_rows <- list()
pred_rows <- list()
tune_rows <- list()

for (fi in seq_along(folds_list)) {
  fo <- folds_list[[fi]]
  te_idx <- fo$test
  tr_idx <- setdiff(seq_len(nrow(X)), te_idx)
  Xtr_raw <- X[tr_idx, , drop=FALSE]; ytr <- y[tr_idx]
  Xte_raw <- X[te_idx, , drop=FALSE]; yte <- y[te_idx]

  cat(sprintf("  split %02d/15 (rep=%d, k=%d, n_train=%d, n_test=%d, prev=%d, pres=%d)\n",
              fi, fo$rep_id, fo$fold, length(tr_idx), length(te_idx),
              sum(ytr==1), sum(ytr==0)))

  # 4a. Fold-local DEP screen on outer train
  scr <- fold_local_dep_screen(Xtr_raw, ytr, det_rate=0.70, fdr_thresh=0.05)
  cat(sprintf("    eligible=%d, fold-local DEPs (BH<0.05)=%d\n", scr$n_eligible, scr$n_dep))

  universe_rows[[fi]] <- data.frame(
    rep_id=fo$rep_id, fold=fo$fold,
    n_train=length(tr_idx), n_test=length(te_idx),
    n_train_high=sum(ytr==1), n_train_low=sum(ytr==0),
    n_universe=ncol(X), n_eligible=scr$n_eligible, n_dep=scr$n_dep,
    stringsAsFactors=FALSE)

  dep_prots <- colnames(Xtr_raw)[scr$dep]
  for (p in dep_prots) {
    dep_rows[[length(dep_rows)+1]] <- data.frame(
      rep_id=fo$rep_id, fold=fo$fold, PG.ProteinGroups=p,
      padj=scr$padj[match(p, colnames(Xtr_raw))],
      log2fc_train=scr$log2fc[match(p, colnames(Xtr_raw))],
      stringsAsFactors=FALSE)
  }

  if (length(dep_prots) < 2) {
    cat("    SKIP: too few fold-local DEPs, recording failure\n")
    metrics_df <- rbind(metrics_df, data.frame(
      rep_id=fo$rep_id, fold=fo$fold,
      n_universe=ncol(X), n_eligible=scr$n_eligible, n_dep=length(dep_prots),
      n_features_ml=0, lasso_auroc=NA, lasso_auprc=NA,
      en_auroc=NA, en_auprc=NA, en_alpha=NA,
      failure="too_few_deps", stringsAsFactors=FALSE))
    next
  }

  # 4b. Subset to fold-local DEPs
  Xtr_dep <- Xtr_raw[, dep_prots, drop=FALSE]
  Xte_dep <- Xte_raw[, dep_prots, drop=FALSE]

  # 4c. Training-only preprocessing
  pp <- fit_pp(Xtr_dep)
  Xtr <- apply_pp(Xtr_dep, pp)
  Xte <- apply_pp(Xte_dep, pp)

  # Drop zero-variance features
  keep <- apply(Xtr, 2, sd, na.rm=TRUE) > 1e-10
  if (sum(keep) < 2) {
    metrics_df <- rbind(metrics_df, data.frame(
      rep_id=fo$rep_id, fold=fo$fold,
      n_universe=ncol(X), n_eligible=scr$n_eligible, n_dep=length(dep_prots),
      n_features_ml=sum(keep), lasso_auroc=NA, lasso_auprc=NA,
      en_auroc=NA, en_auprc=NA, en_alpha=NA,
      failure="zero_variance_after_impute", stringsAsFactors=FALSE))
    next
  }
  Xtr <- Xtr[, keep, drop=FALSE]; Xte <- Xte[, keep, drop=FALSE]
  ml_feats <- colnames(Xtr)

  # 4d. LASSO (alpha=1)
  set.seed(1000 + fi)
  cv_lasso <- cv.glmnet(Xtr, ytr, family="binomial", alpha=1,
                        nfolds=5, type.measure="auc",
                        standardize=FALSE, intercept=TRUE)
  lam_lasso <- cv_lasso$lambda.min
  cf_lasso <- as.matrix(coef(cv_lasso, s=lam_lasso))[-1, 1]
  lasso_sel <- names(cf_lasso)[abs(cf_lasso) > 1e-10]
  pred_lasso <- as.numeric(predict(cv_lasso, newx=Xte, s=lam_lasso, type="response"))
  auroc_lasso <- as.numeric(roc(yte, pred_lasso, quiet=TRUE)$auc)
  auprc_lasso <- auprc(yte, pred_lasso)

  for (p in lasso_sel) {
    lasso_feat_rows[[length(lasso_feat_rows)+1]] <- data.frame(
      rep_id=fo$rep_id, fold=fo$fold, PG.ProteinGroups=p,
      coefficient=cf_lasso[p], stringsAsFactors=FALSE)
  }

  # 4e. Elastic Net (alpha < 1)
  best_en_auc <- -Inf; best_en_alpha <- NA; best_en_lambda <- NA
  best_en_coef <- NULL; best_en_pred <- NULL
  for (a in c(0.1, 0.3, 0.5, 0.7)) {
    set.seed(2000L + fi*100L + as.integer(a*10))
    cv_en <- tryCatch(
      cv.glmnet(Xtr, ytr, family="binomial", alpha=a,
                nfolds=5, type.measure="auc",
                standardize=FALSE, intercept=TRUE),
      error=function(e) NULL)
    if (is.null(cv_en)) next
    i_best <- which.max(cv_en$cvm)
    if (cv_en$cvm[i_best] > best_en_auc) {
      best_en_auc <- cv_en$cvm[i_best]
      best_en_alpha <- a
      best_en_lambda <- cv_en$lambda.min
      best_en_coef <- as.matrix(coef(cv_en, s=best_en_lambda))[-1, 1]
      best_en_pred <- as.numeric(predict(cv_en, newx=Xte, s=best_en_lambda, type="response"))
    }
  }
  en_sel <- names(best_en_coef)[abs(best_en_coef) > 1e-10]
  auroc_en <- as.numeric(roc(yte, best_en_pred, quiet=TRUE)$auc)
  auprc_en <- auprc(yte, best_en_pred)

  for (p in en_sel) {
    en_feat_rows[[length(en_feat_rows)+1]] <- data.frame(
      rep_id=fo$rep_id, fold=fo$fold, PG.ProteinGroups=p,
      coefficient=best_en_coef[p], stringsAsFactors=FALSE)
  }

  tune_rows[[fi]] <- data.frame(
    rep_id=fo$rep_id, fold=fo$fold,
    n_ml_features=ncol(Xtr),
    lasso_lambda_min=lam_lasso,
    en_alpha=best_en_alpha, en_lambda_min=best_en_lambda,
    en_inner_best_auc=best_en_auc,
    stringsAsFactors=FALSE)

  # 4f. Predictions
  for (s in seq_along(te_idx)) {
    pred_rows[[length(pred_rows)+1]] <- data.frame(
      rep_id=fo$rep_id, fold=fo$fold,
      sample_id=disc$UniqueSampleID[te_idx[s]],
      y_true=yte[s],
      lasso_pred=pred_lasso[s],
      en_pred=best_en_pred[s],
      stringsAsFactors=FALSE)
  }

  metrics_df <- rbind(metrics_df, data.frame(
    rep_id=fo$rep_id, fold=fo$fold,
    n_universe=ncol(X), n_eligible=scr$n_eligible, n_dep=length(dep_prots),
    n_features_ml=ncol(Xtr),
    lasso_auroc=auroc_lasso, lasso_auprc=auprc_lasso,
    en_auroc=auroc_en, en_auprc=auprc_en,
    en_alpha=best_en_alpha,
    failure=NA_character_,
    stringsAsFactors=FALSE))

  cat(sprintf("    ML features=%d | LASSO AUC=%.3f AUPRC=%.3f (%d sel) | EN(a=%.1f) AUC=%.3f AUPRC=%.3f (%d sel)\n",
              ncol(Xtr), auroc_lasso, auprc_lasso, length(lasso_sel),
              best_en_alpha, auroc_en, auprc_en, length(en_sel)))
}

# -----------------------------------------------------------------------------
# 5. Write per-split outputs
# -----------------------------------------------------------------------------
cat("\n== 3. Writing outputs ==\n")

write.csv(do.call(rbind, pred_rows), file.path(OUT2_DIR, "strict_nested_outer_predictions.csv"), row.names=FALSE)
write.csv(metrics_df, file.path(OUT2_DIR, "strict_nested_outer_metrics.csv"), row.names=FALSE)
write.csv(do.call(rbind, universe_rows), file.path(OUT2_DIR, "strict_nested_feature_universe_by_split.csv"), row.names=FALSE)
write.csv(do.call(rbind, dep_rows), file.path(OUT2_DIR, "strict_nested_DEP_by_split.csv"), row.names=FALSE)
write.csv(do.call(rbind, lasso_feat_rows), file.path(OUT2_DIR, "strict_nested_LASSO_features_by_split.csv"), row.names=FALSE)
write.csv(do.call(rbind, en_feat_rows), file.path(OUT2_DIR, "strict_nested_ElasticNet_features_by_split.csv"), row.names=FALSE)
write.csv(do.call(rbind, tune_rows), file.path(OUT2_DIR, "strict_nested_tuning.csv"), row.names=FALSE)

# -----------------------------------------------------------------------------
# 6. Feature stability across 15 splits
# -----------------------------------------------------------------------------
cat("== 4. Feature stability ==\n")
all_prot <- colnames(X)

dep_tab <- do.call(rbind, dep_rows)
lasso_tab <- do.call(rbind, lasso_feat_rows)
en_tab <- do.call(rbind, en_feat_rows)

stab <- data.frame(PG.ProteinGroups=all_prot, stringsAsFactors=FALSE)
n_splits <- length(folds_list)

# DEP appearance frequency
stab$dep_appearance_freq <- sapply(all_prot, function(p) {
  if (nrow(dep_tab) == 0) return(0)
  sub <- dep_tab[dep_tab$PG.ProteinGroups == p, ]
  length(unique(paste(sub$rep_id, sub$fold, sep="_"))) / n_splits
})
# LASSO selection frequency (conditional on being available = was a DEP in that split)
stab$lasso_selection_freq <- sapply(all_prot, function(p) {
  avail <- dep_tab[dep_tab$PG.ProteinGroups == p, ]
  if (nrow(avail) == 0) return(NA_real_)
  avail_splits <- unique(paste(avail$rep_id, avail$fold, sep="_"))
  sel <- lasso_tab[lasso_tab$PG.ProteinGroups == p, ]
  sel_splits <- unique(paste(sel$rep_id, sel$fold, sep="_"))
  length(intersect(sel_splits, avail_splits)) / length(avail_splits)
})
# EN selection frequency
stab$en_selection_freq <- sapply(all_prot, function(p) {
  avail <- dep_tab[dep_tab$PG.ProteinGroups == p, ]
  if (nrow(avail) == 0) return(NA_real_)
  avail_splits <- unique(paste(avail$rep_id, avail$fold, sep="_"))
  sel <- en_tab[en_tab$PG.ProteinGroups == p, ]
  sel_splits <- unique(paste(sel$rep_id, sel$fold, sep="_"))
  length(intersect(sel_splits, avail_splits)) / length(avail_splits)
})
# Overall selection frequency across ALL splits (not conditional)
stab$overall_lasso_freq <- sapply(all_prot, function(p) {
  if (nrow(lasso_tab) == 0) return(0)
  sub <- lasso_tab[lasso_tab$PG.ProteinGroups == p, ]
  length(unique(paste(sub$rep_id, sub$fold, sep="_"))) / n_splits
})
stab$overall_en_freq <- sapply(all_prot, function(p) {
  if (nrow(en_tab) == 0) return(0)
  sub <- en_tab[en_tab$PG.ProteinGroups == p, ]
  length(unique(paste(sub$rep_id, sub$fold, sep="_"))) / n_splits
})

# Only keep proteins that ever appeared as a DEP
stab <- stab[stab$dep_appearance_freq > 0, ]
stab <- stab[order(-stab$dep_appearance_freq, -stab$overall_lasso_freq, -stab$overall_en_freq), ]
write.csv(stab, file.path(OUT2_DIR, "strict_nested_feature_stability.csv"), row.names=FALSE)

# -----------------------------------------------------------------------------
# 7. Manifest
# -----------------------------------------------------------------------------
man <- data.frame(
  item=c("protocol","task","outer_splits","outer_repeats","outer_seeds",
         "feature_universe","fold_local_rule","ml_models","inner_cv",
         "forbidden","preprocessing","created"),
  value=c("ANALYSIS_PLAN_v2.1 §7",
          "Discovery High vs Low, strict nested DEP->ML",
          N_OUTER, N_REPEAT, paste(OUTER_SEEDS, collapse=","),
          "1434 proteins (PRIMARY_dose_log2_expression.csv.gz, no D03 injection)",
          "70% detection in BOTH High+Low within outer train; t-test BH-FDR<0.05",
          "LASSO(alpha=1), ElasticNet(alpha in {0.1,0.3,0.5,0.7})",
          "5-fold stratified inner CV on outer train only",
          "fixed-85 list, D08, 29 replicated, 129 hold-out, pathway, prior ML importance, Boruta, XGBoost",
          "training-only median impute + center + scale",
          format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  stringsAsFactors=FALSE)
write.csv(man, file.path(OUT2_DIR, "strict_nested_manifest.csv"), row.names=FALSE)

# -----------------------------------------------------------------------------
# 8. Summary report
# -----------------------------------------------------------------------------
cat("\n=== STRICT NESTED SENSITIVITY SUMMARY ===\n")
cat("\n-- AUROC / AUPRC (non-failed splits) --\n")
ok <- metrics_df[is.na(metrics_df$failure), ]
cat("LASSO AUROC: median=", median(ok$lasso_auroc, na.rm=TRUE),
    " mean=", mean(ok$lasso_auroc, na.rm=TRUE),
    " range=[", min(ok$lasso_auroc, na.rm=TRUE), ",", max(ok$lasso_auroc, na.rm=TRUE), "]\n", sep="")
cat("LASSO AUPRC: median=", median(ok$lasso_auprc, na.rm=TRUE),
    " mean=", mean(ok$lasso_auprc, na.rm=TRUE), "\n", sep="")
cat("EN    AUROC: median=", median(ok$en_auroc, na.rm=TRUE),
    " mean=", mean(ok$en_auroc, na.rm=TRUE),
    " range=[", min(ok$en_auroc, na.rm=TRUE), ",", max(ok$en_auroc, na.rm=TRUE), "]\n", sep="")
cat("EN    AUPRC: median=", median(ok$en_auprc, na.rm=TRUE),
    " mean=", mean(ok$en_auprc, na.rm=TRUE), "\n", sep="")

cat("\n-- Fold-local DEPs per split --\n")
print(metrics_df[, c("rep_id","fold","n_eligible","n_dep","n_features_ml","failure")])

cat("\n-- Top recurring proteins (by DEP appearance freq) --\n")
print(head(stab, 20), row.names=FALSE)

cat("\n-- Anchor 5 recurrence under strict pipeline --\n")
anchors <- c("Q08378","Q8NG11","P22466","Q13316","P05019")
genes <- c("GOLGA3","TSPAN14","GAL","DMP1","IGF1")
for (i in seq_along(anchors)) {
  p <- anchors[i]; g <- genes[i]
  row <- stab[stab$PG.ProteinGroups == p, ]
  if (nrow(row) == 0) {
    cat(sprintf("  %s (%s): NOT a fold-local DEP in any split\n", g, p))
  } else {
    cat(sprintf("  %s (%s): DEP freq=%.2f, LASSO sel=%.2f, EN sel=%.2f\n",
                g, p, row$dep_appearance_freq,
                ifelse(is.na(row$lasso_selection_freq), -1, row$lasso_selection_freq),
                ifelse(is.na(row$en_selection_freq), -1, row$en_selection_freq)))
  }
}

cat("\nDone. Outputs in:", OUT2_DIR, "\n")
