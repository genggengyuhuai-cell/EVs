# Candidate ROC/AUC diagnostics — Methods

**Status:** REPORTING_ONLY / DERIVED_FROM_FROZEN_OUTPUTS. No discovery rerun, no ML retraining, no frozen ml_v2.1 outputs modified.

## 1. Candidate universe
Six fixed candidates (not re-derived):

| PG ID | Gene | Role |
|---|---|---|
| Q08378 | GOLGA3 | Frozen Tier1; four-way consensus |
| Q8NG11 | TSPAN14 | Frozen Tier1; four-way consensus |
| P22466 | GAL | Frozen Tier1 |
| Q13316 | DMP1 | Frozen Tier1 |
| P05019 | IGF1 | Frozen Tier1 |
| P09603 | CSF1 | SVM-RFE-specific exploratory |

## 2. Data sources
- Abundance: `descriptive/PRIMARY_dose_log2_expression.csv.gz` (rows = protein groups, cols = 515 samples).
- Sample labels & split: `descriptive/discovery_validation_split/discovery_validation_assignment.csv`.
- Outcome: High vs Low only (controls excluded).
- Training = Discovery split (High=132, Low=139, n=271).
- Test = reused hold-out Validation split (High=44, Low=47, n=91).

## 3. Statistical implementation
- R 4.3.1; `pROC` for ROC/AUC, DeLong 95% CI.
- `direction="auto"` so AUC is reported in the favorable direction (all six proteins are DOWN_IN_HIGH; pROC flips the sign internally).
- Cutoff = Youden index on Discovery. Validation sens/spec/acc at the Discovery cutoff is the primary validation metric. Validation-optimal cutoff reported separately as "optimistic".
- Multigene: standard logistic regression (`glm`, family=binomial) on Discovery; predicted probabilities carried to Validation. No LASSO/EN/XGBoost/SVM retraining.

## 4. Multigene models (fixed)
- M1 = GOLGA3 + TSPAN14 (2-gene consensus)
- M2 = GOLGA3 + TSPAN14 + GAL (3-gene top-priority)
- M3 = GOLGA3 + TSPAN14 + GAL + DMP1 + IGF1 (5-gene frozen Tier1)
- M4 = CSF1 + GOLGA3 + TSPAN14 (3-gene SVM-sensitive)
- M5 = all 6

## 5. Boundary
These are candidate-level diagnostic ROC curves, not validated biomarkers, not clinical classifiers, not causal predictors.
