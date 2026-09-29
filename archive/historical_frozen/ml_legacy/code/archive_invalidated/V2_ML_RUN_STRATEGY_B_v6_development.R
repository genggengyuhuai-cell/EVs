# V2_ML_RUN_STRATEGY_B_v6.R — Addendum-compliant panel refit implementation
# This file defines the runner. It is NOT executed in this step.

library(readxl); library(glmnet); library(digest); library(pROC)

ROOT <- "F:/env"; setwd(ROOT)
OUT_ML <- "descriptive/analysis_v2.0/ml"
RES_DIR <- file.path(OUT_ML,"results")
dir.create(RES_DIR, showWarnings=FALSE, recursive=TRUE)

ALPHAS <- c(0.1,0.5,0.9,1.0)
N_LAMBDA_FRAC <- 50
PANEL_TYPES <- c("k3","k5","k10","k20","untruncated")
K_MAP <- c(k3=3, k5=5, k10=10, k20=20, untruncated=Inf)

# ---- Load data ----
cat("Loading data...\n")
ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
ch <- function(x){x<-trimws(as.character(x));sub("\\.0$","",x)}
ss$clean <- ch(ss$Sheet1_raw_header)
sm <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv", stringsAsFactors=FALSE)
disc <- sm[sm$Split=="Discovery",]; disc$y <- as.integer(disc$TREAT1_clean!="control")
stopifnot(nrow(disc)==386, sum(disc$y==1)==271, sum(disc$y==0)==115)
raw <- read_excel("rawdata/processed.xlsx", n_max=3817, .name_repair="minimal")
abund <- as.data.frame(raw[,8:ncol(raw)]); rownames(abund) <- raw$PG.ProteinGroups
f3 <- read.csv("descriptive/analysis_v2.0/registry/contaminant_candidate_registry.csv", stringsAsFactors=FALSE)
excl <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible=="TRUE"]
abund_u <- abund[!rownames(abund)%in%excl,]
ss_d <- ss[match(disc$UniqueSampleID,ss$UniqueSampleID),]
dpos <- match(ss_d$clean, ss$clean)
X_all <- t(abund_u[,dpos]); colnames(X_all)<-rownames(abund_u); rownames(X_all)<-disc$UniqueSampleID
of <- read.csv(file.path(OUT_ML,"folds/outer_folds.csv"),stringsAsFactors=FALSE)
inf <- read.csv(file.path(OUT_ML,"folds/inner_folds.csv"),stringsAsFactors=FALSE)

is_det <- function(x) is.finite(x)&x>0
compute_elig <- function(sids){
  m<-X_all[sids,,drop=FALSE];grp<-disc$TREAT1_clean[match(sids,disc$UniqueSampleID)]
  e<-rep(TRUE,ncol(m));names(e)<-colnames(m)
  for(g in c("control","low","high")){
    gs<-sids[grp==g];if(!length(gs))next
    th<-ceiling(0.70*length(gs));e<-e&(colSums(is_det(m[gs,,drop=FALSE]))>=th)
  };e
}
fit_prep <- function(mat){
  med<-apply(mat,2,median,na.rm=TRUE);imp<-mat
  for(j in 1:ncol(imp))imp[is.na(imp[,j]),j]<-med[j]
  mu<-colMeans(imp);sd<-apply(imp,2,sd);zv<-is.na(sd)|sd==0
  list(med=med,mu=mu,sd=sd,zv=zv)
}
aply <- function(mat,p){
  o<-mat
  for(j in 1:ncol(o))o[is.na(o[,j]),j]<-p$med[j]
  for(j in 1:ncol(o))o[,j]<-(o[,j]-p$mu[j])/p$sd[j]
  o
}

# ---- Core candidate evaluation function ----
# Given training matrix x_tr, y_tr, test matrix x_te, alpha, lambda_fraction, panel_type
# Returns predicted probabilities on x_te
eval_candidate <- function(x_tr, y_tr, x_te, alpha, lambda_frac, panel_type) {
  n_tr <- nrow(x_tr)
  # Fit full Elastic Net
  fit_full <- glmnet(x_tr, y_tr, family="binomial", alpha=alpha, nlambda=N_LAMBDA_FRAC, standardize=FALSE)
  lam_max <- fit_full$lambda[1]
  target_lam <- lambda_frac * lam_max
  # Find closest lambda index
  li <- which.min(abs(fit_full$lambda - target_lam))
  # Extract coefficients
  beta <- as.numeric(fit_full$beta[,li]); names(beta) <- colnames(x_tr)
  a0 <- as.numeric(fit_full$a0)[li]
  nz <- abs(beta) > 0
  n_nz <- sum(nz)

  if (n_nz == 0) {
    # Intercept-only
    p_train <- mean(y_tr)
    return(list(pred=rep(p_train, nrow(x_te)), n_features=0, feats=character(0),
                panel_type="intercept_only", lambda_refit=NA))
  }

  if (panel_type == "untruncated") {
    pred <- as.numeric(predict(fit_full, newx=x_te, s=fit_full$lambda[li], type="response"))
    return(list(pred=pred, n_features=n_nz, feats=names(beta)[nz],
                panel_type="untruncated", lambda_refit=fit_full$lambda[li]))
  }

  # Capped: take top-k
  k <- K_MAP[panel_type]
  actual_k <- min(k, n_nz)
  ord <- order(abs(beta[nz]), decreasing=TRUE)
  # Tie-break by lexical PG name
  nz_names <- names(beta)[nz]
  nz_abs <- abs(beta[nz])
  ord <- order(-nz_abs, nz_names, method='radix')
  keep <- nz_names[ord[1:actual_k]]

  # Refit Elastic Net on k features
  x_tr_k <- x_tr[, keep, drop=FALSE]
  x_te_k <- x_te[, keep, drop=FALSE]
  fit_refit <- glmnet(x_tr_k, y_tr, family="binomial", alpha=alpha,
                      nlambda=N_LAMBDA_FRAC, standardize=FALSE)
  lam_max_k <- fit_refit$lambda[1]
  target_lam_k <- lambda_frac * lam_max_k
  li_k <- which.min(abs(fit_refit$lambda - target_lam_k))
  pred <- as.numeric(predict(fit_refit, newx=x_te_k, s=fit_refit$lambda[li_k], type="response"))
  list(pred=pred, n_features=actual_k, feats=keep,
       panel_type=panel_type, lambda_refit=fit_refit$lambda[li_k])
}

# ---- Nested CV (NOT executed) ----
# This function skeleton documents the execution flow.
run_nested_cv <- function() {
  ops <- list(); sls <- list()
  for (rep in 1:3) {
    ro <- of[of$Repeat==rep,]
    for (oo in 1:5) {
      ts <- ro$Participant_ID[ro$Outer_fold==oo]
      tr <- ro$Participant_ID[ro$Outer_fold!=oo]
      e <- compute_elig(tr); ep <- names(e)[e]
      xot <- X_all[tr,ep,drop=FALSE]; yot <- disc$y[match(tr,disc$UniqueSampleID)]
      pp <- fit_prep(xot); kp <- !pp$zv
      xt <- aply(xot,pp)[,kp,drop=FALSE]
      # Inner CV: evaluate all (alpha, lambda_frac, panel_type) candidates
      ri <- inf[inf$Repeat==rep & inf$Outer_fold==oo & inf$Role=="inner_training_or_val",]
      # ... [inner CV loop]
      # Select best via one-SE
      # ...
      # Outer refit + predict
      # ...
    }
  }
}

cat("V2_ML_RUN_STRATEGY_B_v6.R loaded. Ready for execution.\n")
cat("Candidate evaluation function: eval_candidate()\n")
cat("Do NOT run this script directly. Use wrapper.\n")
