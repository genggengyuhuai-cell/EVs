# Limma Differential Abundance Analysis Plan

## Purpose

This document defines the locked statistical workflow for plasma
proteomics differential abundance analysis.

------------------------------------------------------------------------

# 1. Input

Quantitative input:

Spectronaut PG.Quantity

Primary dataset:

-   515 dose-defined samples
-   1434 protein groups

------------------------------------------------------------------------

# 2. Protein filtering

Primary filtering:

A protein must be detected in \>=70% of:

-   control samples;
-   low samples;
-   high samples.

Minimum detected:

  Group       Required
  --------- ----------
  control          108
  low              131
  high             124

Sensitivity thresholds:

-   50%
-   80%

------------------------------------------------------------------------

# 3. Missing values

Primary rule:

NA remains NA.

Not used:

-   zero filling;
-   KNN;
-   MinProb;
-   QRILC;
-   median imputation.

Complete-case sensitivity:

481 proteins detected in all 515 samples.

------------------------------------------------------------------------

# 4. Transformation and normalization

Primary workflow:

PG.Quantity

↓

log2 transformation

↓

limma

No additional sample-wise normalization is applied.

Sensitivity workflow:

log2(PG.Quantity)

↓

median normalization

↓

limma

------------------------------------------------------------------------

# 5. Experimental design

Primary model:

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

------------------------------------------------------------------------

# 6. Contrasts

Primary contrasts:

1.  Low vs Control
2.  High vs Control
3.  High vs Low

------------------------------------------------------------------------

# 7. Limma settings

Workflow:

``` r
lmFit()
contrasts.fit()
eBayes(
trend=TRUE,
robust=TRUE
)
```

Multiple testing:

BH adjusted P value.

------------------------------------------------------------------------

# 8. Sensitivity analyses

Predefined:

1.  Median normalization
2.  Acquisition-date proxy adjustment
3.  50% filtering threshold
4.  80% filtering threshold
5.  Complete-case analysis

Sensitivity analyses assess robustness and are not used to select the
most significant pipeline.

------------------------------------------------------------------------

# 9. Interpretation

Differential abundance indicates statistical association.

It does not establish:

-   clinical biomarkers;
-   causal effects;
-   prediction performance.
