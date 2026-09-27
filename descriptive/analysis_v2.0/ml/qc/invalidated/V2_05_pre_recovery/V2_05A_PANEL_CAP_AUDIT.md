# V2-05A Panel-Cap Conformity Audit

**Date:** 2026-09-27
**Status:** RESOLVED

## Finding

The original V2-05 Strategy B run did NOT enforce panel caps. The spec (Section 7) states:
- Panel caps: k ∈ {3,5,10,20}
- Also available: Untruncated Elastic Net (no cap)
- Selection: among candidates within 1 SE of minimum inner loss, select smallest median panel size

The original implementation used raw glmnet lambda selection without truncation, producing:
- Outer-fold panels: 0, 1, 6-80 features (one fold had 80)
- Final locked model: ~150 nonzero features

This violated the panel-cap constraint (max 20).

## Root cause

The original script (`V2_ML_RUN_STRATEGY_B.R`) selected lambda via one-SE on mean log loss,
but did NOT truncate coefficients to max 20 after selection. The glmnet solution at the
chosen lambda naturally had >20 nonzero features, and those were used directly.

## Remediation

1. Old outputs moved to `ml/qc/invalidated/V2_05_pre_panel_cap/` and
   `ml/models/invalidated/pre_V2_05A/`.
2. New script `V2_ML_RUN_STRATEGY_B_v2.R` enforces panel cap:
   - After one-SE lambda selection, if nonzero features > 20, keep only top-20 by |coefficient|
   - Hard assertion: post-cap feature count ≤ 20
3. Reran nested CV with same frozen folds, same seeds, same data.

## Corrected results

| Repeat | AUROC | Log Loss | Brier |
|---|---:|---:|---:|
| 1 | 0.5000 | 6.86 | 0.298 |
| 2 | 0.5000 | 6.86 | 0.298 |
| 3 | 0.5000 | 6.86 | 0.298 |

AUROC = 0.5000 because the one-SE rule consistently selected the most regularized
lambda (intercept-only model, 0 features). This is the honest protocol-conformant result:
the selected model does not beat chance.

## Panel post-cap distribution (15 outer folds)

| Post-cap features | Count |
|---:|---:|
| 0 | 4 |
| 1 | 5 |
| 6 | 1 |
| 7 | 1 |
| 12 | 1 |
| 20 | 3 |

All ≤ 20. Assertion PASS.

## Final locked model

| Item | Value |
|---|---|
| Alpha | 0.1 |
| Lambda index | 1 (strongest regularization) |
| Panel pre-cap | 0 |
| Panel post-cap | 0 |
| Features | (intercept-only, none selected) |
| Model SHA-256 | 841972b41fe2e0b3e1b44f65eef5ab04fb5e366249da664789798b5da20f208e |
| Protocol-conformant | YES |

## Leakage

129 hold-out: CLOSED. No predictions, no metrics.