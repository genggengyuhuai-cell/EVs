# Fixed-85 ML P0 Repair Report

Status: POST_P0_REPAIR_CURRENT. Historical EN and XGBoost results in `pre_P0_repair_snapshot/` are invalidated.

## Repairs and results

1. All EN AUC-direction defects were repaired: yes.
2. EN fixes: 2 logical selection sites (outer alpha selection and full-data alpha selection), covering all 3 original `which.min` call occurrences plus the full-data comparison direction. `lambda.min` was retained.
3. New full-data EN alpha: 0.1. Outer alpha counts (0.1/0.3/0.5/0.7): 4/6/1/4.
4. New EN outer AUROC mean / median: 0.668688 / 0.662088.
5. EN stable set (selection frequency >=0.70): n=8.
6. New Tier1: n=5.
7. New Tier1 genes: IGF1;GAL;GOLGA3;DMP1;TSPAN14.
8. Tier1 difference: ADDED=NONE; REMOVED=NONE; UNCHANGED=IGF1;GAL;GOLGA3;DMP1;TSPAN14.
9. XGBoost outer-test leakage: eliminated. No outer-test DMatrix appears in `evals`; outer test is created only after nround selection and refit.
10. Inner early stopping: stratified 80/20 split within each outer train; fixed hyperparameters; maximum 200 rounds; patience 20; refit on full outer train at selected best_iteration.
11. New XGB outer AUROC mean / median / range: 0.648769 / 0.657967 / 0.508598-0.786325.
12. Old vs new XGB AUROC mean: 0.710294 -> 0.648769 (-0.061525); median: 0.686813 -> 0.657967 (-0.028846).
13. New XGB Top10: GOLGA3;NCAM1;ST3GAL6;APOD;QSOX2;HSPG2;TSPAN14;APOA5;TAC3;GAL.
14. New XGB Top20: GOLGA3;NCAM1;ST3GAL6;APOD;QSOX2;HSPG2;TSPAN14;APOA5;TAC3;GAL;IGF1;VTN;GOLM2;NRP1;ATP6AP2;HABP2;PTX3;CLSTN1;ACAN;GPC4.
15. Largest absolute XGB rank changes among proteins present in both importance tables: CHST3 (-48), ACAN (-46), SUSD5 (-39), CD109 (-38), HABP2 (-37), FMOD (-35), GOLM2 (-33), MAN1B1 (-31), HSPG2 (-22), COL11A2 (-21).
16. New three-algorithm intersection Top10: GAL;GOLGA3;TSPAN14.
17. New three-algorithm intersection Top20: IGF1;GAL;GOLGA3;TSPAN14.
18. LASSO changed: NO. Implementation unchanged; rerun only.
19. Fixed-85 integrity: candidate input=85; sample IDs/order, High/Low outcome, 15 outer assignments, outer seeds, and fold sizes are unchanged. Equality checks passed before this report was written.
20. Invalidated old outputs: snapshot `integrated_table_85.csv`, `outer_cv_metrics.csv`, `xgboost_full_importance.csv`, plus their M15 report/audit interpretations. The copied Boruta table is historical context only; Boruta was an unchanged-branch rerun.
21. ROC rebuild required: yes, as a provenance update even though Tier1 membership is unchanged; see `ROC_REBUILD_REQUIREMENT.md`.
22. Fig5 rebuild: panels b, c, and d; panel a is unaffected. See `FIG5_REBUILD_REQUIREMENT.md`.
23. D03/D08 modified: NO.
24. Strict nested run or modified: NO.
25. `git diff --check`: scoped fixed-85 ML directory exit 0. Repository-wide exit 2 is caused by pre-existing trailing whitespace in unrelated SVG files outside this repair scope.
26. `git status --short`: the target directory contains the three repaired result CSVs, two modified R scripts, five requested report/comparison files, and the new snapshot directory. The repository already had a large unrelated dirty worktree (817 status lines total).

## Sanity checks

- EN old reconstructed vs new AUROC mean / median: 0.668983/0.660714 -> 0.668688/0.662088.
- XGB best_iteration distribution: 1, 1, 1, 3, 6, 10, 10, 11, 12, 17, 19, 41, 53, 63, 120 (median=11; full-data nrounds=11).
- Outer test participates only in final prediction and AUROC calculation.
- No threshold, candidate universe, preprocessing, outcome, split, or fixed hyperparameter was changed.
- Boruta was rerun only because it is inseparable from the existing entry script; its implementation was unchanged.
