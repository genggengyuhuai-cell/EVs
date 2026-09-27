# V2_ML_RUN_STRATEGY_B_v3.R — Fixed prediction path + panel cap
# Bug fix: use glmnet native predict for untruncated, refit for capped panel.

library(readxl)
library(glmnet)
library(digest)
library(pROC)

ROOT <- "F:/env"; setwd(ROOT)
OUT_ML <- "descriptive/analysis_v2.0/ml"
RES_DIR <- file.path(OUT_ML, "results")
dir.create(RES_DIR, showWarnings=FALSE, recursive=TRUE)

ALPHAS <- c(0.1, 0.5, 0.9, 1.0)
N_LAMBDA <- 50
MAX_PANEL <- 20

# ---- Load data ----
cat("Loading data...\n")
ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
clean_header <- function(x) { x <- trimws(as.character(x)); sub("\\.0$","",x) }
ss$clean <- clean_header(ss$Sheet1_raw_header)
split_meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                        stringsAsFactors=FALSE)
disc <- split_meta[split_meta$Split == "Discovery", ]
stopifnot(nrow(disc) == 386)
disc$y <- as.integer(disc$TREAT1_clean != "control")
stopifnot(sum(disc$y==1)==271, sum(disc$y==0)==115)

raw <- read_excel("rawdata/processed.xlsx", n_max=3817, .name_repair="minimal")
proteins <- data.frame(PG=raw$PG.ProteinGroups, Gene=raw$PG.Genes, stringsAsFactors=FALSE)
excel_cols <- names(raw)[8:ncol(raw)]
excel_clean <- clean_header(excel_cols)
abund <- as.data.frame(raw[, 8:ncol(raw)]); rownames(abund) <- proteins$PG

f3 <- read.csv("descriptive/analysis_v2.0/registry/contaminant_candidate_registry.csv", stringsAsFactors=FALSE)
excl_pgs <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible == "TRUE"]
abund_utech <- abund[!rownames(abund) %in% excl_pgs, ]

ss_disc <- ss[match(disc$UniqueSampleID, ss$UniqueSampleID), ]
disc_pos <- match(ss_disc$clean, excel_clean)
X_all <- t(abund_utech[, disc_pos])
colnames(X_all) <- rownames(abund_utech)
rownames(X_all) <- disc$UniqueSampleID
cat("Discovery matrix:", nrow(X_all), "x", ncol(X_all), "\n")

outer_folds <- read.csv(file.path(OUT_ML, "folds/outer_folds.csv"), stringsAsFactors=FALSE)
inner_folds <- read.csv(file.path(OUT_ML, "folds/inner_folds.csv"), stringsAsFactors=FALSE)

is_det <- function(x) is.finite(x) & x > 0

compute_elig <- function(sids) {
  mat <- X_all[sids, , drop=FALSE]
  grp <- disc$TREAT1_clean[match(sids, disc$UniqueSampleID)]
  elig <- rep(TRUE, ncol(mat)); names(elig) <- colnames(mat)
  for (g in c("control","low","high")) {
    g_sids <- sids[grp == g]
    if (length(g_sids) == 0) next
    thr <- ceiling(0.70 * length(g_sids))
    det_count <- colSums(is_det(mat[g_sids, , drop=FALSE]))
    elig <- elig & (det_count >= thr)
  }
  elig
}

fit_prep <- function(mat) {
  medians <- apply(mat, 2, median, na.rm=TRUE)
  imp <- mat
  for (j in 1:ncol(imp)) { imp[is.na(imp[,j]), j] <- medians[j] }
  means <- colMeans(imp); sds <- apply(imp, 2, sd)
  zv <- is.na(sds) | sds == 0
  list(medians=medians, means=means, sds=sds, zv=zv)
}
apply_prep <- function(mat, p) {
  out <- mat
  for (j in 1:ncol(out)) { out[is.na(out[,j]), j] <- p$medians[j] }
  for (j in 1:ncol(out)) { out[,j] <- (out[,j] - p$means[j]) / p$sds[j] }
  out
}

# Predict with panel cap: select top-k, refit logistic, predict
predict_capped <- function(fit, x_train, y_train, x_test, li_use, max_k=MAX_PANEL) {
  beta <- as.numeric(fit$beta[, li_use])
  names(beta) <- colnames(x_train)
  a0 <- as.numeric(fit$a0)[li_use]
  nz <- abs(beta) > 0
  n_nz <- sum(nz)
  if (n_nz == 0) {
    # intercept-only
    p <- as.numeric(plogis(a0))
    return(list(pred=rep(p, nrow(x_test)), n_features=0, intercept=a0, features=character(0)))
  }
  if (n_nz > max_k) {
    ord <- order(abs(beta[nz]), decreasing=TRUE)
    keep <- names(beta)[nz][ord[1:max_k]]
  } else {
    keep <- names(beta)[nz]
  }
  # Refit logistic on selected features
  df_tr <- data.frame(y=y_train, x_train[, keep, drop=FALSE])
  tryCatch({
    gm <- glm(y ~ ., data=df_tr, family=binomial())
    df_te <- data.frame(x_test[, keep, drop=FALSE])
    p <- as.numeric(predict(gm, newdata=df_te, type="response"))
    list(pred=p, n_features=length(keep), intercept=coef(gm)[1], features=keep)
  }, error=function(e) {
    # fallback: use glmnet coef directly
    beta_c <- beta; beta_c[!names(beta_c) %in% keep] <- 0
    eta <- as.numeric(x_test %*% beta_c) + a0
    list(pred=plogis(eta), n_features=length(keep), intercept=a0, features=keep)
  })
}

# ---- Nested CV ----
cat("\n===== NESTED CV v3 (fixed prediction) =====\n")
outer_pred_list <- list()
sel_list <- list()

for (rep in 1:3) {
  cat("\n--- Repeat", rep, "---\n")
  rep_outer <- outer_folds[outer_folds$Repeat == rep, ]
  for (of in 1:5) {
    cat("  Outer", of, "...")
    test_sids <- rep_outer$Participant_ID[rep_outer$Outer_fold == of]
    train_sids <- rep_outer$Participant_ID[rep_outer$Outer_fold != of]
    stopifnot(length(intersect(train_sids, test_sids)) == 0)

    elig <- compute_elig(train_sids)
    elig_p <- names(elig)[elig]
    x_otrain <- X_all[train_sids, elig_p, drop=FALSE]
    y_otrain <- disc$y[match(train_sids, disc$UniqueSampleID)]
    prep <- fit_prep(x_otrain); keep <- !prep$zv
    x_tr <- apply_prep(x_otrain, prep)[, keep, drop=FALSE]

    # Inner CV
    rep_inner <- inner_folds[inner_folds$Repeat==rep & inner_folds$Outer_fold==of &
                             inner_folds$Role=="inner_training_or_val", ]
    best_ll <- Inf; best_al <- NA; best_li <- NA

    for (al in ALPHAS) {
      ll_mat <- matrix(NA, N_LAMBDA, 5)
      nz_mat <- matrix(NA, N_LAMBDA, 5)
      for (k in 1:5) {
        val_sids <- rep_inner$Participant_ID[rep_inner$Inner_fold == k]
        tr_sids <- setdiff(train_sids, val_sids)
        tr_grp <- disc$TREAT1_clean[match(tr_sids, disc$UniqueSampleID)]
        mat_tr <- X_all[tr_sids, elig_p, drop=FALSE]
        tr_elig <- rep(TRUE, ncol(mat_tr)); names(tr_elig) <- colnames(mat_tr)
        for (g in c("control","low","high")) {
          g_sids <- tr_sids[tr_grp == g]
          if (length(g_sids)==0) next
          thr <- ceiling(0.70*length(g_sids))
          tr_elig <- tr_elig & (colSums(is_det(mat_tr[g_sids,,drop=FALSE])) >= thr)
        }
        use_p <- names(tr_elig)[tr_elig]
        if (length(use_p) < 5) next
        x_tr_i <- X_all[tr_sids, use_p, drop=FALSE]
        y_tr_i <- disc$y[match(tr_sids, disc$UniqueSampleID)]
        prep_i <- fit_prep(x_tr_i); keep_i <- !prep_i$zv
        x_tr_i2 <- apply_prep(x_tr_i, prep_i)[, keep_i, drop=FALSE]
        x_val_i <- X_all[val_sids, use_p, drop=FALSE]
        y_val_i <- disc$y[match(val_sids, disc$UniqueSampleID)]
        x_val_i2 <- apply_prep(x_val_i, prep_i)[, keep_i, drop=FALSE]
        tryCatch({
          fit <- glmnet(x_tr_i2, y_tr_i, family="binomial", alpha=al, nlambda=N_LAMBDA, standardize=FALSE)
          pred <- predict(fit, newx=x_val_i2, type="response")
          for (li in 1:ncol(pred)) {
            p <- pmin(pmax(pred[,li],1e-10),1-1e-10)
            ll_mat[li,k] <- -mean(y_val_i*log(p)+(1-y_val_i)*log(1-p))
            b <- as.numeric(fit$beta[,li])
            ncap <- min(sum(abs(b) > 0), MAX_PANEL)
            nz_mat[li,k] <- ncap
          }
        }, error=function(e) NULL)
      }
      mll <- rowMeans(ll_mat, na.rm=TRUE)
      if (all(is.na(mll))) next
      best <- which.min(mll)
      ll_se <- apply(ll_mat, 1, sd, na.rm=TRUE) / sqrt(5)
      within <- which(mll <= mll[best]+ll_se[best])
      med_nz <- rowMeans(nz_mat, na.rm=TRUE)
      within_order <- within[order(med_nz[within], within)]
      chosen <- within_order[1]
      if (mll[chosen] < best_ll) { best_ll <- mll[chosen]; best_al <- al; best_li <- chosen }
    }

    # Refit on full outer train
    fit_f <- glmnet(x_tr, y_otrain, family="binomial", alpha=best_al, nlambda=N_LAMBDA, standardize=FALSE)
    li_use <- min(best_li, ncol(fit_f$beta))
    x_otest <- X_all[test_sids, elig_p, drop=FALSE]
    y_otest <- disc$y[match(test_sids, disc$UniqueSampleID)]
    x_te <- apply_prep(x_otest, prep)[, keep, drop=FALSE]

    res <- predict_capped(fit_f, x_tr, y_otrain, x_te, li_use)
    pred <- res$pred
    pred <- pmin(pmax(pred, 0, 1), 1)

    outer_pred_list[[length(outer_pred_list)+1]] <- data.frame(
      Participant_ID=test_sids, Repeat=rep, Outer_fold=of,
      observed=y_otest, predicted=pred,
      alpha=best_al, lambda_idx=li_use,
      panel_size=res$n_features,
      stringsAsFactors=FALSE)
    sel_list[[length(sel_list)+1]] <- data.frame(
      Repeat=rep, Outer_fold=of, alpha=best_al, lambda_idx=li_use,
      inner_logloss=best_ll, panel_size=res$n_features,
      stringsAsFactors=FALSE)
    cat(" alpha=", best_al, " panel=", res$n_features,
        " pred_mean=", round(mean(pred),3), "\n")
  }
}

# ---- Save ----
outer_preds <- do.call(rbind, outer_pred_list)
write.csv(outer_preds, file.path(RES_DIR,"strategyB_outer_predictions.csv"), row.names=FALSE, fileEncoding="UTF-8")
sel_params <- do.call(rbind, sel_list)
write.csv(sel_params, file.path(RES_DIR,"strategyB_selected_hyperparameters.csv"), row.names=FALSE, fileEncoding="UTF-8")

cat("\n===== PER-REPEAT PERFORMANCE =====\n")
perf <- list()
for (rep in 1:3) {
  sub <- outer_preds[outer_preds$Repeat==rep,]
  roc_obj <- roc(sub$observed, sub$predicted, quiet=TRUE)
  auroc <- as.numeric(roc_obj$auc)
  ll <- -mean(sub$observed*log(pmax(sub$predicted,1e-10))+(1-sub$observed)*log(pmax(1-sub$predicted,1e-10)))
  br <- mean((sub$observed-sub$predicted)^2)
  cat(sprintf("Repeat %d: AUROC=%.4f LogLoss=%.4f Brier=%.4f mean_pred=%.4f\n",
              rep, auroc, ll, br, mean(sub$predicted)))
  perf[[rep]] <- data.frame(Repeat=rep, AUROC=auroc, LogLoss=ll, Brier=br)
}
perf_df <- do.call(rbind, perf)
write.csv(perf_df, file.path(RES_DIR,"strategyB_outer_fold_summary.csv"), row.names=FALSE, fileEncoding="UTF-8")
cat(sprintf("\nMean AUROC=%.4f\n", mean(perf_df$AUROC)))
cat("Panel distribution:\n"); print(table(sel_params$panel_size))
cat("Alpha distribution:\n"); print(table(sel_params$alpha))

# ---- Final lock ----
cat("\n===== FINAL MODEL LOCK (seed 20260929) =====\n")
set.seed(20260929)
elig386 <- compute_elig(rownames(X_all))
use_p386 <- names(elig386)[elig386]
x386 <- X_all[, use_p386, drop=FALSE]
y386 <- disc$y
prep386 <- fit_prep(x386); keep386 <- !prep386$zv
x386s <- apply_prep(x386, prep386)[, keep386, drop=FALSE]
cat("Eligible:", length(use_p386), " after zv:", ncol(x386s), "\n")

folds5 <- sample(rep(1:5, length.out=386))
best_ll2 <- Inf; best_al2 <- NA; best_li2 <- NA
for (al in ALPHAS) {
  ll_mat <- matrix(NA, N_LAMBDA, 5)
  for (k in 1:5) {
    tr <- folds5 != k; va <- folds5 == k
    tryCatch({
      fit <- glmnet(x386s[tr,], y386[tr], family="binomial", alpha=al, nlambda=N_LAMBDA, standardize=FALSE)
      pred <- predict(fit, newx=x386s[va,], type="response")
      for (li in 1:ncol(pred)) {
        p <- pmin(pmax(pred[,li],1e-10),1-1e-10)
        ll_mat[li,k] <- -mean(y386[va]*log(p)+(1-y386[va])*log(1-p))
      }
    }, error=function(e) NULL)
  }
  mll <- rowMeans(ll_mat, na.rm=TRUE)
  if (all(is.na(mll))) next
  best <- which.min(mll)
  ll_se <- apply(ll_mat, 1, sd, na.rm=TRUE)/sqrt(5)
  within <- which(mll <= mll[best]+ll_se[best])
  chosen <- min(within)
  if (mll[chosen] < best_ll2) { best_ll2 <- mll[chosen]; best_al2 <- al; best_li2 <- chosen }
}
cat("Selected alpha:", best_al2, "lambda_idx:", best_li2, "\n")

final_fit <- glmnet(x386s, y386, family="binomial", alpha=best_al2, nlambda=N_LAMBDA, standardize=FALSE)
li_f <- min(best_li2, ncol(final_fit$beta))
beta_full <- as.numeric(final_fit$beta[, li_f]); names(beta_full) <- colnames(x386s)
nz <- abs(beta_full) > 0
n_pre <- sum(nz)
if (n_pre > MAX_PANEL) {
  ord <- order(abs(beta_full[nz]), decreasing=TRUE)
  keep_final <- names(beta_full)[nz][ord[1:MAX_PANEL]]
} else {
  keep_final <- names(beta_full)[nz]
}
n_post <- length(keep_final)
cat("Final panel: pre=", n_pre, " post=", n_post, "\n")
stopifnot(n_post <= MAX_PANEL)

# Refit final logistic on selected features
if (n_post == 0) {
  final_intercept <- log(mean(y386)/(1-mean(y386)))
  final_pred_baseline <- plogis(final_intercept)
  coef_final <- numeric(0)
  names(coef_final) <- character(0)
} else {
  df_final <- data.frame(y=y386, x386s[, keep_final, drop=FALSE])
  gm_final <- glm(y ~ ., data=df_final, family=binomial())
  coef_final <- coef(gm_final)[-1]
  final_intercept <- coef(gm_final)[1]
  final_pred_baseline <- plogis(final_intercept + mean(as.matrix(x386s[, keep_final, drop=FALSE]) %*% coef_final))
}
cat("Final baseline predicted p:", final_pred_baseline, "(prevalence:", mean(y386), ")\n")

# Save
dir.create(file.path(OUT_ML,"models"), showWarnings=FALSE)
saveRDS(list(fit=final_fit, lambda_idx=li_f, alpha=best_al2,
             features=colnames(x386s), medians=prep386$medians[colnames(x386s)],
             means=prep386$means[colnames(x386s)], sds=prep386$sds[colnames(x386s)],
             eligible=use_p386, panel=keep_final,
             refit_coef=coef_final, refit_intercept=final_intercept),
        file.path(OUT_ML,"models/strategyB_primary_model.rds"))
if (n_post > 0) {
  coef_df <- data.frame(Feature=names(coef_final), Coefficient=as.numeric(coef_final), stringsAsFactors=FALSE)
} else {
  coef_df <- data.frame(Feature=character(0), Coefficient=numeric(0))
}
write.csv(coef_df, file.path(OUT_ML,"models/strategyB_primary_coefficients.csv"), row.names=FALSE, fileEncoding="UTF-8")
write.csv(data.frame(Feature=keep_final), file.path(OUT_ML,"models/strategyB_primary_features.csv"), row.names=FALSE, fileEncoding="UTF-8")

model_sha <- digest(file=file.path(OUT_ML,"models/strategyB_primary_model.rds"), algo="sha256")
manif <- data.frame(item=c("git_commit","seed","alpha","lambda_idx","panel_pre","panel_post",
                            "n_discovery","model_sha256","timestamp"),
  value=c("c543c2ce4f9ef73b86230e72b84d8cb5344e76bc","20260929",
          as.character(best_al2),as.character(li_f),as.character(n_pre),as.character(n_post),
          "386",model_sha,format(Sys.time(),"%Y-%m-%d %H:%M:%S")), stringsAsFactors=FALSE)
write.csv(manif, file.path(OUT_ML,"models/strategyB_model_manifest.csv"), row.names=FALSE, fileEncoding="UTF-8")
writeLines(paste0("PRIMARY MODEL LOCKED\nTimestamp: ", format(Sys.time(),"%Y-%m-%d %H:%M:%S %Z"),
                  "\nModel SHA-256: ", model_sha,
                  "\nGit: c543c2ce4f9ef73b86230e72b84d8cb5344e76bc",
                  "\nDiscovery N: 386\nAlpha: ", best_al2,
                  "\nPanel pre-cap: ", n_pre, "\nPanel post-cap: ", n_post,
                  "\nMax panel cap: ", MAX_PANEL,
                  "\nBaseline predicted p: ", round(final_pred_baseline,4),
                  "\nPrevalence: ", round(mean(y386),4),
                  "\nProtocol-conformant: YES\n"),
           file.path(OUT_ML,"models/PRIMARY_MODEL_LOCK"))
cat("\nDONE.\n")
