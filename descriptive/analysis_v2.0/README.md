# analysis_v2.0 — V2 Abundance / Pathway / ML Mainline (README)

## Module
The v2 abundance, pathway, biological-context, replication and machine-learning mainline
(M05–M11, M12/M12B, M14, ml_v2.1, figures_final_v2).

## Purpose
This is the current scientific mainline for v2 differential abundance, robustness, pathway and
ML. It does not modify frozen v1.0 descriptive results.

## Status
ACTIVE (analysis core CLOSED; modules complete/frozen). Authoritative current status:
`docs/FINAL_BLOCKER_STATUS.md` (`OPEN_ANALYSIS = 0`).

## Active Code (canonical entrypoints)
- `code/V2_M0[5-11]_*.R` — Firth (M08), KNN (M09), corrected pure 2-df interaction (M10),
  LOO site robustness (M11) variants are canonical.
- `M12_pathway_v2.1/` — `M12_01_mapping.R → M12_02_ranked_ora.R → M12_03_integration.R`
  (canonical; `M12_02b_kegg_fix.R` is NON_CANONICAL — KEGG NOT_RUN).
- `M12B_biological_context_v2.1/` — `M12B_all.R`.
- `ml_v2.1/` — `run_v2_1_ml.R` (fixed-85) + `strict_nested_sensitivity.R` (sensitivity).
- `V2_M13_M14_reconciliation.R` → `M14_frozen_replication/`.
- `code/V2_M17_figures_v2.R` → `figures_final_v2/`.

## Final Outputs (source of truth)
- `M12_pathway_v2.1/` (cameraPR 205 / ORA 23 / fgsea 44&41 / KEGG NOT_RUN)
- `M10_environment_interaction/corrected_pure_interaction/` (0/1,430)
- `M14_frozen_replication/`
- `ml_v2.1/results/` + `ml_v2.1/strict_nested/`
- `figures_final_v2/`

## Key Results
- 85 / 1,445 High-vs-Low discovery candidates; reused hold-out 85/83/29/1.
- M10 pure 2-df interaction 0/1,430.
- Pathway: cameraPR 205 (29 GO-BP + 176 Reactome) PRIMARY; ORA 23 (3 + 20) COMPLEMENTARY;
  fgsea 44 family / 41 pooled SENSITIVITY ONLY; KEGG NOT_RUN. Universes 1445/1434/1406
  (R03 closed by author decision).

## Statistical Contract
`docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` (sole contract) +
`docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` (sole claim map).

## Limitations
See `docs/LIMITATIONS.md` (ML conditional-on-85; strict-nested instability; Python env gap;
pathway counts bound to annotation versions).

## Do Not Use (superseded/historical here)
- Legacy `ml/` paths (`ml/ML_ANALYSIS_SPEC_v2.0.md`, `ml/code/`, `ml/folds/`, `ml/qc/`,
  `ml/models/`, `ml/results/`) are **archived** to `archive/historical_code/ml_legacy/` /
  `archive/historical_results/` — not current.
- `M10_environment_interaction/` parent (1034) is archived to
  `archive/historical_results/M10_environment_interaction_parent/`; use only
  `corrected_pure_interaction/`.
- `M13_historical_reconciliation/` archived to `archive/historical_results/`.
- `pre_repair_snapshot` / `pre_P0_repair_snapshot` / `strict_nested_pre_repair_snapshot` /
  `phase6_pre_rebuild_snapshot` directories are **provenance** (archived to `archive/provenance/`),
  not current.

## Reproducibility
Deterministic under the frozen R environment (see `docs/SOFTWARE_ENVIRONMENT_LOCK.md`); module
scripts record SHA-256 manifests. Python/ML env gap disclosed in `docs/LIMITATIONS.md`.

## Next Step
See `docs/NEXT_STEPS.md` (provenance lock; manuscript presentation sync).
