# V2 ML Fold QA Report

**Date:** 2026-09-27
**Status:** FOLDS FROZEN

## Discovery cohort

| Metric | Value |
|---|---:|
| Total Discovery | 386 |
| Control | 115 |
| Exposure (Low+High) | 271 |
| Low | 139 |
| High | 132 |
| Hold-out (Validation) | 129 |

## Stratification

Stratified by Environment × Group within each repeat.
All 6 strata represented: Humid-hot/Control, Humid-hot/Low, Humid-hot/High,
High-altitude/Control, High-altitude/Low, High-altitude/High.

## Outer folds

| Parameter | Value |
|---|---|
| Outer folds | 5 |
| Repeats | 3 |
| Seeds | 20260926, 20260927, 20260928 |
| Outer rows generated | 1,158 (386 × 3) |

Each repeat covers all 386 Discovery participants exactly once per outer fold.
No hold-out participant appears in any outer fold.
Outer test sets are disjoint; union = 386.

## Inner folds

| Parameter | Value |
|---|---|
| Inner folds per outer fold | 5 |
| Inner seed derivation | deterministic from (repeat, outer_fold) |
| Inner rows generated | 5,790 |

Inner folds are nested within outer-training participants.
Outer test participants are marked as "outer_test" with no inner fold assignment.
No outer-test participant appears in any inner fold.

## Leakage QA

| Check | Result |
|---|---|
| Hold-out in outer folds | 0 (PASS) |
| Outer test in inner folds | 0 (PASS) |
| Duplicate participant in fold | 0 (PASS) |
| Each participant in exactly 1 outer test per repeat | PASS |
| Class presence in each fold | Control + Exposure present (PASS) |

## Synthetic unit tests

| Test | Result |
|---|---|
| Median imputer training-only | PASS |
| Scaler training-only | PASS |
| Zero-variance removal | PASS |
| Fold-local eligibility threshold scales with N | PASS |
| Hold-out leakage guard fires | PASS |
| Fold disjoint guard fires | PASS |
| Deterministic seed reproducibility | PASS |
| One-SE rule deterministic | PASS |
| Panel cap enforcement | PASS |
| Forbidden historical path guard | PASS |

Note: 4 "FAIL" entries in test output are the expected guard-firing cases
(the guards correctly stop execution on bad input). All guards verified working.

## Fold manifest

SHA-256 hashes recorded in `manifests/V2_ML_FOLD_MANIFEST.csv`.
**Fold status: FROZEN.** No re-randomization allowed.