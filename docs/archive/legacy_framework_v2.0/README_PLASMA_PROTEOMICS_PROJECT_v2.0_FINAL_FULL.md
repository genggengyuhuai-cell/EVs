# Plasma Proteomics Dose-Associated Analysis

## Final Locked Analysis Framework

**Version:** v2.0 FINAL FULL\
**Status:** Locked analysis framework

------------------------------------------------------------------------

# 1. Scientific question

This project evaluates dose-associated plasma protein-group abundance
changes across:

-   control
-   low
-   high

while accounting for two environmental backgrounds:

-   high_stress
-   high_temperature

Primary endpoint:

> Differential protein-group abundance between dose groups.

Primary comparisons:

1.  Low vs Control
2.  High vs Control
3.  High vs Low

This analysis does not by itself establish biomarkers, diagnostic
performance, or causal environmental effects.

------------------------------------------------------------------------

# 2. Project structure

The project follows the current directory organization:

    PROJECT_ROOT/

    ├── code
    ├── descriptive
    │   └── limma_dose_analysis
    │       ├── diagnostics
    │       ├── figures_final
    │       │   ├── 06a_core
    │       │   ├── 06b_robustness
    │       │   └── 06c_run_replication
    │       ├── results
    │       │   ├── 01_PRIMARY
    │       │   ├── 02_SENS_median_normalization
    │       │   ├── 03_SENS_MS_batch_proxy
    │       │   ├── 04_SENS_threshold_50pct
    │       │   ├── 05_SENS_threshold_80pct
    │       │   ├── 06_SENS_complete_case
    │       │   └── 08_SECONDARY_interaction
    │       ├── robustness
    │       └── run_replication
    │           └── results
    ├── rawdata
    └── README

All versions of this document are stored under:

    PROJECT_ROOT/README/

------------------------------------------------------------------------

# 3. Input data

Primary quantitative matrix:

    PROJECT_ROOT/rawdata/processed.xlsx

Locked sample mapping:

    PROJECT_ROOT/rawdata/sample_mapping_FINAL.xlsx

Quantitative variable:

    Spectronaut PG.Quantity

The matrix contains:

-   3817 protein groups
-   519 sample columns

PG.Quantity values are continuous abundance estimates and are not count
data.

------------------------------------------------------------------------

# 4. Cohort structure

Dose groups:

  Group         n
  --------- -----
  control     153
  low         186
  high        176
  unknown       4

Dose-defined analysis set:

    515 samples

Environmental groups:

  Environment            n
  ------------------ -----
  high_stress          239
  high_temperature     280

Region is nested within environment and is not treated as an independent
crossed factor in the primary model.

------------------------------------------------------------------------

# 5. Acquisition-date terminology

The metadata variable historically named:

    MS_batch_proxy

is interpreted as:

    acquisition-date proxy

It is not a confirmed technical batch identifier.

Acquisition date is evaluated only through:

-   descriptive QC;
-   sensitivity modelling;
-   acquisition-date-stratified robustness analysis.

------------------------------------------------------------------------

# 6. Pre-analysis QC

The descriptive stage evaluates:

-   sample composition;
-   detection coverage;
-   missingness;
-   abundance distribution;
-   acquisition-date structure.

The QC stage does not perform:

-   imputation;
-   normalization;
-   batch correction;
-   differential testing.

Detection definition:

    finite quantitative value > 0

Original matrix:

-   missing values: 891322
-   zero values: 0
-   negative values: 0
-   non-numeric values: 0

------------------------------------------------------------------------

# 7. Detection filtering

Filtering was evaluated using:

-   50%
-   60%
-   70%
-   80%

A protein must satisfy the detection threshold separately within:

-   control
-   low
-   high

Results:

  Threshold     Protein groups   Missingness
  ----------- ---------------- -------------
  50%                     1935        14.20%
  60%                     1670         9.85%
  70%                     1434         6.29%
  80%                     1214         3.60%

Primary rule:

    >=70% detection in each dose group

Final primary matrix:

    1434 protein groups × 515 samples

The 70% threshold is a project-specific completeness criterion, not a
universal proteomics standard.

------------------------------------------------------------------------

# 8. Missing values

Primary rule:

    Missing values remain NA

The primary analysis does not use:

-   NA to zero conversion
-   KNN imputation
-   MinProb
-   QRILC
-   median imputation

Missing values are not interpreted as quantitative zero.

Complete-case sensitivity:

    481 proteins observed in all 515 samples

------------------------------------------------------------------------

# 9. Transformation and normalization

Primary workflow:

    PG.Quantity
        |
        v
    log2(PG.Quantity)
        |
        v
    limma analysis

No additional sample-wise normalization is applied in the primary model.

Reason:

The original Spectronaut cross-run normalization setting cannot
currently be verified. Additional normalization is therefore evaluated
only as sensitivity analysis.

Sensitivity workflow:

    log2(PG.Quantity)
        |
    sample-wise median normalization
        |
    limma analysis

------------------------------------------------------------------------

# 10. Design diagnostics

Primary design:

    dose + environment

Model:

``` r
~ 0 + dose + environment
```

Dose:

-   control
-   low
-   high

Environment:

-   high_stress
-   high_temperature

Important limitation:

Dose distribution is not perfectly balanced across environmental strata.
Environment adjustment reduces this concern, but residual confounding
cannot be completely excluded.

------------------------------------------------------------------------

# 11. Primary limma analysis

Primary contrasts:

-   Low vs Control
-   High vs Control
-   High vs Low

Model:

``` r
lmFit()
contrasts.fit()
eBayes(trend=TRUE, robust=TRUE)
```

Summary threshold:

    BH adjusted P < 0.05

Current primary results:

  Contrast            Significant proteins
  ----------------- ----------------------
  Low vs Control                        14
  High vs Control                        0
  High vs Low                          256

Differential abundance is not equivalent to biomarker validation.

------------------------------------------------------------------------

# 12. Sensitivity analyses

The following analyses are predefined:

## Median normalization

Tests whether conclusions depend on additional global scaling.

## Acquisition-date proxy adjustment

Sensitivity model:

    dose + environment + acquisition-date proxy

The directory name:

    03_SENS_MS_batch_proxy

is retained for compatibility, but the variable is interpreted as
acquisition-date proxy.

## Detection threshold sensitivity

Compared thresholds:

-   50%
-   70%
-   80%

## Complete-case sensitivity

Uses proteins observed in all 515 dose-defined samples.

Sensitivity analyses are not used to select the pipeline producing the
largest number of significant proteins.

------------------------------------------------------------------------

# 13. Acquisition-date-stratified robustness analysis

The two large acquisition-date strata containing all dose groups are
analyzed separately.

This is a robustness assessment, not independent replication.

Within each stratum:

``` r
~ 0 + dose
```

Environment is not included because it is fixed within the selected
strata.

------------------------------------------------------------------------

# 14. Figure workflow

Core figures:

    PROJECT_ROOT/descriptive/limma_dose_analysis/figures_final/06a_core/

Robustness figures:

    PROJECT_ROOT/descriptive/limma_dose_analysis/figures_final/06b_robustness/

Acquisition-date-stratified figures:

    PROJECT_ROOT/descriptive/limma_dose_analysis/figures_final/06c_run_replication/

------------------------------------------------------------------------

# 15. Reproducibility

The workflow preserves:

-   input files;
-   scripts;
-   output tables;
-   figures;
-   analysis logs.

Main analysis output:

    PROJECT_ROOT/descriptive/limma_dose_analysis/

Results:

    results/
    ├── 01_PRIMARY
    ├── 02_SENS_median_normalization
    ├── 03_SENS_MS_batch_proxy
    ├── 04_SENS_threshold_50pct
    ├── 05_SENS_threshold_80pct
    ├── 06_SENS_complete_case
    └── 08_SECONDARY_interaction

------------------------------------------------------------------------

# 16. Locked decisions

Unless a technical or data-integrity error is identified:

-   PG.Quantity is the quantitative input.
-   Primary sample set: 515 dose-defined samples.
-   Primary protein filter: \>=70% in each dose group.
-   Primary protein set: 1434 proteins.
-   Missing values remain NA.
-   No primary imputation.
-   Primary transformation: log2.
-   No additional primary normalization.
-   Median normalization is sensitivity only.
-   Primary model: dose + environment.
-   Acquisition date is sensitivity only.
-   Region is not included as an independent primary factor.
-   Limma is the differential abundance framework.

------------------------------------------------------------------------

# 17. Analysis principle

The workflow is fixed before interpretation of results.

Pipeline choices are determined by:

-   experimental design;
-   data structure;
-   predefined robustness requirements.

They are not changed according to which pipeline produces the largest
number of significant proteins.
