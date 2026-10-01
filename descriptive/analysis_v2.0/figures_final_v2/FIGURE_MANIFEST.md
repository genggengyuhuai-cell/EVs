# M17 manuscript figures — v2（Phase 6 rebuilt, 2026-10-01）

## Export contract
- Backend: R only（ggplot2/patchwork/svglite/cairo_pdf/ragg）。
- 宽度 183 mm；每图 editable PDF + editable SVG + source_data CSV + 300 dpi PNG（仅视觉 QA）。
- 重建脚本：`descriptive/analysis_v2.0/code/V2_M17_phase6_rebuild.R`（只读 repaired canonical 输出；不重拟合模型、不改阈值、不重定义候选）。
- 旧版快照：`figures_final_v2/phase6_pre_rebuild_snapshot/`。

## Figure 状态
| Figure | 状态 | 重建来源 |
|---|---|---|
| Fig1 cohort design | UNCHANGED | D01/D03 frozen |
| Fig2 proteome associations | UNCHANGED | M05/M06/M07/M08 frozen |
| Fig3 candidate biology | PARTIALLY_REBUILT（panel c） | M09 repaired `M09_KNN_E_comparison.csv`（impute.knn） |
| Fig4 environment/site | PARTIALLY_REBUILT（panel d） | M11 repaired `M11_site_LOO_stability.csv`（primary-contract adjusted LOO） |
| Fig5 replication/ML | REBUILT（panel b） | ml_v2.1 repaired outer_cv + strict_nested outer_metrics |
| Fig6 pathway integration | REBUILT（结构重做，a/b/c/d） | M12/M12B repaired ranked/ora/redundancy/membership |

## Panel contracts
- **Fig3c**：overall-exposure imputation sensitivity（prespecified `impute::impute.knn`, k=10, full 515 cohort, Q515 universe, effect E）；sensitivity not validation。其余 panel 未变。
- **Fig4d**：leave-one-site-out influence（primary-contract adjusted LOO，保留 same M05 estimator + Environment adjustment + fixed primary contract）；robustness，非 proof of no site heterogeneity。禁止 site-independent / batch-independent / validated across sites / replicated across sites。
- **Fig5b**：fixed-85 conditional ML（locked 85 universe）与 strict nested ML（discovery redone inside folds）视觉与文字分开；strict nested 仅在 8/15 fit 折上画 AUROC，并标注 7/15 outer folds 无特征；不合并成单一“模型性能”。禁止 validated classifier / clinical model / diagnostic panel。
- **Fig6**：
  - a = representative GO-BP cameraPR（FDR_pooled<0.05，29 条按 FDR 取 top 8）。
  - b = representative Reactome cameraPR（176 条显著中仅 redundancy-cluster REPRESENTATIVE，按 FDR 取 top 8）——Reactome 已进 main。
  - c = candidate-family ORA（GO-BP 3 条全部 + Reactome 非冗余代表 top 5）。
  - d = M12B contextual pathway-candidate network（top 4 通路 × 9 候选）。
  - fgsea = sensitivity，不进 Fig6 main（Canonical_FDR 仍 UNRESOLVED，入 supplement）。
  - selection rule：FDR_pooled<0.05 → Reactome 保留冗余簇代表 → arrange(FDR_pooled) → top N；非 cherry-pick。KEGG 不出现。

## Phase 7（2026-10-01）Fig6b LABEL_ONLY_UPDATE
- **FIG6B_LABEL_ONLY_UPDATE=YES**：仅 Fig6b y 轴刻度标签由 R-HSA ID 改为人类可读 pathway name；selected pathways / ranking / FDR / effect / panel 结构 / 选择规则均未变。
- 注释源：reactome.db **1.86.2**（PATHID→PATHNAME，AnnotationDbi::select）；8 个 ID 全部解析，无 UNRESOLVED。
- 脚本备份：`code/V2_M17_phase6_rebuild.R.phase7.bak`。
- Fig6 状态：REBUILT + LABEL_ONLY_UPDATE；repaired version = Phase5 repaired M12/M12B（cameraPR 205/ORA 23/fgsea 44&41）。
- 导出格式：PDF/SVG/PNG（main figure 矢量，无 TIFF——bundle 无 TIFF 要求）。
