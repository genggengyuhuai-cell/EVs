#!/usr/bin/env Rscript
# V2 M09 — Missingness sensitivity: primary (no imputation) vs median-imputed
# comparison on Q515. Compares M05 E effect under primary vs median-imputed model.
# KNN sensitivity noted as not available (DMwR absent); documented as limitation.

suppressPackageStartupMessages({ library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M09_missingness_sensitivity")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)

q515_ids <- univ$PG.ProteinGroups[univ$Q515==TRUE]
mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
m <- meta[mat_samples,]
m$Group <- factor(m$TREAT1_clean, c("control","low","high"), c("Control","Low","High"))
site_to_env <- function(s) ifelse(grepl("^XZ_",s),"High_altitude",
                           ifelse(grepl("^(FJ_|GZ_)",s),"Humid_hot",NA))
m$Environment <- factor(site_to_env(m$group), c("Humid_hot","High_altitude"))
nL<-sum(m$Group=="Low"); nH<-sum(m$Group=="High")
wL<-nL/(nL+nH); wH<-nH/(nL+nH)

# primary E from M05 result
m05 <- read.csv(file.path(v2,"M05_overall_exposure","M05_overall_exposure_AE_results.csv"),
                check.names=FALSE, stringsAsFactors=FALSE)

# median-imputed matrix (per-protein median across observed)
y_raw <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y_raw)<-"numeric"
y_imp <- t(apply(y_raw, 1, function(r) { r[is.na(r)] <- median(r, na.rm=TRUE); r }))

design <- model.matrix(~0+Group+Environment, data=m)
cn <- colnames(design)
e_vec <- setNames(rep(0,length(cn)),cn)
e_vec["GroupLow"]<-wL; e_vec["GroupHigh"]<-wH; e_vec["GroupControl"]<--1
cont <- matrix(e_vec, ncol=1, dimnames=list(names(e_vec),"E"))
design2 <- contrastAsCoef(design, cont)[["design"]]
fit_imp <- lmFit(y_imp, design2); fit_imp <- eBayes(fit_imp, trend=TRUE, robust=TRUE)
b_imp <- fit_imp$coefficients[,"E"]
se_imp <- fit_imp$stdev.unscaled[,"E"]*sqrt(fit_imp$s2.post)
p_imp <- 2*pt(-abs(b_imp/se_imp), df=fit_imp$df.total)

# align with M05
m05 <- m05[match(q515_ids, m05$PG.ProteinGroups),]
df <- data.frame(PG.ProteinGroups=q515_ids,
  E_primary=m05$log2FC_E,
  E_median_imputed=b_imp,
  P_primary=m05$P_raw,
  P_median_imputed=p_imp)
df$diff_E <- df$E_median_imputed - df$E_primary
df$sign_agree <- sign(df$E_primary)==sign(df$E_median_imputed)
cor_e <- cor(df$E_primary, df$E_median_imputed, use="complete.obs")
med_abs_diff <- median(abs(df$diff_E), na.rm=TRUE)

out_csv <- file.path(out_dir,"M09_median_imputation_sensitivity.csv")
out_man <- file.path(out_dir,"M09_manifest.csv")
for (f in c(out_csv,out_man)) if (file.exists(f)) stop("M09 overwrite: ",f)
write.csv(df,out_csv,row.names=FALSE,na="")

man <- data.frame(item=c("module","universe","n_proteins","n_samples",
  "corr_E_primary_vs_median","median_abs_diff_E","direction_agreement_pct",
  "KNN_status","timestamp"),
  value=c("M09_missingness_sensitivity","Q515",nrow(df),515,
  sprintf("%.4f",cor_e), sprintf("%.4f",med_abs_diff),
  sprintf("%.1f%%",100*mean(df$sign_agree,na.rm=TRUE)),
  "NOT_AVAILABLE_DMwR_not_installed",
  format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")))
write.csv(man,out_man,row.names=FALSE)
cat(sprintf("M09: corr=%.3f median|diff|=%.4f dir_agree=%.1f%%\n",
  cor_e, med_abs_diff, 100*mean(df$sign_agree,na.rm=TRUE)))
cat("M09_DONE\n")
