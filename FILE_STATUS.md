# FILE_STATUS.md

Last updated: 2026-09-24

# Plasma Proteomics File Status

This file defines CURRENT file role and activity status. Do not infer
status from filename numbering alone.

Status vocabulary:

``` text
FROZEN
ACTIVE
ACTIVE-LOCKED
REVIEW
HOLD
PLANNED
DEPRECATED
ARCHIVED
COMPATIBILITY
```

## Sample mapping

-   `P1.py` --- **FROZEN** --- initial mapping audit; keep, do not
    modify unless mapping is reopened.
-   `P2.py` --- **FROZEN** --- ambiguous mapping context inspection.
-   `P3.py` --- **FROZEN** --- final mapping resolution; validated.

## Descriptive / pre-QC Python pipeline

-   `describe_proteomics.py` --- **ACTIVE** --- core descriptive
    proteomics summary; runtime validated in the 2026-09-24 upstream
    run.
-   `detection_gradient.py` --- **ACTIVE** --- detection-threshold
    gradients; runtime validated after environment-label compatibility
    repair.
-   `design_composition.py` --- **ACTIVE** --- sample-composition/design
    plots; MS run date remains a proxy, not a confirmed batch.
-   `complete_four_layers.py` --- **ACTIVE** --- extended descriptive
    pre-QC summaries/figures.
-   `dose_quantitative_filtering.py` --- **ACTIVE-LOCKED** --- primary
    rule remains \>=70% detection in EACH exposure group; generated
    50/60/70/80 sets; runtime-confirmed 70% set = 1434.
-   `normalization_design_diagnostics.py` --- **FROZEN** --- established
    normalization/design diagnostics; runtime validated in the approved
    upstream run.

## Pipeline entry points

-   `run_all.py` --- **ACTIVE** --- canonical upstream
    descriptive/filtering entry point.
-   `run_all_with_dose_filtering.py` --- **COMPATIBILITY** --- older
    compatibility entry point.
-   `run_full_upstream.py` --- **ACTIVE** --- explicit-whitelist
    upstream wrapper; runtime PASS in the controlled validation round.
-   `run_active_r.R` --- **ACTIVE** --- explicit-whitelist R runner
    definition; individual active scripts were runtime validated
    independently via `Rscript --vanilla`.
-   `test_run_all.py` / `test_run_all(1).py` --- **HOLD**.

## Primary abundance analysis

### `05_limma_dose_analysis.R`

**Status: ACTIVE-LOCKED**

Role: primary categorical limma abundance analysis.

Runtime state:

``` text
RUNTIME PASS
515 samples
1434 primary proteins
three categorical contrasts
```

Locked rules: no imputation, NA retained, no additional primary
normalization, `eBayes(trend=TRUE, robust=TRUE)`, BH FDR, categorical
contrasts.

## Plotting / robustness

-   `06_limma_result_plots.R` --- **DEPRECATED** --- superseded; do not
    use as current plotting source.
-   `06a_limma_core_figures.R` --- **ACTIVE** --- **RUNTIME PASS +
    visual QC PASS**; 116 expected non-empty outputs verified.
-   `06b_limma_robustness.R` --- **ACTIVE** --- **RUNTIME PASS + visual
    QC PASS**; approved robustness branches verified.
-   `06c_run_replication.R` --- **ACTIVE** --- **RUNTIME PASS**;
    acquisition-date-stratified robustness.
-   `06d_integrated_results.R` --- **ACTIVE** --- **FINAL RUNTIME PASS**
    after final 08 outputs; verified inclusion contract 1434 / 3817 /
    1848 / 1434 / 414.

## Deprecated trend analysis

-   `07_dose_trend_analysis.R` --- **DEPRECATED** --- continuous
    control=0/low=1/high=2 trend is not part of the active workflow.

## Covariate QC

### `04_covariate_QC.R`

**Status: ACTIVE**

Implementation/runtime state:

``` text
RUNTIME PASS
```

Role: inspect completeness/structure of optional covariates and
preanalytical variables. Do not fabricate absent Age/Sex or
automatically add covariates to the primary model.

## Detection-based main branch

### `dose_restricted_detection.py`

**Status: ACTIVE**

Implementation/runtime state:

``` text
RUNTIME PASS
detection mother table = 3817
detection-model universe = 1848
```

The detection-model universe is
`max(Control, Short, Long detection rate) >= 60%`. The `<20%` rule
remains classification-only.

### `08_detection_pattern_analysis.R`

**Status: ACTIVE-LOCKED**

Implementation/runtime state:

``` text
FINAL RUNTIME PASS
```

Role: downstream detection logistic modelling.

Final primary status per contrast:

``` text
481 constant_detection
182 full_model_separation_no_finite_MLE
1185 ok
```

Primary BH FDR \< 0.05:

``` text
Short vs Control = 1
Long vs Control  = 0
Long vs Short    = 0
```

Acquisition-matched-primary reproduces 481 / 182 / 1185.
Acquisition-adjusted modelling yields 481 constant and 1367
full-model-separation proteins with no finite-MLE fits under the
prespecified standard-MLE/no-fallback policy.

Detection results must remain distinct from abundance results. Do not
silently substitute Firth/penalized estimators.

## DEP analysis

### `09_DEP_characterization.R`

**Status: ACTIVE**

``` text
RUNTIME PASS
Long vs Short DEP = 256
Higher in Long = 0
Higher in Short = 256
```

DEP definition remains BH FDR \< 0.05.

### `DEP_effect_size_summary.R`

**Status: ACTIVE**

``` text
RUNTIME PASS
FDR = 256
FDR + |log2FC| >= 0.5 = 3
FDR + |log2FC| >= 1.0 = 0
```

This module summarizes existing results and does not refit the model.

## Protein clustering

### `10_protein_clustering.R`

**Status: ACTIVE**

``` text
RUNTIME PASS
256 DEP proteins
clusters = 131 / 108 / 5 / 12
```

Clustering is exploratory. Clustering-only `NA -> 0` must never
propagate to primary limma.

## Exposure-pattern classification

### `10_dose_pattern_classification.R`

**Status: REVIEW**

``` text
RUNTIME PASS
Short_peak = 249
Long_suppression = 7
```

The rewritten v2 mutually exclusive classification executes
successfully, but it is not yet fully scientifically locked. Do not
delete it and do not treat runtime success as final scientific
acceptance.

### `11_pattern_protein_annotation.R`

**Status: HOLD**

Paused pending explicit scientific acceptance of the
pattern-classification schema. Do not expand automatically.

## Shared helpers

-   `v21_common.R` --- **ACTIVE** --- shared R helpers/export behavior.
-   `nature_plotting.py` --- **ACTIVE** --- shared Python
    publication-figure helpers.

## Control documents

-   `CODEX_WORKFLOW.md` --- **AUTHORITATIVE WORKING PROTOCOL**
-   `PROJECT_CONTEXT.md` --- **AUTHORITATIVE SCIENTIFIC / ANALYTICAL
    CONTEXT**
-   `FILE_STATUS.md` --- **AUTHORITATIVE FILE MAP**
-   `TASK_CURRENT.md` --- **AUTHORITATIVE CURRENT WORK BREAKPOINT**

Historical maintenance README files remain historical change records and
should not override current control documents.

## Files allowed to leave the active path

Only explicitly approved deprecated scripts:

``` text
06_limma_result_plots.R
07_dose_trend_analysis.R
```

Do not remove additional scripts without explicit instruction.

## Default Codex reading behavior

``` text
READ:
CODEX_WORKFLOW.md
PROJECT_CONTEXT.md
FILE_STATUS.md
TASK_CURRENT.md

THEN READ ONLY:
files required by TASK_CURRENT.md
+
their direct dependencies when necessary
```

Do not recursively scan the repository, reopen frozen mapping code, or
infer current design from deprecated/history files.
