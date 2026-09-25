# TASK_CURRENT.md

Last updated: 2026-09-24

# Current Task --- Core runtime validation complete / project close-out

## Status

``` text
PYTHON UPSTREAM RUNTIME            = PASS
05_limma_dose_analysis.R           = RUNTIME PASS
06a_limma_core_figures.R           = RUNTIME PASS
06b_limma_robustness.R             = RUNTIME PASS
06c_run_replication.R              = RUNTIME PASS
04_covariate_QC.R                  = RUNTIME PASS
08_detection_pattern_analysis.R    = FINAL RUNTIME PASS
06d_integrated_results.R           = FINAL RUNTIME PASS
09_DEP_characterization.R          = RUNTIME PASS
DEP_effect_size_summary.R          = RUNTIME PASS
10_protein_clustering.R            = RUNTIME PASS
10_dose_pattern_classification.R   = RUNTIME PASS / SCIENTIFIC REVIEW
FINAL CORE ANALYSIS CONTRACT       = PASS
```

The active core code/runtime-validation phase is complete. Do not rerun
completed modules merely to reconfirm them. Future work should begin
from scientific interpretation, final figure/table selection,
manuscript-oriented synthesis, or an explicitly reopened analysis
question.

## Locked scientific contracts

### Samples and quantitative abundance

``` text
Exposure-defined samples = 515
Quantitative sets:
50% = 1935
60% = 1670
70% = 1434
80% = 1214

Primary quantitative universe = 1434
Primary threshold = >=70% detection in EACH exposure group
Primary model = abundance ~ exposure group + environment
Primary contrasts = categorical
BH FDR threshold = 0.05
```

Primary abundance results:

``` text
Short exposure vs Control: FDR < 0.05 = 14
Long exposure vs Control:  FDR < 0.05 = 0
Long vs Short exposure:    FDR < 0.05 = 256
```

For Long vs Short exposure, all 256 significant proteins are higher in
Short exposure / lower in Long exposure.

### Detection branch

Frozen detection-model universe:

``` text
max(Control detection rate,
    Short-exposure detection rate,
    Long-exposure detection rate) >= 0.60
```

Confirmed:

``` text
Detection mother table = 3817
Detection universe = 1848
Proteins outside detection universe remain in the mother table
<20% is classification-only and never controls universe membership
BH family = complete fixed 1848-protein detection universe for each contrast
```

Primary detection model status, per contrast:

``` text
constant_detection                         = 481
full_model_separation_no_finite_MLE       = 182
ok                                         = 1185
total                                      = 1848
finite FDR                                 = 1185
```

Primary detection BH FDR \< 0.05:

``` text
Short exposure vs Control = 1
Long exposure vs Control  = 0
Long vs Short exposure    = 0
```

Acquisition-matched-primary status reproduces the primary estimability
structure:

``` text
481 constant
182 full-model separation
1185 ok
```

Acquisition-adjusted model:

``` text
481 constant
1367 full-model separation
0 ok
```

Interpretation: adding categorical acquisition date causes full-model
separation across all nonconstant proteins under the prespecified
standard logistic-MLE framework. Exposure contrasts are therefore not
reported for those fits. No Firth, penalized, pseudo-count, or other
fallback estimator is substituted. The matched-primary diagnostic shows
that this collapse is not caused merely by restriction to the
acquisition-eligible sample set.

Age/Sex sensitivity was not fitted because Age/Sex were absent or below
the prespecified completeness requirement. Do not fabricate or force
this branch.

### Integrated abundance + detection

Final `06d_integrated_results.R` rerun after the final 08 output:

``` text
N_abundance              = 1434
N_detection_mother_table = 3817
N_detection_universe     = 1848
N_joint                  = 1434
N_outside_core           = 414
```

All three contrasts satisfy this same inclusion contract.

``` text
FINAL CORE ANALYSIS CONTRACT = PASS
```

## Downstream abundance-derived modules

These modules do not depend on the final 08/06d outputs and therefore
did not require another rerun after the final detection repair.

### 09_DEP_characterization.R

``` text
Long vs Short DEP = 256
Higher in Long    = 0
Higher in Short   = 256
```

### DEP_effect_size_summary.R

``` text
FDR < 0.05                         = 256
FDR < 0.05 and |log2FC| >= 0.5    = 3
FDR < 0.05 and |log2FC| >= 1.0    = 0
```

### 10_protein_clustering.R

Runtime PASS on 256 DEP proteins.

``` text
Cluster 1 = 131
Cluster 2 = 108
Cluster 3 = 5
Cluster 4 = 12
```

Clustering remains exploratory. Its clustering-only missing-value
handling must not propagate to the primary limma analysis.

### 10_dose_pattern_classification.R

Runtime PASS under the rewritten mutually exclusive v2 classification:

``` text
Short_peak       = 249
Long_suppression = 7
Total            = 256
```

This module remains `REVIEW`, not fully scientifically locked. Runtime
success does not by itself constitute final scientific acceptance.

`11_pattern_protein_annotation.R` remains HOLD.

## Environment terminology --- locked

Canonical scientific/display labels:

``` text
高海拔
湿热
```

Historical internal compatibility keys may remain where required:

``` text
high_stress
high_temperature
```

They must not replace the canonical Chinese labels in final user-facing
environment displays.

## Completed runtime notes retained

-   `06a_limma_core_figures.R`: output contract and visual QC PASS.
-   `06b_limma_robustness.R`: all five approved sensitivity branches
    PASS.
-   `06c_run_replication.R`: acquisition-date-stratified robustness
    completed.
-   `04_covariate_QC.R`: executed successfully.
-   `08_detection_pattern_analysis.R`: final universe parsing,
    model-status logic, BH family, and outputs verified.
-   `06d_integrated_results.R`: rerun against final 08 outputs and
    inclusion contract verified.
-   Known package-build / locale / plotting warnings remain non-fatal
    where already documented.
-   Five partial-NA coefficients in the upstream abundance fit remain
    documented and were not repaired by changing the scientific model.

## Do not change without explicit reopening

``` text
1434 primary abundance universe
3817 detection mother table
1848 detection-model universe
414 detection-universe proteins outside the 1434 abundance core
70% primary quantitative threshold
60% detection-model retention threshold (>=60% in any exposure group)
BH adjustment
DEP = BH FDR < 0.05
categorical exposure contrasts
primary missing-value policy
standard logistic MLE / no penalized fallback policy
```

Do not restore the deprecated continuous control=0 / low=1 / high=2
trend route.

## Current breakpoint / next work

``` text
CORE CODE + RUNTIME VALIDATION = COMPLETE
```

Next work should not be another blanket rerun. Proceed only with an
explicit scientific task, such as:

-   final scientific interpretation and result synthesis;
-   selection/review of manuscript figures and tables;
-   final review of the exposure-pattern v2 branch before annotation;
-   a separately authorized biological annotation/enrichment phase;
-   a separately authorized covariate/preanalytical expansion.

Do not automatically start Age/Sex expansion, platelet/hemolysis
modules, processing-time/freeze-thaw work, enrichment, STRING, pattern
annotation, new imputation, new normalization, new primary covariates,
or EV analyses.
