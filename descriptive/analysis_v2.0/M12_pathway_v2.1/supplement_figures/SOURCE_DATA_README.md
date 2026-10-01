# Supplement Figures — Source Data README

> 日期：2026-10-01 (Phase 6)
> 原则：所有图从 canonical repaired outputs 读取，禁止手工输入 result values

---

## S-PATH3: fgsea 四族补充图

**图文件**: `supplement_figures/SuppFig_S-PATH3_fgsea_4families.{pdf,svg,png}`
**配套摘要图**: `supplement_figures/SuppFig_S-PATH3_fgsea_FDR_summary.{pdf,svg,png}`

| Panel | Source_file | Filter | Sort_order | Displayed_rows | Statistical_family | Notes |
|-------|-------------|--------|------------|----------------|-------------------|-------|
| 4-family dotplot | ranked_gsea/M12_fgsea_combined.csv | padj<0.05 OR padj_pooled<0.05 | By family, then padj_pooled ascending, top 15 per family | 60 (15×4) | Dual: padj_family (within-family BH) + padj_pooled (cross-family BH) | Shape: filled circle = padj_family<0.05; open circle = n.s. family-wise. Dot size = -log10(padj_pooled). Canonical_FDR = UNRESOLVED per contract §12. |
| FDR summary barplot | ranked_gsea/M12_fgsea_combined.csv | Count of padj<0.05 and padj_pooled<0.05 per family | Family order: BP → MF → CC → Reactome | 8 bars (4 families × 2 FDR types) | Both families shown side-by-side | BP: 3 family / 6 pooled; MF: 8 / 7; CC: 11 / 10; Reactome: 22 / 18. Total: 44 family / 41 pooled. |

**Annotation 说明**:
- `padj` (family-wise): fgseaMultilevel internal BH correction within each ontology family separately
- `padj_pooled`: BH correction across all 1016 tested pathways (all 4 families combined)
- 阈值：两列均为 FDR < 0.05
- KEGG = NOT_RUN（不在图中）

---

## S-PATH4: Pathway Method Overlap 图

**图文件**: `supplement_figures/SuppFig_S-PATH4_method_overlap.{pdf,svg,png}`

| Panel | Source_file | Filter | Sort_order | Displayed_rows | Statistical_family | Notes |
|-------|-------------|--------|------------|----------------|-------------------|-------|
| Method combination barplot | PATHWAY_METHOD_OVERLAP.csv | All 363 pathways significant in >=1 method | Count descending | 7 combinations | Descriptive overlap only (no new significance rule) | cameraPR only: 177; fgsea only: 158; All 3 methods: 18; cameraPR+ORA: 5; cameraPR+fgsea: 5; ORA only: 0; ORA+fgsea: 0. |

**Annotation 说明**:
- cameraPR significance = FDR_pooled < 0.05 (GO-BP + Reactome combined BH)
- ORA significance = FDR_pooled < 0.05 (GO-BP + Reactome combined BH)
- fgsea significance = padj_pooled < 0.05 (cross-family BH)
- 此图仅描述三方法重叠，不建立新的显著性规则

---

## S-PATH1: Full cameraPR 表（CSV only, no figure needed）

**Source file**: `ranked/M12_ranked_combined_FDR.csv` (GO-BP + Reactome primary)
**Secondary**: `ranked/M12_ranked_GO_MF.csv`, `ranked/M12_ranked_GO_CC.csv`

| Column | Description |
|--------|-------------|
| pathway_id | GO:xxxxxx or Reactome R-HSA-xxxxx |
| pathway_name | Term name |
| database | GO_BP / GO_MF / GO_CC / Reactome |
| N | Gene set size after 10-500 filter |
| Stat | cameraPR test statistic |
| PValue | Raw p-value |
| FDR | Within-family BH (MF/CC only; primary uses pooled) |
| FDR_pooled | Cross-family BH (GO-BP + Reactome only; primary canonical) |

**Count**: 758 tested (272 BP + 486 Reactome), 205 sig pooled (29 BP + 176 Reactome)

---

## S-PATH2: Full ORA 表（CSV only, no figure needed）

**Source file**: `ora/M12_ORA_combined_FDR.csv` (GO-BP + Reactome primary)

| Column | Description |
|--------|-------------|
| pathway_id | GO:xxxxxx or Reactome R-HSA-xxxxx |
| pathway_name | Term name |
| database | GO_BP / Reactome |
| size | Background size |
| overlap | Overlap with 85 DEPs |
| expected | Expected overlap |
| fold_enrichment | overlap / expected |
| PValue | Fisher exact (one-sided, greater) |
| FDR_pooled | Cross-family BH (GO-BP + Reactome) |

**Count**: 23 sig pooled (3 BP + 20 Reactome)

---

## S-ML1 / S-ML2 / S-ML3: ML 修复结果图

| ID | Source_file | Figure file | Status | Notes |
|----|-------------|-------------|--------|-------|
| S-ML1 | ml_v2.1/results/outer_cv_metrics.csv | `descriptive/analysis_v2.0/supplement_figures/SuppFig_S-ML1_fixed85_performance.{pdf,svg,png}` | REPAIRED_AND_VERIFIED | Fixed-85 outer-fold AUROC boxplot (15 folds, LASSO/EN/XGBoost). Conditional on locked 85. |
| S-ML2 | ml_v2.1/strict_nested/strict_nested_outer_metrics.csv | `descriptive/analysis_v2.0/supplement_figures/SuppFig_S-ML2_strict_nested_metrics.{pdf,svg,png}` | REPAIRED_AND_VERIFIED | Strict-nested AUROC (8/15 fit folds only). 7/15 zero-feature folds excluded. |
| S-ML3 | ml_v2.1/strict_nested/strict_nested_feature_stability.csv + strict_nested_fold_feature_counts.csv | `descriptive/analysis_v2.0/supplement_figures/SuppFig_S-ML3_feature_stability.{pdf,svg,png}` | REPAIRED_AND_VERIFIED | 2-panel: (A) appearance frequency histogram (549 proteins); (B) per-fold DEP count barplot (15 folds). |

---

## S-M09: KNN sensitivity

**Source**: `M09_missingness_sensitivity/KNN_sensitivity/M09_KNN_E_comparison.csv`
**Figure file**: `descriptive/analysis_v2.0/supplement_figures/SuppFig_S-M09_KNN_sensitivity.{pdf,svg,png}`
**Status**: REPAIRED_AND_VERIFIED (Phase 3)
**Caption key wording**: "Sensitivity analysis only — not validation. Full 515-cohort, Q515 universe. Pearson r=0.974, Spearman r=0.964, direction concordance=1343/1430. Primary FDR<0.05=0, KNN FDR<0.05=0."

---

## S-M11: Site LOO robustness

**Source**: `M11_site_robustness/M11_site_LOO_stability.csv`
**Figure file**: `descriptive/analysis_v2.0/supplement_figures/SuppFig_S-M11_site_LOO.{pdf,svg,png}`
**Status**: REPAIRED_AND_VERIFIED (Phase 4)
**Caption key wording**: "Leave-one-site-out sensitivity — not site-independent validation. 9 sites, 1430 proteins. Median absolute effect shift per site left out."

---

## S-PATH5: M12B contextual outputs

| Sub-item | Source_file | Type |
|----------|-------------|------|
| Pathway-protein edges | M12B.../network/M12B_pathway_protein_edges.csv | Table (8134 edges) |
| Pathway-protein nodes | M12B.../network/M12B_pathway_protein_nodes.csv | Table (1211 nodes) |
| Spearman correlation pairs | M12B.../correlation/M12B_DEP85_spearman_correlation.csv | Table |
| Environment concordance | M12B.../environment/M12B_environment_pathway_concordance.csv | Table |
| Integrated candidate context | M12B.../integration/M12B_integrated_candidate_context.csv | Table (85 rows) |

**Note**: M12B is secondary biological context / association only — not causal / regulatory / co-expression network.
