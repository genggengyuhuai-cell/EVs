# archive/ — Historical / Provenance / Supporting Material

## Purpose
This directory holds **historical, provenance, sensitivity, diagnostic, backup, and superseded**
material from the EV-enriched plasma proteomics repository. It preserves context and evidence but
is **not** current scientific source of truth.

## Not Current Source of Truth
**Nothing under `archive/` should be used for current manuscript claims** unless the active
manifest (`docs/FINAL_MAINLINE_MANIFEST.csv`) explicitly references it for provenance. Current
scientific results live in the active directories listed in that manifest (Status
`ACTIVE_PRIMARY` / `ACTIVE_SUPPORTING`).

## Directory Classes

| Directory | Contains |
|---|---|
| `audits/` | Old phase/reviewer/freeze/status/handoff reports, reproducibility audits & manifests, stale control-doc registries, older claim map |
| `provenance/` | Pre-fix snapshots (M09/M11/M12/M12B/ML/strict-nested/figures phase6), repair-comparison evidence, `D10_p20_fix/` (D10 pre-p20-fix snapshot) |
| `historical_code/` | Superseded code (formerly `superseded_code/`) |
| `historical_results/` | Superseded results (e.g., M13 reconciliation, D06, M10 parent, 256-DEP master) |
| `diagnostics/` | Diagnostic-only outputs (candidate ROC, M12/M12B diagnostics, qa_preview renders, env-stratified diagnostics) |
| `sensitivity/` | Valid non-primary sensitivity analyses (limma_dose_analysis, missingness_robustness, ml_postfreeze_svm_rfe) |
| `backups/` | `.bak` / `.orig.bak` / `.phase*.bak` backup files |

## Recovery
Older repository states are recoverable through Git:
- Historical committed states are reachable via `git log` / tags (`analysis-v2.1` → `6d0e004`).
- Every moved file is recorded in
  `archive/audits/repository_consolidation_2026-10-02/PHASE2_MOVE_LOG.csv` (old path, new path, hash
  before/after). Files moved by `git mv` retain their Git history.
- Archived backups of git-tracked files are also recoverable from Git history.

## Historical Numerical Differences
Old reports under `archive/` may contain **superseded numbers** (e.g., pre-repair pathway counts
195/39) and must **not** be silently updated to match current values. **Do not rewrite historical
archived files.** Current accepted numbers are fixed by
`docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` and
`docs/post_v2_1_extended_analysis/POST_V2_1_EXTENDED_ANALYSIS_FREEZE.md`.
