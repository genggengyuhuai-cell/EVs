# QC Descriptive Report

## Purpose

This document records the complete pre-analysis descriptive QC workflow
for the plasma proteomics project.

The purpose of this stage is to describe:

-   sample composition;
-   protein detection coverage;
-   missingness structure;
-   abundance distribution;
-   acquisition-date structure.

No differential abundance testing is performed in this stage.

No filtering, imputation, normalization, or batch correction is applied
to the quantitative matrix.

------------------------------------------------------------------------

# 1. Dataset audit

Input matrix:

-   3817 protein groups
-   519 samples

Quantitative variable:

Spectronaut PG.Quantity

Detection definition:

finite quantitative value \> 0

The original matrix contains:

-   missing values: 891322
-   zero values: 0
-   negative values: 0
-   non-numeric values: 0

Missing values are retained.

------------------------------------------------------------------------

# 2. Sample structure

## Environment

  Environment            n
  ------------------ -----
  high_stress          239
  high_temperature     280

## Dose

  Dose          n
  --------- -----
  control     153
  low         186
  high        176
  unknown       4

Unknown samples are retained for descriptive QC but excluded from
dose-defined differential abundance analysis.

------------------------------------------------------------------------

# 3. Detection gradient

Protein completeness was evaluated across multiple detection thresholds.

Thresholds:

-   10%
-   20%
-   30%
-   40%
-   50%
-   60%
-   70%
-   80%
-   90%
-   100%

The key thresholds used for downstream decisions:

  Threshold     Protein groups
  ----------- ----------------
  50%                     1935
  60%                     1670
  70%                     1434
  80%                     1214

The primary analysis uses the 70% completeness threshold.

------------------------------------------------------------------------

# 4. Missingness landscape

QC evaluates:

-   protein missing rate distribution;
-   sample detection depth;
-   abundance versus missingness relationship.

Missingness is not interpreted as quantitative zero.

Missingness patterns are used for data-quality assessment only.

------------------------------------------------------------------------

# 5. Protein detection landscape

The detection landscape evaluates:

-   proteins detected across regions;
-   proteins detected across environments;
-   broad detection proteins;
-   core protein coverage.

A protein detected in a group does not automatically indicate
group-specific biological regulation.

------------------------------------------------------------------------

# 6. Figure workflow

Figures are generated from:

PROJECT_ROOT/code/

Outputs:

PROJECT_ROOT/descriptive/

All figures are generated programmatically.

------------------------------------------------------------------------

# 7. QC interpretation boundaries

QC results describe:

-   data completeness;
-   technical structure;
-   sample composition.

QC does not prove:

-   biological causality;
-   environmental effects;
-   biomarker validity.
