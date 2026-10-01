# Final ML Protein Set + Performance Figure Audit

Audit date: 2026-09-29.
Scope: `descriptive/analysis_v2.0/ml_v2.1/` (recursive), plus
`manuscript_v2_1/audit/STATISTICAL_REPORTING_AUDIT.md` and
`manuscript_v2_1/audit/WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`.

No model was re-trained, no hyperparameter was re-tuned, no feature was re-selected,
no frozen CSV was modified. All numbers below are read directly from the frozen
outputs. The two deliverables produced this round are:

- `docs/FINAL_ML_RESULT_AUDIT.md` (this file)
- `docs/FINAL_ML_PROTEIN_MAP.csv` (reporting-only join of frozen outputs, tagged
  `DERIVED_FROM_FROZEN_OUTPUTS;NO_MODEL_RERUN`)

---

## 1. What the 85 proteins are, in ML terms

The 85 locked Discovery DEPs (D03 candidate lock) are the
**INPUT_CANDIDATE_SET** for the fixed-85 conditional ML run. They are NOT a
final ML-prioritized panel.

| Bucket | Status in the frozen repo |
|---|---|
| INPUT_CANDIDATE_SET | **YES** — `integrated_table_85.csv` has exactly 85 rows; `run_v2_1_ml.R` asserts `nrow == 85` on `D03_locked_candidates.csv`. |
| FINAL_ML_PRIORITIZED_SET (formal) | **NO** — no column named `Final_Tier`, `Integrated_Tier`, `Priority_class`, `Selected`, `Confirmed`, `Tier`, or `Final` exists in `integrated_table_85.csv`. |
| STRICT_NESTED_SELECTED_SET (formal) | **NO** — `strict_nested/README_METHODS.md` line 77 explicitly: "This run does NOT define a final panel. No composite score is computed." |
| LATER ML feature prioritization | **YES, but descriptive only** — LASSO/EN outer-fold selection frequencies, hand-rolled Boruta status, XGBoost full-data gain ranking. None of these produces a formal cutoff on disk. |
| Formal Tier on disk | **NO** — the only tier logic lives in the read-only reporting script `summarize_tiers.R` (not a frozen result). |

**Bottom line:** fixed-85 uses all 85 as model inputs. ML then produces
importance / selection rankings, but no frozen artifact crowns a smaller set.
Calling any subset "the final ML panel" would be an over-claim.

---

## 2. Formal definition search inside `integrated_table_85.csv`

Actual columns (44 total):

```
PG.ProteinGroups, Gene_symbol.x, Discovery_log2FC.x, Discovery_BH_FDR,
Discovery_direction, Contrast, log2FC, SE, CI_low, CI_high, P_value,
Candidate_family_BH_FDR, AveExpr, residual_df, Model_status,
Discovery_log2FC.y, Direction_concordant, Nominal_replication,
FDR_supported_replication, Effect_difference_signed,
Effect_difference_absolute, PG.Genes, PG.ProteinDescriptions, PG.ProteinNames,
PG.CV, PG.Qvalue, PG.MolecularWeight, Gene_symbol.y, Display_label,
LASSO_selection_freq, LASSO_mean_coef, LASSO_sign_consistency,
EN_selection_freq, EN_mean_coef,
Boruta_confirmed_freq, Boruta_mean_frac_beat,
XGBoost_mean_rank, XGBoost_mean_gain,
LASSO_full_coef, EN_full_coef, Boruta_full_status, XGBoost_full_gain
```

No `Tier`, `Priority`, `Selected`, `Confirmed`, `Final`, `Nested_frequency`,
or `Integrated_tier` column exists. The closest ML-prioritization fields are
the four frequency / importance columns listed above.

The only "tier" rule in the repo is the informal one in `summarize_tiers.R`:

- **Tier 1** = `LASSO_selection_freq >= 0.7 AND EN_selection_freq >= 0.7`
- **Tier 2** = `0.4 <= LASSO_selection_freq < 0.7` (Tier 1 excluded)

These are reporting thresholds, not a frozen panel definition. They are
recomputed live by that script; they are not written to any CSV.

### Counts under that informal rule (recomputed from frozen `integrated_table_85.csv`)

| Tier | n | Proteins (gene symbols) |
|---|---|---|
| Tier 1 (LASSO≥0.7 AND EN≥0.7) | **5** | GAL, TSPAN14, DMP1, IGF1, GOLGA3 |
| Tier 2 (0.4≤LASSO<0.7) | **9** | TAC3, GPNMB, F11R, APOD, CLEC4M, APOA5, B3GALNT1, FCER2, TNR |
| Below both | 71 | — |

These 5 + 9 are NOT a formal final set; they are the largest recurring LASSO/EN
hits under thresholds that exist only in a reporting script.

---

## 3. Boruta-style audit

Implementation (from `run_v2_1_ml.R` lines 139–189): hand-rolled ranger with
shadow variables, 15 inner runs on the full-data fit (25 on full-data),
per-feature binomial test vs p=0.5, BH adjust, cutoff `p_tail = 0.025`. This is
**not** the CRAN `Boruta` package; the audit docs require the qualifier
"Boruta-style ranger importance".

`results/boruta_full_data.csv` (85 rows):

| Status | Count |
|---|---|
| Confirmed | **85** |
| Tentative | 0 |
| Rejected | 0 |

Every feature has `boruta_frac_beat_shadow = 1.0` and
`boruta_padj = 2.98e-08 < 0.025`. On a pre-selected 85-protein DEP set, the
shadow-variable test has no discriminating power — all 85 clear the threshold.

**Interpretation:** Boruta-style does NOT define a smaller prioritized set.
Its only valid use here is as a "all-85 passed the sanity check" statement.
There is no Boruta-style confirmed list to plot as a panel.

`Boruta_rank` is reported as tied rank 1 for all 85 in
`FINAL_ML_PROTEIN_MAP.csv` (no meaningful ordering).

---

## 4. XGBoost feature importance audit

`results/xgboost_full_importance.csv` (85 rows, sorted by `Gain` descending):

- Metric: **Gain** (primary), with Cover and Frequency also present.
- Source: **full-data fit on the locked 85** (not CV-derived). Per the statistical
  audit, this is "post-selection descriptive importance on the fixed 85 panel;
  not causal, not a biomarker effect, not independent mechanism."

Top 10 by Gain (gene symbol, gain, XGB rank):

| Rank | Gene | Gain |
|---|---|---|
| 1 | GOLGA3 | 0.0844 |
| 2 | TSPAN14 | 0.0432 |
| 3 | APOA5 | 0.0305 |
| 4 | COMP | 0.0280 |
| 5 | CD58 | 0.0268 |
| 6 | GAL | 0.0266 |
| 7 | TNR | 0.0251 |
| 8 | ST3GAL6 | 0.0238 |
| 9 | ATP6AP2 | 0.0236 |
| 10 | VTN | 0.0231 |

Top 11–20: P05090 (APOD), P13591 (NCAM1), Q9H0B8 (CRISPLD2), P26022 (PTX3),
P05019 (IGF1), P08493 (MGP), Q16706 (MAN2A1), O95967 (EFEMP2), Q13740 (ALCAM),
Q13316 (DMP1).

No cutoff was applied; these are **top-ranked proteins**, not "selected
proteins". Do not promote them to a panel without an explicit, pre-registered
threshold.

---

## 5. Strict-nested feature stability

Source: `strict_nested/strict_nested_feature_stability.csv` (634 unique PGs
that appeared as a fold-local DEP in ≥1 of 15 outer splits). Columns:
`dep_appearance_freq`, `lasso_selection_freq` (conditional on being a DEP in
that split), `en_selection_freq`, `overall_lasso_freq`, `overall_en_freq`.

### Anchor-5 recurrence (from frozen CSV; matches M15 report)

| PG | Gene | DEP freq (out of 15) | LASSO sel freq (conditional) | EN sel freq (conditional) |
|---|---|---|---|---|
| Q8NG11 | TSPAN14 | 1.00 (15/15) | 1.00 | 1.00 |
| P22466 | GAL | 1.00 (15/15) | 0.93 | 1.00 |
| Q13316 | DMP1 | 0.93 (14/15) | 0.79 | 0.93 |
| P05019 | IGF1 | 0.73 (11/15) | 0.73 | 0.82 |
| Q08378 | GOLGA3 | 0.80 (12/15) | 0.42 | 0.75 |

Only 5 proteins appear as a fold-local DEP in ≥80% of splits; only 3 have
overall LASSO selection frequency ≥0.7. Fold-local DEP counts per split range
8–618 (verified in `strict_nested_outer_metrics.csv`).

This is a **NESTED_STABILITY_SET** defined by recurrence, not a final panel.
It is a different universe from the fixed-85 Tier list and must not be merged
with it on the figure.

---

## 6. AUC / ROC / performance audit

### 6.1 Fixed-85 conditional (`results/outer_cv_metrics.csv`, 15 splits)

| Metric | Mean | Median | Min | Max |
|---|---|---|---|---|
| LASSO AUROC | 0.665 | 0.654 | 0.50 | 0.77 |
| XGBoost AUROC | 0.710 | 0.687 | 0.54 | 0.84 |

- Model: LASSO (α=1, `lambda.min`) and XGBoost (small fixed grid, early stopping).
- Resampling: 5 outer folds × 3 repeats = 15 paired splits, seeds 20260928/29/30.
- **Elastic Net is NOT in this file as an AUROC.** Only `en_alpha` is recorded
  (selected α per split: 0.1 ×6, 0.3 ×4, 0.5 ×3, 0.7 ×2). There is no
  `en_auroc` column in `outer_cv_metrics.csv`.
- **No AUPRC, no accuracy, no balanced accuracy, no sensitivity/specificity,
  no calibration, no CI.** Only point AUROC per split.
- **No prediction-level output.** There is no `fixed_85_predictions.csv` or
  equivalent. ROC curve reconstruction from fixed-85 is **UNAVAILABLE** — do
  not fabricate one.

### 6.2 Strict-nested sensitivity (`strict_nested/strict_nested_outer_metrics.csv`, 15 splits)

| Metric | Mean | Median | Min | Max |
|---|---|---|---|---|
| LASSO AUROC | 0.634 | 0.637 | 0.53 | 0.75 |
| LASSO AUPRC | 0.615 | 0.624 | 0.44 | 0.76 |
| EN AUROC | 0.629 | 0.639 | 0.47 | 0.73 |
| EN AUPRC | 0.612 | 0.616 | 0.44 | 0.73 |

- Per-split DEP count range: 8–618. All 15 splits completed, `failure` all NA.
- **Prediction-level output EXISTS**: `strict_nested_outer_predictions.csv`
  (813 rows = 271 Discovery samples × 1 appearance in outer test; columns
  `rep_id, fold, sample_id, y_true, lasso_pred, en_pred`). ROC / PR curves for
  the strict-nested branch **can** be redrawn from these frozen predictions
  without re-running any model.

### 6.3 Side-by-side interpretation (descriptive only)

- Fixed-85 LASSO median AUROC 0.654 → strict-nested LASSO median AUROC 0.637.
  The drop is small (~0.02). This is the intended sensitivity statement:
  conditioning on the same-cohort 85 lock did not grossly inflate the
  estimate. It is NOT a formal significance test and NOT external validation.
- Fixed-85 XGBoost AUROC (mean 0.710) has no strict-nested comparator
  (XGBoost was explicitly forbidden in the strict-nested run).
- Fixed-85 = **conditional-on-the-locked-85 exploratory estimate**.
- Strict-nested = **leakage-controlled sensitivity estimate**.
- These two must be labeled separately on any figure; do not merge into one
  "ML AUC" number.

---

## 7. "Final ML protein set" — conclusion

**NO FORMAL FINAL ML PANEL EXISTS in the frozen repo.**

Applying the priority order from the brief:

1. Priority 1 (`Final_Tier` / `Integrated_Tier` / `Priority_class`): **absent**.
2. Priority 2 (Boruta-style confirmed): **non-discriminating** (85/85 confirmed
   by construction; cannot define a smaller set).
3. Priority 3 (XGBoost ranking only): valid as **top-ranked**, not as selected.

The honest buckets are:

| Bucket | n | Proteins | Source |
|---|---|---|---|
| INPUT_CANDIDATE_SET | 85 | all locked D03 DEPs | `integrated_table_85.csv` |
| REPORTED_TIER1_fixed85 (informal, from `summarize_tiers.R`) | 5 | GAL, TSPAN14, DMP1, IGF1, GOLGA3 | recomputed from frozen CSV |
| REPORTED_TIER2_fixed85 (informal) | 9 | TAC3, GPNMB, F11R, APOD, CLEC4M, APOA5, B3GALNT1, FCER2, TNR | recomputed from frozen CSV |
| XGB_TOP10 (ranking only, no cutoff) | 10 | GOLGA3, TSPAN14, APOA5, COMP, CD58, GAL, TNR, ST3GAL6, ATP6AP2, VTN | `xgboost_full_importance.csv` |
| NESTED_STABLE_dep≥0.93 (recurrence only) | 3 | TSPAN14, GAL, DMP1 | `strict_nested_feature_stability.csv` |
| NESTED_STABLE_dep≥0.80 (recurrence only) | 5 (incl. above + IGF1, GOLGA3) | TSPAN14, GAL, DMP1, IGF1, GOLGA3 | same |

These are **four different lenses on overlapping proteins**, not one panel.
On the figure they must be labeled as such.

---

## 8. Integrated evidence table — actual fields

`integrated_table_85.csv` already carries most of what the brief asks for, but
under different names:

| Brief field | Actual frozen field |
|---|---|
| Protein | `PG.ProteinGroups` |
| Gene_symbol | `Gene_symbol.x` |
| Discovery_log2FC | `Discovery_log2FC.x` |
| Discovery_FDR | `Discovery_BH_FDR` |
| Replication direction | `Direction_concordant` |
| Replication P / FDR | `P_value`, `Nominal_replication`, `FDR_supported_replication`, `Candidate_family_BH_FDR` |
| Boruta-style status | `Boruta_full_status` (and `Boruta_confirmed_freq`, `Boruta_mean_frac_beat`) |
| XGBoost importance | `XGBoost_full_gain` (and `XGBoost_mean_rank`, `XGBoost_mean_gain`) |
| Nested selection frequency | **NOT present** — lives in `strict_nested_feature_stability.csv`, joined on `PG.ProteinGroups` |
| Tier | **NOT present** — only in `summarize_tiers.R` logic |

`docs/FINAL_ML_PROTEIN_MAP.csv` is the reporting-only join that adds the
missing nested frequencies and the informal tier label. It does NOT backfill
any new statistics.

---

## 9. Recommended final Supplementary ML Figure architecture

The repo already contains a staged rendering-only script
`descriptive/analysis_v2.0/code/V2_M17_figures_v3_ml_supplement.R` producing
`SuppFig_ML_prioritization.pdf/svg`. Its current panels are:

- A: top-15 XGBoost mean gain bar (colored by replication tier)
- B: top-15 LASSO / EN selection frequency (top 15 by EN)
- C: strict-nested selection frequency histogram (all 85)
- D: Discovery log2FC vs XGBoost gain scatter (all 85)

Recommended architecture for the **final** ML supplementary figure (no model
re-run; all data from frozen CSVs):

### Panel A — Performance
- **A1**: ROC curve for the **strict-nested LASSO** branch, reconstructed from
  `strict_nested_outer_predictions.csv` (813 frozen rows). Label "Strict-nested
  LASSO, outer-CV pooled predictions; median AUROC 0.64 (range 0.53–0.75)".
  Optionally overplot EN.
- **A2**: Boxplot / strip plot of **per-split AUROC** for the two branches side
  by side: fixed-85 LASSO (15 points) vs strict-nested LASSO (15 points) vs
  strict-nested EN (15 points). Fixed-85 XGBoost can be added as a second
  fixed-85 series but must be visually separated (no strict-nested comparator).
- Explicitly state on the panel: "Fixed-85 = conditional-on-locked-85;
  Strict-nested = leakage-controlled sensitivity. Fixed-85 ROC cannot be
  reconstructed (no prediction-level output)."

### Panel B — Final ML-prioritized proteins (NOT all 85)
- Plot only the **5 REPORTED_TIER1_fixed85** proteins (GAL, TSPAN14, DMP1,
  IGF1, GOLGA3), with their LASSO/EN frequencies and XGBoost gain.
- If Tier 2 is included, put them in a separate sub-array or use a visual
  weight that clearly distinguishes "tier 1 recurring" from "tier 2 recurring".
- Caption must say: "No formal final panel exists; these are the five proteins
  selected by LASSO and Elastic Net in ≥70% of outer folds under thresholds
  defined in `summarize_tiers.R`."

### Panel C — Feature prioritization
- Dot plot or aligned bars of **XGBoost top 10–15** gain, with Boruta-style
  status annotated (all 85 = Confirmed, so this is a "passes sanity check"
  annotation, not a cutoff).
- Do not label this panel "selected biomarkers". Label it "descriptive
  model-internal importance".

### Panel D — Strict-nested stability
- Bar / lollipop of `dep_appearance_freq` for the 5 nested-stable proteins
  (TSPAN14, GAL, DMP1, IGF1, GOLGA3), with conditional LASSO / EN frequencies
  overlaid.
- Annotate the 8–618 fold-local DEP range to make the instability explicit.
- Do NOT mix these with the fixed-85 Tier 1 list on the same axis without
  relabeling; they are derived from different pipelines.

### What NOT to plot
- All 85 proteins as a main feature-importance panel. The 85 may appear only
  as a small flow-diagram annotation ("candidate universe = 85") or as the
  denominator in the strict-nested histogram.
- A single "ML AUC" that merges fixed-85 and strict-nested.
- Any claim that Boruta "selected" a subset.

---

## 10. Does new analysis need to be run?

No re-training, no re-tuning, no feature re-selection. The only figure work
required is:

1. Reconstruct the strict-nested ROC from `strict_nested_outer_predictions.csv`
   (pure reporting; predictions are frozen).
2. Draw the per-split AUROC boxplot from `outer_cv_metrics.csv` +
   `strict_nested_outer_metrics.csv` (pure reporting).
3. Plot the 5 Tier-1 and 5 nested-stable proteins from
   `integrated_table_85.csv` + `strict_nested_feature_stability.csv`.

The existing `V2_M17_figures_v3_ml_supplement.R` already does most of (2) and
(3); it only lacks the performance panel (A) and the strict-nested ROC.
Modifying that rendering script is allowed (it is not a frozen result CSV),
but it must remain read-only against the frozen `.csv` inputs.

---

## 11. Git status (read-only check)

- `git diff --cached --check`: exit 0, no whitespace errors reported.
- `git status --short`: pre-existing staged changes (M17 figure script + PDF/SVG/
  source data, plus archive/doc edits) were already staged before this audit;
  this audit added `docs/FINAL_ML_RESULT_AUDIT.md` and
  `docs/FINAL_ML_PROTEIN_MAP.csv` as untracked working-tree files.
- No commit, no push, no modified frozen CSV.

---

## 12. Final one-line answer

The 85 proteins are the locked Discovery DEP candidate universe for the
conditional fixed-85 ML run; there is **no formal final ML-prioritized
protein set** on disk. The closest honest summary is five recurring
LASSO/EN hits (GAL, TSPAN14, DMP1, IGF1, GOLGA3) under informal reporting
thresholds, a non-discriminating all-85 Boruta-style pass, an XGBoost ranking
led by GOLGA3/TSPAN14/APOA5, and three strict-nested recurrence-stable proteins
(TSPAN14, GAL, DMP1). Fixed-85 conditional LASSO median AUROC is 0.65;
strict-nested LASSO median AUROC is 0.64 with frozen prediction-level outputs
available for an ROC redraw.
