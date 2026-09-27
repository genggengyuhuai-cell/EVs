# V2 Pipeline Status

**Last updated:** 2026-09-27

## Freeze status

| Component | Status |
|---|---|
| Freeze 3 (Technical Contaminant Registry) | **FROZEN** — investigator approved 2026-09-26 |
| V2-02 Canonical Universe | **FROZEN** — V2-02B rebuild passed all QA gates |
| V2-03 ML Specification | **LOCKED** |
| V2-04 ML Implementation + Discovery Fold Freeze | **READY** — folds frozen, code architecture implemented |
| V2 inferential abundance | NOT STARTED |
| ML model execution (nested CV) | NOT STARTED |
| Final Discovery model lock | NOT LOCKED |
| 129 hold-out evaluation | NOT STARTED |

## Canonical universe counts

| Universe | N |
|---|---:|
| U0 | 3,817 |
| Utech_primary | 3,809 |
| Q515 | 1,430 |
| D515 | 3,054 |

## ML status

| Item | Status |
|---|---|
| Fold assignments (outer + inner) | FROZEN |
| Fold manifest | Written (SHA-256 recorded) |
| Common helpers + leakage guards | Implemented |
| Data prep functions | Implemented |
| Nested CV function architecture | Implemented (not executed) |
| Final model lock guard | Implemented (not executed) |
| Hold-out evaluation guard | Implemented (not executed) |
| Synthetic unit tests | 10/10 verified |
| PRROC package | NOT INSTALLED (dependency gap) |

## Next authorized step

Execute nested CV on Discovery 386 per `ml/ML_ANALYSIS_SPEC_v2.0.md`.
This requires installing PRROC or implementing project-local AUPRC.