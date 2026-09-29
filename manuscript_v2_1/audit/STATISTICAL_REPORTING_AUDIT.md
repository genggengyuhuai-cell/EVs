# Statistical Reporting Audit — v2.1 analysis freeze

Scope: mainline frozen outputs across Cohort/QC (M01–M11), M14 replication, M15 ML v2.1, M12 pathway v2.1, M12B biological context v2.1, M17 figures/source data, Discovery-validation D01–D10. Historical/debug/probe/log/archive files are not statistical authority.

No new analysis, model, feature selection, threshold tuning, or result optimization was performed. Numbers below are read directly from the frozen result CSVs.

## 1. Cohort and analysis populations

| Population | N | Source |
|---|---|---|
| Initial cohort | 519 | M17 Fig1 flow (frozen gate) |
| Final analytical cohort | 515 | M17 Fig1 flow; Group total 153+186+176 = 515; Site total = 515 |
| Discovery subset | 386 | M17 Fig1 flow |
| Reused hold-out subset | 129 | M17 Fig1 flow; M14 hierarchy denominators |

Cross-check: Fig1 source data panel b/c sums to 515; Fig5 panel a denominator is 85; M14 hierarchy rows are 85/85/83/29/1. Consistent.

Required wording: "Discovery subset" and "reused hold-out subset". The 129 hold-out is a **reused within-cohort hold-out**, not an external/independent/prospective validation cohort.

## 2. Primary and secondary analyses

- **Primary inference**: Discovery High-vs-Low DEP screen on the 1,430 protein groups (BH-FDR family A-E; 0/1,430 at BH-FDR<0.05 for overall exposure).
- **Primary candidate lock**: 85 Discovery DEPs frozen by D03 before any hold-out or ML use.
- **Reused hold-out hierarchy**: 85 estimable → 83 direction-concordant → 29 nominal P<0.05 → 1 candidate-family BH-FDR<0.05.
- **ML, two prespecified branches, reported as complementary**:
  - Fixed-85 conditional predictive analysis (LASSO / Elastic Net / hand-rolled Boruta / XGBoost), 15 outer folds.
  - Strict whole-pipeline nested sensitivity (fold-local DEP screen → LASSO / Elastic Net), 15 outer folds, same seeds/folds.
- **Pathway**: cameraPR (primary competitive), ORA (complementary), fgsea (ranked sensitivity).
- **Sensitivity / robustness**: M09 KNN missingness, M11 leave-one-site-out, M08 Firth detection, M10 pure interaction.

## 3. Multiple-testing families (must not be merged)

| Family | Tested universe | Adjustment | Field | Threshold | Role |
|---|---|---|---|---|---|
| Overall exposure abundance (A-E) | 1,430 proteins | Benjamini-Hochberg | `BH_FDR_AE` / `BH_FDR_AE_results` | 0.05 | Primary descriptive |
| Pairwise Low–Control / High–Control / High–Low (A-LC / A-HC / A-HL) | 1,430 each | BH per family | `BH_FDR` in M07 tables | 0.05 | Complementary |
| Detection Firth (A-Det-Firth) | 3,054 proteins | BH | `BH_FDR_A_Det_Firth` | 0.05 | Sensitivity |
| Pure 2-df interaction | 1,430 proteins | BH (corrected) | `interaction_BH` | 0.05 | Sensitivity |
| Replication candidate family (D08) | 85 locked candidates | BH on the 85 | `FDR_supported_replication` flag | 0.05 | Replication |
| cameraPR ranked (PATH-R pooled) | GO BP + GO MF + GO CC + Reactome | BH pooled across families | `FDR_pooled` in M12 ranked | 0.05 | Primary pathway |
| ORA (PATH-O pooled) | 85 DEP foreground vs 1,414 mapped background | BH pooled | `FDR_pooled` in M12 ORA | 0.05 | Complementary |
| fgsea | GO BP/MF/CC + Reactome | BH pooled (fgsea `padj`) | `padj` in M12 fgsea | 0.05 | Ranked sensitivity |

These FDR fields are **not interchangeable**. Manuscript must label each result with its family. Do not write a single unqualified "FDR < 0.05" without naming the family.

## 4. Effect-size reporting

- Abundance analyses report `log2FC_E` / pairwise `effect` with `CI_low`/`CI_high` and raw P + BH-FDR (M05/M07).
- Detection reports Firth LR P + BH-FDR; no effect-size CI for detection rates (by design).
- Interaction reports interaction P + BH-FDR; no interaction effect-size CI.
- ML reports outer-fold AUROC / AUPRC distribution, not a single point estimate.
- Figures show direction and magnitude; captions must name the contrast and direction. Avoid bare "significantly increased/decreased".

## 5. Discovery / replication hierarchy (locked)

| Stage | n | Correct label | Prohibited label |
|---|---|---|---|
| Locked D03 | 85 | 85 discovery DEPs / 85 locked discovery candidates | "85 validated proteins", "85 replicated proteins" |
| Estimable in hold-out | 85 | 85 proteins estimable in reused hold-out | — |
| Same direction | 83 / 85 | Direction-concordant in reused hold-out | "83 replicated", "83 validated" |
| Nominal P<0.05 | 29 / 85 | Nominal replication (P<0.05, uncorrected within family) | "29 FDR-replicated", "29 validated" |
| Candidate-family BH-FDR<0.05 | 1 / 85 | FDR-supported replication (candidate-family BH) | "1 validated biomarker" |

## 6. Environment and interaction

- M10 pure 2-df interaction: **0 / 1,430 proteins at BH-FDR < 0.05**.
- Correct wording: "No exposure × environment interaction survived the prespecified BH-FDR threshold."
- Prohibited: "There was no interaction", "Environment had no modifying effect", "No interaction effect".
- Environment-stratified estimates (High land vs Hot-humid) are **descriptive concordance**, not an interaction test. Stratified significance differences must not be rebranded as interaction evidence.
- Residual confounding and power are not formally modeled; state this as a limitation.

## 7. Site robustness / leave-one-site-out

- M11 LOO is a **sensitivity / robustness** analysis on direction stability and max |shift|.
- It is not independent validation, not external replication.
- Use "leave-one-site-out robustness" / "direction stability under site omission".

## 8. Detection / missingness

- M08 Firth detection on 3,054 proteins; 2/3,054 at BH-FDR<0.05.
- M09 KNN missingness sensitivity on the 85 locked candidates.
- "Not detected" must not be read as "biologically absent".
- Abundance (log2 intensity) and detection (presence/absence) are separate families; do not merge.

## 9. Fixed-85 ML (conditional)

- 85 features are the frozen D03 Discovery DEPs; modeling is **conditional on that locked panel**.
- 15 outer folds (5 × 3 repeats, fixed seeds) on Discovery High+Low (n≈271; train ≈216–218, test ≈53–55).
- Branches: LASSO (α=1), Elastic Net (α grid), hand-rolled Boruta (ranger + shadow), XGBoost.
- Outer AUROC distribution: LASSO ~0.50–0.77, XGBoost ~0.54–0.84 across folds.
- **Must not be written as**: unbiased generalization, fully nested estimate, external validation performance, prospective predictive accuracy.
- Safe phrasing: "predictive performance conditional on the frozen 85-protein discovery panel, assessed by repeated outer cross-validation within the Discovery cohort."

## 10. Strict nested ML sensitivity

- Same 15 outer folds/seeds; per-outer-train fold-local DEP screen (70% detection in both High and Low; Welch t-test BH-FDR<0.05) → LASSO + Elastic Net → untouched outer test.
- Fold-local DEP counts across the 15 splits: observed range **8 to 618** (verified in `strict_nested_outer_metrics.csv`; n_dep min=8, max=618).
- This range reflects **feature-selection instability under resampling**, not biological heterogeneity by itself.
- Forbidden inputs: the D03 85 list, D08 replication, M12 pathway, fixed-85 importance.
- Compare the two branches side-by-side; do not crown a winner.

## 11. Boruta wording

- The implementation is a **hand-rolled Boruta-style** procedure using `ranger` with shadow variables and a pooled binomial confirmation test; it is **not** the CRAN `Boruta` package with its full Confirmed/Tentative/Rejected iteration loop.
- Recommended manuscript phrase: "Boruta-style random-forest feature-importance analysis (ranger; shadow features; pooled binomial confirmation)".
- Do not write plain "Boruta feature selection" without the qualifier.

## 12. XGBoost interpretation

- XGBoost importance is a **post-selection descriptive importance** on the fixed 85 panel; not causal, not a biomarker effect, not independent mechanism.
- Use "model-internal importance" / "relative gain".

## 13. Pathway inference (primary vs complementary)

| Method | Role | FDR-sig count (frozen) |
|---|---|---|
| cameraPR (PATH-R pooled BH) | Primary competitive | **195 total** = 25 GO BP + 170 Reactome |
| ORA (PATH-O pooled BH) | Complementary | **23 total** = 3 GO BP + 20 Reactome |
| fgsea (pooled padj) | Ranked sensitivity | **39 total** = 3 GO BP + 8 GO MF + 11 GO CC + 17 Reactome |
| KEGG | NOT_RUN | — |

Do **not** sum 195 + 23 + 39. These are three separate families on overlapping gene lists. Report each method's count and family.

## 14. Mapping universe

- Tested protein groups: **1,434**.
- Unambiguous one-gene mappings retained for pathway: **1,414**.
- Multi-gene ambiguous: 15; unmapped: 5; duplicate groups: 0.
- The ORA background is the **1,414 mapped gene set**, not 1,434. cameraPR/fgsea use the ranked 1,430-level statistic with the 1,414 mapping contract. Do not conflate 1,434 and 1,414 as the same pathway universe.

## 15. KEGG

KEGG is **NOT_RUN**. Manuscript must not imply GO + Reactome + KEGG were all run. If pathway databases are listed, name only GO BP / GO MF / GO CC / Reactome.

## 16. M12B biological-context limitations

- M12B is a **biological context / interpretation layer**, not mechanistic validation.
- Allowed: "pathway enrichment", "coordinated shift", "core contributing genes", "biological context".
- Prohibited as standalone claims: "causal mechanism", "mechanistic proof", "validated mechanism", "pathway activation", "WGCNA co-expression network", "regulatory network".
- The correlation table is pairwise Spearman, not a co-expression / regulatory network.
- Environment-stratified concordance is descriptive; no interaction claim is inferred.

## 17. Figure-by-figure statistical audit

| Figure | Panel | Source | N | Method / metric | Multiplicity family | Status |
|---|---|---|---|---|---|---|
| Fig 1 | a flow | frozen gates | 519→515→386/129 | design diagram | n/a | PASS |
| Fig 1 | b group | M11_site | 515 | bar counts | n/a | PASS |
| Fig 1 | c site | M11_site | 515 | stacked bar | n/a | PASS |
| Fig 1 | d universe | frozen gates | 3817/3054/1430/1445/85 | bar | n/a | PASS |
| Fig 2 | a overall | M05 | 1,430 | scatter log2FC vs mean abundance | A-E BH | PASS |
| Fig 2 | b pairwise | M07 L-C/H-C/H-L | 3×1,430 | density of effects | A-LC/A-HC/A-HL BH | PASS |
| Fig 2 | c detection | M08 | 3,054 | volcano | A-Det-Firth BH | PASS |
| Fig 2 | d architecture | M06_arch | 1,430 | descriptive counts | none (descriptive) | PASS |
| Fig 3 | a effect landscape | ml85 | 85 | lollipop Discovery log2FC | D03 locked | PASS |
| Fig 3 | b profiles | M06_means | 85×3 | row-z heatmap | descriptive | PASS |
| Fig 3 | c missingness | M09 | 85 | scatter E_primary vs E_knn | sensitivity | PASS |
| Fig 3 | d candidate architecture | ml85 | 85 | counts | descriptive | PASS |
| Fig 4 | a environment | M10 | 1,430 | scatter stratified effects | descriptive (not interaction) | PASS |
| Fig 4 | b interaction | M10 | 1,430 | histogram of interaction BH bins | interaction BH | PASS |
| Fig 4 | c site | M11_site | 515 | stacked bar | n/a | PASS |
| Fig 4 | d LOO | M11_loo | 1,430 | histogram max shift | robustness | PASS |
| Fig 5 | a hierarchy | M14 | 85 | bar 85/85/83/29/1 | candidate-family BH | PASS |
| Fig 5 | b CV | outer_cv + strict_nested | 15 splits | boxplot AUROC by branch | n/a (CV) | PASS |
| Fig 5 | c convergence | ml85 | 85×4 | bubble stability | descriptive | PASS |
| Fig 5 | d support counts | ml85 | 85 | bar | descriptive | PASS |
| Fig 6 | a ranked cameraPR | M12 ranked | top 8 GO BP | signed -log10 FDR | PATH-R | PASS |
| Fig 6 | b sensitivity | M12 concordance | all | scatter cameraPR vs fgsea | PATH-R + fgsea padj | PASS |
| Fig 6 | c ORA | M12 ORA | top 10 (3 FDR-sig GO BP) | dotplot | PATH-O | PASS |
| Fig 6 | d network | M12 membership | top 4 pathways | bipartite edges | descriptive | PASS |

Figure 5 must keep the two ML branches visually labeled as "Fixed-85 conditional ML" and "Strict nested ML" (already done in the script). Figure 6 must not imply KEGG was run (it does not).

## 18. Required manuscript wording constraints

- Always say **"Discovery subset"** and **"reused hold-out subset"**.
- The 85 are **"85 discovery DEPs"** / **"85 locked discovery candidates"** — never "validated".
- 83 = **direction-concordant**; 29 = **nominal (P<0.05)**; 1 = **FDR-supported (candidate-family BH)**.
- Fixed-85 ML = **conditional on the frozen 85-protein panel**; not unbiased generalization.
- Strict nested = **leakage-controlled sensitivity**; 8–618 fold-local DEP range is instability, not biology.
- Boruta = **Boruta-style ranger importance**.
- Interaction: **"no interaction survived the prespecified BH-FDR threshold"** — never "no interaction".
- Pathway: cameraPR primary; ORA complementary; fgsea sensitivity; KEGG not run; do not sum counts.
- M12B: biological context / interpretation; not mechanism.

## 19. Remaining statistical limitations (must be carried into Discussion)

1. Fixed-85 performance is conditional on the same-cohort Discovery lock; strict-nested AUROC is only modestly lower, but this is a sensitivity statement, not external validation.
2. Single reused within-cohort hold-out (n=129), not an independent cohort.
3. Interaction test is underpowered (0/1,430 at BH-FDR<0.05); absence of significance is not evidence of no effect.
4. Environment-stratified estimates are descriptive and residual-confounded.
5. Pathway results depend on the 1,414 unambiguous mappings; 15 multi-gene and 5 unmapped proteins are excluded from pathway denominators.
6. Hand-rolled Boruta is a ranger approximation, not the canonical package.
7. M12B correlations are pairwise Spearman, not a regulatory network.
8. No independent/external cohort; no prospective validation.

## 20. Final status

**PASS_WITH_LIMITATIONS**. No wrong model, no wrong data subset, no incorrect FDR family, no leakage, no broken implementation was found. All required fixes are wording / claim-downgrade / methods-clarification tasks, not reopen-analysis tasks.
