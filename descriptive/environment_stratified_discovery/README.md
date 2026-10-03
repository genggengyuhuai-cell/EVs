# environment_stratified_discovery — README

## Module
Post-v2.1 environment-stratified de novo Discovery (Phase 1: Humid-heat / High-altitude),
Phase-2 interpretation/reconciliation, Phase-3 Exposure-vs-Control, and the
`pathways_control_referenced/` sub-analysis.

## Purpose
Estimate protein-level and ranked-pathway contrasts within each environment stratum. All
results are **secondary/supplementary**; M10 Group × Environment interaction is the authoritative
test for environment heterogeneity.

## Status
ACTIVE_COMPLETE (post-v2.1; Level-2 supplementary + Level-3 exploratory pathway).

## Inputs
- Discovery subset stratified by environment (HH n=209 / HA n=177).
- Stratum-specific eligible universes (Q_HH 1,373 / Q_HA 1,394).

## Active Code
- `code/`

## Final Outputs (source of truth)
- `results/`, `manifest/`
- `CONTRAST_RECONCILIATION_REPORT.md`, `PHASE2_INTERPRETATION_REPORT.md`,
  `PHASE3_EXPOSURE_VS_CONTROL_REPORT.md`
- `pathways_control_referenced/results/`,
  `pathways_control_referenced/ENVIRONMENT_CONTROL_REFERENCED_PATHWAY_REPORT.md`

## Key Results
- Humid-heat: LVC=0, HVC=1, HvL=0, EC=0 BH-FDR.
- High-altitude: LVC=0, **HVC=75**, HvL=0, **EC=7** (TPST2, C1R, SPARC, FSTL1, MENT, XYLT2,
  ST3GAL6; all negative; all within HA HvC 75; 1/7 in frozen 85).
- Env-stratified ranked pathways: HH LVC 328 / HVC 172; HA LVC 78 / HVC 11 (descriptive).
- M10 Group × Environment: 0/1,430 (authoritative).

## Statistical Contract
Per `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` (§4, §7, §10) and POST_V2_1 claim map
(claims B1–B4, E1–E4).

## Limitations
- Stratum-level discoveries are not externally validated and do not establish environment
  specificity. M10 interaction is null. Count differences across environments are descriptive.

## Do Not Use
- Do not call HA 75 / HA 7 "high-altitude-specific biomarkers".
- Do not claim "environment has no effect" or infer interaction from count differences.

## Reproducibility
Deterministic; Git-tracked at HEAD `8695ae6`.

## Next Step
See `docs/NEXT_STEPS.md` (manuscript presentation sync; env-pathway wording).
