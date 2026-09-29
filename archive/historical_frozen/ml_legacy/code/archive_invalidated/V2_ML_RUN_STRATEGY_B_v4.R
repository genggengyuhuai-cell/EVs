# V2_ML_RUN_STRATEGY_B_v4.R — Clean: glmnet native predict + panel cap via feature subset refit
library(readxl); library(glmnet); library(digest); library(pROC)
ROOT <- "F:/env"; setwd(ROOT)
OUT_ML <- "descriptive/analysis_v2.0/ml"
RES_DIR <- file.path(OUT_ML, "results"); dir.create(RES_DIR, showWarnings=FALSE, recursive=TRUE)
ALPHAS <- c(0.1,0.5,0.9,1.0); N_LAMBDA <- 50; MAX_PANEL <- 20

cat("Loading data...\n")
ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
ch <- function(x) { x <- trimws(as.character(x)); sub("\\.0$","",x) }
ss$clean <- ch(ss$Sheet1_raw_header)
sm <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv", stringsAsFactors=FALSE)
disc <- sm[sm$Split=="Discovery",]; disc$y <- as.integer(disc$TREAT1_clean!="control")
stopifnot(nrow(disc)==386, sum(disc$y==1)==271, sum(disc$y==0)==115)
raw <- read_excel("rawdata/processed.xlsx", n_max=3817, .name_repair="minimal")
proteins <- data.frame(PG=raw$PG.ProteinGroups, stringsAsFactors=FALSE)
excel_cols <- names(raw)[8:ncol(raw)]; excel_clean <- ch(excel_cols)
abund <- as.data.frame(raw[,8:ncol(raw)]); rownames(abund) <- proteins$PG
f3 <- read.csv("descriptive/analysis_v2.0/registry/contaminant_candidate_registry.csv", stringsAsFactors=FALSE)
excl_pgs <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible=="TRUE"]
abund_u <- abund[!rownames(abund)%in%excl_pgs,]
ss_d <- ss[match(disc$UniqueSampleID, ss$UniqueSampleID),]
dpos <- match(ss_d$clean, excel_clean)
X_all <- t(abund_u[,dpos]); colnames(X_all) <- rownames(abund_u); rownames(X_all) <- disc$UniqueSampleID
cat("X:", nrow(X_all), "x", ncol(X_all), "\n")
of <- read.csv(file.path(OUT_ML,"folds/outer_folds.csv"), stringsAsFactors=FALSE)
inf <- read.csv(file.path(OUT_ML,"folds/inner_folds.csv"), stringsAsFactors=FALSE)
is_det <- function(x) is.finite(x) & x>0
compute_elig <- function(sids) {
  m <- X_all[sids,,drop=FALSE]; grp <- disc$TREAT1_clean[match(sids,disc$UniqueSampleID)]
  e <- rep(TRUE,ncol(m)); names(e) <- colnames(m)
  for(g in c("control","low","high")) {
    gs <- sids[grp==g]; if(!length(gs)) next
    th <- ceiling(0.70*length(gs))
    e <- e & (colSums(is_det(m[gs,,drop=FALSE]))>=th)
  }; e
}
fit_prep <- function(mat) {
  med <- apply(mat,2,median,na.rm=TRUE); imp <- mat
  for(j in 1:ncol(imp)) imp[is.na(imp[,j]),j] <- med[j]
  mu <- colMeans(imp); sd <- apply(imp,2,sd); zv <- is.na(sd)|sd==0
  list(med=med,mu=mu,sd=sd,zv=zv)
}
aply_prep <- function(mat,p) {
  o <- mat
  for(j in 1:ncol(o)) o[is.na(o[,j]),j] <- p$med[j]
  for(j in 1:ncol(o)) o[,j] <- (o[,j]-p$mu[j])/p$sd[j]
  o
}

# Predict with panel cap using glmnet on selected features
predict_with_cap <- function(fit_full, x_tr, y_tr, x_te, li_use, max_k=MAX_PANEL) {
  beta <- as.numeric(fit_full$beta[,li_use]); names(beta) <- colnames(x_tr)
  a0 <- as.numeric(fit_full$a0)[li_use]
  nz <- abs(beta)>0; n_nz <- sum(nz)
  if(n_nz==0) {
    return(list(pred=rep(plogis(a0),nrow(x_te)), n=0, feats=character(0)))
  }
  if(n_nz>max_k) {
    ord <- order(abs(beta[nz]),decreasing=TRUE)
    keep <- names(beta)[nz][ord[1:max_k]]
  } else {
    keep <- names(beta)[nz]
  }
  # Refit glmnet on just selected features (with small ridge for stability)
  tryCatch({
    fit2 <- glmnet(x_tr[,keep,drop=FALSE], y_tr, family="binomial",
                   alpha=1.0, lambda=0.01, standardize=FALSE)
    p <- as.numeric(predict(fit2, newx=x_te[,keep,drop=FALSE], type="response"))
    list(pred=p, n=length(keep), feats=keep)
  }, error=function(e) {
    # fallback: manual
    bc <- beta; bc[!names(bc)%in%keep] <- 0
    list(pred=as.numeric(plogis(x_te%*%bc+a0)), n=length(keep), feats=keep)
  })
}

cat("\n=== NESTED CV v4 ===\n")
ops <- list(); sls <- list()
for(rep in 1:3) {
  cat("\nRepeat",rep,"\n")
  ro <- of[of$Repeat==rep,]
  for(oo in 1:5) {
    cat(" Outer",oo,"...")
    ts <- ro$Participant_ID[ro$Outer_fold==oo]
    tr <- ro$Participant_ID[ro$Outer_fold!=oo]
    e <- compute_elig(tr); ep <- names(e)[e]
    xot <- X_all[tr,ep,drop=FALSE]; yot <- disc$y[match(tr,disc$UniqueSampleID)]
    pp <- fit_prep(xot); kp <- !pp$zv
    xt <- aply_prep(xot,pp)[,kp,drop=FALSE]
    ri <- inf[inf$Repeat==rep & inf$Outer_fold==oo & inf$Role=="inner_training_or_val",]
    best_ll <- Inf; best_al <- NA; best_li <- NA
    for(al in ALPHAS) {
      ll_m <- matrix(NA,N_LAMBDA,5); nz_m <- matrix(NA,N_LAMBDA,5)
      for(k in 1:5) {
        vs <- ri$Participant_ID[ri$Inner_fold==k]
        is <- setdiff(tr,vs); ig <- disc$TREAT1_clean[match(is,disc$UniqueSampleID)]
        mt <- X_all[is,ep,drop=FALSE]; te <- rep(TRUE,ncol(mt)); names(te) <- colnames(mt)
        for(g in c("control","low","high")) {
          gs <- is[ig==g]; if(!length(gs)) next
          th <- ceiling(0.70*length(gs))
          te <- te & (colSums(is_det(mt[gs,,drop=FALSE]))>=th)
        }
        up <- names(te)[te]; if(length(up)<5) next
        xit <- X_all[is,up,drop=FALSE]; yit <- disc$y[match(is,disc$UniqueSampleID)]
        pi <- fit_prep(xit); ki <- !pi$zv
        xit2 <- aply_prep(xit,pi)[,ki,drop=FALSE]
        xiv <- aply_prep(X_all[vs,up,drop=FALSE],pi)[,ki,drop=FALSE]
        yiv <- disc$y[match(vs,disc$UniqueSampleID)]
        tryCatch({
          f <- glmnet(xit2,yit,family="binomial",alpha=al,nlambda=N_LAMBDA,standardize=FALSE)
          pr <- predict(f,newx=xiv,type="response")
          for(li in 1:ncol(pr)) {
            p <- pmin(pmax(pr[,li],1e-10),1-1e-10)
            ll_m[li,k] <- -mean(yiv*log(p)+(1-yiv)*log(1-p))
            nz_m[li,k] <- min(sum(abs(as.numeric(f$beta[,li]))>0),MAX_PANEL)
          }
        },error=function(e)NULL)
      }
      ml <- rowMeans(ll_m,na.rm=TRUE); if(all(is.na(ml))) next
      b <- which.min(ml); lse <- apply(ll_m,1,sd,na.rm=TRUE)/sqrt(5)
      w <- which(ml<=ml[b]+lse[b]); mnz <- rowMeans(nz_m,na.rm=TRUE)
      ch <- w[order(mnz[w],w)][1]
      if(ml[ch]<best_ll){best_ll<-ml[ch];best_al<-al;best_li<-ch}
    }
    ff <- glmnet(xt,yot,family="binomial",alpha=best_al,nlambda=N_LAMBDA,standardize=FALSE)
    li_u <- min(best_li,ncol(ff$beta))
    xotest <- X_all[ts,ep,drop=FALSE]; yotest <- disc$y[match(ts,disc$UniqueSampleID)]
    xte <- aply_prep(xotest,pp)[,kp,drop=FALSE]
    res <- predict_with_cap(ff, xt, yot, xte, li_u)
    ops[[length(ops)+1]] <- data.frame(Participant_ID=ts,Repeat=rep,Outer_fold=oo,
      observed=yotest,predicted=res$pred,alpha=best_al,lambda_idx=li_u,
      panel_size=res$n,stringsAsFactors=FALSE)
    sls[[length(sls)+1]] <- data.frame(Repeat=rep,Outer_fold=oo,alpha=best_al,
      lambda_idx=li_u,inner_ll=best_ll,panel=res$n,stringsAsFactors=FALSE)
    cat(" a=",best_al," k=",res$n," mean=",round(mean(res$pred),3),"\n")
  }
}
op <- do.call(rbind,ops); sp <- do.call(rbind,sls)
write.csv(op,file.path(RES_DIR,"strategyB_outer_predictions.csv"),row.names=FALSE,fileEncoding="UTF-8")
write.csv(sp,file.path(RES_DIR,"strategyB_selected_hyperparameters.csv"),row.names=FALSE,fileEncoding="UTF-8")

cat("\n=== PER-REPEAT ===\n")
perf <- list()
for(r in 1:3) {
  s <- op[op$Repeat==r,]
  ro <- roc(s$observed,s$predicted,quiet=TRUE); au <- as.numeric(ro$auc)
  ll <- -mean(s$observed*log(pmax(s$predicted,1e-10))+(1-s$observed)*log(pmax(1-s$predicted,1e-10)))
  br <- mean((s$observed-s$predicted)^2)
  cat(sprintf("R%d: AUROC=%.4f LL=%.4f Br=%.4f mean_pred=%.4f\n",r,au,ll,br,mean(s$pred)))
  perf[[r]] <- data.frame(Repeat=r,AUROC=au,LogLoss=ll,Brier=br)
}
pdf <- do.call(rbind,perf)
write.csv(pdf,file.path(RES_DIR,"strategyB_outer_fold_summary.csv"),row.names=FALSE,fileEncoding="UTF-8")
cat(sprintf("Mean AUROC=%.4f\n",mean(pdf$AUROC)))
cat("Panel dist:\n"); print(table(sp$panel))

# Final lock
cat("\n=== FINAL LOCK ===\n")
set.seed(20260929)
e386 <- compute_elig(rownames(X_all)); up386 <- names(e386)[e386]
x386 <- X_all[,up386,drop=FALSE]; y386 <- disc$y
p386 <- fit_prep(x386); k386 <- !p386$zv
x386s <- aply_prep(x386,p386)[,k386,drop=FALSE]
cat("Eligible:",length(up386),"features:",ncol(x386s),"\n")
f5 <- sample(rep(1:5,length.out=386))
bll<-Inf; bal<-NA; bli<-NA
for(al in ALPHAS) {
  ll_m <- matrix(NA,N_LAMBDA,5)
  for(k in 1:5) {
    tr<-f5!=k;va<-f5==k
    tryCatch({
      f<-glmnet(x386s[tr,],y386[tr],family="binomial",alpha=al,nlambda=N_LAMBDA,standardize=FALSE)
      pr<-predict(f,newx=x386s[va,],type="response")
      for(li in 1:ncol(pr)){p<-pmin(pmax(pr[,li],1e-10),1-1e-10);ll_m[li,k]<--mean(y386[va]*log(p)+(1-y386[va])*log(1-p))}
    },error=function(e)NULL)
  }
  ml<-rowMeans(ll_m,na.rm=TRUE);if(all(is.na(ml)))next
  b<-which.min(ml);lse<-apply(ll_m,1,sd,na.rm=TRUE)/sqrt(5)
  w<-which(ml<=ml[b]+lse[b]);ch<-min(w)
  if(ml[ch]<bll){bll<-ml[ch];bal<-al;bli<-ch}
}
cat("Selected alpha:",bal,"lambda_idx:",bli,"\n")
ff2 <- glmnet(x386s,y386,family="binomial",alpha=bal,nlambda=N_LAMBDA,standardize=FALSE)
luf <- min(bli,ncol(ff2$beta))
beta_f <- as.numeric(ff2$beta[,luf]); names(beta_f) <- colnames(x386s)
nz <- abs(beta_f)>0; n_pre <- sum(nz)
if(n_pre>MAX_PANEL) { keep <- names(beta_f)[nz][order(abs(beta_f[nz]),decreasing=TRUE)[1:MAX_PANEL]]
} else { keep <- names(beta_f)[nz] }
n_post <- length(keep)
cat("Final panel: pre=",n_pre," post=",n_post,"\n")
stopifnot(n_post<=MAX_PANEL)
if(n_post==0) {
  bint <- log(mean(y386)/(1-mean(y386))); base_p <- plogis(bint); coefs <- numeric(0); names(coefs)<-character(0)
} else {
  frefit <- glmnet(x386s[,keep,drop=FALSE], y386, family="binomial", alpha=1.0, lambda=0.01, standardize=FALSE)
  coefs <- as.numeric(coef(frefit)[-1,]); names(coefs) <- keep
  bint <- as.numeric(coef(frefit)[1,1])
  base_p <- mean(predict(frefit, newx=x386s[,keep,drop=FALSE], type="response"))
}
cat("Baseline p:",round(base_p,4)," prevalence:",round(mean(y386),4),"\n")
dir.create(file.path(OUT_ML,"models"),showWarnings=FALSE)
saveRDS(list(fit=ff2,lambda_idx=luf,alpha=bal,features=colnames(x386s),
  panel=keep,refit_coef=coefs,refit_intercept=bint,elig=up386),
  file.path(OUT_ML,"models/strategyB_primary_model.rds"))
write.csv(data.frame(Feature=keep,Coefficient=coefs),
  file.path(OUT_ML,"models/strategyB_primary_coefficients.csv"),row.names=FALSE,fileEncoding="UTF-8")
write.csv(data.frame(Feature=keep),
  file.path(OUT_ML,"models/strategyB_primary_features.csv"),row.names=FALSE,fileEncoding="UTF-8")
msha <- digest(file=file.path(OUT_ML,"models/strategyB_primary_model.rds"),algo="sha256")
writeLines(paste0("PRIMARY MODEL LOCKED\n",
  "Timestamp: ",format(Sys.time(),"%Y-%m-%d %H:%M:%S %Z"),"\n",
  "Model SHA-256: ",msha,"\nGit: c543c2ce4f9ef73b86230e72b84d8cb5344e76bc\n",
  "N: 386\nAlpha: ",bal,"\nPanel: ",n_post,"\n",
  "Baseline p: ",round(base_p,4),"\nPrevalence: ",round(mean(y386),4),"\n"),
  file.path(OUT_ML,"models/PRIMARY_MODEL_LOCK"))
cat("DONE.\n")
