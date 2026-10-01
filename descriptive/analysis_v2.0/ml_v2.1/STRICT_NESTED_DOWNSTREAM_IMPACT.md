# Strict Nested Downstream Impact

Status: `POST_PHASE2_REPAIR_CURRENT`.

## Invalidated historical strict-nested outputs

The following pre-repair statements or summaries are invalidated because they were produced by the Welch-based mismatched discovery step:

- the old selected-feature range of 8–618;
- all old strict-nested stable-feature lists, including the ≥0.70, ≥0.80, and ≥0.93 lists;
- all old strict-nested LASSO and Elastic Net AUROC/AUPRC summaries;
- interpretations that treated the old range or stable lists as pure resampling instability under the D02 discovery method.

The historical files remain in `strict_nested_pre_repair_snapshot/` for audit only and are marked `PRE_REPAIR_NOT_INTERPRETABLE_AS_PURE_RESAMPLING_INSTABILITY`. They must not be used as current results.

## Figures and tables requiring rebuild

- Fig5 must be rebuilt if it displays or cites any old strict-nested feature counts, stability values, AUROC, or AUPRC.
- Supplementary ML panels and tables must be rebuilt wherever they display or cite those old strict-nested values.
- Rebuilds must use the current files in `strict_nested/` and must state that performance is conditional on 8 model-fit folds because 7/15 folds yielded zero features.

No figure was rebuilt in this repair-reporting step.

## Unaffected analyses

- The Phase-1 repaired fixed-85 ML analysis is unaffected by Phase 2 and was not modified or rerun.
- D03 and D08 are unaffected and were not modified.
- D02 was used as the discovery-method contract but was not modified.
- SVM-RFE is outside the repair and was not run or modified.
