# Pathway Universe Reconciliation（三层 universe 对账）

> 日期：2026-10-01。对象：M12 pathway v2.1（Phase 5 repaired 重跑后）。
> 目的：澄清三个**不可互换**的 denominator，防止把 1445 / 1434 / 1414 / 1406 写成同一分母。

## 0. 结论措辞（稿件与正文统一使用）

> **"Pathway mapping started from the complete primary inferential universe;
> gene-set analyses used the transparently derived mapped/rankable subset."**

三个数字**不是**同一 denominator 的别名，而是逐层派生的集合大小。

## 1. 三层 universe 定义与数字

| 层 | 名称 | 大小 | 含义 | 出处 |
|---|---|---|---|---|
| **A** | Primary inferential universe | **1,445** | Discovery-eligible protein 全集；85 DEPs 的 BH-FDR 检验族；D02 主模型输入 | `D01_discovery_eligibility/`（eligible=1445，raw=3817）；`PROJECT_CONTEXT.md §2` |
| **B** | Pathway mapping universe | **1,434** | 实际进入 M12_01 mapping 的蛋白组（Q515 PRIMARY 表达矩阵 tested 行） | `mapping/M12_gene_mapping_summary.csv`：total_protein_groups_tested=1434 |
| **C** | Rankable gene-set universe | **1,406** | mapping 后取到有效 ranking 统计量、实际喂给 cameraPR/ORA/fgsea 的基因数（= mapped 1,414 ∩ D02 ESTIMABLE） | `M12_REPAIR_REPORT.md §B`：N_ranked=1406 |

## 2. 逐层差异拆解

### A→B：1,445 → 1,434（差 11 蛋白）
- 1,445 = Discovery 资格宇宙（D01 eligible，High-vs-Low discovery 的检验族）。
- 1,434 = Q515 PRIMARY 表达矩阵中可做丰度模型的蛋白行（M05–M10/M12 mapping 宇宙）。
- 差异 11 个蛋白：属 D01 eligible 但不在 Q515 丰度矩阵 tested 行内（或反之）。
- **根因：R03 已关闭（作者 2026-10-02 裁定）**。方法合同 `M12_CANONICAL_METHOD_CONTRACT.md §4`
  原要求 pathway ranking 宇宙切到 D01 eligible=1,445；Phase 5 重跑保持 Q515=1,434 口径，
  并在 `M12_REPAIR_REPORT.md §B` 与 `FGSEA_FDR_RECONCILIATION.md` 显式声明此为已声明延期项。
  作者 2026-10-02 接受当前三层结构为终态，不重跑（见 `docs/R03_FINAL_AUTHOR_DECISION.md`）。

### B→mapping 中间层：1,434 → 1,414（drop 20）
- unmapped（无 gene 映射）= **5**。
- multi-gene / ambiguous（一个蛋白组对应多基因，取 representative）= **15**。
- duplicate_gene_groups = 0；retained_representative = 1,414；mapping coverage = 98.61%。
- 出处：`mapping/M12_gene_mapping_summary.csv`（逐字）。

### mapping 中间层→C：1,414 → 1,406（差 8）
- 8 个 mapped 基因不在 D02 ESTIMABLE 集（D02 Model_status ≠ ESTIMABLE，无有效 moderated t）。
- 另有 **39 个 D02 蛋白不在 mapped set**——这是 A→B 那 11 蛋白差异在交集层面的自然体现
  （D02 1,445 ∩ mapped 1,414 = 1,406；两侧未交集合分别为 39 与 8）。
- 出处：`M12_REPAIR_REPORT.md §B`。

## 3. 谁是哪个检验族的分母（口径一致）

| 分析 | denominator | 说明 |
|---|---|---|
| Discovery 85 DEPs 的 BH-FDR | **1,445**（层 A） | claim C05；不得用 1430/1434 |
| M05–M10 丰度主分析（含交互 0/1,430） | 1,430（Q515 abundance universe） | 与 pathway 无关，勿混 |
| cameraPR / ORA / fgsea 的 gene-set 背景 | **1,406**（层 C，rankable）；ORA 背景行数 153/178 由 mapping 派生，未硬编码 1,414 | 出现在 ranked/ora 表的 tested 列 |
| mapping 登记 | 1,434 / 1,414 | 见 mapping summary |

## 4. R03 处理结论（不造假，作者已裁定）

> **2026-10-02 作者最终决定**：R03 = **CLOSED_ACCEPT_CURRENT_UNIVERSE_STRUCTURE**。
> 详见 `docs/R03_FINAL_AUTHOR_DECISION.md`。不重跑 M12，不冻结数字不变。

- R03 原文（合同 §4）要求 pathway inferential universe = D01 eligible = 1,445。
- Phase 5 实际：**未切换，保持 Q515=1,434**，并在三处文档显式声明延期。
- 因此本文件**不**把 1,434 改写成 1,445，也不把 1,406 写成 1,445；而是用 §0 那句统一措辞，
  如实说明 mapping 概念上承接 primary inferential universe、实际 gene-set 分析用透明派生的 mapped/rankable subset。
- **作者裁定（2026-10-02）**：接受当前三层 universe 结构（1,445 discovery inferential / 1,434 mapping registry /
  1,406 rankable tested）为终态。理由：rankable set 1,406 已是干净交集；8 个 full-cohort-only 蛋白未进入 D02 ranked
  检验；19 个 discovery-only 蛋白未进 mapping 是已登记的 universe 差异，非 hidden bug；合同 §4 的 1,445 要求是 repair
  期间写入的 forward-looking 注记，非前瞻 preregistered 要求。M12 模块状态升级为 **FINAL_FROZEN**。
