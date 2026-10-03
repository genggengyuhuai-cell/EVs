# control_referenced_pathways — README

## Module
Post-v2.1 control-referenced pathway analysis (cameraPR ranked + nominal-P ORA) across
Low-vs-Control and High-vs-Control, plus pathway theme consolidation.

## Purpose
Test whether control-referenced contrasts show coordinated ranked pathway signal despite
0 protein-level BH-FDR discoveries. Level-3 exploratory / hypothesis-generating.

## Status
ACTIVE_COMPLETE (post-v2.1; Level-3 EXPLORATORY_PATHWAY).

## Inputs
- 1,406 rankable mapped+estimable genes (ranked cameraPR).
- Nominal-P proteins (114 LVC / 145 HVC) as ORA foreground (no FC cutoff).

## Active Code
- `code/` — control-referenced pathway run scripts.

## Final Outputs (source of truth)
- `results/` — per-contrast cameraPR / ORA tables.
- `manifest/`
- `theme_consolidation/CROSS_CONTRAST_THEME_MATRIX.csv` (11 themes)
- `CONTROL_REFERENCED_PATHWAY_REPORT.md`

## Key Results
- Low vs Control cameraPR: 258 pooled FDR-significant (21 GO-BP + 237 Reactome).
- High vs Control cameraPR: 38 (10 GO-BP + 28 Reactome).
- Nominal-P ORA: LVC=0 enriched; HVC=12 enriched (1 GO-BP + 11 Reactome).
- 11-theme consolidation (descriptive): shared immune/complement/acute-phase activation; HvL
  Up reflects Low-suppressed rebound, not High activation.

## Statistical Contract
Per `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` (§10, §11) and POST_V2_1 claim map
(claims C1–C4, D1–D4). cameraPR remains PRIMARY for HvL (205); control-referenced cameraPR is
Level-3 exploratory.

## Limitations
- Ranked/exploratory; no protein-level FDR discoveries support these contrasts.
- GO-BP/Reactome are highly redundant; counts ≠ independent mechanisms.
- cameraPR direction reflects ranked shift, not mechanistic activation.

## Do Not Use
- Do not call the 258 "independent biological processes".
- Do not claim mechanism or "High activates proteasome/cytoskeleton/redox" (HVC NS).

## Reproducibility
Deterministic; bound to annotation package versions (see `docs/LIMITATIONS.md`). Git-tracked at
HEAD `8695ae6`.

## Next Step
See `docs/NEXT_STEPS.md` (pathway-count sync in manuscript text/captions).
