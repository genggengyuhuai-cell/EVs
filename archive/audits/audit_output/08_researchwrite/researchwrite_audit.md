# 科研写作质量审计（researchwrite）

> 审计视角：researchwrite revise / QA 模式（论证先于章节、证据先于文字、契约先于段落、不自动升级事实、删除胜于解释）。
> 审计方式：只读静态审计。未运行任何分析、未修改 `F:\env` 任何既有文件。
> 所有数字逐字引自 `F:\env` 内文件原文并标注出处。
> 审计日期：2026-10-01。

---

## 1. 审计范围与材料

### 1.1 被审对象（全部只读）

| 类别 | 文件 |
|---|---|
| 权威入口 / frozen 边界 | `F:\env\PROJECT_CONTEXT.md` |
| 论证 / 声称载体 | `manuscript_v2_1\audit\WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`、`PROJECT_RECONSTRUCTION_PLAN.md`、`MANUSCRIPT_MODULE_MAP.csv`、`STATISTICAL_CLAIM_MAP.csv`、`REVIEWER_RISK_REGISTER.csv`、`FIGURE_TEXT_AUDIT.csv`、`FIGURE_TEXT_STANDARDIZATION_REPORT.md` |
| 报告类 | `docs\FINAL_REPRODUCIBILITY_AUDIT.md`、`FINAL_ML_RESULT_AUDIT.md`、`ML_ALGORITHM_INTERSECTION_AUDIT.md`、`P0_P1_REPAIR_PLAN.md`、`PATHWAY_FIGURE_INVENTORY_AUDIT.md`、`FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md` |
| 协议（论证源头） | `docs\protocol\ANALYSIS_PLAN_v2.1.md`、`DISCOVERY_VALIDATION_PROTOCOL.md`、`DISCOVERY_VALIDATION_SPLIT_SPEC.md` |

审计中顺带通读了同目录 `STATISTICAL_REPORTING_AUDIT.md`（`PROJECT_CONTEXT.md` §10 列为权威控制文档），因其是 claim→evidence 措辞的直接对照物。

### 1.2 判定基准（frozen 边界，来自 `PROJECT_CONTEXT.md`）

- 身份：environmental-exposure **EV-enriched plasma proteomics**；NOT biomarker discovery / predictive modeling / mechanism validation（`PROJECT_CONTEXT.md` §1）。
- 队列：519 → 515（153 Control / 186 Low / 176 High）；Discovery 386；reused hold-out 129（NOT external/independent）（§2）。
- 复制层级：85 → 83 direction-concordant → 29 nominal → 1 candidate-family FDR（§5）。
- 交互：0/1,430 survived BH-FDR；措辞必须为 "No interaction survived the prespecified BH-FDR threshold."（§5）。
- ML：fixed-85 conditional（非无偏泛化）；strict nested 8–618 = 特征选择不稳定（§5）。
- 通路：cameraPR 195 / ORA 23 / fgsea 39 三方法不可相加；KEGG NOT_RUN（§6）。
- 术语：稿件用 High land / Hot-humid；内部键 High-pressure/high-altitude、Humid-hot、Short/Long dose 只出现在 frozen 结果表（§首注释）。

---

## 2. 独立判定

### 2.1 论证链评估（R1–R6 是否连贯、每节主张是否有证据）

`PROJECT_CONTEXT.md` §8 的骨架 R1 cohort/universe → R2 proteome landscape → R3 85 High-vs-Low → R4 reused-hold-out 层级（85/83/29/1）→ R5 robustness → R6 representative pathway themes，在 `PROJECT_RECONSTRUCTION_PLAN.md` Part 13 被逐节落成 "Question / Figures / Claims" 三件套，论证链本身**连贯、闭合、无孤儿目标**：

- R1（Fig1）主张 519→515 / 386 / 129 / 1,430 / 85，证据指针 Fig1 flow / M01–M11。
- R2（Fig2）主张 "0/1,430 overall at BH-FDR<0.05" 作为 context，证据 M05/M07。
- R3（Fig3）主张 85 locked discovery DEPs，证据 D03 lock。
- R4（Fig5a）主张 83/29/1 层级，证据 M14/D08。
- R5（Fig4）主张 detection 2/3,054、LOO、environment-stratified descriptive、interaction 0/1,430，证据 M08/M11/M10。
- R6（Fig6）主张 cameraPR primary 195 representative themes，证据 M12。

**链的科学判断力良好**：`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md` §1.1 把问题按"数据能回答什么"分级（Primary / Secondary / Exploratory / **cannot answer**），§2 给每个证据域打了 Grade，§3 明确 "The 85 are the central empirical finding, but their scientific weight is modest"。这是本项目文档最强的一环——主张强度与证据强度基本对齐，没有把发现写成结论。

**但论证链的 R5/R6 证据基础已被修复计划重开**（见 3.1 B1）：R5 的 ML robustness 与 R6 的通路主题所依赖的模块（fixed-85 ML、strict nested、M12/M12B）在 `P0_P1_REPAIR_PLAN.md` 中被列为 do-not-freeze / 需要 rebuild。也就是说，链条结构对，但链条末端的证据尚未冻结。

### 2.2 claim→evidence 抽查结果

抽查 `STATISTICAL_CLAIM_MAP.csv`（C01–C30）：

- **结构优秀**：每条 claim 带 Evidence_source / N / Effect_metric / Statistical_test / Multiplicity_family / Adjusted_measure / Evidence_level / Allowed_wording / Prohibited_wording / Status。这是 researchwrite 标准 evidence_table 的成熟形态。
- **发现两处具体错位**：
  - **C05 分母错配**：C05（Discovery DEP lock）`N=1430`，但权威 frozen 分母是 **1,445 Discovery-eligible**（`PROJECT_CONTEXT.md` 第 27 行；`FINAL_REPRODUCIBILITY_AUDIT.md` 第 129 行 "1,445 eligible -> 85 DEPs"；`STATISTICAL_REPORTING_AUDIT.md` §17 Fig1d universe bar "3817/3054/1430/1445/85"）。1,430 是 Q515 分析队列丰度宇宙，不是 Discovery lock 的分母。
  - **C05 证据指针悬空**：C05 Evidence_source="M03/M05 D03"，但 `MANUSCRIPT_MODULE_MAP.csv` 中模块编号从 D01–D10、M05–M12 起，**不存在 M03**；真正产出 85 的是 D02_discovery_primary（produces 85 candidate pool）与 D03_candidate_lock（locks before hold-out use）。
- **Status 列与 P0/P1 不同步**：C16–C19（ML）标 REWORD、C20–C22（通路 195/23/39）标 SAFE，但 `P0_P1_REPAIR_PLAN.md` "Do-not-freeze evidence" 明确把 XGBoost AUROC、EN 系数/Tier1、strict-nested 8–618、M12 mapping/cameraPR/ORA/fgsea 与 195/23/39 计数、M12B 解释全部列为需要 rebuild。claim map 未反映这一重开状态。

### 2.3 与既有自审的差异（本审计新增 / 独立判定）

既有自审（WPSR、STATISTICAL_REPORTING_AUDIT、REVIEWER_RISK_REGISTER）已经把"措辞纪律"做得很干净：凡 "validated / external / causal / biomarker / signature / no interaction" 几乎全部出现在 **Prohibited_wording 列或 "NOT supported" 段落**，没有出现在肯定性主张里。本审计**不重复**这些已知的措辞项，而是聚焦三个既有自审**没有覆盖**的层面：

1. **时间线/文档间一致性**：09-29 的 "PASS / no blockers / no leakage" 结论与 09-30 的 P0/P1 修复计划直接冲突（既有自审把修复计划当作"另一份文档"，未把它当作 claim map 的上游失效证据）。
2. **协议源头的 framing 滑移**：`ANALYSIS_PLAN_v2.1.md` 的 "biomarker-development / biomarker route / panel table" 与 `PROJECT_CONTEXT.md` 身份边界的张力，以及 `DISCOVERY_VALIDATION_PROTOCOL.md` §8 的 "independent Validation participants"。
3. **claim map 的机械错误**：C05 分母与悬空指针——既有自审关注"措辞对不对"，没有逐格核对 claim map 的 N 列与 Evidence_source 列是否指向真实存在的模块。

---

## 3. 分级发现清单

### 3.1 阻断

- **[阻断] B1：claim→evidence 映射与"冻结/PASS"叙事已被 P0/P1 修复计划推翻，但 claim map、风险登记册、权威入口均未降级**
  - 证据指针：
    - `docs\P0_P1_REPAIR_PLAN.md`（2026-09-30）Executive summary："The analysis freeze is blocked… `Freeze_readiness_score = 1/10` … `Safe_to_tag_analysis_v2.1 = NO`"；并明示 "The current results must not be described as `PASS_WITH_LIMITATIONS`, `READY_TO_TAG_WITH_LIMITATIONS`, or `ALL_RERUN_READY`"。
    - 同文件 "Do-not-freeze evidence"：XGBoost outer-fold AUROC、Elastic Net alpha/lambda/系数/选择频率、Tier1 及 ML intersection、strict-nested 8–618、M09、M11、"M12 mapping, cameraPR, fgsea, ORA, the reported 195/23/39 pathway counts, M12 integration, and all M12B interpretations"。
    - 反向证据：`manuscript_v2_1\audit\STATISTICAL_REPORTING_AUDIT.md` §20："**PASS_WITH_LIMITATIONS**. No wrong model… no leakage, no broken implementation was found."；`docs\FINAL_REPRODUCIBILITY_AUDIT.md` §18："**None.** … numerical inconsistency…"、§19 "READY_TO_TAG_WITH_LIMITATIONS."。
    - `STATISTICAL_CLAIM_MAP.csv`：C16/C17/C18/C19 Status=REWORD、C20/C21/C22 Status=SAFE（均未标注 do-not-freeze）。
  - 影响：R5（ML robustness）与 R6（通路主题）是当前自审叙事的组成部分，但其证据模块被修复计划判定为含 P0-1（XGBoost outer-test early-stopping leakage）、P0-2（EN AUC 优化方向误用 `which.min`）、P0-3（M12 mapping `nrows=0` 零行读取）、P0-4（canonical 链含 KEGG fix 而 KEGG=NOT_RUN）。若现在组装稿件正文并写 R5/R6 主张，等于在已知地基被重开的情况下盖楼。这是"论证先于章节"原则的反例：章节框架（R1–R6）已搭好，但 R5/R6 的 allowed claims 尚不能写入正文。
  - 建议（降级 / 暂缓写入）：
    1. 在 `STATISTICAL_CLAIM_MAP.csv` 把 C16–C22 的 Status 改为 `DO_NOT_FREEZE / PENDING_REBUILD`（不是删除，是暂缓成稿）。
    2. 正文 assembly 只先写 R1–R4（队列、景观、85 lock、85/83/29/1 层级）——`P0_P1_REPAIR_PLAN.md` "Keep-unchanged evidence" 明确 D03 的 85、D08 raw 复制表、85/85/83/29/1 层级、386/129 分配均 KEEP_UNCHANGED。
    3. R5/R6 等修复计划 Phase 1–6 完成、下游 rebuild 并重新审计后再写。不要引用 `STATISTICAL_REPORTING_AUDIT.md` §20 的 "no leakage / no broken implementation" 作为已清除结论。

### 3.2 重大

- **[重大] M1：C05 分母错配（1,430 vs 1,445），headline 85 的筛选宇宙在 claim map 中被写错**
  - 证据指针：`STATISTICAL_CLAIM_MAP.csv` C05 行 `N=1430`；对照 `PROJECT_CONTEXT.md` 第 27 行 "85 (BH-FDR < 0.05 on **1,445** Discovery-eligible proteins)"；`FINAL_REPRODUCIBILITY_AUDIT.md` 第 129 行 "Discovery: **1,445** eligible -> 85 DEPs"；`STATISTICAL_REPORTING_AUDIT.md` §17 Fig1d universe bar "3817/3054/**1430**/**1445**/85"。另见 `STATISTICAL_REPORTING_AUDIT.md` §2 把 "Discovery High-vs-Low DEP screen" 与 "0/1,430 overall" 合并写成 "on the 1,430 protein groups"，同样混淆了 Discovery-eligible（1,445）与 Q515 丰度宇宙（1,430）。
  - 影响：稿件 headline "我们在 N 个蛋白中筛出 85 个" 若写成 1,430，与 protocol / Fig1d / reproducibility audit 的 1,445 不一致；审稿人会抓到"筛选池大小对不上"。1,430 是分析队列丰度宇宙（overall exposure / interaction / pairwise），1,445 才是 Discovery-only eligible 宇宙。
  - 建议（改写）：C05 的 N 改为 **1,445（Discovery-eligible）**；把 1,430 保留给 C09（overall exposure）、C13（interaction）、C15（LOO）这三个分析队列口径；在 claim map 或 Table 1 脚注显式列出三个宇宙 1,430 / 1,434 / 1,445 / 1,414 及其用途，避免再次滑移。

- **[重大] M2：C05 证据指针悬空（"M03/M05 D03" 中的 M03 不存在）**
  - 证据指针：`STATISTICAL_CLAIM_MAP.csv` C05 Evidence_source="M03/M05 D03"；`MANUSCRIPT_MODULE_MAP.csv` 全表模块为 D01–D10、M05–M12、M12B、M14、M15、M17，**无 M03**；`PROJECT_CONTEXT.md` §4 v2 abundance 从 M05 起。真正产出 85 的是 `MANUSCRIPT_MODULE_MAP.csv` 第 3 行 D02_discovery_primary（"Produces 85 candidate pool"）与第 4 行 D03_candidate_lock（"Lock before hold-out use"）。
  - 影响：claim→evidence 映射存在悬空引用；按图索骥的复核者找不到 M03。
  - 建议（改写）：C05 Evidence_source 改为 "D02_discovery_primary / D03_candidate_lock"（或按 `PROJECT_CONTEXT.md` §4 的 discovery-validation 入口 `descriptive/discovery_validation/code/D0*.py`）。

- **[重大] M3：研究身份边界滑移——协议层 `ANALYSIS_PLAN_v2.1.md` 反复使用 biomarker-development / biomarker route / panel table，与权威身份边界冲突**
  - 证据指针：`docs\protocol\ANALYSIS_PLAN_v2.1.md` 第 8 行 "Align the main **biomarker-development** question"；第 9 行 "manuscript **biomarker route** DEP-driven"；§5 标题 "Main **biomarker candidate space**"；第 64 行 "The main **biomarker-development** candidate pool"；第 85 行 "main **biomarker route**"；第 229 行 Table 4 "prioritized ML feature/**panel** table"。对照 `PROJECT_CONTEXT.md` §1："NOT supported as primary identity: biomarker discovery study, predictive modeling study. ML is secondary/supporting; no causal or mechanistic claim is made."
  - 影响：协议是论证源头。若稿件 Methods / Introduction 继承 v2.1 修正案的 "biomarker-development framing"，就重新打开了 `PROJECT_CONTEXT.md` 已关闭的身份边界；审稿人读到 "biomarker candidate space" + "ML feature/panel table" 会按 predictive-modeling study 来审，与本研究实际的 single-cohort reused hold-out 证据强度不匹配。注意 v2.1 修正案本身有保护条款（§6.2 "conditional / exploratory predictive performance, not an unbiased estimate"；§8 "Any future definitive classifier validation requires genuinely new participants"），所以这是**词汇/身份滑移**，不是结果段的过度声称。
  - 建议（删除 / 替换）：稿件面向读者的措辞把 "biomarker-development / biomarker route / biomarker candidate space / panel table" 替换为 "exposure-associated candidate prioritization / descriptive prioritization layer"；ML 始终标注 conditional on frozen 85；Table 4 命名为 "candidate prioritization summary" 而非 "panel table"。协议层的 biomarker 字样保留作历史设计记录即可，不进入成稿叙述。

- **[重大] M4：协议（论证源头）仍用 "independent Validation participants" 确认性框架，强于 reused hold-out 实际**
  - 证据指针：`docs\protocol\DISCOVERY_VALIDATION_PROTOCOL.md` §8 主确认问题 "Do Discovery-selected Long-vs-Short proteins reproduce their Long-vs-Short effect in **independent Validation participants**?"；§11–§13 整个层级用 "Validation" 作 confirmatory。对照 `PROJECT_CONTEXT.md` §2："Reused hold-out subset 129 (same cohort; **NOT external / independent validation**)"；`FIGURE_TEXT_STANDARDIZATION_REPORT.md` 第 31 行已把图面 Validation→Reused hold-out。
  - 影响：协议是 "prespecified / prospective" 的论证来源。若稿件引用该协议作为预注册的验证设计，§8 的 "independent" 与实际 reused same-cohort hold-out 矛盾。协议是历史产物，风险在于继承其 confirmatory framing 而不是继承其 split provenance。
  - 建议（删除 / 改写方向）：稿件引用协议时只取 split/seed/stratification provenance（seed 20260925、75/25、Environment×Dose 分层、A01–A26 全 PASS），不引用其 "independent Validation" 确认性叙述；Methods 补一句 "the 129-subject hold-out is a reused within-cohort hold-out; the protocol's 'Validation' label reflects prospective design intent, not external participant acquisition"。

### 3.3 次要

- **[次要] m1：权威入口 `PROJECT_CONTEXT.md` 自身已被列为 CONTROL_DOC_STALE，但仍按"全冻结"呈现**
  - 证据指针：`P0_P1_REPAIR_PLAN.md` "Control-document conflicts"："`PROJECT_CONTEXT.md` still lists the final reproducibility audit as not started while also describing the project as frozen"；canonical 链含 `M12_02b_kegg_fix.R` 而 KEGG=NOT_RUN。对照 `PROJECT_CONTEXT.md` §9 "Final reproducibility audit" 仍列在 "Remaining tasks (not started)"（尽管 `FINAL_REPRODUCIBILITY_AUDIT.md` 已存在）；§4 入口表第 54 行仍列 `M12_02b_kegg_fix.R ->` 在 M12 canonical chain 中。
  - 影响：本审计把 `PROJECT_CONTEXT.md` 当作 frozen 边界对照物，但它自己已经过期；从中取的任何"canonical"数字都可能需要脚注。
  - 建议（修复后更新）：rebuild 完成后，§4 从 active chain 移除 kegg_fix、§9 标注 reproducibility audit 状态（done / blocked）、并加一行指向 `P0_P1_REPAIR_PLAN.md`。

- **[次要] m2：Fig6 通路图对主 cameraPR Reactome 臂过度简化（170/195 无 curated 面板），与 R6 主张强度不匹配**
  - 证据指针：`docs\PATHWAY_FIGURE_INVENTORY_AUDIT.md` §5 verdict："Fig6 is **TOO_REDUCTIVE** on the primary cameraPR Reactome arm (170 of 195 primary pathways are Reactome, and Fig6 shows zero Reactome content in a curated panel)"；同文件 §5 表：cameraPR Reactome 170 → "No"；§7 MISSING_MANUSCRIPT_VISUAL 列出 cameraPR Reactome curated panel、M12B pairwise Spearman heatmap 等。
  - 影响：R6 主张代表通路主题，但图面唯一主通路数据库（Reactome 170）无 curated 展示；稿件视觉证据弱于文字主张。（且 195/23/39 本身在 B1 下待 rebuild。）
  - 建议（补图，非新分析）：从已 frozen 的 `M12_pathway_v2.1/ranked/` 与 `integration/` 出一张代表 Reactome cluster 面板（纯绘图任务，无需重跑统计）后再写 R6。

- **[次要] m3：内部键 Short/Long dose、Humid-hot/High-pressure 在协议文档中作为锁定分析词汇出现，需确保稿件层不泄漏**
  - 证据指针：`DISCOVERY_VALIDATION_PROTOCOL.md` §2/§5 全文用 Humid-hot / High-pressure/high-altitude、Long vs Short primary contrast；`DISCOVERY_VALIDATION_SPLIT_SPEC.md` §2 把 `low→Short`、`high→Long`。`PROJECT_CONTEXT.md` 首注释：内部键只出现在 frozen 结果表。`FIGURE_TEXT_STANDARDIZATION_REPORT.md` 已把图面 display label 映射为 High land / Hot-humid。
  - 影响：低风险，图面已治理；残余风险是 Methods prose 从协议继承 "Short/Long dose" 或 "Humid-hot/High-altitude"。
  - 建议：Methods prose 用 "exposure category (Low/High)" 与 "High land / Hot-humid"；Short/Long、Humid-hot/High-pressure 仅保留在 frozen split 表与结果附录。

### 3.4 提示

- **[提示] t1："删除胜于解释"原则执行良好——未发现靠解释圆场的夸大主张（正面确认）**
  - 证据：`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md` §3 直接降级 "They are not a validated panel… a discovery candidate family, not a signature"；`STATISTICAL_CLAIM_MAP.csv` 每条 claim 配 Prohibited_wording；`REVIEWER_RISK_REGISTER.csv` R05/R06 把 "1/85" 定为 "upper bound of formal replication, not as a success"。全仓库 grep "validated/external/causal/biomarker/signature" 命中几乎全部位于 prohibited 列或 "NOT supported" 段，**未发现肯定性越界声称**。这是本项目文档体系的优势，应予保留，不要在润色中过度回改。

- **[提示] t2：R1–R4（队列→景观→85→层级）可立即成稿，R5/R6 暂缓（基于修复计划 keep-unchanged 清单）**
  - 证据：`P0_P1_REPAIR_PLAN.md` "Keep-unchanged evidence" 表：D03 locked 85、D08 raw 85-protein hold-out replication table、D08 hierarchy 85/85/83/29/1、Discovery/validation assignment、raw source data 全部 KEEP_UNCHANGED。
  - 建议：先组装 R1–R4 正文与 Table 1–3，把 R5 robustness 与 R6 pathway 留待 rebuild 后补写；这样在证据未冻结前不产出越界主张。

---

## 4. 可进入稿件的安全措辞要点

基于上述 frozen 边界与发现，以下措辞可直接进入成稿（逐字与 frozen 文档一致）：

1. **队列 / 宇宙**："Final analytical cohort n=515 (153 Control / 186 Low / 176 High exposure); Discovery subset n=386; reused hold-out subset n=129."（`STATISTICAL_CLAIM_MAP.csv` C01–C04；`PROJECT_CONTEXT.md` §2）。
2. **85 的定性**："a discovery set of 85 exposure-associated (High-vs-Low) proteins locked in the Discovery subset on 1,445 eligible proteins under prespecified BH-FDR<0.05"——**不得**写 validated / replicated / signature / panel（`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md` §3；`STATISTICAL_REPORTING_AUDIT.md` §5）。
3. **复制层级**："83/85 direction-concordant; 29/85 nominally replicated (raw P<0.05); 1/85 FDR-supported replication under candidate-family BH"——29 只能叫 nominal，1 是 "upper bound of formal replication"（`REVIEWER_RISK_REGISTER.csv` R05/R06）。
4. **129 的定性**："reused within-cohort hold-out, NOT external / independent / prospective validation"（`PROJECT_CONTEXT.md` §2；`STATISTICAL_REPORTING_AUDIT.md` §1）。
5. **交互**：逐字用 "No exposure × environment interaction survived the prespecified BH-FDR threshold (0/1,430)"——**不得**写 "there was no interaction" / "no modifying effect"（`PROJECT_CONTEXT.md` §5；`STATISTICAL_REPORTING_AUDIT.md` §6）。
6. **ML（R5，rebuild 后）**："predictive performance conditional on the frozen 85-protein discovery panel, repeated outer CV within Discovery"；strict nested 8–618 表述为 "feature-selection instability under resampling"，**不得**写 unbiased generalization / biological heterogeneity / 选中 panel（`STATISTICAL_CLAIM_MAP.csv` C16/C17；`P0_P1_REPAIR_PLAN.md` Phase 1–2 完成前勿写）。
7. **通路（R6，rebuild 后）**："cameraPR primary (195 FDR-significant; representative themes shown); ORA complementary (23); fgsea sensitivity (39); KEGG not run"——**不得**三数相加，不得写 pathway activation / mechanism（`PROJECT_CONTEXT.md` §6；`STATISTICAL_REPORTING_AUDIT.md` §13/§15）。
8. **身份**："environmental-exposure EV-enriched plasma proteomics study"；EV 后必须跟 "enriched" 而非 "pure"；共分离血浆蛋白与前分析变量作 limitation 列出（`PROJECT_CONTEXT.md` §1；`REVIEWER_RISK_REGISTER.csv` R01/R02/R03）。
9. **术语**：图面与正文用 High land / Hot-humid；内部键 High-pressure/high-altitude、Humid-hot、Short/Long dose 只留在 frozen 结果表（`PROJECT_CONTEXT.md` 首注释；`FIGURE_TEXT_STANDARDIZATION_REPORT.md`）。

---

## 5. 未覆盖 / 无法判定的边界

1. **未逐格复核 ML 与通路的 rebuild 是否已经启动/完成**：本审计只读静态文档，`P0_P1_REPAIR_PLAN.md` 是计划（Date recorded 2026-09-30），未在被审材料中看到 Phase 1–6 的执行回执或 rebuild 后的新 frozen CSV。因此 B1 判为"证据基础待重开"，不判定 ML/通路数字本身对错。
2. **未运行统计复算**：所有数字来自被审文档原文互证；未打开 `ml_v2.1/*.csv`、`M12_pathway_v2.1/*.csv` 逐行核对 85/83/29/1、195/23/39、AUROC 0.65/0.64。claim→evidence 抽查限于 claim map 的 N 列与 Evidence_source 列，未做逐蛋白核对。
3. **未审 `EXPERIMENTAL_DESIGN_REVIEW.md`、`STATISTICAL_REPORTING_AUDIT.md` 的全部章节**：前者只通过 grep 命中片段参考；后者通读全文但本审计聚焦 claim 结构，未复做其图-by-图统计 PASS 判定。
4. **稿件正文尚不存在**（`PROJECT_CONTEXT.md` §9 确认 manuscript assembly 未开始）：因此本次审计对象是自审文档与协议的"论证与声称结构"，不是成稿 prose；anti-slop（语言模板化）与 rubric 第 8 维"语言质量"只能按文档语言推断，不能按真实投稿稿打分。
5. **protocol v1.0（Long-vs-Short、256 全队列基准）与 v2.1 修正案（High-vs-Low、85）的版本关系**：本审计确认 `DISCOVERY_VALIDATION_PROTOCOL.md` 的 Long/Short 是 internal key（=Low/High，见 `SPLIT_SPEC.md` §2 `low→Short`、`high→Long`），256 是全队列 reference benchmark、不是 Discovery lock；未进一步判定 v1.0 的 "prospective validation" 叙述在伦理/注册层面是否构成预注册声明——这超出写作质量审计范围。
6. **rubric 评分**：因被审对象是内部自审文档而非投稿稿，第 5 维（方法可复现性）与第 6 维（创新性）按 internal 口径给分，不套用 paper 7.0 门槛。

### 关键文档 rubric 速评（0–10；低分维度附一句）

| 文档 | 问题清晰度 | 科学张力 | 证据匹配 | 逻辑链 | 风险边界 | 语言 | 最低分维度 |
|---|---|---|---|---|---|---|---|
| `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md` | 9 | 7 | 6 | 8 | 9 | 8 | 证据匹配 6：把 ML/通路当作"已冻结/moderate"，未吸收 P0/P1 重开 |
| `STATISTICAL_REPORTING_AUDIT.md` | 8 | 6 | 5 | 8 | 8 | 8 | 证据匹配 5：§20 "no leakage/no broken implementation" 被 P0-1/P0-2 推翻 |
| `STATISTICAL_CLAIM_MAP.csv`（claim→evidence 层） | 8 | 5 | 5 | 8 | 8 | 7 | 证据匹配 5：C05 分母 1430 错（应 1445）、指针 M03 悬空、C16–C22 未标 do-not-freeze |
| `PROJECT_RECONSTRUCTION_PLAN.md` | 8 | 7 | 7 | 8 | 8 | 8 | 整体健康；唯 R5/R6 模块分配指向待 rebuild 的 ML/通路 |

总分定位：内部自审文档体系整体在 7.0–8.0（可给导师看 ~ 正式打磨之间），**但证据匹配维（第 3 维）是全项目短板**，且被 P0/P1 修复计划进一步拉低。在 R5/R6 rebuild 完成前，不建议进入 nature-style polishing。
