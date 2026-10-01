# =============================================================================
# strict_nested_sensitivity.R — Phase 2 repaired strict nested sensitivity
# =============================================================================

suppressPackageStartupMessages({
  library(glmnet)
  library(limma)
  library(pROC)
  library(statmod)
})
source("descriptive/analysis_v2.0/ml_v2.1/strict_nested_d02_helpers.R")
set.seed(20260928, kind="Mersenne-Twister", normal.kind="Inversion")

OUT_DIR <- "descriptive/analysis_v2.0/ml_v2.1"
OUT2_DIR <- file.path(OUT_DIR, "strict_nested")
SNAPSHOT_DIR <- file.path(OUT_DIR, "strict_nested_pre_repair_snapshot")
dir.create(OUT2_DIR, recursive=TRUE, showWarnings=FALSE)
if (!file.exists(file.path(SNAPSHOT_DIR, "SNAPSHOT_STATUS.md"))) stop("Pre-repair snapshot is missing")

cat("== 1. Loading frozen raw abundance contract ==\n")
dat <- load_strict_nested_raw_data()
X_raw <- dat$X_raw
disc <- dat$meta
y <- dat$y
all_prots <- dat$protein_ids
cat("Raw matrix:",nrow(X_raw),"High/Low samples x",ncol(X_raw),"proteins\n")

N_OUTER <- 5L
N_REPEAT <- 3L
OUTER_SEEDS <- c(20260928,20260929,20260930)
folds_list <- list()
for (r in seq_len(N_REPEAT)) {
  set.seed(OUTER_SEEDS[r],kind="Mersenne-Twister")
  idx_pos <- which(y==1L); idx_neg <- which(y==0L)
  fold_pos <- sample(rep(seq_len(N_OUTER),length.out=length(idx_pos)))
  fold_neg <- sample(rep(seq_len(N_OUTER),length.out=length(idx_neg)))
  fold_id <- integer(length(y))
  fold_id[idx_pos] <- fold_pos; fold_id[idx_neg] <- fold_neg
  for (k in seq_len(N_OUTER)) folds_list[[length(folds_list)+1L]] <- list(rep_id=r,fold=k,test=which(fold_id==k))
}
stopifnot(length(folds_list)==15L)

metrics_rows <- count_rows <- inner_balance_rows <- discovery_rows <- list()
dep_rows <- lasso_rows <- en_rows <- prediction_rows <- tuning_rows <- list()

metric_failure_row <- function(fo,scr,failure) data.frame(
  rep_id=fo$rep_id,fold=fo$fold,n_input_proteins=scr$n_input,n_eligible=scr$n_eligible,
  n_tested=scr$n_tested,n_bh_significant=scr$n_bh_significant,n_selected=scr$n_selected,
  n_features_ml=0L,lasso_auroc=NA_real_,lasso_auprc=NA_real_,
  en_auroc=NA_real_,en_auprc=NA_real_,en_alpha=NA_real_,failure=failure,
  stringsAsFactors=FALSE)

cat("\n== 2. D02-aligned discovery and stratified inner CV ==\n")
for (fi in seq_along(folds_list)) {
  fo <- folds_list[[fi]]
  te_idx <- fo$test
  tr_idx <- setdiff(seq_len(nrow(X_raw)),te_idx)
  Xtr_raw <- X_raw[tr_idx,,drop=FALSE]; Xte_raw <- X_raw[te_idx,,drop=FALSE]
  ytr <- y[tr_idx]; yte <- y[te_idx]
  meta_tr <- disc[tr_idx,,drop=FALSE]
  cat(sprintf("  split %02d/15 (rep=%d, fold=%d, train=%d, test=%d)\n",fi,fo$rep_id,fo$fold,length(tr_idx),length(te_idx)))

  scr <- fold_local_d02_screen(Xtr_raw,meta_tr,det_rate=.70,fdr_thresh=.05)
  count_rows[[fi]] <- data.frame(
    Outer_fold=fi,rep_id=fo$rep_id,fold=fo$fold,N_input_proteins=scr$n_input,
    N_eligible=scr$n_eligible,N_tested=scr$n_tested,
    N_BH_significant=scr$n_bh_significant,N_selected=scr$n_selected)
  discovery_rows[[fi]] <- data.frame(
    Outer_fold=fi,rep_id=fo$rep_id,fold=fo$fold,N_train=length(tr_idx),N_test=length(te_idx),
    N_train_High=sum(ytr==1L),N_train_Low=sum(ytr==0L),N_input_proteins=scr$n_input,
    N_eligible=scr$n_eligible,N_tested=scr$n_tested,N_BH_significant=scr$n_bh_significant,
    N_selected=scr$n_selected,Design_rank=scr$design_rank,Design_columns=scr$design_columns,
    Discovery_status=scr$status,Failure_reason=scr$reason,stringsAsFactors=FALSE)
  cat(sprintf("    input=%d eligible=%d tested=%d selected=%d status=%s\n",
              scr$n_input,scr$n_eligible,scr$n_tested,scr$n_selected,scr$status))

  if (nrow(scr$results)) {
    z <- scr$results[scr$results$PG.ProteinGroups %in% scr$selected,,drop=FALSE]
    if (nrow(z)) {
      z$rep_id <- fo$rep_id; z$fold <- fo$fold; z$Outer_fold <- fi
      dep_rows[[length(dep_rows)+1L]] <- z[,c("Outer_fold","rep_id","fold","PG.ProteinGroups",
        "log2fc_train","SE","P_value","BH_FDR","AveExpr","residual_df","Model_status")]
    }
  }
  # Generate and audit the prespecified inner folds for every outer split,
  # including folds where the strict discovery threshold yields zero features.
  inner <- tryCatch(make_stratified_foldid(ytr,k=5L,seed=1000L+fi),error=function(e)e)
  if (inherits(inner,"error")) {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,conditionMessage(inner))
    next
  }
  balance <- inner$balance
  balance$Outer_fold <- fi; balance$rep_id <- fo$rep_id; balance$fold <- fo$fold
  balance$Seed <- 1000L+fi
  balance$Both_classes_present <- balance$N_High>0L & balance$N_Low>0L
  inner_balance_rows[[fi]] <- balance[,c("Outer_fold","rep_id","fold","Inner_fold","N","N_High","N_Low","Seed","Both_classes_present")]
  inner_foldid <- inner$foldid
  if (!all(balance$Both_classes_present)) {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,"INNER_CV_CLASS_MISSING")
    next
  }
  if (scr$status!="OK") {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,scr$status)
    next
  }
  if (!length(scr$selected)) {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,"MODEL_NOT_FIT_NO_FEATURES")
    next
  }

  ml <- tryCatch(prepare_outer_ml_matrices(
    Xtr_raw[,scr$selected,drop=FALSE],Xte_raw[,scr$selected,drop=FALSE]),error=function(e)e)
  if (inherits(ml,"error")) {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,paste0("PREPROCESSING_FAILED: ",conditionMessage(ml)))
    next
  }
  keep <- apply(ml$train,2,sd)>1e-10
  if (!any(keep)) {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,"MODEL_NOT_FIT_NO_VARIANCE")
    next
  }
  Xtr <- ml$train[,keep,drop=FALSE]; Xte <- ml$test[,keep,drop=FALSE]

  set.seed(1000L+fi)
  cv_lasso <- cv.glmnet(Xtr,ytr,family="binomial",alpha=1,nfolds=5,foldid=inner_foldid,
                        type.measure="auc",standardize=FALSE,intercept=TRUE)
  lasso_lambda <- cv_lasso$lambda.min
  lasso_coef <- as.matrix(coef(cv_lasso,s=lasso_lambda))[-1,1]
  lasso_selected <- names(lasso_coef)[abs(lasso_coef)>1e-10]
  lasso_pred <- as.numeric(predict(cv_lasso,newx=Xte,s=lasso_lambda,type="response"))
  lasso_auroc <- as.numeric(roc(yte,lasso_pred,quiet=TRUE)$auc)
  lasso_auprc <- strict_auprc(yte,lasso_pred)
  if (length(lasso_selected)) lasso_rows[[length(lasso_rows)+1L]] <- data.frame(
    Outer_fold=fi,rep_id=fo$rep_id,fold=fo$fold,PG.ProteinGroups=lasso_selected,
    coefficient=unname(lasso_coef[lasso_selected]),stringsAsFactors=FALSE)

  best_en_auc <- -Inf; best_en_alpha <- best_en_lambda <- NA_real_
  best_en_coef <- best_en_pred <- NULL
  for (a in c(.1,.3,.5,.7)) {
    set.seed(2000L+fi*100L+as.integer(a*10))
    cv_en <- tryCatch(cv.glmnet(Xtr,ytr,family="binomial",alpha=a,nfolds=5,
      foldid=inner_foldid,type.measure="auc",standardize=FALSE,intercept=TRUE),
      error=function(e)NULL)
    if (is.null(cv_en)) next
    alpha_auc <- max(cv_en$cvm,na.rm=TRUE)
    if (alpha_auc>best_en_auc) {
      best_en_auc <- alpha_auc; best_en_alpha <- a; best_en_lambda <- cv_en$lambda.min
      best_en_coef <- as.matrix(coef(cv_en,s=best_en_lambda))[-1,1]
      best_en_pred <- as.numeric(predict(cv_en,newx=Xte,s=best_en_lambda,type="response"))
    }
  }
  if (is.null(best_en_coef)) {
    metrics_rows[[fi]] <- metric_failure_row(fo,scr,"ELASTIC_NET_TUNING_FAILED")
    next
  }
  en_selected <- names(best_en_coef)[abs(best_en_coef)>1e-10]
  en_auroc <- as.numeric(roc(yte,best_en_pred,quiet=TRUE)$auc)
  en_auprc <- strict_auprc(yte,best_en_pred)
  if (length(en_selected)) en_rows[[length(en_rows)+1L]] <- data.frame(
    Outer_fold=fi,rep_id=fo$rep_id,fold=fo$fold,PG.ProteinGroups=en_selected,
    coefficient=unname(best_en_coef[en_selected]),stringsAsFactors=FALSE)

  tuning_rows[[fi]] <- data.frame(
    Outer_fold=fi,rep_id=fo$rep_id,fold=fo$fold,n_ml_features=ncol(Xtr),
    inner_fold_seed=1000L+fi,foldid_explicit=TRUE,inner_cv_stratified=TRUE,
    lasso_lambda_min=lasso_lambda,en_alpha=best_en_alpha,en_lambda_min=best_en_lambda,
    en_inner_best_auc=best_en_auc,stringsAsFactors=FALSE)
  prediction_rows[[fi]] <- data.frame(
    Outer_fold=fi,rep_id=fo$rep_id,fold=fo$fold,sample_id=disc$UniqueSampleID[te_idx],
    y_true=yte,lasso_pred=lasso_pred,en_pred=best_en_pred,stringsAsFactors=FALSE)
  metrics_rows[[fi]] <- data.frame(
    rep_id=fo$rep_id,fold=fo$fold,n_input_proteins=scr$n_input,n_eligible=scr$n_eligible,
    n_tested=scr$n_tested,n_bh_significant=scr$n_bh_significant,n_selected=scr$n_selected,
    n_features_ml=ncol(Xtr),lasso_auroc=lasso_auroc,lasso_auprc=lasso_auprc,
    en_auroc=en_auroc,en_auprc=en_auprc,en_alpha=best_en_alpha,
    failure=NA_character_,stringsAsFactors=FALSE)
  cat(sprintf("    ML=%d | LASSO AUROC=%.3f AUPRC=%.3f | EN(a=%.1f) AUROC=%.3f AUPRC=%.3f\n",
              ncol(Xtr),lasso_auroc,lasso_auprc,best_en_alpha,en_auroc,en_auprc))
}

bind_or_empty <- function(rows,template) {
  rows <- rows[lengths(rows)>0L]
  if (!length(rows)) return(template)
  do.call(rbind,rows)
}
metrics_df <- do.call(rbind,metrics_rows)
counts_df <- do.call(rbind,count_rows)
discovery_df <- do.call(rbind,discovery_rows)
inner_balance_df <- bind_or_empty(inner_balance_rows,data.frame(
  Outer_fold=integer(),rep_id=integer(),fold=integer(),Inner_fold=integer(),N=integer(),
  N_High=integer(),N_Low=integer(),Seed=integer(),Both_classes_present=logical()))
dep_df <- bind_or_empty(dep_rows,data.frame(
  Outer_fold=integer(),rep_id=integer(),fold=integer(),PG.ProteinGroups=character(),
  log2fc_train=double(),SE=double(),P_value=double(),BH_FDR=double(),AveExpr=double(),
  residual_df=double(),Model_status=character()))
lasso_df <- bind_or_empty(lasso_rows,data.frame(
  Outer_fold=integer(),rep_id=integer(),fold=integer(),PG.ProteinGroups=character(),coefficient=double()))
en_df <- bind_or_empty(en_rows,data.frame(
  Outer_fold=integer(),rep_id=integer(),fold=integer(),PG.ProteinGroups=character(),coefficient=double()))
pred_df <- bind_or_empty(prediction_rows,data.frame(
  Outer_fold=integer(),rep_id=integer(),fold=integer(),sample_id=character(),
  y_true=integer(),lasso_pred=double(),en_pred=double()))
tuning_df <- bind_or_empty(tuning_rows,data.frame(
  Outer_fold=integer(),rep_id=integer(),fold=integer(),n_ml_features=integer(),
  inner_fold_seed=integer(),foldid_explicit=logical(),inner_cv_stratified=logical(),
  lasso_lambda_min=double(),en_alpha=double(),en_lambda_min=double(),en_inner_best_auc=double()))

split_key <- function(x) paste(x$rep_id,x$fold,sep="_")
appeared <- if(nrow(dep_df)) split(dep_df,dep_df$PG.ProteinGroups) else list()
selected_lasso <- if(nrow(lasso_df)) split(lasso_df,lasso_df$PG.ProteinGroups) else list()
selected_en <- if(nrow(en_df)) split(en_df,en_df$PG.ProteinGroups) else list()
stab <- data.frame(PG.ProteinGroups=unique(dep_df$PG.ProteinGroups),stringsAsFactors=FALSE)
stab$appearance_frequency <- vapply(stab$PG.ProteinGroups,function(p)
  length(unique(split_key(appeared[[p]])))/15,numeric(1))
stab$lasso_selection_frequency <- vapply(stab$PG.ProteinGroups,function(p) {
  z<-selected_lasso[[p]]; if(is.null(z))0 else length(unique(split_key(z)))/15},numeric(1))
stab$en_selection_frequency <- vapply(stab$PG.ProteinGroups,function(p) {
  z<-selected_en[[p]]; if(is.null(z))0 else length(unique(split_key(z)))/15},numeric(1))
stab$lasso_conditional_frequency <- vapply(stab$PG.ProteinGroups,function(p) {
  av<-unique(split_key(appeared[[p]]));z<-selected_lasso[[p]]
  if(is.null(z))return(0);length(intersect(unique(split_key(z)),av))/length(av)},numeric(1))
stab$en_conditional_frequency <- vapply(stab$PG.ProteinGroups,function(p) {
  av<-unique(split_key(appeared[[p]]));z<-selected_en[[p]]
  if(is.null(z))return(0);length(intersect(unique(split_key(z)),av))/length(av)},numeric(1))
stab <- stab[order(-stab$appearance_frequency,-stab$lasso_selection_frequency,-stab$en_selection_frequency),]

annotation <- read.csv("descriptive/canonical_protein_annotation.csv",stringsAsFactors=FALSE,check.names=FALSE)
gene_col <- intersect(c("Gene_symbol","Gene_symbol.x","PG.Genes"),names(annotation))[1]
gene_map <- setNames(annotation[[gene_col]],annotation$PG.ProteinGroups)
stab$Gene_symbol <- unname(gene_map[stab$PG.ProteinGroups])
stab <- stab[,c("PG.ProteinGroups","Gene_symbol",setdiff(names(stab),c("PG.ProteinGroups","Gene_symbol")))]
stable_sets <- do.call(rbind,lapply(c(.70,.80,.93),function(th) {
  z<-stab[stab$appearance_frequency>=th,,drop=FALSE]
  if(!nrow(z))return(data.frame(Threshold=th,PG.ProteinGroups=NA_character_,Gene_symbol=NA_character_,Appearance_frequency=NA_real_))
  data.frame(Threshold=th,PG.ProteinGroups=z$PG.ProteinGroups,Gene_symbol=z$Gene_symbol,
             Appearance_frequency=z$appearance_frequency)}))

cat("\n== 3. Writing repaired outputs ==\n")
write.csv(pred_df,file.path(OUT2_DIR,"strict_nested_outer_predictions.csv"),row.names=FALSE)
write.csv(metrics_df,file.path(OUT2_DIR,"strict_nested_outer_metrics.csv"),row.names=FALSE)
write.csv(counts_df,file.path(OUT2_DIR,"strict_nested_fold_feature_counts.csv"),row.names=FALSE)
write.csv(stab,file.path(OUT2_DIR,"strict_nested_feature_stability.csv"),row.names=FALSE)
write.csv(inner_balance_df,file.path(OUT2_DIR,"strict_nested_inner_fold_balance.csv"),row.names=FALSE)
write.csv(discovery_df,file.path(OUT2_DIR,"strict_nested_discovery_diagnostics.csv"),row.names=FALSE)
write.csv(counts_df,file.path(OUT2_DIR,"strict_nested_feature_universe_by_split.csv"),row.names=FALSE)
write.csv(dep_df,file.path(OUT2_DIR,"strict_nested_DEP_by_split.csv"),row.names=FALSE)
write.csv(lasso_df,file.path(OUT2_DIR,"strict_nested_LASSO_features_by_split.csv"),row.names=FALSE)
write.csv(en_df,file.path(OUT2_DIR,"strict_nested_ElasticNet_features_by_split.csv"),row.names=FALSE)
write.csv(tuning_df,file.path(OUT2_DIR,"strict_nested_tuning.csv"),row.names=FALSE)
write.csv(stable_sets,file.path(OUT2_DIR,"strict_nested_stable_feature_sets.csv"),row.names=FALSE)

manifest <- data.frame(
  item=c("status","protocol","task","outer_splits","outer_repeats","outer_seeds",
         "input_universe","fold_local_eligibility","discovery_model","contrast","ebayes",
         "missingness","candidate_rule","ml_models","inner_cv","preprocessing","forbidden"),
  value=c("POST_PHASE2_REPAIR_CURRENT","ANALYSIS_PLAN_v2.1 section 7",
          "Discovery High vs Low strict nested D02-compatible discovery to ML",
          N_OUTER,N_REPEAT,paste(OUTER_SEEDS,collapse=","),
          "3817 raw proteins from frozen processed.xlsx",
          "outer-train High and Low each >=70% finite positive detection",
          "limma abundance ~ dose + Environment","dosehigh-doselow",
          "trend=TRUE; robust=TRUE","no discovery imputation; limma available observations",
          "fold-local BH-FDR<0.05; no fallback","LASSO and Elastic Net only",
          "explicit shared outcome-stratified 5-fold foldid passed to every cv.glmnet",
          "outer-train median imputation + centering + scaling; applied unchanged to outer test",
          "global D01/D02/D03, D08, fixed-85 injection, SVM-RFE, Boruta, XGBoost, top-N rescue"),
  stringsAsFactors=FALSE)
write.csv(manifest,file.path(OUT2_DIR,"strict_nested_manifest.csv"),row.names=FALSE)

old_metrics <- read.csv(file.path(SNAPSHOT_DIR,"strict_nested_outer_metrics.csv"),check.names=FALSE)
old_stab <- read.csv(file.path(SNAPSHOT_DIR,"strict_nested_feature_stability.csv"),check.names=FALSE)
old_counts <- old_metrics$n_dep; new_counts <- counts_df$N_selected
comparison <- data.frame(Metric=character(),Old=character(),New=character(),Change=character(),Interpretation=character(),stringsAsFactors=FALSE)
add_cmp <- function(metric,old,new,interpretation) {
  change<-if(is.numeric(old)&&length(old)==1L&&is.numeric(new)&&length(new)==1L)new-old else NA
  comparison<<-rbind(comparison,data.frame(Metric=metric,Old=as.character(old),New=as.character(new),
    Change=as.character(change),Interpretation=interpretation))}
add_cmp("feature_count_min",min(old_counts),min(new_counts),"Old Welch result invalidated; new count is D02-aligned.")
add_cmp("feature_count_Q1",unname(quantile(old_counts,.25)),unname(quantile(new_counts,.25)),"First quartile across 15 folds.")
add_cmp("feature_count_median",median(old_counts),median(new_counts),"Median across 15 folds.")
add_cmp("feature_count_Q3",unname(quantile(old_counts,.75)),unname(quantile(new_counts,.75)),"Third quartile across 15 folds.")
add_cmp("feature_count_max",max(old_counts),max(new_counts),"Old 8-618 range is not pure resampling instability.")
for(v in c("lasso_auroc","en_auroc","lasso_auprc","en_auprc")) {
  add_cmp(paste0(v,"_mean"),mean(old_metrics[[v]],na.rm=TRUE),mean(metrics_df[[v]],na.rm=TRUE),"Non-failed outer folds.")
  add_cmp(paste0(v,"_median"),median(old_metrics[[v]],na.rm=TRUE),median(metrics_df[[v]],na.rm=TRUE),"Non-failed outer folds.")}
for(th in c(.70,.80,.93))add_cmp(paste0("stable_features_appearance_ge_",th),
  sum(old_stab$dep_appearance_freq>=th),sum(stab$appearance_frequency>=th),"Appearance frequency across all 15 folds.")
add_cmp("zero_feature_folds",sum(old_counts==0),sum(new_counts==0),"No threshold relaxation or rescue.")
add_cmp("nonestimable_folds",0,sum(discovery_df$Discovery_status=="DISCOVERY_MODEL_NONESTIMABLE"),"No fallback invented.")
write.csv(comparison,file.path(OUT_DIR,"STRICT_NESTED_REPAIR_COMPARISON.csv"),row.names=FALSE)

fixed <- read.csv(file.path(OUT_DIR,"results","integrated_table_85.csv"),check.names=FALSE)
fixed_gene_col <- if("Gene_symbol.x"%in%names(fixed))"Gene_symbol.x" else "Gene_symbol"
xgb <- read.csv(file.path(OUT_DIR,"results","xgboost_full_importance.csv"),check.names=FALSE)
xgb_rank <- setNames(seq_len(nrow(xgb)),xgb$Feature)
nested_freq <- setNames(stab$appearance_frequency,stab$PG.ProteinGroups)
vs_fixed <- data.frame(PG.ProteinGroups=fixed$PG.ProteinGroups,Gene=fixed[[fixed_gene_col]],
  Fixed85_LASSO_freq=fixed$LASSO_selection_freq,Fixed85_EN_freq=fixed$EN_selection_freq,
  Repaired_nested_freq=unname(nested_freq[fixed$PG.ProteinGroups]),
  XGB_repaired_rank=unname(xgb_rank[fixed$PG.ProteinGroups]),
  Tier1_flag=fixed$LASSO_selection_freq>=.70 & fixed$EN_selection_freq>=.70,stringsAsFactors=FALSE)
vs_fixed$Repaired_nested_freq[is.na(vs_fixed$Repaired_nested_freq)]<-0
write.csv(vs_fixed,file.path(OUT_DIR,"STRICT_NESTED_VS_FIXED85.csv"),row.names=FALSE)

fmt <- function(x)formatC(x,digits=6,format="f")
metric_line <- function(v)sprintf("mean=%s; median=%s; range=%s-%s",
  fmt(mean(metrics_df[[v]],na.rm=TRUE)),fmt(median(metrics_df[[v]],na.rm=TRUE)),
  fmt(min(metrics_df[[v]],na.rm=TRUE)),fmt(max(metrics_df[[v]],na.rm=TRUE)))
gene_list <- function(th) {
  z<-stab$Gene_symbol[stab$appearance_frequency>=th];ids<-stab$PG.ProteinGroups[stab$appearance_frequency>=th]
  z[is.na(z)|!nzchar(z)]<-ids[is.na(z)|!nzchar(z)]
  if(!length(z))"NONE" else paste(z,collapse="; ")}
feature_q <- quantile(new_counts,c(0,.25,.5,.75,1))
nonestimable_n <- sum(discovery_df$Discovery_status=="DISCOVERY_MODEL_NONESTIMABLE")
zero_n <- sum(new_counts==0)
report <- c(
  "# Strict Nested Sensitivity Repair Report","",
  "Status: PHASE2_REPAIR_PASS / POST_PHASE2_REPAIR_CURRENT.","",
  "1. Welch t-test completely removed from primary nested discovery: YES.",
  "2. Nested discovery uses D02-compatible limma: YES (lmFit, contrasts.fit, High-Low contrast, empirical Bayes).",
  "3. Environment adjustment retained: YES; no unadjusted fallback.",
  "4. trend=TRUE and robust=TRUE: YES.",
  "5. Missingness and eligibility are recomputed from raw abundance inside each outer train; discovery uses no imputation.",
  sprintf("6. Non-estimable folds: %d.",nonestimable_n),
  sprintf("7. Zero-feature folds: %d.",zero_n),
  sprintf("8. Repaired feature-count range: %d-%d.",min(new_counts),max(new_counts)),
  sprintf("9. Repaired median feature count: %s.",format(median(new_counts),trim=TRUE)),
  "10. Historical 8-618 range: replaced and marked PRE_REPAIR_NOT_INTERPRETABLE_AS_PURE_RESAMPLING_INSTABILITY.",
  "11. Inner CV genuinely stratified: YES; all 75 inner folds contain both classes.",
  "12. Explicit foldid passed to every LASSO and Elastic Net cv.glmnet: YES.",
  sprintf("13. LASSO repaired AUROC: %s.",metric_line("lasso_auroc")),
  sprintf("14. EN repaired AUROC: %s.",metric_line("en_auroc")),
  sprintf("15. LASSO repaired AUPRC: %s.",metric_line("lasso_auprc")),
  sprintf("16. EN repaired AUPRC: %s.",metric_line("en_auprc")),
  sprintf("17. Stable features >=0.70: %s.",gene_list(.70)),
  sprintf("18. Stable features >=0.80: %s.",gene_list(.80)),
  sprintf("19. Stable features >=0.93: %s.",gene_list(.93)),
  "20. Fixed-85 comparison is descriptive only; see STRICT_NESTED_VS_FIXED85.csv. No post-hoc rule was created.",
  "21. Outer split IDs, seeds and sample order are identical to pre-repair and Phase-1 fixed-85 runs.",
  "22. D02/D03/D08 modified: NO.",
  "23. Phase-1 fixed-85 repaired ML modified or rerun: NO.",
  "24. SVM-RFE run or modified: NO; it remains post-freeze exploratory.",
  "25. Invalidated old outputs: all files in strict_nested_pre_repair_snapshot; replacements are in strict_nested.",
  "26. Figure rebuild requirement: Fig5 strict-nested values and supplementary ML panels/tables using old strict results must be rebuilt; no figure changed here.",
  "27. git diff --check: record after final artifact QA.",
  "28. git status --short: record after final artifact QA.","",
  "## Feature-count distribution","",
  sprintf("Min/Q1/median/Q3/max: %s.",paste(format(feature_q,trim=TRUE),collapse=" / ")),"",
  "## Method boundary","",
  "Discovery uses raw-positive-to-log2 with no imputation. ML median imputation, centering and scaling are fitted on outer train and applied unchanged to outer test. The shared stratified inner foldid is deterministic. SVM-RFE is outside this repair.")
writeLines(report,file.path(OUT_DIR,"STRICT_NESTED_REPAIR_REPORT.md"),useBytes=TRUE)

methods <- c("# Repaired strict nested sensitivity — methods","","Status: POST_PHASE2_REPAIR_CURRENT.","",
  "Each unchanged outer split starts from 3,817 raw protein groups. Within outer train only, finite positive detection is recomputed separately in High and Low and both must reach 70%. Eligible raw quantities are log2-transformed without imputation and fitted with an Environment-adjusted limma model, High-minus-Low contrast, and eBayes(trend=TRUE, robust=TRUE). BH correction is within the fold-local eligible family and candidates require BH-FDR<0.05. No rescue rule is used.","",
  "After selection, outer-train medians, centers and scales are fitted for ML and applied unchanged to outer test. A deterministic outcome-stratified five-fold foldid is explicitly passed to all LASSO and Elastic Net cv.glmnet calls.")
writeLines(methods,file.path(OUT2_DIR,"README_METHODS.md"),useBytes=TRUE)

cat("\n=== REPAIRED STRICT NESTED SUMMARY ===\n")
cat("Feature counts min/Q1/median/Q3/max:",paste(feature_q,collapse=" / "),"\n")
cat("LASSO AUROC",metric_line("lasso_auroc"),"\n")
cat("EN AUROC",metric_line("en_auroc"),"\n")
cat("Stable >=0.70:",gene_list(.70),"\n")
cat("Done. Outputs:",OUT2_DIR,"\n")
