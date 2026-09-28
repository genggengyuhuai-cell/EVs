#!/usr/bin/env Rscript
# V2 M10 — Environment + formal interaction, Q515, N=515.
# Stratified Group effects within Humid-hot and High-altitude;
# formal Group×Environment interaction (2-df) vs main-effects model.

suppressPackageStartupMessages({ library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M10_environment_interaction")
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
stopifnot(nrow(m)==515)

y <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y)<-"numeric"

# interaction design: Group*Environment (no intercept)
design_int <- model.matrix(~0+Group*Environment, data=m)
fit_int <- lmFit(y, design_int); fit_int <- eBayes(fit_int, trend=TRUE, robust=TRUE)
# interaction coefficients: GroupLow:EnvironmentHigh_altitude, GroupHigh:EnvironmentHigh_altitude
int_cols <- grep("EnvironmentHigh_altitude", colnames(fit_int$coefficients), value=TRUE)
cat("Interaction cols:", paste(int_cols, collapse=", "), "\n")
# joint 2-df interaction test via topTable
tt <- topTable(fit_int, coef=int_cols, number=Inf, sort.by="none")
tt <- tt[rownames(y),]
F_int <- tt$F; P_int <- tt$P.Value

# stratified E within each Environment
# Humid_hot: fit subset
fit_strat <- function(env_sub) {
  idx <- m$Environment==env_sub
  ys <- y[, idx, drop=FALSE]
  ms <- m[idx,]
  des <- model.matrix(~0+Group, data=ms)
  # E = (nL/nE)*Low + (nH/nE)*High - Control
  nL_s <- sum(ms$Group=="Low"); nH_s <- sum(ms$Group=="High")
  wL_s <- nL_s/(nL_s+nH_s); wH_s <- nH_s/(nL_s+nH_s)
  cn <- colnames(des)
  ev <- setNames(rep(0,length(cn)),cn); ev["GroupLow"]<-wL_s; ev["GroupHigh"]<-wH_s; ev["GroupControl"]<--1
  cm <- matrix(ev, ncol=1, dimnames=list(names(ev),"E"))
  d2 <- contrastAsCoef(des, cm)[["design"]]
  f <- lmFit(ys, d2); f <- eBayes(f, trend=TRUE, robust=TRUE)
  b <- f$coefficients[,"E"]
  se <- f$stdev.unscaled[,"E"]*sqrt(f$s2.post)
  p <- 2*pt(-abs(b/se), df=f$df.total)
  data.frame(E_strat=b, SE_strat=se, P_strat=p)
}
hum <- fit_strat("Humid_hot")
alt <- fit_strat("High_altitude")
colnames(hum) <- paste0(colnames(hum),"_Humid")
colnames(alt) <- paste0(colnames(alt),"_HighAlt")

res <- data.frame(PG.ProteinGroups=rownames(y),
  interaction_F=F_int, interaction_P=P_int,
  hum, alt)
res$interaction_BH <- p.adjust(res$interaction_P, method="BH")
# directional concordance
res$dir_concordant <- sign(res$E_strat_Humid)==sign(res$E_strat_HighAlt)
ann <- annot[,c("PG.ProteinGroups","Gene_symbol","Display_label")]
res <- merge(res, ann, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
res <- res[order(res$PG.ProteinGroups),]

out_csv <- file.path(out_dir,"M10_environment_interaction.csv")
out_man <- file.path(out_dir,"M10_manifest.csv")
for (f in c(out_csv,out_man)) if (file.exists(f)) stop("M10 overwrite: ",f)
write.csv(res,out_csv,row.names=FALSE,na="")

n_int <- sum(res$interaction_BH<0.05, na.rm=TRUE)
cat(sprintf("M10 interaction BH<0.05: %d/%d; dir concordance: %.1f%%\n",
  n_int, nrow(res), 100*mean(res$dir_concordant,na.rm=TRUE)))
man <- data.frame(item=c("module","universe","n_proteins","n_samples",
  "interaction_FDR_lt_0.05","dir_concordant_pct","timestamp"),
  value=c("M10_environment","Q515",nrow(res),515,n_int,
  sprintf("%.1f%%",100*mean(res$dir_concordant,na.rm=TRUE)),
  format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")))
write.csv(man,out_man,row.names=FALSE)
cat("M10_DONE\n")
