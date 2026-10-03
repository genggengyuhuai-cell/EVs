# 研究设计审计（experimental-design）

> 审计视角：experimental-design 技能的 Fisher 三原则（随机化、重复/伪重复、区组/局部控制）与"8 个毁掉研究的错误"。
> 项目性质：**已收集的观察性队列**，本审计为**回溯性设计审计**——判定既有设计能否支撑其声称，而非收集前设计。
> 审计方式：纯静态只读；未运行任何分析脚本，未修改 `F:\env` 任何既有文件。所有数字逐字引自仓库内文件原文并标注出处。
> 术语：稿件措辞用 **High land / Hot-humid**；内部键 `High-pressure/high-altitude / Humid-hot`、`Short / Long dose` 仅出现在 frozen 结果表。

---

## 1. 审计范围与材料

**权威身份边界（PROJECT_CONTEXT.md，不得推翻）**：
- 主身份 = 环境暴露 × **EV-enriched 血浆蛋白组学**研究；材料措辞为 EV-enriched plasma（NOT 纯 EV 蛋白组；共分离血浆蛋白与前分析效应为已承认局限）。
- NOT 主身份：生物标志物发现/预测建模/机制验证研究。
- Frozen 数字链：519 → **515**（Control 153 / Low 186 / High 176）→ Discovery **386**（种子 20260925 前瞻确定性划分）→ 复用 hold-out **129**（同一队列，NOT 外部/独立验证）。
- 复制层级：85 Discovery DEPs → 83/85 同向 → 29/85 名义 P<0.05 → **1/85** 候选家族 BH-FDR<0.05。
- 交互：0/1,430 Group×Environment 过 BH-FDR<0.05；环境分层 concordance 为描述性，**不是**交互检验。
- 站点 LOO = 稳健性分析，NOT 复制/外部验证。

**本次实际读取的材料（只读）**：
- `PROJECT_CONTEXT.md`；`docs/protocol/STUDY_DESIGN_AUDIT.md`（88KB，Grep+分段）、`ANALYSIS_PLAN_v2.0.md`、`ANALYSIS_PLAN_v2.1.md`、`DISCOVERY_VALIDATION_PROTOCOL.md`、`DISCOVERY_VALIDATION_SPLIT_SPEC.md`。
- `descriptive/`：`design_A/B/C_*.csv`、`design_matrix_columns.csv`、`design_matrix_diagnostics.csv`、`design_confounding_tables.xlsx`、`region_environment_counts.csv`、`condition_by_TREAT1_counts.csv`、`group_by_TREAT1_counts.csv`、`MS_batch_proxy_by_TREAT1_counts.csv`、`group_by_MS_batch_proxy_by_TREAT1_counts.csv`、`group_by_MS_batch_proxy_counts.csv`、`进样时间_summary.csv`、`detection_gradient_counts.csv`、`condition_summary.csv`、`group_summary.csv`、`dose_defined_metadata.csv`（表头+样例行）、`covariate_QC/input_availability.csv`、`exposure_covariate_balance.csv`、`README_METHODS.md`。
- 上游链路：`code/P3.py`（样本映射逻辑，只读未运行）。
- 既有自审（对照基线）：`manuscript_v2_1/audit/EXPERIMENTAL_DESIGN_REVIEW.md`、`WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`。

**判定框架的映射**：本队列无"随机化分配到暴露"（见 Z2），Fisher 随机化原则仅作用于 386/129 的**分析子集划分**（种子 20260925），不作用于暴露分组；重复/伪重复的关键风险在**站点聚类**与**批次-环境别名**；区组/局部控制的关键缺口在**采集顺序/批次未随暴露分层**。

---

## 2. 独立判定（与既有 EXPERIMENTAL_DESIGN_REVIEW.md 差异对比表）

| 设计维度 | 既有 EXPERIMENTAL_DESIGN_REVIEW 的判定 | 本次独立审计的增量/修正 | 判定 |
|---|---|---|---|
| 队列规模 515 / 153-186-176 | "Reasonably balanced"（§2.1） | 一致；补充：519→515 的 4 例排除 = 无授权 control/low/high 剂量样本（unknown），与 `condition_by_TREAT1_counts.csv` unknown=湿热1+高海拔3 吻合 | 一致 |
| 386/129 复用 hold-out | "Same cohort, later-defined… direction concordance inflated… must state explicitly"（§2.1） | **强化**：既有 review 称"later-defined"，但协议明确"Historical N=515 analysis preceded the split, D08–D10 have since examined Validation"（`ANALYSIS_PLAN_v2.0.md:43`；`STUDY_DESIGN_AUDIT.md:37`）——129 不仅同队列，且在 v2.1 前瞻划分前已被既往全队列 256 分析与 D08–D10 触达 | 既有覆盖方向，本次补时序证据 |
| 暴露定义 | "Control/Low/High 是暴露类别标签，非连续剂量；应避免 dose 措辞"（§2.2） | 一致；补充暴露赋值依据 = 是否接受环境防护（protected lower vs unprotected higher target exposure，`STUDY_DESIGN_AUDIT.md:16,38`），为**观察性工作场所/防护类别**，无个体环境测量值 | 一致并补赋值机制 |
| High land vs Hot-humid | "is environment, not exposure; partially confounded with site"（§2.2, §2.4） | **重大强化**：既有措辞为"partially confounded"，但定量证据显示 8 个 MS 批次中 **6 个为单一环境纯批**，两大站点各等于单一采集日，环境轴与采集时代近乎完全别名（见 Z1） | 既有定性，本次补定量 |
| 站点结构 / LOO | "Sites are not independent replication arms; LOO = direction stability only"（§2.3） | 一致；补充稀疏/幽灵格子定量（XZ_YB 10/0/0、XZ_YA 2/19/1）与 9 站点聚类推断效力弱（见 Z5） | 一致并补定量 |
| 前分析变量 | 表格列"Processing batch not explicitly modeled / MS run order not reported as randomized"（§3.3） | **重大强化**：补出前分析变量 ~80% Unknown 且 Tube_Mixing "Insufficient" 随暴露级单调上升（4.6%/7.5%/13.1%）这一**与暴露同向的前分析梯度**（见 Z3） | 既有列举，本次补偏置方向 |
| 协变量（年龄/性别等） | 未单列 | **新增**：`covariate_QC/input_availability.csv` 明示 Age/Sex/Collection_time/Region = `absent_skipped`；主模型仅调整 Environment（见 Z2） | 既有未覆盖 |
| 材料 = EV-enriched | "EV-enriched plasma proteome, magnetic-bead enriched; not pure EV"（§3.1） | **发现文档冲突**：`STUDY_DESIGN_AUDIT.md:18` 仍作 "Plasma, not EV-enriched plasma; other preparation details are unavailable"，与 PROJECT_CONTEXT/既有 review 的 EV-enriched 口径不一致（见 m1） | 既有未识别此冲突 |
| 随机化/设盲 | （未单列章节） | **新增判定**：无暴露随机化（`ANALYSIS_PLAN_v2.0.md:9`；`STUDY_DESIGN_AUDIT.md:91` 明确"random allocation to analysis subsets, **not** randomized exposure assignment"）；全库无任何 MS 进样顺序随机化/分配隐藏/设盲记录 | 既有未单列 |
| 环境分层 concordance | "descriptive concordance, not effect modification"（§2.4） | 一致；与 frozen 边界"0/1,430 交互过 BH-FDR<0.05"吻合 | 一致 |

**结论**：既有 review 在"不能外部验证 / 不是剂量反应 / 不是纯 EV / 无机制"四条主线上判断正确且与 frozen 边界一致；本次审计的增量集中在三处——(a) 把"环境与站点部分混杂"**定量升级为环境与采集时代近乎别名**；(b) 补出**与暴露同向的前分析梯度**与**年龄/性别协变量结构性缺失**；(c) 识别**材料身份文档口径冲突**。

---

## 3. 分级发现清单

### 3.1 阻断（Blocker）

无。

**理由**：在 frozen 身份（观察性、队列内发现、EV-enriched 血浆）之下，稿件被允许主张的命题（队列内 High-vs-Low 关联发现 + 队列内方向一致性 + 多方法稳健性）在结构上均可回答，无一项因设计缺陷而不可估。下述"重大"风险只有在稿件**越界措辞**（称外部验证/因果/EV 纯品/环境主效应）时才升级为阻断；而 PROJECT_CONTEXT 与既有 review 已明确禁止此类越界。

### 3.2 重大（Major）

- **[重大] Z1：High land vs Hot-humid 环境轴与 MS 采集时代/批次近乎完全别名，"环境主效应"不可识别**
  - 证据指针：
    - `descriptive/design_confounding_tables.xlsx` 工作表 `batch_by_condition`：`20250913` 高海拔0/湿热50；`20250914` 0/69；`20251026` 0/12；`20251104` 0/2；`20260527` 142/0；`20260717` 0/123——**8 批中 6 批为单一环境纯批**；唯二跨环境批为 `20251001`（高海拔93/湿热23）与 `20251107`（高海拔1/湿热0）。
    - 同文件 `group_by_batch`：GZ_TH 123 例全部落在 `20260717`；XZ_GG 142 例全部落在 `20260527`——**两大站点各等于单一采集日**。
    - `descriptive/进样时间_summary.csv`：2025 批样本检出蛋白中位数 2136.5/2229/2258/2125，2026 批 1890（20260527）/1836（20260717）；缺失百分比 2025 批约 39%–46%，2026 批 48.3%/50.3%——**采集时代与检出深度/缺失率系统性相关**。
    - `docs/protocol/STUDY_DESIGN_AUDIT.md:39`："Two large sites align with individual acquisition dates… neither a rich model nor leave-one-site-out analysis can identify geographic biology separately from perfectly aligned processing factors."；同文件 `:324` 点名 "GZ_TH with 20260717 and XZ_GG with 20260527 prevents separating those site intercepts from their acquisition-date effects."
  - 影响：环境（湿热 vs 高海拔）与采集时代（2025 Fujian 批 vs 2026 Tibet/Guangzhou 批）高度共线，环境主效应与技术时代效应无法分解；环境调整后的剂量估计仍部分依赖"环境↔时代"这一别名结构。既有 review 的"partially confounded"定性偏弱。
  - 建议：稿件将环境严格置于**稳健性/描述性**位置；不得把"环境间差异"写成干净的环境暴露主效应；环境分层 concordance 不得表述为交互或环境效应（与 frozen"0/1,430 交互"一致）；方法学需明示"站点/采集日与环境对齐，二者不可分离"。

- **[重大] Z2：观察性暴露分组，且年龄/性别/临床协变量结构性缺失，主模型仅调整 Environment**
  - 证据指针：
    - `docs/protocol/ANALYSIS_PLAN_v2.0.md:9`："Exposure assignment has not been established as randomized; associations must not be written as causal effects or mechanisms."
    - `docs/protocol/STUDY_DESIGN_AUDIT.md:91`："This is random allocation to analysis subsets, **not randomized exposure assignment**."
    - `descriptive/covariate_QC/input_availability.csv`：`Age / Sex / Collection_time / Region` 状态均为 `absent_skipped`；仅 `Acquisition_date(进样时间) / Environment(condition) / Cohort_group(group) / Tube_Mixing / WoleBlood_oldTime / Plasma_HoldTime_h` 为 available。
    - `STUDY_DESIGN_AUDIT.md:75`（B6）："Age/Sex are explicitly absent_skipped… lacks BMI, smoking and routine clinical covariates… retain environmental adjustment and acknowledge residual confounding; do not claim comprehensive adjustment."
    - 暴露赋值机制：`STUDY_DESIGN_AUDIT.md:16,38`——Low = 接受环境防护的较低目标暴露，High = 未防护的较高目标暴露；Control<Low<High，不等距，非纵向。
  - 影响：暴露由观察性防护状态决定（非随机），且无可调整的年龄/性别/吸烟/BMI/用药等常见混杂因子；"暴露-蛋白关联"只能作**条件关联**，残余混杂方向与大小不可量化。
  - 建议：全文统一用"association with exposure category / High-vs-Low exposure contrast"，禁止 causal/effect/mechanism/attributable 措辞；方法学明示"未采集年龄/性别等个体协变量，主模型仅调整 Environment"；不得用 site/date 调整后声称混杂已消除（`STUDY_DESIGN_AUDIT.md:144` 原话）。

- **[重大] Z3：前分析变量约 80% 缺失，且 Tube_Mixing "Insufficient" 比例随暴露级单调上升；MS 进样顺序随机化无记录**
  - 证据指针：
    - `descriptive/covariate_QC/exposure_covariate_balance.csv`：`Tube_Mixing=Insufficient` 在 Control/Long 体系下为 7/153=4.6%、14/186=7.5%、23/176=13.1%（L59-67）；`Tube_Mixing=Unknown` 约 49.7%/52.2%/52.3%。
    - 同文件 `Plasma_HoldTime_h=Unknown`：Control 125/153=81.7%、Short 149/186=80.1%、Long 147/176=83.5%（L83-88）；`WoleBlood_oldTime=Unknown` 约 68%–72%（L74-82）。
    - 全库 Grep `random|blind|run order|进样顺序` 于 `descriptive/` 与 `docs/protocol/`：除 UMAP `init="random"` 与 ML 种子外，**无任何 MS 进样顺序随机化、分配隐藏或设盲记录**；`进样时间` 字段即批次代理日期（如 `20250913`），无更细 run-order。
    - 既有 review §3.3 已列"Processing batch not explicitly modeled / MS run order not reported as randomized / Freeze-thaw / Storage time not reported"。
  - 影响：对应"毁掉研究错误#5：批效应被误当生物学"与#6 边缘/位置效应。前分析失控样本比例随暴露级上升，可能与 High-vs-Low 信号同向混杂；保留 NA 的主分析不能消除 missing-not-at-random 偏置。
  - 建议：方法学如实声明前分析记录缺失率与无进样顺序随机化；把前分析/批效应列入局限与敏感性（批固定效应 model B 已纳入，见 `design_matrix_columns.csv`）；不得把缺失/检出梯度差异归因为暴露。

- **[重大] Z4：复用 129 在 v2.1 前瞻划分前已被既往分析触达，方向一致性被同队列前分析与环境 inflated**
  - 证据指针：
    - `docs/protocol/ANALYSIS_PLAN_v2.0.md:43`："Historical N=515 analysis preceded the split… before D08–D10 evaluation… New ML must call the 129 **reused within-cohort hold-out evaluation**… disclose prior analytical use and never call it untouched or external validation."
    - `STUDY_DESIGN_AUDIT.md:37`："the 129 participants are no longer an untouched test resource… it cannot restore blindness or become external validation by renaming the split."
    - `PROJECT_CONTEXT.md:24-34`：Reused hold-out 129（same cohort; NOT external/independent validation）；复制层级 85→83/85→29/85→1/85。
  - 影响：386 与 129 同招募人群、同站点、同平台、同处理批次；83/85 同向率相对真实外部复制被抬高；唯一过多重校正的单蛋白复制为 1/85。
  - 建议：稿件将 129 命名为"reused within-cohort hold-out"，明示既往分析触达史；复制结果表述为"队列内稳定性"，外部/独立验证需新队列（frozen 边界）。

- **[重大] Z5：站点×剂量存在稀疏/幽灵格子，站内剂量效应不可估；9 站点聚类推断效力弱**
  - 证据指针：
    - `descriptive/group_by_TREAT1_counts.csv`：XZ_YB = control 10 / low 0 / high 0（**仅对照，无暴露者**）；XZ_YA = control 2 / low 19 / high 1（**high 仅 1 例**）；FJ_PT = 4/10/12；XZ_YB unknown 2。
    - `region_environment_counts.csv`：9 站点规模极不均（GZ_TH 123、XZ_GG 143 vs FJ_PT 26、XZ_YB 12、XZ_YD 28、XZ_YA 22）。
    - `STUDY_DESIGN_AUDIT.md:320`："do not include a phantom exposed XZ_YB cell. XZ_YA's 2/19/1 composition makes its extreme-looking estimates unreliable."；`:318`："nine sites and four/five per environment provide limited support for variance estimation… ordinary cluster-robust SEs based on nine clusters also do not automatically solve inference."
  - 影响：XZ_YB 无暴露格子使站内 High-vs-Low 不可估；LOO 方向稳定不能证明站点间效应同质；站点水平外推不成立。
  - 建议：稿件明示稀疏格子与"幽灵暴露格子"；站点效应仅作 influence/robustness；不把任一站点当独立复制臂；不做 9-cluster 广义外推推断。

### 3.3 次要（Minor）

- **[次要] m1：材料身份文档口径不一致——EV-enriched vs "Plasma, not EV-enriched"**
  - 证据指针：
    - `PROJECT_CONTEXT.md:13-15`："environmental-exposure EV-enriched plasma proteomics study… Material wording: EV-enriched plasma proteomics (NOT pure EV proteome…)"。
    - 既有 `EXPERIMENTAL_DESIGN_REVIEW.md:55`："EV-enriched plasma proteome — a magnetic-bead (Mag-Net) enriched fraction from plasma."
    - 但 `docs/protocol/STUDY_DESIGN_AUDIT.md:18`："Material and unit: **RESOLVED.** Plasma, **not EV-enriched plasma**; 515 samples from 515 independent participants… Other preparation details are unavailable."
  - 影响：权威概览与协议文档对"是否 EV-enriched"口径相反；稿件方法学若不统一，审稿人会直接质疑材料身份。
  - 建议：以 PROJECT_CONTEXT frozen 边界为准统一为"EV-enriched plasma（magnetic-bead 富集）"；在方法学或勘误中说明 `STUDY_DESIGN_AUDIT.md:18` 的旧措辞为历史文档、已被 v2.1 概览取代；不得反向把材料降级为"普通血浆"而丢失 EV-enriched 框架。

- **[次要] m2：无 EV 纯度/标志物对照，共分离血浆蛋白未量化**
  - 证据指针：`EXPERIMENTAL_DESIGN_REVIEW.md:59-76`（禁用 pure EV/endosomal cargo/EV-specific biology；需承认 abundant plasma/platelet/RBC/coagulation 共分离，无 EV-marker/proteolipid/NTA/cryoEM）；`STUDY_DESIGN_AUDIT.md:241`："Do not infer an EV study from cellular or vesicle-associated proteins in plasma."
  - 影响：富集分数与共分离程度未经验证，不能主张 EV 来源或细胞释放。
  - 建议：稿件措辞保持"EV-enriched"，方法学承认无纯度对照；生物学讨论不落到"EV 释放/EV 生物学解释信号"。

- **[次要] m3：检出梯度随批次/时代系统偏移，缺失非随机且与分组相关**
  - 证据指针：`descriptive/进样时间_summary.csv`（2025 批检出中位 ~2100–2250 vs 2026 批 ~1836–1890；缺失 40% vs 48%–50%）；`detection_gradient_counts.csv`；`condition_summary.csv`（湿热 missing_pct 46.1% vs 高海拔 43.7%）。
  - 影响：NA-not-at-random 偏置与时代/环境交织；保留 NA 的主分析不能消除该偏置。
  - 建议：把检出梯度作为独立证据轴报告（既有 review §4 已把 Detection Firth 列为 Supplement），不得把检出差异读为暴露效应。

- **[次要] m4：386/129 划分仅按 Environment×Dose 分层，未按站点分层**
  - 证据指针：`DISCOVERY_VALIDATION_SPLIT_SPEC.md:15`："Site is not a stratification variable."；`:231-236`：站点平衡仅在划分冻结后作描述性 QC，不得触发重随机。
  - 影响：386 与 129 的站点构成可能不对称，129 子集内某些站点样本极少，估计精度受限（`STUDY_DESIGN_AUDIT.md:103`："No assurance of adequate power follows simply from N=129."）。
  - 建议：Table 2 报告 Discovery vs hold-out 的站点构成与标准化均差；接受 frozen 划分，不事后重平衡。

### 3.4 提示（Hint）

- **[提示] h1：剂量为 3 个不等距类别，无连续暴露测量，不能拟合斜率/ spline 作剂量反应**
  - 证据指针：`STUDY_DESIGN_AUDIT.md:154`："Three cross-sectional groups cannot reconstruct a continuous time course… Do not fit a 0/1/2 linear slope as measured dose response."；既有 review §2.2/§5。
  - 影响：High-vs-Low 是对比结果，不是单调剂量反应。
  - 建议：避免 dose-response / trend / 梯度措辞；用 exposure category / High-vs-Low contrast。

- **[提示] h2：9 个非随机抽取站点，随机截距/9-cluster bootstrap 外推力有限**
  - 证据指针：`STUDY_DESIGN_AUDIT.md:217`："With only nine sites, a cluster bootstrap is fragile… site-specific reporting is a useful transportability diagnostic, not a guarantee."；`:318` 同 Z5。
  - 影响：站点水平结论不可外推到未入组地区。
  - 建议：把站点定位为 recruited sites 的描述性稳健性，不写 population-level generalizability。

- **[提示] h3：519→515 的 4 例排除为"无授权 control/low/high 剂量"样本，需在流程图明示排除理由**
  - 证据指针：`DISCOVERY_VALIDATION_SPLIT_SPEC.md:46-51`："excluding only the four samples without an authorized control/low/high dose… Dose totals 153/186/176"；`condition_by_TREAT1_counts.csv` unknown=湿热1+高海拔3（合计4）。
  - 影响：排除非随机 QC 失败而是剂量标签缺失；流程图应注明，避免被读成质量剔除。
  - 建议：Figure 1 流程图将 519→515 标注为"4 例无授权暴露剂量标签"，与 QC 剔除区分。

---

## 4. 可进入稿件的安全措辞要点

1. **身份**：environmental-exposure **EV-enriched** plasma proteomics（magnetic-bead 富集）；不写 pure EV / EV cargo / EV-specific biology / cell-type release。
2. **暴露**：observational exposure-category association（Control / Low / High exposure）；High-vs-Low exposure contrast；不写 randomized exposure、causal effect、mechanism、dose-response slope、trend。
3. **环境轴**：High land vs Hot-humid 为 **descriptive / robustness**；"No Group×Environment interaction survived the prespecified BH-FDR threshold"（0/1,430），不写"there was no interaction"；环境分层 concordance 不写成交互或环境主效应。
4. **站点/批次**：明示"sites nested within Environment; two large sites (GZ_TH, XZ_GG) align with single acquisition dates; site and acquisition era are not separable"；站点 LOO = robustness/influence，NOT replication/external validation。
5. **复制**：129 = **reused within-cohort hold-out**，同队列、同站点、同批次；复制层级 85→83/85 同向→29/85 名义→**1/85 FDR 支持**；不写 validated / FDR-replicated proteins / external validation cohort。
6. **协变量/前分析**：明示"individual covariates (age/sex/BMI/smoking) not available; primary model adjusts Environment only; preanalytical records largely missing; MS run order randomization not documented"。
7. **ML**：fixed-85 conditional exploratory prioritization，非 unbiased generalization estimate；Boruta-style / XGBoost importance 为 descriptive/post-selection。
8. **路径**：cameraPR 195 为 representative themes，不把 195+23+39 相加；KEGG NOT_RUN。

---

## 5. 未覆盖/无法判定的边界

1. **真实暴露强度的个体测量值**：仓库内无任何个体环境暴露测量（如体温、WBGT、海拔暴露时长、热暴露积分）；暴露赋值完全来自防护类别标签（`STUDY_DESIGN_AUDIT.md:16`）。"暴露是否真的按 Control<Low<High 梯度作用于同一人群"无法从本仓库数据独立验证。
2. **EV 富集是否成功**：无 EV marker / NTA / cryoEM / proteolipid / 共分离定量数据；材料身份只能按 PROJECT_CONTEXT frozen 措辞接受，不能从仓库证据证明富集纯度。
3. **进样顺序与 plate/位置效应**：`进样时间` 仅到日期级（=批次代理），无孔板位置、孔位边缘、pooled-QC 漂移、blank carryover 记录；无法判定是否存在位置/梯度效应。
4. **前分析具体数值**：freeze-thaw 次数、储存时长/温度、离心/预澄清、抗凝剂/采血管型均无记录（`STUDY_DESIGN_AUDIT.md:20,241`）；Z3 的偏置方向只能由 ~80% Unknown 与 Tube_Mixing 梯度间接提示，无法量化偏倚大小。
5. **样本链路 P1/P2 逐行歧义解决**：仅读 `P3.py` 与 PROJECT_CONTEXT §3 链路说明，未逐行复核 P1.py/P2.py 的 ambiguous block 解析（任务要求读代码了解逻辑、不运行）；519→515=4 例与 unknown=4 的一致性已交叉印证，但逐样本映射正确性不在本次设计审计范围。
6. **设计对下游统计模型的拟合细节**：model B（含 8 个批次哑变量）全秩（`design_matrix_diagnostics.csv` rank=11, condition number 31.9）已确认可估，但批效应与环境/剂量的方差分解、ICC、设计效应 DEFF 未在仓库内计算——本审计仅判定"可估但受别名限制"，不重算统计量。
7. **既有 `EXPERIMENTAL_DESIGN_REVIEW.md` 与 `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md` 之外的稿件正文措辞**：本次审计对象为设计文档与设计表；稿件正文（manuscript 草稿）是否已按第 4 节安全措辞落笔，未逐句核对。
