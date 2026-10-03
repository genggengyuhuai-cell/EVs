# Reviewer R3 预投稿审稿报告（互盲三人审稿之 R3）

> 本报告由 R3 独立完成。我是三位互盲审稿人中的第三位，未阅读 R1 或 R2 的任何意见，也不推测其结论。所有数字逐字引自所给不可变材料包，并在每条 concern 后标注出处。本报告冻结后不再修改。

## Review setup

- **Input scope**
  所审对象为 analysis-v2.1 的环境暴露 × EV-enriched 血浆蛋白组学研究。输入不是组装好的稿件正文，而是作者方自审文档、模块与声称映射表、风险登记册，以及 frozen 结果汇总 CSV。具体材料包括 PROJECT_CONTEXT.md、manuscript_v2_1/audit 下的 MANUSCRIPT_MODULE_MAP.csv、STATISTICAL_CLAIM_MAP.csv、FIGURE_TEXT_AUDIT.csv、WHOLE_PROJECT_SCIENTIFIC_REVIEW.md、REVIEWER_RISK_REGISTER.csv，以及 M12/M12B/M05/M06/M14/ml_v2.1 的 frozen 汇总与 finalization 报告，外加 docs 下的协议与可复现性文档。

- **Assessment boundary（评估边界，必须先声明）**
  截至本报告，稿件正文尚未组装。PROJECT_CONTEXT.md 第 9 节明确列出尚未开始的工作，包括最终可复现性审计、analysis-v2.1 freeze tag、稿件组装（图注、表格、方法正文、TIFF 导出）、Nature 风格写作与预投稿审稿。因此我能评审的"稿件声称"全部来自作者方自审文档与 frozen 结果表，无法对正文行文、摘要、引言、讨论的实际措辞做技术读审。凡涉及新颖性定位、跨学科可读性、意义传达的判断，我都标注为"在所给材料中不可评估"，而非据空缺臆断。

- **Shared manuscript claim summary（据材料包重建的声称摘要）**
  在一个 515 人的暴露定义血浆蛋白组学队列中（153 Control / 186 Low / 176 High），以确定性前瞻切分得到 386 人 Discovery 子集，从中筛出 85 个 High-vs-Low 差异蛋白（BH-FDR<0.05）。同一队列内的 129 人 reused hold-out 上，83/85 方向一致，29/85 达到原始 P<0.05，仅 1/85 通过候选族 BH-FDR。整体暴露家族 0/1430 显著，环境×暴露交互 0/1430 显著。通路以 cameraPR 为主（195 条），ORA（23 条）与 fgsea（39 条）为辅，KEGG 未运行。ML 为固定 85 条件下的外循环交叉验证，并配 leakage-controlled 的 strict nested 敏感性（fold-local DEP 数 8 至 618）。

- **Visible evidence base**
  frozen 数字与作者方自审文档，见上文 Input scope。我未运行任何分析脚本，仅做只读核对。

- **Missing materials affecting confidence**
  组装后的稿件正文、摘要、引言、讨论、图表图注与 TIFF 均不存在。无任何文献对比章节，因此新颖性相对于既有工作的增量无法从所给材料判定。无 EV 纯度表征、无外部队列、无功能或细胞起源实验，这些均为作者方已声明的缺口。

- **R3 emphasis（本审稿人的既定侧重）**
  贡献定位与新颖性、声称强度、可复现性、术语纪律、跨学科读者可读性。五轴（originality、scientific importance、interdisciplinary readership、technical soundness、readability for nonspecialists）均有覆盖，但权重按上述侧重分配。

## Overall assessment

这是一项统计纪律相当自觉的单队列探索与稳健性研究。作者方自己建立了严密的声称映射表（STATISTICAL_CLAIM_MAP.csv），逐条标注 SAFE 与 REWORD，并明确列出禁止用语，例如不得把 85 称为 validated、不得把 29 称为 FDR-replicated、不得把 129 称为 external validation。frozen 数字在 PROJECT_CONTEXT、PIPELINE_STATUS、finalization 报告之间总体一致，队列分层、候选锁定先于 hold-out 使用、prespecified FDR 家族这些设计选择在方法学上是正确的。

但从 R3 的侧重看，研究的科学分量目前是"扎实的领域内增量"，而非"突出的广度意义"。正式复制级别只有 1/85，ML 固定 85 条件下的 LASSO 中位 AUROC 约 0.65，strict nested 约 0.63，且无外部队列。核心经验发现（85 个 High-vs-Low 候选）的科学重量被作者方自己在 WHOLE_PROJECT_SCIENTIFIC_REVIEW 第 3 节描述为"modest"。这不是缺陷，而是必须如实呈现的边界。真正的风险不在已做的分析，而在尚未写出的稿件如何定位。

## Who would be interested in the results, and why

环境暴露与健康蛋白组学方向的研究者会关注，因为这是一个多环境点、前瞻切分、带复制层级与多方法敏感性对照的血浆蛋白组学队列。EV-enriched 血浆富集方向的研究者会关注其富集层生物学背景，但作者方明确没有 EV 纯度表征。统计与可复现性方向的研究者会关注其候选锁定、reused hold-out 层级、strict nested 对照这套"克制式报告"模板。广度意义能否成立，取决于尚未写出的引言与讨论能否把"环境暴露 × EV-enriched 血浆蛋白组"这个交叉角度讲清楚，这一点我无法从所给材料判定。

## Major strengths

- 复制层级被诚实地拆成 85 → 83 方向一致 → 29 名义 → 1 FDR 支持，并把 1/85 明确定为正式复制的上界而非成功，见 M14_replication_hierarchy.csv 与 REVIEWER_RISK_REGISTER R05。
- 候选在使用 hold-out 之前即锁定（D03 exactly 85 行，带 SHA-256），避免了用 hold-out 反选特征，见 ANALYSIS_PLAN_v2.1 第 5 节与 docs/FINAL_REPRODUCIBILITY_MANIFEST.csv D03 行。
- 通路方法分层清晰，cameraPR 为主、ORA 互补、fgsea 敏感，且明确禁止把 195+23+39 相加，见 PROJECT_CONTEXT 第 6 节与 C20/C21/C22。
- 计算可复现性结构完整，repo-relative 路径、seed、manifest、universe、contract、registry 齐备，Fig1 至 Fig6 6/6 可溯源，见 docs/FINAL_REPRODUCIBILITY_AUDIT.md 第 8、10、12 节。
- ML 同时给出固定 85 条件估计与 leakage-controlled strict nested 对照，并明确二者不可合并成一个 AUC，见 M15_FINALIZATION_REPORT 第 3、4 节。

## Major Concerns

### R3-M1
- **Concern ID** R3-M1
- **Severity** Major
- **Blocking** No
- **Axis** originality / claim-moderation
- **Claim pointer** PROJECT_CONTEXT.md 第 1 节把研究主身份限定为 environmental-exposure EV-enriched plasma proteomics，并明确 NOT supported as primary identity 的 biomarker discovery、predictive modeling、mechanism validation。但 ANALYSIS_PLAN_v2.1.md 第 5.1 节称 85 为 "main biomarker-development candidate pool"，第 6.1 节称 "Primary prediction task"，第 6.3 节称 Elastic Net 为 "primary multivariable prioritization model"。
- **Evidence pointer** WHOLE_PROJECT_SCIENTIFIC_REVIEW.md 第 1.1 节列出数据能回答与不能回答的问题，第 1.2 节列出不支持的身份；材料包中没有任何引言或文献对比文本（PROJECT_CONTEXT 第 9 节，稿件组装未开始）。
- **Concern** 稿件框架 R1 至 R6 的贡献边界在内部文档中是清楚的，但"环境暴露 × EV-enriched 血浆蛋白组学"相对于既有工作的增量，在任何所给文本中都没有被界定。同时项目自己的规划语言反复使用 biomarker-development 与 prediction，存在滑向 biomarker discovery 或 predictive modeling 定位的风险。在只有 1/85 正式复制、AUROC 约 0.65 的证据下，任何 biomarker 或预测定位都会超出证据。
- **Why it matters** 编辑与审稿人第一判断的就是贡献边界。一旦组装后的稿件滑向"生物标志物开发"或"预测建模"叙事，即使底层发现被克制地报告，论文也会因定位而被拒。新颖性增量相对于既有环境蛋白组学与 EV 富集工作的区分，目前完全无法评估。
- **Resolution test** 组装后的引言必须显式对比既有暴露蛋白组学与 EV-enriched 血浆工作，把贡献表述为"带确定性切分、复制层级与多方法稳健性的发现资源"，而非生物标志物或预测面板。正文不得把 biomarker development / panel / predictive accuracy 用作 headline。在稿件文本存在之前，此项标记为"不可评估，写作阶段必须控制"。

### R3-M2
- **Concern ID** R3-M2
- **Severity** Major
- **Blocking** No
- **Axis** reproducibility
- **Claim pointer** PROJECT_CONTEXT.md 第 9 节把"Final reproducibility audit"与"analysis-v2.1 freeze tag"列为未开始。docs/SOFTWARE_ENVIRONMENT_REPORT.md 记录 R 包版本钉牢为 PARTIALLY_DOCUMENTED，Python 为 NOT_DOCUMENTED。
- **Evidence pointer** docs/SOFTWARE_ENVIRONMENT_REPORT.md 的 "Package version pinning" 与 "Known environment limitations" 两节（无 renv.lock、无 sessionInfo.txt、无 requirements.txt）；docs/FINAL_REPRODUCIBILITY_AUDIT.md 第 10 节与第 17 节；raw-data 处理 P2/P3 的 documented manual step 见该审计第 3 节。
- **Concern** 结构性可复现性（相对路径、seed、manifest、universe、contract、图溯源）很强，但精确软件环境没有钉牢（R 4.3.1 的次要包版本未固定，Python 3.14.7 无 requirements），且决定最终 515 队列的样本映射包含一个人工歧义复核步骤（P2/P3）。跨机器、跨实验室的位级复现因此不被保证。
- **Why it matters** Nature 风格的计算类投稿普遍要求代码加环境锁。未钉牢的环境加上进入队列定义的人工判断，意味着 frozen 数字无法保证在另一台机器上逐位复现。这是 R3 可复现性侧重下最实质的投稿前缺口。
- **Resolution test** 随代码提交 renv.lock（或含精确包版本的 sessionInfo.txt）与 Python requirements.txt/environment.yml，并在方法节写明 P2/P3 歧义复核规则与被人工裁定的行数。在此之前，复现性只能称为"统计层面已审计"，而非"环境已钉牢"。

### R3-M3
- **Concern ID** R3-M3
- **Severity** Major
- **Blocking** No
- **Axis** reproducibility / claim-moderation（内部一致性）
- **Claim pointer** docs/FINAL_ML_RESULT_AUDIT.md 第 6.1 节称 fixed-85 的 outer_cv_metrics.csv 中 "Elastic Net is NOT in this file as an AUROC... There is no en_auroc column in outer_cv_metrics.csv"，只记录了 en_alpha。
- **Evidence pointer A** descriptive/analysis_v2.0/ml_v2.1/results/outer_cv_metrics.csv 的表头实际为 rep_id, fold, n_train, n_test, lasso_auroc, en_alpha, en_cv_auc, en_auroc, xgb_best_iteration, xgb_nrounds, xgb_auroc；15 行数据均含 en_auroc（例如 rep_id 1 fold 1 的 en_auroc 为 0.6455）。即审计文档的"无 en_auroc 列"说法与 frozen CSV 不符。
- **Evidence pointer B（同属一项一致性问题）** descriptive/analysis_v2.0/M12_pathway_v2.1/M12_FINALIZATION_REPORT.md 第 6 节称 fgsea padj<0.05 共 39 条，分桶为 GO BP=5、GO MF=6。而 PROJECT_CONTEXT.md 第 6 节、STATISTICAL_CLAIM_MAP.csv C22、docs/FINAL_REPRODUCIBILITY_AUDIT.md 第 14 节均记为 3 GO BP + 8 GO MF。总数 39 一致，但 BP/MF 分桶在两类权威文档间不一致。
- **Concern** 作者方审计叙事与其引用的 frozen 结果表之间存在两处可核验的不一致。第一处直接关系到"主模型 Elastic Net"的性能能否被报告，因为协议第 6.3 节指定 Elastic Net 为主要稀疏模型，而审计文档却称该文件没有 EN 的 AUROC。第二处关系到通路分桶计数将如何写进正文。
- **Why it matters** 审稿人与生产管线读的是 frozen CSV，不是审计叙事。如果稿件数字来自审计叙事而非从 CSV 重新推导，摘要、方法、补充材料之间会出现自相矛盾。尤其 Elastic Net 是协议指定的主要模型，其性能列是否存在必须先查清。
- **Resolution test** 所有 headline ML 与通路数字必须直接从 frozen CSV（outer_cv_metrics.csv、M12_fgsea_combined.csv）重新推导，订正审计叙事，并确认组装后的稿件数字与 CSV 一致。同时明确 en_auroc 列可用，以便按协议如实报告 fixed-85 Elastic Net 性能。此问题不推翻科学结论，但必须在稿件组装前解决。

### R3-M4
- **Concern ID** R3-M4
- **Severity** Major
- **Blocking** No
- **Axis** writing-clarity / claim-moderation（术语纪律）
- **Claim pointer** PROJECT_CONTEXT.md 术语规则要求稿件词使用 High land 与 Hot-humid，内部键只出现在 frozen 表；C04 禁止把 129 称为 external validation cohort 或 independent validation。
- **Evidence pointer** manuscript_v2_1/audit/FIGURE_TEXT_AUDIT.csv 中多条 ACTIVE/MANUSCRIPT 记录仍未替换，包括 descriptive/discovery_validation/code/figures_prospective_v2.7.R 第 194 至 199、218、233、242、472、690 至 743、875、930、1197 至 1233 行仍把 reused hold-out 标为 "Validation"，第 196 行等处仍用旧环境词 humid-hot / high-altitude；descriptive/analysis_v2.0/code/V2_M17_figures_v2.R 第 78 行仍为 "Dose-defined"。这些记录的 Proposed 动作均为 REPLACE_DISPLAY_ONLY 或 MAP_AT_DISPLAY_LAYER，即尚未执行。
- **Concern** 当前生产脚本在显示层仍把同队列 reused hold-out 渲染为 "Validation"，并使用已废弃的环境标签与 "Dose" 用语。若按现状导出 TIFF，主图 Fig1 与 Fig5 会在视觉上暗示外部验证，并使用非权威术语。
- **Why it matters** 图上的 "Validation" 是一种声称，不只是标签。它直接违反 C04 与"129 不是 external validation"这条红线。在一份整体措辞克制的稿件里，图面误标是最容易意外过度声称的地方。
- **Resolution test** 在 TIFF 导出前执行已映射的显示层替换，重出 Fig1/Fig5，并核验渲染标签读作 reused hold-out 与 High land / Hot-humid。FIGURE_TEXT_AUDIT 已给出逐行替换方案，缺口在于这些替换是待办而非已完成。

### R3-M5
- **Concern ID** R3-M5
- **Severity** Major
- **Blocking** No
- **Axis** scientific importance / interdisciplinary readership
- **Claim pointer** WHOLE_PROJECT_SCIENTIFIC_REVIEW.md 第 2 节给复制、ML、可推广性的评级分别为 Limited、Exploratory/Sensitivity、Limited，第 3 节称 85 个 DEP 的科学重量 modest；C30 声明无独立或外部队列。
- **Evidence pointer** M14_replication_hierarchy.csv（85/83/29/1）；ml_v2.1/results/outer_cv_metrics.csv（fixed-85 LASSO 中位 AUROC 约 0.65）；ml_v2.1/strict_nested/strict_nested_outer_metrics.csv（LASSO/EN 中位 AUROC 约 0.63）；REVIEWER_RISK_REGISTER R05、R06、R19、R26。
- **Concern** frozen 证据支持的是一项控制良好、报告诚实的单队列发现与稳健性研究，而不是一项突破性结果。正式复制级证据仅 1/85，ML AUROC 约 0.63 至 0.71 且无外部队列，无功能、无 EV 纯度、无细胞起源证据。广度意义因此完全取决于尚未写出的叙事能否把"环境暴露 × EV-enriched 血浆"角度立起来。
- **Why it matters** 编辑看重广度意义。一个单队列、仅 1 项正式复制、预测信号温和的工作，是扎实的领域内增量；把它框架成"突出意义"才是科学意义层面的主要风险。
- **Resolution test** 组装后的讨论必须如实量化已证与未证（1/85 为正式复制上界、ML 为条件分析、无外部队列），并通过研究设计（确定性切分、复制层级、strict nested 对照、三方法通路三角验证）来支撑新颖性，而非夸大效应量。在稿件存在之前此项不可评估。

## Minor Comments

### R3-m1
- **Concern ID** R3-m1
- **Severity** Minor
- **Axis** claim-moderation
- **Affected element** ML 补充图中 Boruta 分支
- **Evidence pointer** docs/FINAL_ML_RESULT_AUDIT.md 第 3 节，boruta_full_data.csv 显示 85/85 Confirmed，frac_beat_shadow=1.0，padj=2.98e-08。
- **Issue** 在预选 DEP 集上，shadow 检验没有区分力，"全部 85 通过"不携带任何优先级信息。
- **Required correction** Boruta 只作为"通过健全性检查"的标注呈现，绝不可画成"选出的特征数"。

### R3-m2
- **Concern ID** R3-m2
- **Severity** Minor
- **Axis** figures-and-tables / claim-moderation
- **Affected element** R6 通路主题呈现
- **Evidence pointer** M12_FINALIZATION_REPORT.md 第 10.2 节，integration/M12_pathway_redundancy_clusters.csv（greedy Jaccard>0.5）；REVIEWER_RISK_REGISTER R14。
- **Issue** 195 条 cameraPR 结果中 170 条来自 Reactome，冗余度高；直接报 195 会放大通路发现。
- **Required correction** 正文只报代表性 GO-BP 与核心 Reactome 簇，完整 195 条放补充，绝不把 195+23+39 相加。

### R3-m3
- **Concern ID** R3-m3
- **Severity** Minor
- **Axis** claim-moderation
- **Affected element** 方法节通路数据库描述
- **Evidence pointer** C23（KEGG NOT_RUN）；M12_02b_kegg_fix.R；ora 与 ranked 下的 KEGG CSV 为占位行。
- **Issue** KEGG 因资源缺口未运行，必须显式说明，不能让读者以为做了三套数据库。
- **Required correction** 方法节写明仅做 GO 与 Reactome，KEGG 未运行及原因。

### R3-m4
- **Concern ID** R3-m4
- **Severity** Minor
- **Axis** readability for nonspecialists
- **Affected element** Fig1 与方法节的 universe 分母
- **Evidence pointer** docs/FINAL_REPRODUCIBILITY_AUDIT.md 第 14 节（明确区分 1430 abundance Q515、1434 pathway-tested、1414 mapped）；universes/Q515.csv；mapping/M12_gene_mapping_summary.csv（1414）；D01 的 1445 discovery-eligible。
- **Issue** 存在四个相近分母（1430、1434、1445、1414），跨学科读者极易混淆。
- **Required correction** 在 Fig1 或方法节给一张显式 universe 图，列出四个分母及其各自差异原因。

### R3-m5
- **Concern ID** R3-m5
- **Severity** Minor
- **Axis** writing-clarity / claim-moderation
- **Affected element** 暴露类别用语与 R2 背景叙事
- **Evidence pointer** REVIEWER_RISK_REGISTER R07 与 R21；M05_manifest.csv（n_AE_FDR_lt_0.05=0）；FIGURE_TEXT_AUDIT 中 V2_M17_figures_v2.R 第 78 行 "Dose-defined"。
- **Issue** "dose" 用语与整体暴露家族为零结果之间需要解释，否则读者会困惑为何主对比是 High-vs-Low。
- **Required correction** 统一改用 exposure category，不用 dose response；在 R2 说明整体暴露零结果为何引出 High-vs-Low 对比。

### R3-m6
- **Concern ID** R3-m6
- **Severity** Minor
- **Axis** reproducibility（内部一致性）
- **Affected element** 权威入口文档与最终审计文档的状态表述
- **Evidence pointer** PROJECT_CONTEXT.md 第 9 节把 "Final reproducibility audit" 列为未开始；docs/FINAL_REPRODUCIBILITY_AUDIT.md 署期 2026-09-29，结论为 PASS_WITH_LIMITATIONS 与 READY_TO_TAG_WITH_LIMITATIONS。
- **Issue** 权威入口称最终可复现性审计未开始，但一份最终审计文档已经存在并建议打 tag。二者必有一处过时。
- **Required correction** 对齐两处表述，明确 2026-09-29 那份审计是否即为最终 pre-freeze gate，以及 freeze tag 是否已打。

## Technical failings that need to be addressed before the case is established

1. R3-M3，先从 frozen CSV 重新推导 ML 与通路 headline 数字，订正审计叙事，尤其查清 fixed-85 en_auroc 列的可用性。
2. R3-M2，补环境锁（renv.lock 或 sessionInfo、Python requirements），并在方法节交代 P2/P3 人工复核。
3. R3-M4，在 TIFF 导出前完成显示层标签替换，消除图面 "Validation" 与旧环境词。

以上三项均为稿件组装前的必做动作，不改变已冻结的科学结论。

## Assessment against Nature-style criteria

- **Originality** 在所给材料中不可评估，因无引言与文献对比文本。研究设计层面（确定性前瞻切分、reused-hold-out 复制层级、strict nested 对照、三方法通路三角）在方法学上是谨慎的。
- **Scientific importance** 依 frozen 数字判断为领域内扎实增量，广度意义有限，受限于 1/85 正式复制、无外部队列与无功能证据。
- **Interdisciplinary readership interest** 环境暴露 × 血浆 EV 交叉角度有潜在广度，但取决于尚未写出的叙事。
- **Technical soundness** 统计纪律自觉（prespecified FDR 家族、候选先锁后用），但环境未钉牢，且存在审计文档与 frozen 表的不一致。
- **Readability for nonspecialists** 当前内部键密集（M05 至 M17、D01 至 D10、Q515/Utech、1430/1434/1445/1414 四个分母），需要一张清晰的 universe 图与叙事主线才能让非本领域读者跟上。

## Recommendation posture

我不代表编辑做最终决定，也不断言该稿是否属于某刊。基于 frozen 证据，这是一项边界诚实、控制良好的单队列发现与稳健性研究，目前尚不具备投稿就绪状态，因为稿件正文未组装、freeze tag 未打、图面标签替换待执行、环境未钉牢。若作者在组装稿件时维持声称映射表已强制的克制措辞，解决 R3-M3 的审计不一致，钉牢运行环境，并通过研究设计而非夸大效应量来框定新颖性，则它会成为一篇可信的、适合领域内合适期刊的投稿；它能否达到 Nature 风格的广度意义门槛，属于编辑判断，且取决于尚未写出的叙事与 EV/环境新颖性定位，我无法从本材料包评估。

## Risk / unsupported claims

- 新颖性相对于既有工作的增量在所给材料中无任何文献对比支撑，标记为不可评估，未做任何 prior-work 区分的臆断。
- 我未读到组装后的摘要、引言、讨论或图注，行文层面的 overclaim 仅能从作者方自审文档与图面 audit 记录推断，不能替代对真实正文的读审。
- R3-M3 的两处不一致基于 frozen CSV 与审计文档的直接比对，结论以 CSV 为准。
- 本报告未推测 R1、R2 的任何意见，也未与其对齐。
