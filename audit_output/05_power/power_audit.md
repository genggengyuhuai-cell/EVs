# 功效/样本量审计（statistical-power）

> 审计性质：纯静态只读审计。未运行任何分析/功效计算脚本，未修改 `F:\env` 任何既有文件。
> 审计视角：`statistical-power` 技能的 Common pitfalls 清单（inventing effect size、post-hoc/observed power 循环论证、multiplicity 校正下功效、matching power method to analysis）。
> 项目性质：已完成的观测性组学研究（环境暴露 × EV-enriched 血浆蛋白组学，analysis-v2.1）。本报告**不做**功效计算，只审计功效/样本量问题是否被**恰当说明与设限**。

---

## 1. 审计范围与材料

### 1.1 冻结边界（引自 `PROJECT_CONTEXT.md`）

- 初始队列 519；最终分析队列 **515**（Control 153 / Low 186 / High 176）（`PROJECT_CONTEXT.md` §2）。
- Discovery 子集 **386**（前瞻性确定性拆分，seed 20260925）；复用队列内留出子集 **129**（同队列，非外部/独立验证）（§2）。
- Discovery High-vs-Low DEP **85**（BH-FDR < 0.05，作用于 1,445 个 Discovery-eligible 蛋白）；方向一致 83/85；名义复制 29/85；FDR 支持复制 **1/85**（候选族 BH-FDR）（§2）。
- 交互：**0 / 1,430** Group × Environment 交互在 BH-FDR < 0.05 下存活；措辞冻结为"No interaction survived the prespecified BH-FDR threshold"，禁止写"there was no interaction"（§5）。

### 1.2 只读检索的关键词清单与命中位置

对 `F:\env` 全仓库（限定 `.md`，排除 `archive/` 历史冻结件）执行只读 Grep，关键词与主要命中：

| 关键词 | 命中位置（文件 / 行号） | 性质判定 |
|---|---|---|
| `power`（统计功效义） | `docs\protocol\STUDY_DESIGN_AUDIT.md:103`（"No assurance of adequate power follows simply from N=129"）；`docs\protocol\ANALYSIS_PLAN_v2.0.md:514`（"This is not a power guarantee"）；`manuscript_v2_1\audit\STATISTICAL_REPORTING_AUDIT.md:70,190`；`manuscript_v2_1\audit\WHOLE_PROJECT_SCIENTIFIC_REVIEW.md:27,71`；`manuscript_v2_1\audit\EXPERIMENTAL_DESIGN_REVIEW.md:49`；`docs\FINAL_ML_RESULT_AUDIT.md:100`（shadow-variable test "no discriminating power"，此处为区分度义，非统计功效） | 均为定性提示，无功效计算 |
| `post-hoc` / `observed power` | 全部命中均为**事后效应截断 / 面板调整 / clipping / refit**（`descriptive\discovery_validation\WORKFLOW.md:121`、`FIGURE_PLAN.md:26`、`DISCOVERY_VALIDATION_HANDOFF…:404`、`README.md:136`、`docs\protocol\ANALYSIS_PLAN_v2.0.md:522`、`ANALYSIS_PLAN_v2.1.md:243`、`archive\historical_frozen\ml_legacy\…`）；**未发现** observed power / post-hoc power 计算 | 正面：规避了 post-hoc power 误用 |
| `sample size` / `样本量` | `docs\protocol\STUDY_DESIGN_AUDIT.md:40`（"sample sizes, eligibility membership… differ"）；`descriptive\analysis_v2.0\candidate_diagnostics_roc\CANDIDATE_ROC_AUDIT.md:3-5`（Discovery n=271 / hold-out n=91）；`descriptive\数据描述报告.md:45`（"地区样本量"，描述义） | 仅计数描述，无样本量论证 |
| `MDE` / `minimum detectable` / `detectable effect` | **全仓库零命中** | 缺口：无可检测效应量化 |
| `type II` / `二类错误` / `1-β` / `80% power` / `a priori power` | **全仓库零命中** | 缺口：无先验功效框架 |
| `underpower` / `under-powered` | `STATISTICAL_REPORTING_AUDIT.md:190`；`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md:27`；`EXPERIMENTAL_DESIGN_REVIEW.md:49`；`REVIEWER_RISK_REGISTER.csv` R09 | 仅交互一项被定性为 underpowered |
| `sensitivity analysis` | 大量命中，但全部指**缺失值/站点/归一化/检测阈值**稳健性（`descriptive\missingness_robustness\README_METHODS.md`、`ANALYSIS_PLAN_v2.0.md:82,128,151,214`、`V2_IMPLEMENTATION_GAP_AUDIT.md:83` 等） | 术语已被稳健性占用，非 power sensitivity |
| `multiple comparisons` / `BH` / `FDR family` | `STATISTICAL_REPORTING_AUDIT.md` §3（8 个互斥 FDR 族，1,430 / 85 / 3,054 / 1,414 等）；`PROJECT_CONTEXT.md` §5–§6 | 多重比较族划分严谨，但未与功效显式连接 |

### 1.3 已通读的权威文档

- `PROJECT_CONTEXT.md`（frozen 数字与措辞边界）
- `docs\protocol\ANALYSIS_PLAN_v2.0.md`、`ANALYSIS_PLAN_v2.1.md`、`DISCOVERY_VALIDATION_PROTOCOL.md`、`DISCOVERY_VALIDATION_SPLIT_SPEC.md`、`STUDY_DESIGN_AUDIT.md`、`V2_IMPLEMENTATION_GAP_AUDIT.md`
- `manuscript_v2_1\audit\STATISTICAL_REPORTING_AUDIT.md`、`REVIEWER_RISK_REGISTER.csv`、`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`、`EXPERIMENTAL_DESIGN_REVIEW.md`
- `docs\FINAL_ML_RESULT_AUDIT.md`
- `descriptive\missingness_robustness\README_METHODS.md`

---

## 2. 独立判定（与既有自审差异对比表）

| 维度 | 既有自审结论（STATISTICAL_REPORTING_AUDIT / REVIEWER_RISK_REGISTER / WHOLE_PROJECT_SCIENTIFIC_REVIEW） | 本审计独立判定 | 差异 / 增量 |
|---|---|---|---|
| 交互 underpowered | 已列局限 #3："Interaction test is underpowered (0/1,430 at BH-FDR<0.05); absence of significance is not evidence of no effect."（`STATISTICAL_REPORTING_AUDIT.md:190`）；R09 登记 Medium | **一致**：交互 0/1,430 在 BH-FDR 下确实功效受限，且阴性措辞已合规 | 无差异；本审计确认其措辞合规 |
| post-hoc / observed power | 既有自审未单独列项（因仓库内本就无此计算） | **独立确认**：全仓库无 observed/post-hoc power；所有 "post-hoc" 均指事后效应截断/面板调整，且被协议明令禁止 | **增量**：正面发现，建议稿件主动声明"未做 observed power"以预防审稿人质疑 |
| a priori 功效 / 样本量论证 | 既有自审未列项（默认观测性研究不需先验功效） | **独立确认**：全仓库无任何先验功效分析、无样本量论证、无 SESOI、无 power curve；386/129 拆分目标由 `DISCOVERY_VALIDATION_SPLIT_SPEC.md` §3 以固定 stratum 计数定义，seed 20260925，未提及功效依据 | **增量**：缺口存在，但属"观测性研究可豁免"范畴；缺的不是先验功效，而是**正面声明豁免理由 + 可检测效应边界** |
| MDE / 可检测效应量化 | 既有自审未列项 | **独立确认**：全仓库零 MDE / minimum detectable / detectable effect 命中；`STUDY_DESIGN_AUDIT.md:103` 仅有定性句"No assurance of adequate power follows simply from N=129" | **增量（重大）**：观测性研究允许不做先验功效，但应报告"本 N 下能检出多大效应"的近似边界作为局限；目前完全缺失 |
| 多重比较族对功效的压缩 | 既有自审 §3 严谨划分 8 个互斥 FDR 族，但未将族规模与功效挂钩 | **独立判定**：1,445 / 1,430 蛋白 BH-FDR 与 85 候选族 BH-FDR 是客观功效受限来源；仓库知道交互"underpowered"，但未显式写出"经 BH-FDR 校正后，可检测效应阈值远大于名义 α=0.05" | **增量（次要）**：multiplicity 与 power 的因果链未在文档中显式闭合 |
| 129 留出集精度 | `STUDY_DESIGN_AUDIT.md:103` 定性提及"sensitivity in 44–47 cases and specificity in 38 controls can be imprecise" | **一致**；但该句未进入 `STATISTICAL_REPORTING_AUDIT.md` §19 的局限清单 | **增量（次要）**：建议把 129 留出集精度局限从协议审计提升到稿件 Discussion 局限清单 |
| 阴性结论措辞合规 | 已列禁令：禁止 "There was no interaction"，必须写"No interaction survived the prespecified BH-FDR threshold"（`STATISTICAL_REPORTING_AUDIT.md:67-70`）；R05/R06 登记 | **一致**：frozen 阴性结论（交互 0/1,430、FDR 复制 1/85）均保留"未生存阈值"性质，未写成"不存在" | 无差异；本审计确认合规 |
| 术语冲突（sensitivity = 稳健性 vs 功效灵敏度） | 既有自审未识别 | **独立判定**：本仓库 "sensitivity analysis" 已被缺失值/站点/归一化/检测阈值稳健性占用；审稿人要求 "power sensitivity analysis" 时无对应物 | **增量（次要）**：术语缺口，易被误读 |

---

## 3. 分级发现清单

### 3.1 阻断（Blocker）

无。本项目未发现会导致结论推翻的功效/样本量硬伤。阴性结论措辞已合规，未做 post-hoc power，未虚构效应量。

---

### 3.2 重大（Major）

- **[Major] P-MAJOR-1：协议方法层无任何功效/样本量/MDE 陈述；审计层的 "underpowered" 提示不会自动流入稿件 Methods**
  - 证据指针：
    - `docs\protocol\ANALYSIS_PLAN_v2.0.md` 与 `ANALYSIS_PLAN_v2.1.md` 全文 Grep `power|sample size|a priori|MDE|detectable effect|type II|80% power` 仅命中 `:514` 一句"This is not a power guarantee"（指 CV fold 可行性，非研究功效）。
    - `docs\protocol\DISCOVERY_VALIDATION_SPLIT_SPEC.md` §3 以固定 stratum 计数（95/83/101/58/103/75 → Discovery 386 / Validation 129）定义拆分，seed 20260925；全文无任何功效依据句。
    - "underpowered" / "power not formally modeled" 仅出现在**内部审计文档**（`STATISTICAL_REPORTING_AUDIT.md:70,190`、`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md:27`、`EXPERIMENTAL_DESIGN_REVIEW.md:49`），这些是稿件组装前的自审件，不是 Methods 文本。
  - 影响：稿件 Methods 若直接从 ANALYSIS_PLAN 生成，将出现**完全空白的功效/样本量章节**。审稿人（尤其统计/ML reviewer，已在 `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md:71` 被预警为会 push back "interaction power"）会要求补一段。观测性组学研究豁免先验功效是合理的，但豁免理由必须**正面写出**，不能留空。
  - 建议：在稿件 Methods 或 Discussion 局限中主动写入一句："This was a cross-sectional observational proteomics study; sample size was determined by available recruitment rather than an a priori power calculation. We therefore report below the approximate effect sizes this N could detect and treat null findings as 'not surviving the prespecified threshold' rather than as evidence of absence." 并补 P-MAJOR-2 的 MDE 边界。

- **[Major] P-MAJOR-2：无可检测效应（MDE）量化——成就 N 下"能检出多大效应"完全未提及**
  - 证据指针：全仓库 Grep `MDE|minimum detectable|detectable effect|detect a` 零命中；唯一近似句为 `STUDY_DESIGN_AUDIT.md:103`："No assurance of adequate power follows simply from N=129. For prediction, sensitivity in 44–47 cases and specificity in 38 controls can be imprecise, especially at extreme thresholds."
  - 影响：观测性研究不做先验功效是可接受的，但**不报告"本 N 下可检测效应的近似下界"**会让审稿人无法判断阴性结论（交互 0/1,430、FDR 复制 1/85）是真无效还是功效不足。`STUDY_DESIGN_AUDIT.md:111` 已提到 "Winner's curse（发现集效应高估）and limited validation precision are plausible explanations for attenuation"——这正是功效问题的同源表述，但未量化。
  - 建议：**不做新计算**（本审计约束禁止），但在稿件 Discussion 局限中用定性 + 区间表述写入："With 386 Discovery participants (High n≈132, Low n≈139 in the High-vs-Low contrast) and 129 reused hold-out participants, single-protein detection after BH-FDR correction over 1,430 proteins is restricted to relatively large effects; small-to-moderate effects would not reach multiplicity-controlled significance. The 1/85 FDR-supported replication should be read as an upper bound of formal replication, not as a success rate." 具体数值区间由后续统计合作者按实际 SD 与 BH 族规模补算，不在本静态审计内生成。

---

### 3.3 次要（Minor）

- **[Minor] P-MINOR-1：多重比较族规模（1,445 / 1,430 蛋白 BH-FDR；85 候选族 BH）对功效的压缩未被显式连接为功效约束**
  - 证据指针：`STATISTICAL_REPORTING_AUDIT.md` §3 严谨划分 8 个互斥 FDR 族（1,430 蛋白 A-E、1,430 × 3 pairwise、3,054 detection、1,430 interaction、85 候选复制族、1,414 ORA 背景等），但全文未出现"经 BH-FDR 校正后功效下降 / 可检测效应随族规模增大"的因果句。`PROJECT_CONTEXT.md` §5 冻结交互 0/1,430 时也仅写措辞边界，未写功效边界。
  - 影响：审稿人可能问"1,430 个蛋白做 BH-FDR，你的功效还剩多少？"——仓库内部知道答案（定性 underpowered），但文档未把"族规模 → 校正后 α 收紧 → 可检测效应变大"这条链写出来。
  - 建议：在 Discussion 局限补一句："Because the primary discovery family spanned 1,430 protein groups under Benjamini-Hochberg control, multiplicity correction materially narrowed the set of detectable effects relative to a nominal α=0.05 test; the interaction family (1,430 tests) and the replication family (85 tests) inherit the same constraint."

- **[Minor] P-MINOR-2：129 留出集的灵敏度/特异度精度局限未进入 STATISTICAL_REPORTING_AUDIT 的局限清单**
  - 证据指针：`STUDY_DESIGN_AUDIT.md:103` 已定性写出"sensitivity in 44–47 cases and specificity in 38 controls can be imprecise"，但 `STATISTICAL_REPORTING_AUDIT.md` §19（Remaining statistical limitations）仅列 8 条，未把 129 留出集的预测精度局限作为独立条目。
  - 影响：稿件 Discussion 若以 §19 为蓝本，会漏掉"129 留出集的灵敏度/特异度 CI 很宽"这一点；而 `REVIEWER_RISK_REGISTER.csv` R04/R05/R06 已登记 reused hold-out 与 1/85 复制为 High/Medium 风险。
  - 建议：把 `STUDY_DESIGN_AUDIT.md:103` 的定性句提升为 `STATISTICAL_REPORTING_AUDIT.md` §19 的第 9 条局限："The 129 reused hold-out provides imprecise estimates of sensitivity (44–47 High/Low cases) and specificity (38 controls), particularly at extreme thresholds; metrics on this subset should be read with wide binomial intervals."

- **[Minor] P-MINOR-3：术语冲突——本仓库 "sensitivity analysis" 已被稳健性占用，审稿人要求 "power sensitivity" 时无对应物**
  - 证据指针：全仓库 "sensitivity analysis" 命中均指缺失值（D0–D3，`missingness_robustness\README_METHODS.md:19-24`）、站点 LOO（M11）、归一化（sample-median）、检测阈值（50/60/70/80%）等稳健性；无一处指 power sensitivity（即 MDE at achieved n 的灵敏度曲线）。
  - 影响：统计审稿人若写"please provide a power sensitivity analysis"，作者可能误以为是已有的 M09/M11 稳健性，从而答非所问。
  - 建议：稿件 Discussion 主动区分："Robustness/sensitivity analyses here refer to missing-value, site-leave-one-out and normalization sensitivity; we did not perform a formal power sensitivity (MDE) analysis because this is a completed observational study, and instead report the achievable-effect boundary qualitatively in the Limitations."

---

### 3.4 提示（Prompt / Informational）

- **[Prompt] P-PROMPT-1：已正确规避 post-hoc / observed power 误用——建议稿件主动声明**
  - 证据指针：全仓库 Grep `post-hoc|observed power` 命中均为事后效应截断（`WORKFLOW.md:121`、`FIGURE_PLAN.md:26`、`HANDOFF…:404`、`ANALYSIS_PLAN_v2.1.md:243`）、事后面板 refit/clipping（`archive\historical_frozen\ml_legacy\…`），且这些被协议明令禁止；**未发现任何用观测效应反算 power 的循环论证**。
  - 影响：这是 `statistical-power` 技能 Common pitfalls 第 3 条的高发雷区，本项目已规避。
  - 建议：稿件 Methods 可主动写："We did not compute post-hoc (observed) power from the estimated effects, as this is a deterministic function of the p-value and adds no information; null findings are interpreted using confidence intervals and effect-size CIs instead."

- **[Prompt] P-PROMPT-2：frozen 阴性结论措辞已合规——需在稿件 Discussion 继续保持**
  - 证据指针：`STATISTICAL_REPORTING_AUDIT.md:67-70` 已冻结："No exposure × environment interaction survived the prespecified BH-FDR threshold."；禁止 "There was no interaction"。`REVIEWER_RISK_REGISTER.csv` R09 登记。`STUDY_DESIGN_AUDIT.md:265` 冻结"Zero observed detections never establishes biological absence"；`:428` 冻结"These facts do not prove absence of a High-vs-Control response"。
  - 影响：合规。本审计未发现把阴性结论写成确定性"无效应"的违规句。
  - 建议：稿件 Discussion 保持现有措辞；特别注意 1/85 FDR 复制不得写成"仅 1 个蛋白被验证，其余 84 个无效应"，应写"其余 84 个未在复用留出集上通过候选族 BH-FDR，可能反映功效不足、Winner's curse 衰减或真实无效应，三者无法从本队列区分"。

- **[Prompt] P-PROMPT-3：Winner's curse / 衰减已在协议审计提及，与功效问题同源，可合并写入局限**
  - 证据指针：`STUDY_DESIGN_AUDIT.md:111`："Winner's curse（发现集效应高估）and limited validation precision are plausible explanations for attenuation, not proven explanations for each protein."
  - 影响：Winner's curse 与功效不足共同解释 85 → 29 → 1 的衰减；两者应在 Discussion 合并为一段，而非分列。
  - 建议：Discussion 局限段合并写："The attenuation from 85 discovery DEPs to 29 nominal and 1 FDR-supported replications likely reflects a combination of Winner's-curse inflation in the discovery set, limited precision of the 129 reused hold-out under multiplicity correction, and possibly true effects too small to detect at this N; these components cannot be disentangled from the present single-cohort design."

---

## 4. 可进入稿件的安全措辞要点（功效/灵敏度/阴性结论的保守写法）

以下措辞可直接用于稿件 Methods / Discussion，均为定性句，不涉及新计算：

1. **研究性质与样本量依据**：
   > "This was a cross-sectional observational proteomics study of available recruitment; the final analytical cohort comprised 515 participants (Control 153 / Low 186 / High 176), split prospectively into a 386-participant Discovery subset and a 129-participant reused within-cohort hold-out (seed 20260925). No a priori power calculation was used to determine cohort size; we instead characterize the effect sizes this sample size could detect and interpret null findings conservatively."

2. **可检测效应边界（定性）**：
   > "With 386 Discovery participants and BH-FDR correction across 1,430 protein groups, single-protein discovery was restricted to relatively large effects; small-to-moderate associations would not reach multiplicity-controlled significance. The 129-participant hold-out provides imprecise estimates of sensitivity (44–47 High/Low cases) and specificity (38 controls), particularly at extreme thresholds."

3. **阴性结论（交互）**：
   > "No exposure × environment interaction survived the prespecified BH-FDR threshold (0/1,430). This null result does not establish absence of effect modification; the interaction family is underpowered, and environment-stratified estimates are presented as descriptive concordance rather than as an interaction test."

4. **阴性结论（复制）**：
   > "Among the 85 locked discovery DEPs, 83/85 were direction-concordant, 29/85 reached nominal P<0.05, and only 1/85 survived candidate-family BH-FDR on the reused hold-out. The 1/85 should be read as the upper bound of formal replication-level support in this design, not as a success rate; attenuation likely reflects Winner's-curse inflation, limited hold-out precision, and possibly effects too small to detect at this N."

5. **主动声明未做 observed power**：
   > "We did not compute post-hoc (observed) power from the estimated effects; null findings are interpreted using effect-size confidence intervals and the multiplicity family denominators rather than reverse-calculated power."

6. **术语区分**：
   > "Robustness/sensitivity analyses here refer to missing-value (KNN, left-censored, zero-replacement), site-leave-one-out, normalization and detection-threshold sensitivity; a formal power-sensitivity (MDE) curve was not generated for this completed observational study."

---

## 5. 未覆盖 / 无法判定的边界

1. **未做任何功效数值计算**：按任务约束，本审计未运行 `statistical-power` 技能的 `power.py` / `mde` 函数，未反算 386 / 129 下的 Cohen's d / log2FC MDE。稿件若需数值区间，需后续由统计合作者按实际残差 SD 与 BH 族规模补算。
2. **未审计 R 脚本源码中的功效参数**：本审计只读 `.md` 文档与 frozen CSV 的元信息；未逐行检查 `descriptive/analysis_v2.0/code/V2_M0[5-11]_*.R`、`ml_v2.1/*.R`、`descriptive/discovery_validation/code/D0*.R` 是否内嵌功效/样本量常量。若这些脚本内存在未文档化的功效阈值，本审计无法覆盖。
3. **未审计 figure source CSV 中的功效列**：`figures_final_v2/` 与 `figures_nature_v2.2/` 下的 source CSV 未逐列排查；若某图 caption 或 source 表出现 "power" 字段，本审计未发现。
4. **`docs/archive/legacy_framework_v2.0/` 历史框架文档**：该目录标记为历史冻结，本审计未深读；若其中含历史功效论证，与 v2.1 frozen 边界无关，未纳入判定。
5. **未覆盖 M09 / M11 / D07 / D09 模块内的 README**：任务清单提及这些模块与样本量/敏感性相关，但本审计通过 Grep 关键词已确认其中无 power/MDE/a priori 命中；未逐页通读其 README_METHODS。若这些模块的叙事文本中存在未被关键词捕获的功效表述，本审计可能遗漏。
6. **术语边界遵循**：本报告稿件措辞统一使用 "High land / Hot-humid"；内部键 "High-pressure/high-altitude / Humid-hot" 与 "Short / Long dose" 仅在引用 `DISCOVERY_VALIDATION_SPLIT_SPEC.md` §3 的 frozen stratum 表时出现，未外溢到结论句。
