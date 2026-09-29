# Final Repository Reconstruction Audit — v2.1

This audit classifies the repository into mainline / supplementary / support / archive / historical layers, produces a proposed (not executed) move plan, and identifies dependency blockers. No files were moved, renamed, deleted, committed, or pushed.

## 1. Current scientific mainline

Per the latest authority (whole-project scientific review + statistical reporting audit + reviewer risk register), the scientific mainline is:

R1 cohort / analysis universe → R2 proteome landscape → R3 85 High-vs-Low discovery DEPs → R4 reused-hold-out hierarchy (85 / 83 / 29 / 1) → R5 robustness summary (detection / missingness / site / environment / interaction null) → R6 representative pathway themes.

ML and full pathway detail are secondary / supplementary; M12B is supplementary interpretation.

## 2. Current repository mainline (canonical modules)

| Layer | Modules |
|---|---|
| ACTIVE_MAINLINE | D01, D02, D03, D08; M05, M06, M07, M10 (null), M11 (summary), M12 v2.1 (entry + representative outputs), M14; ml_v2.1 (entry scripts + integrated_table_85 + outer_cv_metrics + strict_nested_outer_metrics); M17 (V2_M17_figures_v2.R + figures_final_v2 Fig1–6 + manifest/QC); upstream universe/contracts/config/registry. |
| ACTIVE_SUPPORTING | figure_display_labels.R, v21_common.R, config/, contracts/, universes/, manifests/, registry/, qc/V2_*_QA.md. |
| SUPPLEMENTARY | M08 Firth details, M09 KNN, M10 stratified details, M11 LOO per-protein, D04/D05/D07/D09/D10, ORA full, fgsea full, M12B correlation/network/annotation, ML full CV tables, strict-nested full split tables, Boruta/XGBoost importance, upstream QC descriptive figures, figures_prospective_v2.7. |
| HISTORICAL_FROZEN | figures_final_v1, M12_pathway_enrichment v1, ml/ legacy tree (incl. invalidated runners), figures_prospective_v2.6, M13 historical reconciliation, docs/archive/* (already archived), KEGG placeholder CSVs. |
| ARCHIVE_CANDIDATE | see §7. |

## 3. Canonical module entries

- D01–D10: `descriptive/discovery_validation/code/` (D01*.py … D10*); canonical results under `descriptive/discovery_validation/D0x_*/`.
- M05–M11: `descriptive/analysis_v2.0/code/V2_M0[5-11]_*.R` (Firth / KNN / corrected-interaction versions are canonical; legacy variants superseded).
- M12 v2.1: `M12_01_mapping.R → M12_02_ranked_ora.R → M12_02b_kegg_fix.R → M12_03_integration.R`.
- M12B v2.1: `M12B_all.R`.
- M14: `V2_M13_M14_reconciliation.R` → `M14_frozen_replication/`.
- M15 / ML v2.1: `ml_v2.1/run_v2_1_ml.R` (fixed-85) + `ml_v2.1/strict_nested_sensitivity.R` (nested). Reporting helpers `summarize_results.R`, `summarize_tiers.R`.
- M17: `code/V2_M17_figures_v2.R` → `figures_final_v2/`.

## 4. Main-text analyses (keep)

R1 cohort/universe (Fig1); R2 proteome landscape (Fig2); R3 85 DEPs (Fig3); R4 hierarchy (Fig5a only); R5 robustness summary (Fig4 panels, brief text); R6 representative pathway themes (Fig6a,c,d).

## 5. Supplementary analyses (downgrade)

M08 Firth full table; M09 KNN per-protein; M10 stratified per-protein; M11 LOO per-protein; D04/D05/D07/D09/D10; ORA 23 table; fgsea 39 table; M12B correlation/network/annotation; ML fixed-85 full CV table; strict-nested full split table; Boruta/XGBoost importance; upstream QC descriptive figures; figures_prospective_v2.7.

## 6. Historical frozen (do not delete)

figures_final_v1; M12_pathway_enrichment v1; ml/ legacy tree (incl. invalidated subtrees); figures_prospective_v2.6; M13_historical_reconciliation; docs/archive/*; KEGG placeholder CSVs.

## 7. Archive candidates (file-level; not moved this round)

17 files already identified in prior audits (M17_probe.R; ml_v2.1 debug/helper/log × 6; M12 debug/helper/log × 10; M12B run.log). Plus 10 superseded scripts in `analysis_v2.0/code/` (V2_M08_detection.R, V2_M09_missingness_sensitivity.R, V2_M10_environment_interaction.R, V2_M15v2_*.R × 4, V2_M16_holdout.R, V2_M17_figures.R). Plus 3 top-level exploratory scripts `code/P1.py P2.py P3.py` (UNKNOWN_REVIEW). Plus `tmp/` and `descriptive/__pycache__/` (gitignore).

## 8. Dependency blockers

- No active M17 / M12 / M12B / ml_v2.1 script sources or reads any of the archive candidates listed in §7. Verified in prior audits.
- `code/P1.py/P2.py/P3.py` are UNKNOWN_REVIEW — purpose not confirmed; do not move until a human confirms they are exploratory.
- `figures_final_v1/`, `figures_prospective_v2.6/`, `ml/` legacy tree are large HISTORICAL_FROZEN bundles; verify no active README/manifest still points to them before any move.

## 9. Duplicate / superseded findings

- Figure bundles: v1 vs v2 (figures_final_v1 superseded); v2.6 vs v2.7 (prospective figures; v2.6 superseded).
- M12: v1 directory vs v2.1 directory (v1 superseded).
- ML: legacy `ml/` vs `ml_v2.1/` (legacy superseded; contains invalidated subtrees).
- Code variants: M08 (non-Firth vs Firth), M09 (non-KNN vs KNN), M10 (non-corrected vs corrected), M17 (v1 vs v2), M15v2 legacy vs ml_v2.1.
- No byte-level duplicates detected beyond these versioned pairs.

## 10. Provenance risks

- All manuscript-facing outputs trace to active scripts reading tracked frozen tables. No manual Excel / Desktop / temp dependency found in M17 / M12 / M12B / ml_v2.1.
- `code/P1.py/P2.py/P3.py` are UNKNOWN_REVIEW provenance.
- `tmp/` and `__pycache__/` are untracked scratch; recommend .gitignore.

## 11. Proposed final repository structure (minimal-change)

Keep the existing root layout; add an `archive/` root that absorbs the proposed moves:

```
F:\env
├── PROJECT_CONTEXT.md            (entry point)
├── .gitignore                    (add tmp/, __pycache__/, *_preview.png)
├── code/                         (top-level exploratory scripts → archive after review)
├── descriptive/
│   ├── analysis_v2.0/
│   │   ├── code/                 (canonical M05–M17 v2.1 scripts; legacy → archive/)
│   │   ├── config/ contracts/ universes/ manifests/ registry/ qc/
│   │   ├── M05..M14/             (frozen result dirs)
│   │   ├── M12_pathway_v2.1/ M12B_biological_context_v2.1/ ml_v2.1/
│   │   ├── figures_final_v2/     (canonical figures)
│   │   └── (legacy dirs → archive/historical_frozen/ after review)
│   ├── discovery_validation/     (D01–D10; figures_prospective_v2.7 canonical)
│   ├── archive/                  (already exists)
│   └── (upstream descriptive tables + figures_nature_v2.2 remain as SUPPLEMENTARY)
├── docs/
│   ├── protocol/                 (current protocol)
│   ├── workflow/                 (current status)
│   ├── task/
│   ├── archive/                 (already archived legacy)
│   ├── ACTIVE_MAINLINE_MANIFEST.csv
│   ├── SUPPLEMENTARY_ANALYSIS_MANIFEST.csv
│   ├── REPOSITORY_RISK_REGISTER.csv
│   └── FINAL_REPOSITORY_RECONSTRUCTION_AUDIT.md
├── manuscript_v2_1/
│   └── audit/                   (all audits + MANUSCRIPT_MODULE_MAP.csv)
├── archive/
│   ├── debug/                    (probes)
│   ├── installers/               (one-off install scripts)
│   ├── logs/                     (console captures)
│   ├── superseded_code/          (legacy .R versions)
│   ├── exploratory/              (UNKNOWN_REVIEW)
│   └── historical_frozen/        (v1 figure bundles, legacy ml/, M12 v1, etc.)
└── rawdata/
```

This is a proposal only; no directories were created or populated this round beyond the manifest/audit CSVs.

## 12. Safe-to-move-now files

- The 17 already-identified debug/log/helper files (§7 first bullet).
- The 10 superseded scripts under `analysis_v2.0/code/`.
- `execute_discovery_validation_split.R`.
- Add `tmp/`, `descriptive/__pycache__/`, and `*_preview.png` to .gitignore.

## 13. Files requiring review before move

- `code/P1.py`, `P2.py`, `P3.py` (UNKNOWN_REVIEW).
- `descriptive/analysis_v2.0/figures_final_v1/` (verify no active reference).
- `descriptive/analysis_v2.0/ml/` (large; verify no active reference).
- `descriptive/discovery_validation/figures_prospective_v2.6/` (verify no manuscript reference).
- `descriptive/figures_nature_v2.2/` (decide SUPPLEMENTARY vs HISTORICAL_FROZEN).

## 14. Control-document cleanup plan

- **Canonical, keep current**: `PROJECT_CONTEXT.md`, `docs/protocol/ANALYSIS_PLAN_v2.1.md`, `docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md`, `docs/protocol/DISCOVERY_VALIDATION_SPLIT_SPEC.md`, `docs/task/TASK_CURRENT.md`, `docs/workflow/MASTER_PROJECT_STATUS_2026-09-28.md`, `descriptive/analysis_v2.0/README.md`, `descovery_validation/README.md` + `WORKFLOW.md` + `DATA_CONTRACTS.md`.
- **Superseded, move to archive**: `docs/protocol/ANALYSIS_PLAN_v2.0.md`, `docs/protocol/V2_IMPLEMENTATION_GAP_AUDIT.md` (historical), `docs/workflow/CODEX_WORKFLOW.md`, `docs/workflow/FILE_STATUS.md`, `docs/workflow/MASTER_PROJECT_AUDIT_BACKLOG.md`, `docs/workflow/PROJECT_LOGIC_AUDIT_2026-09-28.md` (older snapshots).
- **Already archived**: `docs/archive/legacy_framework_v2.0/`, `docs/archive/early_plans/`, `docs/archive/maintenance_logs/`.
- **Pause note**: `descovery_validation/DISCOVERY_VALIDATION_HANDOFF_2026-09-26_PAUSE.md` — keep as historical provenance.

## 15. Git execution plan (this round only)

Stage only the new manifest/audit files:
- `docs/ACTIVE_MAINLINE_MANIFEST.csv`
- `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv`
- `docs/REPOSITORY_RISK_REGISTER.csv`
- `archive/PROPOSED_ARCHIVE_MOVES.csv`
- `archive/HISTORICAL_MANIFEST.csv`
- `manuscript_v2_1/audit/MANUSCRIPT_MODULE_MAP.csv`
- `docs/FINAL_REPOSITORY_RECONSTRUCTION_AUDIT.md`

Do not stage archive candidates themselves. Do not move files.

## 16. Recommended order of archive operations (future, not executed now)

1. Add `.gitignore` entries (tmp/, __pycache__/, *_preview.png).
2. Move the 17 known debug/log/helper files to `archive/{debug,installers,logs}/`.
3. Move the 10 superseded scripts to `archive/superseded_code/`.
4. Review `code/P1.py/P2.py/P3.py`; move after confirmation.
5. Move `figures_final_v1/`, `M12_pathway_enrichment/`, `figures_prospective_v2.6/` to `archive/historical_frozen/`.
6. Treat `descriptive/analysis_v2.0/ml/` as one bulk HISTORICAL_FROZEN move after a no-active-reference grep.
7. Reconcile control docs (§14) and update `PROJECT_CONTEXT.md` to point at this audit.
8. Re-run `git status` and confirm no active script paths broke.

## 17. Blocking issues

None that require reopening analysis. The reconstruction can proceed without any statistical re-run. The only open human-review items are the three top-level exploratory scripts and the three large historical bundles (§13).
