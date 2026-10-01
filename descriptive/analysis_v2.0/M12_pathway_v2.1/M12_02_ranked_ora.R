# =============================================================================
# M12_02_ranked_ora.R — Ranked cameraPR + ORA (v2.1 §10, Phase 5 repaired)
# [Phase 5 REPAIR]:
#   - Removed self-fit lmFit/eBayes (~group, no environment adjustment)
#   - Removed row-wise median imputation
#   - Now reads D02 primary model output (D02_Long_vs_Short_all_tested.csv)
#   - Ranking statistic = signed moderated t = log2FC / SE (from D02, environment-adjusted)
#   - KEGG removed (NOT_RUN per contract §16)
#   - Protein universe from D02 (1,445 eligible), intersected with mapped genes
# =============================================================================
suppressPackageStartupMessages({
  library(limma)
  library(fgsea)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  library(GO.db)
  library(reactome.db)
  library(data.table)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
MAP_DIR <- file.path(M12, "mapping")
RANK_DIR <- file.path(M12, "ranked")
ORA_DIR  <- file.path(M12, "ora")
dir.create(RANK_DIR, recursive=TRUE, showWarnings=FALSE)
dir.create(ORA_DIR,  recursive=TRUE, showWarnings=FALSE)

set.seed(20260928, kind="Mersenne-Twister")

# -----------------------------------------------------------------------------
# 1. Load mapping contract
# -----------------------------------------------------------------------------
cat("== 1. Loading mapping contract ==\n")
contract <- read.csv(file.path(MAP_DIR, "M12_gene_mapping_contract.csv"),
                     stringsAsFactors=FALSE, check.names=FALSE)
reps <- contract[contract$representative_status %in% c("REPRESENTATIVE","SINGLE") &
                 contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", ]
cat("Representative genes for pathway analysis:", nrow(reps), "\n")

# -----------------------------------------------------------------------------
# 2. [Phase 5 REPAIR] Load D02 primary model ranking statistic
#    Canonical ranking = signed moderated t from D02 (~0+dose+environment, eBayes trend+robust)
#    NO imputation. Model_status == "NON_ESTIMABLE" excluded.
# -----------------------------------------------------------------------------
cat("== 2. Loading D02 primary model ranking ==\n")
d02 <- read.csv("descriptive/discovery_validation/D02_discovery_primary/D02_Long_vs_Short_all_tested.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
cat("D02 all tested proteins:", nrow(d02), "\n")

# Filter to ESTIMABLE only
d02_est <- d02[d02$Model_status == "ESTIMABLE", ]
cat("D02 ESTIMABLE proteins:", nrow(d02_est), "\n")
cat("D02 NON_ESTIMABLE (excluded):", nrow(d02) - nrow(d02_est), "\n")

# Signed moderated t = log2FC / SE
d02_est$moderated_t <- d02_est$log2FC / d02_est$SE
cat("D02 moderated t range:", range(d02_est$moderated_t, na.rm=TRUE), "\n")

# Merge with mapping contract (by PG.ProteinGroups)
mapped_pgs <- reps$PG.ProteinGroups
d02_mapped <- d02_est[d02_est$PG.ProteinGroups %in% mapped_pgs, ]
cat("D02 ESTIMABLE + gene-mapped:", nrow(d02_mapped), "\n")

# Map PG -> gene symbol (use representative gene from mapping contract)
prot_to_gene <- setNames(reps$Gene_symbol, reps$PG.ProteinGroups)
d02_mapped$Gene_symbol_mapped <- prot_to_gene[d02_mapped$PG.ProteinGroups]

# Build named stats vector: gene symbol -> moderated t
# Check for duplicate gene symbols (should be 0 duplicate groups per mapping)
stats_df <- d02_mapped[!is.na(d02_mapped$Gene_symbol_mapped),
                       c("Gene_symbol_mapped", "moderated_t")]
stats_df <- stats_df[!duplicated(stats_df$Gene_symbol_mapped), ]
stats <- setNames(stats_df$moderated_t, stats_df$Gene_symbol_mapped)
stats <- sort(stats, decreasing=TRUE)
cat("Ranked genes (unique, mapped, estimable):", length(stats), "\n")

# P7 reporting fields
N_primary_tested <- nrow(d02)
N_gene_mapped <- nrow(reps)
N_ranked <- length(stats)
N_ORA_background <- length(stats)
N_excluded_multigene <- sum(contract$mapping_status == "MULTI_GENE_AMBIGUOUS")
N_unmapped <- sum(contract$mapping_status == "UNMAPPED")
cat(sprintf("P7 fields: N_primary_tested=%d, N_gene_mapped=%d, N_ranked=%d, N_ORA_background=%d, N_excluded_multigene=%d, N_unmapped=%d\n",
            N_primary_tested, N_gene_mapped, N_ranked, N_ORA_background, N_excluded_multigene, N_unmapped))

# -----------------------------------------------------------------------------
# 3. Build pathway gene sets (gene-symbol level)
# -----------------------------------------------------------------------------
cat("\n== 3. Building pathway gene sets ==\n")

# --- GO BP via org.Hs.eg.db (ENTREZ -> SYMBOL) ---
go_map <- AnnotationDbi::select(org.Hs.eg.db,
    keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
    columns=c("GO","ONTOLOGY","SYMBOL"), keytype="ENTREZID")
go_bp_map <- go_map[go_map$ONTOLOGY=="BP" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_bp_terms <- split(go_bp_map$SYMBOL, go_bp_map$GO)
go_bp_terms <- lapply(go_bp_terms, unique)
cat("GO BP raw terms:", length(go_bp_terms), "\n")

# GO BP term names
go_bp_names <- AnnotationDbi::select(GO.db, keys=names(go_bp_terms),
                                  columns="TERM", keytype="GOID")
go_bp_name_map <- setNames(go_bp_names$TERM, go_bp_names$GOID)

# --- GO MF (secondary, for later use) ---
go_mf_map <- go_map[go_map$ONTOLOGY=="MF" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_mf_terms <- split(go_mf_map$SYMBOL, go_mf_map$GO)
go_mf_terms <- lapply(go_mf_terms, unique)
cat("GO MF raw terms:", length(go_mf_terms), "\n")
go_mf_names <- AnnotationDbi::select(GO.db, keys=names(go_mf_terms), columns="TERM", keytype="GOID")
go_mf_name_map <- setNames(go_mf_names$TERM, go_mf_names$GOID)

# --- GO CC (secondary, for later use) ---
go_cc_map <- go_map[go_map$ONTOLOGY=="CC" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_cc_terms <- split(go_cc_map$SYMBOL, go_cc_map$GO)
go_cc_terms <- lapply(go_cc_terms, unique)
cat("GO CC raw terms:", length(go_cc_terms), "\n")
go_cc_names <- AnnotationDbi::select(GO.db, keys=names(go_cc_terms), columns="TERM", keytype="GOID")
go_cc_name_map <- setNames(go_cc_names$TERM, go_cc_names$GOID)

# --- Reactome via reactome.db ---
rea_sets <- list()
rea_map <- AnnotationDbi::select(reactome.db,
    keys=keys(reactome.db, keytype="ENTREZID"),
    columns=c("REACTOMEID"), keytype="ENTREZID")
e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=rea_map$ENTREZID,
                             columns="SYMBOL", keytype="ENTREZID")
rea_map$SYMBOL <- e2s$SYMBOL[match(rea_map$ENTREZID, e2s$ENTREZID)]
rea_map <- rea_map[!is.na(rea_map$SYMBOL), ]
rea_list <- split(rea_map$SYMBOL, rea_map$REACTOMEID)
rea_list <- lapply(rea_list, unique)
rea_sets <- rea_list[lengths(rea_list) >= 10]
cat("Reactome sets (after >=10):", length(rea_sets), "\n")

# [Phase 5 REPAIR] KEGG NOT_RUN per contract §16. No download, no enrichment.
cat("KEGG: NOT_RUN (per contract §16)\n")

# -----------------------------------------------------------------------------
# 4. cameraPR (primary: GO BP + Reactome, FDR_pooled = BH across both)
# -----------------------------------------------------------------------------
run_camerapr <- function(stats, sets, label, cor=0.01, name_map=NULL) {
  cat("  cameraPR:", label, "with", length(sets), "sets\n")
  bg_genes <- names(stats)
  sets_filt <- lapply(sets, function(s) intersect(s, bg_genes))
  keep <- lengths(sets_filt) >= 10 & lengths(sets_filt) <= 500
  sets_filt <- sets_filt[keep]
  cat("    after 10-500 filter:", length(sets_filt), "\n")

  res_list <- lapply(names(sets_filt), function(nm) {
    members <- sets_filt[[nm]]
    idx <- which(names(stats) %in% members)
    cam <- tryCatch(cameraPR(stats, index=idx, use.ranks=FALSE, inter.gene.cor=cor),
                    error=function(e) NULL)
    if (is.null(cam)) return(NULL)
    pname <- if (!is.null(name_map) && nm %in% names(name_map)) name_map[[nm]] else nm
    data.frame(database=label, pathway_id=nm, pathway_name=pname,
               pathway_size=length(members),
               direction=cam$Direction,
               PValue=cam$PValue, FDR=NA,
               NGenes=cam$NGenes,
               stringsAsFactors=FALSE)
  })
  res <- do.call(rbind, res_list)
  res$FDR <- p.adjust(res$PValue, method="BH")
  res[order(res$PValue), ]
}

cat("\n== 4. cameraPR primary (GO BP + Reactome, cor=0.01) ==\n")
go_res   <- run_camerapr(stats, go_bp_terms, "GO_BP", cor=0.01, name_map=go_bp_name_map)
rea_res  <- run_camerapr(stats, rea_sets,  "Reactome", cor=0.01, name_map=NULL)

write.csv(go_res, file.path(RANK_DIR, "M12_ranked_GO_BP.csv"), row.names=FALSE)
write.csv(rea_res, file.path(RANK_DIR, "M12_ranked_Reactome.csv"), row.names=FALSE)

# Combined primary: GO BP + Reactome, FDR_pooled = BH across both
all_rank <- rbind(go_res, rea_res)
all_rank$FDR_pooled <- p.adjust(all_rank$PValue, method="BH")
all_rank <- all_rank[order(all_rank$FDR_pooled), ]
write.csv(all_rank, file.path(RANK_DIR, "M12_ranked_combined_FDR.csv"), row.names=FALSE)
cat("Pooled PATH-R FDR<0.05:", sum(all_rank$FDR_pooled < 0.05), "\n")
cat("  GO_BP sig (pooled):", sum(all_rank$FDR_pooled < 0.05 & all_rank$database=="GO_BP"), "\n")
cat("  Reactome sig (pooled):", sum(all_rank$FDR_pooled < 0.05 & all_rank$database=="Reactome"), "\n")

# Secondary: GO MF + GO CC cameraPR (per-family FDR, M12B role)
cat("\n== 4b. cameraPR secondary (GO MF + GO CC, per-family FDR) ==\n")
mf_res <- run_camerapr(stats, go_mf_terms, "GO_MF", cor=0.01, name_map=go_mf_name_map)
cc_res <- run_camerapr(stats, go_cc_terms, "GO_CC", cor=0.01, name_map=go_cc_name_map)
write.csv(mf_res, file.path(RANK_DIR, "M12_ranked_GO_MF.csv"), row.names=FALSE)
write.csv(cc_res, file.path(RANK_DIR, "M12_ranked_GO_CC.csv"), row.names=FALSE)
cat("  GO_MF tested:", nrow(mf_res), "sig (FDR<0.05):", sum(mf_res$FDR<0.05), "\n")
cat("  GO_CC tested:", nrow(cc_res), "sig (FDR<0.05):", sum(cc_res$FDR<0.05), "\n")

# KEGG placeholder (NOT_RUN)
kegg_placeholder <- data.frame(
  database=character(0), pathway_id=character(0), pathway_name=character(0),
  pathway_size=integer(0), direction=character(0), PValue=numeric(0),
  FDR=numeric(0), NGenes=integer(0), stringsAsFactors=FALSE
)
write.csv(kegg_placeholder, file.path(RANK_DIR, "M12_ranked_KEGG.csv"), row.names=FALSE)

# -----------------------------------------------------------------------------
# 5. ORA on 85 locked D03 DEPs
# -----------------------------------------------------------------------------
cat("\n== 5. ORA on 85 locked D03 DEPs ==\n")
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
cat("D03 locked candidates:", nrow(d03), "\n")

# Map D03 PGs to gene symbols via mapping contract
d03_genes <- unique(na.omit(prot_to_gene[d03$PG.ProteinGroups]))
cat("D03 DEPs -> mapped genes:", length(d03_genes), "\n")

# Foreground = D03 genes that are in the ranked (mapped + estimable) universe
fg <- intersect(d03_genes, names(stats))
# Background = all mapped + estimable genes (NOT hardcoded 1414)
bg <- names(stats)
cat("ORA foreground (D03 mapped + estimable):", length(fg), "\n")
cat("ORA background (mapped + estimable):", length(bg), "\n")

run_ora <- function(fg, bg, sets, label, name_map=NULL) {
  sets_filt <- lapply(sets, function(s) intersect(s, bg))
  keep <- lengths(sets_filt) >= 10 & lengths(sets_filt) <= 500
  sets_filt <- sets_filt[keep]
  N <- length(bg); K <- length(fg)
  res_list <- lapply(names(sets_filt), function(nm) {
    members <- sets_filt[[nm]]
    x <- length(intersect(fg, members))
    m <- length(members)
    if (x == 0) return(NULL)
    ft <- fisher.test(matrix(c(x, m-x, K-x, N-m-K+x), nrow=2), alternative="greater")
    pname <- if (!is.null(name_map) && nm %in% names(name_map)) name_map[[nm]] else nm
    data.frame(database=label, pathway_id=nm, pathway_name=pname,
               foreground_mapped=x, background_pathway=m,
               foreground_total=K, background_total=N,
               enrichment_ratio=(x/K)/(m/N),
               odds_ratio=unname(ft$estimate),
               PValue=ft$p.value, FDR=NA, stringsAsFactors=FALSE)
  })
  res <- do.call(rbind, res_list)
  res$FDR <- p.adjust(res$PValue, method="BH")
  res[order(res$PValue), ]
}

ora_go_bp   <- run_ora(fg, bg, go_bp_terms, "GO_BP", name_map=go_bp_name_map)
ora_rea     <- run_ora(fg, bg, rea_sets,  "Reactome", name_map=NULL)
ora_go_mf   <- run_ora(fg, bg, go_mf_terms, "GO_MF", name_map=go_mf_name_map)
ora_go_cc   <- run_ora(fg, bg, go_cc_terms, "GO_CC", name_map=go_cc_name_map)

write.csv(ora_go_bp, file.path(ORA_DIR, "M12_ORA_GO_BP.csv"), row.names=FALSE)
write.csv(ora_rea, file.path(ORA_DIR, "M12_ORA_Reactome.csv"), row.names=FALSE)
write.csv(ora_go_mf, file.path(ORA_DIR, "M12_ORA_GO_MF.csv"), row.names=FALSE)
write.csv(ora_go_cc, file.path(ORA_DIR, "M12_ORA_GO_CC.csv"), row.names=FALSE)

# Combined primary ORA: GO BP + Reactome, FDR_pooled = BH across both
ora_comb <- rbind(ora_go_bp, ora_rea)
ora_comb$FDR_pooled <- p.adjust(ora_comb$PValue, method="BH")
ora_comb <- ora_comb[order(ora_comb$FDR_pooled), ]
write.csv(ora_comb, file.path(ORA_DIR, "M12_ORA_combined_FDR.csv"), row.names=FALSE)
cat("Pooled PATH-O FDR<0.05:", sum(ora_comb$FDR_pooled < 0.05), "\n")
cat("  GO_BP sig (pooled):", sum(ora_comb$FDR_pooled < 0.05 & ora_comb$database=="GO_BP"), "\n")
cat("  Reactome sig (pooled):", sum(ora_comb$FDR_pooled < 0.05 & ora_comb$database=="Reactome"), "\n")

# KEGG ORA placeholder
write.csv(kegg_placeholder[, c("database","pathway_id","pathway_name")],
          file.path(ORA_DIR, "M12_ORA_KEGG.csv"), row.names=FALSE)

cat("\n=== Top ranked (PATH-R FDR_pooled<0.05) ===\n")
print(head(all_rank[all_rank$FDR_pooled<0.05, c("database","pathway_name","pathway_size","direction","PValue","FDR_pooled")], 15), row.names=FALSE)
cat("\n=== Top ORA (PATH-O FDR_pooled<0.05) ===\n")
print(head(ora_comb[ora_comb$FDR_pooled<0.05, c("database","pathway_name","foreground_mapped","background_pathway","enrichment_ratio","FDR_pooled")], 15), row.names=FALSE)
cat("\nDone M12_02.\n")
