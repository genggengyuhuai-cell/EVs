# 审计总报告 — F:\env（环境暴露 × EV-enriched 血浆蛋白组学研究，analysis-v2.1）

> 本文件是 8 技能 × 全仓库静态审计的总入口。各维度独立报告见第 9 节产物清单。
> 审计方式：纯静态只读。未运行任何项目分析脚本、未运行任何技能包执行管线（delivery_guard / analysis_toolkit / final_facts 等一律未运行）、未修改 F:\env 任何既有文件。所有数字均逐字引自 F:\env 内文件原文并标注出处。
> 权威基线：F:\env\PROJECT_CONTEXT.md（frozen 数字与术语规则）。本审计不推翻任何 frozen 数字，只报告"仓库内文档/结果表与权威基线之间的一致性"。

---

## 1. 审计说明

- 审计对象：`F:\env` 全仓库（协议 docs/protocol/、分析模块 descriptive/、图表 descriptive/figures_nature_v2.2 与 analysis_v2.0/figures_final_v2、数据链路 rawdata/ 与 code/P1-P3、作者方自审 manuscript_v2_1/audit/ 与 docs/ 下 AUDIT/REVIEW/REPORT）。
- 稿件状态：尚无组装好的稿件正文（manuscript_v2_1 下仅有 audit/ 文件；PROJECT_CONTEXT 第 9 节确认稿件组装、freeze tag、最终可复现性审计均未开始）。因此"稿件声称"的审计对象是作者方自审文档、协议与 frozen 结果表中的声称结构，正文行文层不可审读——所有维度均已标注此边界。
- 方法：8 个技能各派独立子代理管线并行审计（nature-statistics、nature-reviewer〔3 位互盲审稿人 + 独立跨审综合〕、nature-figure、experimental-design、statistical-power、doubao-data-analysis〔仅用其分析原则，未运行其脚本〕、doubao-human-signal〔诊断模式，不改写〕、researchwrite）。每个维度独立判定，与作者方既有自审对照但不照抄。
- 本次整合对个别子代理的表述做了两处事实修正（见 §3 共识发现 2 与 §4-设计 处的 GZ_TH 数字），其余照录。

## 2. 执行摘要（最高信号结论）

**总体判定：统计 frozen 数字（519→515→386/129、85/83/29/1、0/1,430、195/23/39 总数、KEGG NOT_RUN、1434/1414/15/5）在结果表层面基本一致（数据链路维度逐项对账约 30 项，28 项一致、0 项无出处、2 项分项不一致）；写作层未发现肯定性越界声称（85≠validated、129≠external validation 等禁用措辞在仓库内几乎全部只出现在"禁止列表"或"NOT supported"条款中）。但存在一组尚未闭合的阻断级问题，在闭合前该仓库对外呈现两种相互矛盾的就绪状态，通路与 ML 结论不宜作为冻结证据进稿件。**

跨维度共识（≥2 条独立管线或本次整合复核确认）的最重要发现：

1. **站点 × 进样日近完全共线，环境主效应与技术/采集批次不可分离**（设计 Z1；审稿 R1-M2、R2-M1〔Blocking〕；链路、图表均有旁证）。9 个站点中两大站点 XZ_GG（142 例，30/66/46，M11_site_composition.csv:6）与 GZ_TH（123 例，46/31/46，M11_site_composition.csv:5）分别集中在单一进样日 20260527 与 20260717，合计占 515 例的约 51%；8 个 MS 批次中 6 个为单一环境纯批；2025 与 2026 批检出中位数相差约 200–400 蛋白；主模型无批次协变量、无 pooled QC 校正。85 个 DEP 的暴露关联在测量层面无法与采集批次分离。
2. **fgsea 通路分项口径双轨并存，仓库未声明哪列为 frozen**（统计 F-01、链路 M1、审稿 R3-M3）。本次整合复核 `M12_fgsea_combined.csv`：`padj`（家族内 BH-FDR）给出 GO BP 3 / MF 8 / CC 11 / Reactome 17（=39，与 PROJECT_CONTEXT 第 6 节、STATISTICAL_CLAIM_MAP C22、FINAL_REPRODUCIBILITY_AUDIT 一致）；`padj_pooled`（跨家族合并 BH）给出 5 / 6 / 11 / 17（=39，与 M12_FINALIZATION_REPORT 第 6 节一致）。总数 39 恒稳，但两列口径在权威文档与终稿报告之间各取其一，未声明。
3. **复现就绪状态自相矛盾，claim 映射未随之降级**（链路 B2〔Blocking〕、写作 B1〔Blocking〕）。`docs/FINAL_REPRODUCIBILITY_AUDIT.md`（2026-09-29）称 READY/no blockers（§18 等处）；`docs/P0_P1_REPAIR_PLAN.md`（2026-09-30）第 10、20、257 行称冻结被阻断（4 个 P0 + 8 个 P1 全部确认，Freeze_readiness_score=1/10，且第 142 行明确点名"FINAL_REPRODUCIBILITY_AUDIT 声称 RERUN_READY 与无阻断，与已确认的 P0/P1 发现相矛盾"）。STATISTICAL_CLAIM_MAP 中 C16–C22 等仍标 REWORD/SAFE，未降级。
4. **M12 通路主线当前代码不可复现（P0-3）**（链路 B1〔Blocking〕）。`M12_01_mapping.R` 第 15–17 行仍以 `nrows=0` 读取 PRIMARY 矩阵，`tested_prots` 实际为空；195/23/39 与 1434/1414/15/5 无法由当前主线代码重建。P0-4（canonical M12 链与 KEGG NOT_RUN 冲突）一并确认。
5. **发现族分母错配**（链路 M3、审稿 R1-M3、写作 M2；本次整合复核 D01_manifest 记录 raw 3817 / eligible 1445）。`STATISTICAL_CLAIM_MAP.csv` C05 行写 N=1430、证据指针 "M03/M05 D03"（M03 模块在仓库不存在），而 85 的 BH-FDR 族应为 1,445（Discovery-eligible）。
6. **ML 审计叙事与 frozen CSV 矛盾**（审稿 R3-M3；本次整合复核 `ml_v2.1/results/outer_cv_metrics.csv` 表头确含 `en_auroc` 且 15 行有值）。`docs/FINAL_ML_RESULT_AUDIT.md` 第 6.1 节称该 CSV 无 `en_auroc` 列。
7. **无 contaminant/decoy 鉴定质控记录**（审稿 R2-M2〔Blocking〕）。导出仅 7 个注释字段，无 contaminant/decoy 标记，PG.Qvalue / PG.CV 口径未建立，1,445 个可入组蛋白的鉴定假阳性与污染物残留无法核验。
8. **功效/可检测效应空白**（功效 MAJOR-1/2、审稿 R1-M1）。全仓库无 a priori 功效分析、无 MDE 量化；观测性研究豁免先验功效合理，但豁免理由与"可检测效应边界"未正面写出；129 留出集灵敏度/特异度精度局限（STUDY_DESIGN_AUDIT.md:103）未进入局限清单。正面：全仓库未发现 post-hoc/observed power 误用。
9. **材料身份文档冲突**（设计；本次整合复核 `STUDY_DESIGN_AUDIT.md` 第 18 行）。该行写 "Plasma, not EV-enriched plasma"，与 PROJECT_CONTEXT 第 1 节 "EV-enriched plasma proteomics" 冲突。
10. **写作层正面结论**（写作审计、AI味诊断）。全仓库 "validated / external / causal / biomarker / signature" 命中几乎全部位于禁用词表或 "NOT supported" 条款中，未发现肯定性越界声称；"删除胜于解释"执行良好；22 份叙述性文档 AI 味指数全部落在 8–25（中位约 14），整批不需要大改。

## 3. 分级发现清单（跨维度合并去重）

> 合并规则：同一底层问题被多条管线独立发现时合并为一条，标注涉及管线与各自发现 ID。证据指针为文件+位置。

### 3.1 阻断级（Blocking，5 条底层问题）

| ID | 底层问题 | 证据指针 | 涉及管线（发现 ID） |
|---|---|---|---|
| BLK-1 | 站点 × 进样日近完全共线，环境效应与批次不可分离；主模型无批次协变量、无 pooled QC 校正 | `descriptive/analysis_v2.0/M11_site_robustness/M11_site_composition.csv:5-6`（GZ_TH 46/31/46=123、XZ_GG 30/66/46=142）；`descriptive/group_by_MS_batch_proxy_by_TREAT1_counts.csv`；`descriptive/进样时间_*.csv` | 设计 Z1；审稿 R1-M2、R2-M1；图表旁证 |
| BLK-2 | 无 contaminant/decoy 鉴定质控；导出注释字段仅 7 个；PG.Qvalue/PG.CV 口径未建立 | 结果导出文件列结构（D 系列与 M 系列蛋白表头）；作者方审计自评 MAJOR（WHOLE_PROJECT_SCIENTIFIC_REVIEW.md） | 审稿 R2-M2 |
| BLK-3 | M12 通路主线不可复现（P0-3：`nrows=0`）；195/23/39 与 1434/1414/15/5 无当前代码可重建；P0-4 未闭合 | `descriptive/analysis_v2.0/M12_pathway_v2.1/code/M12_01_mapping.R`（若该路径不符以 docs/P0_P1_REPAIR_PLAN.md 第 51-68 行为准）；`docs/P0_P1_REPAIR_PLAN.md:51-68` | 链路 B1；统计 F-02 旁证 |
| BLK-4 | 复现审计状态矛盾：09-29 READY vs 09-30 BLOCKED(1/10)；claim map C16-C22 未降级 | `docs/FINAL_REPRODUCIBILITY_AUDIT.md`（09-29）；`docs/P0_P1_REPAIR_PLAN.md:10,20,142,257`（09-30）；`manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` C16–C22 | 链路 B2；写作 B1；审稿 R3-M3 旁证 |
| BLK-5 | P0/P1 修复仅 ML Phase 1 闭合（P0-1/P0-2 已修），M12/严格嵌套/M09/M11 与既有审计/控制文档未闭合 | `docs/P0_P1_REPAIR_PLAN.md:29-45`（P0-1/P0-2 修复记录）与第 257 行（仍 BLOCKED）；`docs/P0_P1_RERUN_PLAN.csv` | 链路 B3 |

### 3.2 重大级（Major，合并后 14 条）

| ID | 问题 | 证据指针 | 涉及管线 |
|---|---|---|---|
| MAJ-1 | fgsea 分项双口径并存未声明（padj 3/8 vs padj_pooled 5/6，总数 39 恒稳） | `M12_pathway_v2.1/ranked_gsea/M12_fgsea_combined.csv`（两列并存）；`PROJECT_CONTEXT.md` 第 6 节 vs `M12_FINALIZATION_REPORT.md` 第 6 节 | 统计 F-01；链路 M1；审稿 R3-M3 |
| MAJ-2 | claim C05 发现族分母错配（1430 vs 1445），证据指针指向不存在的 M03 | `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv:6`；`D01_discovery_eligibility/D01_manifest.txt`（eligible 1445） | 链路 M3；审稿 R1-M3；写作 M2 |
| MAJ-3 | M14_frozen_status 陈旧（Pathway NOT_RUN、ML M15 NOT_STARTED）与既有产物矛盾 | `descriptive/analysis_v2.0/M14_frozen_replication/M14_frozen_status.csv:3-4` | 统计 F-02；链路 M2；审稿 R1-m2 |
| MAJ-4 | ML 审计叙事称 outer_cv_metrics 无 en_auroc 列，CSV 实际有 | `descriptive/analysis_v2.0/ml_v2.1/results/outer_cv_metrics.csv`（表头含 en_auroc）；`docs/FINAL_ML_RESULT_AUDIT.md` 第 6.1 节 | 审稿 R3-M3 |
| MAJ-5 | 材料身份文档冲突：STUDY_DESIGN_AUDIT 写 "Plasma, not EV-enriched" | `docs/protocol/STUDY_DESIGN_AUDIT.md:18` vs `PROJECT_CONTEXT.md:14-18` | 设计；审稿 R3 风险节 |
| MAJ-6 | 协议层身份滑移：ANALYSIS_PLAN_v2.1 反复用 biomarker-development / panel table；DISCOVERY_VALIDATION_PROTOCOL §8 用 "independent Validation participants" | `docs/protocol/ANALYSIS_PLAN_v2.1.md`（biomarker 词条）；`docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md` §8 | 写作 M3；审稿 R3-M1 |
| MAJ-7 | 全仓库无 a priori 功效/MDE；豁免理由与可检测效应边界未正面写出 | 全仓库关键词检索（power/sample size/MDE 零命中）；`manuscript_v2_1/audit/STATISTICAL_REPORTING_AUDIT.md` 提及 underpowered | 功效 MAJOR-1/2；审稿 R1-M1 |
| MAJ-8 | M10 交互检验可识别性受限：环境对比完全跨站点（9 站不重叠），2-df 交互混淆站点异质性与环境修饰；"未通过阈值"不可读为排除修饰效应 | `descriptive/analysis_v2.0/M10_environment_interaction/`；`docs/protocol/ANALYSIS_PLAN_v2.1.md` | 审稿 R1-M2；设计 |
| MAJ-9 | M17 主图 Fig6 通路整合缺 Reactome 主臂（cameraPR 195 中 170 为 Reactome，主图仅 8 条 GO-BP） | `descriptive/analysis_v2.0/figures_final_v2/`（Fig6 面板）；`PROJECT_CONTEXT.md` 第 6 节 | 图表 M1-1 |
| MAJ-10 | 生产脚本/图面标签执行未闭合：figures_prospective_v2.7 生产脚本与 FIGURE_TEXT_AUDIT 多条 ACTIVE 记录仍标 "Validation"/"Dose"/旧环境词（渲染层 SVG 已修复，属正面） | `descriptive/discovery_validation/code/figures_prospective_v2.7.R`；`manuscript_v2_1/audit/FIGURE_TEXT_AUDIT.csv`（ACTIVE 记录） | 图表 m-2；审稿 R3-M4 |
| MAJ-11 | Fig1 universe 漏斗 1,430→1,445 非单调且图注未解释（"全队列定量宇宙"vs"Discovery 子集合格"两套规则） | `descriptive/analysis_v2.0/figures_final_v2/Fig1*`（source csv 与图注） | 图表 m-2 |
| MAJ-12 | 前分析协变量结构性缺失：~80% Unknown；Tube_Mixing "Insufficient" 随暴露级单调上升（4.6%→7.5%→13.1%）；全库无 MS 进样顺序随机化记录 | `descriptive/design_confounding_tables.xlsx`；`descriptive/condition_by_TREAT1_*.csv`；P1/P2/P3 代码 | 设计 Z2/Z3 |
| MAJ-13 | 环境/软件版本未钉牢：无 renv.lock / sessionInfo / 依赖固定；M05-M11 manifest 未集中登记 R 包版本（仅 M12 有） | `docs/SOFTWARE_ENVIRONMENT_REPORT.md`；`analysis_v2.0/` 各模块 manifest | 审稿 R3-M2；统计 F-03；链路 |
| MAJ-14 | M10 父子 manifest 交互显著数 1034 vs corrected 0 并存，未注明口径关系（父表 1430 行中 1034 个 BH<0.05 与 corrected 0/1,430 为不同分析） | `analysis_v2.0/M10_environment_interaction/`（父 manifest 与 corrected_pure_interaction 子目录） | 链路 M4；统计 |

### 3.3 次要与提示级

完整清单见各维度报告。合并后代表性次要问题：Nature Reporting Summary 所需的单双侧声明、randomization/blinding=n/a 声明缺失（统计 F-04/F-05）；F/残差 df 未在稿件层呈现（统计 F-06）；prospective 600 dpi TIFF 超出 Extended Data 300 dpi 指引、约 35/57 图缺配对 source CSV（图表）；GZ_TH 在审稿报告 R2 概述写 129 而表中合计为 123（指针精度小出入，跨审综合已记录，本整合采用 123）；519→515 的 4 例排除原因未定位（链路 m3）；跨 8 份审计文档逐字复用同一免责开场模板（AI味诊断，提示级）。

## 4. 按维度分类结果

### 4.1 统计报告审计（nature-statistics）→ `01_statistics/statistics_audit.md`
- 范围：协议 ×6、frozen 结果表 M05–M14/ml_v2.1/D01–D10、作者方统计自审、图注统计声称。
- 独立判定：frozen 主数字（515/386/129、85/83/29/1、0/1,430、195/23、KEGG NOT_RUN、8–618 稳定性、Boruta-style、ML conditional）与既有自审完全一致；新增 fgsea 分项不一致（F-01）、M14_frozen_status 陈旧（F-02）及 Nature Article 初始投稿清单缺口（软件版本、单双侧、randomization/blinding、F+df）。
- 发现：0 阻断 / 2 重大 / 4 次要 / 3 提示。
- 安全措辞要点与边界：见报告 §4/§5。

### 4.2 模拟同行评审（nature-reviewer，3 位互盲 + 跨审综合）→ `02_reviewer/reviewer_R1.md`、`reviewer_R2.md`、`reviewer_R3.md`、`reviewer_synthesis.md`
- 互盲保证：3 位审稿人为独立子代理上下文，各自只收到同一不可变材料包与各自 emphasis brief，报告冻结后才由独立综合 pass 合并。综合共识仅在 ≥2 位审稿人独立提出同一底层关切时标注。
- R1（统计与设计，emphasis）：0 Blocking / 5 Major / 6 Minor。关注：hold-out 无功效论证、交互×站点混杂、发现族分母 1430 vs 1445。
- R2（技术可靠性，emphasis）：2 Blocking（R2-M1 站点×进样日共线；R2-M2 无 contaminant/decoy QC）/ 4 Major / 6 Minor。
- R3（意义与可复现，emphasis）：0 Blocking / 5 Major / 6 Minor。关注：ML 审计与 CSV 矛盾、环境未锁定、图面 "Validation" 标签未替换。
- 跨审综合：共识阻断 0 项（仅 R2 标阻断、无第二位审稿人独立同调）；共识重大关切 7 组（复制层级弱、分母错配、ML 接近随机且叙事矛盾、环境未锁定、EV 纯度缺失、通路不可相加、审计与 frozen 表不一致）；跨审分歧在于严重度权重（R2 上调测量/鉴定层，R1 独有交互可识别性，R3 独有定位与图面执行风险）。

### 4.3 图表审计（nature-figure）→ `03_figures/figures_audit.md`
- 范围：figures_nature_v2.2（193 文件）、figures_final_v2（30 文件）、figures_prospective_v2.7、既有 PROVENANCE_AUDIT/FILE_MAP/FIGURE_TEXT_AUDIT。
- 独立判定：独立 Grep SVG 渲染文本（非 PDF 抽取）复核——渲染层已无 Validation/Humid-hot/High-altitude，正向 "Reused hold-out / High land / Hot-humid" 在位，Fig5 主动写 "NOT external validation"；冻结数字全部勾稽一致（519→515、153/186/176、386/129、85/83/29/1、交互箱 140+399+427+464=1,430、站点合计 515，无 195+23+39 求和）。
- 发现：0 阻断 / 1 重大（Fig6 缺 Reactome 主臂）/ 4 次要 / 5 提示。
- 新增项（既有审计未覆盖）：Fig1 漏斗非单调、交互分母双口径（0/85 vs 0/1,430 需分别写受测集合）、约 35/57 图缺配对 source CSV、600 dpi TIFF 超限、Python/R 后端混合。

### 4.4 研究设计审计（experimental-design）→ `04_design/design_audit.md`
- 范围：STUDY_DESIGN_AUDIT、协议 ×5、设计表（design_A/B/C、region_environment_counts、MS_batch_proxy、进样时间等）、样本映射链路、作者方 EXPERIMENTAL_DESIGN_REVIEW。
- 独立判定：既有 review 主线判断正确；三处实质增量——(a) 环境↔采集时代从"部分混杂"定量升级为"近乎别名"（8 批中 6 批单一环境纯批）；(b) 与暴露同向的前分析梯度 + 年龄/性别协变量结构性缺失；(c) 材料身份文档口径冲突（STUDY_DESIGN_AUDIT.md:18 "Plasma, not EV-enriched plasma"）。
- 发现：0 阻断 / 5 重大 / 4 次要 / 3 提示。
- 站点数字（本次整合复核）：XZ_GG 142（30/66/46）、GZ_TH 123（46/31/46），M11_site_composition.csv:5-6。

### 4.5 功效/样本量审计（statistical-power）→ `05_power/power_audit.md`
- 范围：全仓库关键词检索（power/sample size/MDE/detectable/sensitivity 等）+ 协议 + 敏感性模块 + 既有自审。
- 独立判定：无 a priori 功效、无 MDE（双重空白，既有自审只说 underpowered 未说"可检测效应边界缺失"）；1,445/1,430/85 多重比较族规模对功效的压缩未与功效显式连接；129 留出集精度局限未提升至局限清单；术语冲突（"sensitivity analysis"已被缺失值/站点稳健性占用）；正面——无 post-hoc/observed power 误用。
- 发现：0 阻断 / 2 重大 / 3 次要 / 3 提示。

### 4.6 数据链路与可复现性审计（doubao-data-analysis 原则，静态）→ `06_data_chain/data_chain_audit.md`
- 范围：frozen 数字对账（约 30 项）、上游 P1/P2/P3→sample_mapping_FINAL 链路、代码-数据-产物链、P0/P1 修复完整性、claim→evidence 抽查。
- 独立判定：对账 28 项一致 / 0 项无出处 / 2 项分项不一致（fgsea BP/MF）；519 初始队列出处确认（P1 代码"all 519 samples are uniquely and safely mapped"）；ML fixed-85 15 折、strict nested 1434/8–618 确认；P0-1/P0-2 已修、P0-3/P0-4 未闭合。
- 发现：3 阻断 / 4 重大 / 3 次要 / 3 提示。

### 4.7 AI 味诊断（doubao-human-signal，诊断模式）→ `07_human_signal/human_signal_audit.md`
- 范围：22 份叙述性/报告类 .md 全读。
- 独立判定：全部文档 AI 味指数 8–25（中位约 14），无一份达中等 AI 味；唯一真实模板指纹是 8 份审计文档逐字复用同一免责开场模板；两份 ML 兄弟审计共享同一"Git/process check"尾节；科研审计体裁的"客观工整"未误判为 AI 味；所有风险限定句（not causal/not biomarker 等）全部保留，未建议删改。
- 发现：0 阻断 / 2 重大 / 3 次要 / 3 提示。整批不需要大改。
- 边界：CSV/脚本/图内文字、docs/protocol/ 未评。

### 4.8 科研写作质量审计（researchwrite）→ `08_researchwrite/researchwrite_audit.md`
- 范围：论证/声称载体（claim map、module map、科学自审、重建计划、图文本审计）+ 报告类 + 协议。
- 独立判定：R1-R6 论证链整体连贯；主张强度核查正面（无肯定性越界声称）；阻断项为 claim→evidence 映射未被 P0/P1 推翻事件同步降级（C16–C22 仍标 SAFE/REWORD）；C05 分母错配 + 指针指向不存在的 M03；身份滑移（v2.1 协议 biomarker 措辞、验证协议 "independent Validation participants"）；"删除胜于解释"执行良好。
- 发现：1 阻断 / 4 重大 / 3 次要 / 2 提示。

## 5. 可进入稿件的安全措辞要点（跨维度汇总）

1. 队列/样本：**"initial cohort of 519 individuals; final analytical cohort of 515 (153 Control / 186 Low / 176 High exposure); a prospectively defined deterministic split (seed 20260925) yielded a Discovery subset of 386 and a reused within-cohort hold-out of 129 (not an external or independent validation)"**。
2. Discovery：**"85 proteins were differentially abundant in the High-versus-Low comparison at BH-FDR < 0.05 across 1,445 Discovery-eligible proteins"**（族分母用 1,445；不得写 85 validated proteins）。
3. 复制层级：**"of the 85, 83 showed concordant direction; 29 replicated at nominal P < 0.05 and 1 survived a candidate-family BH-FDR control on the reused hold-out; the hold-out shares the cohort and cannot provide independent validation"**。
4. 交互：**"No interaction survived the prespecified BH-FDR threshold (0/1,430)"**；不得写 "there was no interaction"；不得把环境分层 concordance 称为交互检验。
5. ML：**"predictive performance is conditional on the frozen 85-protein discovery panel; the fold-local DEP count range (8–618) in the strict nested sensitivity reflects feature-selection instability, not biological heterogeneity"**；XGBoost importance 为描述性、选后、非因果。
6. 通路：**"cameraPR identified 195 FDR-significant pathways (25 GO BP + 170 Reactome; primary), ORA 23 (3 GO BP + 20 Reactome; complementary), fgsea 39 (sensitivity); these three methods answer different questions and are not summed; KEGG was not run"**。fgsea 分项需先裁定并声明使用 padj 还是 padj_pooled 口径（当前仓库双轨并存，见 MAJ-1）。
7. 稳健性：**"site leave-one-out analyses are robustness checks, not replication or external validation"**。
8. 材料身份：**"EV-enriched plasma proteomics (not a pure EV proteome); co-isolated plasma proteins and preanalytical effects are acknowledged limitations"**。同时修正 STUDY_DESIGN_AUDIT.md:18 的口径冲突。
9. 术语：稿件一律用 High land / Hot-humid；High-pressure/high-altitude、Humid-hot、Short/Long dose 仅限 frozen 结果表。
10. 功效/阴性：观测性研究不作先验功效的豁免理由 + 可检测效应边界（MDE）需正面写一句；0/1,430 与 1/85 只能按"未检出/未生存阈值"解释。

## 6. 未覆盖/无法判定的边界（跨维度汇总）

- 稿件正文尚不存在：正文行文、引言/讨论定位、overclaim 的文本层判定不可评估（所有管线已标注）。
- 未运行任何统计复算/脚本（用户明确要求只静态审计）：MDE 数值、鉴定假阳性率、批次方差分解/ICC/DEFF 等需统计合作者补算。
- 未逐行通读大文件：ANALYSIS_PLAN_v2.0（84KB）、STUDY_DESIGN_AUDIT（88KB）、V2_IMPLEMENTATION_GAP_AUDIT（43KB）仅定向检索；M05–M11/M12B/M17 R 脚本未逐行通读。
- 图像本体：未做 183 mm 物理尺寸逐面板目视（色阶/碰撞/色盲模拟）；图上文字 vs source CSV 逐字一致性基于 SVG 文本层与 CSV 核验。
- 上游 xlsx 大矩阵（processed.xlsx/rawdata.xlsx）未逐格读；519→515 的 4 例排除规则在所审文件中未定位。
- figures_nature_v2.2 嵌套的 10 个生产者目录（约 456 文件）未逐一审计（既有 PROVENANCE_AUDIT 生产者层覆盖）。
- 正式 Figure legend、Methods prose、Reporting Summary 尚未撰写，相关合规项（单双侧声明、软件版本登记等）为"待办"而非"已违规"。
- 历史冻结层（archive/、docs/archive/）未深读。

## 7. 产物清单

| 维度 | 报告路径 |
|---|---|
| 总入口（本文件） | `F:\env\audit_output\AUDIT_REPORT_INDEX.md` |
| 1 统计报告审计 | `F:\env\audit_output\01_statistics\statistics_audit.md` |
| 2 审稿人 R1 / R2 / R3 / 跨审综合 | `F:\env\audit_output\02_reviewer\reviewer_R1.md`、`reviewer_R2.md`、`reviewer_R3.md`、`reviewer_synthesis.md` |
| 3 图表审计 | `F:\env\audit_output\03_figures\figures_audit.md` |
| 4 研究设计审计 | `F:\env\audit_output\04_design\design_audit.md` |
| 5 功效/样本量审计 | `F:\env\audit_output\05_power\power_audit.md` |
| 6 数据链路与可复现性审计 | `F:\env\audit_output\06_data_chain\data_chain_audit.md` |
| 7 AI 味诊断 | `F:\env\audit_output\07_human_signal\human_signal_audit.md` |
| 8 科研写作质量审计 | `F:\env\audit_output\08_researchwrite\researchwrite_audit.md` |

---

*审计日期：2026-10-01。全程只读，未改动 F:\env 任何既有文件；唯一新写内容为本 audit_output/ 目录。术语按 PROJECT_CONTEXT 措辞规则。*
