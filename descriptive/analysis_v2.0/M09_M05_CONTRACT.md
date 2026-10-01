# M09–M05 Reference Contract

Status: `FROZEN_REFERENCE_DO_NOT_MODIFY`.

## Purpose

M09 is a missingness/imputation sensitivity analysis for the frozen M05 overall-exposure abundance estimand. M05 is the non-imputed reference and is not rerun or modified by M09.

## Frozen M05 contract

| Component | Contract |
|---|---|
| Population | Full analytical cohort, 515 participants |
| Group counts | Control 153; Low 186; High 176 |
| Protein universe | Fixed Q515, 1,430 protein groups |
| Input | `descriptive/PRIMARY_dose_log2_expression.csv.gz` restricted to `analysis_v2.0/universes/Q515.csv` |
| Abundance scale | Existing log2 abundance matrix; missing values remain `NA` in M05 |
| Sample order | Matrix column order; metadata is matched by `UniqueSampleID` |
| Exposure coding | `Control`, `Low`, `High` from `TREAT1_clean` |
| Environment | `Humid_hot` for FJ/GZ sites and `High_altitude` for XZ sites |
| Design | `~0 + Group + Environment` |
| Estimand E | `(186/362) × mu_Low + (176/362) × mu_High − mu_Control` |
| Exact contrast implementation | `limma::contrastAsCoef` followed by refitting |
| Moderation | `limma::eBayes(trend=TRUE, robust=TRUE)` |
| Primary missingness handling | Observed-value modeling; no imputation |
| Estimability | At least 10 observed values in each Group; non-estimable raw P remains missing |
| Multiplicity family | A-E: BH across all 1,430 Q515 proteins; non-estimable tests use P=1 only for adjustment |
| Frozen output | `M05_overall_exposure/M05_overall_exposure_AE_results.csv` |

## M09 invariants

The repaired M09 must retain the same 515 samples, sample order, Group labels, Environment values, Q515 protein order, design, E weights, exact contrast implementation, empirical-Bayes settings, and BH family. The only intended analytical change is replacement of missing log2 abundance values using the prespecified KNN sensitivity method before fitting.

M09 must not use the Discovery-only subset, D03 locked candidates, D08 replication status, ML features, or any new candidate-selection rule.
