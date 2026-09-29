cat("=== KEGG / Reactome resource probe ===\n")
for (p in c("reactome.db","KEGG.db","AnnotationDbi","org.Hs.eg.db","GO.db")) {
  ok <- requireNamespace(p, quietly=TRUE)
  v <- if (ok) as.character(packageVersion(p)) else "MISSING"
  cat(sprintf("  %-18s %s\n", p, v))
}

# Test GO BP extraction from org.Hs.eg.db
cat("\n=== GO BP via org.Hs.eg.db ===\n")
library(org.Hs.eg.db)
bp <- AnnotationDbi::select(org.Hs.eg.db,
    keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
    columns=c("GO","ONTOLOGY","SYMBOL"),
    keytype="ENTREZID")
bp <- bp[bp$ONTOLOGY=="BP" & !is.na(bp$GO), ]
cat("GO BP gene-term pairs:", nrow(bp), "\n")
cat("Unique GO BP terms:", length(unique(bp$GO)), "\n")
cat("Unique genes:", length(unique(bp$ENTREZID)), "\n")
