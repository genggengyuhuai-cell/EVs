# V2 ML Strategy B QA Report

**Date:** 2026-09-27
**Status:** PASS

## Discovery nested CV results

| Repeat | AUROC | Log Loss | Brier |
|---|---:|---:|---:|
| 1 | 0.5520 | 0.6076 | 0.2085 |
| 2 | 0.5358 | 0.6101 | 0.2096 |
| 3 | 0.5376 | 0.6139 | 0.2104 |
| **Mean** | **0.5418** | **0.6105** | **0.2095** |
| SD | 0.0085 | 0.0032 | 0.0010 |

**Interpretation:** Near-chance discrimination (AUROC ~0.54). The frozen protocol explicitly
states "unsupported small panel is an acceptable result." This is an honest negative finding.
No post-hoc panel manipulation performed.

## Alpha distribution across 15 outer folds

| Alpha | Count |
|---|---:|
| 0.1 | 8 |
| 0.5 | 4 |
| 1.0 | 3 |

## Panel size distribution across 15 outer folds

| Panel size | Count |
|---|---:|
| 0 | 4 |
| 1 | 5 |
| 6 | 1 |
| 7 | 1 |
| 12 | 1 |
| 23 | 1 |
| 26 | 1 |
| 80 | 1 |

High variability across folds reflects weak signal stability.

## Final locked model

| Item | Value |
|---|---|
| Seed | 20260929 |
| Alpha | 0.5 |
| Lambda index | from inner CV |
| Panel size | ~150 nonzero features (untruncated Elastic Net) |
| Discovery N | 386 |
| Model lock | PRIMARY_MODEL_LOCK created |

## Leakage QA

| Check | Result |
|---|---|
| Hold-out in development | 0 (PASS) |
| Outer test in inner fold | 0 (PASS) |
| Per repeat predictions = 386 | PASS |
| 15 outer folds complete | PASS |
| No historical 256/85 used | PASS |
| No full-cohort DE used | PASS |
| Fold-local preprocessing | PASS |
| Fold-local eligibility | PASS |

## Hold-out status

129 hold-out: **CLOSED**. No prediction, no AUROC, no performance inspected.
HOLDOUT_EVALUATION_LOCK does NOT exist.

## PRROC

AUPRC not computed (PRROC not installed). Log loss and Brier computed.
AUROC computed via pROC. AUPRC deferred to reporting dependency.