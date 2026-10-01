# M09 Fig. 3 Rebuild Requirement

Status: `FIG3_REBUILD_REQUIRED`.

- Affected panel: Fig. 3c, `Overall-exposure sensitivity`.
- Producer: `code/V2_M17_figures_v2.R`.
- Old M09 source: `M09_pre_repair_snapshot/M09_KNN_E_comparison.csv`.
- Repaired M09 source: `M09_missingness_sensitivity/KNN_sensitivity/M09_KNN_E_comparison.csv` and `M09_EFFECT_COMPARISON.csv`.
- Old Pearson E correlation: 0.931147.
- Repaired Pearson E correlation: 0.974061.
- Old/repaired Spearman E correlation: 0.913236 / 0.964438.
- Old/repaired direction concordance: 1320/1430 / 1343/1430.
- Repaired E values differ from the old invalidated E values for 953/1430 proteins.
- Numerical E_knn content changed: YES.
- Panel rebuild required: YES.
- Caption/Methods must replace the invalid correlation-weighted/custom description with the full `impute::impute.knn(k=10, rowmax=0.5, colmax=0.8, maxp=1500, rng.seed=20260925)` contract.
- The M17 figure pipeline was not executed in Phase 3.
