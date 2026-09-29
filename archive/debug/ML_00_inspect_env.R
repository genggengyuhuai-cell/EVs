# Inspect environment for v2.1 DEP-driven ML
cat("=== R packages ===\n")
pkgs <- c("glmnet","Boruta","xgboost","readxl","digest","pROC","Matrix")
for (p in pkgs) {
  ok <- requireNamespace(p, quietly=TRUE)
  v <- if (ok) as.character(packageVersion(p)) else "MISSING"
  cat(sprintf("  %-10s %s\n", p, v))
}

cat("\n=== Primary log2 matrix header ===\n")
con <- gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz")
hdr <- readLines(con, n=1); close(con)
parts <- strsplit(hdr, ",")[[1]]
cat("n_cols:", length(parts), "\n")
cat("first 6:", paste(head(parts,6), collapse=" | "), "\n")
cat("last 3:", paste(tail(parts,3), collapse=" | "), "\n")

cat("\n=== Split meta cross-tab ===\n")
m <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv", stringsAsFactors=FALSE)
cat("meta cols:", paste(colnames(m), collapse=", "), "\n")
print(table(Split=m$Split))
print(table(Group=m$TREAT1_clean, Split=m$Split))

cat("\n=== D03 locked candidates: direction tally ===\n")
d <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv", stringsAsFactors=FALSE)
cat("n =", nrow(d), "\n")
print(table(d$Direction))
cat("PG.ProteinGroups unique?", length(unique(d$PG.ProteinGroups)) == nrow(d), "\n")
