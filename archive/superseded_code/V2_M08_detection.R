#!/usr/bin/env Rscript
# V2 M08 — Detection / unique proteins, D515 universe, N=515.
# Detection = binary (non-NA log2 value). Standard logistic glm with Group+Environment.
# Separation / non-convergence explicitly flagged. BH across D515.

suppressPackageStartupMessages({})
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M08_detection")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","D515.csv"), check.names=FALSE, stringsAsFactors=FALSE)
annot <- read.csv(file.path(root,"descriptive","canonical_protein_annotation.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)

d515_ids <- univ$PG.ProteinGroups[univ$D515==TRUE]
stopifnot(length(d515_ids)==3054, !any(duplicated(d515_ids)))
cat("D515:", length(d515_ids), "\n")

mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
m <- meta[mat_samples,]
m$Group <- factor(m$TREAT1_clean, c("control","low","high"), c("Control","Low","High"))
site_to_env <- function(s) ifelse(grepl("^XZ_",s),"High_altitude",
                           ifelse(grepl("^(FJ_|GZ_)",s),"Humid_hot",NA))
m$Environment <- factor(site_to_env(m$group), c("Humid_hot","High_altitude"))
stopifnot(nrow(m)==515, sum(m$Group=="Control")==153, sum(m$Group=="Low")==186, sum(m$Group=="High")==176)

# detection matrix (1=detected, 0=missing)
detmat <- as.integer(!is.na(log2mat[d515_ids, mat_samples]))
dim(detmat) <- c(length(d515_ids), length(mat_samples))
rownames(detmat) <- d515_ids; colnames(detmat) <- mat_samples

# detection rates per group
rate_C <- rowMeans(detmat[, m$Group=="Control", drop=FALSE])
rate_L <- rowMeans(detmat[, m$Group=="Low", drop=FALSE])
rate_H <- rowMeans(detmat[, m$Group=="High", drop=FALSE])

# per-protein logistic: detected ~ Group + Environment, test Group (2-df)
# For efficiency, fit per-protein glm; capture Group likelihood-ratio P.
res_list <- vector("list", length(d515_ids))
for (i in seq_along(d515_ids)) {
  y <- detmat[i,]
  df <- data.frame(y=y, Group=m$Group, Environment=m$Environment)
  df <- df[complete.cases(df),]
  # need both detected and undetected
  if (sum(df$y==1) < 5 || sum(df$y==0) < 5) {
    res_list[[i]] <- data.frame(PG.ProteinGroups=d515_ids[i],
      Group_LR_P=NA, Group_LR_chisq=NA, Model_status="INSUFFICIENT_VARIATION")
    next
  }
  tryCatch({
    fit_full <- glm(y ~ Group + Environment, data=df, family=binomial())
    fit_null <- glm(y ~ Environment, data=df, family=binomial())
    lr <- anova(fit_null, fit_full, test="Chisq")
    p <- lr$`Pr(>Chi)`[2]; chisq <- lr$Deviance[2]
    res_list[[i]] <- data.frame(PG.ProteinGroups=d515_ids[i],
      Group_LR_P=p, Group_LR_chisq=chisq, Model_status="OK")
  }, error=function(e) {
    res_list[[i]] <<- data.frame(PG.ProteinGroups=d515_ids[i],
      Group_LR_P=NA, Group_LR_chisq=NA, Model_status=paste0("FAIL_", substr(conditionMessage(e),1,40)))
  })
}
res <- do.call(rbind, res_list)
res$Rate_Control <- rate_C[res$PG.ProteinGroups]
res$Rate_Low <- rate_L[res$PG.ProteinGroups]
res$Rate_High <- rate_H[res$PG.ProteinGroups]
# BH family A-Det across D515; non-estimable P=1
res$P_for_BH <- ifelse(res$Model_status=="OK", res$Group_LR_P, 1)
res$BH_FDR_A_Det <- p.adjust(res$P_for_BH, method="BH")
res$P_for_BH <- NULL
ann <- annot[,c("PG.ProteinGroups","Gene_symbol","Display_label")]
res <- merge(res, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
res <- res[order(res$PG.ProteinGroups),]

out_csv <- file.path(out_dir,"M08_detection_group_LR.csv")
out_man <- file.path(out_dir,"M08_manifest.csv")
for (f in c(out_csv,out_man)) if (file.exists(f)) stop("M08 overwrite: ",f)
write.csv(res,out_csv,row.names=FALSE,na="")

n_sig <- sum(res$Model_status=="OK" & res$BH_FDR_A_Det < 0.05, na.rm=TRUE)
cat(sprintf("M08 detection Group LR FDR<0.05: %d/%d; non-OK=%d\n",
  n_sig, nrow(res), sum(res$Model_status!="OK")))
man <- data.frame(item=c("module","universe","n_proteins","n_samples","family","timestamp"),
  value=c("M08_detection","D515",nrow(res),515,"A-Det",format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")))
write.csv(man,out_man,row.names=FALSE)
cat("M08_DONE\n")
