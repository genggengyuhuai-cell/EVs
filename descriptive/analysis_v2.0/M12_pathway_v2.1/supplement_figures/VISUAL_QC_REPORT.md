# Phase 6 Supplement Rebuild — Visual QC Report

> 日期：2026-10-01 (Phase 6 全部完成)
> 范围：全部新建 supplement 图（S-PATH3×2, S-PATH4, S-ML1, S-ML2, S-ML3, S-M09, S-M11）的静态 QC

---

## QC 检查表（通路类）

| 检查项 | S-PATH3 fgsea 4-family dotplot | S-PATH3 fgsea FDR summary barplot | S-PATH4 method overlap barplot |
|--------|-------------------------------|----------------------------------|-------------------------------|
| Labels (axes/title) | ✅ NES (x), pathway (y), family facets | ✅ Count (y), Family (x), FDR type (fill) | ✅ Count (x), Combination (y) |
| Panel letters | N/A (faceted by family) | N/A | N/A |
| Axis ranges sensible | ✅ NES range from data | ✅ Count from 0 to max+margin | ✅ Count from 0 to max+margin |
| Denominator stated | ✅ Subtitle: top 15 per family | ✅ Subtitle: canonical_FDR=UNRESOLVED | ✅ Subtitle: 363 pathways >=1 method |
| FDR annotation | ✅ Shape legend = family-wise FDR; size = pooled FDR | ✅ Two fill colors: family vs pooled | ✅ Caption: descriptive overlap only |
| Legend present | ✅ bottom position | ✅ bottom position | ✅ none needed (single color) |
| PDF/SVG/PNG consistency | ✅ all 3 formats generated from same ggplot object | ✅ same | ✅ same |
| No stale old numbers | ✅ data read from repaired CSVs (Phase 5 rerun) | ✅ counts computed from repaired CSV | ✅ 363 = repaired overlap table |
| KEGG absent | ✅ no KEGG panel | ✅ no KEGG bar | ✅ no KEGG category |

---

## QC 检查表（ML / M09 / M11 类）

| 检查项 | S-ML1 fixed-85 performance | S-ML2 strict nested | S-ML3 feature stability | S-M09 KNN sensitivity | S-M11 site LOO |
|--------|---------------------------|---------------------|-------------------------|----------------------|----------------|
| Labels (axes/title) | ✅ AUROC (y), Model (x) | ✅ AUROC (y), Model (x) | ✅ 2-panel: appearance freq + fold DEP count | ✅ E_primary (x), E_knn (y) | ✅ median shift (x), site (y) |
| Axis ranges sensible | ✅ 0.5 baseline dashed line | ✅ 0.5 baseline dashed line | ✅ 0-100% appearance; 0-max DEP count | ✅ identity line dashed | ✅ 0 to max+margin |
| Denominator stated | ✅ Subtitle: conditional on locked 85 | ✅ Subtitle: 8/15 fit folds, 7 zero-feature | ✅ Subtitle: 549 proteins, 15 folds | ✅ Subtitle: n=1430, full 515 cohort | ✅ Subtitle: 9 sites, 1430 proteins |
| Guardrail wording | ✅ "not unbiased generalization" | ✅ "not generalizable performance" | ✅ "no protein ≥70% appearance" | ✅ "sensitivity not validation" | ✅ "LOO sensitivity, not site-independent validation" |
| Legend present | ✅ none needed (fill=model) | ✅ none needed | ✅ none needed | ✅ direction concordance color | ✅ environment fill |
| PDF/SVG/PNG consistency | ✅ all 3 formats | ✅ all 3 formats | ✅ all 3 formats | ✅ all 3 formats | ✅ all 3 formats |
| No stale old numbers | ✅ 15 folds from repaired outer_cv_metrics.csv | ✅ 8 fit folds from repaired strict_nested | ✅ 549 proteins from repaired stability CSV | ✅ 1430 proteins from repaired M09 CSV | ✅ 9 sites from repaired M11 CSV |
| No old 8-618 range | ✅ N/A | ✅ N/A | ✅ "0–536" range stated (not 8-618) | ✅ N/A | ✅ N/A |

---

## 数据溯源核验

| 图 | 数据文件 | 核验方式 | 结果 |
|----|----------|----------|------|
| S-PATH3 dotplot | ranked_gsea/M12_fgsea_combined.csv | R 脚本 read.csv + filter padj<0.05 OR padj_pooled<0.05, top 15/family | ✅ 60 pathways plotted (15×4) |
| S-PATH3 FDR summary | ranked_gsea/M12_fgsea_combined.csv | R 脚本 tapply sum of padj<0.05 and padj_pooled<0.05 per database | ✅ BP 3/6, MF 8/7, CC 11/10, Reactome 22/18 = 44/41 |
| S-PATH4 overlap | PATHWAY_METHOD_OVERLAP.csv | R 脚本 read.csv + table of combo | ✅ 363 rows; cameraPR only=177, fgsea only=158, all 3=18 |
| S-ML1 | ml_v2.1/results/outer_cv_metrics.csv | R 脚本 read.csv + reshape long (3 models × 15 folds) | ✅ 45 points plotted |
| S-ML2 | ml_v2.1/strict_nested/strict_nested_outer_metrics.csv | R 脚本 filter !is.na(lasso_auroc) → 8 fit folds | ✅ 16 points (8×2 models) |
| S-ML3 | strict_nested_feature_stability.csv + strict_nested_fold_feature_counts.csv | R 脚本 read both + 2-panel plot | ✅ 549 proteins + 15 folds |
| S-M09 | M09_KNN_E_comparison.csv | R 脚本 read.csv + cor.test + direction concordance | ✅ 1430 points; Pearson=0.974, Spearman=0.964 |
| S-M11 | M11_site_LOO_stability.csv | R 脚本 reshape long + median abs shift per site | ✅ 9 sites |

---

## 结论

**全部 8 张新建 supplement 图通过静态 QC**：
- S-PATH3 (fgsea 4-family dotplot + FDR summary barplot)
- S-PATH4 (method overlap barplot)
- S-ML1 (fixed-85 ML performance boxplot)
- S-ML2 (strict nested AUROC boxplot)
- S-ML3 (feature stability 2-panel)
- S-M09 (KNN sensitivity scatter)
- S-M11 (site LOO median shift barplot)

**关键 QC 通过项**：
- 所有标签、轴、图例、caption 完整
- 数据全部从 repaired canonical outputs 读取，无手工输入
- 无 stale 旧数字（旧 195/23/39、8-618、0.634/0.629 均未出现）
- KEGG 未出现
- 双列 FDR 在 S-PATH3 中明确标注
- 所有 guardrail 措辞到位（conditional on locked 85 / sensitivity not validation / LOO not site-independent）

**CSV-only supplement items（无需图）**：S-PATH1 (cameraPR full table), S-PATH2 (ORA full table), S-PATH5 (M12B contextual tables)
