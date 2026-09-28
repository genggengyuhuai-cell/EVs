#!/usr/bin/env Rscript
# V2 M11 — Site robustness / heterogeneity, Q515, N=515.
# Site composition, leave-one-site-out E effect stability, heterogeneity summary.
# Site is treated as confounded-with-technical; no geographic-causality claim.

suppressPackageStartupMessages({ library(limma) })
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M11_site_robustness")
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
# site = m$group (e.g. FJ_QZ, XZ_GG)
cat("Site counts:\n"); print(table(m$group, m$Group))

y <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y)<-"numeric"

# M05 E effect as reference
m05 <- read.csv(file.path(v2,"M05_overall_exposure","M05_overall_exposure_AE_results.csv"),
                check.names=FALSE, stringsAsFactors=FALSE)
m05 <- m05[match(q515_ids, m05$PG.ProteinGroups),]

# leave-one-site-out: recompute E dropping each site
sites <- sort(unique(m$group))
loo_es <- list()
for (s in sites) {
  keep <- m$group != s
  ms <- m[keep,]
  ys <- y[, keep, drop=FALSE]
  des <- model.matrix(~0+Group, data=ms)
  nL<-sum(ms$Group=="Low"); nH<-sum(ms$Group=="High")
  wL<-nL/(nL+nH); wH<-nH/(nL+nH)
  cn <- colnames(des)
  ev <- setNames(rep(0,length(cn)),cn); ev["GroupLow"]<-wL; ev["GroupHigh"]<-wH; ev["GroupControl"]<--1
  cm <- matrix(ev, ncol=1, dimnames=list(names(ev),"E"))
  d2 <- contrastAsCoef(des, cm)[["design"]]
  f <- lmFit(ys, d2); f <- eBayes(f, trend=TRUE, robust=TRUE)
  loo_es[[s]] <- f$coefficients[,"E"]
}
loo_mat <- do.call(cbind, loo_es)
colnames(loo_mat) <- paste0("E_loo_drop_", sites)

res <- data.frame(PG.ProteinGroups=q515_ids, E_full=m05$log2FC_E, loo_mat)
res$E_loo_max_shift <- apply(abs(res[, paste0("E_loo_drop_",sites)] - res$E_full), 1, max)
res$E_loo_range <- apply(res[, paste0("E_loo_drop_",sites)], 1, function(x) max(x,na.rm=TRUE)-min(x,na.rm=TRUE))
res$loo_dir_consistent <- apply(res[, paste0("E_loo_drop_",sites)], 1, function(x) all(sign(x)==sign(x[1]), na.rm=TRUE))

out_csv <- file.path(out_dir,"M11_site_LOO_stability.csv")
out_man <- file.path(out_dir,"M11_manifest.csv")
for (f in c(out_csv,out_man)) if (file.exists(f)) stop("M11 overwrite: ",f)
write.csv(res,out_csv,row.names=FALSE,na="")

site_tab <- as.data.frame.matrix(table(m$group, m$Group))
write.csv(site_tab, file.path(out_dir,"M11_site_composition.csv"))

cat(sprintf("M11: sites=%d; LOO dir consistent=%.1f%%; median max shift=%.4f\n",
  length(sites), 100*mean(res$loo_dir_consistent,na.rm=TRUE),
  median(res$E_loo_max_shift,na.rm=TRUE)))
man <- data.frame(item=c("module","universe","n_proteins","n_sites",
  "loo_dir_consistent_pct","median_max_shift_log2","timestamp"),
  value=c("M11_site_robustness","Q515",nrow(res),length(sites),
  sprintf("%.1f%%",100*mean(res$loo_dir_consistent,na.rm=TRUE)),
  sprintf("%.4f",median(res$E_loo_max_shift,na.rm=TRUE)),
  format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")))
write.csv(man,out_man,row.names=FALSE)
cat("M11_DONE\n")
