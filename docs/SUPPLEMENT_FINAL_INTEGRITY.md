# Supplement Final Integrity Check

> 日期：2026-10-01。Phase 7 P19。
> 方法：静态核对 SUPPLEMENT_REBUILD_MANIFEST.csv 逐项；文件存在性 Test-Path；源文件路径 Test-Path；SVG 文本层 grep stale values。

---

## 逐项结果

| Supplement ID | Figure/Table | Exists | Source file exists | Caption label consistent | No stale values | No broken source ref | Verdict |
|---|---|---|---|---|---|---|---|
| **S-ML1** | fixed-85 outer-fold AUROC boxplot | ✅ PDF/PNG/SVG | ✅ outer_cv_metrics.csv | ✅ "conditional on locked 85" | ✅ 无 0.634/0.629 | ✅ | **PASS** |
| **S-ML2** | strict nested outer-fold AUROC (8 fit folds) | ✅ PDF/PNG/SVG | ✅ strict_nested_outer_metrics.csv | ✅ "8 fit folds; 7/15 zero-feature" | ✅ 无 8–618 标签 | ✅ | **PASS** |
| **S-ML3** | feature stability histogram + fold DEP barplot | ✅ PDF/PNG/SVG | ✅ feature_stability.csv + fold_feature_counts.csv | ✅ "549 proteins, max appearance <70%" | ✅ 无旧值 | ✅ | **PASS** |
| **S-M09** | KNN imputation sensitivity scatter | ✅ PDF/PNG/SVG | ✅ M09_KNN_E_comparison.csv | ✅ "Pearson=0.974, sensitivity not validation" | ✅ 无 0.931147 | ✅ | **PASS** |
| **S-M11** | leave-one-site-out median shift | ✅ PDF/PNG/SVG | ✅ M11_site_LOO_stability.csv | ✅ "9 sites, sensitivity not validation" | ✅ 无旧值 | ✅ | **PASS** |
| **S-PATH1** | full cameraPR table (GO-BP + Reactome pooled) | ✅ CSV | ✅ M12_ranked_combined_FDR.csv | ✅ 205 sig = 29 BP + 176 Reactome | ✅ 无 195 | ✅ | **PASS** |
| **S-PATH2** | full ORA table (GO-BP + Reactome pooled) | ✅ CSV | ✅ M12_ORA_combined_FDR.csv | ✅ 23 sig = 3 BP + 20 Reactome | ✅ 不变 | ✅ | **PASS** |
| **S-PATH3** | fgsea 4-family dotplot + FDR summary barplot | ✅ PDF/PNG/SVG ×2 | ✅ M12_fgsea_combined.csv | ✅ dual FDR columns labeled | ✅ 无旧 39 | ✅ | **PASS** |
| **S-PATH4** | method combination barplot | ✅ PDF/PNG/SVG | ✅ PATHWAY_METHOD_OVERLAP.csv | ✅ "363 pathways sig in ≥1 method" | ✅ 无旧值 | ✅ | **PASS** |
| **S-PATH5** | M12B contextual outputs | ✅ CSV tables | ✅ M12B network/correlation/environment dirs | ✅ descriptive context | ✅ 无旧值 | ✅ | **PASS** |

---

## 汇总

- **10/10 supplement items PASS**。
- 全部 figure 文件存在（PDF/PNG/SVG 三件套）；全部源 CSV 存在且指向 repaired canonical outputs。
- SVG 文本层 grep 无 stale statistical values（旧 195 / 0.931147 / 0.634 / 0.629 / 8–618 / 39 pathways 等均未出现在 supplement figure 标签/标题中；grep 命中的 "195" 均为 SVG 几何坐标 x/y 值，非统计数字）。
- 无 broken source_data 引用；无 pre-repair 数据进入 supplement。
- S-PATH3 fgsea 双列标注正确（family-wise padj + pooled padj_pooled）。

---

## 遗留

- 无。Supplement 完整性终审通过。
