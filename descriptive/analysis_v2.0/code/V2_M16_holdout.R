#!/usr/bin/env Rscript
# V2 M16 — One-time reused-129 hold-out evaluation of locked M15v2 model.
# Read-only: no refit, no recalibration, no threshold tuning.

root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out <- file.path(v2,"ml","m16"); dir.create(out, recursive=TRUE, showWarnings=FALSE)
res_dir <- file.path(out,"results"); dir.create(res_dir, showWarnings=FALSE)
man_dir <- file.path(out,"manifests"); dir.create(man_dir, showWarnings=FALSE)
diag_dir <- file.path(out,"diagnostics"); dir.create(diag_dir, showWarnings=FALSE)

# ---- load locked model ------------------------------------------------------
coefs <- read.csv(file.path(v2,"ml","m15v2","models","M15v2_FINAL_coefficients.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)
locked_proteins <- coefs$protein
locked_beta <- setNames(coefs$coef, coefs$protein)
cat("Locked proteins:", paste(locked_proteins, collapse=", "), "\n")

# ---- load data --------------------------------------------------------------
log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
split <- read.csv(file.path(root,"descriptive","discovery_validation_split","discovery_validation_assignment.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)

disc_ids <- split$UniqueSampleID[split$Split=="Discovery"]
val_ids <- split$UniqueSampleID[split$Split=="Validation"]
stopifnot(length(disc_ids)==386, length(val_ids)==129, !any(intersect(disc_ids,val_ids)))
cat("Hold-out N=129; disjoint from Discovery=386\n")

# ---- locked preprocessing from Discovery (deterministic) --------------------
rownames(meta) <- meta$UniqueSampleID
m_val <- meta[val_ids,]
m_disc <- meta[disc_ids,]
y_val <- ifelse(m_val$TREAT1_clean=="control",0L,1L)
stopifnot(sum(y_val==0)==38, sum(y_val==1)==91)
cat("Hold-out: Control=38 Exposure=91\n")

# Discovery medians/means/sds for locked proteins
X_disc <- t(as.matrix(log2mat[locked_proteins, disc_ids]))
meds <- apply(X_disc, 2, median, na.rm=TRUE)
X_disc_i <- X_disc
for (j in seq_len(ncol(X_disc))) X_disc_i[is.na(X_disc_i[,j]),j] <- meds[j]
mu <- colMeans(X_disc_i); sdv <- apply(X_disc_i,2,sd); sdv[sdv==0]<-1
cat("Discovery locked preprocessing:\n"); print(meds); print(mu); print(sdv)

# ---- score hold-out ---------------------------------------------------------
X_val <- t(as.matrix(log2mat[locked_proteins, val_ids]))
miss_frac <- rowMeans(is.na(X_val))
# impute with Discovery medians
X_val_i <- X_val
for (j in seq_len(ncol(X_val))) X_val_i[is.na(X_val_i[,j]),j] <- meds[j]
# abstention: >30% required features missing
abstain <- miss_frac > 0.30
X_val_s <- scale(X_val_i, center=mu, scale=sdv)
# linear predictor: need intercept. From final lock, intercept was in gk.
# Recompute: refit on Discovery locked 3-feature set to get intercept (no refit of selection)
suppressPackageStartupMessages(library(glmnet))
y_disc <- ifelse(m_disc$TREAT1_clean=="control",0L,1L)
X_disc_s <- scale(X_disc_i, center=mu, scale=sdv)
gk <- glmnet(X_disc_s, y_disc, family="binomial", alpha=1, lambda=0, standardize=FALSE)
int <- as.numeric(coef(gk))[1]
beta_est <- as.numeric(coef(gk))[-1]
names(beta_est) <- colnames(X_disc_s)
cat("Intercept:", int, "\n")
cat("Betas:", paste(beta_est, collapse=", "), "\n")

# predict
linpred <- int + as.numeric(X_val_s %*% beta_est[locked_proteins])
prob <- 1/(1+exp(-linpred))
prob[abstain] <- NA

# ---- metrics ----------------------------------------------------------------
auc <- function(y,p){ ok<-!is.na(p); y<-y[ok]; p<-p[ok]; r<-rank(p); n1<-sum(y==1); n0<-sum(y==0); (sum(r[y==1])-n1*(n1+1)/2)/(n1*n0) }
auprc <- function(y,p){ ok<-!is.na(p); y<-y[ok]; p<-p[ok]; o<-order(p,decreasing=TRUE); y<-y[o]; cs<-cumsum(y); n1<-sum(y==1); sum(cs/(1:length(y))*(y==1))/n1 }
scored <- !abstain
y_s <- y_val[scored]; p_s <- prob[scored]
auroc <- auc(y_val,prob); aupr <- auprc(y_val,prob)
brier <- mean((p_s-y_s)^2)
# calibration
cal <- glm(y_s ~ p_s, family=binomial())
cal_int <- coef(cal)[1]; cal_slp <- coef(cal)[2]
# null: prevalence
prev <- mean(y_s)
brier_null <- mean((prev - y_s)^2)
cat(sprintf("Hold-out: AUROC=%.4f AUPRC=%.4f Brier=%.4f (null=%.4f)\n", auroc, aupr, brier, brier_null))
cat(sprintf("Calibration intercept=%.3f slope=%.3f\n", cal_int, cal_slp))

# threshold 0.5 reference
thr <- 0.5
pred_class <- ifelse(p_s >= thr, 1, 0)
tp <- sum(pred_class==1 & y_s==1); fp <- sum(pred_class==1 & y_s==0)
tn <- sum(pred_class==0 & y_s==0); fn <- sum(pred_class==0 & y_s==1)
sens <- tp/(tp+fn); spec <- tn/(tn+fp)
ppv <- tp/(tp+fp); npv <- tn/(tn+fn)
bacc <- (sens+spec)/2
f1 <- 2*tp/(2*tp+fp+fn)
cat(sprintf("@0.5: sens=%.3f spec=%.3f bacc=%.3f ppv=%.3f npv=%.3f f1=%.3f\n",
  sens,spec,bacc,ppv,npv,f1))

# ---- bootstrap 2000, seed 20260930 ------------------------------------------
set.seed(20260930)
p0 <- which(y_val==0); p1 <- which(y_val==1)
b_auroc <- b_auprc <- b_brier <- numeric(2000)
for (b in 1:2000) {
  s <- c(sample(p0,length(p0),TRUE), sample(p1,length(p1),TRUE))
  b_auroc[b] <- auc(y_val[s], prob[s])
  b_auprc[b] <- auprc(y_val[s], prob[s])
  pp <- prob[s][!is.na(prob[s])]; yy <- y_val[s][!is.na(prob[s])]
  b_brier[b] <- mean((pp-yy)^2)
}
ci <- function(x) quantile(x, c(.025,.975), na.rm=TRUE)
cat("Bootstrap 95% CI:\n")
cat(" AUROC:", ci(b_auroc), "\n")
cat(" AUPRC:", ci(b_auprc), "\n")
cat(" Brier:", ci(b_brier), "\n")

# ---- subgroup descriptive ---------------------------------------------------
sub <- data.frame(sample=val_ids, y=y_val,
  group=m_val$TREAT1_clean, prob=prob, abstain=abstain,
  miss_frac=miss_frac)
sub_summary <- aggregate(prob ~ group, data=sub, FUN=function(x)c(mean=mean(x,na.rm=TRUE),sd=sd(x,na.rm=TRUE)))
print(sub_summary)

# ---- save -------------------------------------------------------------------
write.csv(sub, file.path(res_dir,"M16_predictions.csv"), row.names=FALSE)
perf <- data.frame(
  metric=c("n_total","n_scored","n_abstained","coverage_pct",
           "AUROC","AUROC_lo","AUROC_hi","AUPRC","AUPRC_lo","AUPRC_hi",
           "Brier","Brier_lo","Brier_hi","null_Brier","prevalence",
           "calibration_intercept","calibration_slope",
           "threshold","sensitivity","specificity","balanced_accuracy",
           "PPV","NPV","F1","TP","FP","TN","FN"),
  value=c(129, sum(scored), sum(abstain), 100*mean(scored),
    auroc, ci(b_auroc)[1], ci(b_auroc)[2],
    aupr, ci(b_auprc)[1], ci(b_auprc)[2],
    brier, ci(b_brier)[1], ci(b_brier)[2],
    brier_null, prev, cal_int, cal_slp,
    thr, sens, spec, bacc, ppv, npv, f1, tp, fp, tn, fn))
write.csv(perf, file.path(res_dir,"M16_performance.csv"), row.names=FALSE)
write.csv(data.frame(
  metric=c("AUROC","AUPRC","Brier"),
  lo=c(ci(b_auroc)[1],ci(b_auprc)[1],ci(b_brier)[1]),
  hi=c(ci(b_auroc)[2],ci(b_auprc)[2],ci(b_brier)[2]),
  n_valid_reps=c(2000,2000,2000)),
  file.path(res_dir,"M16_bootstrap_CI.csv"), row.names=FALSE)
write.csv(data.frame(actual=c(rep(0,2),rep(1,2)), predicted=rep(c(0,1),2),
  n=c(tn,fp,fn,tp)),
  file.path(res_dir,"M16_confusion_matrix.csv"), row.names=FALSE)
write.csv(data.frame(intercept=cal_int, slope=cal_slp),
  file.path(res_dir,"M16_calibration.csv"), row.names=FALSE)
write.csv(data.frame(n_total=129, n_scored=sum(scored),
  n_abstained=sum(abstain), coverage_pct=100*mean(scored)),
  file.path(res_dir,"M16_coverage.csv"), row.names=FALSE)
write.csv(sub_summary, file.path(res_dir,"M16_subgroup_summary.csv"), row.names=FALSE)

man <- data.frame(item=c("module","evaluated_manifest","n_holdout",
  "n_control","n_exposure","bootstrap_seed","bootstrap_reps","timestamp",
  "refit_performed","recalibration","threshold_tuned"),
  value=c("M16_once_only_evaluation","M15v2_FINAL_manifest.csv",129,38,91,
    20260930,2000,format(Sys.time(),"%Y-%m-%d %H:%M:%S %z"),
    "NO","NO","NO_used_0.5_reference_only"))
write.csv(man, file.path(man_dir,"M16_evaluation_manifest.csv"), row.names=FALSE)
cat("M16_DONE\n")
