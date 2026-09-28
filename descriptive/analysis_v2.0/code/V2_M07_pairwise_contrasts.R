#!/usr/bin/env Rscript
# V2 M07 — Three pairwise abundance contrasts (LC, HC, HL), Q515, N=515.
# Each contrast has its own BH family:
#   A-LC: Low vs Control
#   A-HC: High vs Control
#   A-HL: High vs Low
# Design ~0+Group+Environment; exact contrasts via contrastAsCoef.

suppressPackageStartupMessages({ library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M07_pairwise_contrasts")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)
annot <- read.csv(file.path(root,"descriptive","canonical_protein_annotation.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)

q515_ids <- univ$PG.ProteinGroups[univ$Q515==TRUE]
stopifnot(length(q515_ids)==1430, !any(duplicated(q515_ids)))

mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
m <- meta[mat_samples,]
m$Group <- factor(m$TREAT1_clean, c("control","low","high"), c("Control","Low","High"))
site_to_env <- function(s) ifelse(grepl("^XZ_",s),"High_altitude",
                           ifelse(grepl("^(FJ_|GZ_)",s),"Humid_hot",NA))
m$Environment <- factor(site_to_env(m$group), c("Humid_hot","High_altitude"))
nC<-sum(m$Group=="Control"); nL<-sum(m$Group=="Low"); nH<-sum(m$Group=="High")
stopifnot(nC==153,nL==186,nH==176,nrow(m)==515)

y <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y)<-"numeric"
design <- model.matrix(~0+Group+Environment, data=m)

# build 3 contrasts
cn <- colnames(design)
mk <- function(a,b) { v<-setNames(rep(0,length(cn)),cn); v[b]<-1; v[a]<--1; v }
cont.mat <- cbind(LC=mk("GroupControl","GroupLow"),
                  HC=mk("GroupControl","GroupHigh"),
                  HL=mk("GroupLow","GroupHigh"))
fit0 <- lmFit(y, design)
fit <- contrasts.fit(fit0, cont.mat)
fit <- eBayes(fit, trend=TRUE, robust=TRUE)
dft <- fit$df.total

extract <- function(col) {
  b  <- fit$coefficients[,col]
  se <- fit$stdev.unscaled[,col]*sqrt(fit$s2.post)
  t  <- b/se
  p  <- 2*pt(-abs(t), df=dft)
  tc <- qt(0.975, df=dft)
  data.frame(PG.ProteinGroups=names(b), effect=b, SE=se,
             CI_low=b-tc*se, CI_high=b+tc*se, t=t, df=dft, P_raw=p,
             stringsAsFactors=FALSE)
}
LC <- extract("LC"); HC <- extract("HC"); HL <- extract("HL")

# per-group observed N
nGC <- rowSums(!is.na(y[,m$Group=="Control",drop=FALSE]))
nGL <- rowSums(!is.na(y[,m$Group=="Low",drop=FALSE]))
nGH <- rowSums(!is.na(y[,m$Group=="High",drop=FALSE]))
est <- (nGC>=10 & nGL>=10 & nGH>=10)

finalize <- function(d, fam) {
  d$P_for_BH <- ifelse(est[match(d$PG.ProteinGroups, rownames(y))], d$P_raw, 1)
  d$BH_FDR <- p.adjust(d$P_for_BH, method="BH")
  d$P_for_BH <- NULL
  d$direction <- ifelse(!est[match(d$PG.ProteinGroups, rownames(y))],"NON_ESTIMABLE",
                 ifelse(d$effect>0,"Higher","Lower"))
  d$family <- fam
  d
}
LC <- finalize(LC,"A-LC"); HC <- finalize(HC,"A-HC"); HL <- finalize(HL,"A-HL")

ann <- annot[,c("PG.ProteinGroups","Gene_symbol","Display_label")]
LC <- merge(LC, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
HC <- merge(HC, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
HL <- merge(HL, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
LC <- LC[order(LC$PG.ProteinGroups),]
HC <- HC[order(HC$PG.ProteinGroups),]
HL <- HL[order(HL$PG.ProteinGroups),]

out_lc <- file.path(out_dir,"M07_Low_vs_Control.csv")
out_hc <- file.path(out_dir,"M07_High_vs_Control.csv")
out_hl <- file.path(out_dir,"M07_High_vs_Low.csv")
out_man <- file.path(out_dir,"M07_manifest.csv")
for (f in c(out_lc,out_hc,out_hl,out_man)) if (file.exists(f)) stop("M07 overwrite: ",f)
write.csv(LC,out_lc,row.names=FALSE,na="")
write.csv(HC,out_hc,row.names=FALSE,na="")
write.csv(HL,out_hl,row.names=FALSE,na="")

cat(sprintf("LC FDR<0.05: %d (Higher=%d Lower=%d)\n",
  sum(LC$BH_FDR<0.05 & LC$direction!="NON_ESTIMABLE",na.rm=TRUE),
  sum(LC$BH_FDR<0.05 & LC$direction=="Higher",na.rm=TRUE),
  sum(LC$BH_FDR<0.05 & LC$direction=="Lower",na.rm=TRUE)))
cat(sprintf("HC FDR<0.05: %d (Higher=%d Lower=%d)\n",
  sum(HC$BH_FDR<0.05 & HC$direction!="NON_ESTIMABLE",na.rm=TRUE),
  sum(HC$BH_FDR<0.05 & HC$direction=="Higher",na.rm=TRUE),
  sum(HC$BH_FDR<0.05 & HC$direction=="Lower",na.rm=TRUE)))
cat(sprintf("HL FDR<0.05: %d (Higher=%d Lower=%d)\n",
  sum(HL$BH_FDR<0.05 & HL$direction!="NON_ESTIMABLE",na.rm=TRUE),
  sum(HL$BH_FDR<0.05 & HL$direction=="Higher",na.rm=TRUE),
  sum(HL$BH_FDR<0.05 & HL$direction=="Lower",na.rm=TRUE)))

man <- data.frame(item=c("module","universe","n_proteins","n_samples",
  "families","timestamp"),
  value=c("M07_pairwise","Q515",nrow(LC),515,
          "A-LC,A-HC,A-HL",format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")))
write.csv(man,out_man,row.names=FALSE)
cat("M07_DONE\n")
