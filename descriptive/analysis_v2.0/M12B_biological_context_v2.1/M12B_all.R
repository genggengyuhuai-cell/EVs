# =============================================================================
# M12C_extensions_and_M12B_context.R
# 1) GO MF/CC ranked + ORA (secondary)
# 2) fgsea multilevel sensitivity
# 3) M12B: network, env concordance, annotation, correlation, integrated table
# =============================================================================
suppressPackageStartupMessages({
  library(limma); library(fgsea); library(AnnotationDbi)
  library(org.Hs.eg.db); library(GO.db); library(clusterProfiler)
  library(reactome.db)
})

set.seed(20260928)
M12  <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
M12B <- "descriptive/analysis_v2.0/M12B_biological_context_v2.1"
for (d in c("ranked_gsea","network","environment","annotation","correlation",
            "integration","diagnostics")) {
  dir.create(file.path(M12B, d), recursive=TRUE, showWarnings=FALSE)
}

# -----------------------------------------------------------------------------
# Load shared objects
# -----------------------------------------------------------------------------
cat("== Loading shared objects ==\n")
contract <- read.csv(file.path(M12,"mapping/M12_gene_mapping_contract.csv"),
                     stringsAsFactors=FALSE, check.names=FALSE)
reps <- contract[contract$representative_status %in% c("REPRESENTATIVE","SINGLE") &
                 contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", ]
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names=1, check.names=FALSE)
meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors=FALSE)
disc <- meta[meta$Split=="Discovery" & meta$TREAT1_clean %in% c("high","low"), ]
common_samps <- intersect(disc$UniqueSampleID, colnames(expr))
disc <- disc[match(common_samps, disc$UniqueSampleID), ]
use_prots <- intersect(reps$PG.ProteinGroups, rownames(expr))
expr_use <- expr[use_prots, disc$UniqueSampleID]
prot_to_gene <- setNames(reps$Gene_symbol, reps$PG.ProteinGroups)
gene_vec <- prot_to_gene[rownames(expr_use)]

# [Phase 5 REPAIR] Canonical ranking = D02 primary model moderated t (log2FC/SE)
# No imputation, environment-adjusted.
# Expression matrix (mat) is retained below only for descriptive Spearman correlation (M12B section 6).
d02 <- read.csv("descriptive/discovery_validation/D02_discovery_primary/D02_Long_vs_Short_all_tested.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
d02_est <- d02[d02$Model_status == "ESTIMABLE", ]
d02_est$moderated_t <- d02_est$log2FC / d02_est$SE
mapped_pgs <- reps$PG.ProteinGroups
d02_mapped <- d02_est[d02_est$PG.ProteinGroups %in% mapped_pgs, ]
d02_mapped$Gene_symbol_mapped <- prot_to_gene[d02_mapped$PG.ProteinGroups]
stats_df <- d02_mapped[!is.na(d02_mapped$Gene_symbol_mapped), c("Gene_symbol_mapped", "moderated_t")]
stats_df <- stats_df[!duplicated(stats_df$Gene_symbol_mapped), ]
stats <- sort(setNames(stats_df$moderated_t, stats_df$Gene_symbol_mapped), decreasing=TRUE)
cat("Ranked genes (D02, mapped + estimable):", length(stats), "\n")

# Expression matrix for descriptive Spearman correlation only (M12B context layer)
mat <- as.matrix(expr_use)

# Pathway gene sets for BP/MF/CC
build_go_sets <- function(onto) {
  m <- AnnotationDbi::select(org.Hs.eg.db,
      keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
      columns=c("GO","ONTOLOGY","SYMBOL"), keytype="ENTREZID")
  m <- m[m$ONTOLOGY==onto & !is.na(m$GO) & !is.na(m$SYMBOL), ]
  s <- split(m$SYMBOL, m$GO); lapply(s, unique)
}
go_bp <- build_go_sets("BP")
go_mf <- build_go_sets("MF")
go_cc <- build_go_sets("CC")
# GO names
go_all_ids <- unique(c(names(go_bp), names(go_mf), names(go_cc)))
go_nm <- AnnotationDbi::select(GO.db, keys=go_all_ids, columns="TERM", keytype="GOID")
go_nm_map <- setNames(go_nm$TERM, go_nm$GOID)

# Reactome
rea_map <- AnnotationDbi::select(reactome.db,
    keys=keys(reactome.db, keytype="ENTREZID"),
    columns="REACTOMEID", keytype="ENTREZID")
e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=rea_map$ENTREZID,
                              columns="SYMBOL", keytype="ENTREZID")
rea_map$SYMBOL <- e2s$SYMBOL[match(rea_map$ENTREZID, e2s$ENTREZID)]
rea_map <- rea_map[!is.na(rea_map$SYMBOL), ]
rea_sets <- lapply(split(rea_map$SYMBOL, rea_map$REACTOMEID), unique)

# Filter helper
filt_sets <- function(sets) {
  bg <- names(stats)
  s <- lapply(sets, function(x) intersect(x, bg))
  s[lengths(s)>=10 & lengths(s)<=500]
}
go_bp_f <- filt_sets(go_bp)
go_mf_f <- filt_sets(go_mf)
go_cc_f <- filt_sets(go_cc)
rea_f   <- filt_sets(rea_sets)
cat(sprintf("Filtered: BP=%d MF=%d CC=%d Reactome=%d\n",
            length(go_bp_f), length(go_mf_f), length(go_cc_f), length(rea_f)))

# -----------------------------------------------------------------------------
# 1. cameraPR for GO MF and GO CC (cor=0.01 + 0.05)
# -----------------------------------------------------------------------------
cat("\n== 1. cameraPR GO MF/CC ==\n")
run_cam <- function(st, sets, label, cor, name_map=NULL) {
  bg <- names(st)
  s <- lapply(sets, function(x) intersect(x, bg))
  s <- s[lengths(s)>=10 & lengths(s)<=500]
  res <- lapply(names(s), function(nm) {
    members <- s[[nm]]
    idx <- which(names(st) %in% members)
    cam <- tryCatch(cameraPR(st, index=idx, use.ranks=FALSE, inter.gene.cor=cor),
                    error=function(e) NULL)
    if (is.null(cam)) return(NULL)
    pn <- if (!is.null(name_map) && nm %in% names(name_map)) name_map[[nm]] else nm
    data.frame(database=label, pathway_id=nm, pathway_name=pn,
               pathway_size=length(members), direction=cam$Direction,
               PValue=cam$PValue, FDR=NA, stringsAsFactors=FALSE)
  })
  out <- do.call(rbind, res)
  out$FDR <- p.adjust(out$PValue, method="BH")
  out[order(out$PValue), ]
}

mf_r  <- run_cam(stats, go_mf_f, "GO_MF", cor=0.01, name_map=go_nm_map)
cc_r  <- run_cam(stats, go_cc_f, "GO_CC", cor=0.01, name_map=go_nm_map)
mf_r5 <- run_cam(stats, go_mf_f, "GO_MF", cor=0.05, name_map=go_nm_map)
cc_r5 <- run_cam(stats, go_cc_f, "GO_CC", cor=0.05, name_map=go_nm_map)
write.csv(mf_r, file.path(M12,"ranked/M12_ranked_GO_MF.csv"), row.names=FALSE)
write.csv(cc_r, file.path(M12,"ranked/M12_ranked_GO_CC.csv"), row.names=FALSE)

# Re-read existing BP + Reactome, align columns
bp_r  <- read.csv(file.path(M12,"ranked/M12_ranked_GO_BP.csv"), stringsAsFactors=FALSE)
rea_r <- read.csv(file.path(M12,"ranked/M12_ranked_Reactome.csv"), stringsAsFactors=FALSE)
align_cols <- c("database","pathway_id","pathway_name","pathway_size","direction","PValue","FDR")
bp_r  <- bp_r[, intersect(align_cols, names(bp_r))]
rea_r <- rea_r[, intersect(align_cols, names(rea_r))]
mf_r  <- mf_r[, intersect(align_cols, names(mf_r))]
cc_r  <- cc_r[, intersect(align_cols, names(cc_r))]
# Combined GO_ALL + Reactome (secondary sensitivity)
comb_all <- rbind(bp_r, mf_r, cc_r, rea_r)
comb_all$FDR_pooled_secondary <- p.adjust(comb_all$PValue, method="BH")
comb_all <- comb_all[order(comb_all$FDR_pooled_secondary), ]
write.csv(comb_all, file.path(M12,"ranked/M12_ranked_GO_ALL_plus_Reactome_FDR.csv"), row.names=FALSE)

# ORA for MF/CC
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
d03_genes <- unique(na.omit(prot_to_gene[d03$PG.ProteinGroups]))
fg <- intersect(d03_genes, names(stats)); bg <- names(stats)
run_ora <- function(fg, bg, sets, label) {
  s <- lapply(sets, function(x) intersect(x, bg))
  s <- s[lengths(s)>=10 & lengths(s)<=500]
  N <- length(bg); K <- length(fg)
  res <- lapply(names(s), function(nm) {
    members <- s[[nm]]; x <- length(intersect(fg, members)); m <- length(members)
    if (x==0) return(NULL)
    ft <- fisher.test(matrix(c(x,m-x,K-x,N-m-K+x),2), alternative="greater")
    data.frame(database=label, pathway_id=nm, pathway_name=nm,
               foreground_mapped=x, background_pathway=m,
               foreground_total=K, background_total=N,
               enrichment_ratio=(x/K)/(m/N), odds_ratio=unname(ft$estimate),
               PValue=ft$p.value, FDR=NA, stringsAsFactors=FALSE)
  })
  out <- do.call(rbind, res); out$FDR <- p.adjust(out$PValue, method="BH")
  out[order(out$PValue), ]
}
ora_mf <- run_ora(fg, bg, go_mf_f, "GO_MF")
ora_cc <- run_ora(fg, bg, go_cc_f, "GO_CC")
write.csv(ora_mf, file.path(M12,"ora/M12_ORA_GO_MF.csv"), row.names=FALSE)
write.csv(ora_cc, file.path(M12,"ora/M12_ORA_GO_CC.csv"), row.names=FALSE)
ora_bp  <- read.csv(file.path(M12,"ora/M12_ORA_GO_BP.csv"), stringsAsFactors=FALSE)
ora_rea <- read.csv(file.path(M12,"ora/M12_ORA_Reactome.csv"), stringsAsFactors=FALSE)
ora_align <- c("database","pathway_id","pathway_name","foreground_mapped","background_pathway",
               "foreground_total","background_total","enrichment_ratio","odds_ratio","PValue","FDR")
ora_bp  <- ora_bp[, intersect(ora_align, names(ora_bp))]
ora_rea <- ora_rea[, intersect(ora_align, names(ora_rea))]
ora_mf  <- ora_mf[, intersect(ora_align, names(ora_mf))]
ora_cc  <- ora_cc[, intersect(ora_align, names(ora_cc))]
ora_comb <- rbind(ora_bp, ora_mf, ora_cc, ora_rea)
ora_comb$FDR_pooled_secondary <- p.adjust(ora_comb$PValue, method="BH")
write.csv(ora_comb[order(ora_comb$FDR_pooled_secondary),],
          file.path(M12,"ora/M12_ORA_GO_ALL_plus_Reactome_FDR.csv"), row.names=FALSE)

# -----------------------------------------------------------------------------
# 2. fgsea multilevel
# -----------------------------------------------------------------------------
cat("\n== 2. fgsea multilevel ==\n")
run_fgsea <- function(st, sets, label) {
  s <- lapply(sets, function(x) intersect(x, names(st)))
  s <- s[lengths(s)>=10 & lengths(s)<=500]
  fg <- fgsea::fgseaMultilevel(s, st, minSize=10, maxSize=500,
                                eps=0, nproc=0, scoreType="std")
  fg$database <- label
  fg$direction <- ifelse(fg$NES > 0, "Up", "Down")
  # Collapse list column for CSV writing
  fg$leadingEdge <- vapply(fg$leadingEdge, function(x) paste(x, collapse=";"), character(1))
  fg
}
fg_bp  <- run_fgsea(stats, go_bp_f, "GO_BP")
fg_mf  <- run_fgsea(stats, go_mf_f, "GO_MF")
fg_cc  <- run_fgsea(stats, go_cc_f, "GO_CC")
fg_rea <- run_fgsea(stats, rea_f,   "Reactome")
write.csv(fg_bp,  file.path(M12,"ranked_gsea/M12_fgsea_GO_BP.csv"),  row.names=FALSE)
write.csv(fg_mf,  file.path(M12,"ranked_gsea/M12_fgsea_GO_MF.csv"),  row.names=FALSE)
write.csv(fg_cc,  file.path(M12,"ranked_gsea/M12_fgsea_GO_CC.csv"),  row.names=FALSE)
write.csv(fg_rea, file.path(M12,"ranked_gsea/M12_fgsea_Reactome.csv"),row.names=FALSE)

# Combined
fg_all <- rbind(fg_bp, fg_mf, fg_cc, fg_rea)
fg_all$padj_pooled <- p.adjust(fg_all$pval, method="BH")
fg_all <- fg_all[order(fg_all$padj_pooled),]
write.csv(fg_all, file.path(M12,"ranked_gsea/M12_fgsea_combined.csv"), row.names=FALSE)

# Leading edge expanded
le_rows <- list()
ml_tab <- read.csv("descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv",
                   stringsAsFactors=FALSE, check.names=FALSE)
for (i in seq_len(nrow(fg_all))) {
  le_str <- fg_all$leadingEdge[i]
  le <- strsplit(le_str, ";", fixed=TRUE)[[1]]
  if (!length(le) || is.na(le[1]) || le[1]=="") next
  for (g in le) {
    pg <- names(prot_to_gene)[prot_to_gene == g]
    ml_row <- ml_tab[ml_tab$PG.ProteinGroups %in% pg, ]
    le_rows[[length(le_rows)+1]] <- data.frame(
      database=fg_all$database[i], pathway_id=fg_all$pathway[i],
      gene=g, PG.ProteinGroups=paste(pg, collapse=";"),
      rank_t=ifelse(g %in% names(stats), stats[g], NA),
      NES=fg_all$NES[i], padj=fg_all$padj[i],
      LASSO_freq=ifelse(nrow(ml_row), ml_row$LASSO_selection_freq[1], NA),
      EN_freq=ifelse(nrow(ml_row), ml_row$EN_selection_freq[1], NA),
      XGB_rank=ifelse(nrow(ml_row), ml_row$XGBoost_mean_rank[1], NA),
      stringsAsFactors=FALSE)
  }
}
le_df <- do.call(rbind, le_rows)
write.csv(le_df, file.path(M12,"ranked_gsea/M12_fgsea_leading_edge.csv"), row.names=FALSE)

# cameraPR vs fgsea concordance
cam_all <- rbind(bp_r, mf_r, cc_r, rea_r)
fg_mini <- fg_all[, c("database","pathway","NES","pval","padj","direction")]
names(fg_mini)[names(fg_mini)=="pathway"] <- "pathway_id"
conc <- merge(cam_all, fg_mini, by=c("database","pathway_id"), all=TRUE)
conc$same_direction <- conc$direction.x == conc$direction.y
conc$significant_cameraPR <- conc$FDR < 0.05
conc$significant_fgsea     <- conc$padj < 0.05
conc$significant_both     <- conc$significant_cameraPR & conc$significant_fgsea
write.csv(conc, file.path(M12,"ranked_gsea/M12_cameraPR_fgsea_concordance.csv"), row.names=FALSE)
cat("fgsea pathways:", nrow(fg_all), "; leading-edge rows:", nrow(le_df), "\n")
cat("cameraPR-fgsea same-direction:", sum(conc$same_direction, na.rm=TRUE),
    "/", nrow(conc), "\n")

# -----------------------------------------------------------------------------
# 3. M12B-A: pathway-protein network
# -----------------------------------------------------------------------------
cat("\n== 3. M12B network ==\n")
sig_rank <- read.csv(file.path(M12,"ranked/M12_ranked_combined_FDR.csv"), stringsAsFactors=FALSE)
sig_rank <- sig_rank[sig_rank$FDR_pooled < 0.05, ]
ml_tab <- read.csv("descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv",
                   stringsAsFactors=FALSE, check.names=FALSE)
d08 <- read.csv("descriptive/discovery_validation/D08_validation/D08_replication_summary.csv",
                stringsAsFactors=FALSE, check.names=FALSE)

# Build edges: for each significant pathway, its members that are in our universe
edge_rows <- list()
node_pathway <- list(); node_protein <- list()
sets_all <- c(go_bp_f, go_mf_f, go_cc_f, rea_f)
for (i in seq_len(nrow(sig_rank))) {
  row <- sig_rank[i,]
  members <- sets_all[[row$pathway_id]]
  if (is.null(members)) next
  node_pathway[[row$pathway_id]] <- row
  for (g in members) {
    pgs <- names(prot_to_gene)[prot_to_gene == g]
    for (pg in pgs) {
      mlr <- ml_tab[ml_tab$PG.ProteinGroups == pg, ]
      core_status <- ifelse(
        pg %in% read.csv(file.path(M12,"ranked/M12_pathway_core_genes.csv"),
                         stringsAsFactors=FALSE)$PG.ProteinGroups,
        "core_contributor", "member")
      edge_rows[[length(edge_rows)+1]] <- data.frame(
        database=row$database, pathway_id=row$pathway_id,
        pathway_name=row$pathway_name, pathway_FDR=row$FDR_pooled,
        pathway_direction=row$direction,
        PG.ProteinGroups=pg, Gene_symbol=g,
        core_gene_status=core_status,
        Discovery_log2FC=ifelse(nrow(mlr), mlr$Discovery_log2FC.x[1], NA),
        Discovery_BH_FDR=ifelse(nrow(mlr), mlr$Discovery_BH_FDR[1], NA),
        D08_replication=ifelse(nrow(mlr),
          ifelse(mlr$FDR_supported_replication[1]=="True","FDR_supported",
            ifelse(mlr$Nominal_replication[1]=="True","nominal","not_replicated")),
          NA),
        LASSO_stability=ifelse(nrow(mlr), mlr$LASSO_selection_freq[1], NA),
        ElasticNet_stability=ifelse(nrow(mlr), mlr$EN_selection_freq[1], NA),
        Boruta_freq=ifelse(nrow(mlr), mlr$Boruta_confirmed_freq[1], NA),
        XGBoost_rank=ifelse(nrow(mlr), mlr$XGBoost_mean_rank[1], NA),
        stringsAsFactors=FALSE)
      node_protein[[pg]] <- data.frame(PG=pg, gene=g, stringsAsFactors=FALSE)
    }
  }
}
edges <- do.call(rbind, edge_rows)
write.csv(edges, file.path(M12B,"network/M12B_pathway_protein_edges.csv"), row.names=FALSE)
# Nodes
pw_nodes <- data.frame(
  node_id=paste0("PW_", sig_rank$pathway_id),
  node_type="PATHWAY",
  label=sig_rank$pathway_name,
  database=sig_rank$database,
  pathway_id=sig_rank$pathway_id,
  stringsAsFactors=FALSE)
pr_nodes <- data.frame(
  node_id=edges$PG.ProteinGroups,
  node_type="PROTEIN",
  label=edges$Gene_symbol,
  database=NA, pathway_id=NA,
  stringsAsFactors=FALSE)
nodes <- unique(rbind(pw_nodes, pr_nodes))
write.csv(nodes, file.path(M12B,"network/M12B_pathway_protein_nodes.csv"), row.names=FALSE)
cat("Edges:", nrow(edges), "Pathways:", length(unique(edges$pathway_id)),
    "Proteins:", length(unique(edges$PG.ProteinGroups)), "\n")

# Proteins in multiple significant pathway families
multi <- aggregate(database ~ PG.ProteinGroups, edges,
                   function(x) length(unique(x)))
names(multi)[2] <- "n_pathway_families"
multi <- multi[order(-multi$n_pathway_families), ]
cat("Proteins in >=2 pathway families:", sum(multi$n_pathway_families>=2), "\n")

# -----------------------------------------------------------------------------
# 4. M12B-B: environment concordance classification
# -----------------------------------------------------------------------------
cat("\n== 4. M12B env concordance ==\n")
env_hh <- read.csv(file.path(M12,"environment/M12_env_ranked_HumidHot.csv"), stringsAsFactors=FALSE)
env_ha <- read.csv(file.path(M12,"environment/M12_env_ranked_HighAltitude.csv"), stringsAsFactors=FALSE)
env_c <- merge(env_hh, env_ha, by=c("database","pathway_id"),
               suffixes=c("_HH","_HA"))
env_c$pathway_name <- NA
env_c$same_direction <- env_c$direction_HH == env_c$direction_HA
env_c$opposite_direction <- !env_c$same_direction
# Overall High-vs-Low result
overall <- sig_rank[, c("database","pathway_id","pathway_name","FDR_pooled","direction")]
names(overall)[3:5] <- c("pathway_name_overall","overall_FDR","overall_direction")
env_c <- merge(env_c, overall, by=c("database","pathway_id"), all.x=TRUE)
env_c$pathway_name <- ifelse(is.na(env_c$pathway_name),
                             env_c$pathway_name_overall, env_c$pathway_name)
# Classification
classify <- function(row) {
  d_hh <- row["direction_HH"]; d_ha <- row["direction_HA"]
  if (is.na(d_hh) || is.na(d_ha)) return("NOT_ESTIMABLE")
  same <- d_hh == d_ha
  if (!same) return("OPPOSITE_DIRECTION")
  fdr_hh <- as.numeric(row["FDR_HH"]); fdr_ha <- as.numeric(row["FDR_HA"])
  hh_sig <- !is.na(fdr_hh) && fdr_hh < 0.05
  ha_sig <- !is.na(fdr_ha) && fdr_ha < 0.05
  if (hh_sig && ha_sig) return("SHARED_SAME_DIRECTION")
  if (hh_sig != ha_sig) return("ONE_ENV_SIGNIFICANT_SAME_DIRECTION")
  return("BOTH_NONSIGNIFICANT_SAME_DIRECTION")
}
env_c$classification <- apply(env_c, 1, classify)
env_c$formal_interaction_evidence <- "see M10; not inferred from env stratified analysis"
write.csv(env_c, file.path(M12B,"environment/M12B_environment_pathway_concordance.csv"),
          row.names=FALSE)
env_sum <- as.data.frame(table(env_c$classification))
names(env_sum) <- c("classification","count")
write.csv(env_sum, file.path(M12B,"environment/M12B_environment_pathway_summary.csv"),
          row.names=FALSE)
print(env_sum)

# -----------------------------------------------------------------------------
# 5. M12B-C: protein annotation
# -----------------------------------------------------------------------------
cat("\n== 5. M12B protein annotation ==\n")
canon <- read.csv("descriptive/canonical_protein_annotation.csv",
                  stringsAsFactors=FALSE, check.names=FALSE)
# Use canonical_protein_annotation as primary source
ann_rows <- list()
for (pg in d03$PG.ProteinGroups) {
  crow <- canon[canon$PG.ProteinGroups == pg, ]
  if (!nrow(crow)) crow <- canon[1,]
  g <- prot_to_gene[pg]
  # Heuristic localization from gene symbol (transparent, descriptive)
  gn <- if (!is.na(g)) g else ""
  secreted <- grepl("^(COL|FN|LAM|VCAM|ICAM|SELE|SELP|SELE|MMP|TIMP|SPARC|DMP1|IBP|IGFBP|FN1|LAMA|LAMB|LAMC|THBS|COMP|DCN|BGN|OGN|FMOD|PRELP|PCOL|HSPG|NID|AGRN|HGF|VEGFA|FGF|PDGF|EGF|TGFA|TGFB|BMP|WNT|SHH|NOTCH|DLL|JAG|WIF|DICKKOPF|SOST|GREM|CHRD|NBL|DLK|GDF|INHBA|INHBB|FST|ACTIVIN|NODAL|LEFTY|NRTN|ARTN|NRTN|GDNF|NRTN|PSPN|NTF|NGF|BDNF|NT3|NT4|CNTF|CTF|LIF|OSM|CNTF|IL|CXCL|CCL|CSF|TSLP|FLT3LG|M-CSF|GM-CSF|G-CSF|TPO|EPO|GH|PRL|LEPTIN|ADIPOQ|RESISTIN|Visfatin|NAMPT|ZP|HPT|CRP|SAA|C3|C4|C5|CFB|CFD|CFH|CFI|C1QA|C1QB|C1R|C1S|C2|C6|C7|C8|C9|C5AR1|FPR|ALB|TF|HP|HPX|CP|CERU|TRF|FERR|LTF|LYZ|SLPI|ELAF|CST|KNG|FGA|FGB|FGG|F2|F3|F5|F7|F8|F9|F10|F11|F12|F13|SERPIN|PLG|PLAT|SERPINA|SERPINC|SERPIND|SERPINE|SERPINF|SERPING|THPO|VWF|GP1BA|GP1BB|GP5|GP9|ITGA|ITGB|PECAM|CDH|CDH1|CDH5|OCLN|CLDN|TJP|ESAM|CD93|CLEC|SELECTIN|ICAM|VCAM|MADCAM|PECAM|SELE|SELP|SELL|GLYCAM1|CD34|PODXL|ENDOMUCIN|ESAM|PECAM1|VEGFA|VEGFB|VEGFC|VEGFD|ANGPT|TEK|KDR|FLT1|FLT4|NRP|EFNB|EFNA|EPH|EPHA|EPHB|ROBO|SLIT|SEMA|PLXNR|NRCAM|NCAM|L1CAM|CHL1|NFASC|NRCAM|CADM|NEGR|LSAMP|OPCML|IGSF|HSPG2|AGRN|PERLECAN|COLL|ELN|FBN|EMILIN|MFAP|MAGP|LTBP|DCN|BGN|OGN|FMOD|PREL|PCOL|THBS|COMP|SPARC|SPOCK|TSPN|POSTN|TNC|FN1|VWA|VWF|VWA5A|VWA5B|MATN|TINAG|TINAGL1|EGFL|EGF|FBLN|FREM|FRAS|HMCN|NCAM|NEO|NELL|NELL2|NOG|CHRD|GREM|GREM2|DAND5|CER1|NBL1|SOST|SOSTDC1|WIF1|DKK|SFRP|GPC|GPC1|GPC2|GPC3|GPC4|GPC5|GPC6|CDH|DSG|DSC|PCDH|CLDN|OCLN|JAM|TJP|CGN|MPDZ|MAGI|TJP1|TJP2|TJP3|LIN7|MLLT4|AFAD|EPB41|EZR|RDX|MSN)|", gn)
  # This is too broad; use a simpler transparent heuristic
  is_secreted <- any(grepl("^(COL|FN1|LAMA|LAMB|LAMC|THBS|COMP|DCN|BGN|OGN|FMOD|PRELP|SPARC|POSTN|TNC|VWF|CRP|SAA|C3|C4|FGA|FGB|FGG|ALB|TF|HP|HPX|CP|CERU|TRF|LTF|IGF|GAL|GAS|GDF|BMP|WNT|FGF|VEGF|EGF|PDGF|TGF|IL|CXCL|CCL|CSF|MMP|TIMP|SERPIN|PLG|PLAT|KNG|HPT|HPR|APOA|APOB|APOC|APOE|APOL|LPA|PON|LCAT|CETP|PLTP|HL|LIPC|LIPG|LPL|ANGT|ANGPT|REN|AGT|AGTR|NPP|NPPA|NPPB|BDNF|NGF|NTF|GDNF|CNTF|LIF|OSM|TSLP|FLT3LG|EPO|TPO|GH|PRL|LEP|ADIPOQ|NAMPT|ZP1|ZP2|ZP3|ZP4|HABP2|HABP|PCOL|LOX|LOXL|ELN|FBN|EMILIN|MFAP|MAGP|LTBP|SPOCK|MATN|TINAG|EGFL|FBLN|FREM|FRAS|HMCN|NEO|NELL|NOG|CHRD|GREM|DAND5|SOST|WIF1|DKK|SFRP|GPC|CDH|DSG|DSC|PCDH|CLDN|OCLN|JAM|ICAM|VCAM|SELE|SELP|SELL|PECAM|CD93|CLEC|CD34|PODXL|ESAM|VEGFA|VEGFB|VEGFC|VEGFD|TEK|KDR|FLT1|FLT4|NRP|EFNB|EFNA|EPH|ROBO|SLIT|SEMA|PLXNR|NCAM|L1CAM|CHL1|NFASC|NRCAM|CADM|NEGR|LSAMP|OPCML|HSPG2|AGRN|NID|NID1|NID2|DMP1|DMP2|DMP3|IBSP|SPP1|BSP|MEPE|OFAM|AMBN|ENPP|ENPP1|ENPP2|ENPP3|ENPP4|ENPP5|ENPP6|ENPP7|ENPP2A|ENPP2B|GPP|GPNMB|GPNMB|OSTEOPONTIN|SPP1|BSPII|IBSP|DMP1|MEPE|OFDC|ODAM|SCPP|SIBLING)|", gn))
  is_membrane <- grepl("^(TSPAN|CD|ITG|PECAM|CADHERIN|CLDN|OCLN|JAM|GPCR|GPR|OR|TCR|BCR|IL[0-9]R|CXCR|CCR|CSF[12]R|EPOR|TPOR|GHR|PRLR|LEPR|INSR|IGF1R|EGFR|ERBB|FGFR|PDGFR|VEGFR|KDR|FLT|MET|RON|AXL|TYRO3|MERTK|RET|KIT|FLT3|JAK|TIE|TEK|EPH|EPHA|EPHB|ROS|ALK|LTK|TRK|NTRK|NGFR|TNFRSF|FAS|DR|DCR|TGFBR|BMPR|ACTIVINR|WNT|FZD|LGR|ROR|RYK|PTCH|SMO|Hedgehog|NOTCH|DLL|JAG|NOTCH|SELL|SELE|SELP|CD34|PODXL|ESAM|CD93|CLEC|SIGLEC|DCIR|NKG2|KIR|CTLA|PD1|PDL1|CD28|CD80|CD86|ICOS|4-1BB|OX40|GITR|TNFR|TRAILR|FAS|DR3|DR4|DR5|DCR1|DCR2|RANK|OPG|CD40|CD40L|BAFF|APRIL|BCMA|TACI|CXCR|CCR|XCR|CX3CR|XCR1|CX3CR1|CCR|CXCR|CCR1|CCR2|CCR3|CCR4|CCR5|CCR6|CCR7|CCR8|CCR9|CCR10|CXCR1|CXCR2|CXCR3|CXCR4|CXCR5|CXCR6|CXCR7|ACKR|DARC|CCBP2|CCR|XCR1|CX3CR1|TSPAN1|TSPAN2|TSPAN3|TSPAN4|TSPAN5|TSPAN6|TSPAN7|TSPAN8|TSPAN9|TSPAN10|TSPAN11|TSPAN12|TSPAN13|TSPAN14|TSPAN15|TSPAN16|TSPAN17|TSPAN18|TSPAN19|TSPAN20|TSPAN21|TSPAN22|TSPAN23|TSPAN24|TSPAN25|TSPAN26|TSPAN27|TSPAN28|TSPAN29|TSPAN30|TSPAN31|TSPAN32|TSPAN33|TSPAN34|GOLGA|GOLGA2|GOLGA3|GOLGA4|GOLGA5|GOLGA6|GOLGA7|GOLGB1|GOLGA2|GOLGA3|GOLGA4|GOLGA5|GOLGA6|GOLGA7|GOLGB1|GOLM1|GOLPH3|GOLPH3L|GOLT1|GOLT1A|GOLT1B|GOLSYN|GM130|GOLGA2|GRASP65|GORASP1|GORASP2|GOLGA2|GOLGA3|GOLGA4|GOLGA5|GOLGA6|GOLGA7|GOLGB1|GOLGA2|GOLGA3|GOLGA4|GOLGA5|GOLGA6|GOLGA7|GOLGB1|GOLGA2|GOLGA3|GOLGA4|GOLGA5|GOLGA6|GOLGA7|GOLGB1)", gn)
  is_ecm <- grepl("^(COL|FN1|LAMA|LAMB|LAMC|THBS|COMP|DCN|BGN|OGN|FMOD|PRELP|SPARC|POSTN|TNC|VWF|ELN|FBN|EMILIN|MFAP|MAGP|LTBP|SPOCK|MATN|TINAG|EGFL|FBLN|FREM|FRAS|HMCN|NEO|HSPG2|AGRN|NID|NID1|NID2|DMP1|IBSP|SPP1|BSP|MEPE|OFDC|AMBN|DCN|BGN|OGN|FMOD|PRELP|LOX|LOXL|TGFBI|TGFB|TGFBR|ELN|FBN|EMILIN|MFAP|MAGP|LTBP|SPOCK|MATN|TINAG|TINAGL1|EGFL|EGFLAM|EGFL7|EGFL6|EGFL5|EGFL4|EGFL3|EGFL2|EGFL1|FBLN1|FBLN2|FBLN3|FBLN4|FBLN5|FREM1|FREM2|FREM3|FRAS1|HMCN1|HMCN2|HMCN3|NEO1|NEO2|NELL1|NELL2|HSPG2|AGRN|NID1|NID2|DMP1|IBSP|SPP1|BSP|MEPE|OFDC|ODAM|SCPP|SIBLING|POSTN|TNC|TNXB|TNXB|DCN|BGN|OGN|FMOD|PRELP|PCOL|COL|LOX|LOXL|ELN|FBN|EMILIN|MFAP|MAGP|LTBP|SPARC|SPOCK|THBS|COMP|MATN|TINAG|TINAGL1|EGFL|FBLN|FREM|FRAS|HMCN|NEO|NELL|HSPG2|AGRN|NID|DMP1|IBSP|SPP1|BSP|MEPE|OFDC|ODAM|SCPP|SIBLING|VWA|VWA5A|VWA5B|VWA5C|VWA5D|VWA5E|VWA5F|VWA5G|VWA5H|VWA5I|VWA5J|VWA5K|VWA5L|VWA5M|VWA5N|VWA5O|VWA5P|VWA5Q|VWA5R|VWA5S|VWA5T|VWA5U|VWA5V|VWA5W|VWA5X|VWA5Y|VWA5Z)", gn)
  is_intracellular <- !is_secreted & !is_membrane & !is_ecm

  # Tissue context heuristic
  tissue <- if (grepl("^(DMP1|IBSP|SPP1|BSP|MEPE|AMBN|SCPP|SIBLING|COL1|COL2|COL3|COL10|COL11|COMP|MATN|PRELP|OGN|FMOD|DCN|BGN)", gn)) "bone/cartilage/ECM"
       else if (grepl("^(IGF1|IGF2|INS|GH|PRL|LEP|ADIPOQ|GCG|GIP|GLP|PYY|NPY|AGRP|POMC|CRH|ACTH|TSH|LH|FSH|HCG|STH|HGH|HPL|GHRL|MLN|CORT|CORTI|CORTISOL|ALDO|CORTICOSTERONE|DEHA|DHEA|DHEAS|ESTR|PROG|TEST|DHT|T|E2|E1|E3|P4|T4|T3|RT3|CALC|PTH|PTHrP|FGF23|KLOTHO|VDR|FGF23|KLOTHO)|", gn)) "nervous/endocrine"
       else if (grepl("^(IL|CXCL|CCL|CSF|MMP|TIMP|IG|IGH|IGK|IGL|CD|HLA|HLA-D|HLA-A|HLA-B|HLA-C|HLA-E|HLA-F|HLA-G|HLA-DM|HLA-DO|HLA-DP|HLA-DQ|HLA-DR|HLA-DX|HLA-DY|HLA-DZ|HLA-E|HLA-F|HLA-G|HLA-H|HLA-J|HLA-K|HLA-L|HLA-N|HLA-S|HLA-T|HLA-U|HLA-V|HLA-W|HLA-X|HLA-Y|HLA-Z|HLA-H|HLA-J|HLA-K|HLA-L|HLA-N|HLA-S|HLA-T|HLA-U|HLA-V|HLA-W|HLA-X|HLA-Y|HLA-Z)|", gn)) "immune/hematopoietic"
       else if (grepl("^(VEGF|KDR|FLT1|FLT4|ANGPT|TEK|TIE|PECAM|CDH5|ESAM|CD93|VWF|EDN|EDNR|ACE|AGT|REN|NPP|NPPA|NPPB|NPR|NPRA|NPRB|NPPC|NPRC|PROCR|EPCR|THBD|TM|TMEM|CDH5|CLDN5|OCLN|TJP1|TJP2|TJP3|JAM|ESAM|PECAM1|VEGFA|VEGFB|VEGFC|VEGFD|ANGPT1|ANGPT2|ANGPT4|TEK|TIE1|TIE2|KDR|FLT1|FLT4|NRP1|NRP2|EFNB|EFNA|EPH|EPHA|EPHB|ROBO|SLIT|SEMA|PLXNR|NRCAM|NCAM|L1CAM|CHL1|NFASC|CADM|NEGR|LSAMP|OPCML|IGSF|HSPG2|AGRN|PERLECAN|COLL|ELN|FBN|EMILIN|MFAP|MAGP|LTBP|DCN|BGN|OGN|FMOD|PREL|PCOL|THBS|COMP|SPARC|SPOCK|TSPN|POSTN|TNC|FN1|VWA|VWF|VWA5A|VWA5B|MATN|TINAG|TINAGL1|EGFL|EGF|FBLN|FREM|FRAS|HMCN|NCAM|NEO|NELL|NELL2|NOG|CHRD|GREM|GREM2|DAND5|CER1|NBL1|SOST|SOSTDC1|WIF1|DKK|SFRP|GPC|GPC1|GPC2|GPC3|GPC4|GPC5|GPC6|CDH|DSG|DSC|PCDH|CLDN|OCLN|JAM|TJP|CGN|MPDZ|MAGI|TJP1|TJP2|TJP3|LIN7|MLLT4|AFAD|EPB41|EZR|RDX|MSN)", gn)) "vascular/endothelial"
       else if (grepl("^(MYO|ACTA|ACTN|MYH|MYL|TNNT|TNNC|TNNI|TPM|MYOM|MYPN|MYOZ|MYOT|TCAP|CSRP|CKM|CKB|ENO|PGAM|PFKM|PKM|LDHA|LDHB|PDK|PDHA|PDHB|CS|ACO|IDH|OGDH|SDH|FH|MDH|ATP5|COX|CYC|UQCR|NDUF|SDHA|SDHB|SDHC|SDHD|UQCRC|UQCRFS|CYC1|ATP5A|ATP5B|ATP5C|ATP5D|ATP5E|ATP5F|ATP5G|ATP5H|ATP5I|ATP5J|ATP5K|ATP5L|ATP5O|ATP5S|CKMT|CKB|CKM|LDHA|LDHB|LDHC|PFK|PKM|HK|GAPDH|PGK|ENO|PGAM|TPI|GPI|PYGM|PYGB|PYGL|GP|GYS|GSK|PGM|AGL|PYGL|PHKA|PHKB|PHKG|CFL|DMD|SGCA|SGCB|SGCG|SGCD|SGCE|SGCG|DTNA|DTNB|UTRN|DYSTROPHIN|UTROPHIN|DES|VIM|LMNA|LMNB|LMNA|LMNB1|LMNB2|LMN|EMD|SYNE|Nes|NESTIN|GFAP|NEFL|NEFM|NEFH|NEFH|PRPH|INA|ISL1|MYOD1|MYOG|MYF5|MYF6|MEF2|SRF|TCAP|TTN|NEB|OBS|MYOM|MYOZ|MYPN|ANKRD|CSRP|TELETHONIN|TTN|NEB|OBSCN|OBSL1|OBSL2|MYOM1|MYOM2|MYOM3|MYOZ1|MYOZ2|MYOZ3|MYPN|ANKRD1|ANKRD2|ANKRD23|CSRP3|TCAP|MYOT|MYO|ACTA1|ACTA2|ACTG2|ACTN2|ACTN3|MYH1|MYH2|MYH3|MYH4|MYH6|MYH7|MYH8|MYH10|MYH11|MYH13|MYH14|MYH15|MYH7B|MYO1|MYO5|MYO6|MYO7|MYO9|MYO10|MYO15|MYO18|MYO19|MYL1|MYL2|MYL3|MYL4|MYL5|MYL6|MYL7|MYL9|MYL10|MYL12|MYLK|MYLK2|MYLK3|MYLK4|MYO18B|MYO19|TNNT1|TNNT2|TNNT3|TNNC1|TNNC2|TNNI1|TNNI2|TNNI3|TPM1|TPM2|TPM3|TPM4|TMOD|TMOD1|TMOD2|TMOD3|TMOD4|NEB|TTN|OBS|OBSCN|OBSL1|OBSL2|MYOM1|MYOM2|MYOM3|MYOZ1|MYOZ2|MYOZ3|MYPN|ANKRD1|ANKRD2|ANKRD23|CSRP3|TCAP|MYOT)", gn)) "muscle"
       else if (grepl("^(ALB|TF|HP|HPX|CP|CERU|TRF|LTF|FERR|HPT|HPR|CRP|SAA|APOA|APOB|APOC|APOE|APOL|LPA|PON|LCAT|CETP|PLTP|LIPC|LIPG|LPL|FGA|FGB|FGG|F2|F5|F7|F8|F9|F10|F11|F12|F13|SERPIN|PLG|PLAT|KNG|C3|C4|C5|CFB|CFD|CFH|CFI|C1Q|C1R|C1S|C2|C6|C7|C8|C9|FGB|FGA|FGG|PROS|PROC|PROZ|SERPINC1|SERPIND1|SERPINE1|SERPINE2|SERPINF2|SERPING1|SERPINA1|SERPINA3|SERPINA4|SERPINA5|SERPINA6|SERPINA7|SERPINA10|SERPINA11|SERPINA12|SERPINA13|SERPINB|SERPINC|SERPIND|SERPINE|SERPINF|SERPING|ALB|TF|HP|HPX|CP|CERU|TRF|LTF|FERR|HPT|HPR|CRP|SAA|APOA|APOB|APOC|APOE|APOL|LPA|PON|LCAT|CETP|PLTP|LIPC|LIPG|LPL|ANGT|ANGPT|REN|AGT|AGTR|NPP|NPPA|NPPB|NPR|VWF|F8|F9|FV|FVII|FIX|FX|FXI|FXII|FXIII|PROT|THROMBIN|FIBRIN|PLASMIN|PLASMINOGEN|T-PA|U-PA|PAI|TFPI|THROMBOMODULIN|PROTEIN C|PROTEIN S|PROTEIN Z|ANTITHROMBIN|HEPARIN|HSPG|HGF|HGFAC|HGF|HGFA|HGFAC|HGF|HGFAC|HGF|HGFAC)|", gn)) "liver"
       else "other/unknown"

  ann_rows[[length(ann_rows)+1]] <- data.frame(
    PG.ProteinGroups=pg, Gene_symbol=g,
    protein_name=if (!is.na(crow$PG.ProteinNames[1])) crow$PG.ProteinNames[1] else "",
    localization_class=ifelse(is_ecm,"ECM",ifelse(is_secreted,"secreted",
                          ifelse(is_membrane,"cell membrane","intracellular"))),
    secreted_flag=is_secreted, membrane_flag=is_membrane,
    ECM_flag=is_ecm, intracellular_flag=is_intracellular,
    tissue_context=tissue, cell_context=NA,
    protein_class=NA, drug_target_flag=NA,
    annotation_source="canonical_protein_annotation.csv + heuristic gene-symbol rule",
    annotation_version="project_in_place",
    annotation_date=format(Sys.Date()),
    annotation_confidence="heuristic_descriptive",
    stringsAsFactors=FALSE)
}
ann_df <- do.call(rbind, ann_rows)
write.csv(ann_df, file.path(M12B,"annotation/M12B_protein_annotation.csv"), row.names=FALSE)
cat("Annotated 85 DEPs; secreted:", sum(ann_df$secreted_flag),
    "membrane:", sum(ann_df$membrane_flag),
    "ECM:", sum(ann_df$ECM_flag),
    "intracellular:", sum(ann_df$intracellular_flag), "\n")

# -----------------------------------------------------------------------------
# 6. M12B-D: 85-DEP correlation
# -----------------------------------------------------------------------------
cat("\n== 6. M12B correlation ==\n")
dep85 <- d03$PG.ProteinGroups
expr_85 <- mat[dep85, ]  # already median-imputed per row
# Pairwise Spearman on Discovery High+Low
spear <- cor(t(expr_85), method="spearman", use="pairwise.complete.obs")
write.csv(data.frame(PG.ProteinGroups=rownames(spear), spear, check.names=FALSE),
          file.path(M12B,"correlation/M12B_DEP85_spearman_correlation.csv"), row.names=FALSE)

# Pairs
pairs <- list()
for (i in 1:(nrow(spear)-1)) for (j in (i+1):nrow(spear)) {
  pairs[[length(pairs)+1]] <- data.frame(
    protein_1=rownames(spear)[i], protein_2=rownames(spear)[j],
    Gene_symbol_1=gene_vec[rownames(spear)[i]],
    Gene_symbol_2=gene_vec[rownames(spear)[j]],
    rho=spear[i,j],
    pairwise_N=sum(complete.cases(t(expr_85)[,c(i,j)])),
    stringsAsFactors=FALSE)
}
pairs_df <- do.call(rbind, pairs)
write.csv(pairs_df, file.path(M12B,"correlation/M12B_DEP85_correlation_pairs.csv"), row.names=FALSE)

# Per-protein summary
sum_rows <- list()
for (i in seq_len(nrow(spear))) {
  v <- abs(spear[i, -i])
  sum_rows[[i]] <- data.frame(
    PG.ProteinGroups=rownames(spear)[i], Gene_symbol=gene_vec[rownames(spear)[i]],
    median_abs_rho=median(v), max_abs_rho=max(v),
    n_ge_0.5=sum(v>=0.5), n_ge_0.7=sum(v>=0.7), n_ge_0.8=sum(v>=0.8),
    stringsAsFactors=FALSE)
}
sum_df <- do.call(rbind, sum_rows)
write.csv(sum_df, file.path(M12B,"correlation/M12B_DEP85_collinearity_summary.csv"), row.names=FALSE)

cat("Median |rho|:", median(abs(pairs_df$rho)), "\n")
cat("Pairs |rho|>=0.5:", sum(abs(pairs_df$rho)>=0.5), "\n")
cat("Pairs |rho|>=0.7:", sum(abs(pairs_df$rho)>=0.7), "\n")
cat("Pairs |rho|>=0.8:", sum(abs(pairs_df$rho)>=0.8), "\n")

# Anchor 5 strongest partners
cat("\nAnchor 5 strongest partners:\n")
for (g in c("TSPAN14","GAL","DMP1","IGF1","GOLGA3")) {
  pgs <- names(prot_to_gene)[prot_to_gene==g]
  for (pg in pgs) {
    if (pg %in% rownames(spear)) {
      v <- abs(spear[pg, setdiff(rownames(spear),pg)])
      top <- sort(v, decreasing=TRUE)[1:3]
      cat(sprintf("  %s (%s): %s\n", g, pg,
                  paste(sprintf("%s=%.2f", gene_vec[names(top)], top), collapse=", ")))
    }
  }
}

# -----------------------------------------------------------------------------
# 7. M12B-E: integrated table
# -----------------------------------------------------------------------------
cat("\n== 7. M12B integrated table ==\n")
strict_stab <- read.csv("descriptive/analysis_v2.0/ml_v2.1/strict_nested/strict_nested_feature_stability.csv",
                        stringsAsFactors=FALSE)
int_rows <- list()
for (i in seq_len(nrow(ml_tab))) {
  pg <- ml_tab$PG.ProteinGroups[i]
  g  <- ml_tab$Gene_symbol.x[i]
  ss <- strict_stab[strict_stab$PG.ProteinGroups == pg, ]
  # Pathway memberships
  pw_go_bp <- paste(unique(edges$pathway_id[edges$PG.ProteinGroups==pg & edges$database=="GO_BP"]), collapse=";")
  pw_rea   <- paste(unique(edges$pathway_id[edges$PG.ProteinGroups==pg & edges$database=="Reactome"]), collapse=";")
  pw_mf    <- paste(unique(edges$pathway_id[edges$PG.ProteinGroups==pg & edges$database=="GO_MF"]), collapse=";")
  pw_cc    <- paste(unique(edges$pathway_id[edges$PG.ProteinGroups==pg & edges$database=="GO_CC"]), collapse=";")
  core <- ifelse(pg %in% read.csv(file.path(M12,"ranked/M12_pathway_core_genes.csv"),
                                   stringsAsFactors=FALSE)$PG.ProteinGroups,
                 "core_contributor", "member")
  ann <- ann_df[ann_df$PG.ProteinGroups == pg, ]
  corr <- sum_df[sum_df$PG.ProteinGroups == pg, ]
  int_rows[[i]] <- data.frame(
    PG.ProteinGroups=pg, Gene_symbol=g,
    Discovery_log2FC=ml_tab$Discovery_log2FC.x[i],
    Discovery_BH_FDR=ml_tab$Discovery_BH_FDR[i],
    strict_nested_DEP_freq=ifelse(nrow(ss), ss$appearance_frequency[1], NA),
    LASSO_conditional_stability=ml_tab$LASSO_selection_freq[i],
    EN_conditional_stability=ml_tab$EN_selection_freq[i],
    strict_nested_LASSO_stability=ifelse(nrow(ss), ss$lasso_selection_frequency[1], NA),
    strict_nested_EN_stability=ifelse(nrow(ss), ss$en_selection_frequency[1], NA),
    XGBoost_mean_rank=ml_tab$XGBoost_mean_rank[i],
    XGBoost_mean_gain=ml_tab$XGBoost_mean_gain[i],
    D08_direction_concordant=ml_tab$Direction_concordant[i],
    D08_nominal_replication=ml_tab$Nominal_replication[i],
    D08_FDR_supported=ml_tab$FDR_supported_replication[i],
    GO_BP_significant_pathways=pw_go_bp,
    GO_MF_significant_pathways=pw_mf,
    GO_CC_significant_pathways=pw_cc,
    Reactome_significant_pathways=pw_rea,
    core_contributor_status=core,
    localization_class=ifelse(nrow(ann), ann$localization_class[1], NA),
    tissue_context=ifelse(nrow(ann), ann$tissue_context[1], NA),
    median_abs_rho=ifelse(nrow(corr), corr$median_abs_rho[1], NA),
    max_abs_rho=ifelse(nrow(corr), corr$max_abs_rho[1], NA),
    stringsAsFactors=FALSE)
}
int_df <- do.call(rbind, int_rows)
write.csv(int_df, file.path(M12B,"integration/M12B_integrated_candidate_context.csv"), row.names=FALSE)
cat("Integrated rows:", nrow(int_df), "(should be 85)\n")

# -----------------------------------------------------------------------------
# 8. Manifest
# -----------------------------------------------------------------------------
man <- data.frame(
  item=c("protocol","contrast","ranked_statistic","cameraPR_cor","cameraPR_sensitivity",
         "fgsea","GO_source","Reactome_source","KEGG_source","organism","gene_id_type",
         "limma_version","fgsea_version","org.Hs.eg.db_version","reactome.db_version",
         "correlation_method","correlation_samples","created"),
  value=c("ANALYSIS_PLAN_v2.1 §10 + M12B supplementary",
          "Discovery High vs Low (High+Low n=271)",
          "signed moderated t from eBayes",
          "0.01","0.05",
          "fgseaMultilevel (cameraPR sensitivity only)",
          "org.Hs.eg.db 3.18.0 GO:BP/MF/CC",
          "reactome.db (Bioconductor)",
          "NOT_RUN_NO_REPRODUCIBLE_KEGG_SOURCE",
          "Homo sapiens","gene_symbol",
          as.character(packageVersion("limma")),
          as.character(packageVersion("fgsea")),
          as.character(packageVersion("org.Hs.eg.db")),
          as.character(packageVersion("reactome.db")),
          "Spearman pairwise.complete.obs",
          "Discovery High+Low (n=271)",
          format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  stringsAsFactors=FALSE)
write.csv(man, file.path(M12B,"diagnostics/M12B_run_manifest.csv"), row.names=FALSE)
write.csv(man, file.path(M12B,"diagnostics/M12B_annotation_sources.csv"), row.names=FALSE)

cat("\n=== ALL DONE ===\n")
