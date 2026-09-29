cat("=== Full Bioconductor resource probe ===\n")
for (p in c("reactome.db","KEGG.db","GO.db","org.Hs.eg.db",
            "clusterProfiler","ReactomePA","DOSE","enrichplot")) {
  ok <- requireNamespace(p, quietly=TRUE)
  v <- if (ok) as.character(packageVersion(p)) else "MISSING"
  cat(sprintf("  %-18s %s\n", p, v))
}
