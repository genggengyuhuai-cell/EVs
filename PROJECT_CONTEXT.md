# PROJECT_CONTEXT.md

Last updated: 2026-09-23

# Plasma Proteomics Project Context

## 1. Project purpose

This is a long-term plasma proteomics project based on Spectronaut protein-group quantitative output.

The project is actively evolving. Analysis modules may be added, removed, renamed, rewritten, or reclassified over time.

This file defines the CURRENT authoritative scientific and analytical context.

Historical scripts and historical README files must not override this file.

---

## 2. Project root

```text
F:\env
```

Main working areas:

```text
F:\env\
├── rawdata\
├── descriptive\
├── reademe\
├── code\
└── ...
```

The exact physical location of a script may change over time.

File activity status must be determined from `FILE_STATUS.md`, not inferred from filename numbering alone.

---

## 3. Dataset

Primary source:

- Plasma proteomics
- Spectronaut output
- Quantitative field: PG.Quantity
- Protein-group level analysis

Current verified dataset structure:

- 3817 protein-group rows
- 519 sample columns
- 515 exposure-defined samples

All 3817 protein groups are detected in at least one sample.

Global missingness is substantial and is biologically and technically meaningful.

Missingness must not automatically be treated as random numerical missingness.

---

## 4. Sample mapping

Sample mapping has already been resolved and validated.

Original mapping workflow:

```text
P1.py
P2.py
P3.py
```

Final status:

- 519 mapped sample columns
- 519 unique metadata assignments
- no duplicate metadata assignment
- no unresolved sample mapping
- mapping check PASS

P1/P2/P3 are retained for auditability.

They are frozen unless explicitly reopened.

Do not rewrite the mapping logic during unrelated tasks.

---

## 5. Exposure-group structure and compatibility keys

The scientific interpretation of the three analysis groups is:

```text
Control
Short exposure
Long exposure
```

The current internal compatibility keys remain:

```text
control
low
high
```

These keys are retained because existing scripts, contrasts, directories, and saved result objects use them.

They must not be interpreted as continuous concentration dose labels.

Preferred display mapping:

```text
control -> Control
low     -> Short exposure
high    -> Long exposure
```

Historical contrast keys remain:

```text
Low_vs_Control
High_vs_Control
High_vs_Low
```

Preferred display wording:

```text
Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

Unknown exposure samples may remain in descriptive QC but are excluded from exposure-defined differential abundance analysis unless explicitly stated otherwise.

---

## 6. Environment and region structure

### Environment

```text
high_stress
high_temperature
```

### Region / group

```text
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

Region is descriptive / sensitivity context and is not an independent crossed primary factor when structurally nested within environment.

---

## 7. Acquisition-date information

Injection / acquisition date can be used descriptively and in sensitivity analysis.

IMPORTANT:

```text
MS run date is NOT a confirmed technical batch ID.
```

Preferred wording:

```text
MS run date
run-date proxy
acquisition-date proxy
acquisition-date stratum
MS run-date proxy
```

Do not present run date as a confirmed batch unless new experimental records establish that.

---

## 8. Other preanalytical variables

Possible metadata variables include:

```text
Tube_Mixing
WoleBlood_oldTime
Plasma_HoldTime_h
TREAT2
```

Do not fabricate missing metadata.

Age/Sex should only be used if they actually exist in the current metadata and satisfy completeness requirements.

---

# 9. Current analytical architecture

The project now contains TWO main analytical branches.

Both are part of the main analysis.

They answer different biological questions and must not be conflated.

---

## 9.1 Branch A — quantitative abundance analysis

Scientific question:

> Among proteins with sufficiently stable quantitative detection across Control, Short exposure, and Long exposure, which proteins show exposure-group abundance differences?

### Primary quantitative protein set

A protein enters the primary quantitative analysis when it is detected in:

```text
>=70% of control samples
AND
>=70% of short-exposure samples
AND
>=70% of long-exposure samples
```

Current primary quantitative protein count:

```text
1434
```

### Filtering sets generated upstream

The quantitative filtering stage evaluates / retains threshold sets including:

```text
50%
60%
70%
80%
```

### Primary threshold

```text
70%
```

### Formal limma threshold sensitivities

The locked limma threshold-sensitivity analyses are:

```text
50%
80%
```

The 60% set exists as an upstream filtering / descriptive set but is not a locked formal limma threshold-sensitivity branch.

### Quantitative input

```text
log2(PG.Quantity)
```

Primary analysis rules:

- no imputation
- missing values remain NA
- no NA -> 0 conversion
- no additional normalization in the primary model
- no ComBat
- no removeBatchEffect before differential analysis
- no KNN / MinProb / QRILC in the primary differential analysis

Median normalization is a sensitivity analysis only.

### Primary model

```text
abundance ~ exposure_group + environment
```

Implementation compatibility may still use the internal `dose` factor name.

Current limma settings:

```text
lmFit()
contrasts.fit()
eBayes(trend = TRUE, robust = TRUE)
BH-adjusted P values
```

### Main contrasts

Internal keys:

```text
Low vs Control
High vs Control
High vs Low
```

Preferred interpretation:

```text
Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

Current downstream emphasis:

```text
Long vs Short exposure
```

### Current locked results

Using historical contrast keys:

```text
Low vs Control:
FDR < 0.05 = 14

High vs Control:
FDR < 0.05 = 0

High vs Low:
FDR < 0.05 = 256
```

For High vs Low / Long vs Short exposure:

- all 256 significant proteins are higher in Short exposure than Long exposure
- median log2FC approximately -0.295
- mean log2FC approximately -0.304

Effect-size reporting layers include:

```text
FDR < 0.05
FDR < 0.05 and |log2FC| >= 0.5
FDR < 0.05 and |log2FC| >= 1
```

These layers do not refit the model.

---

## 9.2 Branch B — detection-based analysis

Scientific question:

> Are there proteins preferentially detected, restricted, or absent across exposure groups even when they do not belong to the common quantitative core?

This is now a MAIN analytical branch.

It is not merely supplementary.

This branch uses the broader protein universe and focuses on detection patterns rather than continuous abundance alone.

Potential categories include:

```text
Control-specific
Short-specific
Long-specific
Control + Short
Control + Long
Short + Long
Broad detection
Sparse
Other / unresolved
```

Internal compatibility naming may still use `Low` / `High` in code or historical files.

Primary restricted-detection threshold:

```text
>=70%
```

Sensitivity threshold:

```text
>=60%
```

The exact category logic must be defined by the active detection-analysis code.

Detection status and abundance status must remain separate.

A protein outside the abundance core must NOT automatically be labelled:

```text
not differentially expressed
```

Preferred wording:

```text
abundance not evaluated in the primary quantitative model
```

where appropriate.

---

# 10. Missing-value policy

Missing-value handling depends on analysis purpose.

## Primary limma analysis

```text
NA retained
no imputation
no NA -> 0
```

## Detection analysis

Detection / non-detection is itself information.

Do not impute quantitative abundance before defining detection status.

## Clustering / visualisation

Some exploratory clustering or pattern-visualisation scripts may use:

```text
NA -> 0
```

only when explicitly defined by that script.

This is analysis-specific and must never propagate into the primary limma analysis.

---

# 11. Sensitivity / robustness framework

Current formal limma sensitivity analyses include:

```text
median normalization
acquisition-date proxy covariate
50% detection threshold
80% detection threshold
complete-case proteins
within-run / acquisition-date-stratified robustness
```

These do not replace the primary model.

Primary model remains:

```text
exposure group + environment
```

Implementation may still use the historical internal factor name `dose`.

Within-run analyses are sensitivity / robustness analyses only.

---

# 12. Linear trend analysis

The previous linear trend analysis used the historical compatibility coding:

```text
control = 0
low = 1
high = 2
```

This route is no longer active.

Reasons:

- no FDR-significant linear-trend proteins
- the biological comparison is exposure duration category, not a validated continuous dose scale
- the current emphasis is categorical exposure comparison, especially Long vs Short exposure

Do not restore linear trend to the active workflow unless explicitly requested.

---

# 13. DEP downstream analysis

Primary DEP source:

```text
High vs Low
FDR < 0.05
```

Preferred interpretation:

```text
Long vs Short exposure
```

Current DEP count:

```text
256
```

Current downstream modules include:

```text
DEP characterization
effect-size summary
protein clustering
exposure-pattern analysis
protein annotation
```

Not all downstream modules are equally active.

Current activity status must be read from `FILE_STATUS.md`.

---

# 14. Integrated abundance + detection layer

The project now includes an integrated interpretation / figure layer.

Primary active integration script:

```text
06d_integrated_results.R
```

Its role is to combine already computed abundance and detection evidence for interpretation and visualisation.

It must not refit the locked primary limma analysis.

Important principles:

- retain proteins not jointly evaluable
- do not convert missing abundance estimates to zero
- do not merge abundance and detection FDR values into a new significance test
- keep abundance-only, detection-only, both, neither, and not-jointly-evaluable states explicit

---

# 15. Plotting policy

All active publication-oriented plotting code should follow Nature-style scientific figure principles.

Current plotting rules:

- prefer one figure per output
- avoid unnecessary multi-panel composites
- use clean scientific typography
- use restrained, consistent colour palettes
- keep labels readable
- preserve adequate margins and whitespace
- export editable PDF/SVG where appropriate
- export high-resolution PNG previews
- plot meaningful summaries instead of only exporting tables when a visual representation is useful
- do not alter statistical definitions merely to make a figure look better
- figure code must remain downstream of the locked statistical analysis unless explicitly stated otherwise

When a Nature-related plotting skill is available, use it for figure-code design.

---

# 16. Code modification policy

For maintenance tasks, the default rule is:

```text
MODIFY CODE ONLY
DO NOT RUN ANALYSIS
```

Unless explicitly requested, do NOT:

- execute R analysis scripts
- execute Python analysis scripts
- fit models
- regenerate figures
- regenerate result tables
- rerun the whole pipeline
- modify raw data
- delete additional scripts
- archive additional scripts

Static inspection may be used when necessary.

Static syntax checking should only be performed when explicitly requested or when it does not execute the scientific workflow.

---

# 17. R coding rule

This is a persistent project-wide rule.

Never break double-bracket indexing.

Correct:

```r
x[[name]] <- value
folds_now[[fold_id]]
pathway_rank[[sample_name]]
```

Never generate malformed forms that split `[[...]]` across lines.

Before finalising R code, check pairing of:

```text
[[ ]]
[ ]
( )
{ }
```

Also check ggplot continuation so that `+` is not left as a standalone expression.

---

# 18. Documentation policy

Historical README files are retained as change records.

They are NOT the primary current context source.

Authority is domain-specific:

```text
Scientific / statistical design truth -> PROJECT_CONTEXT.md
File-role / activity truth           -> FILE_STATUS.md
Current work-progress truth           -> TASK_CURRENT.md
Implementation truth                  -> current active source code
Historical rationale / chronology     -> README files
```

If sources conflict, resolve the conflict according to the domain above rather than using one universal priority list.

---

# 19. Context-reading rule for Codex

At the beginning of a new task:

1. Read `CODEX_WORKFLOW.md`.
2. Read `PROJECT_CONTEXT.md`.
3. Read `FILE_STATUS.md`.
4. Read `TASK_CURRENT.md`.
5. Do NOT recursively scan the whole repository.
6. Do NOT read every historical README.
7. Inspect only files required by the current `In progress` task.
8. Read direct dependencies only when necessary.
9. Deprecated and archived files must not be interpreted as part of the current workflow.
10. Historical files may be consulted only when the task specifically requires understanding an old decision.

This rule exists to keep long-term project context accurate and to minimise unnecessary context usage.
