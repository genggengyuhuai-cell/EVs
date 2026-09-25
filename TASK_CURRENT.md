# TASK_CURRENT.md

Last updated: 2026-09-24

# Current Task --- Final scientific / output audit

## Status

The controlled runtime-validation phase is substantially complete.

```text
PYTHON UPSTREAM RUNTIME      = PASS
ACTIVE R RUNTIME            = SUBSTANTIALLY COMPLETE
PRIMARY LIMMA                = PASS
DETECTION MODEL RUNTIME      = PASS
INTEGRATED RESULTS RUNTIME   = PASS
DOWNSTREAM DEP RUNTIME       = PASS
FINAL SCIENTIFIC / OUTPUT QC = IN PROGRESS
```

Do not rerun already validated modules merely to reconfirm them. The current
breakpoint is final scientific, methodological, output-contract, and figure/source-data
audit.

## Locked scientific definitions --- DO NOT CHANGE

- exposure-defined samples = 515
- primary quantitative rule = >=70% detection in EACH of Control / Short / Long
- primary quantitative core = 1434 proteins
- detection mother table = 3817 proteins
- detection-analysis universe = 1848 proteins
- detection-universe rule =
  `max(Control, Short, Long detection rate) >= 0.60`
- `<20%` is classification-only and is NOT a detection-universe retention rule
- detection-model BH family = complete fixed 1848-protein universe per contrast
- primary abundance model = exposure group + environment
- primary abundance missing values remain NA; no primary imputation
- primary limma uses categorical contrasts and BH-adjusted P values
- formal DEP definition = BH FDR < 0.05
- effect-size thresholds are characterization only and do not redefine DEP
- canonical environment display labels = `高海拔` / `湿热`
- historical English environment keys are internal compatibility identifiers only
- deprecated continuous 0/1/2 exposure trend remains outside the active workflow

## Verified Python upstream

- `run_all.py` = PASS
- `normalization_design_diagnostics.py` = PASS
- `dose_restricted_detection.py` = PASS
- exposure-defined samples = 515
- quantitative sets:
  - 50% = 1935
  - 60% = 1670
  - 70% = 1434
  - 80% = 1214
- detection mother table = 3817
- detection-analysis universe = 1848
- outside detection-analysis universe = 1969

## Verified R runtime

- `05_limma_dose_analysis.R` = PASS
- `06a_limma_core_figures.R` = PASS
  - structural output contract PASS
  - visual QC PASS
- `06b_limma_robustness.R` = PASS
  - structural output contract PASS
  - visual QC PASS
- `06c_run_replication.R` = PASS
- `04_covariate_QC.R` = executed without runtime error
- `08_detection_pattern_analysis.R` = PASS
- `06d_integrated_results.R` = PASS
- `09_DEP_characterization.R` = PASS
- `DEP_effect_size_summary.R` = PASS
- `10_protein_clustering.R` = runtime PASS
- `10_dose_pattern_classification.R` = runtime PASS

Runtime PASS does not automatically mean final scientific acceptance.

## Primary abundance checkpoints

Primary quantitative universe:

```text
1434 proteins
```

Primary categorical FDR counts:

```text
Short exposure vs Control = 14
Long exposure vs Control  = 0
Long vs Short exposure    = 256
```

For Long vs Short exposure:

- DEP = 256 by BH FDR < 0.05
- Higher in Long = 0
- Higher in Short = 256
- median logFC approximately -0.295
- mean logFC approximately -0.304

Effect-size characterization:

```text
FDR < 0.05                         = 256
FDR < 0.05 and |log2FC| >= 0.5    = 3
FDR < 0.05 and |log2FC| >= 1.0    = 0
```

These effect-size layers do not redefine DEP.

## Detection-analysis runtime checkpoints

Primary detection model, per contrast:

```text
detection universe          = 1848
ok                          = 1185
constant_detection          = 481
separation_nonfinite_MLE    = 182
finite P                    = 1185
finite FDR                  = 1185
```

Primary detection FDR < 0.05:

```text
Short exposure vs Control = 1
Long exposure vs Control  = 0
Long vs Short exposure    = 0
```

Age/Sex sensitivity:

```text
age_sex_absent_or_below_90pct_complete = 1848 per contrast
```

Acquisition-matched primary:

```text
ok                       = 1185
constant_detection       = 481
separation_nonfinite_MLE = 182
```

Acquisition-adjusted detection sensitivity:

```text
constant_detection       = 481
separation_nonfinite_MLE = 1367
ok                       = 0
```

This acquisition-adjusted branch remains a scientific/design audit item.
Do not silently replace failed/non-finite MLEs with pseudo-counts, Firth,
penalized logistic regression, or another estimator without a separate explicit
methodological decision.

## Integrated-results checkpoint

`06d_integrated_results.R` runtime = PASS.

For each of the three abundance contrasts:

```text
N_abundance               = 1434
N_detection_mother_table  = 3817
N_detection_universe      = 1848
N_joint                   = 1434
N_outside_core            = 414
```

The complete 3817-protein mother table remains retained. The detection universe
is not collapsed to the 1185 estimable proteins. Abundance and detection
universes remain distinct.

## Downstream DEP checkpoints

`09_DEP_characterization.R`:

```text
DEP = 256
Higher in Long = 0
Higher in Short = 256
```

`DEP_effect_size_summary.R`:

```text
input proteins = 1434
FDR DEP = 256
FDR + |log2FC| >= 0.5 = 3
FDR + |log2FC| >= 1.0 = 0
```

`10_protein_clustering.R`:

```text
DEP proteins = 256
expression proteins = 256
missing values before replacement = 3017
missing values after replacement = 0
proteins after z-score = 256
NA in z matrix = 0
Inf in z matrix = 0

Cluster 1 = 131
Cluster 2 = 108
Cluster 3 = 5
Cluster 4 = 12
```

Clustering remains exploratory. The project permits `NA -> 0` only for explicitly
defined clustering/visualisation use; this must never propagate into primary
limma analysis.

`10_dose_pattern_classification.R`:

```text
Short_peak       = 249
Long_suppression = 7
Total            = 256
```

Runtime PASS only. This module remains scientifically under REVIEW until the
exact mutually exclusive classification formulas are audited and accepted.
Pattern classes do not define statistical significance.

`11_pattern_protein_annotation.R` remains HOLD.

## Current final-audit priorities

1. Audit `10_protein_clustering.R`.
   - verify the exact missing-value replacement implementation;
   - confirm replacement occurs only in the exploratory clustering/visualisation
     working matrix;
   - confirm it cannot propagate into primary limma or DEP definition;
   - review clustering parameters and interpretation.

2. Audit `10_dose_pattern_classification.R`.
   - verify exact mathematical definitions of `Short_peak` and
     `Long_suppression`;
   - verify mutual exclusivity and complete intentional classification of all
     256 DEP;
   - keep this module exploratory unless explicitly accepted.

3. Audit the acquisition-adjusted detection sensitivity.
   - explain/document why all 1367 non-constant proteins are
     `separation_nonfinite_MLE`;
   - determine whether this is an estimability/design limitation;
   - do not introduce a replacement estimator without a separate methodological
     decision.

4. Audit `04_covariate_QC.R`.
   - runtime completed without error;
   - output contract and scientific QC remain to be explicitly verified.

5. Complete downstream figure/source-data QC where still pending.
   - 06a = complete;
   - 06b = complete;
   - review applicable outputs from 06c, 08, 06d, clustering, and pattern
     classification for structural contract, terminology, source-data integrity,
     and visual quality.

6. Non-blocking code hygiene after scientific audit.
   - maintain `v21_output()` protection for reproducible output directories;
   - clean deprecation/package/locale warnings only where doing so does not alter
     scientific definitions.

## Known non-blocking warnings / limitations

- known R locale startup warnings;
- package build-version warnings;
- ggplot2 deprecation warnings in some figure modules;
- five partial-NA coefficients in the primary fit;
- Python Matplotlib deprecation warning;
- Chinese-font handling must remain compatible with canonical display labels.

Do not repair these by changing scientific definitions.

## Explicitly not part of the current task

Do not start:

- Age/Sex expansion beyond currently available/completeness-qualified data
- platelet/hemolysis formal module
- processing-time/freeze-thaw expansion
- QC/reference/technical-replicate redesign
- Spectronaut normalization redesign
- GO/KEGG/pathway enrichment
- STRING
- pattern annotation
- repository-wide low/high/dose terminology migration
- new primary imputation
- new primary normalization
- new primary covariates
- deprecated continuous 0/1/2 exposure trend
- EV-workstream analyses

These belong in the master audit/backlog unless the project breakpoint explicitly
moves to one of them.

## Exact breakpoint for the next session

```text
START HERE:

Runtime validation is substantially complete.

NEXT:
Audit `10_protein_clustering.R` only.

Then:
Audit `10_dose_pattern_classification.R`.

Do not rerun 05/06a/06b/06c/08/06d/09/DEP summary/10 modules merely to
reconfirm successful execution.

Do not alter 1434 / 1848 / 3817 / 70% / 60% / BH / DEP=FDR<0.05 definitions.
```
