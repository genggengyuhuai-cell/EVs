# V2 ML Analysis Specification v2.0

**Status:** LOCKED — pre-registered implementation specification
**Date:** 2026-09-27
**Authority:** Derived from `docs/protocol/ANALYSIS_PLAN_v2.0.md` Module 15–16
**No model has been run. No AUROC/AUPRC result exists.**

---

## 1. Prediction target

### Primary task
- **Target:** Control vs Exposure (combined Low + High)
- **Positive class:** Exposure (Low or High)
- **Negative class:** Control
- **Discovery distribution:** Control=115, Exposure=271 (total 386)
- **Hold-out distribution:** Control=38, Exposure=91 (total 129)

### Secondary tasks (prespecified, not primary)
| Task | Discovery N (neg/pos) | Hold-out N (neg/pos) | Positive class |
|---|---|---|---|
| Control vs Low | 115/139 | 38/47 | Low |
| Control vs High | 115/132 | 38/44 | High |
| Low vs High | 139/132 | 47/44 | High |
| Three-class (exploratory) | 115/139/132 | 38/47/44 | N/A |

No class weighting, SMOTE, or undersampling. No Random Forest or gradient boosting in this version.

---

## 2. Participant split (frozen, immutable)

| Split | N | Role |
|---|---:|---|
| Discovery | 386 | All model development: nested CV, feature selection, hyperparameter tuning, final lock |
| Reused hold-out | 129 | ONE evaluation only, AFTER final Discovery model lock |

The 129 is a **reused within-cohort hold-out**. It has prior analytical use (D08–D10).
It must NEVER be described as:
- External validation
- Untouched validation
- Independent external cohort

It MUST be described as: reused within-cohort hold-out evaluation.

### Hold-out is strictly off-limits during development
- No hold-out used for preprocessing
- No hold-out used for feature eligibility
- No hold-out used for feature selection
- No hold-out used for hyperparameter tuning
- No hold-out used for threshold selection
- No hold-out AUROC/AUPRC inspected before model lock

---

## 3. Feature universe

### Mfold (fold-local eligibility)
- Start from Utech_primary (3,809)
- Within each training fold, a protein is eligible if it meets ≥70% detection
  in EACH relevant original Group (Control, Low, High) computed on that fold's training participants only
- All-missing or zero-variance features are removed based on training fold only
- Mfold is RECOMPUTED in every training split — never subset from canonical Q515
- Canonical Q515=1430 is the biological universe, NOT the ML feature set

### Strategy B (primary)
- No DE preselection
- All Mfold quantitative features enter Elastic Net
- Feature selection happens via Elastic Net penalty within nested CV

### Strategy A (secondary comparison)
- Same Mfold universe
- Fold-local limma screen at BH-FDR < 0.10
  - Primary task: three-group model, weighted E contrast using fold-training Low/High proportions
  - Secondary tasks: screen their pairwise contrast
- Screening uses ONLY the outer-training fold; inner folds and outer test fold are excluded
- Empty screen → intercept-only prediction
- Historical 85-candidate list and historical 256 DEP are NOT used as feature screens
- Detection features are NOT part of primary panel (require separate amendment)

---

## 4. Fold-local preprocessing (every training fold)

1. **Eligibility:** Recompute Mfold on training participants only
2. **Median imputation:** Replace missing values with training-fold protein median
   - Median computed on training fold only
   - Validation/test fold uses training-derived median
3. **Z-scaling:** center and scale using training-fold mean and SD
   - Validation/test fold uses training-derived parameters
4. **Zero-variance removal:** Remove features with zero variance in training fold
5. **Strategy A screening (if applicable):** limma BH<0.10 on training fold only

**Absolute prohibitions:**
- Do NOT preprocess the full 386 before CV split
- Do NOT use hold-out data in any preprocessing step
- Do NOT fit ComBat/quantile normalization on combined Discovery+hold-out
- Do NOT learn the log2 transform (it is fixed)

---

## 5. Nested CV structure

| Parameter | Value |
|---|---|
| Outer folds | 5 |
| Inner folds | 5 |
| Outer repeats | 3 |
| Outer seeds | 20260926, 20260927, 20260928 |
| Inner seed derivation | Deterministic from (repeat_id, outer_fold_id) |
| Stratification | Within Environment × Group strata |

- Participant IDs assigned once per repeat within strata
- No seed search
- Inner CV selects hyperparameters within each outer training fold
- Outer test fold never participates in inner tuning

### Fold assignment table
Must output `folds/fold_assignments.csv` with columns:
participant_id, repeat_id, outer_fold, inner_fold, group, environment

---

## 6. Elastic Net hyperparameter grid

| Parameter | Value |
|---|---|
| Model | Elastic Net logistic regression (glmnet) |
| Alpha values | {0.1, 0.5, 0.9, 1.0} |
| Lambda | 50 log-spaced values from lambda_max to 0.001×lambda_max |
| lambda_max | Computed separately in each training set |
| Inner selection metric | Mean log loss (deviance) |

For each outer fold × repeat, the full grid is evaluated in inner CV.

---

## 7. Panel-size constraint

| Parameter | Value |
|---|---|
| Panel caps | k ∈ {3, 5, 10, 20} |
| Also available | Untruncated Elastic Net (no cap) |
| Selection rule | Among candidates within 1 SE of minimum inner mean loss, select smallest median fitted panel size |
| Tie-break 1 | Stronger regularization (larger lambda fraction) |
| Tie-break 2 | Larger alpha |
| Tie-break 3 | Lexical parameter order |
| Protein tie-break | Documented assay-feasibility tier (if frozen), otherwise lexical ID |

No manual post-CV panel substitution.
If fewer than k features are supported, smaller panel is used honestly.

---

## 8. Performance metrics

| Metric | Role |
|---|---|
| AUROC | Primary discrimination metric |
| AUPRC | Reporting metric (not tuning) |
| Calibration intercept/slope | Reporting metric |
| Brier score | Reporting metric |
| Mean log loss | Inner CV tuning metric |

For each repeat: one outer-held-out prediction per participant, then average repeat-level metrics.
Internal bootstrap: 2,000 participant bootstrap replicates stratified by original Group.

---

## 9. Final Discovery model lock

| Parameter | Value |
|---|---|
| Data | All 386 (or relevant secondary-task subset) |
| Inner CV | Same 5-fold structure |
| Lock seed | 20260929 |
| Locked outputs | Exact protein IDs/order, imputer/scaler params, coefficients, intercept, alpha, lambda, panel size, threshold rule |

No post-lock feature substitution.
No arbitrary missingness abstention threshold.
Only the locked pipeline proceeds to hold-out evaluation.

---

## 10. Reused 129 hold-out evaluation (one-time only)

| Parameter | Value |
|---|---|
| Data | Frozen 129 hold-out |
| Input | Locked feature list, no refitting |
| Bootstrap replicates | 2,000 |
| Bootstrap seed | 20260930 |
| Metrics | AUROC, AUPRC, sensitivity, specificity, balanced accuracy, PPV, NPV, F1, confusion, calibration intercept/slope, Brier |
| Calibration | Five bins, cutpoints from Discovery cross-fitted probabilities |

**Prohibitions at hold-out:**
- No threshold tuning
- No feature reselection
- No recalibration (evaluate but do not update)
- No looking at results then re-running Discovery
- No using hold-out to choose between Strategy A and B

---

## 11. Additional required analyses

- Environment-only benchmark (predict from Environment label alone)
- Intercept-only baseline
- Strategy A comparison (prespecified, not post-hoc replacement for B)
- LOO predictive robustness (Discovery leave-one-out)
- Selection frequency, sign consistency, coefficient distribution across 15 outer fits

---

## 12. Implementation architecture

```
ml/
├── ML_ANALYSIS_SPEC_v2.0.md   (this file)
├── ML_LEAKAGE_CHECKLIST.md
├── ML_DEPENDENCY_AUDIT.md
├── code/
│   ├── V2_ML_01_prepare.R      (load data, split, fold assignment)
│   ├── V2_ML_02_nested_cv.R    (nested CV loop)
│   ├── V2_ML_03_lock_model.R   (final Discovery lock)
│   └── V2_ML_04_holdout_eval.R (one-time 129 evaluation)
├── folds/                      (fold assignment CSVs)
├── models/                     (locked model objects)
├── results/                    (CV metrics, panel tables)
├── qc/                         (leakage checks, assertions)
└── manifests/                  (provenance)
```