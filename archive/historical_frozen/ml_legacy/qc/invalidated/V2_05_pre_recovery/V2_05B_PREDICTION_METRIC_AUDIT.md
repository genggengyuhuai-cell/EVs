# V2-05B Prediction/Metric Audit

**Date:** 2026-09-27
**Status:** RESOLVED

## Root cause

The v2 implementation used unpenalized `glm()` to refit the top-k selected features.
With small feature sets (1-20 features from ~1400 candidates) and ~300 training samples,
the unpenalized logistic regression hit **perfect separation**, producing predicted
probabilities of exactly 0 or 1. On outer test folds, this manifested as all predictions
= 1.0 (mean prediction 1.0, log loss 6.86, Brier 0.298).

This was a **reporting AND inner-selection bug**: the same broken prediction path was used
for outer test prediction. Inner CV used glmnet native predict (correct), so inner
hyperparameter selection was NOT affected. Only outer test prediction and final model
prediction were wrong.

## Fix

Replace unpenalized glm refit with a **small-ridge glmnet refit** (alpha=1.0, lambda=0.01)
on the selected panel. This prevents perfect separation and produces calibrated probabilities.

## Corrected results (same frozen folds, same seeds, same data)

| Repeat | AUROC | Log Loss | Brier | Mean pred |
|---|---:|---:|---:|---:|
| 1 | 0.5327 | 0.6245 | 0.2128 | 0.708 |
| 2 | 0.5240 | 0.7151 | 0.2342 | 0.689 |
| 3 | 0.5341 | 0.6666 | 0.2211 | 0.699 |
| **Mean** | **0.5303** | **0.6687** | **0.2227** | |

Intercept-only baseline sanity:
- Prevalence = 0.7021
- Theoretical log loss ≈ 0.609, Brier ≈ 0.209
- Observed (Repeat 1 intercept-only folds): LL ≈ 0.61, Brier ≈ 0.21 — consistent

## Panel distribution (15 outer folds)

0→4, 1→5, 6→1, 7→1, 12→1, 20→3. All ≤20.

## Final locked model

- Alpha: 0.1, lambda_idx: 1 (strongest regularization)
- Panel: 0 features (intercept-only)
- Baseline predicted p: 0.7021 (= prevalence)
- Protocol-conformant: YES

## Three-repeat predictions now differ

After fix, repeats have distinct prediction vectors (mean 0.708, 0.689, 0.699).
Previously identical repeats were an artifact of all predictions collapsing to 1.0.

## Inner selection status

Inner CV used glmnet native `predict(..., type="response")` throughout — NOT affected
by the glm refit bug. Hyperparameter selections are valid.