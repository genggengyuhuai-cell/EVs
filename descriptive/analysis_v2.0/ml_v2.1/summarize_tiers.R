df <- read.csv("descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv",
               stringsAsFactors=FALSE, check.names=FALSE)
# The merge created Gene_symbol.x (from D03) and Gene_symbol.y (from D08). Use x.
cat("=== Key candidates with gene symbols ===\n")
# Tier 1: LASSO freq >= 0.7 AND EN freq >= 0.7
tier1 <- df[df$LASSO_selection_freq >= 0.7 & df$EN_selection_freq >= 0.7, ]
tier1 <- tier1[order(-tier1$LASSO_selection_freq, -tier1$EN_selection_freq), ]
print(tier1[, c("PG.ProteinGroups","Gene_symbol.x","Discovery_log2FC.x","Discovery_BH_FDR",
                "LASSO_selection_freq","LASSO_full_coef","EN_selection_freq","EN_full_coef",
                "XGBoost_mean_rank","XGBoost_full_gain",
                "Direction_concordant","Nominal_replication","FDR_supported_replication")],
      row.names=FALSE)

cat("\n=== Tier 2: LASSO 0.4-0.7 (not already in tier1) ===\n")
tier2 <- df[df$LASSO_selection_freq >= 0.4 & df$LASSO_selection_freq < 0.7, ]
tier2 <- tier2[order(-tier2$LASSO_selection_freq), ]
print(tier2[, c("PG.ProteinGroups","Gene_symbol.x",
                "LASSO_selection_freq","LASSO_full_coef","EN_selection_freq","EN_full_coef",
                "XGBoost_mean_rank","XGBoost_full_gain",
                "Direction_concordant","Nominal_replication")], row.names=FALSE)

cat("\n=== XGBoost top-10 that LASSO/EN miss entirely (LASSO_freq=0) ===\n")
top_xgb <- df[order(-df$XGBoost_full_gain), ][1:15, ]
miss <- top_xgb[top_xgb$LASSO_selection_freq == 0, ]
print(miss[, c("PG.ProteinGroups","Gene_symbol.x","XGBoost_full_gain","XGBoost_mean_rank",
               "Direction_concordant","Nominal_replication")], row.names=FALSE)

cat("\n=== D08 nominally replicated proteins that also survive ML ===\n")
rep <- df[df$Nominal_replication == TRUE, ]
rep <- rep[order(-rep$LASSO_selection_freq, -rep$EN_selection_freq), ]
print(rep[, c("PG.ProteinGroups","Gene_symbol.x",
              "LASSO_selection_freq","EN_selection_freq","XGBoost_full_gain",
              "FDR_supported_replication")], row.names=FALSE)
cat("\nTotal nominally replicated in D08:", sum(df$Nominal_replication == TRUE), "\n")
cat("Total FDR-supported in D08:", sum(df$FDR_supported_replication == TRUE), "\n")
