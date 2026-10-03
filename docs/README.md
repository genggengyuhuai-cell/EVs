# docs/ — Control Documentation

This directory holds the project's authoritative control documents. It is **navigation only**;
the precedence of documents is defined below. Archived historical reports never override current
contracts.

## Authoritative documents (read in this order)

1. `FINAL_MAINLINE_MANIFEST.csv` — single active file-level registry. One row per relevant file
   (or collection), with `Status` (`ACTIVE_PRIMARY` / `ACTIVE_SUPPORTING` / `ACTIVE_SENSITIVITY` /
   `ACTIVE_DIAGNOSTIC` / `HISTORICAL_ARCHIVED`), source-of-truth markers, and archive locations.
2. `FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` — the sole statistical/reporting contract.
3. `PROJECT_CONTEXT.md` (repo root) — short machine/human project state.
4. Current module README (inside each active module).
5. Archived historical reports (`archive/audits/`, `archive/historical_results/`, etc.) —
   provenance only.

> **Precedence rule**: `FINAL_MAINLINE_MANIFEST.csv` > `FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md`
> > `PROJECT_CONTEXT.md` > current module README > archived historical reports. **Historical audits
> never override current contracts.** An old document containing "FINAL" in its name does not
> override a later validated scientific state.

## Authoritative claim map

- `post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` is the **sole** active manuscript claim
  map. The older `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` is archived (historical).

## Key current controls (active)

| File | Role |
|---|---|
| `FINAL_MAINLINE_MANIFEST.csv` | Single active file registry |
| `FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` | Sole statistical/reporting contract |
| `LIMITATIONS.md` | Accepted unresolved limitations |
| `NEXT_STEPS.md` | The only project-level future-work list |
| `CURRENT_AUTHORITATIVE_RESULTS.md` | Frozen current results authority |
| `FINAL_BLOCKER_STATUS.md` | Blocker/analysis status (`OPEN_ANALYSIS = 0`) |
| `R03_FINAL_AUTHOR_DECISION.md` | R03 author closure (universes 1445/1434/1406) |
| `post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` | Sole claim map |
| `post_v2_1_extended_analysis/POST_V2_1_EXTENDED_ANALYSIS_FREEZE.md` | Post-v2.1 freeze + accepted counts |
| `protocol/` | Frozen analysis protocols (ANALYSIS_PLAN_v2.0/v2.1, split specs, design audit) |

## Archived / historical

- Old audits, freeze/phase/status reports, reproducibility audits/manifests, stale manifests,
  and backup `.bak` files moved to `archive/audits/`, `archive/backups/`, etc. — **not** current
  source of truth.
- `docs/archive/` — historical docs, never a current execution basis.
- `docs/workflow/` and `docs/task/` were archived (contents under `archive/audits/docs_workflow/`
  and `archive/audits/docs_task/`) and the empty directories removed.
