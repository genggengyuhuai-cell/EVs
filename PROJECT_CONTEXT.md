# PROJECT_CONTEXT.md

Last updated: 2026-09-24

# Plasma Proteomics Project Context

## 1. Project purpose

This is a long-term plasma proteomics project based on Spectronaut
protein-group quantitative output. This file defines the CURRENT
authoritative scientific and analytical context. Historical scripts and
README files must not override it.

## 2. Project root

``` text
F:\env
```

Main working area for this analysis is `F:\env\descriptive`. File
activity status must be determined from `FILE_STATUS.md`, not inferred
from filename numbering.

## 3. Dataset

Primary source:

-   plasma proteomics;
-   Spectronaut output;
-   quantitative field: `PG.Quantity`;
-   protein-group level analysis.

Current verified structure:

``` text
3817 protein-group rows
519 mapped sample columns
515 exposure-defined samples
```

All 3817 protein groups are detected in at least one sample. Missingness
is substantial and may be biologically and technically meaningful; it
must not automatically be treated as random numerical missingness.

## 4. Sample mapping

The P1/P2/P3 mapping chain is frozen and validated:

``` text
519 mapped sample columns
519 unique metadata assignments
no duplicate metadata assignment
no unresolved sample mapping
mapping check PASS
```

Do not rewrite mapping logic unless mapping is explicitly reopened.

## 5. Exposure-group structure and compatibility keys

Scientific interpretation:

``` text
Control
Short exposure
Long exposure
```

Internal compatibility keys may remain:

``` text
control
low
high
```

They are categorical compatibility identifiers, not a validated
continuous dose scale.

Historical contrast keys:

``` text
Low_vs_Control
High_vs_Control
High_vs_Low
```

Preferred display wording:

``` text
Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

## 6. Environment and region structure

Canonical scientific/display environment labels:

``` text
高海拔
湿热
```

Historical internal compatibility identifiers may remain where required:

``` text
high_stress
high_temperature
```

The English keys must not replace the canonical Chinese labels in final
user-facing environment displays.

Region/group values include:

``` text
FJ_FQ
FJ_PT
FJ_QZ
GZ_TH
XZ_GG
XZ_YA
XZ_YB
XZ_YC
XZ_YD
```

Region is descriptive/sensitivity context and is not an independent
crossed primary factor when structurally nested within environment.

## 7. Acquisition-date information

Injection/acquisition date may be used descriptively and in sensitivity
analysis.

``` text
MS run date is NOT a confirmed technical batch ID.
```

Preferred wording includes `MS run date`, `run-date proxy`,
`acquisition-date proxy`, and `acquisition-date stratum`.

## 8. Other preanalytical variables

Possible metadata variables include `Tube_Mixing`, `WoleBlood_oldTime`,
`Plasma_HoldTime_h`, and `TREAT2`. Do not fabricate missing metadata.

Age/Sex may only be used when present and sufficiently complete. In the
current detection sensitivity implementation, the Age/Sex branch is
unavailable because the fields are absent or below the prespecified
completeness requirement.

# 9. Current analytical architecture

The project contains two main analytical branches. Both are part of the
main analysis and answer different questions.

## 9.1 Branch A --- quantitative abundance analysis

Primary quantitative inclusion rule:

``` text
>=70% detection in control
AND >=70% detection in short exposure
AND >=70% detection in long exposure
```

Current primary quantitative universe:

``` text
1434 proteins
```

Upstream filtering sets:

``` text
50% = 1935
60% = 1670
70% = 1434
80% = 1214
```

Formal limma threshold sensitivities remain 50% and 80%; the 60% set is
an upstream filtering/descriptive set, not a formal limma sensitivity
branch.

Quantitative input:

``` text
log2(PG.Quantity)
```

Primary rules:

-   no imputation;
-   missing values remain NA;
-   no NA -\> 0;
-   no additional normalization in the primary model;
-   no ComBat/removeBatchEffect before differential analysis;
-   median normalization is sensitivity-only.

Primary model:

``` text
abundance ~ exposure group + environment
```

Current limma settings:

``` text
lmFit()
contrasts.fit()
eBayes(trend = TRUE, robust = TRUE)
BH-adjusted P values
```

Primary categorical contrasts:

``` text
Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

Current locked abundance results:

``` text
Short exposure vs Control: FDR < 0.05 = 14
Long exposure vs Control:  FDR < 0.05 = 0
Long vs Short exposure:    FDR < 0.05 = 256
```

For Long vs Short exposure, all 256 significant proteins are higher in
Short exposure than Long exposure; median log2FC is approximately -0.295
and mean log2FC approximately -0.304.

Effect-size reporting layers:

``` text
FDR < 0.05
FDR < 0.05 and |log2FC| >= 0.5
FDR < 0.05 and |log2FC| >= 1
```

These layers do not refit the model.

## 9.2 Branch B --- detection-based analysis

Scientific question: are proteins preferentially detected, restricted,
or absent across exposure groups, including proteins outside the common
quantitative core?

This is a MAIN analytical branch and remains distinct from abundance
inference.

Detection-model universe:

``` text
max(Control detection rate,
    Short-exposure detection rate,
    Long-exposure detection rate) >= 60%
```

Confirmed durable counts:

``` text
full detection mother table = 3817
detection-model universe    = 1848
```

The `<20%` rule is classification-only for specific/restricted patterns
and never controls detection-model universe membership.

For each detection-model contrast, BH correction uses the complete fixed
1848-protein universe.

Primary detection model:

``` text
detected ~ exposure + environment
```

Estimator policy:

``` text
standard binomial logistic MLE
no Firth fallback
no penalized fallback
no pseudo-count fallback
```

Final primary detection status per contrast:

``` text
constant_detection                   = 481
full_model_separation_no_finite_MLE = 182
ok                                   = 1185
```

Final primary detection BH FDR \< 0.05:

``` text
Short exposure vs Control = 1
Long exposure vs Control  = 0
Long vs Short exposure    = 0
```

Acquisition-matched-primary reproduces the same 481 / 182 / 1185
estimability structure.

For the acquisition-adjusted model
(`detected ~ exposure + environment + acquisition_date`), all 1367
nonconstant proteins show full-model separation and no standard
finite-MLE exposure inference is reported. This is an estimability
limitation of that sensitivity specification; it does not redefine the
primary detection result and does not justify silently substituting
another estimator.

Detection status and abundance status must remain separate. A protein
outside the abundance core should be described as
`abundance not evaluated in the primary quantitative model`, not
automatically as `not differentially expressed`.

# 10. Missing-value policy

Primary limma:

``` text
NA retained
no imputation
no NA -> 0
```

Detection/non-detection is itself information; do not impute
quantitative abundance before defining detection status.

Exploratory clustering/visualisation may use NA -\> 0 only when
explicitly defined by that script. This must never propagate into
primary limma.

# 11. Sensitivity / robustness framework

Formal abundance robustness includes:

``` text
median normalization
acquisition-date proxy covariate
50% detection threshold
80% detection threshold
complete-case proteins
within-run / acquisition-date-stratified robustness
```

These do not replace the primary model.

# 12. Linear trend analysis

The historical continuous coding:

``` text
control = 0
low = 1
high = 2
```

is no longer active. Do not restore it unless explicitly requested.

# 13. DEP downstream analysis

Primary DEP source:

``` text
Long vs Short exposure
BH FDR < 0.05
```

Current DEP count:

``` text
256
```

All 256 are higher in Short exposure / lower in Long exposure.

Current effect-size counts:

``` text
FDR < 0.05                      = 256
FDR < 0.05 and |log2FC| >= 0.5 = 3
FDR < 0.05 and |log2FC| >= 1   = 0
```

Clustering and exposure-pattern classification are downstream
exploratory descriptions; their activity/acceptance status is controlled
by `FILE_STATUS.md`.

# 14. Integrated abundance + detection layer

`06d_integrated_results.R` combines already computed abundance and
detection evidence for interpretation/visualisation and does not refit
the primary limma model or create a combined significance test.

Final verified inclusion contract:

``` text
N_abundance              = 1434
N_detection_mother_table = 3817
N_detection_universe     = 1848
N_joint                  = 1434
N_outside_core           = 414
```

This contract is identical across all three categorical contrasts.

# 15. Plotting policy

Publication-oriented figures should use clean scientific typography,
readable labels, restrained palettes, adequate whitespace, editable
PDF/SVG where appropriate, high-resolution PNG previews, and matching
source-data exports. Figure aesthetics must not alter statistical
definitions.

# 16. Code modification policy

Do not rerun or redesign locked analyses merely for maintenance. Do not
modify raw data, mapping files, frozen inputs, or scientific definitions
without an explicit task.

# 17. Persistent R coding rule

Never break `[[...]]` indexing. Before finalising R code, check pairing
of `[[ ]]`, `[ ]`, `( )`, `{ }`, and ensure ggplot `+` is not left as a
standalone expression.

# 18. Documentation authority

``` text
Scientific / statistical design truth -> PROJECT_CONTEXT.md
File-role / activity truth           -> FILE_STATUS.md
Current work-progress truth           -> TASK_CURRENT.md
Implementation truth                  -> current active source code
Historical rationale / chronology     -> README files
```

# 19. Context-reading rule for Codex

At the beginning of a new task:

1.  Read `CODEX_WORKFLOW.md`.
2.  Read `PROJECT_CONTEXT.md`.
3.  Read `FILE_STATUS.md`.
4.  Read `TASK_CURRENT.md`.
5.  Do not recursively scan the repository.
6.  Inspect only files required by the current task and direct
    dependencies.
7.  Do not use deprecated/archived scripts to infer current design.
