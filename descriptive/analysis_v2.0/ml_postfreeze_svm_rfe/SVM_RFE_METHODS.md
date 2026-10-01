# SVM-RFE Methods (Post-Freeze Exploratory)

**Analysis_status:** POST_FREEZE_EXPLORATORY
**Input_universe:** 85 locked D03 Discovery DEPs (identical to ml_v2.1 fixed-85 branch)
**Frozen_models_modified:** NO
**Existing_frozen_results_recomputed:** NO

This analysis is a post-freeze sensitivity layer. It does NOT modify
`descriptive/analysis_v2.0/ml_v2.1/`, does NOT redefine the frozen Tier-1 set,
and does NOT constitute a new primary result.

---

## 1. Input contract

| Item | Value | Source |
|---|---|---|
| Candidate universe | 85 locked D03 Discovery DEPs | `descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv` |
| Expression matrix | PRIMARY_dose_log2_expression.csv.gz, 1434 × 515 | identical to ml_v2.1 |
| Outcome | High (y=1, n=132) vs Low (y=0, n=139); controls excluded | identical to ml_v2.1 |
| Sample count | 271 Discovery High+Low | identical to ml_v2.1 |
| Preprocessing | median imputation → center → scale, fit on outer train only | identical to ml_v2.1 |

`N_input = 85` (verified; `stopifnot(nrow(d03) == 85)`).

## 2. Outer resampling (exact reproduction of ml_v2.1)

- 5 outer folds × 3 repeats = **15 outer assessment splits**.
- Seeds: `20260928`, `20260929`, `20260930`; stratified within High and Low.
- Fold construction code is copied verbatim from `run_v2_1_ml.R` lines 95–107.
- The same 15 test folds are used by LASSO / EN / XGBoost in the frozen run,
  so SVM-RFE outer predictions are directly comparable.

## 3. SVM-RFE algorithm

- **Kernel:** linear (per spec; linear weights are directly interpretable).
- **Implementation:** `e1071::svm` with `kernel="linear", type="C-classification"`.
- **Weight extraction:** `w = t(coefs) %*% SV`, i.e. the standard primal linear
  SVM weight vector from dual coefficients and support vectors.
- **RFE ranking criterion:** `w^2` (Guyon et al. 2002).
- **Elimination schedule:** per iteration, remove the weakest 25% of remaining
  features (minimum 1); stop at 1. The last surviving feature is rank 1.

## 4. Inner CV (leakage-free hyperparameter + subset-size selection)

For each outer training fold:

1. 5-fold stratified inner CV on the outer training data.
2. Candidate C grid: **{0.1, 1, 10}**.
3. Candidate subset sizes: **{1, 2, 3, 5, 10, 15, 20, 30, 40, 60, 85}**.
4. For each C, run RFE on the outer train to obtain a best-first feature
   ranking; then evaluate inner-CV AUROC at each subset size.
5. Pick (C, subset_size) maximizing mean inner-CV AUROC; **1-standard-error
   tie-break to the smaller subset size**.
6. Retrain the final linear SVM on the full outer training set with the chosen
   C and chosen subset size; predict the untouched outer test fold.

The outer test fold never participates in C selection, ranking, or subset-size
choice. No full-data SVM-RFE is run.

## 5. Output metrics

Per outer fold: `chosen_C`, `chosen_subset_size`, `inner_best_auc`,
`auroc` (pROC), `auprc` (trapezoid on precision-recall).

Feature stability across 15 outer folds:

- `selection_count` = number of outer folds in which the protein was selected.
- `selection_frequency` = `selection_count / 15`.

## 6. Reporting-aligned descriptive thresholds

These are **DESCRIPTIVE_SENSITIVITY_THRESHOLDS**, not pre-registered cutoffs:

- `SVM_RFE_REPORTED_STABLE_SET` = `selection_frequency >= 0.70`
  (reporting-aligned with LASSO/EN; descriptive comparison only).
- Supplementary: `>= 0.80`, `>= 0.93`.

No threshold was chosen to make the intersection with frozen sets "look good".

## 7. Feature importance

The final linear SVM weight magnitude `|w|` from the outer-train refit is the
SVM-RFE importance. The RFE elimination order is the feature ranking. Both are
recorded per fold in `svm_rfe_fold_selected_features.csv`; the cross-fold
aggregation is `selection_frequency`.

## 8. Files

| File | Content |
|---|---|
| `run_svm_rfe.R` | Self-contained R script |
| `svm_rfe_outer_metrics.csv` | Per-fold C, subset size, inner AUROC, outer AUROC/AUPRC |
| `svm_rfe_feature_stability.csv` | Per-protein selection count / frequency across 15 outer folds |
| `svm_rfe_fold_selected_features.csv` | Long table of selected features per outer fold |
| `svm_rfe_intersection_summary.csv` | Set sizes and gene lists vs frozen sets |
| `svm_rfe_intersection_proteins.csv` | Per-protein join of SVM-RFE + frozen flags |
| `SVM_RFE_AUDIT.md` | This audit |
| `SVM_RFE_METHODS.md` | This methods doc |
