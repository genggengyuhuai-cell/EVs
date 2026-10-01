# M11 Fig. 4 Rebuild Requirement

Status: `FIG4D_REBUILD_REQUIRED`.

| Panel | Old source | Repaired source | Old metric | New metric | Needs rebuild? | Caption change? | Reason |
|---|---|---|---|---|---|---|---|
| Fig. 4c Site composition | `M11_pre_repair_snapshot/M11_site_composition.csv` | `M11_site_robustness/M11_site_composition.csv` | Site × Group counts | Same counts with explicit Site/Environment/Total fields | NO | NO | Composition is descriptive and numerically unchanged |
| Fig. 4d LOO influence | `M11_pre_repair_snapshot/M11_site_LOO_stability.csv` | `M11_site_robustness/M11_site_LOO_stability.csv` and `M11_EFFECT_COMPARISON.csv` | Unadjusted, deletion-reweighted LOO maximum shift and direction summary | Primary-contract adjusted LOO maximum shift and direction versus frozen M05 | YES | YES | Formula and weights were repaired; numerical source changed=YES |

The Fig. 4 producer reads M11 Site composition for panel c and the canonical LOO stability table for panel d. The M17 figure pipeline was not executed in Phase 4.
