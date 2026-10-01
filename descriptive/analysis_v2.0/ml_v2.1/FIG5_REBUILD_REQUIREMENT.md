# Fig5 Rebuild Requirement

Status: REBUILD_REQUIRED_AFTER_P0_REPAIR. `V2_M17_figures_v2.R` and `figures_final_v2/` were not modified.

- Panel a: no repaired EN/XGB dependency; no rebuild required for P0.
- Panel b: rebuild. Replace the invalid fixed-85 XGBoost outer AUROC distribution (old mean/median 0.710294/0.686813) with the repaired distribution (0.648769/0.657967). Fixed-85 LASSO and strict-nested values are unchanged.
- Panel c: rebuild. EN selection frequencies and XGBoost mean-rank-derived point sizes changed. LASSO is unchanged; Boruta was unchanged-branch rerun only.
- Panel d: rebuild. Recalculate the EN >=50% support count and XGBoost top-20 mean-rank support count from repaired `integrated_table_85.csv`. LASSO and the criterion thresholds remain unchanged.

Old panel b XGBoost AUROCs and old panel c/d EN/XGB-derived values are PRE_P0_REPAIR_INVALIDATED. Use the current repaired CSVs as replacements.
