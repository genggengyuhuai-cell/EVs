# V2 Pipeline Status

**Last updated:** 2026-09-27

## Freeze status

| Component | Status |
|---|---|
| Freeze 3 (Technical Contaminant Registry) | **FROZEN** |
| V2-02 Canonical Universe | **FROZEN** |
| V2-03 ML Specification v2.0 | **LOCKED** |
| V2-03 Addendum 01 (Panel Refit) | **FROZEN** |
| V2-04 ML Implementation + Fold Freeze | **READY** |
| V2-05 Primary Strategy B Result | **NOT CURRENTLY VALID** |
| Primary Discovery Model | **NOT LOCKED** |
| 129 Hold-out | **CLOSED** |
| Full-cohort v2 abundance inference | NOT STARTED |

## Canonical universes

U0=3,817 | Utech=3,809 | Q515=1,430 | D515=3,054

## Panel-refit addendum

Addendum 01 freezes the top-k panel coefficient estimation rule:
- k3/k5/k10/k20: penalized Elastic Net refit on selected features, same alpha + lambda_fraction
- untruncated: native glmnet model
- intercept-only: training prevalence
- No unpenalized glm refit

Synthetic tests 20-31: 12 PASS, 0 FAIL.