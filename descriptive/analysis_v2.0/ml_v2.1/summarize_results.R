# Read integrated table and summarize
df <- read.csv("descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv",
               stringsAsFactors=FALSE, check.names=FALSE)
cat("Shape:", nrow(df), "x", ncol(df), "\n\n")
cat("Columns:\n")
print(colnames(df))

# Show key ML columns
key <- c("PG.ProteinGroups","Gene_symbol","Discovery_log2FC","Discovery_BH_FDR",
         "LASSO_selection_freq","LASSO_full_coef",
         "EN_selection_freq","EN_full_coef",
         "Boruta_confirmed_freq","Boruta_full_status",
         "XGBoost_mean_rank","XGBoost_full_gain",
         "Direction_concordant","Nominal_replication","FDR_supported_replication")
key <- intersect(key, colnames(df))
cat("\nKey columns present:", paste(key, collapse=", "), "\n")

# Sort by a "robustness score" = LASSO_freq + EN_freq + XGBoost rank (lower better)
df$xgb_rank <- df$XGBoost_mean_rank
df$robust_score <- (df$LASSO_selection_freq + df$EN_selection_freq) - df$xgb_rank/15
df_sorted <- df[order(-df$LASSO_selection_freq, -df$EN_selection_freq, df$xgb_rank), ]

cat("\n=== Top 25 by LASSO selection frequency, then EN, then XGBoost rank ===\n")
show_cols <- intersect(c("Gene_symbol","PG.ProteinGroups","Discovery_log2FC","Discovery_BH_FDR",
                         "LASSO_selection_freq","LASSO_full_coef",
                         "EN_selection_freq","EN_full_coef",
                         "Boruta_confirmed_freq",
                         "XGBoost_mean_rank","XGBoost_full_gain",
                         "Direction_concordant","Nominal_replication"), colnames(df_sorted))
print(head(df_sorted[, show_cols], 25), row.names=FALSE)

cat("\n=== LASSO selection frequency distribution ===\n")
print(table(df$LASSO_selection_freq))
cat("\n=== EN selection frequency distribution ===\n")
print(table(df$EN_selection_freq))

cat("\n=== Proteins selected by LASSO in >=10/15 outer folds ===\n")
print(df_sorted[df_sorted$LASSO_selection_freq >= 10, show_cols], row.names=FALSE)

cat("\n=== Proteins in top-10 XGBoost gain AND in LASSO nonzero ===\n")
top_xgb <- df_sorted[order(df_sorted$XGBoost_full_gain, decreasing=TRUE), ][1:15, ]
print(top_xgb[, show_cols], row.names=FALSE)
