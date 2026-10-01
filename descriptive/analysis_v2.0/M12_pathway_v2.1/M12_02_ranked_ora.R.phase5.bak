# =============================================================================
# M12_02_ranked_ora.R — Ranked cameraPR + ORA (v2.1 §10)
# Uses local Bioconductor resources (no msigdbdf dependency).
# =============================================================================
suppressPackageStartupMessages({
  library(limma)
  library(fgsea)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  library(GO.db)
  library(clusterProfiler)
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
# 2. Load expression + metadata, Discovery High vs Low
# -----------------------------------------------------------------------------
cat("== 2. Loading expression and metadata ==\n")
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names=1, check.names=FALSE)
meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors=FALSE)
disc <- meta[meta$Split == "Discovery" & meta$TREAT1_clean %in% c("high","low"), ]
common_samps <- intersect(disc$UniqueSampleID, colnames(expr))
disc <- disc[match(common_samps, disc$UniqueSampleID), ]

use_prots <- intersect(reps$PG.ProteinGroups, rownames(expr))
expr_use <- expr[use_prots, disc$UniqueSampleID]
cat("Matrix:", nrow(expr_use), "proteins x", ncol(expr_use), "samples\n")

prot_to_gene <- setNames(reps$Gene_symbol, reps$PG.ProteinGroups)
gene_vec <- prot_to_gene[rownames(expr_use)]
stopifnot(!any(duplicated(gene_vec)))

# -----------------------------------------------------------------------------
# 3. limma High vs Low
# -----------------------------------------------------------------------------
cat("== 3. Fitting limma High vs Low ==\n")
group <- factor(disc$TREAT1_clean, levels=c("low","high"))
design <- model.matrix(~ group); colnames(design) <- c("Intercept","High_vs_Low")
mat <- as.matrix(expr_use)
for (i in seq_len(nrow(mat))) {
  rmed <- median(mat[i,], na.rm=TRUE)
  mat[i, is.na(mat[i,])] <- rmed
}
fit <- lmFit(mat, design); fit <- eBayes(fit)
tt <- topTable(fit, coef="High_vs_Low", number=Inf, sort.by="none")
tt$PG.ProteinGroups <- rownames(tt)
tt$Gene_symbol <- gene_vec[tt$PG.ProteinGroups]
stats <- setNames(tt$t, tt$Gene_symbol)
stats <- sort(stats[!is.na(names(stats))], decreasing=TRUE)
cat("Ranked genes:", length(stats), "\n")

# -----------------------------------------------------------------------------
# 4. Build pathway gene sets (gene-symbol level)
# -----------------------------------------------------------------------------
cat("== 4. Building pathway gene sets ==\n")

# --- GO BP via org.Hs.eg.db (ENTREZ -> SYMBOL) ---
go_map <- AnnotationDbi::select(org.Hs.eg.db,
    keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
    columns=c("GO","ONTOLOGY","SYMBOL"), keytype="ENTREZID")
go_map <- go_map[go_map$ONTOLOGY=="BP" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_terms <- split(go_map$SYMBOL, go_map$GO)
go_terms <- lapply(go_terms, unique)
cat("GO BP raw terms:", length(go_terms), "\n")

# GO term names
go_names <- AnnotationDbi::select(GO.db, keys=names(go_terms),
                                  columns="TERM", keytype="GOID")
go_name_map <- setNames(go_names$TERM, go_names$GOID)

# --- KEGG via clusterProfiler download ---
kegg_sets <- list()
tryCatch({
  kegg_list <- clusterProfiler::download_KEGG("hsa")
  # kegg_list$KEGGPATHID2EXTID maps pathway -> Entrez
  # Need Entrez -> Symbol
  e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=names(kegg_list$KEGGPATHID2EXTID),
                              columns="SYMBOL", keytype="ENTREZID")
  # Actually KEGGPATHID2EXTID is a named vector: pathway -> entrez
  # Build list
  for (pid in unique(names(kegg_list$KEGGPATHID2EXTID))) {
    entrez <- kegg_list$KEGGPATHID2EXTID[names(kegg_list$KEGGPATHID2EXTID)==pid]
    syms <- AnnotationDbi::select(org.Hs.eg.db, keys=entrez,
                                  columns="SYMBOL", keytype="ENTREZID")$SYMBOL
    syms <- unique(na.omit(syms))
    if (length(syms) >= 10) kegg_sets[[pid]] <- syms
  }
  cat("KEGG sets (after >=10):", length(kegg_sets), "\n")
}, error=function(e) {
  cat("KEGG download failed:", conditionMessage(e), "\n")
})

# --- Reactome via ReactomePA / reactome.db ---
rea_sets <- list()
tryCatch({
  library(reactome.db)
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
}, error=function(e) {
  cat("Reactome via reactome.db failed:", conditionMessage(e), "\n")
})

# -----------------------------------------------------------------------------
# 5. cameraPR
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

cat("\n== 5. cameraPR (cor=0.01) ==\n")
go_res   <- run_camerapr(stats, go_terms, "GO_BP", cor=0.01, name_map=go_name_map)
kegg_res <- if (length(kegg_sets)) run_camerapr(stats, kegg_sets, "KEGG", cor=0.01) else NULL
rea_res  <- if (length(rea_sets))  run_camerapr(stats, rea_sets,  "Reactome", cor=0.01) else NULL

write.csv(go_res, file.path(RANK_DIR, "M12_ranked_GO_BP.csv"), row.names=FALSE)
if (!is.null(kegg_res)) write.csv(kegg_res, file.path(RANK_DIR, "M12_ranked_KEGG.csv"), row.names=FALSE)
if (!is.null(rea_res))  write.csv(rea_res,  file.path(RANK_DIR, "M12_ranked_Reactome.csv"), row.names=FALSE)

# Combined
all_rank <- do.call(rbind, Filter(Negate(is.null), list(go_res, kegg_res, rea_res)))
all_rank$FDR_pooled <- p.adjust(all_rank$PValue, method="BH")
all_rank <- all_rank[order(all_rank$FDR_pooled), ]
write.csv(all_rank, file.path(RANK_DIR, "M12_ranked_combined_FDR.csv"), row.names=FALSE)
cat("Pooled PATH-R FDR<0.05:", sum(all_rank$FDR_pooled < 0.05), "\n")

# Sensitivity cor=0.05
cat("\n== 5b. Sensitivity cor=0.05 ==\n")
go_s   <- run_camerapr(stats, go_terms, "GO_BP", cor=0.05, name_map=go_name_map)
kegg_s <- if (length(kegg_sets)) run_camerapr(stats, kegg_sets, "KEGG", cor=0.05) else NULL
rea_s  <- if (length(rea_sets))  run_camerapr(stats, rea_sets,  "Reactome", cor=0.05) else NULL
all_sens <- do.call(rbind, Filter(Negate(is.null), list(go_s, kegg_s, rea_s)))
all_sens$FDR_pooled <- p.adjust(all_sens$PValue, method="BH")
write.csv(all_sens, file.path(RANK_DIR, "M12_ranked_sensitivity_cor005.csv"), row.names=FALSE)

# -----------------------------------------------------------------------------
# 6. ORA on 85 DEPs
# -----------------------------------------------------------------------------
cat("\n== 6. ORA on 85 DEPs ==\n")
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
d03_genes <- unique(na.omit(prot_to_gene[d03$PG.ProteinGroups]))
cat("85 DEPs ->", length(d03_genes), "unique genes\n")
fg <- intersect(d03_genes, names(stats))
bg <- names(stats)

run_ora <- function(fg, bg, sets, label) {
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
    data.frame(database=label, pathway_id=nm, pathway_name=nm,
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

ora_go   <- run_ora(fg, bg, go_terms, "GO_BP")
ora_kegg <- if (length(kegg_sets)) run_ora(fg, bg, kegg_sets, "KEGG") else NULL
ora_rea  <- if (length(rea_sets))  run_ora(fg, bg, rea_sets,  "Reactome") else NULL
write.csv(ora_go, file.path(ORA_DIR, "M12_ORA_GO_BP.csv"), row.names=FALSE)
if (!is.null(ora_kegg)) write.csv(ora_kegg, file.path(ORA_DIR, "M12_ORA_KEGG.csv"), row.names=FALSE)
if (!is.null(ora_rea))  write.csv(ora_rea,  file.path(ORA_DIR, "M12_ORA_Reactome.csv"), row.names=FALSE)

ora_comb <- do.call(rbind, Filter(Negate(is.null), list(ora_go, ora_kegg, ora_rea)))
ora_comb$FDR_pooled <- p.adjust(ora_comb$PValue, method="BH")
ora_comb <- ora_comb[order(ora_comb$FDR_pooled), ]
write.csv(ora_comb, file.path(ORA_DIR, "M12_ORA_combined_FDR.csv"), row.names=FALSE)
cat("Pooled PATH-O FDR<0.05:", sum(ora_comb$FDR_pooled < 0.05), "\n")

cat("\n=== Top ranked (PATH-R FDR<0.05) ===\n")
print(head(all_rank[all_rank$FDR_pooled<0.05, c("database","pathway_name","pathway_size","direction","PValue","FDR_pooled")], 15), row.names=FALSE)
cat("\n=== Top ORA (PATH-O FDR<0.05) ===\n")
print(head(ora_comb[ora_comb$FDR_pooled<0.05, c("database","pathway_name","foreground_mapped","background_pathway","enrichment_ratio","FDR_pooled")], 15), row.names=FALSE)
cat("\nDone.\n")
