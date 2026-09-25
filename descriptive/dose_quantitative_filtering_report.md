# Dose-wise quantitative filtering

## Fixed analysis rule

Primary scientific grouping:
control / low / high.

Primary quantitative protein set:
a protein must be detected in at least 70% of samples
within EACH of control, low, and high.

Sensitivity thresholds:
50%, 60%, 80%.

Missing values are retained as NA.
No imputation, no NA-to-zero conversion, no normalization,
no batch correction, and no differential analysis are performed here.

## Dose sample counts

- control: 153 samples
- low: 186 samples
- high: 176 samples

Dose-defined samples:
515

Samples excluded from dose-defined matrices because TREAT1 is not
control/low/high:
4

## Exact minimum detected samples

| threshold_pct | dose | samples | minimum_detected_samples | effective_minimum_pct |
| --- | --- | --- | --- | --- |
| 50 | control | 153 | 77 | 50.326797385620914 |
| 50 | low | 186 | 93 | 50.0 |
| 50 | high | 176 | 88 | 50.0 |
| 60 | control | 153 | 92 | 60.130718954248366 |
| 60 | low | 186 | 112 | 60.215053763440864 |
| 60 | high | 176 | 106 | 60.22727272727273 |
| 70 | control | 153 | 108 | 70.58823529411765 |
| 70 | low | 186 | 131 | 70.43010752688173 |
| 70 | high | 176 | 124 | 70.45454545454545 |
| 80 | control | 153 | 123 | 80.3921568627451 |
| 80 | low | 186 | 149 | 80.10752688172043 |
| 80 | high | 176 | 141 | 80.11363636363636 |

## Protein sets and residual missingness

| threshold_pct | protein_groups | missing_pct | control_missing_pct | low_missing_pct | high_missing_pct | is_primary |
| --- | --- | --- | --- | --- | --- | --- |
| 50 | 1935 | 14.20 | 13.79 | 13.37 | 15.44 | False |
| 60 | 1670 | 9.85 | 9.44 | 9.12 | 10.97 | False |
| 70 | 1434 | 6.29 | 5.90 | 5.69 | 7.25 | True |
| 80 | 1214 | 3.60 | 3.27 | 3.18 | 4.32 | False |

## Primary outputs

- PRIMARY_dose_quantitative_proteins.csv
- PRIMARY_dose_quantitative_expression.csv.gz
- dose_defined_metadata.csv

The primary expression matrix contains only real observed quantitative
values plus the original NA pattern. No missing values were created,
replaced, or imputed.

## Sensitivity outputs

For each threshold in [50, 60, 70, 80]:
- proteins_all_doses_geXXpct.csv
- dose_expression_all_doses_geXXpct.csv.gz

## Validation

- Input SHA256 hashes match the existing QC audit.
- Matrix headers match the locked sample mapping.
- Protein IDs are unique.
- Threshold sets are nested.
- Every retained protein meets the threshold in every dose group.
- Saved primary NA positions exactly reproduce the original NA pattern.
- Saved observed quantitative values exactly reproduce the original values.
