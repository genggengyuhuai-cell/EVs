# MASTER_PROJECT_AUDIT_BACKLOG.md

Last updated: 2026-09-24

# Plasma / EV Project — Master Audit and Backlog

## 1. Purpose

This file is the project-level audit and backlog.

It exists to preserve important work items that emerged across project conversations without overloading `TASK_CURRENT.md`.

It is **not** the authoritative source for:
- scientific/statistical design — use `PROJECT_CONTEXT.md`;
- file role/activity — use `FILE_STATUS.md`;
- the immediate breakpoint — use `TASK_CURRENT.md`;
- implementation truth — inspect current active source code;
- chronological maintenance history — use versioned README files.

This file answers:

> What has been completed, what still requires validation, what remains scientifically unresolved, what is deliberately deferred, and what future work must not be forgotten?

Status vocabulary used here:

```text
DONE / FROZEN
CODE + STATIC DONE / RUNTIME PENDING
RUNTIME PENDING
SCIENTIFIC REVIEW REQUIRED
PLANNED
HOLD
DEPRECATED
SEPARATE WORKSTREAM
```

A code implementation, static review, runtime validation, and scientific acceptance are separate states and must never be treated as interchangeable.

---

# 2. Current project position

The plasma exposure-proteomics pipeline has passed the main implementation/static-maintenance stage.

The detection-analysis universe correction has also been implemented and statically reviewed.

The controlled runtime-validation and core scientific-validation stages
have been completed for the current plasma exposure-proteomics pipeline.

The current project breakpoint is:

```text
PHASE 5 — BIOLOGICAL DOWNSTREAM ANALYSIS
CURRENT SUBSTEP — protein-level biological audit before formal enrichment
```

The immediate sequence is:

```text
review annotated 256 primary Long-vs-Short DEP
        ↓
compare top-FDR and top-effect-size proteins
        ↓
identify recurring protein families / biological themes
        ↓
lock enrichment foreground/background/database contract
        ↓
run formal enrichment / network analyses only after that contract is explicit
```

Do not reopen validated core statistical modules without a concrete inconsistency
or an explicitly reopened scientific question.

---

# 3. Locked / completed foundations

## 3.1 Sample mapping

Status:

```text
DONE / FROZEN
```

Established state:

- P1 / P2 / P3 mapping workflow is frozen.
- 519 sample columns are mapped.
- Primary exposure-defined analyses use 515 samples.
- Mapping logic must not be reopened during unrelated work.

Remaining action:

```text
NONE unless mapping is explicitly reopened.
```

---

## 3.2 Exposure terminology

Status:

```text
SCIENTIFIC DISPLAY TERMINOLOGY LOCKED
INTERNAL COMPATIBILITY MIGRATION DEFERRED
```

Scientific/display terminology:

```text
Control
Short exposure
Long exposure

Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

Historical compatibility keys may remain internally:

```text
control / low / high
dose

Low_vs_Control
High_vs_Control
High_vs_Low
```

Do not perform repository-wide mechanical replacement of `low`, `high`, or `dose`.

A full internal-key migration, if still desired, must be a separate post-validation task with explicit dependency checks.

---

# 4. Branch A — quantitative abundance analysis

## 4.1 Primary quantitative universe

Status:

```text
LOCKED DEFINITION
RUNTIME RECONFIRMATION PENDING
```

Primary rule:

```text
>=70% detection in Control
AND
>=70% detection in Short exposure
AND
>=70% detection in Long exposure
```

Historical/expected primary protein count:

```text
1434
```

The number 1434 is an expected historical checkpoint, not a newly runtime-confirmed result.

Upstream sets also include:

```text
50%
60%
70%
80%
```

Formal limma threshold sensitivities remain:

```text
50%
80%
```

The 60% quantitative set is an upstream/descriptive set and is not a separate locked formal limma sensitivity branch.

---

## 4.2 Primary abundance model

Status:

```text
CODE + STATIC DONE / RUNTIME PENDING
```

Locked principles:

```text
log2(PG.Quantity)
NA retained
no imputation
no abundance NA -> 0
no additional normalization in the primary model
categorical exposure group
environment adjustment
lmFit()
contrasts.fit()
eBayes(trend = TRUE, robust = TRUE)
BH FDR
```

Important:

`eBayes(trend = TRUE)` is limma mean–variance trend modelling. It is not the deprecated exposure `0/1/2` trend analysis.

Primary contrasts:

```text
Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

Historical internal contrast keys may remain for compatibility.

---

## 4.3 Deprecated continuous exposure trend

Status:

```text
DEPRECATED
```

The historical route:

```text
control = 0
low = 1
high = 2
```

must not be restored to the active primary workflow.

Do not restore:

```text
dose_numeric
make_trend_design
linear_dose_trend
07_SECONDARY_linear_dose_trend.csv
07_SECONDARY_linear_dose_trend_fit.rds
```

unless the scientific question is explicitly reopened.

---

# 5. Branch B — detection-based analysis

## 5.1 Detection-analysis universe

Status:

```text
CODE + STATIC DONE / RUNTIME PENDING
```

Frozen rule:

```text
max(
    Control detection rate,
    Short-exposure detection rate,
    Long-exposure detection rate
) >= 0.60
```

Examples that must enter the universe:

```text
Control  Short  Long
0%       60%    12%
60%      30%    40%
35%      65%    52%
62%      61%    58%
```

Example that must not enter:

```text
30%      40%    50%
```

The full all-protein detection-rate mother table remains intact.

The `<20%` criterion is classification-only and must never determine detection-analysis universe membership.

---

## 5.2 Detection modelling and multiple testing

Status:

```text
CODE + STATIC DONE / RUNTIME PENDING
```

Current contract:

- primary logistic models operate only on the fixed >=60%-in-any-group universe;
- every model contrast uses that complete fixed universe as its BH correction family;
- non-estimable/model-failure states remain explicit;
- proteins outside the universe remain in the mother table but are not modelled;
- no alternative estimator should be silently substituted.

Runtime validation must confirm the actual universe size, model-status distribution, OR/logOR/CI/FDR outputs, and output contracts.

---

## 5.3 Detection pattern classification thresholds

Status:

```text
LOCKED AS A SEPARATE CONCEPT
```

Pattern thresholds:

```text
70% = primary restricted-detection classification
60% = sensitivity restricted-detection classification
```

These must not be confused with the fixed >=60%-in-any-group modelling universe.

The `<20%` rule may participate in specific/restricted classification but not universe retention.

---

# 6. Abundance × detection integration

Status:

```text
CODE + STATIC DONE / RUNTIME PENDING
```

Required interpretation states remain explicit:

```text
abundance-only
detection-only
both
neither
not jointly evaluable
```

Integration requirements:

- retain the full detection mother table;
- distinguish outside-universe/not-modelled proteins from negative model results;
- do not convert missing abundance estimates to zero;
- do not create a combined abundance/detection significance test;
- do not alter abundance statistics or abundance FDR.

Runtime/scientific validation must inspect concordance and discordance between abundance and detection evidence.

---

# 7. Pipeline runners and execution control

## 7.1 Python runner

Status:

```text
CODE + STATIC DONE / NEVER FORMALLY RUNTIME VALIDATED
```

Approved sequence:

```text
run_all.py
normalization_design_diagnostics.py
dose_restricted_detection.py
```

Requirements:

- explicit whitelist;
- fail immediately on genuine failure;
- no dynamic `.py` discovery;
- no broad cleanup.

---

## 7.2 R runner

Status:

```text
CODE + STATIC DONE / NEVER FORMALLY RUNTIME VALIDATED
```

Approved active sequence:

```text
05_limma_dose_analysis.R
06a_limma_core_figures.R
06b_limma_robustness.R
06c_run_replication.R
04_covariate_QC.R
08_detection_pattern_analysis.R
06d_integrated_results.R
09_DEP_characterization.R
DEP_effect_size_summary.R
10_protein_clustering.R
10_dose_pattern_classification.R
```

Each R script should run as an independent:

```text
Rscript --vanilla
```

process.

A non-zero exit must stop the runner.

`11_pattern_protein_annotation.R` must remain outside this active sequence.

---

# 8. Immediate runtime-validation backlog

Status:

```text
CURRENT PRIORITY
```

## Stage 1 — Python upstream

Run:

```text
descriptive/run_full_upstream.py
```

Check:

- expected exposure-defined sample count = 515;
- generated quantitative 50/60/70/80 sets;
- historical/expected >=70% primary core = 1434;
- actual `In_detection_analysis_universe` count;
- detection mother-table completeness;
- output filenames/contracts;
- warnings/errors;
- no accidental modification of frozen inputs.

Do not convert historical expected counts into “validated” counts until the rerun confirms them.

## Stage 2 — R preparation

Before running R:

- inspect target output directories;
- respect `v21_output()` refusal to overwrite non-empty directories;
- archive/repoint only explicit reproducible outputs when necessary;
- do not recursively delete directories;
- never clean raw data, mapping files, curated metadata, frozen inputs, archive history, or control documents.

## Stage 3 — R active runner

Run:

```text
descriptive/run_active_r.R
```

Use fail-fast execution.

For any failure:

```text
stop
identify exact script
identify exact error
make smallest necessary repair
rerun from an appropriate controlled point
```

Do not use runtime validation as permission for broad refactoring.

---

# 9. Scientific-validation backlog after runtime success

Status:

```text
PENDING AFTER RUNTIME
```

Re-evaluate:

### Sample / universe checks
- 515 exposure-defined samples;
- 1434 primary quantitative proteins;
- 50/60/70/80 quantitative sets;
- detection-analysis universe size.

### Primary abundance results
- Short exposure vs Control;
- Long exposure vs Control;
- Long vs Short exposure;
- DEP counts and directions;
- effect-size distributions;
- abundance FDR outputs.

### Sample structure
- PCA;
- UMAP;
- environment structure;
- acquisition-date/run-date proxy structure.

UMAP remains supplementary; it does not replace PCA.

### Robustness
- median-normalization sensitivity;
- acquisition-date proxy sensitivity;
- 50% / 80% threshold sensitivity;
- complete-case analysis;
- within-run/acquisition-date-stratified robustness.

### Detection
- logistic model status;
- separation/non-estimability;
- OR/logOR and confidence intervals;
- BH FDR;
- acquisition-date sensitivity;
- restricted/specific pattern summaries.

### Integration
- abundance-only;
- detection-only;
- both;
- neither;
- not jointly evaluable;
- biologically meaningful concordance/discordance.

### Downstream DEP analysis
- DEP characterization;
- effect-size summaries;
- clustering stability and interpretability.

---

# 10. Exposure-pattern classification and annotation

## 10.1 `10_dose_pattern_classification.R`

Status:

```text
DONE / SCIENTIFICALLY ACCEPTED AS DESCRIPTIVE-EXPLORATORY
```

Final v2 runtime:

```text
Short_peak        = 249
Long_suppression  = 7
Total             = 256
```

The classification is mutually exclusive and exhaustive for the 256 primary
Long-vs-Short abundance DEP. Review of the actual three-group effect
distribution showed that the dominant Short-high shape is not merely an
artifact of the 0.05 descriptive tolerance.

Scientific qualification is locked: these labels describe unadjusted observed
group-mean profiles. They are not independent inferential discoveries and do
not replace the primary limma contrasts.

Canonical output directory:

```text
10_dose_pattern_classification_v2
```

The historical `10_dose_pattern_classification/` Low/High output is retained
only as historical/compatibility material and must not be used as the current
pattern source.

## 10.2 `11_pattern_protein_annotation.R`

Status:

```text
DONE / FINAL RUNTIME PASS
```

Final mapping QC:

```text
Input_DEP                    = 256
UniProt_mapped               = 256
UniProt_unmapped             = 0
UniProt_mapping_rate_percent = 100
```

All 256 primary Long-vs-Short DEP are annotated and retained. Pattern v2 is
metadata only and does not filter the inferential universe. Top statistical
and effect-size outputs are ranked from the primary limma results.

The next step is not further pattern reclassification. It is protein-level
biological interpretation of the annotated 256-protein set, followed by an
explicit enrichment-design contract.

# 11. Preanalytical / methodological QC backlog

Status:

```text
PLANNED — IMPORTANT, NOT CURRENT BLOCKER
```

Historical project discussions identified preanalytical variation as a major methodological theme.

Items to formalize later include:

## 11.1 Processing / holding time
Potential variables already discussed include:

```text
WoleBlood_oldTime
Plasma_HoldTime_h
```

Future questions:

- association with missingness/detection rate;
- association with total protein signal;
- association with PCA/sample structure;
- protein-specific effects;
- whether exposure groups/environment are confounded with processing time.

Do not assume a processing-time effect before analysing available metadata.

## 11.2 Freeze–thaw

Freeze–thaw was identified as an important plasma-proteomics methodological factor.

Current project status:

```text
scientifically relevant
not yet a formal current analysis module
```

Before adding it, verify whether reliable sample-level freeze–thaw metadata actually exist.

## 11.3 Centrifugation / plasma preparation

Centrifugation and plasma preparation are important preanalytical considerations, but the current project control files do not establish a complete sample-level centrifugation variable suitable for modelling.

Do not fabricate such metadata.

## 11.4 Platelet / hemolysis / contamination signatures

Status:

```text
PLANNED
```

Potential future QC layer:

- platelet-associated protein signature;
- hemolysis-associated protein signature;
- other preanalytical contamination indicators where defensible.

Purpose:

```text
QC / sensitivity / interpretation
```

not automatic sample deletion and not automatic adjustment of the primary model.

A formal signature list and decision rule must be established before implementation.

---

# 12. Covariates

## 12.1 Age / Sex

Status:

```text
PLANNED / DEFERRED
NOT A CURRENT BLOCKER
```

Use only if fields exist and completeness/quality are adequate.

Do not fabricate them and do not automatically add them to the primary model.

When revisited, first perform:

```text
availability
missingness
distribution
group balance
confounding assessment
```

before deciding whether any sensitivity model is justified.

## 12.2 Existing optional preanalytical covariates

Potential metadata include:

```text
Tube_Mixing
WoleBlood_oldTime
Plasma_HoldTime_h
TREAT2
```

`04_covariate_QC.R` should be runtime validated before expanding this branch.

Literal `0`, `Unknown`, `NA`, missing, and empty string must remain distinguishable.

---

# 13. Acquisition date / MS run

Status:

```text
SCIENTIFIC WORDING LOCKED
RUNTIME/SCIENTIFIC VALIDATION PENDING
```

Allowed interpretation:

```text
MS run date
run-date proxy
acquisition-date proxy
acquisition-date stratum
MS run-date proxy
```

Do not call it a confirmed technical batch without external experimental records establishing that interpretation.

Current use:

```text
descriptive structure
sensitivity / robustness
```

not replacement of the primary exposure + environment model.

---

# 14. QC / reference / technical replicate assessment

Status:

```text
PLANNED
```

Historical discussions identified this as unfinished.

Future audit should first determine what the dataset actually contains:

- QC injections;
- pooled/reference samples;
- technical replicates;
- repeated acquisitions;
- reference-channel or normalization controls, if any.

Only then define metrics such as:

- CV;
- correlation;
- drift;
- missingness;
- run-order effects;
- reproducibility.

Do not infer technical replicate structure from acquisition date alone.

---

# 15. Spectronaut upstream processing / normalization

Status:

```text
UNRESOLVED — VERIFY LATER
```

The primary statistical pipeline intentionally performs no additional normalization.

However, a separate methodological question remains:

> What normalization / cross-run normalization was actually applied in the specific Spectronaut export used for this project?

Future action:

1. obtain/export the actual Spectronaut processing settings or project report;
2. document normalization mode;
3. document protein-group quantification settings relevant to `PG.Quantity`;
4. determine whether any cross-run normalization was already applied;
5. interpret downstream “no additional normalization” in that upstream context.

Do not infer the project's actual Spectronaut settings from unrelated published papers.

Median normalization remains a downstream sensitivity analysis unless the scientific design is explicitly changed.

---

# 16. Missing-value policy audit

Status:

```text
LOCKED
```

Primary abundance:

```text
NA retained
no imputation
no NA -> 0
```

Detection:

```text
detection/non-detection is itself information
```

Exploratory clustering/heatmap:

```text
NA -> 0 allowed only where explicitly defined for that visualization/clustering matrix
```

Future reviews must ensure clustering-specific preprocessing never leaks into primary limma or detection modelling.

---

# 17. Functional annotation / network / pathway backlog

Status:

```text
CURRENT — PROTEIN-LEVEL AUDIT FIRST; FORMAL ENRICHMENT CONTRACT NEXT
```

Completed prerequisite:

- protein annotation of all 256 primary Long-vs-Short DEP;
- UniProt mapping 256/256 (100%).

Current immediate work:

- inspect the full annotated 256-protein set;
- compare top-FDR and top-effect-size proteins;
- identify recurring protein families and plausible functional themes.

Before GO/Reactome/KEGG/STRING/PPI is executed, explicitly lock:

1. foreground definition;
2. defensible tested-protein background/universe;
3. identifier mapping;
4. database(s) and versions where available;
5. multiple-testing procedure;
6. handling of overlapping/redundant terms;
7. separation of abundance-derived and detection-derived candidate sets.

The whole human proteome must not be silently used as the enrichment
background when the scientific tested universe is narrower. Do not reuse
enrichment universes or candidate-selection rules from the separate EV
workstream without explicit justification.

---

# 18. EV workstream

Status:

```text
SEPARATE WORKSTREAM
```

Project conversations also contain a broader EV/plasma-proteomics research direction, including questions around:

- extracellular vesicle biology;
- plasma vs serum;
- EV enrichment;
- Mag-Net;
- liquid biopsy;
- EV biomarkers;
- cell-of-origin interpretation;
- EVs in other body fluids;
- competing EV enrichment technologies;
- methodological gaps.

These topics are scientifically relevant to the wider project but are not current blockers for the exposure plasma-proteomics runtime validation.

Keep the workstreams conceptually separate:

```text
Plasma exposure-proteomics pipeline
    ├── abundance
    ├── detection
    ├── integration
    ├── QC / robustness
    └── downstream biology

EV / EV-biomarker workstream
    ├── EV enrichment / characterization
    ├── EV proteomics
    ├── biomarker questions
    ├── network/pathway analysis
    └── predictive modelling where appropriate
```

Do not treat code/results from one workstream as evidence that an analogous task is complete in the other.

---

# 19. Items explicitly not to do now

At the current breakpoint, do not automatically expand into unrelated
methodological branches:

```text
Age/Sex modelling
platelet/hemolysis formal module
technical-replicate redesign
Spectronaut normalization redesign
repository-wide terminology migration
new primary normalization
new imputation strategy
new primary covariates
continuous 0/1/2 exposure trend
```

GO/Reactome/KEGG/STRING/PPI are now eligible downstream tasks only after the
foreground/background/database contract is explicitly locked.

A runtime error may justify a minimal repair; it does not justify reopening unrelated scientific design.

---

# 20. Documentation reconciliation

The control-document roles should remain distinct.

## `PROJECT_CONTEXT.md`

Should contain only current scientific/analytical truth.

It should include/retain:

- two-main-branch architecture;
- primary >=70% quantitative core;
- primary abundance model;
- detection-analysis universe >=60% in any exposure group;
- separation of detection-universe and pattern thresholds;
- missing-value policy;
- acquisition-date proxy interpretation;
- integrated evidence principles;
- explicit current implementation/validation state where useful.

It should **not** become the full backlog.

Recommended current adjustment:

```text
record Detection correction as
CODE IMPLEMENTED + STATICALLY REVIEWED
RUNTIME VALIDATION PENDING
```

Do not add every future EV/QC/enrichment idea.

---

## `TASK_CURRENT.md`

Should contain only the current breakpoint.

Recommended current content focus:

```text
CURRENT:
Controlled runtime validation

NEXT:
1. run descriptive/run_full_upstream.py
2. inspect required checkpoints
3. prepare R outputs safely
4. run descriptive/run_active_r.R fail-fast

DO NOT:
redesign scientific logic
start enrichment
start Age/Sex
activate pattern annotation
perform terminology migration
```

Detection-universe implementation should now appear under completed work, not `In progress`.

Do not copy this entire master backlog into `TASK_CURRENT.md`.

---

## `FILE_STATUS.md`

No task-specific role change is currently required solely because the detection-universe correction was implemented.

Retain existing roles unless runtime/scientific validation produces a real role transition.

In particular:

```text
10_dose_pattern_classification.R = REVIEW
11_pattern_protein_annotation.R  = HOLD
```

Do not change these to ACTIVE-LOCKED/DONE merely because code exists.

---

## README history

README files remain chronological records.

Retain old versions.

Add a new maintenance record for the detection-universe correction, e.g.:

```text
README_CODE_MAINTENANCE_v2.4.md
```

It should record:

- the five files changed in the correction round;
- fixed >=60%-in-any-group universe;
- `<20%` classification-only;
- logistic model universe;
- BH-family definition;
- integration outside-universe handling;
- abundance branch unchanged;
- static checks passed;
- **NO ANALYSIS EXECUTED**;
- **RUNTIME VALIDATION PENDING**.

Do not rewrite v2.2/v2.3 to make them look current.

---

# 21. Recommended phase structure

## Phase 0 — Mapping

```text
DONE / FROZEN
```

## Phase 1 — Pipeline implementation and static maintenance

```text
DONE
```

## Phase 1.5 — Detection scientific-definition correction

```text
DONE
```

## Phase 2 — Controlled runtime validation

```text
DONE
```

## Phase 3 — Scientific validation

```text
DONE for current core abundance/detection/integration pipeline
```

Includes completed review of abundance, detection, integration, robustness,
PCA/UMAP outputs, clustering, and exposure-pattern v2.

## Phase 4 — Methodological / QC expansion

```text
PLANNED / DEFERRED
```

Includes platelet/hemolysis/preanalytical QC, processing/holding-time analysis,
freeze-thaw if metadata exist, QC/reference/technical-replicate assessment,
Spectronaut upstream normalization confirmation, and Age/Sex where justified.

## Phase 5 — Biological downstream analysis

```text
CURRENT
```

Current order:

```text
protein-level audit of annotated 256 DEP
        ↓
lock enrichment design
        ↓
GO / Reactome / KEGG / STRING/PPI as justified
        ↓
manuscript-level biological synthesis
```

## EV workstream

```text
SEPARATE / PARALLEL
```

Do not let its analyses redefine the plasma exposure-proteomics pipeline.

---

# 22. Next exact breakpoint

The next active operation is:

```text
READ / REVIEW:
11_pattern_protein_annotation/
    01_DEP_protein_annotation.csv
    03_DEP_top30_FDR.csv
    04_DEP_top30_effect_size.csv
```

Then establish:

```text
what the 256 DEP represent biologically
which proteins/families dominate top statistical evidence
which proteins/families dominate effect magnitude
the enrichment foreground/background/database contract
```

Do not run formal enrichment before the background/universe is explicitly
defined.

---

# 23. Core audit conclusion

The core pipeline has now run correctly on the real project data and the
structural checkpoints have been validated. The detection universe, abundance
universe, integration contract, DEP set, exposure-pattern v2, and protein
annotation stage are no longer runtime blockers.

The immediate unresolved scientific task is:

> What biological processes, protein families, and pathways are represented by
> the validated 256 primary Long-vs-Short DEP, using an enrichment design with a
> defensible tested-protein background?

The methodological backlog — preanalytics, platelet/hemolysis signatures,
technical/QC replicates, Spectronaut upstream normalization, and Age/Sex —
remains important but is deliberately deferred from the current biological
interpretation breakpoint.

The EV workstream remains related at the broader research-program level but operationally separate from this plasma exposure-proteomics pipeline.
