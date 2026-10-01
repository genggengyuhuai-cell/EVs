# 统计报告审计（nature-statistics）

审计视角：`nature-statistics` 技能（Nature 旗舰刊统计报告红线）。
审计性质：**纯静态只读审计**，未运行任何 R/Python 分析脚本，未修改 F:\env 下任何既有文件。所有数字逐字引自仓库内 frozen 文件原文；frozen 数字为权威基线，本审计不推翻，仅做对账与措辞判定。
审计日期：2026-10-01。

---

## 1. 审计范围与材料

### 1.1 已读取的技能参考文件

| 文件 | 读取方式 |
|---|---|
| `C:\Users\caoxu\.agents\skills\nature-statistics\SKILL.md` | 全量 Read |
| `references\nature-article-requirements.md` | 全量 Read |
| `references\common-failure-modes.md` | 全量 Read |
| `references\reviewer-checklist.md` | 全量 Read |

### 1.2 已读取的项目权威与协议文件

| 文件 | 读取方式 |
|---|---|
| `F:\env\PROJECT_CONTEXT.md` | 全量 Read（frozen 数字基线） |
| `F:\env\docs\protocol\ANALYSIS_PLAN_v2.1.md` | 全量 Read |
| `F:\env\manuscript_v2_1\audit\STATISTICAL_REPORTING_AUDIT.md` | 全量 Read（既有自审，对照用） |
| `F:\env\manuscript_v2_1\audit\STATISTICAL_CLAIM_MAP.csv` | 全量 Read |
| `F:\env\manuscript_v2_1\audit\REVIEWER_RISK_REGISTER.csv` | 全量 Read |
| `F:\env\manuscript_v2_1\audit\FIGURE_TEXT_AUDIT.csv` | 全量 Read |
| `F:\env\manuscript_v2_1\audit\FIGURE_TEXT_STANDARDIZATION_REPORT.md` | 全量 Read |
| `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\M12_FINALIZATION_REPORT.md` | 全量 Read |
| `F:\env\docs\FINAL_ML_RESULT_AUDIT.md` | 前 80 行 Read |
| `F:\env\docs\FINAL_REPRODUCIBILITY_AUDIT.md` | 前 60 行 Read |
| `F:\env\docs\CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md` | 第 70–95 行定向 Read |

### 1.3 已读取/核验的 frozen 结果 CSV

| 文件 | 核验内容 |
|---|---|
| `M14_frozen_replication\M14_replication_hierarchy.csv` | 85/85/83/29/1 层级 |
| `M14_frozen_replication\M14_frozen_status.csv` | 状态字段 |
| `M10_environment_interaction\corrected_pure_interaction\M10_pure_interaction.csv` | 1,430 行；`interaction_BH<0.05` 计数 = 0 |
| `M10_environment_interaction\corrected_pure_interaction\M10_corrected_manifest.csv` | df=2, n_sig=0 |
| `M12_pathway_v2.1\mapping\M12_gene_mapping_summary.csv` | 1434/1414/15/5 |
| `M12_pathway_v2.1\ora\M12_ORA_KEGG.csv` | KEGG_NOT_RUN |
| `M12_pathway_v2.1\ranked\M12_ranked_KEGG.csv` | KEGG_NOT_RUN |
| `M12_pathway_v2.1\ranked\M12_ranked_combined_FDR.csv` | cameraPR sig 计数（GO_BP=25, Reactome=170） |
| `M12_pathway_v2.1\ora\M12_ORA_combined_FDR.csv` | ORA sig 计数（GO_BP=3, Reactome=20） |
| `M12_pathway_v2.1\ranked_gsea\M12_fgsea_combined.csv` | fgsea sig 计数（GO_BP=5, GO_MF=6, GO_CC=11, Reactome=17） |
| `ml_v2.1\strict_nested\strict_nested_outer_metrics.csv` | n_dep min=8, max=618 |
| `ml_v2.1\results\outer_cv_metrics.csv` | fixed-85 15 outer folds |
| `discovery_validation\D08_validation\D08_replication_summary.csv` | 85/85/83/29/1 |
| `discovery_validation\D01_discovery_eligibility\D01_discovery_eligible_proteins.csv` | 1,445 eligible proteins |
| `M05_overall_exposure\M05_manifest.csv` | 1,430 proteins; n_AE_FDR_lt_0.05=0 |
| `M08_detection\Firth_primary\M08_Firth_manifest.csv` | n_total=3054, n_sig=2 |
| `M07_pairwise_contrasts\M07_High_vs_Low.csv` | 列含 effect/CI_low/CI_high/t/df/P_raw/BH_FDR |

### 1.4 未全量读取的文件及理由

- `docs\protocol\ANALYSIS_PLAN_v2.0.md`（84 KB）、`STUDY_DESIGN_AUDIT.md`（88 KB）、`V2_IMPLEMENTATION_GAP_AUDIT.md`（43 KB）：体量大，且 v2.1 amendment 已显式声明其前向部分被取代；统计口径以 v2.1 与 frozen CSV 为准。本次审计未对这三份大文件逐行 Grep，理由是 frozen 结果表与 v2.1 协议已覆盖统计设计抽取所需的全部 n、重复、FDR 族、效应量字段。
- `DISCOVERY_VALIDATION_PROTOCOL.md`、`DISCOVERY_VALIDATION_SPLIT_SPEC.md`：未全量 Read；其关键产物（D01/D08 CSV）已直接核验。
- M12B、M11、M09、M06、M13 的 CSV：本次审计聚焦统计报告红线（n、FDR、效应量、交互措辞、复制层级），这些模块的 frozen 数字已在 `STATISTICAL_REPORTING_AUDIT.md` 与 PROJECT_CONTEXT 中登记，未逐行复核。
- `docs\FINAL_ML_RESULT_AUDIT.md` 第 81 行之后、`FINAL_REPRODUCIBILITY_AUDIT.md` 第 61 行之后：未读，理由是本审计关注统计报告措辞与数字对账，非工程可复现性细节。

---

## 2. 独立判定

本审计以 nature-statistics 技能红线独立走完"设计抽取 → n 与重复 → claim→analysis 映射 → 常见失败模式 → 报告完整性 → 图注统计 → QA"七步。总体结论：**PASS_WITH_LIMITATIONS**，与既有自审一致；但本审计额外发现 2 项既有自审未登记的问题（见 3.2 F-01、F-02）。

### 2.1 与既有自审（STATISTICAL_REPORTING_AUDIT.md）的对比

| 既有自审结论 | 本审计独立判定 | 差异与理由 |
|---|---|---|
| 519→515→386/129 口径正确 | 一致。M05 manifest 登记 Control=153/Low=186/High=176，合计 515；D01 eligible=1,445 行；M14 hierarchy 85/85/83/29/1 与 D08 summary 完全一致。 | 无差异 |
| 0/1,430 overall exposure at BH-FDR<0.05 | 一致。M05 manifest `n_AE_FDR_lt_0.05=0`。 | 无差异 |
| 0/1,430 interaction at BH-FDR<0.05 | 一致。本审计用 PowerShell 逐行计数 `M10_pure_interaction.csv` 的 `interaction_BH<0.05`，结果为 0/1,430；df=2 已登记于 manifest。 | 无差异 |
| cameraPR 195（GO BP 25 + Reactome 170） | 一致。逐行计数 `M12_ranked_combined_FDR.csv`：GO_BP=25, Reactome=170。 | 无差异 |
| ORA 23（GO BP 3 + Reactome 20） | 一致。逐行计数：GO_BP=3, Reactome=20。 | 无差异 |
| fgsea 39（GO BP 3 + GO MF 8 + GO CC 11 + Reactome 17） | **部分不一致**。逐行计数 `M12_fgsea_combined.csv` 的 `padj_pooled<0.05`：GO_BP=**5**、GO_MF=**6**、GO_CC=11、Reactome=17，合计 39。总数 39 与 PROJECT_CONTEXT 一致，但 GO_BP 与 GO_MF 的子项拆分与 PROJECT_CONTEXT 第六节、既有自审第 119 行不一致（既有自审写 3/8，frozen CSV 实为 5/6）。 | **新发现 F-01**：权威基线文档自身子项拆分有误；总数正确。 |
| KEGG NOT_RUN | 一致。两份 KEGG placeholder CSV 均为 `KEGG_NOT_RUN` 状态行。 | 无差异 |
| strict nested 8–618 | 一致。`strict_nested_outer_metrics.csv` 中 n_dep 最小=8（rep2,fold2）、最大=618（rep3,fold1）。 | 无差异 |
| M08 Firth 2/3,054 | 一致。Firth manifest `n_total=3054, n_sig=2`。 | 无差异 |
| 措辞红线（85≠validated、29≠FDR-replicated、129≠external validation、交互句必须 "No interaction survived…"） | 一致。本审计 Grep `manuscript_v2_1\` 与 `docs\` 目录，未发现这些违禁措辞被实际用作正面声称；它们仅出现在"禁止措辞"列、风险讨论或 CONSOLIDATION_REPORT 的元描述中。 | 无差异 |
| M14 frozen status | **既有自审未提及**。`M14_frozen_replication\M14_frozen_status.csv` 仍写 "Pathway (frozen D10) = NOT_RUN_NO_APPROVED_MAPPING"、"ML M15 = NOT_STARTED"，与 PROJECT_CONTEXT 第四节（M12 v2.1、ml_v2.1 均为 ACTIVE_MAINLINE 且产物已存在）矛盾。 | **新发现 F-02**：frozen status 文件过期，可能误导后续作者或审稿人。 |
| Nature Methods 统计节完整性（软件版本、t/F+df、one/two-sided、randomization/blinding） | 既有自审未专门对照 Nature Article 清单逐项核。M07 CSV 含 t/df/CI_low/CI_high（好）；M12 manifest 登记了 limma 3.58.1、fgsea 1.28.0、org.Hs.eg.db 3.18.0、reactome.db 1.86.2；但 M05–M11 主分析的 R 版本、limma/e1071/logistf 版本未集中登记；Firth detection 的单/双侧未在 manifest 声明；randomization/blinding 对本观察性队列未显式声明 "n/a"。 | **新发现 F-03/F-04/F-05**：Nature 投稿前 Methods 统计节仍需补全。 |

---

## 3. 分级发现清单

### 3.1 阻断（P0）

无。本审计未发现错误模型、错误数据子集、错误 FDR 族、泄漏或实现错误。

### 3.2 重大（P1）

- **[P1] F-01：fgsea 子项拆分在权威基线文档中与 frozen CSV 不一致**
  - 证据指针：
    - `F:\env\PROJECT_CONTEXT.md` 第六节："fgsea (sensitivity, ranked) 39 pathways（GO BP 3; GO MF 8; GO CC 11; Reactome 17）"。
    - `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_combined.csv` 逐行计数 `padj_pooled<0.05`：GO_BP=5、GO_MF=6、GO_CC=11、Reactome=17（合计 39）。
    - `M12_FINALIZATION_REPORT.md` 第 64 行也写 "GO BP = 5, GO MF = 6, GO CC = 11, Reactome = 17"，与 CSV 一致。
  - 影响：总数 39 正确，不影响主结论；但 PROJECT_CONTEXT 作为 frozen 数字基线，其 GO BP/GO MF 子项拆分写错。若作者按 PROJECT_CONTEXT 撰写 Methods/Results，会出现与 supplementary CSV 对账不上的低级错误，审稿人对账时会质疑严谨性。
  - 建议：以 frozen CSV（5/6/11/17）为准，修正 PROJECT_CONTEXT 第六节 fgsea 子项拆分；同步修正 `STATISTICAL_REPORTING_AUDIT.md` 第 119 行与 `STATISTICAL_CLAIM_MAP.csv` C22 行。注意本审计不修改任何既有文件，仅指出差异。

- **[P1] F-02：M14_frozen_status.csv 状态字段过期，与当前管线阶段矛盾**
  - 证据指针：`F:\env\descriptive\analysis_v2.0\M14_frozen_replication\M14_frozen_status.csv` 内容为：
    - "Pathway (frozen D10)" = `NOT_RUN_NO_APPROVED_MAPPING`
    - "ML M15" = `NOT_STARTED`
    - "ML M16" = `NOT_AUTHORIZED`
  - 对照：`PROJECT_CONTEXT.md` 第四节将 M12 v2.1、ml_v2.1 列为 ACTIVE_MAINLINE；`M12_pathway_v2.1\M12_FINALIZATION_REPORT.md` 与 `ml_v2.1\results\outer_cv_metrics.csv` 等 frozen 产物均已存在。
  - 影响：该文件名含 "frozen"，后续作者或审稿人若打开此 CSV，会误以为通路与 ML 未做。虽然 hierarchy CSV（85/83/29/1）本身正确，但 status 文件会制造"项目到底做没做 ML/通路"的混淆。
  - 建议：在 Methods/Supplementary 中明确此 status CSV 是早期快照，或在下一次冻结时刷新其字段值；投稿稿件不应引用此文件作为通路/ML 状态证据。

### 3.3 次要（P2）

- **[P2] F-03：Nature Methods 统计节软件版本登记不集中**
  - 证据指针：M12 manifest（`diagnostics\M12_run_manifest.csv`）登记了 limma 3.58.1、fgsea 1.28.0、org.Hs.eg.db 3.18.0、reactome.db 1.86.2；但 M05/M07/M10/M08 主分析（`M05_manifest.csv`、`M07_manifest.csv`、`M10_corrected_manifest.csv`、`M08_Firth_manifest.csv`）未登记 R 版本、limma 版本、eBayes 参数（trend=TRUE, robust=TRUE 已在 M05 manifest）、logistf 版本、glmnet 版本、ranger 版本、xgboost 版本。
  - 影响：Nature 初始投稿要求 Methods 给出软件包及版本；当前 frozen manifest 覆盖不全，投稿前需汇总。
  - 建议：在 Methods "Statistical analysis" 节集中列出 R 版本 + 关键包版本（limma, stats, logistf, glmnet, ranger, xgboost, fgsea, clusterProfiler, org.Hs.eg.db, reactome.db）。

- **[P2] F-04：Firth detection 与 overall-exposure omnibus 的单/双侧声明缺失**
  - 证据指针：ORA 已在 M12 finalization report 第 54 行明确 `alternative="greater"`（one-sided Fisher）；但 M08 Firth 检测率检验（`M08_Firth_manifest.csv`）未声明双侧/单侧；M05 overall exposure（A-E）在 limma 框架下为 omnibus F 检验，未在 manuscript-facing 文档中声明双侧。
  - 影响：Nature 要求每个检验声明 one-tailed/two-tailed。当前 ORA 明确，其余检验需补。
  - 建议：Methods 中明确：limma moderated t/F 均为 two-sided；Firth 检测率 Group LR 为 two-sided likelihood ratio；ORA 为 one-sided Fisher (alternative="greater")；cameraPR 与 fgsea 为 two-sided competitive/ranked test。

- **[P2] F-05：观察性队列的 randomization / blinding 未显式声明 n/a**
  - 证据指针：所有 frozen manifest 与既有自审均未提及 randomization/blinding。本研究为环境暴露流行病学观察性队列（PROJECT_CONTEXT 第一节）。
  - 影响：Nature Reporting Summary 要求勾选 randomization/blinding；不写会被退回补勾。
  - 建议：Methods 与 Reporting Summary 显式写："This is an observational cross-sectional cohort study; participants were not randomized to exposure group and sample processing was not blinded. Exposure assignment was determined by residential site/region as recorded in the cohort protocol."

- **[P2] F-06：M05 overall exposure 的 F 统计量与 df 未在 manuscript-facing 层面对外呈现**
  - 证据指针：M05 manifest 仅登记 `n_AE_FDR_lt_0.05=0` 与 `model=limma lmFit ~0+Group+Environment`、`eBayes(trend=TRUE, robust=TRUE)`；未登记 omnibus F 统计量与残差 df。M07 pairwise CSV 含 `t` 与 `df` 列（已确认存在）。
  - 影响：Nature 要求 ANOVA/F 检验给出 F 统计量与 df；当前 0/1,430 是阴性结果，正文可不列每蛋白 F，但 Methods 应说明模型自由度结构（515 样本，Group=3 水平 + Environment=2 水平，残差 df ≈ 515 - 估计系数数）。
  - 建议：Methods 给出残差 df 与 F 检验构造；Results 报告 0/1,430 时附一句 "the smallest adjusted P across 1,430 proteins was 0.XX"（如 frozen CSV 中有）。

### 3.4 提示（P3）

- **[P3] F-07：M14 status CSV 中 "Peptide evidence = SOURCE_NOT_AVAILABLE" 与 v2.1 已移除 unique-peptide scope 的关系**
  - 证据指针：`M14_frozen_status.csv` 第 2 行；`ANALYSIS_PLAN_v2.1.md` 第四节已将 unique-peptide evidence 从 active scope 移除。
  - 影响：小。Methods 已说明不要求 peptide 层；此 CSV 字段保留历史痕迹。
  - 建议：Methods 中一句 "Unique-peptide evidence was not available and was excluded from the v2.1 analysis scope (see Analysis Plan v2.1 §4)" 即可。

- **[P3] F-08：M12B 相关性 / 网络措辞已有自审约束，但 Methods 需明确 "pairwise Spearman, not WGCNA"**
  - 证据指针：`STATISTICAL_REPORTING_AUDIT.md` 第 140 行、`STATISTICAL_CLAIM_MAP.csv` C25/C26/C27 均已登记。
  - 影响：低。既有自审已覆盖；本审计未在 M12B 输出 CSV 中逐行核对，但 frozen 产物命名（`M12B_spearman*`、`M12B_edges*`）与措辞规则一致。
  - 建议：Methods 保留 "pairwise Spearman correlations; no co-expression module detection" 一句即可。

- **[P3] F-09：strict nested ML 的 8–618 折叠局部 DEP 数，正文应避免被误读为"生物学异质性"**
  - 证据指针：`strict_nested_outer_metrics.csv` n_dep 范围 8–618；PROJECT_CONTEXT 第五节、既有自审第 98 行均已明确此为特征选择不稳定。
  - 影响：低。措辞规则已冻结。
  - 建议：Results/Methods 固定句："Fold-local DEP counts ranged from 8 to 618 across 15 outer splits, reflecting instability of feature selection under resampling rather than biological heterogeneity."

---

## 4. 可进入稿件的安全措辞要点

以下为本审计基于 frozen CSV 逐字核对后认为可直接进入稿件的措辞模板：

1. **队列与划分**：
   > "The initial cohort comprised 519 participants; after QC the analytical cohort was 515 (153 Control, 186 Low, 176 High exposure). A prospective deterministic split (seed 20260925) assigned 386 participants to the Discovery subset and 129 to a reused within-cohort hold-out subset. The reused hold-out is not an external or independent validation cohort."

2. **Discovery 筛选**：
   > "Within the Discovery subset, 1,445 proteins met quantitative eligibility. High-vs-Low differential abundance was assessed by moderated linear models (limma; trend=TRUE, robust=TRUE) with Benjamini-Hochberg FDR correction across 1,445 proteins. Eighty-five proteins survived FDR < 0.05."

3. **复制层级（必须按此五级表述，不得跳级）**：
   > "On the reused hold-out subset, all 85 proteins remained estimable; 83/85 showed concordant direction of effect; 29/85 reached nominal P < 0.05 (uncorrected within the 85-protein candidate family); and 1/85 survived candidate-family BH-FDR < 0.05. This single FDR-supported protein is the only multiplicity-controlled replication signal."

4. **交互**（必须以此句为基准，不得改写为"there was no interaction"）：
   > "No exposure × environment interaction survived the prespecified BH-FDR threshold (0/1,430 proteins; 2-degree-of-freedom Wald test; BH across 1,430 tests)."

5. **通路**（三方法分列，不相加）：
   > "cameraPR (primary competitive, inter-gene correlation 0.01) identified 195 FDR-significant pathways (25 GO Biological Process; 170 Reactome). One-sided Fisher ORA on the 85 locked DEPs against the 1,414 mapped background identified 23 pathways (3 GO BP; 20 Reactome). fgsea (sensitivity, ranked) identified 39 pathways at pooled padj < 0.05 (GO BP 5; GO MF 6; GO CC 11; Reactome 17; per `M12_fgsea_combined.csv`). KEGG was not run because the KEGG REST resource returned an incomplete pathway list. The three methods answer distinct questions and their counts must not be summed."
   >
   > 注意：此处 fgsea 子项采用 frozen CSV 的 5/6/11/17，不采用 PROJECT_CONTEXT 的 3/8/11/17（见 F-01）。

6. **ML**：
   > "Predictive modeling was conditional on the frozen 85-protein Discovery panel and assessed by 15 outer cross-validation folds (5 repeats × 3 seeds) within the Discovery High+Low subset (n=271). This is a conditional, exploratory predictive-performance estimate; it is not an unbiased generalization estimate and not an external validation. A strict whole-pipeline nested sensitivity (fold-local DEP screen within each outer training split) showed fold-local DEP counts ranging 8–618, reflecting feature-selection instability under resampling."

7. **Boruta / XGBoost**：
   > "Feature relevance was additionally examined by a Boruta-style random-forest procedure (ranger with shadow variables and a pooled binomial confirmation test; not the CRAN Boruta package) and by XGBoost relative-gain importance; both are descriptive, post-selection analyses on the fixed 85-protein panel and are not causal biomarker estimates."

8. **Site LOO**：
   > "Leave-one-site-out analyses assessed direction stability and maximum effect shift; they are robustness analyses, not independent replication."

---

## 5. 未覆盖 / 无法判定的边界

1. **未运行分析**：本审计为静态只读，未重新计算 FDR、未重跑 limma、未核对 85 个 DEP 的逐蛋白 log2FC/CI 是否与 D03 lock 完全一致（仅核对层级计数 85/83/29/1）。
2. **M12B 生物学上下文**：未逐行读取 M12B 的 Spearman/网络 CSV；其统计正确性假定由 `M12B_all.R` 与既有自审保证。
3. **M09 KNN、M11 LOO、M06 architecture**：未逐行复核其 frozen CSV；仅引用其汇总计数。
4. **图注逐字核对**：`FIGURE_TEXT_AUDIT.csv` 与 `FIGURE_TEXT_STANDARDIZATION_REPORT.md` 已登记图注修改项；本审计未打开 TIFF/PDF 图像本身核对图上文字与 source-data CSV 是否逐字一致。
5. **ANALYSIS_PLAN_v2.0.md / STUDY_DESIGN_AUDIT.md / V2_IMPLEMENTATION_GAP_AUDIT.md 大文件**：未逐行 Grep，理由见 1.4；若这三份文档中存在与 v2.1 矛盾的旧统计措辞，本审计未捕获。
6. **原始 P 值最小/最大值**：本审计未从 M05/M07 CSV 中提取"最小原始 P"或"最小调整 P"的具体数值；若投稿需要在 Results 中报告最小 adjusted P，需另行从 frozen CSV 读取。
7. **统计功效 / 样本量论证**：frozen 文档中未见到先验功效计算（power calculation）；本审计不判断其是否必要（观察性队列的 Nature 投稿通常不强制，但 Reporting Summary 可能要求）。
8. **缺失数据机制**：M09 KNN sensitivity 已做，但缺失机制（MCAR/MAR/MNAR）未在统计层显式建模；既有自审第 192 行已列为 limitation。
9. **多产物对账**：本审计未运行 `delivery_guard.py` 或 `final_facts.py`（那些属于 doubao-data-analysis 技能产物门，不在本 nature-statistics 审计范围）；数字对账仅到"frozen CSV 逐行计数"一层。

---

**审计结论**：整体统计报告架构与 frozen 数字基线一致，措辞红线在既有自审文档中已被充分识别；本审计新增 2 项 P1（fgsea 子项数字不一致、M14 status 文件过期）与 4 项 P2（Nature Methods 软件版本、单/双侧声明、randomization/blinding n/a、M05 F 统计量 df），均为投稿前可通过措辞与文档整理修复的问题，无需重跑分析。
