sink("F:/env/descriptive/analysis_v2.0/M12_pathway_v2.1/probe.log")
cat("start\n")
for (p in c("limma","org.Hs.eg.db","msigdbr","fgsea","clusterProfiler",
            "AnnotationDbi","GO.db","qvalue","data.table")) {
  ok <- requireNamespace(p, quietly=TRUE)
  v <- if (ok) as.character(packageVersion(p)) else "MISSING"
  cat(sprintf("  %-18s %s\n", p, v))
}
cat("\n--- canonical_protein_annotation.csv ---\n")
ann_all <- read.csv("F:/env/descriptive/canonical_protein_annotation.csv", stringsAsFactors=FALSE, check.names=FALSE)
cat("rows:", nrow(ann_all), "\n")
cat("cols:", paste(colnames(ann_all), collapse=", "), "\n")
print(head(ann_all, 2))
cat("\n--- D515 universe ---\n")
u_all <- read.csv("F:/env/descriptive/analysis_v2.0/universes/D515.csv", stringsAsFactors=FALSE, check.names=FALSE)
cat("rows:", nrow(u_all), "\n")
cat("cols:", paste(colnames(u_all), collapse=", "), "\n")
sink()
cat("done\n")
