pkgs <- c("limma","fgsea","org.Hs.eg.db","GO.db","reactome.db","clusterProfiler","AnnotationDbi","data.table","statmod","glmnet","ranger","xgboost","logistf")
cat("R.version:\n")
cat(R.version.string, "\n")
cat("\nPackage versions:\n")
for (p in pkgs) {
  v <- tryCatch(as.character(packageVersion(p)), error=function(e) "NOT_INSTALLED")
  cat(sprintf("  %-20s %s\n", p, v))
}
