# M15 / ML v2.1 Finalization Audit Report

Audit date: 2026-09-29.
Scope: `descriptive/analysis_v2.0/ml_v2.1/` (recursive).
No statistics, code, seeds, thresholds, or outputs were modified. No models were re-run.

---

## 1. Authoritative scripts

| Pipeline | Authoritative entry | Notes |
|---|---|---|
| Fixed-85 conditional analysis | `run_v2_1_ml.R` | D03-locked 85 DEP universe; Discovery High=132 / Low=139 (n=271); 5 outer folds × 3 repeats = 15 outer assessment splits; LASSO (α=1, fixed), Elastic Net (α∈{0.1,0.3,0.5,0.7}), hand-rolled Boruta (ranger + shadow), XGBoost. Full-data fits are explicitly labeled conditional/exploratory. |
| Strict whole-pipeline nested sensitivity | `strict_nested_sensitivity.R` | Starts from the full 1434-protein universe; per-outer-train fold-local DEP screen (70% detection in BOTH High+Low; Welch t-test BH-FDR<0.05) → LASSO + Elastic Net → untouched outer test. Same 15 outer folds/seeds as the fixed-85 run so the two are directly comparable. |
| Final reporting helpers | `summarize_results.R`, `summarize_tiers.R` | Read-only reporting scripts that consume `results/integrated_table_85.csv`. They do not feed back into either pipeline and do not produce the authoritative result CSVs. Kept for manuscript summarization. |

No `source()` calls exist anywhere in the directory; the two pipelines are self-contained.

---

## 2. Final result files

### Fixed-85 conditional (`results/`)
- `integrated_table_85.csv` — per-protein integrated table (D03 + D08 + LASSO/EN/Boruta/XGBoost aggregations). **FINAL_RESULT**.
- `outer_cv_metrics.csv` — per-split LASSO AUROC, XGBoost AUROC, chosen EN α. **FINAL_RESULT**.
- `boruta_full_data.csv` — full-data hand-rolled Boruta per-feature status. **SUPPORTING_RESULT**.
- `xgboost_full_importance.csv` — full-data XGBoost gain table. **SUPPORTING_RESULT**.

### Strict nested sensitivity (`strict_nested/`)
- `strict_nested_outer_metrics.csv` — per-split LASSO/EN AUROC+AUPRC, DEP counts, failure flags. All 15 splits completed (`failure` all NA). **FINAL_RESULT**.
- `strict_nested_feature_stability.csv` — cross-split DEP appearance frequency + conditional LASSO/EN selection frequency. **FINAL_RESULT**.
- `strict_nested_manifest.csv` — protocol provenance (seeds, universe, fold-local rule, models, forbidden list). **REPRODUCIBILITY_REQUIRED**.
- `README_METHODS.md` — methods doc. **REPRODUCIBILITY_REQUIRED**.
- `strict_nested_outer_predictions.csv`, `strict_nested_DEP_by_split.csv`, `strict_nested_LASSO_features_by_split.csv`, `strict_nested_ElasticNet_features_by_split.csv`, `strict_nested_feature_universe_by_split.csv`, `strict_nested_tuning.csv` — per-split supporting tables. **SUPPORTING_RESULT**.

---

## 3. Fixed-85 conditional analysis status

- Inputs: `descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv` (asserted `nrow == 85`, no duplicate PG), `descriptive/PRIMARY_dose_log2_expression.csv.gz` (1434 × 515), `descriptive/discovery_validation_split/discovery_validation_assignment.csv` (Discovery High+Low only).
- Task: Discovery High (n=132) vs Low (n=139), controls excluded.
- Outer CV: 5 × 3 = 15 splits; seeds `20260928, 20260929, 20260930`; stratified within High and Low.
- Branches: LASSO (α=1, `lambda.min`), Elastic Net (α grid, `lambda.min`, inner 5-fold CV), hand-rolled Boruta (ranger, shadow variables, 10 inner runs in outer loop / 25 on full data), XGBoost (fixed small grid, early stopping).
- Preprocessing: median imputation + center + scale fit on outer train only.
- Status: **COMPLETE**. 15/15 outer folds reported in `outer_cv_metrics.csv`; integrated table built; full-data fits written.
- Caveat preserved (per current scientific definition): full-data / integrated-table performance is a **conditional-on-the-locked-85 exploratory estimate**, NOT an unbiased leakage-free generalization estimate. The strict nested run is the leakage-controlled sensitivity comparator.

---

## 4. Strict nested sensitivity status

- Inputs: same expression matrix + split meta, but the candidate space is the full 1434-protein universe (D03 list explicitly forbidden).
- Per outer train: 70%-detection eligibility in both groups → Welch t-test → BH-FDR<0.05 → LASSO (α=1) + Elastic Net (α grid) with 5-fold inner CV → predict untouched outer test.
- 15/15 splits completed (no `too_few_deps` / `zero_variance_after_impute` failures). Fold-local DEP counts per split range 8–618 as documented in `README_METHODS.md`.
- Anchor-5 recurrence under strict pipeline (from log and `strict_nested_feature_stability.csv`): TSPAN14 (Q8NG11) DEP=1.00/LASSO=1.00/EN=1.00; GAL (P22466) 1.00/0.93/1.00; DMP1 (Q13316) 0.93/0.79/0.93; IGF1 (P05019) 0.73/0.73/0.82; GOLGA3 (Q08378) 0.80/0.42/0.75.
- Status: **COMPLETE**.

---

## 5. Debug / helper / log classification

| File | Classification | Reason |
|---|---|---|
| `00_inspect_env.R` | DEBUG_ONLY → ARCHIVE_CANDIDATE | One-shot environment probe (package versions, matrix header, split cross-tab, D03 direction tally). Not sourced by any active script, not referenced in `README_METHODS.md`, no tracked output. |
| `check_trees.R` | DEBUG_ONLY → ARCHIVE_CANDIDATE | 6-line probe that prints ranger/randomForest/Boruta/xgboost availability. Superseded by `00_inspect_env.R`. |
| `install_boruta.R` | INSTALL_HELPER → ARCHIVE_CANDIDATE | One-off `install.packages` call against Posit Package Manager. Note: the active `run_v2_1_ml.R` uses a hand-rolled Boruta via `ranger`, not the `Boruta` package, so this helper is not part of the runtime dependency chain. |
| `run.log` | LOG_ONLY | Console capture of the fixed-85 run. Authoritative provenance is in `outer_cv_metrics.csv` + in-code seeds. |
| `strict_nested_run.log` | LOG_ONLY | Console capture of the strict nested run. Authoritative provenance is in `strict_nested_manifest.csv` + `README_METHODS.md`. |

No active script `source()`-es any of these helpers. No README references them. They produce no tracked result artifacts.

---

## 6. Reproducibility dependencies

- **Random seeds**: `set.seed(20260928, kind="Mersenne-Twister", normal.kind="Inversion")` at top of both entry scripts; outer repeat seeds `20260928, 20260929, 20260930`; branch-level offsets (1000+/2000+/3000+/4000+/5001/5002/5003) for LASSO / EN / Boruta / XGBoost / full-data fits. All seeds are pinned in code.
- **Fold definitions**: deterministic stratified 5×3 split inside each script, using identical seed block and identical sample order, so fixed-85 and strict-nested outer folds are paired 1:1.
- **Sample split source**: `descriptive/discovery_validation_split/discovery_validation_assignment.csv`, filter `Split == "Discovery" & TREAT1_clean %in% c("high","low")`.
- **Frozen 85 feature source**: `descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv` (asserted exactly 85 rows, unique PG).
- **R package dependencies**: `glmnet`, `ranger`, `xgboost`, `pROC` (active pipelines). `Boruta` package is NOT required at runtime (hand-rolled implementation). `install_boruta.R` is historical only.
- **File paths**: all paths are **relative** to the repo root (`descriptive/...`). No hard-coded `F:\`, `C:\`, `Users\`, `Desktop`, `Downloads`, `temp`, or `tmp` paths were found in any `.R` file. The only absolute-looking strings are HTTPS URLs inside `install_boruta.R` (CRAN/PPM), which is itself flagged ARCHIVE_CANDIDATE.
- **External input coupling**: no active script reads from `archive/`, desktop, Downloads, temp, or manual spreadsheets. All inputs are tracked repo-relative CSVs / gz files.

---

## 7. Known limitations

1. The fixed-85 integrated table and full-data fits are **conditional / exploratory** (the 85 DEPs were locked on the same Discovery cohort). They must not be described as an unbiased out-of-sample generalization estimate. The strict nested run is the leakage-controlled comparator and its AUROC degradation vs fixed-85 is small, which is the intended sensitivity statement.
2. The hand-rolled Boruta implementation uses 15/25 iterations and a single pooled binomial test per feature; this is a lightweight ranger-based approximation of Kursa & Rudnicky (2010), not the canonical `Boruta` package with its full Confirmed/Tentative/Rejected iteration loop. This is documented in-code; interpretation should be consistent with that implementation.
3. `install_boruta.R` references a Posit Package Manager Linux/Jammy URL while the host is Windows; it is a historical install attempt and is not required for reproducibility of the committed outputs.
4. No plots/PDF/RDS objects were produced; all numeric results are CSVs. There is no companion figure generation script in this directory.

---

## 8. Files recommended for Git (this audit)

Stage explicitly (whitelist only; no `git add .`):
- `descriptive/analysis_v2.0/ml_v2.1/run_v2_1_ml.R` — ACTIVE_FINAL
- `descriptive/analysis_v2.0/ml_v2.1/strict_nested_sensitivity.R` — ACTIVE_FINAL
- `descriptive/analysis_v2.0/ml_v2.1/summarize_results.R` — SUPPORTING (manuscript reporting)
- `descriptive/analysis_v2.0/ml_v2.1/summarize_tiers.R` — SUPPORTING (manuscript tiering)
- `descriptive/analysis_v2.0/ml_v2.1/M15_FILE_AUDIT.csv` — this audit
- `descriptive/analysis_v2.0/ml_v2.1/M15_FINALIZATION_REPORT.md` — this report

Not staged:
- `00_inspect_env.R`, `check_trees.R`, `install_boruta.R` (DEBUG_ONLY / INSTALL_HELPER → ARCHIVE_CANDIDATE)
- `run.log`, `strict_nested_run.log` (LOG_ONLY; console captures, not authoritative)

Already tracked and left untouched (no re-stage needed): `results/*.csv` (4 files), `strict_nested/*` (9 files).

---

## 9. Files recommended for later archive

- `00_inspect_env.R`
- `check_trees.R`
- `install_boruta.R`
- `run.log`
- `strict_nested_run.log`

These are flagged `ARCHIVE_LATER` / `DO_NOT_TRACK` in `M15_FILE_AUDIT.csv`. They are **not deleted and not moved** by this audit.

---

## 10. Blocking issues

None.

---

## Final M15 status: **PASS_WITH_LIMITATIONS**

(Complete on both pipelines; limitations are the pre-existing scientific caveats in §7 — fixed-85 is conditional/exploratory, hand-rolled Boruta is a ranger approximation, and debug/log helpers are intentionally excluded from the Git whitelist.)
