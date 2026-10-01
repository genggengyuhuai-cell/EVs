# Reviewer R2 独立审稿报告（预投稿，互盲审稿人之一）

> 本报告以预投稿互盲审稿人 R2 身份独立形成。R2 的 emphasis brief 为蛋白组学技术可靠性。本报告不可见 R1 与 R3 的意见，也不对其推测。报告在读完不可变材料包后冻结，冻结后不再修改。

## Review setup

- **Input scope**
  仅作者方提供的不可变材料包，包括 `PROJECT_CONTEXT.md`、`manuscript_v2_1/audit/` 下的模块映射、统计声称映射、图文审计、整体科学自审、风险登记，以及 frozen 结果表（D01、D02、D03、D08、D09、M08 Firth、M09 KNN、M11 站点 LOO、M14 复制层级）和协议文档（`DISCOVERY_VALIDATION_PROTOCOL.md`、`ANALYSIS_PLAN_v2.1.md`、`STUDY_DESIGN_AUDIT.md`）。

- **Assessment boundary（评估边界，必须标注）**
  尚无组装完成的稿件正文、Methods 散文、图注与 TIFF 图。本报告所审的“稿件声称”全部来自作者方自审文档、统计声称映射与 frozen 结果表，而非逐行正文。技术行文层面的读审（language、figure legend 细节、Methods 段落完整性）受限，凡依赖正文措辞的判断均标注为“待正文组装后复核”。本报告不运行任何分析脚本，不修改 `F:\env` 既有文件。

- **Shared manuscript claim summary（材料包内一致的核心声称）**
  在一个环境暴露队列的 EV-enriched 血浆蛋白组学数据中，Discovery 子集（n=386）内 High exposure 对 Low exposure 的差异分析在 1,445 个可入组蛋白上得到 85 个 BH-FDR<0.05 的差异蛋白（DEP），在 reused within-cohort hold-out（n=129）上 83/85 方向一致、29/85 名义 P<0.05、1/85 通过候选家族 BH-FDR。整体暴露效应 0/1430 达到 BH-FDR<0.05，交互 0/1430 达到阈值。站点 LOO 与 KNN/Firth 作为稳健性层。

- **Visible evidence base**
  frozen manifest 与 integrity assertion（D01/D03/D08）、复制层级表（D08/M14）、站点组成与 LOO（M11）、检测梯度（D09）、Firth（M08）、KNN（M09）、参与者映射诊断（D01 participant mapping）、设计审计（`STUDY_DESIGN_AUDIT.md`）。

- **Missing materials affecting confidence（影响置信度的缺失材料）**
  无 Spectronaut 搜库/导出配置、无 FASTA/decoy/contaminant 注册表、无肽段层面证据、无 pooled QC 漂移记录、无 R 包版本锁定文件、无 EV 富集方法学细节与 EV 纯度标记。这些缺失直接限制蛋白组学技术可靠性判断。

## Reviewer 2

- **Overall assessment**
  这是一项纪律性很强的预注册切分设计，frozen 数字、脚本哈希、切分种子（20260925）和“锁定 85 个候选后才触碰 hold-out”的顺序在文档中可核验，作者对复制层级（85/83/29/1）的表述也异常克制。从 R2 关注的蛋白组学技术可靠性角度看，最核心的问题不在统计措辞，而在测量与采集层面。队列中两个最大站点（XZ_GG 142 人、GZ_TH 129 人，合计占 515 人的 53%）的样本分别在单一进样日（20260527、20260717）一次性采集，站点、环境与进样日期完全对齐，而主分析模型既未纳入采集日期/批次协变量，也无 pooled QC 漂移校正可查。这使得 High-vs-Low 的核心对比在相当程度上无法与采集批次/前分析效应分离。叠加无污染物/decoy 标记、上游归一化不可复原、肽段特异性证据整体缺失，85 个 DEP 的“暴露关联”目前更应被读为“在站点与批次强耦合下观测到的差异”，而非干净的暴露生物学信号。作者已在内部风险登记中承认其中大部分问题，但材料包中未见任何用于在分析上去混杂的正式证据。

- **Who would be interested in the results, and why**
  环境暴露与血浆蛋白组学交叉领域、大气/高原与湿热环境健康效应队列、以及从事大队列非靶向蛋白组学切分设计与缺失数据稳健性的方法学读者会感兴趣。研究价值在于其诚实的复制层级披露与预注册切分流程，而不在于 85 个蛋白本身的生物学确定性。临床/转化读者不应据此寻找生物标志物，因为作者已明确无外部队列、无靶向验证、无条件外推。

- **Major strengths**
  预注册切分与单一执行（种子 20260925，一次执行，26 项 integrity assertions 全过），候选锁定先于 hold-out 使用（D03_A05 no Validation input PASS）。复制层级按方向一致、名义 P、候选家族 FDR 三级分开报告，且明确禁止把 29 称为 FDR-replicated、把 129 称为 external validation。检测族（Firth，2/3054）与丰度族（1445）分开建模，KNN 敏感性（k=10，Pearson 0.9311，方向一致 92.3%）作为缺失稳健性层位置正确。计算可追溯性强，rawdata 经 P1/P2/P3 到 `sample_mapping_FINAL.xlsx` 的链路有 sha256 记录。

- **Major Concerns**

### R2-M1
- **Concern ID** R2-M1
- **Severity** Major
- **Blocking** Yes
- **Axis** statistical-rigor / experimental-design（批次与混杂）
- **Claim pointer** R3 声称 85 个 High-vs-Low DEP 为暴露关联蛋白，见 `PROJECT_CONTEXT.md` 第 2 节 frozen numbers 与 `STATISTICAL_CLAIM_MAP.csv` C05。
- **Evidence pointer**
  `descriptive/discovery_validation/D01_discovery_eligibility/D01_participant_mapping_diagnostics.csv`（样本 ID 前缀即进样日期，XZ_GG 全部 142 条为 20260527，GZ_TH 全部 129 条为 20260717）；`descriptive/analysis_v2.0/M11_site_robustness/M11_site_composition.csv`（XZ_GG 30/66/46，GZ_TH 46/31/46）；`docs/protocol/STUDY_DESIGN_AUDIT.md` 第 39 行与第 324 行（“Two large sites align with individual acquisition dates... prevents separating those site intercepts from their acquisition-date effects”）；`D02_diagnostics.csv`（normalization=NONE，无批次协变量）。
- **Concern**
  两个最大站点各自在单一进样日完成全部样本采集，站点与进样日期/批次完全共线。XZ_GG 偏 Low exposure（66 Low 对 30 Control），GZ_TH 偏 Hot-humid 且对照/暴露近乎均分。High-vs-Low 对比的相当一部分变异来自这两个单日批次，而非暴露本身。主模型仅 log2(PG.Quantity)、无额外归一化、未把进样日期或 tube/hold-time 作为协变量，材料包中也无 pooled QC 漂移校正或 ComBat 类去批次证据。协议第 2 节虽提醒“进样/处理日期不应自动等同于独立 MS 批次”，但设计审计自身结论是二者在这两个站点上不可分离。
- **Why it matters**
  若 85 个 DEP 中相当比例由采集日漂移、柱效或前分析时间驱动，则“暴露相关蛋白”这一核心声称在测量层面未被建立。reused hold-out 与 Discovery 来自同一批进样日，无法在内部去混杂；LOO 也正是因为站点与日期共线而无法把地理 biology 与处理效应分开。
- **Resolution test**
  在不重跑冻结数字的前提下，作者需至少提供以下之一并写入正文。其一，在多进样日站点子集内重做 High-vs-Low，报告 85 个 DEP 的方向与显著性保留情况。其二，把进样日期、Tube_Mixing、Plasma_HoldTime 等可得处理变量作为协变量加入模型，报告 85 个 DEP 的效应位移。其三，展示 PCA/UMAP 按进样日与按 group 的分离程度，并给出 pooled QC（如有）的日内漂移量。若以上均不可行，正文必须把 85 明确降级为“站点与采集批次未分离的发现集”，不得作为暴露关联主结论。

### R2-M2
- **Concern ID** R2-M2
- **Severity** Major
- **Blocking** Yes
- **Axis** data-resource-quality（蛋白鉴定与污染物控制）
- **Claim pointer** R1/R2 声称在 3,817 个原始蛋白组基础上经资格规则得到 1,445 个 Discovery 可入组蛋白，见 `D01_manifest.txt`（raw_protein_count=3817，eligible_protein_count=1445）。
- **Evidence pointer**
  `STUDY_DESIGN_AUDIT.md` 第 247、249、251 行与 B3（第 72 行，评级 MAJOR，“No explicit contaminant/decoy flag... no verified technical-contaminant removal”）；第 25 行（“Upstream normalization is not fully recoverable; PG.Quantity alone cannot establish whether normalization was enabled”）。材料包中无 Spectronaut 搜库配置、无 FASTA、无 contaminant 注册表。
- **Concern**
  导出仅含 7 个注释字段，无 contaminant/decoy 标记，`PG.Qvalue` 的定义与聚合方式未建立，`PG.CV` 不能被当作技术重复 CV。材料包未记录鉴定 FDR、decoy 处理、搜库数据库与上游 Spectronaut 归一化设置。B3 被作者方审计评为 MAJOR。这意味着 1,445 个蛋白组的假鉴定率与污染物残留无法从现有材料核验。
- **Why it matters**
  蛋白组学发现的可信度首先取决于鉴定层面的假阳性与技术污染物。在无 contaminant 注册表、无鉴定 q 值定义的情况下，85 个 DEP 中是否混入 keratin、trypsin、BSA 或共分离高丰度血浆蛋白无法判断。这直接削弱 universe 的可信度，进而影响 FDR 族的分母。
- **Resolution test**
  正文 Methods 必须补报搜库数据库、decoy 策略、蛋白鉴定 FDR 阈值、contaminant 注册表（数量、移除理由、保留数），并明确 `PG.Qvalue` 与 `PG.CV` 的计算口径。若搜库配置确已不可得，须在 Limitations 中明确写出“鉴定层面 QC 记录不完整”，而不得在图注或正文中暗示已完成标准 contaminant 去除。这是报告补全，不要求重新采集。

### R2-M3
- **Concern ID** R2-M3
- **Severity** Major
- **Blocking** No
- **Axis** claim-moderation（材料边界，EV-enriched 血浆蛋白组学）
- **Claim pointer** 研究身份为“environmental-exposure EV-enriched plasma proteomics study”，见 `PROJECT_CONTEXT.md` 第 1 节，禁止把测得蛋白称为 EV-derived。
- **Evidence pointer**
  `REVIEWER_RISK_REGISTER.csv` R01（High，无 EV purity/marker/NTA/cryoEM）、R02（Medium，共分离高丰度血浆/血小板/RBC/凝血蛋白预期）、R25（High，未做 EV 表征）；`STUDY_DESIGN_AUDIT.md` 第 241 行（“Do not infer an EV study from cellular or vesicle-associated proteins in plasma”）。
- **Concern**
  材料包正确地把身份限定为 EV-enriched 而非 pure EV，但在无任何 EV 富集方法学细节、无 marker/粒径/proteolipid 对照的情况下，论文标题与摘要若保留“EV”字样，读者极易把测得蛋白读为 EV 来源。共分离血浆蛋白（ALB、免疫球蛋白、载脂蛋白、补体、纤维蛋白原）在 `STUDY_DESIGN_AUDIT.md` 第 235 行被明确保留为血浆生物学而非污染物，这一区分必须在正文中说清。
- **Why it matters**
  这不是要求作者补做 EV 实验（R25 已注明 would strengthen but not block），而是要求措辞与材料边界严格对齐。一旦正文把 85 个 DEP 表述为“EV 相关蛋白”或暗示囊泡来源，整个材料身份即被越界。
- **Resolution test**
  标题/摘要/Results 统一使用“EV-enriched plasma proteomics”，Methods 写明富集流程，Discussion 明确声明无 EV 纯度验证、不做细胞来源推断、共分离血浆蛋白按血浆蛋白组解释。作者方风险登记已规划此措辞，正文组装时须落实，R2 在正文稿上会复核。

### R2-M4
- **Concern ID** R2-M4
- **Severity** Major
- **Blocking** No
- **Axis** statistical-rigor（复制逻辑解读克制）
- **Claim pointer** R4 复制层级 85/83/29/1，见 `STATISTICAL_CLAIM_MAP.csv` C06/C07/C08 与 `M14_replication_hierarchy.csv`。
- **Evidence pointer**
  `D08_replication_summary.csv`（N_locked=85，方向一致 83，名义 29，FDR 1）；`M14_replication_hierarchy.csv`（每级均标注 reused within-cohort hold-out; NOT external validation）；`STUDY_DESIGN_AUDIT.md` 第 107 行（同一批人此前已用于 515 人历史分析，应表述为“prespecified split-sample replication within a previously explored cohort”）。
- **Concern**
  数字本身报告诚实，R2 无异议。但从技术可靠性看，reused hold-out 的 129 人与 Discovery 共享同样的站点、进样日与前分析结构，因此 83/85 的方向一致与 1/85 的 FDR 命中并不能独立排除 R2-M1 的批次混杂。即唯一通过候选家族 FDR 的那一个蛋白，其“复制”也发生在同一套进样日结构上。
- **Why it matters**
  若正文把 83/83 方向一致作为“信号稳健”的论据，而不说明 hold-out 与 Discovery 共享批次，读者会高估复制强度。1/85 的正式复制本就很弱，再叠加批次共享，其解释力应进一步收敛。
- **Resolution test**
  正文在呈现复制层级时，须同句说明 hold-out 与 Discovery 同队列、同站点、同进样日结构，方向一致率只反映切分内一致性，不构成对批次混杂的独立检验。1/85 须表述为 formal replication 的上限，而非成功复制的证据。

- **Minor Comments**

### R2-m1
- **Concern ID** R2-m1
- **Severity** Minor
- **Axis** reproducibility
- **Affected element** Methods 软件环境与数据可用性
- **Evidence pointer**
  仓库根目录无 renv.lock、无 DESCRIPTION、无 sessionInfo、无 Dockerfile；仅 `descriptive/requirements.txt` 含 numpy/pandas/matplotlib/openpyxl 四个 Python 包。R 侧用到 limma、logistf、ranger、xgboost、fgsea/cameraPR，但无版本锁定。
- **Issue**
  frozen 表记录了脚本与输入的 sha256，但 R 包版本与 R 版本未固定，第三方读者难以精确复现 logistf、cameraPR 等结果。
- **Required correction**
  在 Methods 或补充材料附 R sessionInfo 或 renv.lock，列出 R 版本与关键包版本；Python 侧已有 requirements.txt，R 侧需补齐。

### R2-m2
- **Concern ID** R2-m2
- **Severity** Minor
- **Axis** data-resource-quality（肽段特异性）
- **Affected element** Methods QC 与 D09 补充表
- **Evidence pointer**
  `D09_unique_peptide_support.csv`（85 行 Unique_peptide_count 全空，Peptide_support_status=SOURCE_NOT_AVAILABLE）；`D09_manifest.csv`（peptide_source=SOURCE_NOT_AVAILABLE）；`ANALYSIS_PLAN_v2.1.md` 第 4 节（v2.1 主动移除 unique-peptide 范围）；`M14_frozen_status.csv`（Peptide evidence=SOURCE_NOT_AVAILABLE）。
- **Issue**
  v2.1 主动移除肽段层面分析是有意识的决策，但蛋白组学惯例要求报告单独特异肽段量化的蛋白比例。85 个 DEP 中有多少仅由 1 条 unique peptide 支撑，现有材料无法回答。
- **Required correction**
  正文 Methods 明确声明肽段层面特异性数据在本项目不可得，因此未做 single-peptide 质控；D09 补充表若保留全空的 unique-peptide 列，应删除或显式标注为不可用，避免读者误以为已完成检查。

### R2-m3
- **Concern ID** R2-m3
- **Severity** Minor
- **Axis** statistical-rigor（CI 近似）
- **Affected element** D08 hold-out 95% CI
- **Evidence pointer**
  `STUDY_DESIGN_AUDIT.md` B10（MODERATE，`dv_shared.R:78-88` 用 abs(log2FC/t) 重构 SE 并以 qnorm(.975) 取 CI，而 P 值用 moderated t）。
- **Issue**
  hold-out 的效应 CI 为正态近似，与 moderated t 的 P 值不完全同源，零效应蛋白可能出现 0/0。
- **Required correction**
  在 Methods 或补充说明中写明 hold-out CI 为正态近似；若后续授权修订，改用 limma 的 moderated CI，但不得据此重算冻结的 29/1 计数。

### R2-m4
- **Concern ID** R2-m4
- **Severity** Minor
- **Axis** figures-and-tables（universe 口径）
- **Affected element** Table 1 与 Methods 中蛋白 universe 数字
- **Evidence pointer**
  材料包出现四个相近但不同的蛋白数，分别为 D01 eligible 1,445（`D01_manifest.txt`）、pathway tested 1,434（`PROJECT_CONTEXT.md` 第 6 节）、M05/M11 abundance 1,430（`M11_manifest.csv`）、M08 detection 3,054（`M08_Firth_manifest.csv`）。
- **Issue**
  四个数字分属不同分析族（Discovery 可入组、pathway 映射、丰度估计、检测检验），若正文不逐一标注口径，读者易混淆。
- **Required correction**
  在 Table 1 或 Methods 用一句话明确每个数字对应的分析族与分母，特别是 1,445 与历史 1,434 的关系（`D01_manifest.txt` 已注明 historical_1434_used_as_input=NO）。

### R2-m5
- **Concern ID** R2-m5
- **Severity** Minor
- **Axis** experimental-design（前分析异质性）
- **Affected element** Methods 样本处理与 Limitations
- **Evidence pointer**
  `D01_participant_mapping_diagnostics.csv`（Tube_Mixing 对 FJ_FQ F 系列全为 Insufficient；Plasma_HoldTime_h 按站点分 0、2、>6、4h、Unknown；多条 Note 标注 hemolysis observed/suspected hemolysis 但 mapping_status=PASS 保留；单样本 missing_pct 最高约 72%）。
- **Issue**
  前分析变量（混匀、血浆放置时间、溶血）按站点/批次系统分化，且溶血样本未排除。这些与 R2-M1 的批次问题同源，但本身可作为协变量或局限性透明报告。
- **Required correction**
  Methods 报告 Tube_Mixing、Plasma_HoldTime、溶血标记的分布与处理规则；说明溶血样本为何保留，或将其纳入 R2-M1 建议的协变量敏感性分析。

### R2-m6
- **Concern ID** R2-m6
- **Severity** Minor
- **Axis** reproducibility（样本映射链路）
- **Affected element** Methods 数据处理流程
- **Evidence pointer**
  `PROJECT_CONTEXT.md` 第 3 节（P1/P2/P3 → sample_mapping_FINAL）；`D01_manifest.txt`（mapping_sha256=5971f585...）；`D01_participant_mapping_diagnostics.csv`（全部 mapping_status=PASS，Resolution_method 为 P1_UNIQUE_NAME 或 BLOCK_BOUNDARY_AND_SAMPLE_ID）。
- **Issue**
  样本映射链路本身闭合且有哈希，是优点。但进样日期隐含在样本 ID 前缀中，未作为显式元数据列进入分析矩阵。
- **Required correction**
  Methods 说明样本 ID 编码规则，并把进样日期作为显式列保留在补充元数据中，供 R2-M1 的去混杂分析使用。

- **Technical failings that need to be addressed before the case is established**
  R2-M1（站点与进样日完全共线且无去批次证据）与 R2-M2（无 contaminant/decoy/鉴定 QC 记录）。两者均直接影响 85 个 DEP 作为“暴露关联蛋白”的测量有效性，须在正文组装前以分析补全或明确降级措辞回应。

- **Assessment against Nature-style criteria**
  - originality 一项，在预注册切分与诚实复制层级的披露上有方法学价值，但生物学发现本身受单队列、无外部验证限制，原创性中等。
  - scientific importance 一项，85 个蛋白的科学分量有限，因为正式复制仅 1/85 且无外部队列，更像方法学与稳健性示范，而非 outstanding discovery。
  - interdisciplinary readership 一项，环境暴露与蛋白组学交叉读者会关注，但结论需降级为 hypothesis-generating。
  - technical soundness 一项，当前最大短板集中在 R2-M1 与 R2-M2。
  - readability for nonspecialists 一项，待正文组装后评估，材料包内声称映射与术语纪律（High land/Hot-humid）为良好基础。

- **Recommendation posture**
  以 R2 的蛋白组学技术可靠性视角，本工作在统计纪律上值得肯定，但在测量与批次层面尚未建立核心声称。建议作者在回应 R2-M1 与 R2-M2 后再进入实质送审。R2 不就期刊适配或最终录用下结论，该判断属于编辑职权。R2 的立场是 major revision，且 R2-M1 与 R2-M2 在补全前构成 blocking。

## Risk / unsupported claims（R2 视角）

- 85 个 DEP 目前不能被读作暴露生物学信号，因为进样日与站点完全共线且无去混杂证据，见 R2-M1。
- 1/85 的 FDR-supported 复制不能读作独立验证，因为 hold-out 与 Discovery 共享同一站点/进样日结构，见 R2-M4。
- 85 个 DEP 的鉴定层面假阳性与污染物残留目前不可核验，见 R2-M2。
- 本报告未读组装后正文，凡涉及措辞、图注、Methods 完整性的判断均待正文稿复核；R2 不对 R1、R3 的意见做任何推测或回应。
