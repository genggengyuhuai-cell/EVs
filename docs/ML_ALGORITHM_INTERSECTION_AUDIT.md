# Frozen ML Algorithm Set & Intersection Audit

Audit date: 2026-09-29.
Scope: `descriptive/analysis_v2.0/ml_v2.1/` (frozen scripts + frozen CSVs only).

No model was re-trained, no CV re-run, no Boruta recomputed, no XGBoost refit,
no threshold invented. Every number below is either (a) read directly from a
frozen result CSV, or (b) derived by set operations on frozen columns under
rules that already exist in `summarize_tiers.R`. Provenance tags used:

- **FROZEN_OUTPUT** — value read verbatim from a committed CSV.
- **FROZEN_SCRIPT_RULE** — threshold defined in a committed `.R` reporting script.
- **DERIVED_FROM_FROZEN_OUTPUTS** — set operation on frozen columns; no new statistic.

Deliverables:
- `docs/ML_ALGORITHM_INTERSECTION_AUDIT.md` (this file)
- `docs/ML_ALGORITHM_INTERSECTION_MAP.csv` (85 rows, reporting-only join)

---

## 1. Candidate universe

| Item | Value | Source | Provenance |
|---|---|---|---|
| INPUT_CANDIDATE_SET | **85 locked D03 Discovery DEPs** | `run_v2_1_ml.R` asserts `nrow == 85` on `D03_locked_candidates.csv`; `results/integrated_table_85.csv` has exactly 85 rows | FROZEN_OUTPUT |

85 = the fixed-85 ML candidate universe. It is **not** a final ML panel and
**not** a validated biomarker set.

---

## 2. LASSO evidence

| Item | Value | Source | Provenance |
|---|---|---|---|
| LASSO input count | 85 | `integrated_table_85.csv` (85 rows); `run_v2_1_ml.R` | FROZEN_OUTPUT |
| Selection definition | nonzero coefficient at `lambda.min` in outer-fold LASSO (α=1) | `run_v2_1_ml.R` | FROZEN_SCRIPT_RULE |
| Frequency denominator | 15 outer splits (5 folds × 3 repeats) | `outer_cv_metrics.csv` (15 rows); seeds 20260928/29/30 | FROZEN_OUTPUT |
| Frequency field | `LASSO_selection_freq` in `integrated_table_85.csv` | same | FROZEN_OUTPUT |
| Reporting threshold | `>= 0.70` | `summarize_tiers.R` line 6 (`df$LASSO_selection_freq >= 0.7 & df$EN_selection_freq >= 0.7`) | FROZEN_SCRIPT_RULE |

**REPORTED_LASSO_STABLE_SET (LASSO ≥ 0.70): n = 5**

| Gene | LASSO freq | EN freq | XGB rank |
|---|---|---|---|
| GAL | 1.000 | 1.000 | 6 |
| TSPAN14 | 1.000 | 1.000 | 2 |
| DMP1 | 0.867 | 0.933 | 20 |
| IGF1 | 0.800 | 0.800 | 15 |
| GOLGA3 | 0.733 | 0.867 | 1 |

Descriptive-only supplementary counts (not new selection thresholds):

| Threshold | n |
|---|---|
| LASSO = 1.00 (selected in all 15 folds) | 2 (GAL, TSPAN14) |
| LASSO ≥ 0.40 | 14 |
| LASSO > 0 (selected in ≥1 fold) | 34 |
| LASSO = 0 (never selected) | 51 |

These counts are descriptive only; the only reporting rule in the frozen
workflow is `>= 0.70`.

---

## 3. Elastic Net evidence

| Item | Value | Source | Provenance |
|---|---|---|---|
| EN input count | 85 | `integrated_table_85.csv` | FROZEN_OUTPUT |
| Selection definition | nonzero coefficient at chosen (α, λ); α ∈ {0.1, 0.3, 0.5, 0.7} by inner CV | `run_v2_1_ml.R` | FROZEN_SCRIPT_RULE |
| Frequency denominator | 15 outer splits | `outer_cv_metrics.csv` | FROZEN_OUTPUT |
| Frequency field | `EN_selection_freq` | `integrated_table_85.csv` | FROZEN_OUTPUT |
| Reporting threshold | `>= 0.70` | `summarize_tiers.R` line 6 | FROZEN_SCRIPT_RULE |

**REPORTED_EN_STABLE_SET (EN ≥ 0.70): n = 9**

| Gene | LASSO freq | EN freq | XGB rank |
|---|---|---|---|
| TSPAN14 | 1.000 | 1.000 | 2 |
| GAL | 1.000 | 1.000 | 6 |
| DMP1 | 0.867 | 0.933 | 20 |
| GOLGA3 | 0.733 | 0.867 | 1 |
| F11R | 0.600 | 0.800 | 55 |
| APOD | 0.600 | 0.800 | 11 |
| IGF1 | 0.800 | 0.800 | 15 |
| RABGGTA | 0.333 | 0.733 | 39 |
| TAC3 | 0.600 | 0.733 | 29 |

Descriptive-only: EN > 0 in 46/85; EN ≥ 0.40 in 22/85.

---

## 4. Tier-1 rule cross-check

`summarize_tiers.R` defines Tier 1 as `LASSO_selection_freq >= 0.7 AND
EN_selection_freq >= 0.7`.

| Item | Value |
|---|---|
| N_TIER1 | **5** |
| Tier-1 genes | GAL, TSPAN14, DMP1, IGF1, GOLGA3 |

This exactly matches the previous audit (`docs/FINAL_ML_RESULT_AUDIT.md` §2).
**No frozen-evidence conflict.**

---

## 5. XGBoost evidence

| Item | Value | Source | Provenance |
|---|---|---|---|
| XGBoost input count | 85 | `xgboost_full_importance.csv` has 85 rows | FROZEN_OUTPUT |
| Importance metric | **Gain** (also Cover, Frequency columns present) | `xgboost_full_importance.csv` | FROZEN_OUTPUT |
| Fit scope | Full-data fit on the locked 85 (descriptive post-selection importance) | `run_v2_1_ml.R`; STATISTICAL_REPORTING_AUDIT §12 | FROZEN_OUTPUT |
| Algorithm-intrinsic cutoff | **None** — no row is dropped; all 85 receive a Gain value | `xgboost_full_importance.csv` | FROZEN_OUTPUT |

There is **no** frozen `XGBoost_selected_N_proteins` set. The correct term is
**top-ranked proteins**.

### Reporting cutoffs (from existing reporting-derived workflow)

| Set | n | Source | Provenance |
|---|---|---|---|
| XGB_TOP10_SET | 10 | `docs/FINAL_ML_PROTEIN_MAP.csv` (previous audit) flags `XGB_TOP10` by rank ≤ 10; this is a reporting bucket, not an algorithm-intrinsic threshold | DERIVED_FROM_FROZEN_OUTPUTS |
| XGB_TOP20_SET | 20 | same, rank ≤ 20 | DERIVED_FROM_FROZEN_OUTPUTS |

**XGB Top10 (by Gain, descending):**
GOLGA3 (0.0844), TSPAN14 (0.0432), APOA5 (0.0305), COMP (0.0280), CD58 (0.0268),
GAL (0.0266), TNR (0.0251), ST3GAL6 (0.0238), ATP6AP2 (0.0236), VTN (0.0231).

**XGB Top11–20:** APOD (0.0229), NCAM1 (0.0212), CRISPLD2 (0.0211),
PTX3 (0.0208), IGF1 (0.0196), MGP (0.0195), MAN2A1 (0.0193), EFEMP2 (0.0187),
ALCAM (0.0172), DMP1 (0.0171).

No new Top5 / Top15 / arbitrary-gain cutoff was introduced.

---

## 6. Three-algorithm intersections

Strict-nested is **not** a fourth algorithm; it is an evaluation architecture.
Intersections below use only LASSO, Elastic Net, and XGBoost.

### Analysis A — stricter display (XGB Top10)

| Set | n | Genes |
|---|---|---|
| LASSO ≥ 0.70 | 5 | GAL, TSPAN14, DMP1, IGF1, GOLGA3 |
| EN ≥ 0.70 | 9 | TSPAN14, GAL, DMP1, GOLGA3, F11R, APOD, IGF1, RABGGTA, TAC3 |
| XGB Top10 | 10 | GOLGA3, TSPAN14, APOA5, COMP, CD58, GAL, TNR, ST3GAL6, ATP6AP2, VTN |
| **LASSO ∩ EN** | **5** | GAL, TSPAN14, DMP1, IGF1, GOLGA3 (= Tier 1) |
| **LASSO ∩ XGB Top10** | **3** | GAL, GOLGA3, TSPAN14 |
| **EN ∩ XGB Top10** | **3** | GAL, GOLGA3, TSPAN14 |
| **LASSO ∩ EN ∩ XGB Top10** | **3** | GAL, GOLGA3, TSPAN14 |

### Analysis B — broader display (XGB Top20)

| Set | n | Genes |
|---|---|---|
| XGB Top20 | 20 | Top10 + APOD, NCAM1, CRISPLD2, PTX3, IGF1, MGP, MAN2A1, EFEMP2, ALCAM, DMP1 |
| **LASSO ∩ XGB Top20** | **5** | GAL, GOLGA3, TSPAN14, DMP1, IGF1 (all five Tier-1 proteins) |
| **EN ∩ XGB Top20** | **6** | GAL, GOLGA3, TSPAN14, DMP1, IGF1, APOD |
| **LASSO ∩ EN ∩ XGB Top20** | **5** | GAL, GOLGA3, TSPAN14, DMP1, IGF1 |

---

## 7. Tier-1 proteins — full algorithm evidence

| Gene | LASSO freq | EN freq | XGB rank | XGB Gain | In Top10 | In Top20 | Nested count /15 | Nested freq |
|---|---|---|---|---|---|---|---|---|
| GOLGA3 | 0.733 | 0.867 | 1 | 0.0844 | YES | YES | 12 | 0.800 |
| TSPAN14 | 1.000 | 1.000 | 2 | 0.0432 | YES | YES | 15 | 1.000 |
| GAL | 1.000 | 1.000 | 6 | 0.0266 | YES | YES | 15 | 1.000 |
| IGF1 | 0.800 | 0.800 | 15 | 0.0196 | NO | YES | 11 | 0.733 |
| DMP1 | 0.867 | 0.933 | 20 | 0.0171 | NO | YES | 14 | 0.933 |

- **Which Tier-1 proteins are also XGB Top10?** GOLGA3 (rank 1), TSPAN14
  (rank 2), GAL (rank 6) — 3 of 5.
- **Which Tier-1 proteins are also XGB Top20?** All 5 (IGF1 rank 15, DMP1
  rank 20).

---

## 8. Strict-nested stability as independent support layer

Computed from `strict_nested_feature_stability.csv`
(`dep_appearance_freq`, denominator 15 outer splits). This is **nested
stability support**, not a fourth algorithm and not merged into the Venn.

| Threshold | n among the 85 | Genes |
|---|---|---|
| Nested freq ≥ 0.93 | 8 | GAL, TSPAN14, ACAN, B3GALNT1, APOD, OMD, HSPG2, DMP1 |
| Nested freq ≥ 0.80 | 20 | TSPAN14, ACAN, GAL, B3GALNT1, APOD, HSPG2, DMP1, OMD, ST3GAL6, NDNF, DCN, PDGFRB, MAN1B1, CDH23, CDH13, CLEC11A, GOLGA3, NCAM1, SPP2, GPC1 |

Note that several nested-stable proteins (ACAN, B3GALNT1, APOD, OMD, HSPG2,
ST3GAL6, NDNF, DCN, PDGFRB, etc.) are **not** in the three-algorithm LASSO/EN
Tier-1 set. This is expected: nested stability measures fold-local
re-discovery under a leakage-controlled architecture, which is a different
question from fixed-85 penalized selection frequency. They must be reported
side-by-side, not merged.

---

## 9. Boruta-style handling

`boruta_full_data.csv`: **85/85 Confirmed**, 0 Tentative, 0 Rejected
(`boruta_frac_beat_shadow = 1.0` for every protein; `padj = 2.98e-08 <
p_tail = 0.025`).

**Interpretation:** Boruta-style served as a shadow-feature sanity check but
did **not** reduce the 85-candidate universe. It is **NON_DISCRIMINATING_FOR_
PRIORITIZATION** and is excluded from the three-algorithm Venn/UpSet.

---

## 10. Algorithm flow

```
85 locked Discovery DEPs  (INPUT_CANDIDATE_SET, FROZEN_OUTPUT)
        |
        +---- LASSO (alpha=1, lambda.min)
        |       input = 85
        |       selection = nonzero coef in outer fold
        |       denominator = 15 outer splits
        |       reporting rule (summarize_tiers.R): freq >= 0.70
        |       REPORTED_LASSO_STABLE_SET = 5
        |
        +---- Elastic Net (alpha in {0.1,0.3,0.5,0.7}, lambda.min)
        |       input = 85
        |       selection = nonzero coef in outer fold
        |       denominator = 15 outer splits
        |       reporting rule (summarize_tiers.R): freq >= 0.70
        |       REPORTED_EN_STABLE_SET = 9
        |
        +---- XGBoost (full-data, descriptive)
                input = 85
                ranked output = 85 (Gain; no algorithm-intrinsic cutoff)
                XGB_TOP10_SET (reporting bucket) = 10
                XGB_TOP20_SET (reporting bucket) = 20

Tier1 = LASSO>=0.70 AND EN>=0.70 = 5 (GAL, TSPAN14, DMP1, IGF1, GOLGA3)
```

All three algorithms consumed exactly 85 inputs. No algorithm's actual input
differed from 85.

---

## 11. Provenance table (core numbers)

| Value | Definition | Source file | Source field / rule | Provenance |
|---|---|---|---|---|
| 85 | Candidate universe | `integrated_table_85.csv` | row count | FROZEN_OUTPUT |
| 15 | Outer splits | `outer_cv_metrics.csv` | row count | FROZEN_OUTPUT |
| LASSO freq | nonzero coef / 15 | `integrated_table_85.csv` | `LASSO_selection_freq` | FROZEN_OUTPUT |
| EN freq | nonzero coef / 15 | `integrated_table_85.csv` | `EN_selection_freq` | FROZEN_OUTPUT |
| LASSO ≥ 0.70 → 5 | reporting threshold | `summarize_tiers.R` line 6 | `LASSO_selection_freq >= 0.7` | FROZEN_SCRIPT_RULE |
| EN ≥ 0.70 → 9 | reporting threshold | `summarize_tiers.R` line 6 | `EN_selection_freq >= 0.7` | FROZEN_SCRIPT_RULE |
| XGB Gain | full-data gain | `xgboost_full_importance.csv` | `Gain` | FROZEN_OUTPUT |
| XGB rank | rank by Gain desc | derived | row order | DERIVED_FROM_FROZEN_OUTPUTS |
| XGB Top10 = 10 | reporting bucket | derived | rank ≤ 10 | DERIVED_FROM_FROZEN_OUTPUTS |
| XGB Top20 = 20 | reporting bucket | derived | rank ≤ 20 | DERIVED_FROM_FROZEN_OUTPUTS |
| Nested freq | fold-local DEP / 15 | `strict_nested_feature_stability.csv` | `dep_appearance_freq` | FROZEN_OUTPUT |
| Boruta status | shadow test | `boruta_full_data.csv` | `boruta_status` | FROZEN_OUTPUT |
| All intersections | set operations | this audit | — | DERIVED_FROM_FROZEN_OUTPUTS |

No `NEW_ANALYSIS`, no `POST_HOC_THRESHOLD`, no `INFERRED_WITHOUT_SOURCE`.

---

## 12. Interpretation boundary

The three-algorithm intersections describe **proteins concordantly prioritized
across the frozen LASSO, Elastic Net, and XGBoost reporting frameworks**. They
are **not** final biomarkers, **not** validated biomarkers, **not** causal
proteins, and **not** independent predictors. Even though the Top10 triple
intersection is only 3 proteins (GAL, GOLGA3, TSPAN14), this does not license
defining a new "final panel" — the brief explicitly forbids that.

---

## 13. Git / process check

- No model re-run, no CV re-run, no Boruta recompute, no XGBoost refit.
- No post-hoc cutoff introduced (Top10/Top20 buckets already existed in the
  prior reporting-derived map; 0.70 threshold already existed in
  `summarize_tiers.R`).
- No frozen CSV modified.
- `git diff --cached --check`: exit 0.
- `git status --short`: the two new files
  `docs/ML_ALGORITHM_INTERSECTION_AUDIT.md` and
  `docs/ML_ALGORITHM_INTERSECTION_MAP.csv` appear as untracked (`??`).
- No commit, no push.
