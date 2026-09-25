# Descriptive pipeline run order

## A. Source inputs

```text
rawdata/
    processed.xlsx
    sample_mapping_FINAL.xlsx
```

## B. Active executable scripts

```text
01_describe_proteomics.py
02_detection_gradient.py
03_design_composition.py
04_complete_four_layers.py
05_dose_quantitative_filtering.py
06_covariate_QC.R
07_limma_dose_analysis.R
08a_limma_core_figures.R
08b_limma_robustness.R
08c_run_replication.R
08d_integrated_results.R
09_detection_pattern_analysis.R
10a_DEP_characterization.R
10b_DEP_effect_size_summary.R
11a_dose_pattern_classification.R
11b_protein_clustering.R
12_pattern_protein_annotation.R
```

`v21_common.R`, `nature_plotting.py`, and the two `stage05_*_helper.py` files are
helpers and are not independently executed pipeline stages.

## C. Actual dependency graph

```text
rawdata -> 01
            +-> 02 -> 04
            +-> 03
            +-> 05 -----------------------> 09
                 +-> 06                    |
                 +-> 07 -> 08a             |
                      |  -> 08b             |
                      |  -> 08c             |
                      |      \              |
                      +-------+-----> 08d <-+
                      +-> 10a -> 11a -> 12
                      |      \-> 11b
                      +-> 10b
```

Stage 04 does not consume Stage 03 output. Stage 07 does not consume Stage 06 output;
Stage 06 is a mandatory QC checkpoint before Stage 07, not a fabricated file
dependency. Stage 09 is a binary-detection branch from Stage 05. Stage 08d genuinely
requires Stage 09 and therefore is run after it despite its filename.

## D. Stage table

| Stage | Script | Depends on | Main inputs | Main outputs |
|---|---|---|---|---|
| 01 | `01_describe_proteomics.py` | rawdata | two raw workbooks | `audit.json`, sample/protein statistics, detection rates, `canonical_protein_annotation.csv` |
| 02 | `02_detection_gradient.py` | 01 | audit, Stage 01 detection rates/statistics | detection-gradient tables and figures |
| 03 | `03_design_composition.py` | 01 | `sample_statistics.csv` | design-composition tables and figures |
| 04 | `04_complete_four_layers.py` | 01, 02 | Stage 01 statistics/rates, Stage 02 gradient | complete four-layer descriptive tables/report/figures |
| 05 | `05_dose_quantitative_filtering.py` | 01 | raw matrix, audit, sample statistics, canonical annotation | quantitative matrices, log2/sensitivity data, metadata, `detection_pattern/` mother data |
| 06 | `06_covariate_QC.R` | 01, 05 | sample statistics, dose metadata; optional Stage 05 diagnostics | `covariate_QC/` tables and figures |
| 07 | `07_limma_dose_analysis.R` | 05 | primary/sensitivity expression and dose metadata | limma result tables, saved fits, diagnostics |
| 08a | `08a_limma_core_figures.R` | 05, 07 | Stage 05 diagnostics/expression and Stage 07 primary results | core figures and source data |
| 08b | `08b_limma_robustness.R` | 07 | primary and sensitivity limma tables | robustness figures/tables |
| 08c | `08c_run_replication.R` | 05, 07 | primary expression/metadata and primary limma tables | run-replication fits/tables/figures |
| 09 | `09_detection_pattern_analysis.R` | 05 | binary matrix, detection metadata/rates/membership | logistic-model detection results |
| 08d | `08d_integrated_results.R` | 05, 07, 09 | abundance results/fit/expression plus detection results/rates | integrated abundance/detection figures and tables; individual-protein titles use canonical `Display_label` |
| 10a | `10a_DEP_characterization.R` | 07 | primary Long-vs-Short limma table | DEP tables and characterization figures |
| 10b | `10b_DEP_effect_size_summary.R` | 07 | primary Long-vs-Short limma table | effect-size summaries and figures |
| 11a | `11a_dose_pattern_classification.R` | 05, 10a | DEP table, primary expression, metadata | descriptive three-group pattern tables/figures |
| 11b | `11b_protein_clustering.R` | 05, 10a | DEP table, primary expression, metadata | exploratory clustering of z-scored observed three-group response profiles; no sample-level imputation |
| 12 | `12_pattern_protein_annotation.R` | 01, 11a | canonical annotation and Stage 11a pattern table | deterministically annotated pattern results |

## E. Manual execution commands

Run these from `descriptive/`, stopping to inspect after every command:

```powershell
python 01_describe_proteomics.py
python 02_detection_gradient.py
python 03_design_composition.py
python 04_complete_four_layers.py
python 05_dose_quantitative_filtering.py
Rscript --vanilla 06_covariate_QC.R
Rscript --vanilla 07_limma_dose_analysis.R
Rscript --vanilla 08a_limma_core_figures.R
Rscript --vanilla 08b_limma_robustness.R
Rscript --vanilla 08c_run_replication.R
Rscript --vanilla 09_detection_pattern_analysis.R
Rscript --vanilla 08d_integrated_results.R
Rscript --vanilla 10a_DEP_characterization.R
Rscript --vanilla 10b_DEP_effect_size_summary.R
Rscript --vanilla 11a_dose_pattern_classification.R
Rscript --vanilla 11b_protein_clustering.R
Rscript --vanilla 12_pattern_protein_annotation.R
```

## F. Validation rule

Manual stage validation has passed. The locked core state is 3,817 raw protein groups,
519 raw samples, 3,810 mapped gene symbols plus 7 fallback/unmapped labels, 515
dose-defined samples, 1,434 primary quantitative proteins, approximately 6.29%
primary residual missingness, and 256 DEPs. The primary threshold is at least 70%
detection in each exposure group. Primary input is log2 only; missing values
remain `NA`, primary imputation is none, primary `NA -> 0` is not used, and median
normalization is sensitivity-only.

Stage 11a remains the canonical rule-based classification (`Short_peak = 249`,
`Long_suppression = 7`). Stage 11b is exploratory unsupervised response-profile
clustering using the 256 × 3 observed Control/Short/Long group-mean matrix followed by
protein-wise z-scoring (`C1 = 130`, `C2 = 96`, `C3 = 7`, `C4 = 23`), with no
sample-level imputation. All 7 `Long_suppression` proteins map to C3; the 249
`Short_peak` proteins map to C1/C2/C4 as 130/96/23. K-means K=2–6 is
sensitivity-only and no optimal biological K is claimed.

## G. `run_all.py`

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
```

Stages 01–12 constitute the frozen v1.0 analytical pipeline. Do not modify frozen
analytical source unless a verified scientific or software bug is identified, the
modification is explicitly authorized, the analytical version is incremented,
affected stages are revalidated, and end-to-end reproducibility is re-established
when required. Cosmetic cleanup, code deduplication, refactoring, warning suppression,
or style improvement alone is not sufficient reason to modify frozen v1.0 analytical
source. New biological analyses should preferentially be implemented as downstream
modules rather than by modifying the frozen primary pipeline.
