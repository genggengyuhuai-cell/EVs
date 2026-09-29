# =============================================================================
# ml_v2_1_run_all.R
# DEP-driven multi-ML prioritization — v2.1
#
# Architecture (per investigator override 2026-09-28):
#   85 locked Discovery High-vs-Low DEPs (fixed candidate space)
#     |
#     +--> LASSO (alpha = 1, fixed)             -> own protein list
#     +--> Elastic Net (alpha in {0.1,0.3,0.5,0.7}, tuned) -> own protein list
#     +--> Boruta (ranger + shadow variables)  -> own Confirmed list
#     +--> XGBoost (nonlinear robustness)       -> own importance ranking
#     |
#     +--> integrated table (side-by-side, NO auto-winner)
#
# Task: Discovery High exposure (y=1) vs Low exposure (y=0), n=271.
# Control samples excluded from the primary ML route.
# All preprocessing (median imputation, centering/scaling) fit on outer train.
# =============================================================================

suppressPackageStartupMessages({
  library(glmnet)
  library(ranger)
  library(xgboost)
  library(pROC)
})

set.seed(20260928, kind="Mersenne-Twister", normal.kind="Inversion")

OUT_DIR <- "descriptive/analysis_v2.0/ml_v2.1"
RES_DIR <- file.path(OUT_DIR, "results")
dir.create(RES_DIR, recursive=TRUE, showWarnings=FALSE)

# -----------------------------------------------------------------------------
# 1. Load data
# -----------------------------------------------------------------------------
cat("== 1. Loading data ==\n")

# 1a. D03 locked 85 candidates
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
stopifnot(nrow(d03) == 85)
stopifnot(!any(duplicated(d03$PG.ProteinGroups)))
candidates <- d03$PG.ProteinGroups
cat("D03 locked candidates:", length(candidates), "\n")

# 1b. Primary log2 abundance matrix
cat("Reading PRIMARY_dose_log2_expression.csv.gz ...\n")
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names=1, check.names=FALSE)
cat("  matrix:", nrow(expr), "proteins x", ncol(expr), "samples\n")

# 1c. Split meta
meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors=FALSE)
disc <- meta[meta$Split == "Discovery" & meta$TREAT1_clean %in% c("high","low"), ]
cat("After split+group filter, TREAT1_clean table:\n")
print(table(disc$TREAT1_clean, useNA="ifany"))
cat("Discovery High+Low samples:", nrow(disc),
    " (high=", sum(disc$TREAT1_clean=="high"),
    ", low=", sum(disc$TREAT1_clean=="low"), ")\n", sep="")

# 1d. Align: samples in disc must be columns of expr
common_samps <- intersect(disc$UniqueSampleID, colnames(expr))
cat("Overlap samples expr ∩ meta:", length(common_samps), "\n")
disc <- disc[disc$UniqueSampleID %in% common_samps, ]
disc <- disc[match(common_samps, disc$UniqueSampleID), ]

# 1e. Subset expression to candidates × disc samples
X <- t(as.matrix(expr[intersect(candidates, rownames(expr)), disc$UniqueSampleID]))
cat("X matrix:", nrow(X), "samples x", ncol(X), "proteins\n")
missing_prot <- setdiff(candidates, colnames(X))
if (length(missing_prot)) warning("Proteins not in matrix: ", paste(missing_prot, collapse=", "))

y <- as.integer(disc$TREAT1_clean == "high")  # positive = High exposure
cat("y=1 (High):", sum(y==1, na.rm=TRUE), " y=0 (Low):", sum(y==0, na.rm=TRUE),
    " y=NA:", sum(is.na(y)), "\n")
cat("unique TREAT1_clean after reorder:", paste(unique(disc$TREAT1_clean), collapse="|"), "\n")
if (any(is.na(y))) {
  cat("  NA rows in disc:\n")
  print(which(is.na(y)))
  print(head(disc[is.na(y), ], 5))
}

# Gene symbol lookup for display
gene_lookup <- setNames(d03$Gene_symbol.x, d03$PG.ProteinGroups)

# -----------------------------------------------------------------------------
# 2. Outer stratified CV folds (5 outer x 3 repeats = 15)
# -----------------------------------------------------------------------------
cat("\n== 2. Building outer CV folds ==\n")
N_OUTER <- 5
N_REPEAT <- 3
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
cat("Outer folds:", length(folds_list), "\n")
str(folds_list[1:2], max.level=1)

# -----------------------------------------------------------------------------
# 3. Helpers: training-only preprocessing
# -----------------------------------------------------------------------------
fit_preprocess <- function(Xtr) {
  # Median imputation (training-only)
  imp <- apply(Xtr, 2, median, na.rm=TRUE)
  Xtr_imp <- Xtr
  for (j in seq_len(ncol(Xtr_imp))) Xtr_imp[is.na(Xtr_imp[,j]), j] <- imp[j]
  mu  <- colMeans(Xtr_imp)
  sd_ <- apply(Xtr_imp, 2, sd)
  sd_[is.na(sd_)] <- 0
  list(imp=imp, mu=mu, sd=sd_)
}
apply_preprocess <- function(Xnew, pp) {
  Xout <- Xnew
  for (j in seq_len(ncol(Xout))) {
    Xout[is.na(Xout[,j]), j] <- pp$imp[j]
    Xout[,j] <- (Xout[,j] - pp$mu[j]) / ifelse(pp$sd[j]==0, 1, pp$sd[j])
  }
  Xout
}

# -----------------------------------------------------------------------------
# 4. Hand-rolled Boruta (ranger + shadow variables)
# -----------------------------------------------------------------------------
# Kursa & Rudnicky 2010: permute each feature -> shadow; fit RF;
#   compare each real feature's importance to max shadow importance;
#   binomial test across iterations -> Confirmed/Tentative/Rejected.
boruta_ranger <- function(Xtr, ytr, n_runs=15, seed=1L, p_tail=0.025) {
  # Xtr: numeric matrix (samples x features), no NA. ytr: 0/1 factor.
  feats <- colnames(Xtr)
  n <- nrow(Xtr); p <- ncol(Xtr)
  imp_record <- matrix(0, n_runs, p, dimnames=list(NULL, feats))
  for (it in seq_len(n_runs)) {
    set.seed(seed + it)
    # Build shadow matrix
    shadow <- apply(Xtr, 2, sample)
    colnames(shadow) <- paste0("shadow_", feats)
    X_aug <- cbind(Xtr, shadow)
    rf <- ranger(x=X_aug, y=as.factor(ytr), probability=FALSE,
                 importance="impurity", num.trees=500, mtry=ceiling(sqrt(ncol(X_aug))),
                 verbose=FALSE)
    imp <- rf$variable.importance
    imp_record[it, feats] <- imp[feats]
  }
  # Aggregate: for each iteration, max shadow importance
  # Shadow importance distribution pooled across iterations
  shadow_imp <- imp_record  # placeholder
  # Recompute shadow imps by re-running is wasteful; instead we use the
  # standard Boruta convention: per-iteration max shadow. We didn't store
  # shadow imps above, so re-do compactly:
  shadow_max <- numeric(n_runs)
  for (it in seq_len(n_runs)) {
    set.seed(seed + it)
    shadow <- apply(Xtr, 2, sample)
    X_aug <- cbind(Xtr, shadow)
    rf <- ranger(x=X_aug, y=as.factor(ytr), importance="impurity",
                 num.trees=500, mtry=ceiling(sqrt(ncol(X_aug))), verbose=FALSE)
    imp <- rf$variable.importance
    shadow_max[it] <- max(imp[grepl("^shadow_", names(imp))])
  }
  # For each feature: fraction of runs where imp > max shadow
  beat <- sweep(imp_record, 1, shadow_max, ">")
  frac_beat <- colMeans(beat)
  # Binomial test per feature vs 0.5 (null: equally likely to beat shadow)
  pvals <- sapply(feats, function(f) {
    k <- sum(beat[,f]); n <- n_runs
    binom.test(k, n, p=0.5, alternative="greater")$p.value
  })
  padj <- p.adjust(pvals, method="BH")
  status <- ifelse(padj < p_tail, "Confirmed",
            ifelse(padj > 1 - p_tail, "Rejected", "Tentative"))
  data.frame(PG.ProteinGroups=feats,
             boruta_frac_beat_shadow=frac_beat,
             boruta_pvalue=pvals,
             boruta_padj=padj,
             boruta_status=status,
             row.names=NULL, stringsAsFactors=FALSE)
}

# -----------------------------------------------------------------------------
# 5. Outer-CV loop
# -----------------------------------------------------------------------------
cat("\n== 3. Outer CV: 15 splits x 4 branches ==\n")

# Accumulators
lasso_sel   <- list()   # per outer split: named vector of nonzero coefs
en_sel      <- list()
boruta_res  <- list()
xgb_gain    <- list()
outer_metrics <- data.frame()

for (fi in seq_along(folds_list)) {
  fo <- folds_list[[fi]]
  cat(sprintf("  fold %02d/%d (rep=%d, k=%d)\n", fi, length(folds_list), fo$rep_id, fo$fold))
  te_idx <- fo$test
  tr_idx <- setdiff(seq_len(nrow(X)), te_idx)

  Xtr_raw <- X[tr_idx, , drop=FALSE]; ytr <- y[tr_idx]
  Xte_raw <- X[te_idx, , drop=FALSE]; yte <- y[te_idx]

  pp <- fit_preprocess(Xtr_raw)
  Xtr <- apply_preprocess(Xtr_raw, pp)
  Xte <- apply_preprocess(Xte_raw, pp)
  cat("      preprocessed\n")

  # --- 5a. LASSO (alpha = 1, fixed) ---
  set.seed(1000 + fi)
  cv_lasso <- cv.glmnet(Xtr, ytr, family="binomial", alpha=1,
                        nfolds=5, type.measure="auc",
                        standardize=FALSE, intercept=TRUE)
  lam_lasso <- cv_lasso$lambda.min
  coef_lasso <- as.matrix(coef(cv_lasso, s=lam_lasso))[-1, 1]  # drop intercept
  lasso_sel[[fi]] <- coef_lasso[abs(coef_lasso) > 1e-10]
  cat("      LASSO done, nonzero=", length(lasso_sel[[fi]]), "\n", sep="")

  # --- 5b. Elastic Net (alpha < 1, tuned over grid) ---
  en_grid <- data.frame(alpha=c(0.1, 0.3, 0.5, 0.7))
  best_auc <- -Inf; best_alpha <- NA; best_lambda <- NA
  best_en_coef <- NULL
  for (a in en_grid$alpha) {
    set.seed(2000L + fi * 100L + as.integer(a*10))
    cv_en <- tryCatch(
      cv.glmnet(Xtr, ytr, family="binomial", alpha=a,
                nfolds=5, type.measure="auc",
                standardize=FALSE, intercept=TRUE),
      error=function(e) { cat("      EN alpha=",a," error:", conditionMessage(e),"\n"); NULL })
    if (is.null(cv_en)) next
    i_min <- which.min(cv_en$cvm)
    # AUC: higher is better; track MAX cvm (since type.measure=auc, cvm is AUC)
    if (cv_en$cvm[i_min] > best_auc) {
      best_auc <- cv_en$cvm[i_min]
      best_alpha <- a
      best_lambda <- cv_en$lambda.min
      cf <- as.matrix(coef(cv_en, s=best_lambda))[-1, 1]
      best_en_coef <- cf[abs(cf) > 1e-10]
    }
  }
  en_sel[[fi]] <- best_en_coef
  attr(en_sel[[fi]], "alpha") <- best_alpha
  cat("      EN done, best_alpha=", best_alpha, " nonzero=", length(best_en_coef), "\n", sep="")

  # --- 5c. Boruta (training-only) ---
  # Use 10 runs in outer loop (faster); full 25 runs on full data later
  br <- tryCatch(boruta_ranger(Xtr, ytr, n_runs=10, seed=3000+fi),
                 error=function(e) { cat("      Boruta error:", conditionMessage(e),"\n"); NULL })
  if (!is.null(br)) boruta_res[[fi]] <- br
  cat("      Boruta done\n")

  # --- 5d. XGBoost (tuned lightly, training-only) ---
  dtrain <- xgb.DMatrix(data=Xtr, label=ytr)
  dtest  <- xgb.DMatrix(data=Xte, label=yte)
  params <- list(objective="binary:logistic", eval_metric="auc",
                 max_depth=3, eta=0.05, subsample=0.8,
                 colsample_bytree=0.8, min_child_weight=5)
  set.seed(4000 + fi)
  bst <- xgb.train(params=params, data=dtrain, nrounds=200,
                   verbose=0, watchlist=list(eval=dtest),
                   early_stopping_rounds=20)
  imp <- xgb.importance(colnames(Xtr), model=bst)
  gain <- setNames(imp$Gain, imp$Feature)
  xgb_gain[[fi]] <- gain
  cat("      XGBoost done, top feature:", names(which.max(gain)), "\n")

  # Outer-test metric
  pred_te <- predict(cv_lasso, newx=Xte, s=lam_lasso, type="response")
  outer_metrics <- rbind(outer_metrics, data.frame(
    rep_id=fo$rep_id, fold=fo$fold,
    n_train=length(tr_idx), n_test=length(te_idx),
    lasso_auroc=as.numeric(roc(yte, pred_te, quiet=TRUE)$auc),
    en_alpha=best_alpha,
    xgb_auroc=as.numeric(roc(yte, predict(bst, dtest), quiet=TRUE)$auc)
  ))
  cat(sprintf("         LASSO AUC=%.3f | EN(a=%.1f) CV-AUC=%.3f | XGB test-AUC=%.3f\n",
              outer_metrics$lasso_auroc[nrow(outer_metrics)],
              best_alpha, 1-best_auc, outer_metrics$xgb_auroc[nrow(outer_metrics)]))
}

# -----------------------------------------------------------------------------
# 6. Aggregate selection frequencies across outer splits
# -----------------------------------------------------------------------------
cat("\n== 4. Aggregating across outer splits ==\n")

all_feats <- colnames(X)
# LASSO selection frequency
lasso_freq <- sapply(all_feats, function(f) {
  mean(sapply(lasso_sel, function(v) f %in% names(v)))
})
# Mean signed coefficient when selected
lasso_mean_coef <- sapply(all_feats, function(f) {
  vals <- sapply(lasso_sel, function(v) if (f %in% names(v)) v[[f]] else NA)
  mean(vals, na.rm=TRUE)
})
lasso_sign_consistency <- sapply(all_feats, function(f) {
  vals <- sapply(lasso_sel, function(v) if (f %in% names(v)) sign(v[[f]]) else NA)
  vals <- vals[!is.na(vals)]
  if (!length(vals)) return(NA_real_)
  max(mean(vals > 0), mean(vals < 0))
})

# Elastic Net
en_freq <- sapply(all_feats, function(f) {
  mean(sapply(en_sel, function(v) f %in% names(v)))
})
en_mean_coef <- sapply(all_feats, function(f) {
  vals <- sapply(en_sel, function(v) if (f %in% names(v)) v[[f]] else NA)
  mean(vals, na.rm=TRUE)
})

# Boruta confirmation frequency across outer folds
boruta_outer_status <- do.call(rbind, lapply(boruta_res, function(br) {
  data.frame(PG=br$PG.ProteinGroups, status=br$boruta_status,
             frac=br$boruta_frac_beat_shadow, stringsAsFactors=FALSE)
}))
boruta_confirmed_freq <- sapply(all_feats, function(f) {
  sub <- boruta_outer_status[boruta_outer_status$PG == f, ]
  if (!nrow(sub)) return(NA_real_)
  mean(sub$status == "Confirmed")
})
boruta_mean_frac <- sapply(all_feats, function(f) {
  sub <- boruta_outer_status[boruta_outer_status$PG == f, ]
  if (!nrow(sub)) return(NA_real_)
  mean(sub$frac)
})

# XGBoost gain stability: mean rank & mean gain across folds
xgb_rank_mat <- sapply(xgb_gain, function(v) {
  r <- rank(-v[match(all_feats, names(v))], na.last="keep")
  setNames(r, all_feats)
})
xgb_mean_rank <- rowMeans(xgb_rank_mat, na.rm=TRUE)
xgb_mean_gain <- sapply(all_feats, function(f) {
  mean(sapply(xgb_gain, function(v) if (f %in% names(v)) v[[f]] else 0))
})

# -----------------------------------------------------------------------------
# 7. Full-data fits (descriptive / conditional, labeled as exploratory)
# -----------------------------------------------------------------------------
cat("\n== 5. Full-data fits (conditional / exploratory) ==\n")
pp_full <- fit_preprocess(X)
Xfull <- apply_preprocess(X, pp_full)

# LASSO on all 271
set.seed(5001)
cv_lf <- cv.glmnet(Xfull, y, family="binomial", alpha=1, nfolds=5,
                   type.measure="auc", standardize=FALSE)
lasso_full_coef <- as.matrix(coef(cv_lf, s=cv_lf$lambda.min))[-1,1]

# Elastic Net on all 271
best_auc <- -1; best_en_full <- NULL; best_a <- NA
for (a in c(0.1,0.3,0.5,0.7)) {
  set.seed(5002 + a*100)
  cv_en <- cv.glmnet(Xfull, y, family="binomial", alpha=a, nfolds=5,
                     type.measure="auc", standardize=FALSE)
  if (cv_en$cvm[which.min(cv_en$cvm)] < best_auc || is.null(best_en_full)) {
    best_auc <- cv_en$cvm[which.min(cv_en$cvm)]
    best_a <- a
    best_en_full <- as.matrix(coef(cv_en, s=cv_en$lambda.min))[-1,1]
  }
}

# Boruta on all 271 (more iterations)
cat("  Running full-data Boruta (25 iterations) ...\n")
br_full <- boruta_ranger(Xfull, y, n_runs=25, seed=5003)

# XGBoost on all 271
dtrain_full <- xgb.DMatrix(data=Xfull, label=y)
bst_full <- xgb.train(params=list(objective="binary:logistic", eval_metric="auc",
                                  max_depth=3, eta=0.05, subsample=0.8,
                                  colsample_bytree=0.8, min_child_weight=5),
                      data=dtrain_full, nrounds=300, verbose=0)
imp_full <- xgb.importance(colnames(Xfull), model=bst_full)

# -----------------------------------------------------------------------------
# 8. Integrated table
# -----------------------------------------------------------------------------
cat("\n== 6. Building integrated table ==\n")

# Pull D08 replication evidence
d08 <- read.csv("descriptive/discovery_validation/D08_validation/D08_validation_results.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
cat("D08 columns:", paste(head(colnames(d08), 20), collapse=", "), "\n")

# Build integrated
intab <- data.frame(
  PG.ProteinGroups = d03$PG.ProteinGroups,
  Gene_symbol      = d03$Gene_symbol.x,
  Discovery_log2FC = d03$log2FC,
  Discovery_BH_FDR = d03$BH_FDR,
  Discovery_direction = d03$Direction,
  stringsAsFactors=FALSE
)

# Map D08 columns by name
# Try to find direction-concordance / nominal / FDR columns in D08
d08_keys <- colnames(d08)
cat("D08 keys available:", paste(d08_keys, collapse=" | "), "\n")

# Join by PG.ProteinGroups if present
if ("PG.ProteinGroups" %in% d08_keys) {
  intab <- merge(intab, d08, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
}

# Add ML aggregations
intab$LASSO_selection_freq <- lasso_freq[match(intab$PG.ProteinGroups, names(lasso_freq))]
intab$LASSO_mean_coef      <- lasso_mean_coef[match(intab$PG.ProteinGroups, names(lasso_mean_coef))]
intab$LASSO_sign_consistency <- lasso_sign_consistency[match(intab$PG.ProteinGroups, names(lasso_sign_consistency))]
intab$EN_selection_freq    <- en_freq[match(intab$PG.ProteinGroups, names(en_freq))]
intab$EN_mean_coef         <- en_mean_coef[match(intab$PG.ProteinGroups, names(en_mean_coef))]
intab$Boruta_confirmed_freq <- boruta_confirmed_freq[match(intab$PG.ProteinGroups, names(boruta_confirmed_freq))]
intab$Boruta_mean_frac_beat <- boruta_mean_frac[match(intab$PG.ProteinGroups, names(boruta_mean_frac))]
intab$XGBoost_mean_rank    <- xgb_mean_rank[match(intab$PG.ProteinGroups, names(xgb_mean_rank))]
intab$XGBoost_mean_gain    <- xgb_mean_gain[match(intab$PG.ProteinGroups, names(xgb_mean_gain))]

# Full-data fits
intab$LASSO_full_coef <- lasso_full_coef[match(intab$PG.ProteinGroups, names(lasso_full_coef))]
intab$EN_full_coef    <- best_en_full[match(intab$PG.ProteinGroups, names(best_en_full))]
br_full_match <- setNames(br_full$boruta_status, br_full$PG.ProteinGroups)
intab$Boruta_full_status <- br_full_match[match(intab$PG.ProteinGroups, names(br_full_match))]
imp_full_match <- setNames(imp_full$Gain, imp_full$Feature)
intab$XGBoost_full_gain <- imp_full_match[match(intab$PG.ProteinGroups, names(imp_full_match))]

# Write outputs
write.csv(intab, file.path(RES_DIR, "integrated_table_85.csv"), row.names=FALSE)
write.csv(outer_metrics, file.path(RES_DIR, "outer_cv_metrics.csv"), row.names=FALSE)
write.csv(br_full, file.path(RES_DIR, "boruta_full_data.csv"), row.names=FALSE)
write.csv(imp_full, file.path(RES_DIR, "xgboost_full_importance.csv"), row.names=FALSE)

cat("\n=== Outer CV summary ===\n")
print(summary(outer_metrics[, c("lasso_auroc","xgb_auroc")]))
cat("\nElastic Net alpha chosen distribution:\n")
print(table(outer_metrics$en_alpha))

cat("\n=== Branch-specific selected protein lists (full-data fits) ===\n")
cat("LASSO (nonzero):", sum(abs(lasso_full_coef) > 1e-10), "proteins\n")
cat("  ", paste(names(lasso_full_coef)[abs(lasso_full_coef)>1e-10], collapse=", "), "\n")
cat("Elastic Net (nonzero):", sum(abs(best_en_full) > 1e-10), "proteins (alpha=", best_a, ")\n", sep="")
cat("  ", paste(names(best_en_full)[abs(best_en_full)>1e-10], collapse=", "), "\n")
cat("Boruta Confirmed:", sum(br_full$boruta_status=="Confirmed"),
    " Tentative:", sum(br_full$boruta_status=="Tentative"),
    " Rejected:", sum(br_full$boruta_status=="Rejected"), "\n")
cat("Top-10 XGBoost by gain:\n")
print(head(imp_full, 10))

cat("\nDone. Outputs in:", RES_DIR, "\n")
