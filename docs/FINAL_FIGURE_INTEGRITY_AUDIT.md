# Final Figure Integrity Audit

> 日期：2026-10-01。Phase 7 P18。
> 方法：静态核对 figures_final_v2/ 文件时间戳、source_data CSV 结构、SVG 文本层 grep、FIGURE_MANIFEST.md / VISUAL_QC.md 交叉核验。
> 边界：仅只读审计，不重画、不修改任何 figure 文件。

---

## 逐 Figure 结论

| Figure | 状态 | Source data provenance | 无旧值 | 无 stale captions | 分母正确 | KEGG absent | fgsea 不作 primary | 结论 |
|---|---|---|---|---|---|---|---|---|
| **Fig1 cohort design** | UNCHANGED | ✅ D01/D03 frozen | ✅ n=519/515/386/129 | ✅ "reused within-cohort hold-out" | ✅ | n/a | n/a | **YES** |
| **Fig2 proteome associations** | UNCHANGED | ✅ M05/M06/M07/M08 frozen | ✅ 0/1430 overall exposure | ✅ | ✅ 1430 = Q515 abundance universe | n/a | n/a | **YES** |
| **Fig3 candidate biology** | PARTIALLY_REBUILT (panel c) | ✅ panel c = c_missingness 来自 repaired M09 KNN_E_comparison.csv | ✅ 无 0.931147（旧 Pearson） | ✅ "sensitivity not validation" | ✅ 1430 Q515 universe | n/a | n/a | **YES** |
| **Fig4 environment/site** | PARTIALLY_REBUILT (panel d) | ✅ panel d = d_loo 来自 repaired M11 site_LOO_stability.csv | ✅ 无旧 LOO 范围 | ✅ "robustness, not proof of no site heterogeneity" | ✅ 1430 / 9 sites | n/a | n/a | **YES** |
| **Fig5 replication/ML** | REBUILT (panel b) | ✅ panel b = b_cv + b_strict_nested_meta 来自 repaired outer_cv + strict_nested | ✅ 无 0.634 / 0.629 / 8–618 | ✅ "7/15 outer folds: no features"；不选赢家 | ✅ 85 fixed-85 denominator；8/15 fit folds | n/a | n/a | **YES** |
| **Fig6 pathway integration** | REBUILT + LABEL_ONLY_UPDATE | ✅ a/c/d 来自 repaired M12/M12B | ✅ 无 195 / 39 pathways | ✅ FDR_pooled 标注；selection_rule 列存在 | ✅ 205 = 29 BP + 176 Reactome | ✅ 不出现 | ✅ fgsea 不在主图（仅 supplement） | **YES** |

---

## Fig6b Reactome Readable Names 专项

- **FIG6B_LABEL_ONLY_UPDATE=YES**（FIGURE_MANIFEST.md §Phase 7）
- 8/8 Reactome 代表通路全部解析人类可读名：
  1. R-HSA-3560782 → Diseases associated with glycosaminoglycan metabolism
  2. R-HSA-3000178 → ECM proteoglycans
  3. R-HSA-1474244 → Extracellular matrix organization
  4. R-HSA-1638091 → Heparan sulfate/heparin (HS-GAG) metabolism
  5. R-HSA-2022870 → Chondroitin sulfate biosynthesis
  6. R-HSA-9711123 → Cellular response to chemical stress
  7. R-HSA-1474228 → Degradation of the extracellular matrix
  8. R-HSA-1638074 → Keratan sulfate/keratin metabolism
- 注释源：reactome.db **1.86.2**（AnnotationDbi::select PATHID→PATHNAME）
- source_data.csv `readable_name` 列：存在且 8/8 非空；`annotation_source` 列 = "reactome.db 1.86.2 PATHID->PATHNAME"
- selection_rule 列已标注 "Phase7 label-only update"（数值/排名/选择规则未变）
- **无 UNRESOLVED ID**

---

## 全图 Stale Value Grep 结果

- SVG 文本层 grep（>.*0.931.*<|>.*0.634.*<|>.*0.629.*<|>.*195 pathway|>.*39 pathway|>.*KEGG.*<）：**0 命中**
- 旧 195 / 23 / 39 pathway 总数：未出现在任何主图标签/标题中
- fgsea "primary" 措辞：未出现在主图中（fgsea 仅在 Supplement S-PATH3）
- KEGG：未出现在任何主图面板或标签中

---

## 汇总

- **6/6 figures PASS**（YES）
- Fig6b Reactome readable names 8/8 解析成功（reactome.db 1.86.2）
- 无 stale statistical values、无 broken provenance、KEGG absent、fgsea 不误作 primary
- 全部 source_data CSV 存在且指向 repaired canonical outputs

---

## 遗留

- 无。Figure 终审通过。
- 剩余全局阻断均为 reporting/provenance/git 层（非 figure 层）。
