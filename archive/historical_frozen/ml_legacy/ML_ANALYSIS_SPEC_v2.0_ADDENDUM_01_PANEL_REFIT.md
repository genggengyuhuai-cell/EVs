# ML Analysis Specification v2.0 — Addendum 01: Panel-Refit Rule

**Status:** FROZEN — investigator-approved pre-holdout clarification
**Date:** 2026-09-27
**Authority:** Investigator decision under SPECIFICATION_GAP_REQUIRES_INVESTIGATOR
**Does NOT modify:** `ML_ANALYSIS_SPEC_v2.0.md` (kept unchanged)

---

## 1. Reason

The original v2.0 spec defined alpha grid, lambda grid, panel candidates k={3,5,10,20},
untruncated candidate, nested CV, and one-SE selection, but did **not** specify how
coefficients should be estimated after a top-k feature panel is selected.

This gap was discovered:
- Before any valid primary Strategy B result,
- Before any 129 hold-out evaluation,
- While debugging reporting bugs, not after inspecting model performance.

This addendum is therefore a **pre-holdout implementation clarification**, not an
outcome-driven protocol modification.

## 2. Candidate identity

For every training split, each candidate is identified by the triple:

```
(alpha, lambda_fraction, panel_type)
```

where:
- `alpha` ∈ {0.1, 0.5, 0.9, 1.0}
- `lambda_fraction` ∈ {1.0, ..., 0.001} (50 log-spaced fractions, lambda/lambda_max)
- `panel_type` ∈ {k3, k5, k10, k20, untruncated}

Total theoretical candidates per inner split: 4 × 50 × 5 = 1000.

## 3. Lambda fraction parameterization

- 50 lambda points from lambda_max → 0.001 × lambda_max, log-spaced.
- `lambda_fraction = lambda / lambda_max`
- Each training split computes its own lambda_max from the data.
- `lambda = lambda_fraction × lambda_max_split`.
- Absolute lambda from one split is never copied to another.

## 4. Full Elastic-Net selection fit

In the current training split:
1. Fold-local Mfold eligibility
2. Fold-local median imputation
3. Fold-local z-scaling
4. Fold-local zero-variance removal
5. Elastic Net fit at candidate alpha
6. Evaluate candidate lambda_fraction
7. Extract intercept, coefficients, nonzero features
8. Rank nonzero features by descending |coefficient|
9. Tie-break: PG.ProteinGroups lexical order

## 5. k=3/5/10/20 panel selection

For k ∈ {3,5,10,20}:
- `actual_panel_size = min(k, number_of_nonzero_features)`
- Take top-k from nonzero-coefficient features only.
- Do NOT pad with zero-coefficient features to reach k.
- If nonzero count = 0, candidate is intercept-only (actual size 0).

## 6. Penalized panel refit (k3/k5/k10/k20)

After selecting top-k features:
- Refit Elastic Net on ONLY those k features.
- `alpha_refit = alpha_selection` (inherited, not re-tuned).
- `lambda_fraction_refit = lambda_fraction_selection` (inherited).
- Compute `lambda_max_panel` from the k-feature training matrix.
- `lambda_refit = lambda_fraction_refit × lambda_max_panel`.
- No second tuning parameter.
- Use the SAME training-split preprocessing (medians, scaling) already fitted.
- Validation/test only apply frozen training transformation → predict.

## 7. Intercept-only candidate

If actual_panel_size = 0:
- No glm, no glmnet, no special workaround.
- `p_train = mean(y_training)`
- `intercept = qlogis(p_train)`
- Prediction = p_train for all participants.
- Save prevalence, intercept, probability.

## 8. Untruncated candidate

- Use native glmnet Elastic Net model at selected alpha + lambda_fraction.
- No top-k truncation.
- No second refit.
- Feature count has no 20-feature cap.

## 9. Prohibited

- Unpenalized `glm(family=binomial)` as panel refit (separation risk).
- Post-hoc alpha/lambda patches (e.g. "alpha=1, lambda=0.01").
- Padding zero-coefficient features to reach k.
- Using validation data for preprocessing or panel selection.

## 10. Inner CV evaluation

Each inner split evaluates all candidate identities. Record per candidate:
- alpha, lambda_fraction, panel_type, requested k
- actual panel size, selected feature IDs
- full-model absolute lambda, panel lambda_max, refit absolute lambda
- validation log loss, convergence, prediction range

## 11. One-SE selection

Unchanged from frozen spec:
1. Find minimum mean inner-CV log loss.
2. Threshold = minimum + 1 SE.
3. Among eligible candidates, follow frozen preference: smallest median panel size,
   then stronger regularization, then larger alpha, then lexical.

## 12. Outer model construction

For each frozen outer fold:
1. Inner CV selects (alpha, lambda_fraction, panel_type).
2. Refit on full outer-training:
   - Mfold eligibility, preprocessing, full Elastic Net
   - Derive panel, refit if capped, use native if untruncated
3. Predict outer-test once.
4. Outer-test never participates in any selection.

## 13. Final Discovery lock

Same pipeline on all 386 with final tuning folds, then refit on all 386.
Final manifest records: panel_type, requested_k, actual_feature_N.

## 14. Status

This addendum is FROZEN. No real Strategy B execution has used it yet.
