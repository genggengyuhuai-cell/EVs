# M12 Fig6 重建需求（M12_FIG6_REBUILD_REQUIREMENT）

> 性质：**规划文档**。未重画 Fig6、未运行任何脚本、未修改任何图形/结果产物。
> 权威总状态：**FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED；ANALYSIS_REOPEN_REQUIRED=YES；SAFE_TO_TAG_ANALYSIS_V2_1=NO；M12=BLOCKED（BLOCKED_PENDING_RERUN）；M12B=BLOCKED_BY_M12；Fig6=NOT_FINAL；历史 195/23/39=PRE_REPAIR_EXISTING_OUTPUT；FGSEA_FROZEN_FAMILY=HOLD_UNTIL_M12_REPAIR_AND_RERUN；KEGG=NOT_RUN。**
> 根因（ROUND2 P0-3）：`M12_01_mapping.R` 原以 `nrows=0` 读 PRIMARY 矩阵，`tested_prots` 为空；已加 `stopifnot` 断言（预期 tested=1434/mapped=1414/multi=15/unmapped=5）但**未重跑**。故 M12/M12B 全部旧通路产物在 rerun 前不得标 FINAL_FROZEN。
> 数字逐字引自文件，不自行计算；凡 source 是 M12/M12B 旧产物的 panel，rerun 后必然 invalidated（ranking/estimand/FDR 任一变化都会改变显著列表）。

---

## 1. 当前 Fig6 逐 panel source（重建前现状，引自 V2_M17_figures_v2.R L252–291）

| Panel | 标题（脚本 L256/263/270/284） | 当前 source 文件（脚本行） | 当前内容 |
|---|---|---|---|
| **a**（a_ranked） | "Ranked cameraPR pathways" | `M12_pathway_v2.1/ranked/M12_ranked_combined_FDR.csv`（L33，L253 `filter(database=="GO_BP",FDR_pooled<0.05)%>%slice_head(n=8)`） | cameraPR GO-BP top 8（25 条显著中取 8，按 FDR_pooled） |
| **b**（b_sensitivity） | "Ranked-method sensitivity" | `M12_pathway_v2.1/ranked_gsea/M12_cameraPR_fgsea_concordance.csv`（L34，L258 `filter(is.finite(FDR),is.finite(padj))`） | cameraPR FDR(x) × fgsea padj(y) 一致性散点 887 点（1020 行剔非有限） |
| **c**（c_ora） | "Candidate-family ORA" | `M12_pathway_v2.1/ora/M12_ORA_combined_FDR.csv`（L35，L266 `filter(database=="GO_BP",FDR_pooled<0.05)%>%slice_head(n=10)`） | ORA GO-BP 3 条（显著全部；cap 10 仅 3 过阈） |
| **d**（d_network） | "Compact pathway-candidate map" | `M12_pathway_v2.1/integration/M12_ML_candidate_pathway_membership.csv`（L36，L271–273 `filter(pathway_database=="GO_BP")…slice_head(n=4)`） | M12B GO-BP top-4 通路 × 候选蛋白 = 11 边 |

面板组装 L286 `(p6a|p6b)/(p6c|p6d)`，L287 `save_figure(fig6,"Fig6_pathway_integration",height_mm=158)`。

---

## 2. repaired rerun 后逐 panel invalidated 判定

M12 canonical 链 = `M12_01_mapping.R → M12_02_ranked_ora.R → M12_03_integration.R`（kegg_fix 已移出 canonical），M12B 依赖 M12。映射 universe（1434/1414/15/5）、cameraPR/ORA/fgsea 的 ranking 与 FDR 全部将被重新估计。

| Panel | source 是否 M12/M12B 旧产物 | rerun 后 invalidated？ | invalidated 机理 | 必须更换为 |
|---|---|---|---|---|
| a_ranked | 是（cameraPR combined） | **YES** | mapping universe 变化 → 背景/基因集交集变化 → cameraPR t 统计与 FDR_pooled 重排 → GO-BP 显著列表与 top8 必然改变 | repaired `M12_ranked_combined_FDR.csv`（GO-BP 行） |
| b_sensitivity | 是（cameraPR + fgsea 双侧） | **YES** | x 轴 cameraPR FDR 与 y 轴 fgsea padj 都来自 M12；rerun 后 887 点坐标、significant_both/cameraPR-only/fgsea-only/neither 四分类全变；padj vs padj_pooled 口径未定 | repaired `M12_cameraPR_fgsea_concordance.csv`（并先冻结 FDR 列口径） |
| c_ora | 是（ORA combined） | **YES** | ORA foreground=85 不变，但 background=1414 随 mapping rerun 变化 → Fisher enrichment ratio/OR/FDR_pooled 重算 → GO-BP 显著列表改变 | repaired `M12_ORA_combined_FDR.csv`（GO-BP 行） |
| d_network | 是（M12B integration） | **YES** | M12B BLOCKED_BY_M12；pathway_database GO-BP 归属与 ranked_pathway_FDR 随 rerun 变 → top-4 通路与 11 边必然重选 | repaired `M12_ML_candidate_pathway_membership.csv` |

**结论：Fig6 四个 panel 的 source 在 M12/M12B rerun 后全部 invalidated，无任何 panel 可保留旧坐标。** 重建时必须先完成 rerun 并复核 195/23/39（或新计数）、universe、fgsea 口径，再从 repaired 输出重画；不得在旧 PRE_REPAIR 数字上做版式微调后当作 FINAL。

---

## 3. main / supplement 呈现建议（基于 pre-repair 占比，最终以 repaired 复核）

### 3.1 Reactome —— 必须进入 main

- **依据**：pre-repair cameraPR 主分析 195 条 = GO-BP 25 + Reactome 170；Reactome 占主分析 **170/195 ≈ 87%**，却在当前 Fig6 零 curated 面板（仅散点 364 点）。
- **推荐**：重建后 main 至少同时展示 **representative GO-BP + representative Reactome**。Reactome 冗余度高（`M12_FINALIZATION_REPORT` §10.2），应使用 `integration/M12_pathway_redundancy_clusters.csv`（greedy Jaccard>0.5）把 170 条聚成主题簇，main 展示每簇 1 条代表（而非 raw 170）。
- **形式**：可在 a_ranked 旁增设一个 curated Reactome 主题条形/点面板，或把 a 改为"GO-BP 主题 + Reactome 主题"双面板；图注写明"representative themes after redundancy clustering"。

### 3.2 GO-MF / GO-CC —— 建议 supplement

- **依据**：MF/CC cameraPR 与 ORA 均为 **M12B 次分支**产物（家族内 FDR，不进主分支 FDR_pooled 的 195/23）；pre-repair cameraPR MF 15/CC 19、ORA MF 7/CC 4，量级小且非主推断。
- **推荐**：main 不设 MF/CC curated 面板；作为 supplement 全家族结果（表 + 小图）呈现。若 repaired 后某家族跃升为主信号，再议是否提升。

### 3.3 fgsea —— 需要显式可视化，不能只在散点 y 轴带过

- **依据**：当前 b_sensitivity 用 fgsea padj 作 y 轴画一致性散点，39 条显著 fgsea 未逐条列出、无 leading-edge curated 面板；且 `M12_FINALIZATION_REPORT §6` 用 padj_pooled（BP5/MF6/CC11/Reactome17），Fig6b 用 padj（BP3/MF8/CC11/Reactome17），口径未冻结（FGSEA_FROZEN_FAMILY=HOLD）。
- **推荐**：
  1. rerun 后**先冻结 fgsea FDR 列口径**（padj 家族内 vs padj_pooled 跨族合并），再画图；图注必须写明所用列。
  2. 给 fgsea 一个**显式 curated 面板**（建议 supplement：按家族列 leading-edge top 项，或 cameraPR×fgsea 一致性主题条形），不要让 fgsea 只作为 b 散点的第二坐标轴。
  3. main 可保留一个紧凑的 cameraPR×fgsea 一致性总览，但需与 curated fgsea 面板配套。

---

## 4. 重建硬约束（写给未来出图脚本，不在本轮执行）

- 不得重算/重调通路阈值；只消费 repaired 输出表。
- 三法（cameraPR/ORA/fgsea）分别陈述，**不得相加为单一通路数**。
- KEGG 维持 NOT_RUN，不补画。
- 图注遵循 PROTECTED 措辞：reused within-cohort hold-out、High land/Hot-humid、"No interaction survived BH-FDR"。
- 重建后逐 panel 与 repaired 输出表对账（行数、显著数、FDR 列），再走 nature-figure 导出（183 mm、Arial、editable PDF/SVG、≥5 pt）。

---

## 5. Phase 5 repaired 复核与 P27 最终判定（2026-10-01 定稿）

> 本节为 P27 最终判定， supersede 上文 pre-repair 基线。数字独立复核自 `M12_REPAIR_REPORT.md` + `ranked/M12_ranked_combined_FDR.csv` + `ranked_gsea/M12_fgsea_combined.csv`（只读统计，未 rerun）。

### 5.1 repaired 各 family 计数（复核一致）

| Method | Family | Tested | Sig | FDR 列 |
|---|---|---|---|---|
| cameraPR（primary pooled） | GO-BP | 272 | **29** | FDR_pooled |
| cameraPR（primary pooled） | Reactome | 486 | **176** | FDR_pooled |
| cameraPR 合计 | — | 758 | **205** | — |
| ORA（primary pooled） | GO-BP | — | 3 | FDR_pooled |
| ORA（primary pooled） | Reactome | — | 20 | FDR_pooled |
| ORA 合计 | — | — | **23**（不变） | — |
| fgsea | GO-BP | 272 | padj 3 / pooled 6 | padj vs padj_pooled |
| fgsea | GO-MF | 107 | padj 8 / pooled 7 | — |
| fgsea | GO-CC | 151 | padj 11 / pooled 10 | — |
| fgsea | Reactome | 486 | padj 22 / pooled 18 | — |
| fgsea 合计 | — | 1016 | **padj 44 / pooled 41** | — |

- universe：mapping 1434/1414/15/5 复现一致；N_ranked=1406。
- 旧值对照：cameraPR 195(25+170)→**205(29+176)**；ORA 23 不变；fgsea padj 39→**44**、pooled 39→**41**。
- **fgsea Canonical_FDR = UNRESOLVED（保持）**：padj_family(44) 与 padj_pooled(41) 均不标 FINAL_FROZEN。

### 5.2 逐 panel invalidated 结论复核

repaired 重跑已完成，四 panel source 全部来自 repaired M12/M12B 输出。复核结论：**当前 Fig6（Fig6=NOT_FINAL）四个 panel 仍全部 invalidated，须按 repaired 输出重画**——
a_ranked（cameraPR GO-BP，现应从 repaired `M12_ranked_combined_FDR.csv` 取，GO-BP 显著数 25→29，top8 必然变化）、
b_sensitivity（cameraPR FDR × fgsea padj 散点，双轴坐标随 repaired 重估）、
c_ora（ORA GO-BP 3 条，数字不变但须重对账）、
d_network（M12B GO-BP top-4×边，membership 随 repaired 重选）。
无 panel 可保留旧 PRE_REPAIR 坐标。

### 5.3 Reactome 必须进 main（维持，repaired 依据）

- **维持建议**：repaired cameraPR 主分析 205 条中 Reactome=176，占 **176/205 ≈ 86%**，仍为绝对主导，而当前 Fig6 对 Reactome 零 curated 面板（仅散点 364 点）。
- 重建后 main 必须同时展示 representative GO-BP + representative Reactome；Reactome 用 `M12_pathway_redundancy_clusters.csv`（Jaccard>0.5）聚簇后取代表主题。
- GO-MF/GO-CC 仍建议 supplement（M12B 次分支家族内 FDR：cameraPR MF 16/CC 16、ORA MF 7/CC 4，不进主分支 pooled）。

### 5.4 Fig6b 散点落图前置条件

- **Fig6b（cameraPR × fgsea 一致性散点）在 fgsea FDR 口径冻结前不得落图**：repaired 后 padj_family=44 vs padj_pooled=41，BP 3 vs 6、MF 8 vs 7、CC 11 vs 10、Reactome 22 vs 18，家族拆分显著不同；Canonical_FDR=UNRESOLVED。
- 须先由团队裁定 canonical fgsea FDR family（padj_family 或 padj_pooled），再据裁定列重画 b 面板并在图注写明列名。在此之前 a/c/d 可先行按 repaired cameraPR/ORA 输出重建，b 面板挂起。

### 5.5 P27 最终判定：FIG6_PRESENTATION_GAP

- **最终判定：YES（存在展示缺口，且 repaired 后仍成立）**。
- repaired 口径依据：cameraPR 主分析 Reactome 176/205 ≈ 86%，当前 Fig6 零 curated Reactome 面板；GO-BP 仅 8/29；ORA Reactome 20 条零展示；fgsea 44/41 条仅作散点 y 轴、无 leading-edge。
- 结论句：**FIG6_PRESENTATION_IS_NOT_REPRESENTATIVE_OF_FULL_PATHWAY_OUTPUT（repaired 复核维持）**。
- 缺口闭合条件：main 补 representative Reactome 主题面板 + fgsea 口径冻结后补显式 fgsea 面板，再复评。本轮不画图。
