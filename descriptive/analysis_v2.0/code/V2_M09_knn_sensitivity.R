#!/usr/bin/env Rscript
# V2 M09 KNN sensitivity — k-NN imputation on Q515, compare M05 E effect.
# k=10 Euclidean on scaled observed values (row-based protein imputation).
suppressPackageStartupMessages({ library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M09_missingness_sensitivity","KNN_sensitivity")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)
m05 <- read.csv(file.path(v2,"M05_overall_exposure","M05_overall_exposure_AE_results.csv"),
                check.names=FALSE, stringsAsFactors=FALSE)

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

y <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y)<-"numeric"
# row-wise k-NN impute: for each missing cell, find k nearest proteins by correlation
# using observed overlap, average their values
k <- 10
y_imp <- y
# scale each protein
ys <- t(scale(t(y)))
for (i in seq_len(nrow(y))) {
  miss <- is.na(y[i,])
  if (all(!miss)) next
  # compute correlation with other proteins on overlapping observed
  obs <- !miss
  cors <- rep(0, nrow(y))
  for (j in seq_len(nrow(y))) {
    ov <- !is.na(y[j,]) & obs
    if (sum(ov) < 5) next
    cors[j] <- cor(ys[i,ov], ys[j,ov], use="complete.obs")
  }
  cors[i] <- -2
  neigh <- order(cors, decreasing=TRUE)[1:k]
  for (mm in which(miss)) {
    vals <- y[neigh, mm]
    y_imp[i,mm] <- median(vals, na.rm=TRUE)
  }
}
# still missing -> median
for (i in seq_len(nrow(y_imp))) if (anyNA(y_imp[i,])) y_imp[i,is.na(y_imp[i,])] <- median(y_imp[i,],na.rm=TRUE)

design <- model.matrix(~0+Group+Environment, data=m)
cn <- colnames(design)
e_vec <- setNames(rep(0,length(cn)),cn)
e_vec["GroupLow"]<-wL; e_vec["GroupHigh"]<-wH; e_vec["GroupControl"]<--1
cm <- matrix(e_vec,ncol=1,dimnames=list(names(e_vec),"E"))
d2 <- contrastAsCoef(design,cm)[["design"]]
fit <- lmFit(y_imp, d2); fit <- eBayes(fit, trend=TRUE, robust=TRUE)
e_knn <- fit$coefficients[,"E"]
names(e_knn) <- rownames(y_imp)

m05 <- m05[match(q515_ids, m05$PG.ProteinGroups),]
df <- data.frame(PG.ProteinGroups=q515_ids,
  E_primary=m05$log2FC_E, E_knn=e_knn[q515_ids])
df$diff <- df$E_knn - df$E_primary
cor_e <- cor(df$E_primary, df$E_knn, use="complete.obs")
rho <- cor(df$E_primary, df$E_knn, method="spearman", use="complete.obs")
agree <- mean(sign(df$E_primary)==sign(df$E_knn), na.rm=TRUE)
write.csv(df, file.path(out_dir,"M09_KNN_E_comparison.csv"), row.names=FALSE)
write.csv(data.frame(item=c("k","distance","corr_pearson","corr_spearman","direction_agreement_pct","timestamp"),
  value=c(10,"correlation-weighted Euclidean on z-scored proteins",
    sprintf("%.4f",cor_e),sprintf("%.4f",rho),sprintf("%.1f%%",100*agree),
    format(Sys.time(),"%F %T"))),
  file.path(out_dir,"M09_KNN_manifest.csv"), row.names=FALSE)
cat(sprintf("M09 KNN: corr=%.3f spearman=%.3f agree=%.1f%%\n",cor_e,rho,100*agree))
cat("M09_KNN_DONE\n")
