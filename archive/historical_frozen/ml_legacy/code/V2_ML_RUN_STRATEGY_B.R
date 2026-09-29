# V2_ML_RUN_STRATEGY_B.R — Optimized version
library(readxl); library(glmnet); library(digest); library(pROC)
ROOT <- "F:/env"; setwd(ROOT)
OUT_ML <- "descriptive/analysis_v2.0/ml"
RES_DIR <- file.path(OUT_ML,"results"); MOD_DIR <- file.path(OUT_ML,"models")
dir.create(RES_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(MOD_DIR, showWarnings=FALSE, recursive=TRUE)
ALPHAS <- c(0.1,0.5,0.9,1.0)
N_LF <- 50
PANEL_TYPES <- c("k3","k5","k10","k20","untruncated")
K_MAP <- c(k3=3,k5=5,k10=10,k20=20,untruncated=Inf)
LF <- exp(seq(log(1),log(0.001),length.out=N_LF))
cat("Loading...\n")
ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
ch <- function(x){x<-trimws(as.character(x));sub("\\.0$","",x)}
ss$clean <- ch(ss$Sheet1_raw_header)
sm <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv", stringsAsFactors=FALSE)
disc <- sm[sm$Split=="Discovery",]; disc$y <- as.integer(disc$TREAT1_clean!="control")
raw <- read_excel("rawdata/processed.xlsx", n_max=3817, .name_repair="minimal")
abund <- as.data.frame(raw[,8:ncol(raw)]); rownames(abund) <- raw$PG.ProteinGroups
f3 <- read.csv("descriptive/analysis_v2.0/registry/contaminant_candidate_registry.csv", stringsAsFactors=FALSE)
excl <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible=="TRUE"]
abund_u <- abund[!rownames(abund)%in%excl,]
ss_d <- ss[match(disc$UniqueSampleID,ss$UniqueSampleID),]
dpos <- match(ss_d$clean,ss$clean)
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
ll_fn <- function(y,p){p<-pmax(pmin(p,1e-10),1-1e-10);-mean(y*log(p)+(1-y)*log(1-p))}
br_fn <- function(y,p) mean((p-y)^2)

# Single-candidate evaluator used by unit tests
eval_candidate <- function(xt,yt,xv,yv,alpha,lambda_frac,panel_type){
  if(ncol(xt)<2){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
    return(list(feats=character(0),n_features=0,lambda_refit=NA,pred=pr))}
  fit<-glmnet(xt,yt,family="binomial",alpha=alpha,nlambda=N_LF,standardize=FALSE)
  li<-which.min(abs(fit$lambda-lambda_frac*fit$lambda[1]))
  beta<-as.numeric(fit$beta[,li]);names(beta)<-colnames(xt)
  nz<-abs(beta)>0;nnz<-sum(nz)
  if(nnz==0){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
    return(list(feats=character(0),n_features=0,lambda_refit=NA,pred=pr))}
  if(panel_type=="untruncated"){
    pr<-as.numeric(predict(fit,newx=xv,s=fit$lambda[li],type="response"))
    return(list(feats=names(beta)[nz],n_features=nnz,lambda_refit=fit$lambda[li],pred=pr))}
  k<-K_MAP[panel_type];ak<-min(k,nnz)
  nzn<-names(beta)[nz];nza<-abs(beta[nz])
  ord<-order(-nza,nzn,method='radix');keep<-nzn[ord[1:ak]]
  xtk<-xt[,keep,drop=FALSE]
  if(ncol(xtk)<2){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
    return(list(feats=keep,n_features=length(keep),lambda_refit=NA,pred=pr))}
  fit2<-glmnet(xtk,yt,family="binomial",alpha=alpha,nlambda=N_LF,standardize=FALSE)
  li2<-which.min(abs(fit2$lambda-lambda_frac*fit2$lambda[1]))
  pr<-as.numeric(predict(fit2,newx=xv[,keep,drop=FALSE],s=fit2$lambda[li2],type="response"))
  list(feats=keep,n_features=ak,lambda_refit=fit2$lambda[li2],pred=pr)
}
# Global instrumentation counters
.counters <- new.env(parent=emptyenv())
.counters$full_path_fit_count <- 0
.counters$panel_refit_requests <- 0
.counters$unique_panel_refit_count <- 0
.counters$cache_hits <- 0

# Efficient: given preprocessed xt,yt,xv,yv, evaluate all candidates for one alpha
# With per-(keep) cache for capped-panel refits.
eval_alpha <- function(xt,yt,xv,yv,alpha){
  .counters$full_path_fit_count <- .counters$full_path_fit_count + 1
  if(ncol(xt)<2){
    p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
    return(data.frame(a=alpha,lf=LF,pt=rep(PANEL_TYPES,each=N_LF),
      ll=ll_fn(yv,pr),nf=0,stringsAsFactors=FALSE))
  }
  fit<-glmnet(xt,yt,family="binomial",alpha=alpha,nlambda=N_LF,standardize=FALSE)
  lams<-fit$lambda;lam_max<-lams[1]
  li_sapply<-sapply(LF,function(f) which.min(abs(lams-f*lam_max)))
  refit_cache <- new.env(hash=TRUE, parent=emptyenv())
  rows<-list()
  for(pt in PANEL_TYPES){
    for(i in seq_along(li_sapply)){
      li<-li_sapply[i];lf<-LF[i]
      beta<-as.numeric(fit$beta[,li]);names(beta)<-colnames(xt)
      nz<-abs(beta)>0;nnz<-sum(nz)
      if(nnz==0){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
        rows[[length(rows)+1]]<-data.frame(a=alpha,lf=lf,pt=pt,ll=ll_fn(yv,pr),nf=0,stringsAsFactors=FALSE);next}
      if(pt=="untruncated"){
        pr<-as.numeric(predict(fit,newx=xv,s=lams[li],type="response"))
        rows[[length(rows)+1]]<-data.frame(a=alpha,lf=lf,pt=pt,ll=ll_fn(yv,pr),nf=nnz,stringsAsFactors=FALSE);next}
      k<-K_MAP[pt];ak<-min(k,nnz)
      nzn<-names(beta)[nz];nza<-abs(beta[nz])
      ord<-order(-nza,nzn,method='radix');keep<-nzn[ord[1:ak]]
      if(ncol(xt[,keep,drop=FALSE])<2){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
        rows[[length(rows)+1]]<-data.frame(a=alpha,lf=lf,pt=pt,ll=ll_fn(yv,pr),nf=length(keep),stringsAsFactors=FALSE);next}
      .counters$panel_refit_requests <- .counters$panel_refit_requests + 1
      ck <- paste(keep, collapse="|")
      if(exists(ck, envir=refit_cache, inherits=FALSE)){
        .counters$cache_hits <- .counters$cache_hits + 1
        cached <- get(ck, envir=refit_cache)
        fit2 <- cached$fit2; xvk <- cached$xvk
      } else {
        .counters$unique_panel_refit_count <- .counters$unique_panel_refit_count + 1
        xtk<-xt[,keep,drop=FALSE];xvk<-xv[,keep,drop=FALSE]
        fit2<-glmnet(xtk,yt,family="binomial",alpha=alpha,nlambda=N_LF,standardize=FALSE)
        assign(ck, list(fit2=fit2, xvk=xvk), envir=refit_cache)
      }
      li2<-which.min(abs(fit2$lambda-lf*fit2$lambda[1]))
      pr<-as.numeric(predict(fit2,newx=xvk,s=fit2$lambda[li2],type="response"))
      rows[[length(rows)+1]]<-data.frame(a=alpha,lf=lf,pt=pt,ll=ll_fn(yv,pr),nf=ak,stringsAsFactors=FALSE)
    }
  }
  do.call(rbind,rows)
}

inner_cv_o <- function(rep,oo){
  ri<-inf[inf$Repeat==rep&inf$Outer_fold==oo&inf$Role=="inner_training_or_val",]
  agg_df<-NULL
  for(iv in 1:5){
    itr<-ri$Participant_ID[ri$Inner_fold!=iv];ivl<-ri$Participant_ID[ri$Inner_fold==iv]
    e<-compute_elig(itr);ep<-names(e)[e]
    xit<-X_all[itr,ep,drop=FALSE];yit<-disc$y[match(itr,disc$UniqueSampleID)]
    pp<-fit_prep(xit);kp<-!pp$zv
    xt<-aply(xit,pp)[,kp,drop=FALSE]
    xv<-aply(X_all[ivl,ep,drop=FALSE],pp)[,kp,drop=FALSE]
    yv<-disc$y[match(ivl,disc$UniqueSampleID)]
    for(al in ALPHAS){
      r<-eval_alpha(xt,yit,xv,yv,al)
      if(is.null(agg_df)) agg_df<-r else agg_df<-rbind(agg_df,r)
    }
  }
  # Aggregate
  keys<-unique(agg_df[,c("a","lf","pt")])
  res<-do.call(rbind,lapply(seq_len(nrow(keys)),function(k){
    s<-agg_df[agg_df$a==keys$a[k]&agg_df$lf==keys$lf[k]&agg_df$pt==keys$pt[k],]
    data.frame(a=keys$a[k],lf=keys$lf[k],pt=keys$pt[k],ll=mean(s$ll),sd=sd(s$ll),nf=median(s$nf),stringsAsFactors=FALSE)
  }))
  res$se<-res$sd/sqrt(5)
  bi<-which.min(res$ll);th<-res$ll[bi]+res$se[bi]
  el<-res[res$ll<=th,]
  el<-el[order(el$nf,-el$lf,-el$a,el$pt),]
  list(best=el[1,])
}

# Outer predict with selected params
outer_pred <- function(rep,oo,ba,blf,bpt){
  ts<-of$Participant_ID[of$Repeat==rep&of$Outer_fold==oo]
  tr<-of$Participant_ID[of$Repeat==rep&of$Outer_fold!=oo]
  e<-compute_elig(tr);ep<-names(e)[e]
  xot<-X_all[tr,ep,drop=FALSE];yot<-disc$y[match(tr,disc$UniqueSampleID)]
  pp<-fit_prep(xot);kp<-!pp$zv
  xt<-aply(xot,pp)[,kp,drop=FALSE]
  xte<-aply(X_all[ts,ep,drop=FALSE],pp)[,kp,drop=FALSE]
  yotest<-disc$y[match(ts,disc$UniqueSampleID)]
  if(ncol(xt)<2){p_tr<-mean(yot);return(list(pred=rep(p_tr,length(ts)),nf=0,feats=character(0)))}
  fit<-glmnet(xt,yot,family="binomial",alpha=ba,nlambda=N_LF,standardize=FALSE)
  li<-which.min(abs(fit$lambda-blf*fit$lambda[1]))
  beta<-as.numeric(fit$beta[,li]);names(beta)<-colnames(xt)
  nz<-abs(beta)>0;nnz<-sum(nz)
  if(nnz==0){p_tr<-mean(yot);return(list(pred=rep(p_tr,length(ts)),nf=0,feats=character(0)))}
  if(bpt=="untruncated"){
    pr<-as.numeric(predict(fit,newx=xte,s=fit$lambda[li],type="response"))
    return(list(pred=pr,nf=nnz,feats=names(beta)[nz]))}
  k<-K_MAP[bpt];ak<-min(k,nnz)
  nzn<-names(beta)[nz];nza<-abs(beta[nz])
  ord<-order(-nza,nzn,method='radix');keep<-nzn[ord[1:ak]]
  xtk<-xt[,keep,drop=FALSE];xvk<-xte[,keep,drop=FALSE]
  if(ncol(xtk)<2){p_tr<-mean(yot);return(list(pred=rep(p_tr,length(ts)),nf=ncol(xtk),feats=keep))}
  fit2<-glmnet(xtk,yot,family="binomial",alpha=ba,nlambda=N_LF,standardize=FALSE)
  li2<-which.min(abs(fit2$lambda-blf*fit2$lambda[1]))
  pr<-as.numeric(predict(fit2,newx=xvk,s=fit2$lambda[li2],type="response"))
  list(pred=pr,nf=ak,feats=keep)
}

if (sys.nframe() == 0) {
cat("NESTED CV...\n")
allp<-list();alls<-list()
for(rep in 1:3){
  cat("Repeat",rep,"\n")
  for(oo in 1:5){
    cat(" O",oo)
    ic<-inner_cv_o(rep,oo);b<-ic$best
    ts<-of$Participant_ID[of$Repeat==rep&of$Outer_fold==oo]
    op<-outer_pred(rep,oo,b$a,b$lf,b$pt)
    allp[[length(allp)+1]]<-data.frame(Participant_ID=ts,Repeat=rep,Outer_fold=oo,
      observed=disc$y[match(ts,disc$UniqueSampleID)],predicted=op$pred,
      alpha=b$a,lam_frac=b$lf,panel=b$pt,n_feat=op$nf,stringsAsFactors=FALSE)
    alls[[length(alls)+1]]<-data.frame(Repeat=rep,Outer_fold=oo,alpha=b$a,lam_frac=b$lf,panel=b$pt,n_feat=b$nf,inner_ll=b$ll,stringsAsFactors=FALSE)
  }
  cat("\n")
}
op<-do.call(rbind,allp);sl<-do.call(rbind,alls)
cat("PER-REPEAT:\n")
mdf<-do.call(rbind,lapply(1:3,function(rep){
  d<-op[op$Repeat==rep,];rc<-roc(d$observed,d$predicted,quiet=TRUE)
  data.frame(Repeat=rep,AUROC=as.numeric(rc$auc),LogLoss=ll_fn(d$observed,d$predicted),Brier=br_fn(d$observed,d$predicted),stringsAsFactors=FALSE)
}))
for(i in 1:3) cat(sprintf("R%d: AUROC=%.4f LL=%.4f Brier=%.4f\n",i,mdf$AUROC[i],mdf$LogLoss[i],mdf$Brier[i]))
cat(sprintf("Mean AUROC=%.4f SD=%.4f\n",mean(mdf$AUROC),sd(mdf$AUROC)))
# Final tuning
cat("FINAL TUNING...\n")
set.seed(20260929)
ff<-sample(rep(1:5,length.out=386))
fa_list<-NULL
for(fv in 1:5){
  ftr<-disc$UniqueSampleID[ff!=fv];fval<-disc$UniqueSampleID[ff==fv]
  e<-compute_elig(ftr);ep<-names(e)[e]
  xft<-X_all[ftr,ep,drop=FALSE];yft<-disc$y[match(ftr,disc$UniqueSampleID)]
  pp<-fit_prep(xft);kp<-!pp$zv
  xt<-aply(xft,pp)[,kp,drop=FALSE]
  xv<-aply(X_all[fval,ep,drop=FALSE],pp)[,kp,drop=FALSE]
  yv<-disc$y[match(fval,disc$UniqueSampleID)]
  for(al in ALPHAS){
    r<-eval_alpha(xt,yft,xv,yv,al)
    if(is.null(fa_list)) fa_list<-r else fa_list<-rbind(fa_list,r)
  }
}
fk<-unique(fa_list[,c("a","lf","pt")])
fa<-do.call(rbind,lapply(seq_len(nrow(fk)),function(k){
  s<-fa_list[fa_list$a==fk$a[k]&fa_list$lf==fk$lf[k]&fa_list$pt==fk$pt[k],]
  data.frame(a=fk$a[k],lf=fk$lf[k],pt=fk$pt[k],ll=mean(s$ll),sd=sd(s$ll),nf=median(s$nf),stringsAsFactors=FALSE)
}))
fa$se<-fa$sd/sqrt(5)
fbi<-which.min(fa$ll);fth<-fa$ll[fbi]+fa$se[fbi]
fel<-fa[fa$ll<=fth,];fel<-fel[order(fel$nf,-fel$lf,-fel$a,fel$pt),];fb<-fel[1,]
cat(sprintf("FINAL: a=%.1f lf=%.5f p=%s nf=%d\n",fb$a,fb$lf,fb$pt,fb$nf))
# Final model on all 386
e_a<-compute_elig(disc$UniqueSampleID);ep_a<-names(e_a)[e_a]
xa<-X_all[disc$UniqueSampleID,ep_a,drop=FALSE];ya<-disc$y
pp_a<-fit_prep(xa);kp_a<-!pp_a$zv
xa_s<-aply(xa,pp_a)[,kp_a,drop=FALSE]
# Use outer_pred-like logic on all 386
if(ncol(xa_s)<2){p_tr<-mean(ya);rf_pred<-rep(p_tr,386);rf_nf<-0;rf_feats<-character(0)} else {
  fit<-glmnet(xa_s,ya,family="binomial",alpha=fb$a,nlambda=N_LF,standardize=FALSE)
  li<-which.min(abs(fit$lambda-fb$lf*fit$lambda[1]))
  beta<-as.numeric(fit$beta[,li]);names(beta)<-colnames(xa_s)
  nz<-abs(beta)>0;nnz<-sum(nz)
  if(nnz==0){rf_pred<-rep(mean(ya),386);rf_nf<-0;rf_feats<-character(0)}
  else if(fb$pt=="untruncated"){rf_pred<-as.numeric(predict(fit,newx=xa_s,s=fit$lambda[li],type="response"));rf_nf<-nnz;rf_feats<-names(beta)[nz]}
  else{
    k<-K_MAP[fb$pt];ak<-min(k,nnz)
    nzn<-names(beta)[nz];nza<-abs(beta[nz])
    ord<-order(-nza,nzn,method='radix');keep<-nzn[ord[1:ak]]
    xtk<-xa_s[,keep,drop=FALSE]
    if(ncol(xtk)<2){rf_pred<-rep(mean(ya),386);rf_nf<-ncol(xtk);rf_feats<-keep}
    else{
      fit2<-glmnet(xtk,ya,family="binomial",alpha=fb$a,nlambda=N_LF,standardize=FALSE)
      li2<-which.min(abs(fit2$lambda-fb$lf*fit2$lambda[1]))
      rf_pred<-as.numeric(predict(fit2,newx=xtk,s=fit2$lambda[li2],type="response"))
      rf_nf<-ak;rf_feats<-keep
    }
  }
}
cat("Panel:",fb$pt,"features:",rf_nf,"\n")
cat("Features:",paste(rf_feats,collapse=", "),"\n")
write.csv(op,file.path(RES_DIR,"strategyB_outer_predictions.csv"),row.names=FALSE)
write.csv(sl,file.path(RES_DIR,"strategyB_selected_hyperparameters.csv"),row.names=FALSE)
write.csv(mdf,file.path(RES_DIR,"strategyB_repeat_metrics.csv"),row.names=FALSE)
saveRDS(list(alpha=fb$a,lam_frac=fb$lf,panel=fb$pt,n_feat=rf_nf,feats=rf_feats,pp=pp_a,kp=kp_a,ep=ep_a),file.path(MOD_DIR,"strategyB_primary_model.rds"))
write.csv(data.frame(Feature=rf_feats,stringsAsFactors=FALSE),file.path(MOD_DIR,"strategyB_primary_features.csv"),row.names=FALSE)
man<-data.frame(metric=c("Discovery_N","Control","Exposure","Mean_AUROC","Mean_LogLoss","Mean_Brier","Final_alpha","Final_lam_frac","Final_panel","Final_n_feat"),
  value=c(386,115,271,round(mean(mdf$AUROC),4),round(mean(mdf$LogLoss),4),round(mean(mdf$Brier),4),fb$a,fb$lf,fb$pt,rf_nf),stringsAsFactors=FALSE)
write.csv(man,file.path(MOD_DIR,"strategyB_model_manifest.csv"),row.names=FALSE)
lock<-data.frame(item=c("status","timestamp","model_sha","manifest_sha"),
  value=c("LOCKED",as.character(Sys.time()),digest(file.path(MOD_DIR,"strategyB_primary_model.rds"),algo="sha256"),digest(file.path(MOD_DIR,"strategyB_model_manifest.csv"),algo="sha256")),stringsAsFactors=FALSE)
write.csv(lock,file.path(MOD_DIR,"PRIMARY_MODEL_LOCK"),row.names=FALSE)
cat(sprintf("\n=== COUNTERS ===\n"))
cat(sprintf("full_path_fit_count:    %d\n", .counters$full_path_fit_count))
cat(sprintf("panel_refit_requests:   %d\n", .counters$panel_refit_requests))
cat(sprintf("unique_panel_refit_count:%d\n", .counters$unique_panel_refit_count))
cat(sprintf("cache_hits:             %d\n", .counters$cache_hits))
cat(sprintf("estimated reduction:    %.1f%%\n",
  100*(1-.counters$unique_panel_refit_count/.counters$panel_refit_requests)))
cat("DONE.\n")
}
