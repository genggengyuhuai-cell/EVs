# Normalization and design diagnostics

## Input
- PRIMARY_dose_quantitative_expression.csv.gz
- dose_defined_metadata.csv

Primary set:
- proteins: 1434
- dose-defined samples: 515
- residual missingness: 6.29%

## Primary normalization candidate
PG.Quantity -> log2(PG.Quantity)

No additional normalization is applied to the primary candidate matrix.

## Sensitivity normalization candidate
log2(PG.Quantity) -> sample-wise median normalization

Per-sample original log2 median range:
7.9199 to 11.1744

Median absolute sensitivity shift:
0.3582

Maximum absolute sensitivity shift:
1.9321

NA pattern is preserved exactly.

## Complete-case PCA
Complete-case proteins across all dose-defined samples:
481

PCA is diagnostic only and uses no imputation.

## Candidate design matrices
| model | samples | columns | rank | full_rank | condition_number | minimum_singular_value |
| --- | --- | --- | --- | --- | --- | --- |
| A_dose_condition | 515 | 4 | 4 | True | 4.6384 | 6.1973 |
| B_dose_condition_batch | 515 | 11 | 11 | True | 31.9394 | 0.9515 |
| C_dose_condition_interaction | 515 | 6 | 6 | True | 11.2052 | 2.6454 |

Models:
- A: dose + environment
- B: dose + environment + MS_batch_proxy
- C: dose * environment

Notes:
- MS_batch_proxy is the run-date proxy, not a confirmed technical batch ID.
- Region is deliberately not included with environment because region is nested within environment.
- full_rank=True means algebraically estimable.
- A high condition number can still indicate near-collinearity.

## Outputs
- PRIMARY_dose_log2_expression.csv.gz
- SENSITIVITY_dose_log2_median_normalized_expression.csv.gz
- normalization_sample_diagnostics.csv
- normalization_group_summaries.csv
- design_matrix_diagnostics.csv
- design_matrix_columns.csv
- design_confounding_tables.xlsx
- Figure12_normalization_diagnostics
- Figure13_median_normalization_sensitivity
- Figure14_complete_case_PCA, if complete-case PCA is possible
- Figure15_design_overlap

## Boundaries
No imputation.
No NA-to-zero conversion.
No batch correction.
No ComBat.
No removeBatchEffect.
No limma.
No sample/protein exclusion.

The next step is to choose the final normalization and limma design only after
reviewing sample-level global shifts, PCA, design rank, and batch overlap.
