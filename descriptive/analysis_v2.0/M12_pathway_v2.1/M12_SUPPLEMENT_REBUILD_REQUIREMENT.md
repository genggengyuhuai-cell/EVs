# M12 Supplement 通路重建需求（M12_SUPPLEMENT_REBUILD_REQUIREMENT）

> 性质：**规划文档**。未运行脚本、未重画、未修改任何产物。
> 权威总状态同 `M12_FIG6_REBUILD_REQUIREMENT.md`：M12=BLOCKED_PENDING_RERUN；M12B=BLOCKED_BY_M12；Fig6=NOT_FINAL；195/23/39=PRE_REPAIR_EXISTING_OUTPUT；FGSEA_FROZEN_FAMILY=HOLD；KEGG=NOT_RUN。
> 原则：**不要只留 CSV 而无可视化建议**——每类内容给出建议形式（表/图/补充数据）。

---

## 1. 现状（PRE_REPAIR，引自 PATHWAY_PRESENTATION_INVENTORY.md）

- main：仅 Fig6，且 a/c/d 全锁 GO-BP；Reactome/MF/CC/fgsea 无 curated 面板。
- supplement：**零通路图**（figures_nature_v2.2、prospective_v2.7 0 命中；M12/M12B 目录 0 图形文件）。
- 大量 family×method 仅 RESULT_TABLE_ONLY。

---

## 2. 重建内容清单（逐项：内容 / 建议形式 / 数据源 / 说明）

| # | 内容 | 建议形式 | 数据源（repaired 后） | 层级 |
|---|---|---|---|---|
| S1 | **full cameraPR 表**（GO-BP/MF/CC/Reactome 全 tested+显著） | 补充数据表（CSV 即可）+ 每家族一个小型条形/点图 | `ranked/M12_ranked_*.csv`、`M12_ranked_combined_FDR.csv` | Supplement |
| S2 | **full ORA 表**（GO-BP/MF/CC/Reactome） | 补充数据表 + GO-BP/Reactome 富集比小图 | `ora/M12_ORA_*.csv`、`M12_ORA_combined_FDR.csv` | Supplement |
| S3 | **full fgsea 表**（四家族 + leading-edge） | 补充数据表（combined + per-family + leading_edge 已存在）+ 一个按家族分面的 NES/leading-edge 图 | `ranked_gsea/M12_fgsea_*.csv`、`M12_fgsea_leading_edge.csv` | Supplement |
| S4 | **Reactome 主臂** | **repaired 后建议升 main**（见 Fig6 需求 §3.1）；supplement 保留 redundancy cluster 全簇图/表 | `ranked/M12_ranked_Reactome.csv`、`integration/M12_pathway_redundancy_clusters.csv` | main(代表) + supp(全簇) |
| S5 | **method overlap（PATHWAY_METHOD_OVERLAP）** | 一个通路×方法的一致性图（Venn/upSet 或条形：cameraPR-only/ORA-only/fgsea-only/overlap） | `M12_cameraPR_fgsea_concordance.csv` + ORA/cameraPR 通路 ID 交集 | Supplement |
| S6 | **M12B candidate-network** | 网络图/边表（edges/nodes 已存在 CSV），按 GO-BP + Reactome 候选-通路边 | `M12B.../network/M12B_pathway_protein_edges|nodes.csv` | Supplement（main 仅 top-4 紧凑图） |
| S7 | **M12B Spearman 相关**（DEP85 collinearity） | 相关热图（现仅 3 CSV，零图） | `M12B.../correlation/*.csv` | Supplement |
| S8 | **M12B 环境一致性**（High land vs Hot-humid 分层） | 一致性条形/散点（现仅 2 CSV） | `M12B.../environment/*.csv`、`M12.../environment/*.csv` | Supplement |
| S9 | **mapping universe 契约** | 方法/补充表（1434→1414/15/5） | `mapping/M12_gene_mapping_contract.csv` | Methods + Supp table |

---

## 3. 关键口径要求（rerun 后落图前必须冻结）

- **fgsea FDR 列**：当前 Fig6b 用 `padj`（BP3/MF8/CC11/Reactome17），`M12_FINALIZATION_REPORT §6` 写 `padj_pooled`（BP5/MF6/CC11/Reactome17）。重建前必须二选一并在所有 supplement 图与表统一；图注标注列名。在 HOLD 解除前不得据此定稿。
- **cameraPR 家族归属**：主分支 FDR_pooled 仅 GO-BP+Reactome（=195）；MF/CC 为 M12B 次分支家族内 FDR（不计入 195）。S1 全表须分列"primary FDR_pooled"与"secondary within-family FDR"。
- **Reactome 冗余**：170 条 raw hit 不可直陈；main 与 supplement 均以 redundancy cluster 代表主题呈现，cluster 表作为补充数据。
- **三法不相加**：cameraPR/ORA/fgsea 各自计数独立陈述；S5 overlap 图是"交集"不是"总和"。
- KEGG：NOT_RUN，不建表不画图。

---

## 4. P27 判定：FIG6_PRESENTATION_GAP

> 判定对象：当前 Fig6 是否代表完整通路输出（即 curated 面板覆盖主分析的足够比例）。

- **pre-repair 基线判定：YES（存在展示缺口）**。
  - 依据：cameraPR 主分析 195 条中 Reactome 170 条（≈87%）在 Fig6 无任何 curated 面板；GO-BP 仅展示 8/25；ORA Reactome 20 条零展示；fgsea 39 条仅作散点 y 轴，无 leading-edge。
  - 结论：**FIG6_PRESENTATION_IS_NOT_REPRESENTATIVE_OF_FULL_PATHWAY_OUTPUT**（与上一轮审计一致）。
- **标注**：此为 **pre-repair 基线判定**；最终 gap 比例与结论须在 M12/M12B rerun、family 计数与 FDR 口径复核后重算（repaired 后 Reactome 占比可能变化）。
- **本轮不画图**；缺口闭合 = main 补 representative Reactome + supplement 全家族可视化（S1–S8）后再复评。

---

## 5. 边界

- 本规划不触发任何 rerun/绘图；S1–S8 的数字均为 PRE_REPAIR 基线，重建时以 repaired 表覆盖。
- 未决定 fgsea frozen 列（HOLD）、未补 KEGG、未把 MF/CC 提升为主。
