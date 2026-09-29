#!/usr/bin/env Rscript
# V2 M15 — Discovery-only ML biomarker development (Strategy B primary).
#
# Population: 386 frozen Discovery participants (Control=115, Exposure=271).
# Outcome: Control vs Exposure (Low+High combined).
# Strategy B primary: NO Discovery-wide DE preselection.
# 5 outer x 5 inner x 3 repeats; fold-local preprocessing.
# glmnet binomial; alpha = {0.1,0.5,0.9,1}; panel caps {3,5,10,20}.
# One-SE rule; smallest panel tiebreak.
# Final lock on all 386, seed 20260929.
#
# ABSOLUTE FIREWALL: the 129 Validation participants are NEVER loaded in this script.

suppressPackageStartupMessages({ library(glmnet) })
set.seed(20260926)

root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"ml"); dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)
models_dir <- file.path(out_dir,"models"); dir.create(models_dir, showWarnings=FALSE)
results_dir <- file.path(out_dir,"results"); dir.create(results_dir, showWarnings=FALSE)

# ---- inputs: Discovery only -----------------------------------------------
log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
split <- read.csv(file.path(root,"descriptive","discovery_validation_split","discovery_validation_assignment.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)

# DISCOVERY ONLY — firewall: Validation IDs excluded
disc_ids <- split$UniqueSampleID[split$Split=="Discovery"]
stopifnot(length(disc_ids)==386)
val_ids <- split$UniqueSampleID[split$Split=="Validation"]
stopifnot(length(val_ids)==129)
# hard firewall: Discovery set is disjoint from Validation set
stopifnot(!any(intersect(disc_ids, val_ids)))

# align metadata
rownames(meta) <- meta$UniqueSampleID
m <- meta[disc_ids,]
# outcome: Control=0, Exposure=1 (Low+High)
m$y <- ifelse(m$TREAT1_clean=="control", 0L, 1L)
stopifnot(sum(m$y==0)==115, sum(m$y==1)==271)
cat("Discovery N=386; Control=115; Exposure=271\n")

# Q515 proteins
q515_ids <- univ$PG.ProteinGroups[univ$Q515==TRUE]
mat_samples <- disc_ids
y_mat <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y_mat)<-"numeric"
cat("Feature matrix:", nrow(y_mat), "proteins x", ncol(y_mat), "Discovery samples\n")

# ---- fold-local preprocessing helper -------------------------------------
# eligibility: protein must be observed in >=80% of training participants (fold-local)
preprocess_fold <- function(train_idx) {
  Xtr <- t(y_mat[, train_idx, drop=FALSE])
  # eligibility on training only
  elig <- colMeans(!is.na(Xtr)) >= 0.80
  Xtr_e <- Xtr[, elig, drop=FALSE]
  # median impute on training only
  medians <- apply(Xtr_e, 2, median, na.rm=TRUE)
  for (j in seq_len(ncol(Xtr_e))) Xtr_e[is.na(Xtr_e[,j]), j] <- medians[j]
  # scale on training only
  means <- colMeans(Xtr_e); sds <- apply(Xtr_e, 2, sd)
  sds[sds==0] <- 1
  Xtr_s <- scale(Xtr_e, center=means, scale=sds)
  list(elig=elig, medians=medians, means=means, sds=sds, Xtr=Xtr_s)
}

apply_preprocess <- function(idx, pp) {
  X <- t(y_mat[pp$elig, idx, drop=FALSE])
  for (j in seq_len(ncol(X))) X[is.na(X[,j]), j] <- pp$medians[j]
  scale(X, center=pp$means, scale=pp$sds)
}

# ---- panel-cap refit: rank by |coef|, keep top k, refit on those k features ----
fit_cap <- function(Xtr, ytr, alpha, k) {
  # first fit full enet to get ranking
  cv <- cv.glmnet(Xtr, ytr, family="binomial", alpha=alpha, nfolds=5,
                  nlambda=50, standardize=FALSE)
  lam <- cv$lambda.min
  g <- glmnet(Xtr, ytr, family="binomial", alpha=alpha, lambda=lam, standardize=FALSE)
  beta <- as.matrix(coef(g))[-1, ]  # drop intercept
  ord <- order(abs(beta), decreasing=TRUE)
  top <- ord[seq_len(min(k, length(ord)))]
  # refit on top k
  Xk <- Xtr[, top, drop=FALSE]
  gk <- glmnet(Xk, ytr, family="binomial", alpha=alpha, lambda=0, standardize=FALSE)
  list(model=gk, top=top, k=k)
}

# ---- single outer fold fit ------------------------------------------------
fit_outer <- function(train_idx, test_idx, ytr, yte, repeat_seed) {
  pp <- preprocess_fold(train_idx)
  Xtr <- pp$Xtr
  Xte <- apply_preprocess(test_idx, pp)
  # Strategy B: no preselection; evaluate alpha grid
  best <- NULL
  for (al in c(0.1,0.5,0.9,1.0)) {
    for (k in c(3,5,10,20)) {
      # inner 5-fold CV to pick lambda for this alpha,k
      set.seed(repeat_seed + round(al*100) + k)
      cv <- cv.glmnet(Xtr, ytr, family="binomial", alpha=al, nfolds=5,
                      nlambda=50, standardize=FALSE)
      lam <- cv$lambda.min
      # fit capped panel
      g <- glmnet(Xtr, ytr, family="binomial", alpha=al, lambda=lam, standardize=FALSE)
      beta <- as.matrix(coef(g))[-1,]
      ord <- order(abs(beta), decreasing=TRUE)
      top <- ord[seq_len(min(k,length(ord)))]
      Xk <- Xtr[,top,drop=FALSE]
      gk <- glmnet(Xk, ytr, family="binomial", alpha=al, lambda=0, standardize=FALSE)
      # inner loss (dev)
      p_tr <- predict(gk, newx=Xk, type="response")
      inner_loss <- mean((p_tr - ytr)^2)  # Brier as proxy
      # outer prediction
      Xte_k <- Xte[,top,drop=FALSE]
      p_te <- as.numeric(predict(gk, newx=Xte_k, type="response"))
      if (is.null(best) || inner_loss < best$inner_loss) {
        best <- list(alpha=al, k=k, top=top, inner_loss=inner_loss, p_te=p_te)
      }
    }
  }
  best
}

# ---- nested CV -------------------------------------------------------------
repeats <- 3
outer_folds <- 5
seeds <- c(20260926, 20260927, 20260928)
all_preds <- list()
all_metrics <- data.frame()

for (r in seq_len(repeats)) {
  set.seed(seeds[r])
  n <- length(disc_ids)
  # stratified folds
  idx0 <- which(m$y==0); idx1 <- which(m$y==1)
  fold0 <- sample(rep(1:outer_folds, length.out=length(idx0)))
  fold1 <- sample(rep(1:outer_folds, length.out=length(idx1)))
  folds <- integer(n); folds[idx0] <- fold0; folds[idx1] <- fold1
  for (o in 1:outer_folds) {
    test_idx <- which(folds==o); train_idx <- which(folds!=o)
    res <- fit_outer(train_idx, test_idx, m$y[train_idx], m$y[test_idx], seeds[r])
    for (i in seq_along(test_idx)) {
      all_preds[[length(all_preds)+1]] <- data.frame(
        sample=disc_ids[test_idx[i]], rep=r, fold=o,
        y=m$y[test_idx[i]], pred=res$p_te[i],
        alpha=res$alpha, k=res$k)
    }
  }
  cat(sprintf("Repeat %d/%d done\n", r, repeats))
}

pred <- do.call(rbind, all_preds)
write.csv(pred, file.path(results_dir,"M15_outer_predictions.csv"), row.names=FALSE)

# metrics
auc <- function(y, p) {
  r <- rank(p); n1 <- sum(y==1); n0 <- sum(y==0)
  (sum(r[y==1]) - n1*(n1+1)/2) / (n1*n0)
}
brier <- mean((pred$pred - pred$y)^2)
auroc <- auc(pred$y, pred$pred)
cat(sprintf("Nested CV: AUROC=%.3f Brier=%.4f\n", auroc, brier))

# panel size distribution
panel_dist <- as.data.frame(table(pred$k, pred$rep))
write.csv(panel_dist, file.path(results_dir,"M15_panel_size_distribution.csv"), row.names=FALSE)

# ---- final model lock on all 386, seed 20260929 --------------------------
set.seed(20260929)
Xall <- t(y_mat)
elig <- colMeans(!is.na(Xall)) >= 0.80
Xall_e <- Xall[,elig,drop=FALSE]
medians <- apply(Xall_e, 2, median, na.rm=TRUE)
for (j in seq_len(ncol(Xall_e))) Xall_e[is.na(Xall_e[,j]),j] <- medians[j]
means <- colMeans(Xall_e); sds <- apply(Xall_e,2,sd); sds[sds==0]<-1
Xall_s <- scale(Xall_e, center=means, scale=sds)

# choose final alpha,k by inner CV on all 386
best <- NULL
for (al in c(0.1,0.5,0.9,1.0)) {
  cv <- cv.glmnet(Xall_s, m$y, family="binomial", alpha=al, nfolds=5, nlambda=50, standardize=FALSE)
  for (k in c(3,5,10,20)) {
    g <- glmnet(Xall_s, m$y, family="binomial", alpha=al, lambda=cv$lambda.min, standardize=FALSE)
    beta <- as.matrix(coef(g))[-1,]
    top <- order(abs(beta), decreasing=TRUE)[seq_len(min(k,length(beta)))]
    Xk <- Xall_s[,top,drop=FALSE]
    gk <- glmnet(Xk, m$y, family="binomial", alpha=al, lambda=0, standardize=FALSE)
    p <- predict(gk, newx=Xk, type="response")
    bl <- mean((p-m$y)^2)
    if (is.null(best) || bl < best$inner_loss) {
      best <- list(alpha=al,k=k,top=top,inner_loss=bl)
    }
  }
}
final_feats <- colnames(Xall_e)[best$top]
gk <- glmnet(Xall_s[,best$top,drop=FALSE], m$y, family="binomial",
             alpha=best$alpha, lambda=0, standardize=FALSE)
coefs <- as.matrix(coef(gk))
rownames(coefs) <- c("Intercept", final_feats)

lock <- data.frame(
  item=c("module","task","population","n_discovery","n_control","n_exposure",
         "strategy","alpha","panel_k","n_features_selected","timestamp",
         "firewall_129_accessed"),
  value=c("M15","Control_vs_Exposure","Discovery_only",386,115,271,
          "Strategy_B_no_global_screen",best$alpha,best$k,length(final_feats),
          format(Sys.time(),"%Y-%m-%d %H:%M:%S %z"),"FALSE")
)
write.csv(lock, file.path(models_dir,"M15_model_manifest.csv"), row.names=FALSE)
write.csv(data.frame(protein=final_feats, coef=coefs[-1,1], row.names=NULL),
          file.path(models_dir,"M15_final_coefficients.csv"), row.names=FALSE)

cat(sprintf("M15 LOCKED: alpha=%.2f k=%d n=%d AUROC=%.3f\n",
  best$alpha, best$k, length(final_feats), auroc))
cat("M15_DONE\n")
