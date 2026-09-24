# Reproducibility Documentation

## Project structure

All project files follow:

PROJECT_ROOT/

-   code/
-   descriptive/
-   rawdata/
-   README/

------------------------------------------------------------------------

# 1. Workflow order

The recommended execution order:

    sample mapping audit

    ↓

    describe_proteomics.py

    ↓

    detection_gradient.py

    ↓

    design_composition.py

    ↓

    complete_four_layers.py

    ↓

    dose_quantitative_filtering.py

    ↓

    normalization_design_diagnostics.py

    ↓

    05_limma_dose_analysis.R

    ↓

    06a core figures

    ↓

    06b robustness figures

    ↓

    06c acquisition-date-stratified analysis

------------------------------------------------------------------------

# 2. Input files

Raw input:

PROJECT_ROOT/rawdata/

Contains:

-   processed.xlsx
-   sample_mapping_FINAL.xlsx

------------------------------------------------------------------------

# 3. Output structure

Main analysis output:

PROJECT_ROOT/descriptive/limma_dose_analysis/

Contains:

-   diagnostics/
-   figures_final/
-   results/
-   robustness/
-   run_replication/

------------------------------------------------------------------------

# 4. Version management

README versions are stored in:

PROJECT_ROOT/README/

Changes affecting:

-   filtering;
-   normalization;
-   missing value strategy;
-   statistical model;

require a new README version.

------------------------------------------------------------------------

# 5. Reproducibility principle

All analyses should be traceable from:

input data

↓

code

↓

output tables

↓

figures

↓

interpretation

The primary workflow is not changed according to the number of
significant proteins produced.
