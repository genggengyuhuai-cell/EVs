# Control Document Consolidation Report — 2026-09-29

Scope: unify project control documents to the analysis-v2.1 frozen state.
No analysis was rerun; no frozen result was modified; no scientific file was moved.

## 1. Documents reviewed

- Root: `PROJECT_CONTEXT.md` (rewritten).
- `docs/protocol/`: `ANALYSIS_PLAN_v2.0.md`, `ANALYSIS_PLAN_v2.1.md`,
  `DISCOVERY_VALIDATION_PROTOCOL.md`, `DISCOVERY_VALIDATION_SPLIT_SPEC.md`,
  `STUDY_DESIGN_AUDIT.md`, `V2_IMPLEMENTATION_GAP_AUDIT.md`.
- `docs/workflow/`: `CODEX_WORKFLOW.md`, `FILE_STATUS.md`,
  `MASTER_PROJECT_AUDIT_BACKLOG.md`,
  `MASTER_PROJECT_STATUS_2026-09-28.md`,
  `PROJECT_LOGIC_AUDIT_2026-09-28.md`.
- `docs/task/TASK_CURRENT.md`.
- `docs/README.md`.
- Audit / manifest family: `docs/ACTIVE_MAINLINE_MANIFEST.csv`,
  `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv`,
  `docs/REPOSITORY_RISK_REGISTER.csv`,
  `docs/FINAL_REPOSITORY_RECONSTRUCTION_AUDIT.md`,
  `docs/FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md`,
  `docs/FIGURES_NATURE_V2_2_FILE_MAP.csv`.
- `manuscript_v2_1/audit/STATISTICAL_REPORTING_AUDIT.md`,
  `STATISTICAL_CLAIM_MAP.csv`, `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`,
  `EXPERIMENTAL_DESIGN_REVIEW.md`, `PROJECT_RECONSTRUCTION_PLAN.md`,
  `REVIEWER_RISK_REGISTER.csv`, `MANUSCRIPT_MODULE_MAP.csv`.
- `docs/archive/*` (already-archived historical layer).

Total: 34 documents classified.

## 2. Canonical current documents (21)

- Root: `PROJECT_CONTEXT.md` (rewritten).
- `docs/PIPELINE_STATUS.md` (new).
- `docs/ACTIVE_MAINLINE_MANIFEST.csv`, `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv`,
  `docs/REPOSITORY_RISK_REGISTER.csv`, `docs/FINAL_REPOSITORY_RECONSTRUCTION_AUDIT.md`.
- `docs/FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md`,
  `docs/FIGURES_NATURE_V2_2_FILE_MAP.csv`.
- `docs/CONTROL_DOCUMENT_INDEX.csv` (new),
  `docs/CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md` (this file).
- `archive/PROPOSED_ARCHIVE_MOVES.csv`, `archive/ARCHIVE_MANIFEST.csv`,
  `archive/HISTORICAL_MANIFEST.csv`.
- `manuscript_v2_1/audit/STATISTICAL_REPORTING_AUDIT.md`,
  `STATISTICAL_CLAIM_MAP.csv`, `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`,
  `EXPERIMENTAL_DESIGN_REVIEW.md`, `PROJECT_RECONSTRUCTION_PLAN.md`,
  `REVIEWER_RISK_REGISTER.csv`, `MANUSCRIPT_MODULE_MAP.csv`.
- `docs/protocol/ANALYSIS_PLAN_v2.1.md`,
  `DISCOVERY_VALIDATION_PROTOCOL.md`, `DISCOVERY_VALIDATION_SPLIT_SPEC.md`.

## 3. Superseded / historical (13)

- `docs/protocol/ANALYSIS_PLAN_v2.0.md` -> superseded by v2.1.
- `docs/protocol/V2_IMPLEMENTATION_GAP_AUDIT.md` -> historical.
- `docs/protocol/STUDY_DESIGN_AUDIT.md` -> supporting historical (design provenance).
- `docs/workflow/MASTER_PROJECT_STATUS_2026-09-28.md`,
  `PROJECT_LOGIC_AUDIT_2026-09-28.md`, `CODEX_WORKFLOW.md`, `FILE_STATUS.md`,
  `MASTER_PROJECT_AUDIT_BACKLOG.md` -> dated snapshots; superseded by
  `PIPELINE_STATUS.md` + `CONTROL_DOCUMENT_INDEX.csv`.
- `docs/task/TASK_CURRENT.md` -> stale (still says "next: M07").
- `docs/archive/early_plans/*`, `docs/archive/legacy_framework_v2.0/*`,
  `docs/archive/maintenance_logs/*` -> already archived.

No files were moved this round. The historical files remain in place; their status is
recorded in `CONTROL_DOCUMENT_INDEX.csv`. A future batch may move them under
`docs/archive/` once the freeze tag is cut.

## 4. Conflicts fixed

### 4.1 Terminology

The old `PROJECT_CONTEXT.md` repeatedly used `High-pressure/high-altitude` and
`Humid-hot` (12+ occurrences) and on line 382 called the 129 split an
"independent Validation split". The rewritten `PROJECT_CONTEXT.md` uses
manuscript-facing **High land** / **Hot-humid** and explicitly calls the 129 the
**reused hold-out subset** (not external / independent validation). Internal keys
are noted as internal-only.

No banned phrases (`external validation`, `validated biomarker`, `85 validated
proteins`, `29 FDR-replicated`, `predictive biomarker study`, `mechanistic
validation`, `pure EV proteome`) remain in the rewritten current control doc.

### 4.2 Path / entrypoint

The old `PROJECT_CONTEXT.md` referenced frozen v1.0 stages 01–12, the 256-DEP
Long-vs-Short set, and `figures_prospective.R` as the next task. The rewritten
doc lists canonical v2.1 entrypoints: P1/P2/P3, D01–D10, M05–M11 (Firth/KNN/
corrected-interaction variants), M12 v2.1 chain, M12B, M14, ml_v2.1, M17. Old
paths (`analysis_v2.0/ml/`, `figures_final_v1/`, `figures_prospective_v2.6/`,
`M12_pathway_enrichment/`, `V2_M12_pathway.R`, root `execute_discovery_validation_split.R`)
are explicitly marked HISTORICAL_FROZEN under `archive/`.

### 4.3 Numerical conflicts

The old `PROJECT_CONTEXT.md` mixed v1.0 numbers (3,817 raw protein groups,
1,434 primary, 256 Long-vs-Short DEP) with v2.1 numbers (85 High-vs-Low). The
rewritten doc separates:
- Cohort: 519 / 515 / 386 / 129.
- Discovery: 1,445 Discovery-eligible proteins -> 85 High-vs-Low DEPs.
- Replication: 83 / 29 / 1.
- Pathway: cameraPR 205 / ORA 23 / fgsea 44 (family-wise) & 41 (pooled, sensitivity) / KEGG NOT_RUN; mapping 1434 / 1414 / 15 / 5.
- Interaction: 0/1,430 at BH-FDR<0.05.
- ML: fixed-85 conditional + strict nested (range 8–618).

The historical 256-DEP Long-vs-Short v1.0 benchmark remains a frozen historical
reference and is not presented as the current discovery result.

### 4.4 Module status

The old `MASTER_PROJECT_STATUS_2026-09-28.md` still said M12 BLOCKED, M15v2
locked, and figures at `figures_final_v1/`. The new `PIPELINE_STATUS.md` records
M12 v2.1 FROZEN_COMPLETE, ml_v2.1 PASS_WITH_LIMITATIONS, M17 FROZEN_COMPLETE at
`figures_final_v2/`, and the archive layer.

## 5. Unresolved conflicts

None blocking. The dated snapshots under `docs/workflow/` still contain old
path/number wording, but they are explicitly marked HISTORICAL in the index and
are not cited as current authority. They can be physically moved to
`docs/archive/` in a later housekeeping batch.

## 6. Remaining control-doc risks

- `docs/workflow/*.md` and `docs/task/TASK_CURRENT.md` still exist on disk and
  may be opened by a future reader. Mitigation: `CONTROL_DOCUMENT_INDEX.csv`
  flags them SUPERSEDED/HISTORICAL; `PROJECT_CONTEXT.md` points to the new
  canonical files. Physical move recommended after the v2.1 tag.
- `docs/protocol/STUDY_DESIGN_AUDIT.md` uses internal environment keys; retained
  as design provenance.
- No control doc currently claims the 85 are "validated" or the 129 is "external
  validation" after the rewrite.

## 7. Analysis reopen required?

No. No statistical or numerical conflict was found that would require reopening
analysis. The consolidation is documentation-only.

## 8. Ready for final reproducibility audit?

Yes. All analysis modules are frozen, all canonical entrypoints are documented,
the archive layer is provenance-tracked, and terminology / path / numbering
conflicts have been resolved in the current control docs.
