# Fig6 通路展示审计（FIG6_PATHWAY_PRESENTATION_AUDIT）

> 性质：纯静态只读审计。未重画任何图、未 rerun M17/M12、未修改任何图形或脚本。
> 权威总状态（本审计全程适用）：
> **FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED；ANALYSIS_REOPEN_REQUIRED=YES；SAFE_TO_TAG_ANALYSIS_V2_1=NO；M12=BLOCKED；M12B=BLOCKED_BY_M12；Fig6=NOT_FINAL；历史 195/23/39=PRE_REPAIR_EXISTING_OUTPUT（不得标 FINAL_FROZEN）；FGSEA_FROZEN_FAMILY=HOLD_UNTIL_M12_REPAIR_AND_RERUN；KEGG=NOT_RUN。**
> 数字逐字引自文件（R 脚本行号 / source csv / 结果表），不自行计算。

---

## 1. Fig6 数据来源追踪（按 R 脚本与 source csv 逐 panel）

出图脚本：`descriptive/analysis_v2.0/code/V2_M17_figures_v2.R`（Fig6 段：行 252–291）。
四个输入表在行 33–36 读入：

| 变量 | 行 | 文件 | 含义 |
|---|---|---|---|
| `ranked` | 33 | `M12_pathway_v2.1/ranked/M12_ranked_combined_FDR.csv` | cameraPR（竞争法）合并 FDR |
| `gsea` | 34 | `M12_pathway_v2.1/ranked_gsea/M12_cameraPR_fgsea_concordance.csv` | cameraPR↔fgsea 一致性 |
| `ora` | 35 | `M12_pathway_v2.1/ora/M12_ORA_combined_FDR.csv` | ORA（单侧 Fisher）合并 FDR |
| `path_member` | 36 | `M12_pathway_v2.1/integration/M12_ML_candidate_pathway_membership.csv` | M12B 候选-通路归属 |

### 逐 panel 表

| Panel | Method | Database | Ontology | N_terms_shown | Source_file（脚本行） | Selection_rule（脚本原文摘录） |
|---|---|---|---|---|---|---|
| **a**（a_ranked） | cameraPR（primary, competitive） | GO_BP | 生物过程 | **8**（GO-BP 显著总数 25 中的 8） | `M12_ranked_combined_FDR.csv`（行 253） | `filter(database=="GO_BP", FDR_pooled<0.05) %>% arrange(FDR_pooled) %>% slice_head(n=8)`；`signed_score=±log10(FDR_pooled)` |
| **b**（b_sensitivity） | cameraPR × fgsea 一致性散点 | GO_BP + GO_CC + GO_MF + Reactome | 全部四本体 | **887 个点**（concordance 表 1020 行剔除非有限后） | `M12_cameraPR_fgsea_concordance.csv`（行 258–259） | `filter(is.finite(FDR),is.finite(padj))`；x=`-log10(cameraPR FDR)`，y=`-log10(fgsea padj)`；4 类一致性（both/cameraPR only/fgsea only/neither） |
| **c**（c_ora） | ORA（complementary, one-sided Fisher） | GO_BP | 生物过程 | **3**（GO-BP 显著总数 3 的全部；脚本 slice_head(n=10) 但仅 3 条过阈） | `M12_ORA_combined_FDR.csv`（行 266–268） | `filter(database=="GO_BP", FDR_pooled<0.05) %>% arrange(FDR_pooled) %>% slice_head(n=10)` |
| **d**（d_network） | M12B 候选-通路紧凑图 | GO_BP | 生物过程 | **4 条通路 × 候选蛋白 = 11 条边** | `M12_ML_candidate_pathway_membership.csv`（行 271–274） | `filter(pathway_database=="GO_BP", !is.na(ranked_pathway_FDR))` → min pathway_fdr → `slice_head(n=4)` |

面板组装（行 286–287）：`(p6a | p6b) / (p6c | p6d)`，tag_levels="a"，`save_figure(..., height_mm=158)`，183 mm 宽。
source 写出（行 288–291）：a_ranked 取 `PValue/FDR_pooled`；b_sensitivity 取 `FDR(cameraPR)/padj(fgsea)`；c_ora 取 `PValue/FDR_pooled`；d_network 取 `pathway_fdr`。

source csv 实测行数（`Fig6_pathway_integration_source_data.csv`）：a_ranked=8、b_sensitivity=887、c_ora=3、d_network=11，合计 909，与脚本一致。

---

## 2. Fig6 是否展示各 family / method（逐项 YES/NO/PARTIAL/UNCLEAR）

| 对象 | 判定 | 证据 |
|---|---|---|
| **GO-BP** | **YES** | a_ranked 8 条 GO-BP cameraPR；c_ora 3 条 GO-BP ORA；d_network 4 条 GO-BP 通路节点 |
| **GO-MF** | **NO**（无 curated 面板） | 仅作为 b_sensitivity 散点中的点（105 行）出现；无独立条形/leading-edge 面板 |
| **GO-CC** | **NO**（无 curated 面板） | 仅作为 b_sensitivity 散点中的点（147 行）出现；无独立面板 |
| **Reactome** | **NO**（无 curated 面板） | 仅作为 b_sensitivity 散点中的点（364 行）出现；主分析 170/195 条 Reactome 通路无任何 curated 面板 |
| **cameraPR** | **YES（仅 GO-BP curated）** | a_ranked 8 条 GO-BP；b 面板 x 轴为 cameraPR FDR。Reactome 臂（170 条）未 curated |
| **ORA** | **YES（仅 GO-BP curated）** | c_ora 3 条 GO-BP；Reactome ORA（20 条）未进入任何图 |
| **fgsea** | **PARTIAL** | b_sensitivity y 轴用 fgsea `padj` 画 887 点一致性散点，但 39 条显著 fgsea 项未逐条列出、无 leading-edge curated 面板 |
| **M12B** | **PARTIAL** | d_network 仅 GO-BP top-4 候选映射（11 边）；M12B Spearman 相关（3 CSV）与环境一致性（2 CSV）未展示 |

### 明确记录

> **FIG6_PRESENTATION_IS_NOT_REPRESENTATIVE_OF_FULL_PATHWAY_OUTPUT**

Fig6 的 curated 面板（a/c/d）全部锁定 GO-BP：
- cameraPR 主分析 195 条 = GO-BP 25 + Reactome 170；Fig6 只 curated 展示 8 条 GO-BP，**170 条 Reactome 主分析通路在主图中零 curated 呈现**。
- ORA 23 条 = GO-BP 3 + Reactome 20；Fig6 c 展示全部 3 条 GO-BP，**Reactome 20 条未展示**。
- fgsea 39 条 = GO-BP 3 + GO-MF 8 + GO-CC 11 + Reactome 17；Fig6 仅以散点 y 轴带过，**无逐条 leading-edge**。
- b_sensitivity 的 887 行是"全测试一致性扫描"，不是 39 条显著 fgsea 的 curated 展示，不能当作 fgsea 结果面板。

---

## 3. fgsea FDR 列记录（padj vs padj_pooled）

- **Fig6 b_sensitivity 实际使用的 fgsea FDR 列 = `padj`**（R 行 258：`fgsea_score=safe_log10(padj)`；行 289：`fgsea_fdr=padj`）。`M12_cameraPR_fgsea_concordance.csv` 表头含 `padj`，**不含 `padj_pooled`**。
- `M12_fgsea_combined.csv` 表头同时含 `padj` 与 `padj_pooled`。实测显著计数：

| database | tested | padj<0.05 | padj_pooled<0.05 |
|---|---|---|---|
| GO_BP | 274 | 3 | 5 |
| GO_MF | 108 | 8 | 6 |
| GO_CC | 151 | 11 | 11 |
| Reactome | 487 | 17 | 17 |
| **合计** | 1020 | **39** | **39** |

- 冻结 fgsea 家族拆分（BP3 / MF8 / CC11 / Reactome17）与 **`padj`** 列一致；`padj_pooled` 给出 BP5 / MF6 / CC11 / Reactome17（总数同为 39，但 BP/MF 拆分不同）。
- **结论**：Fig6 b_sensitivity 用 `padj`，与冻结 39 的家族拆分一致；但若未来 Supplement 图改用 `padj_pooled`，BP/MF 拆分将变为 5/6 而非 3/8，必须在图注标明所用列。当前无任何 Supplement 通路图使用 `padj_pooled`。

---

## 4. 与 ROUND 1 图审计（figures_audit.md）的关系

- ROUND 1 发现 M1-1（Fig6 缺 Reactome 主臂）：本审计从 **R 脚本选择规则 + source csv 行数 + 结果表计数**三层独立复证，结论一致且更精确——缺口根因是行 253/266/271 三个 `filter(database=="GO_BP")` 把 a/c/d 三面板全部锁死在 GO-BP，Reactome 仅在 b 散点出现。
- ROUND 1 未触及：fgsea FDR 列（padj vs padj_pooled）的家族拆分差异、b_sensitivity 887 行的真实来源（concordance 表 1020 行剔除非有限）、d_network 的 M12B top-4 选择规则。本轮补齐。
- 权威总状态变化：ROUND 1 按 PROJECT_CONTEXT 把 195/23/39 视为冻结；本轮按新指令将其降级为 **PRE_REPAIR_EXISTING_OUTPUT**，Fig6=NOT_FINAL，本审计结论不构成"可投稿"判定。
