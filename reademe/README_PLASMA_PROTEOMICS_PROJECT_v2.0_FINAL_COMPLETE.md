# Plasma Proteomics Dose-Associated Analysis

## README: Final Locked Project Framework

**Version:** v2.0 FINAL\
**Status:** Locked analysis framework and reproducibility record

------------------------------------------------------------------------

# 1. Project overview

## 1.1 Scientific objective

This project evaluates dose-associated plasma protein-group abundance
changes across:

-   control
-   low
-   high

while accounting for two environmental backgrounds:

-   high_stress
-   high_temperature

The primary question is:

> Which plasma protein groups show abundance differences associated with
> exposure dose after accounting for environmental background structure?

------------------------------------------------------------------------

## 1.2 Primary endpoint

The primary endpoint is differential protein-group abundance.

Primary contrasts:

1.  Low vs Control
2.  High vs Control
3.  High vs Low

This analysis does not directly establish:

-   clinical biomarkers;
-   diagnostic performance;
-   prediction models;
-   causal environmental effects.

Differential abundance is not equivalent to biomarker validation.

------------------------------------------------------------------------

# 2. Project directory structure

The project follows the current structure:

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

All README versions are stored in:

    PROJECT_ROOT/README/

------------------------------------------------------------------------

# 3. Input data and audit

## 3.1 Quantitative matrix

Input:

    PROJECT_ROOT/rawdata/processed.xlsx

Locked sample mapping:

    PROJECT_ROOT/rawdata/sample_mapping_FINAL.xlsx

Quantitative variable:

    Spectronaut PG.Quantity

The matrix contains:

-   3817 protein groups
-   519 sample columns

PG.Quantity values are continuous protein-group abundance estimates and
are not count data.

------------------------------------------------------------------------

## 3.2 Data integrity audit

Validated:

-   sample columns;
-   metadata mapping;
-   unique sample identifiers;
-   unique protein-group identifiers.

Original missingness:

    44.99%

Original matrix:

-   missing values retained;
-   no zero conversion;
-   no imputation before QC.

------------------------------------------------------------------------

# 4. Cohort structure

## 4.1 Dose groups

  Dose          n
  --------- -----
  control     153
  low         186
  high        176
  unknown       4

Dose-defined analysis:

    515 samples

Unknown samples remain in descriptive analysis but are excluded from
dose-defined differential abundance analysis.

------------------------------------------------------------------------

## 4.2 Environmental groups

  Environment            n
  ------------------ -----
  high_stress          239
  high_temperature     280

Environment is treated as a biological/sampling-background factor.

It is not treated as a technical batch.

------------------------------------------------------------------------

## 4.3 Region structure

Nine region/group categories:

    FJ_FQ
    FJ_PT
    FJ_QZ
    GZ_TH
    XZ_GG
    XZ_YA
    XZ_YB
    XZ_YC
    XZ_YD

Region is nested within environment.

Therefore region and environment are not treated as independent crossed
fixed effects in the primary model.

------------------------------------------------------------------------

# 5. Acquisition-date terminology

The metadata variable historically named:

    MS_batch_proxy

is interpreted as:

    acquisition-date proxy

It is not a confirmed technical batch identifier.

Acquisition date is used for:

-   descriptive QC;
-   sensitivity modelling;
-   acquisition-date-stratified robustness analysis.

It is not used for automatic batch correction.

------------------------------------------------------------------------

# 6. Pre-analysis descriptive QC

The QC stage evaluates:

-   sample composition;
-   detection coverage;
-   missingness;
-   abundance distribution;
-   acquisition-date structure.

The QC stage does not perform:

-   differential testing;
-   imputation;
-   normalization;
-   batch correction.

Detection definition:

    finite quantitative value > 0

------------------------------------------------------------------------

# 7. Detection filtering

## 7.1 Threshold evaluation

Thresholds evaluated:

  Threshold     Protein groups   Residual missingness
  ----------- ---------------- ----------------------
  50%                     1935                 14.20%
  60%                     1670                  9.85%
  70%                     1434                  6.29%
  80%                     1214                  3.60%

A protein must satisfy the threshold separately in:

-   control;
-   low;
-   high.

------------------------------------------------------------------------

## 7.2 Locked primary threshold

Primary filtering:

    >=70% detection in each dose group

Required detected samples:

  Dose        Required
  --------- ----------
  control          108
  low              131
  high             124

Primary analysis set:

    1434 protein groups × 515 samples

The 70% threshold is a project-specific completeness criterion.

------------------------------------------------------------------------

# 8. Missing value strategy

Primary rule:

    Missing values remain NA

The primary workflow does not use:

-   NA to zero conversion;
-   KNN;
-   MinProb;
-   QRILC;
-   median imputation.

Missing values are not interpreted as true zero abundance.

Complete-case sensitivity:

    481 proteins detected in all 515 samples

------------------------------------------------------------------------

# 9. Transformation and normalization

## 9.1 Primary workflow

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
currently be verified.

Therefore additional normalization is evaluated only as sensitivity
analysis.

------------------------------------------------------------------------

## 9.2 Median normalization sensitivity

Sensitivity workflow:

    log2(PG.Quantity)
            |
    sample-wise median normalization
            |
    limma analysis

The original missing-value pattern is preserved.

------------------------------------------------------------------------

# 10. Design diagnostics

Primary model:

``` r
~ 0 + dose + environment
```

Factors:

Dose:

-   control
-   low
-   high

Environment:

-   high_stress
-   high_temperature

------------------------------------------------------------------------

## 10.1 Design limitation

Dose distribution is not perfectly balanced across environmental strata.

Therefore:

-   environment adjustment is included;
-   residual confounding cannot be completely excluded.

------------------------------------------------------------------------

# 11. Primary differential abundance analysis

Framework:

    limma

Workflow:

``` r
lmFit()
contrasts.fit()
eBayes(trend=TRUE, robust=TRUE)
```

Summary threshold:

    BH adjusted P < 0.05

Primary contrasts:

-   Low vs Control
-   High vs Control
-   High vs Low

------------------------------------------------------------------------

# 12. Primary results

Current results:

  Contrast            Significant protein groups
  ----------------- ----------------------------
  Low vs Control                              14
  High vs Control                              0
  High vs Low                                256

Interpretation:

High vs Low represents the strongest observed dose-associated contrast.

However:

-   significance does not equal biomarker validation;
-   abundance difference does not establish causality.

------------------------------------------------------------------------

# 13. Sensitivity analyses

Predefined sensitivity analyses:

## 13.1 Median normalization

Tests whether conclusions depend on additional global scaling.

Output:

    results/02_SENS_median_normalization/

------------------------------------------------------------------------

## 13.2 Acquisition-date proxy adjustment

Sensitivity model:

    dose + environment + acquisition-date proxy

Output:

    results/03_SENS_MS_batch_proxy/

Directory naming is retained for compatibility.

------------------------------------------------------------------------

## 13.3 Detection threshold sensitivity

Outputs:

    results/04_SENS_threshold_50pct/

    results/05_SENS_threshold_80pct/

------------------------------------------------------------------------

## 13.4 Complete-case sensitivity

Output:

    results/06_SENS_complete_case/

------------------------------------------------------------------------

# 14. Acquisition-date-stratified robustness analysis

This analysis is not independent replication.

Purpose:

> Evaluate whether dose-associated directions are consistent within
> large acquisition-date strata containing all dose groups.

Output:

    descriptive/limma_dose_analysis/run_replication/

Figures:

    figures_final/06c_run_replication/

------------------------------------------------------------------------

# 15. Figure workflow

Core publication figures:

    descriptive/limma_dose_analysis/figures_final/06a_core/

Robustness figures:

    descriptive/limma_dose_analysis/figures_final/06b_robustness/

Acquisition-date-stratified figures:

    descriptive/limma_dose_analysis/figures_final/06c_run_replication/

------------------------------------------------------------------------

# 16. Reproducibility workflow

Analysis order:

    sample mapping audit

    ↓

    descriptive QC

    ↓

    detection filtering

    ↓

    normalization diagnostics

    ↓

    limma differential abundance

    ↓

    core figures

    ↓

    robustness figures

    ↓

    acquisition-date-stratified analysis

Main output location:

    PROJECT_ROOT/descriptive/limma_dose_analysis/

------------------------------------------------------------------------

# 17. Locked decisions

Unless a technical/data-integrity error is discovered:

-   Quantitative input: Spectronaut PG.Quantity
-   Primary samples: 515 dose-defined samples
-   Primary protein filter: \>=70% in each dose group
-   Primary proteins: 1434
-   Missing values: retained as NA
-   No primary imputation
-   Transformation: log2
-   Primary normalization: no additional normalization
-   Median normalization: sensitivity only
-   Primary model: dose + environment
-   Acquisition date: sensitivity only
-   Region: descriptive/sensitivity only
-   Differential abundance framework: limma

------------------------------------------------------------------------

# 18. Current limitations

Known limitations:

1.  Original Spectronaut normalization settings are unavailable.
2.  Acquisition date is not a confirmed technical batch.
3.  Region and environment are structurally linked.
4.  Dose groups are not perfectly balanced across environments.
5.  Differential abundance alone does not establish biomarker
    performance.
6.  External validation is not included in the current workflow.

------------------------------------------------------------------------

# 19. Analysis principle

The workflow is locked before biological interpretation.

Pipeline decisions are determined by:

-   experimental design;
-   data structure;
-   predefined robustness requirements.

They are not selected according to which workflow produces the largest
number of significant proteins.
