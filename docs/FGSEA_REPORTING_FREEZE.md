# FGSEA Reporting Freeze

> 日期：2026-10-01。Phase 6 初版；Phase 7 终态更新。
> 状态：**FGSEA_REPORTING_STATUS = FROZEN_AS_DUAL_REPORTED_SENSITIVITY**
> 本文档冻结 fgsea 在稿件中的报告规则；不改变任何计算结果。

---

## 1. 终态判定（Phase 7 确认）

- **FGSEA_CANONICAL_FDR = DUAL_REPORTED_SENSITIVITY**（终态，不再要求选 family-wise 或 pooled 作唯一 primary）
- **PRIMARY_INFERENCE = NONE**（fgsea 永远不作为主文 primary pathway inference）
- 层级固定：
  - **cameraPR = PRIMARY**（primary pathway inference）
  - **ORA = COMPLEMENTARY**（complementary one-sided Fisher）
  - **fgsea = SENSITIVITY / SUPPORTING ONLY**（ranked GSEA multilevel, dual FDR columns）
- 理由：v2.1 §10 与 frozen protocol 均未指定 fgsea canonical family；两套计数均有效且总数接近（44 vs 41）；按"禁止按数字好看选择"原则，双列透明展示即为终态。无需团队后续二选一裁定。

---

## 2. 两套 BH 定义（均保留，双列并报）

| 列名 | 定义 | 校正族 | 用途 |
|---|---|---|---|
| `padj`（family-wise） | 每个 ontology/database 内部独立 BH 校正 | 族内（BP=272, MF=107, CC=151, Reactome=486） | Supplement 表；与 fgseaMultilevel 默认输出一致 |
| `padj_pooled`（pooled） | 跨全部 fgsea tested 集合合并 p 值后一次 BH | 跨全部 1,016 tests | Supplement 表；与 cameraPR/ORA pooled BH 口径对齐 |

- 两列均永久保留在 `M12_fgsea_combined.csv`；不得只保留一列。
- 两列均为 sensitivity 计数，均不作为主文 primary discovery 数字。

---

## 3. Repaired 双套计数（Phase 5 重跑后，终值）

| Family | Tested | padj（family-wise BH）<0.05 | padj_pooled（pooled BH）<0.05 |
|---|---|---|---|
| GO BP | 272 | 3 | 6 |
| GO MF | 107 | 8 | 7 |
| GO CC | 151 | 11 | 10 |
| Reactome | 486 | 22 | 18 |
| **合计** | **1,016** | **44** | **41** |

- 数字出处：`descriptive/analysis_v2.0/M12_pathway_v2.1/ranked_gsea/M12_fgsea_combined.csv`（Phase 5 repaired）。
- 历史 PRE_REPAIR 数字（39 total）仅存于 `pre_repair_snapshot/`，不引用。

---

## 4. 方法角色层级（终态冻结）

| 方法 | 角色 | 主文引用 | Supplement 引用 |
|---|---|---|---|
| **cameraPR** | **Primary pathway inference**（competitive ranked test, inter-gene cor=0.01） | 是（主结果通路结论，205 = 29 GO-BP + 176 Reactome） | 是（full table, S-PATH1） |
| **ORA** | **Complementary**（one-sided Fisher, 85 DEP foreground vs mapped background） | 是（简要提及，23 = 3 GO-BP + 20 Reactome） | 是（full table, S-PATH2） |
| **fgsea** | **Sensitivity / supporting only**（ranked GSEA multilevel） | 否（仅 Discussion/Limitation 一句"sensitivity analysis"） | 是（full table + 可视化，S-PATH3，双列并报） |
| KEGG | NOT_RUN | 否 | 否（仅 provenance 注记） |

- **fgsea 永远不得被称为 primary discovery family**。
- 主文若提及 fgsea，只能用 "sensitivity analysis"、"consistent with"、"corroborated by ranked GSEA" 等从属措辞。
- Supplement fgsea 表须同时列出 padj 与 padj_pooled 两列及各自显著计数，标注 "dual FDR reporting — sensitivity only, not primary inference"。

---

## 5. GO-MF / GO-CC placement（终态）

| 层级 | 内容 |
|---|---|
| **MAIN text** | GO-BP（cameraPR primary + ORA primary）+ Reactome（cameraPR primary + ORA primary）。代表性 theme 经 redundancy clusters 聚簇后展示（Fig6a=GO-BP, Fig6b=Reactome）。 |
| **SUPPLEMENT** | GO-MF cameraPR（16 sig, per-family FDR）、GO-CC cameraPR（16 sig, per-family FDR）、GO-MF ORA（7 sig）、GO-CC ORA（4 sig）、full fgsea 双列表、full pathway tables、environment-stratified concordance、leading-edge 全表。 |

- GO-MF 与 GO-CC 是 M12B 次要分支产物（per-family BH，未与主族合并校正），不进入主文通路结论。

---

## 6. 稿件措辞规则（终态）

- 主文通路段开头："cameraPR identified 205 FDR-significant pathways (29 GO Biological Process + 176 Reactome; primary competitive ranked test). ORA identified 23 pathways (3 GO BP + 20 Reactome; complementary one-sided Fisher). fgsea multilevel GSEA was performed as a sensitivity analysis (see Supplementary Table X)."
- 不得写 "195+23+39" 或任何三方法相加。
- 不得写 "KEGG pathway analysis"。
- Supplement fgsea 表标题："fgsea multilevel sensitivity analysis — dual FDR reporting (family-wise padj and pooled padj_pooled); sensitivity only, not primary inference."

---

## 7. M12 模块状态与剩余 hold

- **M12 当前状态**：REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD → **fgsea FDR hold 已通过本冻结解除**（DUAL_REPORTED_SENSITIVITY 为终态，不再 UNRESOLVED）。
- **M12 剩余 hold**：
  1. **R03 inferential universe 切换延期**（从 Q515=1,434 切到 D01 eligible=1,445）——已声明延期项，M12 暂不标 FINAL_FROZEN。
  2. **Fig6b label 更新**——待 Fig6b 重导出后确认 caption 无 stale fgsea 措辞（P18 暂缓项）。
- M12 升级为 **REPAIRED_RERUN_COMPLETE** 的条件：R03 团队裁定 + Fig6 全部 panel caption 终审通过。

---

## 8. 本冻结为终态

本冻结（FGSEA_REPORTING_STATUS=FROZEN_AS_DUAL_REPORTED_SENSITIVITY）不再开放"二选一"裁定。所有稿件、Supplement、figure、claim map 引用 fgsea 时须双列并报、标 sensitivity、不做 primary inference。
