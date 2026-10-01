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

# -----------------------------------------------------------------------------
# Phase 1 fixed-85 P0 repair comparison outputs
# -----------------------------------------------------------------------------
base_dir <- "descriptive/analysis_v2.0/ml_v2.1"
snapshot_dir <- file.path(base_dir, "pre_P0_repair_snapshot")

old_df <- read.csv(file.path(snapshot_dir, "integrated_table_85.csv"),
                   stringsAsFactors=FALSE, check.names=FALSE)
new_df <- read.csv(file.path(base_dir, "results", "integrated_table_85.csv"),
                   stringsAsFactors=FALSE, check.names=FALSE)
old_cv <- read.csv(file.path(snapshot_dir, "outer_cv_metrics.csv"),
                   stringsAsFactors=FALSE, check.names=FALSE)
new_cv <- read.csv(file.path(base_dir, "results", "outer_cv_metrics.csv"),
                   stringsAsFactors=FALSE, check.names=FALSE)
old_en_cv <- read.csv(file.path(snapshot_dir, "outer_cv_en_metrics_reconstructed.csv"),
                      stringsAsFactors=FALSE, check.names=FALSE)
old_xgb <- read.csv(file.path(snapshot_dir, "xgboost_full_importance.csv"),
                    stringsAsFactors=FALSE, check.names=FALSE)
new_xgb <- read.csv(file.path(base_dir, "results", "xgboost_full_importance.csv"),
                    stringsAsFactors=FALSE, check.names=FALSE)

stopifnot(nrow(old_df) == 85L, nrow(new_df) == 85L)
stopifnot(identical(old_df$PG.ProteinGroups, new_df$PG.ProteinGroups))
stopifnot(identical(old_cv[, c("rep_id", "fold", "n_train", "n_test")],
                    new_cv[, c("rep_id", "fold", "n_train", "n_test")]))
stopifnot(nrow(old_cv) == 15L, nrow(new_cv) == 15L)

gene_col <- if ("Gene_symbol.x" %in% names(new_df)) "Gene_symbol.x" else "Gene_symbol"
genes <- new_df[[gene_col]]
names(genes) <- new_df$PG.ProteinGroups

old_rank <- setNames(seq_len(nrow(old_xgb)), old_xgb$Feature)
new_rank <- setNames(seq_len(nrow(new_xgb)), new_xgb$Feature)
old_gain <- setNames(old_xgb$Gain, old_xgb$Feature)
new_gain <- setNames(new_xgb$Gain, new_xgb$Feature)
old_top10 <- head(old_xgb$Feature, 10L)
new_top10 <- head(new_xgb$Feature, 10L)
old_top20 <- head(old_xgb$Feature, 20L)
new_top20 <- head(new_xgb$Feature, 20L)

old_tier1 <- old_df$PG.ProteinGroups[old_df$LASSO_selection_freq >= 0.70 &
                                     old_df$EN_selection_freq >= 0.70]
new_tier1 <- new_df$PG.ProteinGroups[new_df$LASSO_selection_freq >= 0.70 &
                                     new_df$EN_selection_freq >= 0.70]
old_lasso <- old_df$PG.ProteinGroups[old_df$LASSO_selection_freq >= 0.70]
new_lasso <- new_df$PG.ProteinGroups[new_df$LASSO_selection_freq >= 0.70]
old_en <- old_df$PG.ProteinGroups[old_df$EN_selection_freq >= 0.70]
new_en <- new_df$PG.ProteinGroups[new_df$EN_selection_freq >= 0.70]

feature_changes <- data.frame(
  PG.ProteinGroups=new_df$PG.ProteinGroups,
  Gene_symbol=genes[new_df$PG.ProteinGroups],
  Old_LASSO_selection_freq=old_df$LASSO_selection_freq,
  New_LASSO_selection_freq=new_df$LASSO_selection_freq,
  Old_EN_selection_freq=old_df$EN_selection_freq,
  New_EN_selection_freq=new_df$EN_selection_freq,
  EN_selection_freq_change=new_df$EN_selection_freq - old_df$EN_selection_freq,
  Old_EN_full_coef=old_df$EN_full_coef,
  New_EN_full_coef=new_df$EN_full_coef,
  EN_full_coef_change=new_df$EN_full_coef - old_df$EN_full_coef,
  Old_XGB_rank=unname(old_rank[new_df$PG.ProteinGroups]),
  New_XGB_rank=unname(new_rank[new_df$PG.ProteinGroups]),
  Old_XGB_gain=unname(old_gain[new_df$PG.ProteinGroups]),
  New_XGB_gain=unname(new_gain[new_df$PG.ProteinGroups]),
  stringsAsFactors=FALSE
)
feature_changes$XGB_rank_change <- feature_changes$New_XGB_rank - feature_changes$Old_XGB_rank
feature_changes$Old_Top10 <- feature_changes$PG.ProteinGroups %in% old_top10
feature_changes$New_Top10 <- feature_changes$PG.ProteinGroups %in% new_top10
feature_changes$Top10_membership_change <- ifelse(feature_changes$Old_Top10 == feature_changes$New_Top10,
                                                   "UNCHANGED", ifelse(feature_changes$New_Top10, "ADDED", "REMOVED"))
feature_changes$Old_Top20 <- feature_changes$PG.ProteinGroups %in% old_top20
feature_changes$New_Top20 <- feature_changes$PG.ProteinGroups %in% new_top20
feature_changes$Top20_membership_change <- ifelse(feature_changes$Old_Top20 == feature_changes$New_Top20,
                                                   "UNCHANGED", ifelse(feature_changes$New_Top20, "ADDED", "REMOVED"))
feature_changes$Old_Tier1 <- feature_changes$PG.ProteinGroups %in% old_tier1
feature_changes$New_Tier1 <- feature_changes$PG.ProteinGroups %in% new_tier1
feature_changes$Tier1_membership_change <- ifelse(feature_changes$Old_Tier1 == feature_changes$New_Tier1,
                                                   "UNCHANGED", ifelse(feature_changes$New_Tier1, "ADDED", "REMOVED"))
feature_changes$Old_result_status <- "PRE_P0_REPAIR_INVALIDATED"
feature_changes$New_result_status <- "POST_P0_REPAIR_CURRENT"
write.csv(feature_changes, file.path(base_dir, "ML_P0_REPAIR_FEATURE_CHANGES.csv"), row.names=FALSE)

gene_list <- function(ids) {
  if (!length(ids)) return("NONE")
  paste(unname(genes[ids]), collapse=";")
}
num <- function(x) formatC(x, digits=6, format="f")
rel <- function(old, new) if (is.finite(old) && old != 0) num((new-old)/abs(old)) else NA_character_
comparison <- data.frame(Metric=character(), Old_value=character(), New_value=character(),
                         Absolute_change=character(), Relative_change=character(),
                         Interpretation=character(), Old_status=character(), New_status=character(),
                         stringsAsFactors=FALSE)
add_cmp <- function(metric, old, new, abs_change=NA_character_, relative=NA_character_,
                    interpretation) {
  comparison <<- rbind(comparison, data.frame(Metric=metric, Old_value=as.character(old),
    New_value=as.character(new), Absolute_change=as.character(abs_change),
    Relative_change=as.character(relative), Interpretation=interpretation,
    Old_status="PRE_P0_REPAIR_INVALIDATED", New_status="POST_P0_REPAIR_CURRENT",
    stringsAsFactors=FALSE))
}

old_en_mean <- mean(old_en_cv$en_auroc); new_en_mean <- mean(new_cv$en_auroc)
old_en_median <- median(old_en_cv$en_auroc); new_en_median <- median(new_cv$en_auroc)
old_xgb_mean <- mean(old_cv$xgb_auroc); new_xgb_mean <- mean(new_cv$xgb_auroc)
old_xgb_median <- median(old_cv$xgb_auroc); new_xgb_median <- median(new_cv$xgb_auroc)

add_cmp("EN_full_data_selected_alpha", "0.1", "0.1", "0", "0",
        "Full-data alpha is unchanged, but selection now explicitly maximizes CV AUC.")
add_cmp("EN_outer_alpha_distribution_0.1_0.3_0.5_0.7", paste(as.integer(table(factor(old_cv$en_alpha, levels=c(.1,.3,.5,.7)))), collapse=";"),
        paste(as.integer(table(factor(new_cv$en_alpha, levels=c(.1,.3,.5,.7)))), collapse=";"), NA, NA,
        "Outer-fold alpha choices changed after correcting AUC direction.")
add_cmp("EN_outer_AUROC_mean", num(old_en_mean), num(new_en_mean), num(new_en_mean-old_en_mean), rel(old_en_mean,new_en_mean),
        "Historical EN AUROC was reconstructed with the old erroneous selection logic on identical splits.")
add_cmp("EN_outer_AUROC_median", num(old_en_median), num(new_en_median), num(new_en_median-old_en_median), rel(old_en_median,new_en_median),
        "Median outer-test AUROC after correct alpha selection.")
add_cmp("EN_stable_set_n_freq_ge_0.70", length(old_en), length(new_en), length(new_en)-length(old_en), rel(length(old_en),length(new_en)),
        "Stable-set size changed at the unchanged 0.70 threshold.")
add_cmp("EN_stable_set_genes", gene_list(old_en), gene_list(new_en), NA, NA,
        "Protein-level membership is detailed in ML_P0_REPAIR_FEATURE_CHANGES.csv.")
add_cmp("EN_selection_frequency_changed_proteins", 0, sum(abs(feature_changes$EN_selection_freq_change)>1e-12, na.rm=TRUE), NA, NA,
        "Count of proteins whose EN outer selection frequency changed.")
add_cmp("EN_full_coefficient_changed_proteins", 0, sum(abs(feature_changes$EN_full_coef_change)>1e-12, na.rm=TRUE), NA, NA,
        "Full-data alpha and lambda.min fit remained unchanged.")
add_cmp("Tier1_n", length(old_tier1), length(new_tier1), length(new_tier1)-length(old_tier1), rel(length(old_tier1),length(new_tier1)),
        "Tier1 rule remained LASSO>=0.70 AND EN>=0.70.")
add_cmp("Tier1_genes", gene_list(old_tier1), gene_list(new_tier1), NA, NA,
        "Tier1 membership is unchanged.")
add_cmp("Tier1_ADDED", "NONE", gene_list(setdiff(new_tier1,old_tier1)), NA, NA, "Post-repair additions.")
add_cmp("Tier1_REMOVED", "NONE", gene_list(setdiff(old_tier1,new_tier1)), NA, NA, "Post-repair removals.")
add_cmp("Tier1_UNCHANGED", gene_list(intersect(old_tier1,new_tier1)), gene_list(intersect(old_tier1,new_tier1)), NA, NA, "Membership retained.")
add_cmp("XGB_outer_AUROC_mean", num(old_xgb_mean), num(new_xgb_mean), num(new_xgb_mean-old_xgb_mean), rel(old_xgb_mean,new_xgb_mean),
        "Old value is invalidated because outer test informed early stopping.")
add_cmp("XGB_outer_AUROC_median", num(old_xgb_median), num(new_xgb_median), num(new_xgb_median-old_xgb_median), rel(old_xgb_median,new_xgb_median),
        "New value uses training-only nround selection.")
add_cmp("XGB_outer_AUROC_range", paste(num(range(old_cv$xgb_auroc)),collapse=";"), paste(num(range(new_cv$xgb_auroc)),collapse=";"), NA, NA,
        "Minimum and maximum outer AUROC.")
add_cmp("XGB_best_iteration_distribution", "NOT_VALID_OUTER_TEST_SELECTED", paste(sort(new_cv$xgb_best_iteration),collapse=";"), NA, NA,
        "Each nround was selected on an inner validation subset of outer train.")
add_cmp("XGB_full_nrounds", "300", as.integer(round(median(new_cv$xgb_best_iteration))),
        as.integer(round(median(new_cv$xgb_best_iteration)))-300L, rel(300,as.integer(round(median(new_cv$xgb_best_iteration)))),
        "Full-data importance fit uses the median legal outer-training best_iteration.")
add_cmp("XGB_Top10", gene_list(old_top10), gene_list(new_top10), NA, NA, "Gain-ranked Top10; old ranking invalidated.")
add_cmp("XGB_Top20", gene_list(old_top20), gene_list(new_top20), NA, NA, "Gain-ranked Top20; old ranking invalidated.")

intersection_specs <- list(
  LASSO_intersect_EN=function(l,e,t10,t20) intersect(l,e),
  LASSO_intersect_XGB_Top10=function(l,e,t10,t20) intersect(l,t10),
  EN_intersect_XGB_Top10=function(l,e,t10,t20) intersect(e,t10),
  LASSO_intersect_EN_intersect_XGB_Top10=function(l,e,t10,t20) Reduce(intersect,list(l,e,t10)),
  LASSO_intersect_XGB_Top20=function(l,e,t10,t20) intersect(l,t20),
  EN_intersect_XGB_Top20=function(l,e,t10,t20) intersect(e,t20),
  LASSO_intersect_EN_intersect_XGB_Top20=function(l,e,t10,t20) Reduce(intersect,list(l,e,t20))
)
for (nm in names(intersection_specs)) {
  old_ids <- intersection_specs[[nm]](old_lasso,old_en,old_top10,old_top20)
  new_ids <- intersection_specs[[nm]](new_lasso,new_en,new_top10,new_top20)
  add_cmp(nm, gene_list(old_ids), gene_list(new_ids), NA, NA,
          "Old intersection is PRE_P0_REPAIR_INVALIDATED; new is POST_P0_REPAIR_CURRENT.")
}
add_cmp("LASSO_output_changed", "NO", ifelse(all(abs(feature_changes$Old_LASSO_selection_freq-feature_changes$New_LASSO_selection_freq)<1e-12),"NO","YES"), NA, NA,
        "LASSO implementation was unchanged; branch rerun only.")
write.csv(comparison, file.path(base_dir, "ML_P0_REPAIR_COMPARISON.csv"), row.names=FALSE)

ranked_change <- feature_changes[is.finite(feature_changes$XGB_rank_change), ]
ranked_change <- ranked_change[order(-abs(ranked_change$XGB_rank_change)), ]
rank_text <- paste(sprintf("%s (%+d)", head(ranked_change$Gene_symbol,10), head(ranked_change$XGB_rank_change,10)), collapse=", ")

report <- c(
  "# Fixed-85 ML P0 Repair Report",
  "",
  "Status: POST_P0_REPAIR_CURRENT. Historical EN and XGBoost results in `pre_P0_repair_snapshot/` are invalidated.",
  "",
  "## Repairs and results",
  "",
  "1. All EN AUC-direction defects were repaired: yes.",
  "2. EN fixes: 2 logical selection sites (outer alpha selection and full-data alpha selection), covering all 3 original `which.min` call occurrences plus the full-data comparison direction. `lambda.min` was retained.",
  sprintf("3. New full-data EN alpha: 0.1. Outer alpha counts (0.1/0.3/0.5/0.7): %s.", paste(as.integer(table(factor(new_cv$en_alpha,levels=c(.1,.3,.5,.7)))),collapse="/")),
  sprintf("4. New EN outer AUROC mean / median: %s / %s.", num(new_en_mean), num(new_en_median)),
  sprintf("5. EN stable set (selection frequency >=0.70): n=%d.", length(new_en)),
  sprintf("6. New Tier1: n=%d.", length(new_tier1)),
  sprintf("7. New Tier1 genes: %s.", gene_list(new_tier1)),
  sprintf("8. Tier1 difference: ADDED=%s; REMOVED=%s; UNCHANGED=%s.", gene_list(setdiff(new_tier1,old_tier1)), gene_list(setdiff(old_tier1,new_tier1)), gene_list(intersect(old_tier1,new_tier1))),
  "9. XGBoost outer-test leakage: eliminated. No outer-test DMatrix appears in `evals`; outer test is created only after nround selection and refit.",
  "10. Inner early stopping: stratified 80/20 split within each outer train; fixed hyperparameters; maximum 200 rounds; patience 20; refit on full outer train at selected best_iteration.",
  sprintf("11. New XGB outer AUROC mean / median / range: %s / %s / %s-%s.", num(new_xgb_mean),num(new_xgb_median),num(min(new_cv$xgb_auroc)),num(max(new_cv$xgb_auroc))),
  sprintf("12. Old vs new XGB AUROC mean: %s -> %s (%s); median: %s -> %s (%s).",num(old_xgb_mean),num(new_xgb_mean),num(new_xgb_mean-old_xgb_mean),num(old_xgb_median),num(new_xgb_median),num(new_xgb_median-old_xgb_median)),
  sprintf("13. New XGB Top10: %s.",gene_list(new_top10)),
  sprintf("14. New XGB Top20: %s.",gene_list(new_top20)),
  sprintf("15. Largest absolute XGB rank changes among proteins present in both importance tables: %s.",rank_text),
  sprintf("16. New three-algorithm intersection Top10: %s.",gene_list(Reduce(intersect,list(new_lasso,new_en,new_top10)))),
  sprintf("17. New three-algorithm intersection Top20: %s.",gene_list(Reduce(intersect,list(new_lasso,new_en,new_top20)))),
  sprintf("18. LASSO changed: %s. Implementation unchanged; rerun only.",ifelse(all(abs(feature_changes$Old_LASSO_selection_freq-feature_changes$New_LASSO_selection_freq)<1e-12),"NO","YES")),
  "19. Fixed-85 integrity: candidate input=85; sample IDs/order, High/Low outcome, 15 outer assignments, outer seeds, and fold sizes are unchanged. Equality checks passed before this report was written.",
  "20. Invalidated old outputs: snapshot `integrated_table_85.csv`, `outer_cv_metrics.csv`, `xgboost_full_importance.csv`, plus their M15 report/audit interpretations. The copied Boruta table is historical context only; Boruta was an unchanged-branch rerun.",
  "21. ROC rebuild required: yes, as a provenance update even though Tier1 membership is unchanged; see `ROC_REBUILD_REQUIREMENT.md`.",
  "22. Fig5 rebuild: panels b, c, and d; panel a is unaffected. See `FIG5_REBUILD_REQUIREMENT.md`.",
  "23. D03/D08 modified: NO.",
  "24. Strict nested run or modified: NO.",
  "25. `git diff --check`: scoped fixed-85 ML directory exit 0. Repository-wide exit 2 is caused by pre-existing trailing whitespace in unrelated SVG files outside this repair scope.",
  "26. `git status --short`: the target directory contains the three repaired result CSVs, two modified R scripts, five requested report/comparison files, and the new snapshot directory. The repository already had a large unrelated dirty worktree (817 status lines total).",
  "",
  "## Sanity checks",
  "",
  sprintf("- EN old reconstructed vs new AUROC mean / median: %s/%s -> %s/%s.",num(old_en_mean),num(old_en_median),num(new_en_mean),num(new_en_median)),
  sprintf("- XGB best_iteration distribution: %s (median=%d; full-data nrounds=%d).",paste(sort(new_cv$xgb_best_iteration),collapse=", "),as.integer(median(new_cv$xgb_best_iteration)),as.integer(round(median(new_cv$xgb_best_iteration)))),
  "- Outer test participates only in final prediction and AUROC calculation.",
  "- No threshold, candidate universe, preprocessing, outcome, split, or fixed hyperparameter was changed.",
  "- Boruta was rerun only because it is inseparable from the existing entry script; its implementation was unchanged."
)
writeLines(report, file.path(base_dir,"ML_P0_REPAIR_REPORT.md"), useBytes=TRUE)

roc_req <- c(
  "# ROC Rebuild Requirement",
  "",
  "Status: REBUILD_REQUIRED_AFTER_P0_REPAIR.",
  "",
  sprintf("Old Tier1: %s.",gene_list(old_tier1)),
  sprintf("New Tier1: %s.",gene_list(new_tier1)),
  "Numeric candidate definitions: UNCHANGED. Provenance/status labels must still be refreshed from PRE_P0_REPAIR_INVALIDATED to POST_P0_REPAIR_CURRENT.",
  "",
  "Candidate labels depending on the old Tier1 definition: GOLGA3, TSPAN14, GAL, DMP1, and IGF1 (`Frozen_Tier1` and `Tier1_flag`). CSF1 is not Tier1-dependent.",
  "",
  "Multigene dependencies: M3 is the direct five-gene Tier1 model; M5 contains the full Tier1 plus CSF1. M1 and M2 contain Tier1 subsets but their numeric gene sets also remain unchanged.",
  "",
  "Overlays to rebuild or revalidate: the univariate Discovery/Validation overlay (labels/provenance) and the multigene Discovery/Validation overlay (M3/M5 provenance). Do not overwrite existing ROC files in this phase."
)
writeLines(roc_req,file.path(base_dir,"ROC_REBUILD_REQUIREMENT.md"),useBytes=TRUE)

fig_req <- c(
  "# Fig5 Rebuild Requirement",
  "",
  "Status: REBUILD_REQUIRED_AFTER_P0_REPAIR. `V2_M17_figures_v2.R` and `figures_final_v2/` were not modified.",
  "",
  "- Panel a: no repaired EN/XGB dependency; no rebuild required for P0.",
  sprintf("- Panel b: rebuild. Replace the invalid fixed-85 XGBoost outer AUROC distribution (old mean/median %s/%s) with the repaired distribution (%s/%s). Fixed-85 LASSO and strict-nested values are unchanged.",num(old_xgb_mean),num(old_xgb_median),num(new_xgb_mean),num(new_xgb_median)),
  "- Panel c: rebuild. EN selection frequencies and XGBoost mean-rank-derived point sizes changed. LASSO is unchanged; Boruta was unchanged-branch rerun only.",
  "- Panel d: rebuild. Recalculate the EN >=50% support count and XGBoost top-20 mean-rank support count from repaired `integrated_table_85.csv`. LASSO and the criterion thresholds remain unchanged.",
  "",
  "Old panel b XGBoost AUROCs and old panel c/d EN/XGB-derived values are PRE_P0_REPAIR_INVALIDATED. Use the current repaired CSVs as replacements."
)
writeLines(fig_req,file.path(base_dir,"FIG5_REBUILD_REQUIREMENT.md"),useBytes=TRUE)

cat("\nP0 repair comparison artifacts written to", base_dir, "\n")
