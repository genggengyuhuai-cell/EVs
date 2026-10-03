# SVM-RFE Post-Freeze Exploratory Audit

**Analysis_status:** POST_FREEZE_EXPLORATORY
**Input_universe:** 85 locked D03 Discovery DEPs
**Frozen_models_modified:** NO
**Existing_frozen_results_recomputed:** NO

This is an exploratory sensitivity analysis. It does NOT redefine the frozen
analysis-v2.1 Tier-1 set and does NOT constitute a validated biomarker panel.

---

## 1. Run contract

| Item | Value |
|---|---|
| Input N | **85** (verified; `stopifnot(nrow(d03) == 85)`) |
| Outcome | Discovery High (n=132) vs Low (n=139); controls excluded |
| Outer folds | 15 (5 × 3 repeats, seeds 20260928/29/30, exact reproduction of ml_v2.1) |
| Inner CV | 5-fold stratified on outer train |
| Kernel | **linear** (per spec; weights directly interpretable) |
| C grid | {0.1, 1, 10} |
| Subset-size grid | {1, 2, 3, 5, 10, 15, 20, 30, 40, 60, 85} |
| Selection rule | max mean inner-CV AUROC; 1-SE tie-break to smaller size |
| Outer test leakage | none (RFE + C + subset size chosen on outer train only) |

## 2. Per-fold selected feature count

| rep_id | fold | chosen C | chosen subset size | inner best AUROC | outer AUROC | outer AUPRC |
|---|---|---|---|---|---|---|
| 1 | 1 | 10 | 30 | 0.788 | 0.608 | 0.451 |
| 1 | 2 | 1 | 40 | 0.747 | 0.577 | 0.463 |
| 1 | 3 | 10 | 5 | 0.729 | 0.725 | 0.651 |
| 1 | 4 | 10 | 30 | 0.780 | 0.648 | 0.404 |
| 1 | 5 | 10 | 30 | 0.736 | 0.574 | 0.511 |
| 2 | 1 | 0.1 | 30 | 0.738 | 0.635 | 0.552 |
| 2 | 2 | 1 | 20 | 0.776 | 0.526 | 0.485 |
| 2 | 3 | 1 | 15 | 0.780 | 0.529 | 0.501 |
| 2 | 4 | 10 | 15 | 0.731 | 0.555 | 0.556 |
| 2 | 5 | 0.1 | 30 | 0.746 | 0.654 | 0.683 |
| 3 | 1 | 0.1 | 15 | 0.772 | 0.492 | 0.469 |
| 3 | 2 | 1 | 10 | 0.747 | 0.542 | 0.538 |
| 3 | 3 | 0.1 | 20 | 0.766 | 0.599 | 0.525 |
| 3 | 4 | 0.1 | 15 | 0.732 | 0.603 | 0.581 |
| 3 | 5 | 0.1 | 30 | 0.770 | 0.591 | 0.583 |

**Selected feature count per fold:** median = **20**, range = **5–40**.

## 3. Outer performance

| Metric | Mean | Median | Min | Max |
|---|---|---|---|---|
| Outer AUROC | 0.591 | 0.591 | 0.492 | 0.725 |
| Outer AUPRC | 0.530 | 0.525 | 0.404 | 0.683 |

For context, frozen fixed-85 LASSO median AUROC = 0.654; strict-nested LASSO
median AUROC = 0.637. SVM-RFE outer AUROC is ~0.05–0.06 lower, consistent with
an additional feature-selection step nested inside CV.

## 4. SVM-RFE feature stability (across 15 outer folds)

| Threshold | n | Genes |
|---|---|---|
| freq ≥ 0.70 (REPORTED_STABLE) | **3** | **CSF1, GOLGA3, TSPAN14** |
| freq ≥ 0.80 | 1 | CSF1 |
| freq ≥ 0.93 | 0 | (none) |
| freq > 0 (selected in ≥1 fold) | 44 | — |

Per-protein detail for the REPORTED_STABLE set:

| Gene | PG | selection_count / 15 | frequency |
|---|---|---|---|
| CSF1 | P09603 | 13 | 0.867 |
| GOLGA3 | Q08378 | 11 | 0.733 |
| TSPAN14 | Q8NG11 | 11 | 0.733 |

## 5. Tier-1 5 proteins — SVM-RFE evidence

| Gene | PG | SVM-RFE count /15 | SVM-RFE freq | ≥0.70? | ≥0.80? | ≥0.93? |
|---|---|---|---|---|---|---|
| GOLGA3 | Q08378 | 11 | 0.733 | YES | no | no |
| TSPAN14 | Q8NG11 | 11 | 0.733 | YES | no | no |
| IGF1 | P05019 | 8 | 0.533 | no | no | no |
| GAL | P22466 | 4 | 0.267 | no | no | no |
| DMP1 | Q13316 | 4 | 0.267 | no | no | no |

Only **GOLGA3 and TSPAN14** cross the reporting-aligned 0.70 SVM-RFE threshold.
GAL and DMP1 (which are 100% LASSO/EN stable in the fixed-85 run) are selected
in only 4/15 outer folds by SVM-RFE — a notable divergence between the linear
penalized models and the linear SVM-RFE ranking.

## 6. Intersections with frozen reporting sets

All intersections below use `SVM_RFE_selection_frequency >= 0.70` as the
exploratory SVM-RFE set. This is a reporting-aligned descriptive threshold,
not a pre-registered SVM-RFE cutoff.

| Set | n | Genes |
|---|---|---|
| SVM-RFE ≥ 0.70 (REPORTED_STABLE) | 3 | CSF1, GOLGA3, TSPAN14 |
| LASSO ≥ 0.70 (frozen) | 5 | GAL, TSPAN14, DMP1, IGF1, GOLGA3 |
| EN ≥ 0.70 (frozen) | 9 | TSPAN14, GAL, DMP1, GOLGA3, F11R, APOD, IGF1, RABGGTA, TAC3 |
| Tier1 = LASSO ∩ EN (frozen) | 5 | GAL, TSPAN14, DMP1, IGF1, GOLGA3 |
| XGB Top10 (frozen) | 10 | GOLGA3, TSPAN14, APOA5, COMP, CD58, GAL, TNR, ST3GAL6, ATP6AP2, VTN |
| XGB Top20 (frozen) | 20 | Top10 + APOD, NCAM1, CRISPLD2, PTX3, IGF1, MGP, MAN2A1, EFEMP2, ALCAM, DMP1 |
| **SVM-RFE ∩ LASSO** | **2** | GOLGA3, TSPAN14 |
| **SVM-RFE ∩ EN** | **2** | GOLGA3, TSPAN14 |
| **SVM-RFE ∩ XGB Top10** | **2** | GOLGA3, TSPAN14 |
| **SVM-RFE ∩ XGB Top20** | **2** | GOLGA3, TSPAN14 |
| **SVM-RFE ∩ Tier1** | **2** | GOLGA3, TSPAN14 |
| **4-way: SVM-RFE ∩ Tier1 ∩ XGB Top10** | **2** | GOLGA3, TSPAN14 |
| **4-way: SVM-RFE ∩ Tier1 ∩ XGB Top20** | **2** | GOLGA3, TSPAN14 |

**SVM-specific (selected by SVM-RFE ≥0.70 but NOT in any frozen Tier1/XGB set):**
CSF1 (P09603) — 13/15 outer folds. This is the only protein where SVM-RFE
independently surfaces a candidate not already prominent in the frozen
reporting sets.

## 7. Strict-nested stability (kept separate)

The existing `strict_nested_feature_stability.csv` measures **fold-local DEP
appearance frequency** under the leakage-controlled whole-pipeline run. It is a
different definition from SVM-RFE selection frequency. They are reported
side-by-side in `svm_rfe_intersection_proteins.csv` under
`Nested_DEP_frequency` and `SVM_RFE_selection_frequency`; they are NOT merged.

## 8. Process checks

| Item | Status |
|---|---|
| Frozen `ml_v2.1/` modified? | **NO** |
| Frozen LASSO/EN/XGB/Boruta recomputed? | **NO** |
| New discovery / DEP screening? | **NO** |
| Feature elimination inside outer CV? | **YES** |
| C / subset size chosen on outer test? | **NO** (inner CV only) |
| Post-hoc cutoff chosen to inflate intersections? | **NO** (0.70 is reporting-aligned with LASSO/EN; 0.80/0.93 are descriptive only) |
| Data leakage from full-data SVM-RFE? | **NO** (no full-data RFE was run) |
| Kernel used for ranking? | linear (not RBF) |
| Commit / push / tag? | none |

## 9. Interpretation boundary

The SVM-RFE REPORTED_STABLE set (CSF1, GOLGA3, TSPAN14) and the 4-way
intersection (GOLGA3, TSPAN14) describe **proteins concordantly prioritized
across the post-freeze SVM-RFE sensitivity layer and the frozen LASSO/EN/XGBoost
reporting frameworks**. They are NOT validated biomarkers, NOT a frozen final
panel, and NOT a redefinition of the analysis-v2.1 Tier-1 set.

## 10. Git

See `git status --short` in the final reply. This audit added files under
`descriptive/analysis_v2.0/ml_postfreeze_svm_rfe/` only. No frozen CSV in
`ml_v2.1/` was touched.
