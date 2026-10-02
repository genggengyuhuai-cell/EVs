#!/usr/bin/env Rscript
# Environment-stratified control-referenced cameraPR for 4 contrasts:
# HH LVC, HH HVC, HA LVC, HA HVC. Reuses frozen M12 mapping + gene sets.

suppressPackageStartupMessages({
  library(limma)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  library(GO.db)
  library(reactome.db)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
MAP_DIR <- file.path(M12, "mapping")
OUT <- "descriptive/environment_stratified_discovery/pathways_control_referenced"
RES <- file.path(OUT, "results")
DIAG <- file.path(OUT, "diagnostics")
dir.create(RES, recursive=TRUE, showWarnings=FALSE)
dir.create(DIAG, recursive=TRUE, showWarnings=FALSE)

set.seed(20260928, kind="Mersenne-Twister")

# ---- mapping contract (same as M12) ----
contract <- read.csv(file.path(MAP_DIR, "M12_gene_mapping_contract.csv"),
                     stringsAsFactors=FALSE, check.names=FALSE)
reps <- contract[contract$representative_status %in% c("REPRESENTATIVE","SINGLE") &
                 contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", ]
prot_to_gene <- setNames(reps$Gene_symbol, reps$PG.ProteinGroups)

# ---- gene sets (identical to M12) ----
go_map <- AnnotationDbi::select(org.Hs.eg.db,
    keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
    columns=c("GO","ONTOLOGY","SYMBOL"), keytype="ENTREZID")
go_bp_map <- go_map[go_map$ONTOLOGY=="BP" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_bp_terms <- lapply(split(go_bp_map$SYMBOL, go_bp_map$GO), unique)
go_bp_names <- AnnotationDbi::select(GO.db, keys=names(go_bp_terms),
                                      columns="TERM", keytype="GOID")
go_bp_name_map <- setNames(go_bp_names$TERM, go_bp_names$GOID)

rea_map <- AnnotationDbi::select(reactome.db,
    keys=keys(reactome.db, keytype="ENTREZID"),
    columns=c("REACTOMEID"), keytype="ENTREZID")
e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=rea_map$ENTREZID,
                             columns="SYMBOL", keytype="ENTREZID")
rea_map$SYMBOL <- e2s$SYMBOL[match(rea_map$ENTREZID, e2s$ENTREZID)]
rea_map <- rea_map[!is.na(rea_map$SYMBOL), ]
rea_list <- lapply(split(rea_map$SYMBOL, rea_map$REACTOMEID), unique)
rea_sets <- rea_list[lengths(rea_list) >= 10]

# ---- cameraPR runner ----
run_cam <- function(df, contrast_tag) {
  est <- df[df$Model_status == "ESTIMABLE" & df$Contrast == contrast_tag, ]
  est$moderated_t <- est$log2FC / est$SE
  est$gsym <- prot_to_gene[est$PG.ProteinGroups]
  st <- est[!is.na(est$gsym), c("gsym","moderated_t")]
  st <- st[!duplicated(st$gsym), ]
  stats <- sort(setNames(st$moderated_t, st$gsym), decreasing=TRUE)

  one <- function(sets, db, nm) {
    bg <- names(stats)
    sets_f <- lapply(sets, function(s) intersect(s, bg))
    keep <- lengths(sets_f) >= 10 & lengths(sets_f) <= 500
    sets_f <- sets_f[keep]
    rr <- lapply(names(sets_f), function(nm2) {
      mem <- sets_f[[nm2]]
      idx <- which(names(stats) %in% mem)
      cam <- tryCatch(cameraPR(stats, index=idx, use.ranks=FALSE, inter.gene.cor=0.01),
                      error=function(e) NULL)
      if (is.null(cam)) return(NULL)
      pname <- if (!is.null(nm) && nm2 %in% names(nm)) nm[[nm2]] else nm2
      data.frame(database=db, pathway_id=nm2, pathway_name=pname,
                 pathway_size=length(mem), direction=cam$Direction,
                 PValue=cam$PValue, FDR=NA, NGenes=cam$NGenes,
                 stringsAsFactors=FALSE)
    })
    r <- do.call(rbind, rr)
    r$FDR <- p.adjust(r$PValue, method="BH")
    r[order(r$PValue), ]
  }
  go <- one(go_bp_terms, "GO_BP", go_bp_name_map)
  ra <- one(rea_sets, "Reactome", NULL)
  all <- rbind(go, ra)
  all$FDR_pooled <- p.adjust(all$PValue, method="BH")
  list(go=go, rea=ra, all=all, n_ranked=length(stats), n_est=nrow(est))
}

# ---- load Phase 1 results ----
hh <- read.csv("descriptive/environment_stratified_discovery/results/humid_heat/humid_heat_all_tested.csv",
               stringsAsFactors=FALSE, check.names=FALSE)
ha <- read.csv("descriptive/environment_stratified_discovery/results/high_altitude/high_altitude_all_tested.csv",
               stringsAsFactors=FALSE, check.names=FALSE)

stopifnot(nrow(hh) == 1373*3, nrow(ha) == 1394*3)

hh_lvc <- run_cam(hh, "Short_vs_Control")
hh_hvc <- run_cam(hh, "Long_vs_Control")
ha_lvc <- run_cam(ha, "Short_vs_Control")
ha_hvc <- run_cam(ha, "Long_vs_Control")

# ---- write outputs ----
w <- function(x, f) write.csv(x, f, row.names=FALSE)
w(hh_lvc$all, file.path(RES, "HH_low_vs_control_cameraPR_all.csv"))
w(hh_lvc$all[hh_lvc$all$FDR_pooled<0.05,], file.path(RES, "HH_low_vs_control_cameraPR_significant.csv"))
w(hh_hvc$all, file.path(RES, "HH_high_vs_control_cameraPR_all.csv"))
w(hh_hvc$all[hh_hvc$all$FDR_pooled<0.05,], file.path(RES, "HH_high_vs_control_cameraPR_significant.csv"))
w(ha_lvc$all, file.path(RES, "HA_low_vs_control_cameraPR_all.csv"))
w(ha_lvc$all[ha_lvc$all$FDR_pooled<0.05,], file.path(RES, "HA_low_vs_control_cameraPR_significant.csv"))
w(ha_hvc$all, file.path(RES, "HA_high_vs_control_cameraPR_all.csv"))
w(ha_hvc$all[ha_hvc$all$FDR_pooled<0.05,], file.path(RES, "HA_high_vs_control_cameraPR_significant.csv"))

# ---- summary ----
cnt <- function(x) c(
  GO_BP_tested=sum(x$database=="GO_BP"),
  GO_BP_sig=sum(x$database=="GO_BP" & x$FDR_pooled<0.05),
  Reactome_tested=sum(x$database=="Reactome"),
  Reactome_sig=sum(x$database=="Reactome" & x$FDR_pooled<0.05),
  Total_sig=sum(x$FDR_pooled<0.05)
)
summ <- data.frame(
  Environment=c("Humid-heat","Humid-heat","High-altitude","High-altitude"),
  Contrast=c("Low vs Control","High vs Control","Low vs Control","High vs Control"),
  Q_universe=c(1373,1373,1394,1394),
  N_estimable=c(hh_lvc$n_est, hh_hvc$n_est, ha_lvc$n_est, ha_hvc$n_est),
  N_ranked_genes=c(hh_lvc$n_ranked, hh_hvc$n_ranked, ha_lvc$n_ranked, ha_hvc$n_ranked),
  rbind(cnt(hh_lvc$all), cnt(hh_hvc$all), cnt(ha_lvc$all), cnt(ha_hvc$all))
)
w(summ, file.path(RES, "environment_control_pathway_summary.csv"))

# ---- cross-contrast reconciliation ----
mk <- function(x, tag) x[, c("pathway_id","database","direction","PValue","FDR_pooled")]
names(hh_lvc$all)[3] <- "pathway_name"
rec <- Reduce(function(a,b) merge(a,b, by="pathway_id", all=TRUE),
  list(
    hh_lvc$all[, c("pathway_id","direction","FDR_pooled")] |> setNames(c("pathway_id","HH_LVC_dir","HH_LVC_FDR")),
    hh_hvc$all[, c("pathway_id","direction","FDR_pooled")] |> setNames(c("pathway_id","HH_HVC_dir","HH_HVC_FDR")),
    ha_lvc$all[, c("pathway_id","direction","FDR_pooled")] |> setNames(c("pathway_id","HA_LVC_dir","HA_LVC_FDR")),
    ha_hvc$all[, c("pathway_id","direction","FDR_pooled")] |> setNames(c("pathway_id","HA_HVC_dir","HA_HVC_FDR"))
  ))
w(rec, file.path(RES, "environment_control_pathway_reconciliation.csv"))

# ---- overall vs environment ----
ov_lvc <- read.csv("descriptive/discovery_validation/control_referenced_pathways/results/low_vs_control_cameraPR_all.csv",
                   stringsAsFactors=FALSE)
ov_hvc <- read.csv("descriptive/discovery_validation/control_referenced_pathways/results/high_vs_control_cameraPR_all.csv",
                   stringsAsFactors=FALSE)
ov_lvc_sig <- ov_lvc$pathway_id[ov_lvc$FDR_pooled<0.05]
ov_hvc_sig <- ov_hvc$pathway_id[ov_hvc$FDR_pooled<0.05]

ov_rec <- data.frame(
  pathway_id=unique(c(ov_lvc_sig, ov_hvc_sig)),
  Overall_LVC_sig=NA, Overall_HVC_sig=NA,
  HH_LVC_sig=NA, HH_HVC_sig=NA, HA_LVC_sig=NA, HA_HVC_sig=NA
)
ov_rec$Overall_LVC_sig <- ov_rec$pathway_id %in% ov_lvc_sig
ov_rec$Overall_HVC_sig <- ov_rec$pathway_id %in% ov_hvc_sig
ov_rec$HH_LVC_sig <- ov_rec$pathway_id %in% hh_lvc$all$pathway_id[hh_lvc$all$FDR_pooled<0.05]
ov_rec$HH_HVC_sig <- ov_rec$pathway_id %in% hh_hvc$all$pathway_id[hh_hvc$all$FDR_pooled<0.05]
ov_rec$HA_LVC_sig <- ov_rec$pathway_id %in% ha_lvc$all$pathway_id[ha_lvc$all$FDR_pooled<0.05]
ov_rec$HA_HVC_sig <- ov_rec$pathway_id %in% ha_hvc$all$pathway_id[ha_hvc$all$FDR_pooled<0.05]
w(ov_rec, file.path(RES, "overall_vs_environment_pathway_reconciliation.csv"))

# ---- diagnostics ----
diag <- data.frame(
  metric=c("Q_HH","Q_HA","HH_LVC_estimable","HH_HVC_estimable","HA_LVC_estimable","HA_HVC_estimable",
           "HH_LVC_ranked_genes","HH_HVC_ranked_genes","HA_LVC_ranked_genes","HA_HVC_ranked_genes",
           "HH_LVC_sig","HH_HVC_sig","HA_LVC_sig","HA_HVC_sig",
           "Overall_LVC_sig_reference","Overall_HVC_sig_reference"),
  value=c(1373,1394,hh_lvc$n_est,hh_hvc$n_est,ha_lvc$n_est,ha_hvc$n_est,
          hh_lvc$n_ranked,hh_hvc$n_ranked,ha_lvc$n_ranked,ha_hvc$n_ranked,
          sum(hh_lvc$all$FDR_pooled<0.05), sum(hh_hvc$all$FDR_pooled<0.05),
          sum(ha_lvc$all$FDR_pooled<0.05), sum(ha_hvc$all$FDR_pooled<0.05),
          258, 38)
)
w(diag, file.path(DIAG, "analysis_validation.csv"))

cat("DONE\n")
print(summ)
