#!/usr/bin/env Rscript
# V2 M15v2 — Protocol-compliant repair.
# Strategy B primary + Strategy A secondary.
# Inner selection: mean log loss + exact one-SE rule.
# Fold-local everything. 129 firewall.

suppressPackageStartupMessages({ library(glmnet); library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"ml","m15v2"); dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)
res_dir <- file.path(out_dir,"results"); dir.create(res_dir, showWarnings=FALSE)
mod_dir <- file.path(out_dir,"models"); dir.create(mod_dir, showWarnings=FALSE)

# ---- data: Discovery only --------------------------------------------------
log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
split <- read.csv(file.path(root,"descriptive","discovery_validation_split","discovery_validation_assignment.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)

disc_ids <- split$UniqueSampleID[split$Split=="Discovery"]
val_ids <- split$UniqueSampleID[split$Split=="Validation"]
stopifnot(length(disc_ids)==386, length(val_ids)==129, !any(intersect(disc_ids,val_ids)))

rownames(meta) <- meta$UniqueSampleID
m <- meta[disc_ids,]
m$y <- ifelse(m$TREAT1_clean=="control",0L,1L)
m$Group3 <- factor(m$TREAT1_clean, c("control","low","high"))
stopifnot(sum(m$y==0)==115, sum(m$y==1)==271)

q515_ids <- univ$PG.ProteinGroups[univ$Q515==TRUE]
y_mat <- as.matrix(log2mat[q515_ids, disc_ids]); storage.mode(y_mat)<-"numeric"
cat("Discovery", length(disc_ids), "proteins", length(q515_ids), "\n")

# ---- helpers ---------------------------------------------------------------
log_loss <- function(y,p) { p<-pmin(pmax(p,1e-15),1-1e-15); -mean(y*log(p)+(1-y)*log(1-p)) }

prep_train <- function(idx) {
  Xtr <- t(y_mat[,idx,drop=FALSE])
  elig <- colMeans(!is.na(Xtr)) >= 0.80
  Xe <- Xtr[,elig,drop=FALSE]
  meds <- apply(Xe,2,median,na.rm=TRUE)
  for (j in seq_len(ncol(Xe))) Xe[is.na(Xe[,j]),j] <- meds[j]
  mu <- colMeans(Xe); sd <- apply(Xe,2,sd); sd[sd==0]<-1
  Xs <- scale(Xe, center=mu, scale=sd)
  list(elig=elig, meds=meds, mu=mu, sd=sd, Xs=Xs)
}
prep_test <- function(idx, pp) {
  X <- t(y_mat[pp$elig,idx,drop=FALSE])
  for (j in seq_len(ncol(X))) X[is.na(X[,j]),j] <- pp$meds[j]
  scale(X, center=pp$mu, scale=pp$sd)
}

# Strategy A screen: fold-local limma three-group, weighted E contrast, BH<0.10
screen_stratA <- function(train_idx) {
  Xtr <- t(y_mat[,train_idx,drop=FALSE])
  ms <- m[train_idx,]
  # design ~0+Group3
  des <- model.matrix(~0+Group3, data=ms)
  # E = (nL/nE)*Low + (nH/nE)*High - Control
  nL<-sum(ms$Group3=="low"); nH<-sum(ms$Group3=="high")
  wL<-nL/(nL+nH); wH<-nH/(nL+nH)
  cn<-colnames(des)
  ev<-setNames(rep(0,length(cn)),cn); ev["Group3low"]<-wL; ev["Group3high"]<-wH; ev["Group3control"]<--1
  cm<-matrix(ev,ncol=1,dimnames=list(names(ev),"E"))
  d2<-contrastAsCoef(des,cm)[["design"]]
  # need protein-wise; Xtr is samples x proteins -> transpose
  fit <- lmFit(t(Xtr), d2)
  fit <- eBayes(fit, trend=TRUE, robust=TRUE)
  tt <- topTable(fit, coef="E", number=Inf, sort.by="none")
  rownames(tt) <- colnames(Xtr)
  tt$BH <- p.adjust(tt$P.Value, method="BH")
  rownames(tt)[tt$BH < 0.10]
}

# fit one candidate pipeline on train, predict test
fit_predict <- function(Xtr, ytr, Xte, al, k) {
  if (ncol(Xtr) < 2) return(list(p=rep(mean(ytr),nrow(Xte)), k=0, feats=character(0)))
  cv <- cv.glmnet(Xtr, ytr, family="binomial", alpha=al, nfolds=5,
                  nlambda=50, standardize=FALSE)
  lam <- cv$lambda.min
  g <- glmnet(Xtr, ytr, family="binomial", alpha=al, lambda=lam, standardize=FALSE)
  beta <- as.matrix(coef(g))[-1,]
  ord <- order(abs(beta), decreasing=TRUE)
  kk <- min(k, sum(beta!=0))
  if (kk < 1) return(list(p=rep(mean(ytr),nrow(Xte)), k=0, feats=character(0)))
  top <- ord[seq_len(kk)]
  Xk <- Xtr[,top,drop=FALSE]
  if (ncol(Xk) < 2) return(list(p=rep(mean(ytr),nrow(Xte)), k=0, feats=character(0)))
  gk <- glmnet(Xk, ytr, family="binomial", alpha=al, lambda=0, standardize=FALSE)
  pt <- as.numeric(predict(gk, newx=Xte[,top,drop=FALSE], type="response"))
  list(p=pt, k=kk, feats=colnames(Xtr)[top])
}

# ---- nested CV --------------------------------------------------------------
reps <- 3; folds <- 5; seeds <- c(20260926,20260927,20260928)
alphas <- c(0.1,0.5,0.9,1.0); ks <- c(3,5,10,20)
predB <- list(); predA <- list(); sel_rows <- list()

for (r in seq_len(reps)) {
  set.seed(seeds[r])
  n <- length(disc_ids)
  idx0 <- which(m$y==0); idx1 <- which(m$y==1)
  f0 <- sample(rep(1:folds, length.out=length(idx0)))
  f1 <- sample(rep(1:folds, length.out=length(idx1)))
  fold <- integer(n); fold[idx0]<-f0; fold[idx1]<-f1
  for (o in 1:folds) {
    tr <- which(fold!=o); te <- which(fold==o)
    # Strategy B
    pp <- prep_train(tr)
    Xtr <- pp$Xs; Xte <- prep_test(te,pp)
    # inner selection: 5-fold inner CV log loss for each (alpha,k)
    inner_loss <- matrix(NA, length(alphas), length(ks),
                         dimnames=list(as.character(alphas), as.character(ks)))
    inner_se <- inner_loss
    set.seed(seeds[r]+o)
    ii <- sample(rep(1:5, length.out=length(tr)))
    for (ai in seq_along(alphas)) {
      for (ki in seq_along(ks)) {
        ll <- numeric(5)
        for (iv in 1:5) {
          itr <- which(ii!=iv); ite <- which(ii==iv)
          r2 <- fit_predict(Xtr[itr,,drop=FALSE], m$y[tr][itr],
                            Xtr[ite,,drop=FALSE], alphas[ai], ks[ki])
          ll[iv] <- log_loss(m$y[tr][ite], r2$p)
        }
        inner_loss[ai,ki] <- mean(ll)
        inner_se[ai,ki] <- sd(ll)/sqrt(5)
      }
    }
    # one-SE rule
    min_l <- min(inner_loss)
    se_min <- inner_se[which.min(inner_loss)]
    within <- inner_loss <= min_l + se_min
    # smallest k within one-SE, tiebreak larger alpha
    cand <- which(within, arr.ind=TRUE)
    cand <- cand[order(cand[,2], -cand[,1]), , drop=FALSE]  # smallest k, then larger alpha
    pick <- cand[1,]
    al <- alphas[pick[1]]; k <- ks[pick[2]]
    final <- fit_predict(Xtr, m$y[tr], Xte, al, k)
    for (i in seq_along(te)) predB[[length(predB)+1]] <- data.frame(
      sample=disc_ids[te[i]], rep=r, fold=o, y=m$y[te[i]],
      pred=final$p[i], alpha=al, k=final$k)
    sel_rows[[length(sel_rows)+1]] <- data.frame(
      rep=r, fold=o, alpha=al, k=k, inner_loss=min_l,
      se_min=se_min, n_candidates_within_SE=sum(within))

    # Strategy A: fold-local screen
    screen <- screen_stratA(tr)
    if (length(screen) < 1) {
      # intercept-only
      pA <- rep(mean(m$y[tr]), length(te))
      kA <- 0
    } else {
      XtrA <- Xtr[, match(screen, colnames(Xtr)), drop=FALSE]
      XteA <- Xte[, match(screen, colnames(Xtr)), drop=FALSE]
      # inner selection on screened set
      iLoss <- matrix(NA, length(alphas), length(ks),
                      dimnames=list(as.character(alphas), as.character(ks)))
      for (ai in seq_along(alphas)) {
        for (ki in seq_along(ks)) {
          ll <- numeric(5)
          for (iv in 1:5) {
            itr <- which(ii!=iv); ite <- which(ii==iv)
            r2 <- fit_predict(XtrA[itr,,drop=FALSE], m$y[tr][itr],
                              XtrA[ite,,drop=FALSE], alphas[ai], ks[ki])
            ll[iv] <- log_loss(m$y[tr][ite], r2$p)
          }
          iLoss[ai,ki] <- mean(ll)
        }
      }
      mL <- min(iLoss); sM <- sd(as.vector(iLoss))/sqrt(20)
      w2 <- iLoss <= mL + sM
      c2 <- which(w2, arr.ind=TRUE)
      c2 <- c2[order(c2[,2], -c2[,1]), , drop=FALSE]
      pA <- fit_predict(XtrA, m$y[tr], XteA, alphas[c2[1,1]], ks[c2[1,2]])$p
      kA <- ks[c2[1,2]]
    }
    for (i in seq_along(te)) predA[[length(predA)+1]] <- data.frame(
      sample=disc_ids[te[i]], rep=r, fold=o, y=m$y[te[i]],
      pred=pA[i], n_screen=length(screen), k=kA)
  }
  cat("Rep", r, "done\n")
}

predB <- do.call(rbind, predB); predA <- do.call(rbind, predA)
selB <- do.call(rbind, sel_rows)
write.csv(predB, file.path(res_dir,"M15v2_StrategyB_OOF.csv"), row.names=FALSE)
write.csv(predA, file.path(res_dir,"M15v2_StrategyA_OOF.csv"), row.names=FALSE)
write.csv(selB, file.path(res_dir,"M15v2_inner_selection_audit.csv"), row.names=FALSE)

# metrics
auc <- function(y,p){r<-rank(p);n1<-sum(y==1);n0<-sum(y==0);(sum(r[y==1])-n1*(n1+1)/2)/(n1*n0)}
auprc <- function(y,p){o<-order(p,decreasing=TRUE);y<-y[o];cs<-cumsum(y);n1<-sum(y==1);sum(cs/(1:length(y))*(y==1))/n1}
rep_metrics <- function(pred, name) {
  a <- auc(pred$y,pred$pred); b <- mean((pred$pred-pred$y)^2)
  al <- glm(y~pred, data=pred, family=binomial())
  cat(sprintf("%s: AUROC=%.4f AUPRC=%.4f Brier=%.4f cal_int=%.3f cal_slope=%.3f\n",
    name, a, auprc(pred$y,pred$pred), b, coef(al)[1], coef(al)[2]))
}
rep_metrics(predB,"StrategyB"); rep_metrics(predA,"StrategyA")

# bootstrap 2000
set.seed(20260929)
boot_ci <- function(pred) {
  parts <- unique(pred$sample); yy <- pred$y[!duplicated(pred$sample)]
  names(yy)<-pred$sample[!duplicated(pred$sample)]
  p0<-names(yy[yy==0]); p1<-names(yy[yy==1])
  ba<-numeric(2000); bb<-numeric(2000)
  for (b in 1:2000) {
    sp<-c(sample(p0,length(p0),TRUE), sample(p1,length(p1),TRUE))
    s<-pred[pred$sample%in%sp,]
    ba[b]<-auc(s$y,s$pred); bb[b]<-mean((s$pred-s$y)^2)
  }
  c(au_lo=quantile(ba,.025),au_hi=quantile(ba,.975),
    br_lo=quantile(bb,.025),br_hi=quantile(bb,.975))
}
cat("StrategyB 95% CI:\n"); print(boot_ci(predB))
cat("StrategyA 95% CI:\n"); print(boot_ci(predA))

cat("M15v2_DONE\n")
