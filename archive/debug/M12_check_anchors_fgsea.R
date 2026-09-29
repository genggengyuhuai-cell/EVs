le <- read.csv("descriptive/analysis_v2.0/M12_pathway_v2.1/ranked_gsea/M12_fgsea_leading_edge.csv",
               stringsAsFactors=FALSE, check.names=FALSE)
cat("Columns:", paste(names(le), collapse=", "), "\n\n")
anchors <- c("GOLGA3","TSPAN14","GAL","DMP1","IGF1")
cat("=== Anchor 5 in fgsea leading-edge ===\n")
for (g in anchors) {
  sub <- le[le$gene == g, ]
  cat(sprintf("\n%s: %d leading-edge rows\n", g, nrow(sub)))
  if (nrow(sub)) {
    cat("  databases:", paste(unique(sub$database), collapse=", "), "\n")
    cat("  pathways (first 8):", paste(head(unique(sub$pathway_id),8), collapse=", "), "\n")
    cat("  padj range:", paste(format(range(sub$padj, na.rm=TRUE), digits=3), collapse=" - "), "\n")
    cat("  NES range:", paste(format(range(sub$NES, na.rm=TRUE), digits=2), collapse=" to "), "\n")
    cat("  LASSO freq:", sub$LASSO_freq[1], " EN freq:", sub$EN_freq[1], " XGB rank:", sub$XGB_rank[1], "\n")
  }
}
