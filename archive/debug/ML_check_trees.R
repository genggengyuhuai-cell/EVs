cat("=== Tree / RF packages available ===\n")
for (p in c("ranger","randomForest","Boruta","xgboost")) {
  ok <- requireNamespace(p, quietly=TRUE)
  v <- if (ok) as.character(packageVersion(p)) else "MISSING"
  cat(sprintf("  %-14s %s\n", p, v))
}
