# FILE_STATUS.md

Last updated: 2026-09-23

# Plasma Proteomics File Status

This file defines the CURRENT activity status and role of project code.

It is the authoritative source for FILE ROLE and FILE ACTIVITY STATUS.

Do not infer status from filename numbering alone.

Status vocabulary:

```text
FROZEN
ACTIVE
ACTIVE-LOCKED
REVIEW
HOLD
PLANNED
DEPRECATED
ARCHIVED
COMPATIBILITY
```

---

# 1. Sample mapping

## P1.py

Status:

```text
FROZEN
```

Role:

Initial sample-mapping audit.

Main purpose:

- inspect original sample headers
- generate mapping candidates
- identify unique mappings
- identify ambiguous mappings
- provide audit trail

Action:

```text
KEEP
DO NOT MODIFY
```

unless mapping is explicitly reopened.

---

## P2.py

Status:

```text
FROZEN
```

Role:

Ambiguous sample-mapping context inspection.

Action:

```text
KEEP
DO NOT MODIFY
```

unless mapping is explicitly reopened.

---

## P3.py

Status:

```text
FROZEN
```

Role:

Final mapping resolution.

Current final mapping is already validated.

Action:

```text
KEEP
DO NOT MODIFY
```

unless mapping is explicitly reopened.

---

# 2. Descriptive / pre-QC Python pipeline

## describe_proteomics.py

Status:

```text
ACTIVE
```

Role:

Core descriptive proteomics summary.

Includes:

- matrix audit
- sample statistics
- protein statistics
- missingness
- detection coverage
- descriptive figures

Current development focus:

- publication-quality plotting
- independent figure outputs

Do not alter core scientific definitions without explicit instruction.

---

## detection_gradient.py

Status:

```text
ACTIVE
```

Role:

Detection-threshold gradients across groups / environments.

Current development focus:

- publication-quality independent plots
- retain threshold logic

---

## design_composition.py

Status:

```text
ACTIVE
```

Role:

Sample-composition and design-description plots.

Important terminology:

```text
MS run date = proxy only
not confirmed technical batch
```

Current development focus:

- publication-quality independent plots
- avoid unnecessary combined panels

---

## complete_four_layers.py

Status:

```text
ACTIVE
```

Role:

Extended descriptive pre-QC summaries and figures.

Current development focus:

- publication-quality plotting
- independent figure outputs where appropriate

---

## dose_quantitative_filtering.py

Status:

```text
ACTIVE-LOCKED
```

Role:

Exposure-group-wise quantitative protein filtering.

Primary rule:

```text
>=70% detection in EACH of control / short / long exposure groups
```

Internal compatibility keys remain:

```text
control / low / high
```

Generated filtering sets include:

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

Scientific filtering logic is currently locked.

Do not change thresholds unless explicitly requested.

---

# 3. Normalization / design diagnostics

## normalization_design_diagnostics.py

Status:

```text
FROZEN
```

Role:

Normalization and design diagnostics used before the primary limma analysis.

Important:

- retained as part of the established analysis history
- not the current development target
- do not modify during plotting-only maintenance
- do not rerun unless explicitly requested

---

# 4. Pipeline entry points

## run_all.py

Status:

```text
ACTIVE
```

Role:

Canonical UPSTREAM descriptive / filtering entry point.

Current scope:

```text
descriptive QC
+
quantitative filtering
```

It is NOT the canonical entry point for the full downstream project.

Do not automatically append limma, detection modelling, integrated figures, annotation, or enrichment modules to this entry point unless explicitly instructed.

---

## run_all_with_dose_filtering.py

Status:

```text
COMPATIBILITY
```

Role:

Older / compatibility entry point.

Keep unless explicitly instructed to remove.

It should not become a second competing canonical upstream workflow.

---

## run_full_upstream.py

Status:

```text
ACTIVE
```

Role:

Future full-upstream orchestration wrapper with the explicit sequence:

```text
run_all.py
normalization_design_diagnostics.py
dose_restricted_detection.py
```

It does not replace the canonical upstream role of `run_all.py`, does not
discover scripts dynamically, and does not clean existing outputs.

---

## run_active_r.R

Status:

```text
ACTIVE
```

Role:

Future explicit-whitelist runner for the approved active R sequence.

It excludes `11_pattern_protein_annotation.R`, archived scripts, and the
deprecated continuous trend route. It does not delete or clean outputs.

---

## test_run_all.py / test_run_all(1).py

Status:

```text
HOLD
```

Role:

Entry-point regression / subprocess behaviour checks.

Do not run unless explicitly requested.

---

# 5. Primary abundance analysis

## 05_limma_dose_analysis.R

Status:

```text
ACTIVE-LOCKED
```

Role:

Primary limma abundance analysis.

Scientific interpretation:

```text
Control
Short exposure
Long exposure
```

Historical internal factor / keys may still use:

```text
dose
control
low
high
```

Primary model:

```text
abundance ~ exposure group + environment
```

Implementation may retain historical `dose` naming.

Primary quantitative protein set:

```text
1434 proteins
```

Primary rules:

- no imputation
- no additional normalization
- NA retained
- robust eBayes
- trend=TRUE in eBayes variance modelling
- categorical contrasts are primary

Do not change this script during plotting-only maintenance unless explicitly instructed.

---

# 6. Plotting / robustness scripts

## 06_limma_result_plots.R

Status:

```text
DEPRECATED
```

Reason:

Superseded by more specific publication-figure scripts.

Action:

```text
REMOVE FROM ACTIVE WORKFLOW
DO NOT DELETE UNLESS EXPLICITLY INSTRUCTED
DO NOT USE AS CURRENT PLOTTING SOURCE
```

---

## 06a_limma_core_figures.R

Status:

```text
ACTIVE
```

Role:

Core publication figures from locked primary analysis.

Current development focus:

- Nature-style plotting
- independent figure outputs
- clean typography
- clean spacing
- avoid unnecessary composite panels
- retain statistical logic
- do not refit limma

Implementation state:

```text
runtime validated 2026-09-24
structural output contract PASS
visual QC PASS
```

---

## 06b_limma_robustness.R

Status:

```text
ACTIVE
```

Role:

Robustness / sensitivity figures.

Current development focus:

- Nature-style plotting
- independent figure outputs where useful
- retain robustness calculations

---

## 06c_run_replication.R

Status:

```text
ACTIVE
```

Role:

Within-run / acquisition-date-stratified sensitivity and robustness analysis.

Important wording:

Preferred:

```text
run-date stratum
acquisition-date stratum
MS run-date proxy
acquisition-date-stratified robustness
```

Avoid:

```text
confirmed batch
independent biological replication
```

Current development focus:

- terminology consistency
- publication-quality figures
- no change to core statistical logic unless explicitly requested

---

## 06d_integrated_results.R

Status:

```text
ACTIVE
```

Role:

Integrated abundance + detection result visualisation and interpretation.

Primary functions include:

- MA plots
- effect-rank plots
- forest plots from saved limma fit uncertainty
- descriptive exposure profiles
- abundance × detection evidence plots
- jointly evaluable / not-jointly-evaluable status handling

Important:

- reads existing abundance and detection results
- does not refit the locked primary limma model
- does not convert missing abundance estimates to zero
- does not create a new combined significance test

Current development focus:

- Nature-style plotting
- independent figure outputs
- output naming consistency
- explicit treatment of non-jointly-evaluable proteins

Implementation state:

```text
runtime validated 2026-09-24
final figure / source-data QC remains pending
```

---

# 7. Deprecated trend analysis

## 07_dose_trend_analysis.R

Status:

```text
DEPRECATED
```

Reason:

The monotonic linear trend route is no longer part of the main analysis.

Action:

```text
REMOVE FROM ACTIVE WORKFLOW
DO NOT DELETE UNLESS EXPLICITLY INSTRUCTED
DO NOT RESTORE WITHOUT EXPLICIT REQUEST
```

---

# 8. DEP analysis

## DEP_effect_size_summary.R

Status:

```text
ACTIVE
```

Previous / related filename:

```text
07_DEP_threshold_summary.R
```

Role:

Summarise FDR-significant Long-vs-Short proteins across effect-size layers.

Historical key:

```text
High_vs_Low
```

Current reporting layers:

```text
FDR < 0.05
FDR < 0.05 & |log2FC| >= 0.5
FDR < 0.05 & |log2FC| >= 1
```

Current development focus:

- clear naming
- plot useful summaries rather than only tables
- do not refit models

---

## 09_DEP_characterization.R

Status:

```text
ACTIVE
```

Role:

Characterise Long-vs-Short FDR-significant proteins.

Historical key may remain:

```text
High_vs_Low
```

Current DEP definition:

```text
BH FDR < 0.05
```

Current significant count:

```text
256
```

Current development focus:

- useful publication-oriented plots in addition to tables
- no change to DEP definition unless explicitly requested

---

# 9. Protein clustering

## 10_protein_clustering.R

Status:

```text
ACTIVE
```

Role:

Exploratory clustering of Long-vs-Short DEP proteins.

Important:

```text
NA -> 0 may be used here for clustering / visualisation only.
```

This rule must not be propagated to limma.

Current development focus:

- publication-quality visualisation
- independent figures where useful
- keep clustering interpretation exploratory

---

# 10. Exposure-pattern classification

## 10_dose_pattern_classification.R

Status:

```text
REVIEW
```

Role:

Classify Control / Short / Long exposure abundance patterns among Long-vs-Short DEP proteins.

History:

- previous logic contained overlapping classification rules
- old plotting code contained duplicated ggplot additions
- script was substantially rewritten in v2.0
- new schema uses mutually exclusive pattern classes

Current instruction:

```text
DO NOT DELETE
DO NOT TREAT AS FULLY LOCKED
```

This module is not the highest-priority active branch at present.

---

## 11_pattern_protein_annotation.R

Status:

```text
HOLD
```

Role:

Annotate proteins from exposure-pattern classification.

Current state:

Paused.

Reason:

Depends on final acceptance / migration of the rewritten pattern-classification schema.

Do not expand this module until the upstream classification is explicitly accepted.

---

# 11. Detection-based main branch

## dose_restricted_detection.py

Status:

```text
ACTIVE
```

Role:

Identify exposure-restricted / exposure-preferential detection patterns from the broader protein universe.

This belongs to the MAIN scientific workflow.

Not merely supplementary.

Implementation state:

```text
runtime validated 2026-09-24
Python upstream PASS
```

---

## 08_detection_pattern_analysis.R

Status:

```text
ACTIVE
```

Role:

Downstream detection-pattern analysis and modelling.

Important:

- detection results must remain distinct from abundance results
- model failures / separation must be reported transparently
- do not silently substitute alternative estimators unless explicitly designed

Current development focus:

- publication-quality figures
- useful model-status visualisation
- retain explicit failure states

Implementation state:

```text
runtime validated 2026-09-24
scientific result validation remains in progress
```

---

## v21_common.R

Status:

```text
ACTIVE
```

Role:

Shared R plotting / helper functions for v2.1 modules.

Current development focus:

- Nature-style plotting helpers
- consistent typography
- consistent export behaviour

---

## nature_plotting.py

Status:

```text
ACTIVE
```

Role:

Shared Python plotting helpers.

Current development focus:

- Nature-style plotting
- consistent export
- reusable single-figure formatting

---

# 12. Covariate QC

## 04_covariate_QC.R

Status:

```text
ACTIVE
```

Role:

Inspect completeness and structure of optional covariates / preanalytical variables.

Important rules:

- distinguish missing values from literal zero
- distinguish `Unknown`, `NA`, `missing`, empty string, and valid numeric zero
- do not fabricate absent Age/Sex fields
- do not automatically add covariates to the main model

Implementation state:

```text
executed without runtime error 2026-09-24
output-contract / scientific QC remains pending
```

---

# 13. README / context files

## CODEX_WORKFLOW.md

Status:

```text
AUTHORITATIVE WORKING PROTOCOL
```

Defines how Codex should read, edit, and maintain project context.

---

## PROJECT_CONTEXT.md

Status:

```text
AUTHORITATIVE SCIENTIFIC / ANALYTICAL CONTEXT
```

Use for scientific and statistical design truth.

---

## FILE_STATUS.md

Status:

```text
AUTHORITATIVE FILE MAP
```

Use for file role and activity truth.

---

## TASK_CURRENT.md

Status:

```text
AUTHORITATIVE CURRENT WORK BREAKPOINT
```

Use for current progress and next action.

This file is replaceable and should describe only the current task.

---

## README_CODE_MAINTENANCE_v2.0.md

Status:

```text
HISTORICAL CHANGE RECORD
```

Do not read by default.

---

## README_CODE_MAINTENANCE_v2.1.md

Status:

```text
HISTORICAL CHANGE RECORD
```

Do not read by default.

Read only when the current task needs v2.1 implementation history.

---

# 14. Files currently allowed to leave the active code path

At present, the only explicitly approved scripts to move out of the active workflow are:

```text
06_limma_result_plots.R
07_dose_trend_analysis.R
```

Do NOT remove additional scripts from the active workflow without explicit instruction.

---

# 15. Default Codex reading behaviour

For every new task:

```text
READ:
CODEX_WORKFLOW.md
PROJECT_CONTEXT.md
FILE_STATUS.md
TASK_CURRENT.md
```

Then:

```text
READ ONLY:
the exact files required by TASK_CURRENT.md
+
their direct dependencies when necessary
```

Do NOT:

- recursively scan the entire project
- inspect every historical README
- reopen frozen mapping code
- use deprecated scripts to infer current design
- treat filename numbering as proof of activity status
