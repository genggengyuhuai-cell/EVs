#!/usr/bin/env Rscript
# V2 M08 Firth — Detection Group test, D515 universe.
suppressPackageStartupMessages({ library(logistf) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M08_detection","Firth_primary")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","D515.csv"), check.names=FALSE, stringsAsFactors=FALSE)
annot <- read.csv(file.path(root,"descriptive","canonical_protein_annotation.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)

d515_ids <- univ$PG.ProteinGroups[univ$D515==TRUE]
stopifnot(length(d515_ids)==3054)
mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
m <- meta[mat_samples,]
m$Group <- factor(m$TREAT1_clean, c("control","low","high"), c("Control","Low","High"))
site_to_env <- function(s) ifelse(grepl("^XZ_",s),"High_altitude",
                           ifelse(grepl("^(FJ_|GZ_)",s),"Humid_hot",NA))
m$Environment <- factor(site_to_env(m$group), c("Humid_hot","High_altitude"))
detmat <- 1L*(!is.na(log2mat[d515_ids, mat_samples]))
rownames(detmat) <- d515_ids

res <- data.frame(PG.ProteinGroups=d515_ids,
  rate_C=rowMeans(detmat[,m$Group=="Control"]),
  rate_L=rowMeans(detmat[,m$Group=="Low"]),
  rate_H=rowMeans(detmat[,m$Group=="High"]),
  Firth_Group_LR_P=NA_real_, Firth_Group_chisq=NA_real_, Model_status="PENDING")

for (i in seq_len(nrow(detmat))) {
  y <- detmat[i,]
  if (sum(y==1)<5 || sum(y==0)<5) { res$Model_status[i]<-"INSUFFICIENT"; next }
  tryCatch({
    df <- data.frame(y=y, Group=m$Group, Environment=m$Environment)
    f1 <- logistf(y ~ Group + Environment, data=df)
    f0 <- logistf(y ~ Environment, data=df)
    an <- anova(f0, f1)
    res$Firth_Group_LR_P[i] <- an$pval
    res$Firth_Group_chisq[i] <- an$chisq
    res$Model_status[i] <- "OK"
  }, error=function(e) { res$Model_status[i]<-paste0("FAIL_",substr(conditionMessage(e),1,40)) })
}
res$P_for_BH <- ifelse(res$Model_status=="OK", res$Firth_Group_LR_P, 1)
res$BH_FDR_A_Det_Firth <- p.adjust(res$P_for_BH, method="BH")
res$P_for_BH <- NULL
ann <- annot[,c("PG.ProteinGroups","Gene_symbol","Display_label")]
res <- merge(res, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
res <- res[order(res$PG.ProteinGroups),]
out_csv <- file.path(out_dir,"M08_Firth_detection_Group_LR.csv")
if (file.exists(out_csv)) stop("M08 Firth overwrite")
write.csv(res,out_csv,row.names=FALSE,na="")
n_sig <- sum(res$Model_status=="OK" & res$BH_FDR_A_Det_Firth<0.05, na.rm=TRUE)
cat(sprintf("M08 Firth: %d/%d FDR<0.05; non-OK=%d\n", n_sig, nrow(res), sum(res$Model_status!="OK")))
write.csv(data.frame(item=c("module","package","n_sig","n_total","timestamp"),
  value=c("M08_Firth","logistf",n_sig,nrow(res),format(Sys.time(),"%F %T"))),
  file.path(out_dir,"M08_Firth_manifest.csv"), row.names=FALSE)
cat("M08_FIRTH_DONE\n")
