# Code Maintenance v2.4 — Detection Analysis Universe Correction

Date: 2026-09-24

This round implemented and statically reviewed the detection-analysis universe correction. **NO ANALYSIS WAS EXECUTED. RUNTIME VALIDATION REMAINS PENDING.**

## Scientific definition implemented

Primary detection logistic modelling now uses the fixed detection-analysis universe:

```text
max(Control detection rate,
    Short-exposure detection rate,
    Long-exposure detection rate) >= 0.60
```

A protein enters the detection-analysis universe when at least one exposure group has detection rate >=60%.

The `<20%` rule is **classification-only**. It may be used for specific/restricted pattern classification, but it is not a retention criterion.

The 70% primary and 60% sensitivity pattern-classification thresholds remain separate from the fixed >=60% detection-analysis universe.

## Files modified

- `descriptive/dose_restricted_detection.py`
  - retained the complete all-protein mother table;
  - added `In_detection_analysis_universe`;
  - defined membership only from the maximum Control / Short / Long detection rate >=0.60;
  - kept `<20%` restricted to pattern classification.

- `descriptive/08_detection_pattern_analysis.R`
  - primary logistic modelling now includes only proteins in `In_detection_analysis_universe`;
  - validates the universe definition against the group detection rates;
  - each contrast uses the complete fixed >=60% universe as the BH correction family;
  - model failures / non-estimable results remain explicit rather than silently changing estimators.

- `descriptive/06d_integrated_results.R`
  - retains the complete detection mother table in integration;
  - validates detection-result membership against the fixed universe;
  - explicitly marks proteins outside the detection-analysis universe as not modelled / outside the universe;
  - does not alter abundance statistics or abundance FDR.

- `PROJECT_CONTEXT.md`
  - records the frozen detection-universe definition and its separation from pattern-classification thresholds.

- `TASK_CURRENT.md`
  - advances the breakpoint from detection-universe implementation to controlled runtime validation.

## Files not requiring task-specific modification

- `FILE_STATUS.md`: no file role, activity status, canonical entry point, or HOLD/DEPRECATED classification changed.
- `CODEX_WORKFLOW.md`: working protocol did not change.

## Unchanged scientific components

This round did **not** change:

- the primary quantitative >=70% core;
- the primary abundance model;
- categorical exposure contrasts;
- abundance missing-value handling;
- limma statistics or abundance FDR;
- median-normalization sensitivity status;
- acquisition-date sensitivity logic;
- clustering-only NA -> 0 policy;
- exposure-pattern v2 scientific acceptance status.

## Static review status

```text
CODE IMPLEMENTED              = YES
STATICALLY REVIEWED           = YES
ANALYSIS EXECUTED             = NO
RUNTIME VALIDATED             = NO
SCIENTIFICALLY ACCEPTED       = NO
```

Static source checks and R delimiter checks passed. This does not substitute for runtime validation.

## Next breakpoint

Stop scientific-code editing and begin controlled runtime validation.

First run:

```text
descriptive/run_full_upstream.py
```

Then inspect, at minimum:

- exposure-defined sample count (expected/historical: 515);
- quantitative 50/60/70/80 sets;
- primary >=70% quantitative core (historical/expected: 1434; must be rechecked at runtime);
- actual `In_detection_analysis_universe` protein count;
- output contracts and any runtime errors.

Only after the Python upstream sequence passes should the approved R whitelist be run through:

```text
descriptive/run_active_r.R
```

Before the R run, handle non-empty output directories explicitly and conservatively. Do not add broad cleanup or recursive deletion.

The next phase is **runtime validation**, not further scientific redesign.
