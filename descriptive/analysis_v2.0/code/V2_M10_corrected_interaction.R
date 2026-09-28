#!/usr/bin/env Rscript
# V2 M10 corrected — pure 2-df Group x Environment interaction.
suppressPackageStartupMessages({ library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M10_environment_interaction","corrected_pure_interaction")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

log2mat <- read.csv(gzfile(file.path(root,"descriptive","PRIMARY_dose_log2_expression.csv.gz")),
                    check.names=FALSE, row.names=1)
meta <- read.csv(file.path(root,"descriptive","dose_defined_metadata.csv"),
                 check.names=FALSE, stringsAsFactors=FALSE)
univ <- read.csv(file.path(v2,"universes","Q515.csv"), check.names=FALSE, stringsAsFactors=FALSE)
annot <- read.csv(file.path(root,"descriptive","canonical_protein_annotation.csv"),
                  check.names=FALSE, stringsAsFactors=FALSE)
q515_ids <- univ$PG.ProteinGroups[univ$Q515==TRUE]
mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
m <- meta[mat_samples,]
m$Group <- factor(m$TREAT1_clean, c("control","low","high"), c("Control","Low","High"))
site_to_env <- function(s) ifelse(grepl("^XZ_",s),"High_altitude",
                           ifelse(grepl("^(FJ_|GZ_)",s),"Humid_hot",NA))
m$Environment <- factor(site_to_env(m$group), c("Humid_hot","High_altitude"))
y <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y)<-"numeric"

# design with interaction; test ONLY the two interaction terms
design <- model.matrix(~0+Group*Environment, data=m)
fit <- lmFit(y, design); fit <- eBayes(fit, trend=TRUE, robust=TRUE)
int_cols <- grep(":", colnames(fit$coefficients), value=TRUE)
cat("Pure interaction cols:", paste(int_cols, collapse=", "), "\n")
stopifnot(length(int_cols)==2)
tt <- topTable(fit, coef=int_cols, number=Inf, sort.by="none")
tt <- tt[rownames(y),]
F_int <- tt$F; P_int <- tt$P.Value
BH_int <- p.adjust(P_int, method="BH")

# stratified E within each Environment
strat <- function(env) {
  idx <- m$Environment==env
  ys <- y[,idx]; ms <- m[idx,]
  des <- model.matrix(~0+Group, data=ms)
  nL<-sum(ms$Group=="Low"); nH<-sum(ms$Group=="High")
  wL<-nL/(nL+nH); wH<-nH/(nL+nH)
  cn<-colnames(des)
  ev<-setNames(rep(0,length(cn)),cn); ev["GroupLow"]<-wL; ev["GroupHigh"]<-wH; ev["GroupControl"]<--1
  cm<-matrix(ev,ncol=1,dimnames=list(names(ev),"E"))
  d2<-contrastAsCoef(des,cm)[["design"]]
  f<-lmFit(ys,d2); f<-eBayes(f,trend=TRUE,robust=TRUE)
  f$coefficients[,"E"]
}
e_hum <- strat("Humid_hot"); e_alt <- strat("High_altitude")

res <- data.frame(PG.ProteinGroups=q515_ids,
  E_Humid=e_hum, E_HighAlt=e_alt,
  interaction_F=F_int, interaction_P=P_int, interaction_BH=BH_int)
res$dir_concordant <- sign(res$E_Humid)==sign(res$E_HighAlt)
ann <- annot[,c("PG.ProteinGroups","Gene_symbol","Display_label")]
res <- merge(res, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
res <- res[order(res$PG.ProteinGroups),]
write.csv(res, file.path(out_dir,"M10_pure_interaction.csv"), row.names=FALSE)
n_sig <- sum(res$interaction_BH<0.05, na.rm=TRUE)
cat(sprintf("M10 corrected pure 2-df interaction BH<0.05: %d/%d; dir concordance=%.1f%%\n",
  n_sig, nrow(res), 100*mean(res$dir_concordant,na.rm=TRUE)))
write.csv(data.frame(item=c("module","df_interaction","n_sig","dir_concordance_pct","timestamp"),
  value=c("M10_corrected","2",n_sig,
    sprintf("%.1f%%",100*mean(res$dir_concordant,na.rm=TRUE)),
    format(Sys.time(),"%F %T"))),
  file.path(out_dir,"M10_corrected_manifest.csv"), row.names=FALSE)
cat("M10_CORRECTED_DONE\n")
