# Fix KEGG gene sets and append to ranked/ORA outputs
suppressPackageStartupMessages({
  library(limma)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  library(clusterProfiler)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
RANK_DIR <- file.path(M12, "ranked")
ORA_DIR  <- file.path(M12, "ora")

# Load stats (recompute quickly from saved contract)
contract <- read.csv(file.path(M12, "mapping/M12_gene_mapping_contract.csv"),
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
stats <- sort(setNames(tt$t, tt$Gene_symbol), decreasing=TRUE)

# KEGG via download_KEGG
cat("Downloading KEGG...\n")
kegg_list <- clusterProfiler::download_KEGG("hsa")
# KEGGPATHID2EXTID is an env; convert to list
p2e <- as.list(kegg_list$KEGGPATHID2EXTID)
p2n <- as.list(kegg_list$KEGGPATHID2NAME)
cat("KEGG pathways:", length(p2e), "\n")

# Map Entrez -> Symbol
entrez_all <- unique(unlist(p2e))
e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=entrez_all,
                              columns="SYMBOL", keytype="ENTREZID")
e2s_map <- setNames(e2s$SYMBOL, e2s$ENTREZID)

kegg_sets <- lapply(p2e, function(entrez) {
  syms <- unique(na.omit(e2s_map[entrez]))
  syms
})
kegg_sets <- kegg_sets[lengths(kegg_sets) >= 10]
cat("KEGG sets (>=10 genes):", length(kegg_sets), "\n")

# cameraPR
run_cam <- function(stats, sets, label, cor=0.01, names_map=NULL) {
  bg <- names(stats)
  sets_f <- lapply(sets, function(s) intersect(s, bg))
  keep <- lengths(sets_f) >= 10 & lengths(sets_f) <= 500
  sets_f <- sets_f[keep]
  cat(label, "pathways tested:", length(sets_f), "\n")
  res <- lapply(names(sets_f), function(nm) {
    members <- sets_f[[nm]]
    idx <- which(names(stats) %in% members)
    cam <- tryCatch(cameraPR(stats, index=idx, use.ranks=FALSE, inter.gene.cor=cor),
                    error=function(e) NULL)
    if (is.null(cam)) return(NULL)
    pname <- if (!is.null(names_map) && nm %in% names(names_map)) names_map[[nm]] else nm
    data.frame(database=label, pathway_id=nm, pathway_name=pname,
               pathway_size=length(members), direction=cam$Direction,
               PValue=cam$PValue, FDR=NA, NGenes=cam$NGenes,
               stringsAsFactors=FALSE)
  })
  res <- do.call(rbind, res)
  res$FDR <- p.adjust(res$PValue, method="BH")
  res[order(res$PValue), ]
}

kegg_res   <- run_cam(stats, kegg_sets, "KEGG", cor=0.01, names_map=p2n)
kegg_sens  <- run_cam(stats, kegg_sets, "KEGG", cor=0.05, names_map=p2n)
write.csv(kegg_res, file.path(RANK_DIR, "M12_ranked_KEGG.csv"), row.names=FALSE)

# Append to combined FDR
prev_comb <- read.csv(file.path(RANK_DIR, "M12_ranked_combined_FDR.csv"), stringsAsFactors=FALSE)
new_comb <- rbind(prev_comb[prev_comb$database != "KEGG", ], kegg_res)
new_comb$FDR_pooled <- p.adjust(new_comb$PValue, method="BH")
new_comb <- new_comb[order(new_comb$FDR_pooled), ]
write.csv(new_comb, file.path(RANK_DIR, "M12_ranked_combined_FDR.csv"), row.names=FALSE)

prev_sens <- read.csv(file.path(RANK_DIR, "M12_ranked_sensitivity_cor005.csv"), stringsAsFactors=FALSE)
new_sens <- rbind(prev_sens[prev_sens$database != "KEGG", ], kegg_sens)
new_sens$FDR_pooled <- p.adjust(new_sens$PValue, method="BH")
write.csv(new_sens, file.path(RANK_DIR, "M12_ranked_sensitivity_cor005.csv"), row.names=FALSE)

# ORA KEGG
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
d03_genes <- unique(na.omit(prot_to_gene[d03$PG.ProteinGroups]))
fg <- intersect(d03_genes, names(stats)); bg <- names(stats)
run_ora <- function(fg, bg, sets, label) {
  sets_f <- lapply(sets, function(s) intersect(s, bg))
  keep <- lengths(sets_f) >= 10 & lengths(sets_f) <= 500
  sets_f <- sets_f[keep]
  N <- length(bg); K <- length(fg)
  res <- lapply(names(sets_f), function(nm) {
    members <- sets_f[[nm]]
    x <- length(intersect(fg, members)); m <- length(members)
    if (x == 0) return(NULL)
    ft <- fisher.test(matrix(c(x, m-x, K-x, N-m-K+x), nrow=2), alternative="greater")
    data.frame(database=label, pathway_id=nm, pathway_name=nm,
               foreground_mapped=x, background_pathway=m,
               foreground_total=K, background_total=N,
               enrichment_ratio=(x/K)/(m/N), odds_ratio=unname(ft$estimate),
               PValue=ft$p.value, FDR=NA, stringsAsFactors=FALSE)
  })
  res <- do.call(rbind, res); res$FDR <- p.adjust(res$PValue, method="BH")
  res[order(res$PValue), ]
}
ora_kegg <- run_ora(fg, bg, kegg_sets, "KEGG")
write.csv(ora_kegg, file.path(ORA_DIR, "M12_ORA_KEGG.csv"), row.names=FALSE)

prev_ora <- read.csv(file.path(ORA_DIR, "M12_ORA_combined_FDR.csv"), stringsAsFactors=FALSE)
new_ora <- rbind(prev_ora[prev_ora$database != "KEGG", ], ora_kegg)
new_ora$FDR_pooled <- p.adjust(new_ora$PValue, method="BH")
new_ora <- new_ora[order(new_ora$FDR_pooled), ]
write.csv(new_ora, file.path(ORA_DIR, "M12_ORA_combined_FDR.csv"), row.names=FALSE)

cat("\nKEGG ranked FDR<0.05:", sum(kegg_res$FDR < 0.05), "\n")
cat("KEGG ORA FDR<0.05:", sum(ora_kegg$FDR < 0.05), "\n")
cat("Done.\n")
