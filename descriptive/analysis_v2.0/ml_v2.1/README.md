# ml_v2.1 — README

## Module
Machine-learning analysis on the frozen 85 candidate set (fixed-85) plus a strict-nested
discovery-stability diagnostic.

## Purpose
Conditional discrimination of High vs Low using the already-locked 85 Discovery candidates, and
a strict fold-local differential-screening + nested sensitivity to assess discovery-to-model
pipeline stability.

## Status
ACTIVE_COMPLETE (module frozen; reporting contract governs wording).

## Inputs
- Frozen 85-candidate set; Discovery High-vs-Low subset (n=271).

## Active Code
- `run_v2_1_ml.R` (fixed-85), `strict_nested_sensitivity.R`, `strict_nested_d02_helpers.R`,
  `summarize_results.R`, `summarize_tiers.R`

## Final Outputs (source of truth)
- `results/` — `outer_cv_metrics.csv`, `integrated_table_85.csv`, Boruta/XGBoost importance
- `strict_nested/` — fold-local tables, `README_METHODS.md`

## Key Results
- Fixed-85: repeated outer CV (5-fold x 3 repeats = 15 folds), nested tuning, no outer-test
  early-stopping leakage. Elastic Net mean AUROC 0.668688 / median 0.662088; XGBoost mean
  0.648769 / median 0.657967 / range 0.508598-0.786325. Tier1 (selection stability): GAL,
  TSPAN14, DMP1, IGF1, GOLGA3.
- Strict nested: 15 outer folds; 7/15 zero-feature; 8/15 evaluable; feature count 0/0/3/59/536;
  stable appearance >=0.70: NONE.

## Statistical Contract
Per `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` (section 9) — conditional-on-85, NOT
external validation, framing "modest".

## Limitations
- Fixed-85 is conditional discrimination, not unbiased pipeline/clinical/diagnostic performance.
- Strict-nested instability is resampling sensitivity, not biological heterogeneity.
- Python/ML execution environment NOT_LOCATED / TO_CONFIRM (see `docs/LIMITATIONS.md`).

## Do Not Use
- Do not call ML "external validation", "diagnostic performance", or "validated biomarker panel".
- Do not report "nested AUROC across 15 folds" (7/15 had no model fit).

## Reproducibility
R scripts deterministic under frozen R (see `docs/SOFTWARE_ENVIRONMENT_LOCK.md`); Python env gap
disclosed.

## Next Step
See `docs/NEXT_STEPS.md` (provenance lock; manuscript ML wording).
