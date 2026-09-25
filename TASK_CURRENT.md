# TASK_CURRENT.md

Last updated: 2026-09-24

# Current Task --- Core pipeline locked / biological interpretation breakpoint

## Status

``` text
PYTHON UPSTREAM RUNTIME                 = PASS
05_limma_dose_analysis.R                = RUNTIME PASS
06a_limma_core_figures.R                = RUNTIME + VISUAL QC PASS
06b_limma_robustness.R                  = RUNTIME + VISUAL QC PASS
06c_run_replication.R                   = RUNTIME PASS
04_covariate_QC.R                       = RUNTIME PASS
08_detection_pattern_analysis.R         = FINAL RUNTIME PASS
06d_integrated_results.R                = FINAL RUNTIME PASS
09_DEP_characterization.R               = RUNTIME PASS
DEP_effect_size_summary.R               = RUNTIME PASS
10_protein_clustering.R                 = RUNTIME PASS
10_dose_pattern_classification.R v2     = RUNTIME + SCIENTIFIC REVIEW PASS
11_pattern_protein_annotation.R         = FINAL RUNTIME PASS
FINAL CORE ANALYSIS CONTRACT            = PASS
```

The implementation/runtime audit is complete. Do not blanket-rerun completed
modules. The current breakpoint is the transition from validated statistical
results to protein-level biological interpretation.

## Locked scientific contracts

### Samples / abundance

``` text
Exposure-defined samples = 515
Quantitative sets:
50% = 1935
60% = 1670
70% = 1434
80% = 1214

Primary abundance universe = 1434
Primary threshold = >=70% detection in EACH exposure group
Primary model = abundance ~ exposure group + environment
Primary contrasts = categorical
BH FDR threshold = 0.05
```

Primary abundance results:

``` text
Short exposure vs Control: FDR < 0.05 = 14
Long exposure vs Control:  FDR < 0.05 = 0
Long vs Short exposure:    FDR < 0.05 = 256
```

All 256 Long-vs-Short DEP are higher in Short exposure / lower in Long
exposure.

Effect-size layers:

``` text
FDR < 0.05                         = 256
FDR < 0.05 and |log2FC| >= 0.5    = 3
FDR < 0.05 and |log2FC| >= 1.0    = 0
```

### Detection

``` text
Detection mother table = 3817
Detection-model universe = 1848
Retention rule = >=60% detection in ANY exposure group
<20% rule = classification-only
BH family = fixed 1848-protein universe per contrast
```

Primary status per contrast:

``` text
constant_detection                   = 481
full_model_separation_no_finite_MLE = 182
ok                                   = 1185
finite FDR                           = 1185
```

Primary detection BH FDR < 0.05:

``` text
Short exposure vs Control = 1
Long exposure vs Control  = 0
Long vs Short exposure    = 0
```

Standard binomial logistic MLE remains locked; no Firth, penalized,
pseudo-count, or other fallback estimator is substituted.

### Integrated abundance + detection

``` text
N_abundance              = 1434
N_detection_mother_table = 3817
N_detection_universe     = 1848
N_joint                  = 1434
N_outside_core           = 414
```

All three categorical contrasts satisfy the same inclusion contract.

## Downstream abundance-derived modules

### `10_protein_clustering.R`

``` text
RUNTIME PASS
Cluster 1 = 131
Cluster 2 = 108
Cluster 3 = 5
Cluster 4 = 12
```

Clustering remains exploratory. Clustering-only missing-value handling must
not propagate into primary limma.

### `10_dose_pattern_classification.R` v2

``` text
RUNTIME PASS
SCIENTIFIC REVIEW PASS WITH DESCRIPTIVE QUALIFICATION
Short_peak        = 249
Long_suppression  = 7
Total             = 256
```

Scientific use is locked as descriptive/exploratory only. Pattern labels
describe unadjusted observed three-group profiles; they are not independent
inferential discoveries.

Canonical current output:

``` text
limma_dose_analysis/results/10_dose_pattern_classification_v2
```

Historical `10_dose_pattern_classification/` contains the old Low/High schema
and must not be used as the current source.

### `11_pattern_protein_annotation.R`

``` text
FINAL RUNTIME PASS
Input_DEP                    = 256
UniProt_mapped               = 256
UniProt_unmapped             = 0
UniProt_mapping_rate_percent = 100
```

All 256 primary Long-vs-Short DEP are retained. Pattern is metadata only; no
protein is excluded by Pattern. Top effect-size ranking uses primary limma
logFC.

Current outputs include:

``` text
01_DEP_protein_annotation.csv
02_DEP_pattern_summary.csv
03_DEP_top30_FDR.csv
04_DEP_top30_effect_size.csv
05_UniProt_mapping_QC.csv
06_UniProt_unmapped_proteins.csv
```

## Current breakpoint / next exact work

``` text
CORE CODE + RUNTIME + PATTERN/ANNOTATION REVIEW = COMPLETE

NEXT:
PROTEIN-LEVEL BIOLOGICAL AUDIT OF THE 256 PRIMARY LONG-vs-SHORT DEP
```

Open/read only:

``` text
11_pattern_protein_annotation/
    01_DEP_protein_annotation.csv
    03_DEP_top30_FDR.csv
    04_DEP_top30_effect_size.csv
```

Next actions:

1. Inspect the annotated 256-protein set itself.
2. Compare top-FDR and top-effect-size proteins.
3. Identify recurring protein families / functional themes without yet
   treating pathway enrichment as established evidence.
4. Define the formal enrichment contract before running GO/Reactome/KEGG/PPI:
   foreground, tested-protein background, identifier mapping, database(s),
   multiple-testing procedure, and separation from the detection branch.
5. Only then implement/run the biological enrichment module.

## Hold / later

Do not automatically start:

``` text
Age/Sex expansion
processing-time / freeze-thaw analyses
platelet/hemolysis formal QC module
technical-replicate redesign
Spectronaut normalization redesign
repository-wide internal terminology migration
EV analyses
new primary normalization
new imputation
new primary covariates
continuous control=0 / low=1 / high=2 trend
```

## Do not change without explicit reopening

``` text
1434 primary abundance universe
3817 detection mother table
1848 detection-model universe
414 detection-universe proteins outside the 1434 abundance core
70% primary quantitative threshold
60% detection-model retention threshold (>=60% in any exposure group)
BH adjustment
DEP = BH FDR < 0.05
categorical exposure contrasts
primary missing-value policy
standard logistic MLE / no penalized fallback policy
```

## Resume instruction

A new session should read:

``` text
CODEX_WORKFLOW.md
PROJECT_CONTEXT.md
FILE_STATUS.md
TASK_CURRENT.md
```

Then begin from the protein-level biological audit above. Do not rescan or
rerun completed statistical modules unless a concrete inconsistency is found.
