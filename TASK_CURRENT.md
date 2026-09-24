# TASK_CURRENT.md

Last updated: 2026-09-23

# Current Task — 06a PCA + UMAP Static Readiness Review

This file describes ONLY the current task.

It is the authoritative source for CURRENT WORK PROGRESS and the next breakpoint.

It is intended to support interrupted / resumed Codex work without forcing Codex to rescan the entire project.

It may be replaced when the next task begins.

---

# 1. Current objective

Perform a final static readiness review of `06a_limma_core_figures.R` PCA and UMAP code so that the user may run it manually.

This is a code-readiness task, not an analysis rerun or a new figure-maintenance round.

Status: static review complete. The revised PCA/UMAP code is IMPLEMENTED / READY FOR USER EXECUTION, but has NOT been executed or runtime validated and no scientific result is confirmed.

---

# 2. Hard restriction

```text
DO NOT RUN THE ANALYSIS.
```

Only modify code and documentation.

Do NOT:

- execute R analysis scripts
- execute Python analysis scripts
- fit statistical models
- regenerate figures
- regenerate statistical result tables
- run the complete pipeline
- rerun limma
- rerun detection models
- modify raw data
- change the locked primary statistical model
- change detection thresholds
- delete additional scripts
- archive additional scripts

The only currently approved deprecated / archived analysis scripts remain:

```text
06_limma_result_plots.R
07_dose_trend_analysis.R
```

Do not remove anything else.

---

# 3. Progress snapshot

## 3.1 Completed / established

### Project-control system

Completed:

- `CODEX_WORKFLOW.md` defines Codex working behaviour.
- `PROJECT_CONTEXT.md` defines current scientific / analytical truth.
- `FILE_STATUS.md` defines file role / activity truth.
- `TASK_CURRENT.md` defines the current work breakpoint.
- historical README files remain change records and are not read by default.

### Scientific / workflow decisions already established

Completed / locked:

- P1/P2/P3 mapping chain is frozen.
- primary quantitative set remains 1434 proteins.
- primary limma remains categorical exposure-group analysis with environment adjustment.
- primary limma keeps NA and uses no imputation.
- `06_limma_result_plots.R` remains outside the active workflow.
- `07_dose_trend_analysis.R` remains outside the active interpretation workflow.
- acquisition date is a proxy / sensitivity variable, not a confirmed technical batch.
- detection-based analysis is now a main branch alongside quantitative abundance.
- `run_all.py` is the canonical UPSTREAM descriptive/filtering entry point only.
- `06d_integrated_results.R` is an active downstream integration / figure script.
- display terminology should use Control / Short exposure / Long exposure while retaining historical compatibility keys where required.

### v2.0 maintenance already completed in code

- `06a_limma_core_figures.R` updated.
- `06c_run_replication.R` terminology / naming revised.
- `07_DEP_threshold_summary.R` reorganized / renamed as `DEP_effect_size_summary.R`.
- `10_dose_pattern_classification.R` substantially rewritten.
- unified upstream `run_all.py` established.
- compatibility entry point retained.
- `README_CODE_MAINTENANCE_v2.0.md` created.

### v2.1 extension already completed in code

- `04_covariate_QC.R` added / implemented.
- `dose_restricted_detection.py` added / implemented.
- `08_detection_pattern_analysis.R` added / implemented.
- `06d_integrated_results.R` added / implemented.
- `v21_common.R` added / implemented.
- abundance + detection integrated interpretation layer added.
- Nature-style plotting infrastructure expanded.
- `README_CODE_MAINTENANCE_v2.1.md` created.

IMPORTANT:

These are implementation states only.

They do NOT mean the new scientific analyses were executed or validated.

---

# 4. File-by-file breakpoint table

This table is the main resume map.

Use it before reopening any code.

| File | Current status | Last known state | Next action |
|---|---|---|---|
| `README_CODE_MAINTENANCE_v2.2.md` | DONE | final historical maintenance record created; records the completed Nature-style figure / naming / consistency cleanup without claiming unreviewed files complete | maintenance round closed; do not start a new task without explicit instruction |
| `nature_plotting.py` | DONE | final consistency review confirmed shared single-figure theme, PDF/SVG/600 dpi PNG export, and matching source-data support for batch saves | complete; no data handling, filtering, or modelling is performed by the helper |
| `v21_common.R` | DONE | final consistency review confirmed shared exposure terminology, restrained R theme, independent-figure export, and matching source-data naming defaults | complete; no analysis definitions or clustering decisions are set by the helper |
| `describe_proteomics.py` | DONE | independent descriptive figures use standardized `Figure_01_` / `Figure_02_` names with explicit matching source-data exports; legacy panel labels were removed from generated descriptions | complete; descriptive definitions and input checks are unchanged |
| `detection_gradient.py` | DONE | independent detection-gradient figures use standardized `Figure_03_` names with matching source-data exports and clear group/environment titles | complete; detection thresholds and calculations are unchanged |
| `design_composition.py` | DONE | independent composition figures use standardized `Figure_04_` names; display text uses Control / Short exposure / Long exposure and acquisition-date proxy terminology | complete; sample-composition definitions and counts are unchanged |
| `complete_four_layers.py` | DONE | static review confirmed independent coverage, sample-depth, and detection-landscape outputs; no code change required | complete; do not reopen unless a concrete dependency or output-consistency issue arises |
| `06a_limma_core_figures.R` | IMPLEMENTED / READY FOR USER EXECUTION | final static PCA/UMAP review complete: PCA uses the complete-case primary matrix with cached-score/sign-aware consistency checks; UMAP uses complete-case, centered, non-zero-variance proteins with all samples retained and explicit sample-ID metadata joining | NOT EXECUTED and NOT runtime validated; user may run manually, and no scientific result is confirmed |
| `06b_limma_robustness.R` | DONE | formal output naming is standardized; all metrics and sensitivity definitions are retained | a small number of legacy B1/B2/B3 section comments remain for final static cleanup only; they do not affect DONE status |
| `06c_run_replication.R` | DONE | formal figure and source-data naming is standardized; acquisition-date-stratified robustness wording and the within-stratum sensitivity model are retained | a small number of legacy C1/C2 section comments remain for final static cleanup only; they do not affect DONE status |
| `06d_integrated_results.R` | DONE | static review completed; independent MA, effect-rank, forest, single-protein profile, integrated abundance × detection, outside-core, and evidence-count outputs use standardized `Figure_06d_` display-name-based filenames and matching source-data naming | complete; no limma refit, no missing-abundance-to-0 conversion, and abundance/detection evidence remain separate |
| `04_covariate_QC.R` | DONE | static review confirmed independent completeness, raw-token, blank-missingness, numeric-distribution, categorical-balance, and QC-association outputs; standardized `Figure_04_covariate_QC_` filenames pair with source-data exports | complete; raw 0 / Unknown / NA / missing distinctions, QC definitions, and descriptive statistics are unchanged |
| `08_detection_pattern_analysis.R` | DONE | static review confirmed independent model-status, effect/CI, and acquisition-date sensitivity figures; standardized `Figure_08_detection_` filenames pair with source-data exports, and display labels retain all failed/non-estimable/separation states | complete; detection thresholds, logistic models, FDR, robustness definitions, and detection-versus-abundance interpretation are unchanged |
| `DEP_effect_size_summary.R` | DONE | static review confirmed independent threshold-count and all-tested-protein log2FC-distribution figures; standardized `Figure_DEP_effect_size_summary_` filenames pair with source-data exports and display the locked nested FDR/effect-size layers | complete; DEP definition, contrast, FDR threshold, log2FC thresholds, and statistical logic are unchanged |
| `09_DEP_characterization.R` | DONE | static review confirmed independent DEP-direction and top-30-by-FDR / top-30-by-absolute-moderated-t figures; standardized `Figure_09_DEP_characterization_` filenames pair with source-data exports and use Long vs Short exposure terminology | complete; existing figures sufficiently express the module, and DEP definition, ranking, direction, FDR, and contrast logic are unchanged |
| `10_protein_clustering.R` | DONE | static review confirmed independent all-DEP/top-50 heatmaps, hierarchical cluster-size/effect-distribution, and exploratory K-means sensitivity outputs; standardized `Figure_10_protein_clustering_` filenames pair with source-data exports | complete; exploratory clustering, clustering-only NA->0, protein-wise z-score, hierarchical clustering, and K-means parameters are unchanged |
| `10_dose_pattern_classification.R` | HOLD / REVIEW | v2.0 rewrite exists | do not expand during current plotting round unless explicitly requested |
| `11_pattern_protein_annotation.R` | HOLD | depends on old / migrated pattern schema | no action |
| `normalization_design_diagnostics.py` | FROZEN | established diagnostic step | no action |
| `05_limma_dose_analysis.R` | ACTIVE-LOCKED | primary analysis locked | no action |

IMPORTANT:

A `PARTIAL` label means prior edits exist but the exact final visual state has not been confirmed in this project-control file.

Codex must inspect the current file before deciding whether further edits are needed.

Do NOT blindly rewrite files marked PARTIAL.

---

# 5. Current In progress

Static code work is complete. No further Codex code action is scheduled.

```text
NEXT BREAKPOINT: user manual execution of 06a_limma_core_figures.R.
This execution is outside the present static-review task. Return with the runtime log only if an error occurs.
```

For each target:

1. inspect current code
2. determine whether Nature-style / independent-output requirements are already satisfied
3. change only what is still needed
4. update this table immediately after the file is completed
5. move to the next unfinished file

---

# 6. Current To do

The items below are retained as the historical v2.2 cleanup checklist and are not active for the present 06a readiness task. The v2.2 cleanup remains closed; no further 06a code changes are scheduled before user execution.

After file-by-file plotting work is complete:

### A. Final static review

Review modified active plotting files for:

- broken function references
- duplicated plotting calls
- inconsistent output names
- inconsistent figure directories
- malformed R indexing
- malformed ggplot `+` placement
- accidental model / threshold changes
- accidental restoration of deprecated terminology

Do NOT execute the scientific workflow.

### B. Check output naming / directory consistency

Check that:

- figure filenames are informative
- output directories are consistent
- old and new naming does not create ambiguous duplicates
- new plotting code does not overwrite unrelated historical results

### C. Update project-control files only if needed

Update `FILE_STATUS.md` only if file roles changed.

Update `PROJECT_CONTEXT.md` only if scientific / analytical design changed.

Do not update them for purely cosmetic edits.

### D. Create the next README version

Create a NEW README inside the existing `reademe` folder.

Do not overwrite:

```text
README_CODE_MAINTENANCE_v2.0.md
README_CODE_MAINTENANCE_v2.1.md
```

The new README should record:

1. files modified
2. files added
3. files deprecated
4. plotting changes
5. whether statistical logic changed
6. whether analysis was executed
7. unfinished modules
8. terminology changes
9. dependencies added or removed

The README should be concise and chronological.

Do not duplicate the full content of `PROJECT_CONTEXT.md`.

---

# 7. Hold / not part of the current task

The following items are currently paused or outside this plotting-maintenance task:

```text
old pattern-protein annotation
GO / KEGG enrichment
final biological acceptance of rewritten exposure-pattern classification
linear trend analysis
new biological interpretation work
new statistical model design
new threshold design
```

Do not expand these modules during the current task unless explicitly instructed.

---

# 8. Plotting requirements

Use Nature-style scientific figure principles.

Where a Nature figure skill is available, use it to guide figure-code design.

Main requirements:

- prefer one plot per output
- multi-panel composites are not required
- split unnecessarily crowded composite figures into independent figures
- use clean scientific typography
- use restrained and consistent colour palettes
- avoid decorative styling
- keep axis labels concise and readable
- keep legends compact
- avoid excessively small text
- preserve useful whitespace
- keep figure dimensions appropriate for publication
- ensure vector-friendly outputs
- prefer editable PDF/SVG where appropriate
- keep high-resolution PNG preview output
- retain source-data output when already part of the workflow

Do not alter statistics to improve aesthetics.

---

# 9. Plot rather than table when useful

If an active analysis currently exports an important summary only as CSV/table and the result has a clear graphical representation, add plotting CODE where useful.

Priority examples:

- detection-pattern counts
- model-estimation status
- DEP effect-size distribution
- significant-protein counts
- cluster-size distribution
- sensitivity / robustness summaries
- covariate completeness
- threshold summaries

Do NOT create meaningless charts merely to reduce table use.

Preferred pattern:

```text
table for exact values
+
figure for interpretation
```

when both are useful.

---

# 10. Independent figures

Current preference:

```text
one figure = one output
```

Do not force several unrelated plots into one large composite.

A multi-panel figure is acceptable only when the panels answer one tightly linked scientific question.

Otherwise produce independent figure files.

---

# 11. Statistical logic that must remain unchanged

Do not modify the primary abundance model.

Scientific interpretation:

```text
abundance ~ exposure group + environment
```

Historical implementation may still use:

```text
dose + environment
```

Do not modify the primary quantitative threshold:

```text
>=70% detection in each of Control / Short / Long exposure
```

Do not modify formal limma sensitivity thresholds unless explicitly requested.

Do not reintroduce linear trend analysis.

Do not change Long-vs-Short DEP definition:

```text
BH FDR < 0.05
```

Do not change missing-value rules of the primary limma analysis.

---

# 12. Terminology rule

Preferred display wording:

```text
Control
Short exposure
Long exposure
Short exposure vs Control
Long exposure vs Control
Long vs Short exposure
```

Historical internal keys may remain:

```text
control
low
high
Low_vs_Control
High_vs_Control
High_vs_Low
```

For `06c_run_replication.R` and related plots:

Preferred wording:

```text
MS run date
run-date stratum
acquisition-date stratum
MS run-date proxy
acquisition-date-stratified robustness
```

Avoid:

```text
confirmed technical batch
independent biological replication
```

unless new metadata proves otherwise.

---

# 13. Detection branch rule

Detection-based results and abundance-based results must remain separate.

Do not classify proteins outside the primary abundance core as:

```text
not differentially expressed
```

Preferred interpretation:

```text
abundance not evaluated in the primary quantitative model
```

Detection modelling failure / separation / non-estimability must remain explicit.

Do not silently substitute another estimation method.

---

# 14. R syntax rule

Before finalising any modified R file, visually verify:

```text
[[ ]]
[ ]
( )
{ }
```

Never split valid double-bracket indexing.

Examples that must remain valid:

```r
x[[name]] <- value
results[[contrast_name]]
folds_now[[fold_id]]
```

Also ensure ggplot continuation does not leave a standalone `+` expression.

---

# 15. Continuous breakpoint update rule

After completing ONE meaningful file / subtask:

1. update the file-by-file breakpoint table
2. change its status to `DONE` when truly complete
3. record a concise last-known state
4. identify the next file under `In progress`

Do not wait until the whole plotting round is finished.

The file must always answer:

> If Codex stops now, what exact file should the next session open next?

---

# 16. Resume rule for interrupted Codex sessions

If a Codex session stops because of usage limits or context limits:

1. start a new session
2. read:
   - `CODEX_WORKFLOW.md`
   - `PROJECT_CONTEXT.md`
   - `FILE_STATUS.md`
   - `TASK_CURRENT.md`
3. find the first unfinished item in the file-by-file breakpoint table / In progress section
4. inspect only that target file and direct dependencies
5. continue from there
6. do not rescan files marked DONE unless there is a concrete dependency or consistency issue
7. keep edits incremental
8. update `TASK_CURRENT.md` after each completed subtask

This rule is specifically intended to reduce Codex context consumption.

---

# 17. Current execution status

For this task:

```text
Analysis execution: NOT ALLOWED
Figure generation: NOT ALLOWED
Model fitting: NOT ALLOWED
Pipeline execution: NOT ALLOWED
Code modification: ALLOWED
README update: ALLOWED
```

---

# 18. Completion condition

The current task is complete when:

- all relevant active plotting code has been reviewed
- active plotting code follows the agreed Nature-style principles
- unnecessarily crowded composite figures are split where scientifically appropriate
- important table-only summaries have sensible plotting code where useful
- `06d_integrated_results.R` has been included in the review
- output naming and figure-directory logic are internally consistent
- statistical definitions remain unchanged
- no scientific analysis has been executed
- no extra scripts have been deleted or archived
- project-control files are updated only where their domain changed
- a new README version documents the completed maintenance round
