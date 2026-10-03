# Master project audit backlog

## Current audit state

Analytical pipeline version: **v1.0**. Status: **FROZEN**.

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
MISSINGNESS / IMPUTATION ROBUSTNESS ANALYSIS: COMPLETED
```

For actual dependency safety, Stage 09 must run before 08d because 08d consumes its
results; numbering does not imply adjacent dependencies. `descriptive/RUN_ORDER.md`
contains the exact manual sequence.

Reasonable regression checks and downstream derivations are not competing sources of
truth and should not be removed merely to eliminate duplicated calculations.

There are no remaining validation items for the v1.0 freeze. Stages 01–12 constitute
the frozen v1.0 analytical pipeline. Modification requires a verified scientific or
software bug, explicit authorization, a version increment, affected-stage
revalidation, and end-to-end reproducibility when required. Cosmetic cleanup, code
deduplication, refactoring, warning suppression, or style improvement alone is not a
sufficient reason to modify frozen source. New biological analyses should
preferentially be implemented as downstream modules.

## Completed downstream methodological audit

Missingness / imputation robustness is **COMPLETED** in
`descriptive/missingness_robustness/`. It is a post-freeze module, not a new pipeline
stage and not a competing source of truth. D0 exactly reproduced the frozen 256 DEP.
D1 showed substantial distortion from direct zero replacement. D2 retained 227/256
canonical DEP; its 29 losses kept their negative effect direction, had median absolute
delta-logFC approximately 0.040, and none had an absolute change of at least 0.5.
D2 therefore primarily reflects significance sensitivity. D3 retained 254/256 with
100% canonical direction concordance and 256/256 pattern retention. The missingness
mechanism is not claimed as proven, KNN is not designated the best method, and the
canonical 256 are not redefined.

All seven canonical `Long_suppression` proteins (NRP1, IL7R, ICAM3, BGN, RARRES2,
HSP90AB1, and CSF1R) are completely observed, remain invariant and significant under
D0–D3, and were independently assigned to Stage 11b C3.

## Immediate next analytical task

Build the canonical 256-DEP master biological characterization table integrating
primary statistics, Control/Short/Long profiles, Stage 11a pattern, Stage 11b cluster,
and missingness-robustness flags. This work has not begun.

## Future manuscript reporting layer — do not modify frozen v1.0

For a later read-only manuscript/source-data reporting layer, add the following from
the frozen v1 model objects without changing the v1 analysis or inferential decisions:

- 95% confidence intervals;
- actual observed sample count per protein and contrast;
- residual degrees of freedom;
- explicit multiplicity-family identifiers.
