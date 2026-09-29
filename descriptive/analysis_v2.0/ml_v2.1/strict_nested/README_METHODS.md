# M15-v2.1 — Strict whole-pipeline nested sensitivity (v2.1 §7)

Protocol: `docs/protocol/ANALYSIS_PLAN_v2.1.md` §7.
Run date: 2026-09-28.
Location: `descriptive/analysis_v2.0/ml_v2.1/strict_nested/`.

## Purpose

Estimate the performance and feature stability of the complete
Discovery High-vs-Low DEP-screening → ML pipeline **without injecting the
full-Discovery locked 85-protein list**. The fixed-85 conditional analysis
(`../run_v2_1_ml.R`) asks "given the 85 known DEPs, which proteins carry
multivariable signal?"; this strict run asks "if we rediscover DEPs from
scratch inside every outer training fold, does the same signal survive, and
how stable are the selected proteins?"

## Resampling contract

- 5 outer folds × 3 repeats = **15 outer assessment splits**.
- Same seeds (`20260928`, `20260929`, `20260930`) and same stratified splitting
  as the fixed-85 conditional run, so the two are directly comparable.
- Discovery High+Low only: n=271 (High=132, Low=139). Control excluded.
- Each outer training set: ~216 samples; outer assessment: ~54 samples.

## Per-split procedure (outer train only)

1. Start from the **1434-protein quantitative universe**
   (`PRIMARY_dose_log2_expression.csv.gz`), NOT from the 85 D03 list.
2. **Fold-local eligibility**: require finite+positive detection in ≥70% of
   training High and ≥70% of training Low samples.
3. **Fold-local DEP screen**: per-protein Welch t-test High vs Low on
   training only; BH-FDR across eligible proteins; keep **BH-FDR < 0.05**.
4. **Training-only preprocessing**: median imputation → center → scale.
5. **LASSO (α=1)**: 5-fold inner CV on outer train, `type.measure="auc"`,
   choose `lambda.min`; record nonzero coefficients.
6. **Elastic Net (α ∈ {0.1, 0.3, 0.5, 0.7})**: same inner CV; pick the
   (α, λ) with highest inner CV-AUC; record nonzero coefficients.
7. Predict the **untouched outer assessment fold**.
8. Compute AUROC (pROC) and AUPRC (trapezoid on precision-recall).

## Forbidden inputs (leakage guard)

- The fixed full-Discovery 85 list (D03).
- D08 replication results, the 29 nominally replicated proteins, the 1/85
  FDR-supported protein.
- The reused 129 hold-out.
- Pathway results (M12 not yet run).
- Feature importance from the fixed-85 run.
- Boruta and XGBoost (per investigator instruction; LASSO + EN are sufficient
  for the primary whole-pipeline sensitivity).

## Output files

| File | Content |
|---|---|
| `strict_nested_outer_predictions.csv` | Per-sample predictions on outer test folds |
| `strict_nested_outer_metrics.csv` | Per-split AUROC, AUPRC, DEP counts, failures |
| `strict_nested_feature_universe_by_split.csv` | Universe / eligible / DEP counts per split |
| `strict_nested_DEP_by_split.csv` | Exact PG.ProteinGroups that passed fold-local DEP screen |
| `strict_nested_LASSO_features_by_split.csv` | LASSO nonzero features + coefficients per split |
| `strict_nested_ElasticNet_features_by_split.csv` | EN nonzero features + coefficients per split |
| `strict_nested_feature_stability.csv` | DEP appearance freq, conditional LASSO/EN selection freq |
| `strict_nested_tuning.csv` | Chosen lambda.min / alpha per split |
| `strict_nested_manifest.csv` | Protocol provenance |

## Interpretation notes

- Fold-local DEP counts vary widely (8–618 across splits) because BH-FDR
  control on ~216 training samples is noisy. This is expected and is exactly
  what the strict sensitivity is designed to expose.
- Performance degradation vs fixed-85 conditional is small (LASSO median
  AUROC 0.654 → 0.637), suggesting the fixed-85 estimates were not grossly
  inflated by selection-on-the-same-data.
- Anchor 5 proteins (TSPAN14, GAL, DMP1, IGF1, GOLGA3) all recur as
  fold-local DEPs in ≥73% of splits, but their LASSO selection frequencies
  drop compared to the fixed-85 run, especially GOLGA3 (100% → 42%).
- This run does NOT define a final panel. No composite score is computed.
