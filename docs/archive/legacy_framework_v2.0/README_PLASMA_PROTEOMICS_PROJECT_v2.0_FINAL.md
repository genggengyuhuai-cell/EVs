# Plasma Proteomics Dose-Associated Analysis

## Final Locked Analysis Framework

**Version:** v2.0 FINAL\
**Status:** Locked analysis framework

------------------------------------------------------------------------

# 1. Project overview

## 1.1 Scientific question

This project evaluates whether plasma protein-group abundance patterns
are associated with exposure dose levels:

-   control
-   low
-   high

while accounting for two environmental backgrounds:

-   high_stress
-   high_temperature

The primary question is whether plasma protein abundances are associated
with exposure dose after accounting for environmental background
structure.

## 1.2 Primary endpoint

Primary endpoint:

Differential protein-group abundance between dose groups.

Primary contrasts:

1.  Low vs Control
2.  High vs Control
3.  High vs Low

This project does not directly establish clinical biomarkers, diagnostic
performance, predictive models, or causal environmental effects.

------------------------------------------------------------------------

# 2. Project directory structure

PROJECT_ROOT/

-   code/
-   descriptive/
    -   limma_dose_analysis/
        -   diagnostics/
        -   figures_final/
            -   06a_core/
            -   06b_robustness/
            -   06c_run_replication/
        -   results/
            -   01_PRIMARY/
            -   02_SENS_median_normalization/
            -   03_SENS_MS_batch_proxy/
            -   04_SENS_threshold_50pct/
            -   05_SENS_threshold_80pct/
            -   06_SENS_complete_case/
            -   08_SECONDARY_interaction/
        -   robustness/
        -   run_replication/
            -   results/
-   rawdata/
-   README/

All future versions are stored under:

PROJECT_ROOT/README/

------------------------------------------------------------------------

# 3. Dataset definition

Input quantitative data:

Spectronaut PG.Quantity

Initial matrix:

-   3817 protein groups
-   519 sample columns

The matrix represents continuous protein-group abundance estimates and
is not RNA-seq-style count data.

The locked sample mapping is:

PROJECT_ROOT/rawdata/sample_mapping_FINAL.xlsx

------------------------------------------------------------------------

# 4. Sample structure

Dose groups:

  Dose        Samples
  --------- ---------
  control         153
  low             186
  high            176
  unknown           4

Dose-defined analysis set:

515 samples

Environmental groups:

  Environment          Samples
  ------------------ ---------
  high_stress              239
  high_temperature         280

Region is nested within environment and is not treated as an independent
crossed covariate in the primary model.

------------------------------------------------------------------------

# 5. Acquisition-date terminology

The variable historically named MS_batch_proxy represents
acquisition-date structure.

Preferred terminology:

acquisition-date proxy

It is not interpreted as a confirmed technical batch.

Acquisition date is used only for:

-   descriptive QC;
-   sensitivity modelling;
-   acquisition-date-stratified robustness analysis.

------------------------------------------------------------------------

# 6. Detection filtering

Detection is defined as:

finite quantitative value greater than zero.

Primary filtering rule:

A protein must be detected in at least 70% of samples within each dose
group separately.

Primary quantitative set:

-   1434 protein groups
-   515 dose-defined samples
-   residual missingness 6.29%

Minimum detected samples:

  Dose        Required
  --------- ----------
  control          108
  low              131
  high             124

Sensitivity thresholds:

-   50%
-   80%

------------------------------------------------------------------------

# 7. Missing value strategy

Primary rule:

Missing values remain NA.

The primary analysis does not use:

-   NA to zero conversion
-   KNN imputation
-   MinProb
-   QRILC
-   median imputation

Missingness is not interpreted as quantitative zero.

------------------------------------------------------------------------

# 8. Transformation and normalization

Primary analysis:

PG.Quantity -\> log2(PG.Quantity)

No additional sample-wise normalization is applied in the primary model.

Reason:

The original Spectronaut cross-run normalization setting cannot
currently be verified. Additional normalization is therefore evaluated
only as a sensitivity analysis.

Sensitivity:

log2(PG.Quantity) -\> sample-wise median normalization

The original missing-value pattern is preserved.

------------------------------------------------------------------------

# 9. Primary statistical model

Primary limma model:

:   0 + dose + environment

Factors:

dose: - control - low - high

environment: - high_stress - high_temperature

Primary contrasts:

-   Low vs Control
-   High vs Control
-   High vs Low

Empirical Bayes:

limma eBayes(trend=TRUE, robust=TRUE)

FDR summary threshold:

BH-adjusted P \< 0.05

------------------------------------------------------------------------

# 10. Sensitivity analyses

The locked sensitivity analyses include:

1.  median normalization
2.  acquisition-date proxy covariate
3.  50% detection threshold
4.  80% detection threshold
5.  complete-case proteins

These analyses evaluate robustness and are not used to select the
pipeline producing the largest number of significant proteins.

------------------------------------------------------------------------

# 11. Acquisition-date stratified robustness analysis

The two large acquisition-date strata containing all dose groups are
analyzed separately.

This is a robustness assessment, not a confirmed technical batch
replication.

Within each stratum:

:   0 + dose

Environment is fixed within the selected strata and is not included.

------------------------------------------------------------------------

# 12. Current interpretation boundaries

Supported:

-   dose-associated protein abundance differences;
-   robustness assessment across predefined sensitivity analyses.

Not established:

-   confirmed technical batch effects;
-   clinical biomarker validity;
-   causal environmental effects;
-   linear dose response.

------------------------------------------------------------------------

# 13. Locked decisions

Unless a technical or data-integrity error is discovered:

-   Input quantity: Spectronaut PG.Quantity
-   Primary sample set: 515 dose-defined samples
-   Primary protein filter: \>=70% in each dose group
-   Missing values: retained as NA
-   Primary imputation: none
-   Transformation: log2
-   Primary normalization: no additional normalization
-   Sensitivity normalization: median normalization
-   Primary model: dose + environment
-   Acquisition date: sensitivity variable only
-   Region: descriptive/sensitivity only
-   Differential abundance engine: limma

------------------------------------------------------------------------

# 14. Reproducibility principle

The workflow is locked before interpretation of differential abundance
results.

Pipeline decisions are determined by:

-   data structure;
-   experimental design;
-   predefined robustness requirements.

They are not selected according to which workflow produces the largest
number of significant proteins.
