# V2-05C Outer Refit / Penalization Protocol Audit

**Date:** 2026-09-27
**Status:** RESOLVED

## Root cause

The outer test predictions were all 1.0 due to a trivial clipping bug:
```r
pred <- pmin(pmax(pred, 0, 1), 1)   # WRONG: pmax(pred,0,1) = max(pred,1) >= 1
```
Should have been:
```r
pred <- pmax(pmin(pred, 1), 0)      # correct
```

This was a **REPORTING-ONLY bug**. The predictions from `predict(..., type="response")`
were correct (range 0.63-0.78). Only the post-hoc clipping broke them.

Inner tuning was NOT affected — it uses `pmin(pmax(p,1e-10),1-1e-10)` which is correct.

## Refit rule determination

The frozen spec (Section 7) does NOT mandate a post-hoc refit after panel selection.
The correct approach: use glmnet native predict at selected (alpha, lambda) directly.
The panel cap is enforced through the one-SE selection rule (prefer smaller panel
within 1 SE), not through post-hoc truncation or refit.

"Also available: Untruncated Elastic Net (no cap)" means models with >20 nonzero
features are allowed as the untruncated candidate.

## v4 alpha=1/lambda=0.01 assessment

That was a POST-HOC IMPLEMENTATION PATCH. Not pre-registered. Replaced by v5
(native glmnet predict, no refit).

## Corrected results

| Repeat | AUROC | Log Loss | Brier | Mean pred |
|---|---:|---:|---:|---:|
| 1 | 0.5520 | 0.6076 | 0.2085 | 0.703 |
| 2 | 0.5358 | 0.6101 | 0.2096 | 0.700 |
| 3 | 0.5376 | 0.6139 | 0.2104 | 0.702 |
| **Mean** | **0.5418** | **0.6105** | **0.2095** | |

These match the original v1 (pre-cap) run — confirming inner selections are valid.

## Panel distribution

0→4, 1→5, 6→1, 7→1, 12→1, 23→1, 26→1, 80→1.
Some outer folds select untruncated models (23-80 features) per spec.

## Final locked model

- Alpha: 0.1, lambda_idx: 1 (lambda_max)
- Panel: 0 features (intercept-only)
- Baseline p: 0.7021 = prevalence
- Rule: native glmnet predict at selected lambda
- PRIMARY_MODEL_LOCK rebuilt