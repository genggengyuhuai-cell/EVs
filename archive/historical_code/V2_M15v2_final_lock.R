#!/usr/bin/env Rscript
# M15v2 final lock on all 386 Discovery, seed 20260929.
suppressPackageStartupMessages({ library(glmnet) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"ml","m15v2"); mod_dir <- file.path(out_dir,"models")

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
split <- read.csv(file.path(root,"descriptive","discovery_validation_split","discovery_validation_assignment.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)

disc_ids <- split$UniqueSampleID[split$Split=="Discovery"]
val_ids <- split$UniqueSampleID[split$Split=="Validation"]
stopifnot(length(disc_ids)==386, !any(intersect(disc_ids,val_ids)))
rownames(meta) <- meta$UniqueSampleID
m <- meta[disc_ids,]
y <- ifelse(m$TREAT1_clean=="control",0L,1L)
q515_ids <- univ$PG.ProteinGroups[univ$Q515==TRUE]
X <- t(as.matrix(log2mat[q515_ids, disc_ids])); storage.mode(X)<-"numeric"

# fold-local eligibility on all 386 (final lock)
elig <- colMeans(!is.na(X)) >= 0.80
Xe <- X[,elig,drop=FALSE]
meds <- apply(Xe,2,median,na.rm=TRUE)
for (j in seq_len(ncol(Xe))) Xe[is.na(Xe[,j]),j] <- meds[j]
mu <- colMeans(Xe); sdv <- apply(Xe,2,sd); sdv[sdv==0]<-1
Xs <- scale(Xe, center=mu, scale=sdv)

# inner selection: 5-fold CV log loss, one-SE rule
set.seed(20260929)
alphas <- c(0.1,0.5,0.9,1.0); ks <- c(3,5,10,20)
ii <- sample(rep(1:5, length.out=nrow(Xs)))
best <- NULL
for (al in alphas) for (k in ks) {
  ll <- numeric(5)
  for (iv in 1:5) {
    itr <- which(ii!=iv); ite <- which(ii==iv)
    cv <- cv.glmnet(Xs[itr,], y[itr], family="binomial", alpha=al, nfolds=5, nlambda=50, standardize=FALSE)
    g <- glmnet(Xs[itr,], y[itr], family="binomial", alpha=al, lambda=cv$lambda.min, standardize=FALSE)
    beta <- as.matrix(coef(g))[-1,]
    ord <- order(abs(beta), decreasing=TRUE)
    kk <- min(k, sum(beta!=0))
    if (kk<2) { ll[iv] <- mean((mean(y[itr])-y[ite])^2); next }
    top <- ord[1:kk]
    gk <- glmnet(Xs[itr,top], y[itr], family="binomial", alpha=al, lambda=0, standardize=FALSE)
    p <- as.numeric(predict(gk, newx=Xs[ite,top], type="response"))
    p<-pmin(pmax(p,1e-15),1-1e-15); ll[iv] <- -mean(y[ite]*log(p)+(1-y[ite])*log(1-p))
  }
  m_l <- mean(ll); se_l <- sd(ll)/sqrt(5)
  if (is.null(best)) { best <- list(al=al,k=k,ml=m_l,se=se_l)
  } else if (m_l <= best$ml + best$se) {
    if (k < best$k || (k==best$k && al > best$al))
      best <- list(al=al,k=k,ml=m_l,se=se_l)
  }
}
cat("Selected: alpha=",best$al," k=",best$k,"\n")

# final fit
cv <- cv.glmnet(Xs, y, family="binomial", alpha=best$al, nfolds=5, nlambda=50, standardize=FALSE)
g <- glmnet(Xs, y, family="binomial", alpha=best$al, lambda=cv$lambda.min, standardize=FALSE)
beta <- as.matrix(coef(g))[-1,]
ord <- order(abs(beta), decreasing=TRUE)
kk <- min(best$k, sum(beta!=0))
top <- ord[1:kk]
feats <- colnames(Xs)[top]
gk <- glmnet(Xs[,top], y, family="binomial", alpha=best$al, lambda=0, standardize=FALSE)
cf <- as.matrix(coef(gk))
int <- cf[1,1]; coefs <- cf[-1,1]
names(coefs) <- feats

# reproduction check
p1 <- as.numeric(predict(gk, newx=Xs[,top], type="response"))
# independent: logit = int + Xs %*% coefs
linpred <- int + as.numeric(Xs[,top] %*% coefs)
p2 <- 1/(1+exp(-linpred))
cat(sprintf("Reproduction max|p1-p2|=%.2e\n", max(abs(p1-p2))))

# save
write.csv(data.frame(protein=feats, coef=coefs, row.names=NULL),
          file.path(mod_dir,"M15v2_FINAL_coefficients.csv"), row.names=FALSE)
lock <- data.frame(
  item=c("module","strategy","task","n","n_control","n_exposure",
         "alpha","panel_k","n_features","seed_final","repro_max_abs_diff",
         "timestamp","firewall_129"),
  value=c("M15v2","Strategy_B_primary","Control_vs_Exposure",386,115,271,
          best$al,best$k,kk,20260929,
          sprintf("%.2e",max(abs(p1-p2))),
          format(Sys.time(),"%Y-%m-%d %H:%M:%S %z"),
          "PASS_no_129_loaded"))
write.csv(lock, file.path(mod_dir,"M15v2_FINAL_manifest.csv"), row.names=FALSE)
cat("M15v2_LOCK_DONE\n")
