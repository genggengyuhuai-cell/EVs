# EV-enriched Plasma Proteomics — Repository

## Project
Short scientific purpose: identify proteins and pathways associated with environmental exposure
in an EV-enriched plasma proteomics study. Primary scientific distinction is **High vs Low**
exposure (85 discovery candidates); pathway and control-referenced analyses provide biological
context. See `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` for exact wording rules.

## Current Status
- **Analysis core: CLOSED.** No scientific analysis is open (`OPEN_ANALYSIS = 0`).
- **Scientific HEAD: `8695ae6`** (`8695ae640a324a3bd0541aa96792d5ec2c2d244b`) — the current
  complete scientific state after post-v2.1 extended contrast + environment-pathway closure.
- **`analysis-v2.1` = historical repaired-core freeze** (peels to `6d0e004`). It is NOT the
  current complete scientific state and is not relabeled as such.
- **Open scientific analyses: none.** Remaining work is reporting / provenance / manuscript /
  git / repository only.
- **Manuscript preparation: ongoing** (`MANUSCRIPT_STATUS = IN_PROGRESS`, `SUBMISSION_READY = NO`).

## Repository Map
- **Active analysis** — `descriptive/discovery_validation/` (D01–D10 + post-v2.1 pairwise
  completion + control-referenced pathways), `descriptive/analysis_v2.0/` (M05–M11, M12/M12B
  pathway, M14, ml_v2.1, figures_final_v2).
- **Discovery/validation** — `descriptive/discovery_validation/D02_discovery_primary/`,
  `D08_validation/` (reused within-cohort hold-out).
- **Pathway** — `descriptive/analysis_v2.0/M12_pathway_v2.1/` (cameraPR PRIMARY, ORA
  COMPLEMENTARY, fgsea SENSITIVITY, KEGG NOT_RUN).
- **ML** — `descriptive/analysis_v2.0/ml_v2.1/` (fixed-85 + strict nested).
- **Manuscript** — `manuscript_v2_1/`.
- **Control docs** — `docs/` (see next section).
- **Archive** — `archive/` (historical/provenance/sensitivity/diagnostic/backup; NOT current
  source of truth).
- **External templates** — `external_templates/` (user-supplied report templates; not analysis).

## Authoritative Control Documents
- `docs/FINAL_MAINLINE_MANIFEST.csv` — single active file registry.
- `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` — sole statistical/reporting contract.
- `docs/LIMITATIONS.md` — accepted unresolved limitations.
- `docs/NEXT_STEPS.md` — the only project-level future-work list.
- `PROJECT_CONTEXT.md` — short machine/human project state.
- `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` — sole authoritative claim map
  (see below).

## Current Manuscript Claim Map
- **Authoritative path**: `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv`
- The older `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` is archived (historical, not active
  authority) under `archive/audits/manuscript_claim_map/`.

## Historical Material
- `archive/` is **provenance/history only** and is **not current scientific source of truth**.
  Nothing under `archive/` may support a current manuscript claim unless the active manifest
  (`docs/FINAL_MAINLINE_MANIFEST.csv`) explicitly references it for provenance.
- Historical numeric differences inside archived files are left historically faithful; do not
  rewrite them to match current numbers.

## How to Resume Work
1. Read this README.
2. Read `PROJECT_CONTEXT.md`.
3. Read `docs/NEXT_STEPS.md` (the only active to-do list).
4. Read the relevant module README.
5. Do **not** infer current status from archived Phase reports — they are historical.
