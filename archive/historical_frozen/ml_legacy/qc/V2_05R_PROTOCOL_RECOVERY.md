# V2-05R Primary ML Protocol Recovery QA

**Date:** 2026-09-27  
**Current outcome:** `SPECIFICATION_GAP_REQUIRES_INVESTIGATOR`  
**Authoritative status:** `descriptive/analysis_v2.0/PIPELINE_STATUS.md`

## Recovery decision

The frozen specification requires real `k=3,5,10,20` and untruncated candidates,
but does not define how coefficients are estimated after top-k feature selection.
Coefficient truncation, penalized refitting and unpenalized refitting are different
models. V2-05R therefore stopped before implementing or running those models, as
required by the recovery instruction.

The implementation is fail-closed and is not ready for real Strategy B execution.

## Required QA answers

1. **Unique Strategy B runner:** `ml/code/V2_ML_RUN_STRATEGY_B.R`.
2. **Archived invalidated runners:** five, under `ml/code/archive_invalidated/`.
3. **Lambda grid:** implemented explicitly as 50 decreasing log-spaced values from
   training-split `lambda_max` to `0.001 × lambda_max`, with hard assertions.
4. **3/5/10/20/untruncated candidates:** identities and deterministic feature ranking
   are defined, but candidate fitting is deliberately blocked because the refit rule
   is absent from the frozen specification.
5. **One-SE:** deterministic selector is implemented for real candidate result tables;
   it records the minimum candidate, boundary and eligible candidates. Real panel-model
   input is blocked.
6. **Final tuning:** training-only preprocessing helpers and structural invariance test
   are present. Full final tuning is not executable until the panel rule is frozen.
7. **Automated tests:** total 19, PASS 19, FAIL 0, process exit code 0.
8. **Artifact contract:** active names are
   `strategyB_primary_model.rds`, `strategyB_model_manifest.csv`, and
   `PRIMARY_MODEL_LOCK` under `ml/models/`.
9. **SHA contract:** model/manifest/lock model-SHA equality is implemented and tested.
   No active artifacts exist, so there is no current valid SHA set. Future provenance
   must also record spec, code, folds and participant hashes before a valid lock.
10. **Current primary model:** NOT LOCKED. Historical artifacts are retained only under
    `ml/models/invalidated/V2_05_protocol_audit_2026-09-27/`.
11. **AUROC 0.5418:** EXPLORATORY / PROTOCOL-NONCONFORMING; not a primary result.
12. **129 hold-out:** CLOSED / NOT EVALUATED. The runner rejects execution with
    `NO VALID PRIMARY_MODEL_LOCK`.
13. **Status documents:** `PIPELINE_STATUS.md` is the sole current-status source;
    README is navigation-only; the frozen ML specification was not edited.

## Config-file classification

| Original | Classification | Action |
|---|---|---|
| `v2_config.R` | Documentation | Renamed `v2_config.md`; invalid source instruction removed. |
| `v2_no_overwrite.R` | Documentation | Renamed `v2_no_overwrite.md`. |
| `v2_provenance.R` | Documentation | Renamed `v2_provenance.md`; references updated. |

## Paused work

- Strategy A: not run.
- LASSO/SVM-RFE/RF/XGBoost/Boruta/GBDT secondary analyses: not run.
- Full-cohort abundance, ordered/IUT, omnibus, pairwise, detection, environment,
  site and pathway inference: not run.
- Nature-style v1 reporting additions were recorded only in the audit backlog.

## Investigator decision required

Freeze exactly one top-k panel coefficient-estimation policy, including its inner-fold
training behavior and final all-Discovery fit behavior. Only then can real panel
candidates, complete final fold-local tuning and execution-readiness tests be built.

## Execution boundary confirmation

- No real ML model was executed.
- No new AUROC was generated.
- No 129 hold-out result was inspected.
- No full-cohort biological inference was run.
- Frozen ML specification and frozen CV folds were unchanged.
- Frozen historical v1 results were unchanged.
- No push was performed.
