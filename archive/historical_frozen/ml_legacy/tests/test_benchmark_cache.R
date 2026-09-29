# Equivalence benchmark: old (uncached) vs new (cached) eval_alpha
library(glmnet)
set.seed(42)
n <- 120; p <- 40
x <- matrix(rnorm(n*p), n, p)
colnames(x) <- paste0("PG", 1:p)
true_beta <- c(2,-1.5,1,-0.8,0.5, rep(0,p-5))
y <- rbinom(n,1,plogis(x %*% true_beta))
tr <- 1:80; te <- 81:120
xt <- x[tr,]; yt <- y[tr]; xv <- x[te,]; yv <- y[te]

ALPHAS <- c(0.1,0.5,0.9,1.0); N_LF <- 50
PANEL_TYPES <- c("k3","k5","k10","k20","untruncated")
K_MAP <- c(k3=3,k5=5,k10=10,k20=20,untruncated=Inf)
LF <- exp(seq(log(1),log(0.001),length.out=N_LF))
ll_fn <- function(y,p){p<-pmax(pmin(p,1e-10),1-1e-10);-mean(y*log(p)+(1-y)*log(1-p))}

# OLD (uncached) — canonical order: pt outer, lf inner
eval_old <- function(xt,yt,xv,yv,alpha){
  if(ncol(xt)<2){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
    return(data.frame(a=alpha,lf=LF,pt=rep(PANEL_TYPES,each=N_LF),ll=ll_fn(yv,pr),nf=0,stringsAsFactors=FALSE))}
  fit<-glmnet(xt,yt,family="binomial",alpha=alpha,nlambda=N_LF,standardize=FALSE)
  lams<-fit$lambda;lam_max<-lams[1]
  li_sapply<-sapply(LF,function(f) which.min(abs(lams-f*lam_max)))
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
      xtk<-xt[,keep,drop=FALSE];xvk<-xv[,keep,drop=FALSE]
      if(ncol(xtk)<2){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
        rows[[length(rows)+1]]<-data.frame(a=alpha,lf=lf,pt=pt,ll=ll_fn(yv,pr),nf=ncol(xtk),stringsAsFactors=FALSE);next}
      fit2<-glmnet(xtk,yt,family="binomial",alpha=alpha,nlambda=N_LF,standardize=FALSE)
      li2<-which.min(abs(fit2$lambda-lf*fit2$lambda[1]))
      pr<-as.numeric(predict(fit2,newx=xvk,s=fit2$lambda[li2],type="response"))
      rows[[length(rows)+1]]<-data.frame(a=alpha,lf=lf,pt=pt,ll=ll_fn(yv,pr),nf=ak,stringsAsFactors=FALSE)
    }
  }
  do.call(rbind,rows)
}

# NEW (cached) — mirrors canonical runner exactly: pt outer, lf inner
.counters <- new.env(parent=emptyenv())
.counters$full_path_fit_count <- 0
.counters$panel_refit_requests <- 0
.counters$unique_panel_refit_count <- 0
.counters$cache_hits <- 0
eval_new <- function(xt,yt,xv,yv,alpha){
  .counters$full_path_fit_count <- .counters$full_path_fit_count + 1
  if(ncol(xt)<2){p_tr<-mean(yt);pr<-rep(p_tr,nrow(xv))
    return(data.frame(a=alpha,lf=LF,pt=rep(PANEL_TYPES,each=N_LF),ll=ll_fn(yv,pr),nf=0,stringsAsFactors=FALSE))}
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

# Run both
cat("Running old (uncached)...\n")
t_old <- system.time(res_old <- eval_old(xt,yt,xv,yv,0.5))
cat("Running new (cached)...\n")
t_new <- system.time(res_new <- eval_new(xt,yt,xv,yv,0.5))

# Compare with strict checks
TOL <- 1e-10
checks <- list()
checks$nrow_ok   <- nrow(res_old) == nrow(res_new)
checks$a_ok       <- isTRUE(all.equal(res_old$a,  res_new$a,  check.attributes=FALSE))
checks$lf_ok     <- isTRUE(all.equal(res_old$lf, res_new$lf, check.attributes=FALSE))
checks$pt_ok     <- isTRUE(all.equal(res_old$pt, res_new$pt, check.attributes=FALSE))
checks$nf_ok     <- isTRUE(all.equal(res_old$nf, res_new$nf, check.attributes=FALSE))
checks$ll_maxdiff <- max(abs(res_old$ll - res_new$ll))
checks$ll_ok     <- checks$ll_maxdiff <= TOL
order_identical <- checks$nrow_ok && checks$a_ok && checks$lf_ok && checks$pt_ok && checks$nf_ok

cat(sprintf("\n=== BENCHMARK (alpha=0.5, 80 train, 40 test, 40 features) ===\n"))
cat(sprintf("Old time: %.3fs\n", t_old["elapsed"]))
cat(sprintf("New time: %.3fs\n", t_new["elapsed"]))
cat(sprintf("Rows old=%d new=%d\n", nrow(res_old), nrow(res_new)))
cat(sprintf("nrow identical:     %s\n", checks$nrow_ok))
cat(sprintf("a identical:         %s\n", checks$a_ok))
cat(sprintf("lf identical:        %s\n", checks$lf_ok))
cat(sprintf("pt identical:        %s\n", checks$pt_ok))
cat(sprintf("n_feat identical:    %s\n", checks$nf_ok))
cat(sprintf("LL identical (<=%.0e): %s\n", TOL, checks$ll_ok))
cat(sprintf("max |LL diff|:       %e\n", checks$ll_maxdiff))
cat(sprintf("CANDIDATE_ORDER_IDENTICAL=%s\n", ifelse(order_identical,"TRUE","FALSE")))
cat(sprintf("\nCounters:\n"))
cat(sprintf("  full_path_fit_count:     %d\n", .counters$full_path_fit_count))
cat(sprintf("  panel_refit_requests:    %d\n", .counters$panel_refit_requests))
cat(sprintf("  unique_panel_refit:      %d\n", .counters$unique_panel_refit_count))
cat(sprintf("  cache_hits:              %d\n", .counters$cache_hits))
cat(sprintf("  reduction: %.1f%%\n", 100*(1-.counters$unique_panel_refit_count/.counters$panel_refit_requests)))

# Hard fail if any check fails
if(!all(unlist(checks[c("nrow_ok","a_ok","lf_ok","pt_ok","nf_ok","ll_ok")]))){
  cat("\nBENCHMARK FAILED: candidate rows not exactly equivalent\n")
  quit(status=1)
}
cat("\nBENCHMARK PASS\n")
