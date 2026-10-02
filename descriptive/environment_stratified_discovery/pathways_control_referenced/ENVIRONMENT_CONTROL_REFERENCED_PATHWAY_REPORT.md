# Environment-Stratified Control-Referenced Pathway Report

> Exploratory ranked pathway analysis. Reads existing Phase 1 estimates; no model refit. Reuses frozen M12 mapping (1,414 representative genes) and gene sets (GO-BP, Reactome, set size 10–500, cameraPR cor=0.01, pooled BH).

## Summary matrix

| Environment | Contrast | Protein BH-FDR<0.05 | GO-BP pathway | Reactome pathway | Total pathway |
|---|---|---|---|---|---|
| Humid-heat (n=209, Q_HH=1,373) | Low vs Control | 0 | **52** | **276** | **328** |
| Humid-heat | High vs Control | 1 | **14** | **158** | **172** |
| High-altitude (n=177, Q_HA=1,394) | Low vs Control | 0 | **6** | **72** | **78** |
| High-altitude | High vs Control | 75 | **3** | **8** | **11** |

Ranked genes (mapped + estimable): HH=1,344; HA=1,361.

## Key finding

Despite **0 protein-level BH-FDR discoveries** for HH Low-vs-Control and HA Low-vs-Control, ranked pathway analysis identifies **328** and **78** pooled FDR-significant pathways respectively. This demonstrates coordinated pathway-level shifts relative to Control even when no individual protein survives protein-level multiple-testing.

## Top pathways

### HH Low vs Control (328 sig)
- Complement activation (classical) — Up
- Acute-phase response — Up
- Immunoglobulin mediated/immunoglobulin production — Up
- Adaptive immune response — Up
- Proteasome-mediated ubiquitin catabolism — **Down**
- Actin cytoskeleton / actin filament organization — **Down**
- Platelet aggregation — **Down**

### HH High vs Control (172 sig)
- Same immune/complement/acute-phase Up theme as HH LVC
- Proteasome/cytoskeleton Down theme persists but attenuated

### HA Low vs Control (78 sig)
- Immune/complement Up theme (broader than Overall LVC in this stratum)
- Proteasome/cytoskeleton Down theme present

### HA High vs Control (11 sig)
- Cell adhesion (integrin-mediated) — Down
- O-glycan processing — Down
- Despite 75 protein-level BH discoveries, only 11 pathway-level signals — the HA protein signal is distributed across immune genes without strong gene-set-level enrichment beyond what LVC already captures.

## Cross-environment pattern

- **HH shows much broader pathway signal than HA** for both Low vs Control (328 vs 78) and High vs Control (172 vs 11).
- The immune/complement/acute-phase Up theme and proteasome/cytoskeleton Down theme are present in **both** HH and HA for Low vs Control — shared directional response.
- HA High vs Control has 75 protein-level hits but weak pathway signal, suggesting the HA protein signal is relatively dispersed rather than concentrated in canonical gene sets.
- HH Low vs Control has 0 protein-level hits but 328 pathway signals, confirming distributed coordinated shifts.

## Relation to Overall control-referenced pathways

- Overall LVC = 258 pathways; HH LVC = 328; HA LVC = 78. The HH stratum drives the majority of the Overall LVC signal.
- Overall HVC = 38; HH HVC = 172; HA HVC = 11. HH HVC shows stronger pathway enrichment than Overall, despite only 1 protein-level hit.
- "Significant Overall but not stratum" is expected by power/precision; not a contradiction.

## Visual Control→Low trend

The user's observation that Control and Low appear visually different is supported at the pathway level:
- HH LVC: 328 pathways, dominated by immune/complement/acute-phase Up and proteasome/cytoskeleton Down.
- HA LVC: 78 pathways, same directional themes.
- This is **coordinated pathway-level remodeling** at the Low exposure state, not individual DEPs.

## Interpretation boundaries

- These are exploratory ranked pathway results, not primary endpoints.
- HH/HA significance-count differences do **not** prove environment interaction.
- Canonical M10 remains authoritative for formal Group × Environment heterogeneity (0/1,430).
- "Up" / "Down" describe ranked direction, not mechanism.

## Outputs

```
pathways_control_referenced/
  code/env_control_pathways.R
  results/{HH,HA}_{low,high}_vs_control_cameraPR_{all,significant}.csv
  results/environment_control_pathway_summary.csv
  results/environment_control_pathway_reconciliation.csv
  results/overall_vs_environment_pathway_reconciliation.csv
  diagnostics/analysis_validation.csv
```

ENV_CONTROL_REFERENCED_PATHWAYS = PASS
