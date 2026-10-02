# Post-v2.1 Environment-Pathway Amendment

**Amendment date**: 2026-10-03
**Status**: FINAL_FROZEN_WITH_ENVIRONMENT_PATHWAY_AMENDMENT
**Previous freeze**: POST_V2_1_EXTENDED_ANALYSIS_FREEZE = PASS (2026-10-02)

This amendment appends the environment-stratified control-referenced ranked pathway analysis completed after the initial freeze. No numerical analysis was rerun.

## New authoritative results

| Environment | Contrast | Protein FDR<0.05 | GO-BP pathway | Reactome pathway | Total pathway | Ranked genes |
|---|---|---|---|---|---|---|
| Humid-heat (Q_HH=1,373) | Low vs Control | 0 | 52 | 276 | **328** | 1,344 |
| Humid-heat | High vs Control | 1 | 14 | 158 | **172** | 1,344 |
| High-altitude (Q_HA=1,394) | Low vs Control | 0 | 6 | 72 | **78** | 1,361 |
| High-altitude | High vs Control | 75 | 3 | 8 | **11** | 1,361 |

Method: cameraPR (inter.gene.cor=0.01, set size 10–500), pooled BH across GO-BP + Reactome. Ranking = limma moderated t. Reuses frozen M12 mapping contract (1,414 representative genes).

## New claims

- **Claim A**: Low-vs-Control comparisons showed coordinated ranked pathway-level signals within both environments despite no individual protein surviving protein-level BH correction. (Exploratory pathway level.)
- **Claim B**: Humid-heat yielded a **broader** set of FDR-significant ranked pathway signals than high-altitude for the corresponding control-referenced contrasts. (Descriptive; "broader" not "stronger".)
- **Claim C**: High-altitude High-vs-Control produced a relatively concentrated protein-level discovery pattern (75 protein hits, 11 pathway signals) compared with the broader distributed pathway-level patterns observed in Humid-heat (1 protein hit, 172 pathway signals). (Descriptive.)
- **Claim D**: The observed Control-to-Low profile shifts were compatible with coordinated pathway-level remodeling in both environments. (Descriptive.)

## Critical wording correction

"HH pathway signal is stronger than HA" is **prohibited**. The correct wording is "HH yielded a broader set of FDR-significant ranked pathways than HA." Pathway counts are not effect-size metrics; GO-BP and Reactome terms are highly redundant.

## Formal environment boundary preserved

- Canonical M10 Group × Environment interaction: 0/1,430 BH-FDR significant.
- Therefore: no "HA-specific pathway", "HH-specific pathway", or "environment-specific program" claim is authorized from stratified counts alone.

## New limitations added

1. Pathway-count differences between environments are descriptive, not formal interaction tests.
2. GO-BP and Reactome pathways are highly redundant; significant pathway counts are not independent mechanisms.
3. Ranked pathway significance can occur without protein-level FDR discoveries because the gene-set test assesses coordinated shifts.
4. cameraPR direction reflects ranked gene-set shift, not mechanistic activation/inhibition.
5. Environment-stratified pathway analyses are secondary/exploratory.
