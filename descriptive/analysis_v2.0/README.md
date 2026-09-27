# analysis_v2.0 — V2 Analysis Workspace

This directory contains the v2.0 analysis specification, implementation and
versioned outputs. It does not modify frozen v1.0 results.

## Current status

Do not infer execution status from this README. The only authoritative current-status
source is [`PIPELINE_STATUS.md`](PIPELINE_STATUS.md).

The frozen statistical specification is
[`ml/ML_ANALYSIS_SPEC_v2.0.md`](ml/ML_ANALYSIS_SPEC_v2.0.md). It describes what must
be implemented and is not an execution log.

## Directory guide

- `config/*.md`: configuration and provenance specifications; documentation, not R code.
- `registry/`: frozen contaminant registry and supporting audit.
- `contracts/`: input, universe and output contracts.
- `universes/`: frozen Utech, Q515 and D515 artifacts.
- `ml/code/V2_ML_RUN_STRATEGY_B.R`: the only future primary Strategy B runner.
- `ml/code/archive_invalidated/`: historical nonconforming runners retained for audit.
- `ml/folds/`: frozen Discovery CV assignments.
- `ml/qc/`: current recovery QA and crosswalk.
- `ml/qc/invalidated/`: superseded ML QA claims.
- `ml/models/invalidated/`: invalidated historical model artifacts.
- `ml/results/invalidated/`: exploratory protocol-nonconforming historical results.

## Authority hierarchy

1. `docs/protocol/ANALYSIS_PLAN_v2.0.md`
2. `ml/ML_ANALYSIS_SPEC_v2.0.md`
3. `PIPELINE_STATUS.md` for current execution state
4. Current implementation and QA artifacts

The 129-person reused within-cohort hold-out remains closed until a valid primary
model lock exists and evaluation is separately authorized.
