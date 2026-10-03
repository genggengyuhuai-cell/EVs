# =============================================================================
# M12_03_integration.R — Core genes, env stratified, redundancy, ML integration
# =============================================================================
suppressPackageStartupMessages({
  library(limma)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
MAP_DIR <- file.path(M12, "mapping")
RANK_DIR <- file.path(M12, "ranked")
ORA_DIR  <- file.path(M12, "ora")
ENV_DIR  <- file.path(M12, "environment")
INT_DIR  <- file.path(M12, "integration")
DIAG_DIR <- file.path(M12, "diagnostics")
dir.create(ENV_DIR, recursive=TRUE, showWarnings=FALSE)
dir.create(INT_DIR, recursive=TRUE, showWarnings=FALSE)
dir.create(DIAG_DIR, recursive=TRUE, showWarnings=FALSE)

set.seed(20260928)

# Reload stats
contract <- read.csv(file.path(MAP_DIR, "M12_gene_mapping_contract.csv"),
                     stringsAsFactors=FALSE, check.names=FALSE)
reps <- contract[contract$representative_status %in% c("REPRESENTATIVE","SINGLE") &
                 contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", ]
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names=1, check.names=FALSE)
meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors=FALSE)
disc <- meta[meta$Split == "Discovery" & meta$TREAT1_clean %in% c("high","low"), ]
common_samps <- intersect(disc$UniqueSampleID, colnames(expr))
disc <- disc[match(common_samps, disc$UniqueSampleID), ]
use_prots <- intersect(reps$PG.ProteinGroups, rownames(expr))
expr_use <- expr[use_prots, disc$UniqueSampleID]
prot_to_gene <- setNames(reps$Gene_symbol, reps$PG.ProteinGroups)
gene_vec <- prot_to_gene[rownames(expr_use)]

group <- factor(disc$TREAT1_clean, levels=c("low","high"))
design <- model.matrix(~ group); colnames(design) <- c("Intercept","High_vs_Low")
mat <- as.matrix(expr_use)
for (i in seq_len(nrow(mat))) {
  rmed <- median(mat[i,], na.rm=TRUE); mat[i, is.na(mat[i,])] <- rmed
}
fit <- eBayes(lmFit(mat, design))
tt <- topTable(fit, coef="High_vs_Low", number=Inf, sort.by="none")
tt$Gene_symbol <- gene_vec[rownames(tt)]
stats <- setNames(tt$t, tt$Gene_symbol)
stats <- sort(stats, decreasing=TRUE)

# Reload combined ranked results
ranked <- read.csv(file.path(RANK_DIR, "M12_ranked_combined_FDR.csv"), stringsAsFactors=FALSE)
ora <- read.csv(file.path(ORA_DIR, "M12_ORA_combined_FDR.csv"), stringsAsFactors=FALSE)

# Reload gene sets (GO BP)
go_map <- AnnotationDbi::select(org.Hs.eg.db,
    keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
    columns=c("GO","ONTOLOGY","SYMBOL"), keytype="ENTREZID")
go_map <- go_map[go_map$ONTOLOGY=="BP" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_terms <- split(go_map$SYMBOL, go_map$GO)
go_terms <- lapply(go_terms, unique)

# Reactome
library(reactome.db)
rea_map <- AnnotationDbi::select(reactome.db,
    keys=keys(reactome.db, keytype="ENTREZID"),
    columns=c("REACTOMEID"), keytype="ENTREZID")
e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=rea_map$ENTREZID,
                             columns="SYMBOL", keytype="ENTREZID")
rea_map$SYMBOL <- e2s$SYMBOL[match(rea_map$ENTREZID, e2s$ENTREZID)]
rea_map <- rea_map[!is.na(rea_map$SYMBOL), ]
rea_sets <- split(rea_map$SYMBOL, rea_map$REACTOMEID)
rea_sets <- lapply(rea_sets, unique)

# -----------------------------------------------------------------------------
# A. Core contributing genes for significant ranked pathways
# -----------------------------------------------------------------------------
cat("== A. Core contributing genes ==\n")
sig_rank <- ranked[ranked$FDR_pooled < 0.05, ]
core_rows <- list()
for (i in seq_len(nrow(sig_rank))) {
  row <- sig_rank[i, ]
  sets <- if (row$database=="GO_BP") go_terms else rea_sets
  members <- intersect(sets[[row$pathway_id]], names(stats))
  if (!length(members)) next
  # Core = top quartile of pathway members by |t|
  member_stats <- stats[members]
  thr <- quantile(abs(member_stats), 0.75, na.rm=TRUE)
  is_core <- abs(member_stats) >= thr
  for (g in names(member_stats)[is_core]) {
    # Find PG.ProteinGroups
    pg <- names(prot_to_gene)[prot_to_gene == g]
    core_rows[[length(core_rows)+1]] <- data.frame(
      database=row$database, pathway_id=row$pathway_id,
      pathway_name=row$pathway_name, pathway_direction=row$direction,
      gene=g, PG.ProteinGroups=paste(pg, collapse=";"),
      rank_statistic=member_stats[g],
      contribution_core_status="top_quartile_by_abs_t",
      method_used_to_define_core="cameraPR_without_native_leading_edge__top_quartile",
      stringsAsFactors=FALSE)
  }
}
core_df <- do.call(rbind, core_rows)
write.csv(core_df, file.path(RANK_DIR, "M12_pathway_core_genes.csv"), row.names=FALSE)
cat("Core-gene rows:", nrow(core_df), "\n")

# -----------------------------------------------------------------------------
# B. Environment-stratified sensitivity
# -----------------------------------------------------------------------------
cat("\n== B. Environment-stratified ==\n")
disc$Environment <- sub(" / .*$", "", disc$Stratum)
cat("Environments:", paste(unique(disc$Environment), collapse=", "), "\n")

run_env <- function(env_name) {
  sub <- disc[disc$Environment == env_name & disc$TREAT1_clean %in% c("high","low"), ]
  cat("  ", env_name, "n=", nrow(sub), "\n")
  if (nrow(sub) < 30) return(NULL)
  Xsub <- mat[, match(sub$UniqueSampleID, colnames(mat)), drop=FALSE]
  g <- factor(sub$TREAT1_clean, levels=c("low","high"))
  d <- model.matrix(~ g); colnames(d) <- c("Intercept","High_vs_Low")
  f <- tryCatch(eBayes(lmFit(Xsub, d)), error=function(e) NULL)
  if (is.null(f)) return(NULL)
  tt_e <- topTable(f, coef="High_vs_Low", number=Inf, sort.by="none")
  tt_e$Gene_symbol <- gene_vec[rownames(tt_e)]
  s <- sort(setNames(tt_e$t, tt_e$Gene_symbol), decreasing=TRUE)
  # Quick cameraPR on GO BP + Reactome
  run_cam <- function(st, sets, label) {
    bg <- names(st)
    sets_f <- lapply(sets, function(x) intersect(x, bg))
    keep <- lengths(sets_f) >= 10 & lengths(sets_f) <= 500
    sets_f <- sets_f[keep]
    rs <- lapply(names(sets_f), function(nm) {
      members <- sets_f[[nm]]
      idx <- which(names(st) %in% members)
      cam <- tryCatch(cameraPR(st, index=idx, use.ranks=FALSE, inter.gene.cor=0.01),
                      error=function(e) NULL)
      if (is.null(cam)) return(NULL)
      data.frame(database=label, pathway_id=nm, direction=cam$Direction,
                 PValue=cam$PValue, stringsAsFactors=FALSE)
    })
    do.call(rbind, rs)
  }
  r_go  <- run_cam(s, go_terms, "GO_BP")
  r_rea <- run_cam(s, rea_sets, "Reactome")
  out <- rbind(r_go, r_rea)
  out$FDR <- p.adjust(out$PValue, method="BH")
  out[order(out$PValue), ]
}

env_1 <- run_env("Humid-hot")
env_2 <- run_env("High-pressure/high-altitude")
write.csv(env_1, file.path(ENV_DIR, "M12_env_ranked_HumidHot.csv"), row.names=FALSE)
write.csv(env_2, file.path(ENV_DIR, "M12_env_ranked_HighAltitude.csv"), row.names=FALSE)

# Concordance
if (!is.null(env_1) && !is.null(env_2)) {
  concord <- merge(env_1, env_2, by=c("database","pathway_id"), suffixes=c("_HH","_HA"))
  concord$same_direction <- concord$direction_HH == concord$direction_HA
  concord$formal_interaction_evidence <- "see M10; not inferred from significance differences"
  write.csv(concord, file.path(ENV_DIR, "M12_env_pathway_concordance.csv"), row.names=FALSE)
  cat("Concordant directions:", sum(concord$same_direction, na.rm=TRUE),
      "/", nrow(concord), "\n")
}

# -----------------------------------------------------------------------------
# C. ML candidate pathway membership
# -----------------------------------------------------------------------------
cat("\n== C. ML candidate pathway membership ==\n")
ml_tab <- read.csv("descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv",
                   stringsAsFactors=FALSE, check.names=FALSE)
anchor_genes <- c("GOLGA3","TSPAN14","GAL","DMP1","IGF1")

ml_rows <- list()
for (i in seq_len(nrow(ml_tab))) {
  gene <- ml_tab$Gene_symbol.x[i]
  pg <- ml_tab$PG.ProteinGroups[i]
  # Which ML branches selected this?
  branches <- c()
  if (!is.na(ml_tab$LASSO_selection_freq[i]) && ml_tab$LASSO_selection_freq[i] >= 0.5)
    branches <- c(branches, "LASSO")
  if (!is.na(ml_tab$EN_selection_freq[i]) && ml_tab$EN_selection_freq[i] >= 0.5)
    branches <- c(branches, "ElasticNet")
  if (!is.na(ml_tab$XGBoost_mean_rank[i]) && ml_tab$XGBoost_mean_rank[i] <= 20)
    branches <- c(branches, "XGBoost_top20")
  if (!length(branches)) next
  # Which significant pathways contain this gene?
  for (db in c("GO_BP","Reactome")) {
    sets <- if (db=="GO_BP") go_terms else rea_sets
    sig_p <- sig_rank[sig_rank$database==db, ]
    for (j in seq_len(nrow(sig_p))) {
      pname <- sig_p$pathway_id[j]
      members_p <- sets[[pname]]
      if (is.null(members_p)) members_p <- character(0)
      if (gene %in% members_p) {
        ml_rows[[length(ml_rows)+1]] <- data.frame(
          PG.ProteinGroups=pg, Gene_symbol=gene,
          ML_branch=paste(branches, collapse=";"),
          ML_stability=paste("LASSO=", round(ml_tab$LASSO_selection_freq[i],2),
                             " EN=", round(ml_tab$EN_selection_freq[i],2),
                             " XGB_rank=", round(ml_tab$XGBoost_mean_rank[i],1), sep=""),
          pathway_database=db, pathway_id=pname,
          pathway_name=sig_p$pathway_name[j],
          ranked_pathway_FDR=sig_p$FDR_pooled[j],
          ora_pathway_FDR=NA,
          core_status=ifelse(gene %in% core_df$gene, "core_contributor", "member"),
          D08_replication=ifelse(ml_tab$Nominal_replication[i]=="True", "nominal", "not_nominal"),
          stringsAsFactors=FALSE)
      }
    }
  }
}
ml_path <- do.call(rbind, ml_rows)
write.csv(ml_path, file.path(INT_DIR, "M12_ML_candidate_pathway_membership.csv"), row.names=FALSE)
cat("ML-pathway rows:", nrow(ml_path), "\n")

# Check anchors
cat("\nAnchor 5 in significant pathway cores:\n")
for (g in anchor_genes) {
  in_core <- g %in% core_df$gene
  in_rank <- any(ml_path$Gene_symbol == g)
  cat(sprintf("  %s: in_core=%s, in_ML_pathway_table=%s\n", g, in_core, in_rank))
}

# -----------------------------------------------------------------------------
# D. Pathway redundancy reduction (simple: cluster by gene overlap)
# -----------------------------------------------------------------------------
cat("\n== D. Redundancy clusters ==\n")
sig_for_red <- sig_rank[sig_rank$database=="Reactome", ]  # Reactome is most redundant
# Jaccard overlap between pathways
sets_rea <- lapply(rea_sets[sig_for_red$pathway_id], function(s) intersect(s, names(stats)))
n <- length(sets_rea)
if (n > 1) {
  # Simple greedy clustering by Jaccard > 0.5
  sim <- matrix(0, n, n, dimnames=list(names(sets_rea), names(sets_rea)))
  for (i in 1:(n-1)) for (j in (i+1):n) {
    inter <- length(intersect(sets_rea[[i]], sets_rea[[j]]))
    uni   <- length(union(sets_rea[[i]], sets_rea[[j]]))
    sim[i,j] <- sim[j,i] <- inter/uni
  }
  cluster <- rep(NA, n); cid <- 0
  for (i in 1:n) {
    if (is.na(cluster[i])) {
      cid <- cid + 1
      cluster[i] <- cid
      # Greedy: attach neighbors with jaccard > 0.5
      for (j in 1:n) if (is.na(cluster[j]) && sim[i,j] > 0.5) cluster[j] <- cid
    }
  }
  # Representative = smallest FDR, then size, then lexical
  rep_rows <- list()
  for (c in unique(cluster)) {
    members <- which(cluster == c)
    sub <- sig_for_red[members, ]
    sub$cluster <- c
    sub$rep <- ifelse(sub$FDR_pooled == min(sub$FDR_pooled) &
                      sub$pathway_size == min(sub$pathway_size[sub$FDR_pooled==min(sub$FDR_pooled)]),
                      "REPRESENTATIVE", "redundant_member")
    rep_rows[[length(rep_rows)+1]] <- sub[, c("database","pathway_id","pathway_name","FDR_pooled","pathway_size","cluster","rep")]
  }
  red <- do.call(rbind, rep_rows)
  names(red)[names(red)=="rep"] <- "representative_theme"
  red$similarity_measure <- "Jaccard>0.5"
  write.csv(red, file.path(INT_DIR, "M12_pathway_redundancy_clusters.csv"), row.names=FALSE)
  cat("Redundancy clusters:", length(unique(red$cluster)), "\n")
}

# -----------------------------------------------------------------------------
# E. Manifest + DB versions
# -----------------------------------------------------------------------------
cat("\n== E. Manifest ==\n")
manifest <- data.frame(
  item=c("protocol","contrast","ranked_statistic","cameraPR_cor","cameraPR_sensitivity_cor",
         "GO_source","Reactome_source","KEGG_source","organism","gene_id_type",
         "limma_version","fgsea_version","clusterProfiler_version","org.Hs.eg.db_version",
         "reactome.db_version","created"),
  value=c("ANALYSIS_PLAN_v2.1 §10",
          "Discovery High vs Low",
          "signed moderated t from eBayes",
          "0.01", "0.05",
          "org.Hs.eg.db 3.18.0 GO:BP",
          "reactome.db (Bioconductor)",
          "NOT_RUN_NO_REPRODUCIBLE_KEGG_SOURCE (KEGG REST returned incomplete)",
          "Homo sapiens",
          "gene_symbol",
          as.character(packageVersion("limma")),
          as.character(packageVersion("fgsea")),
          as.character(packageVersion("clusterProfiler")),
          as.character(packageVersion("org.Hs.eg.db")),
          as.character(packageVersion("reactome.db")),
          format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z")),
  stringsAsFactors=FALSE)
write.csv(manifest, file.path(DIAG_DIR, "M12_run_manifest.csv"), row.names=FALSE)
write.csv(manifest, file.path(DIAG_DIR, "M12_database_versions.csv"), row.names=FALSE)

# Mapping diagnostics
map_sum <- read.csv(file.path(MAP_DIR, "M12_gene_mapping_summary.csv"))
write.csv(map_sum, file.path(DIAG_DIR, "M12_mapping_diagnostics.csv"), row.names=FALSE)

cat("\nDone.\n")
