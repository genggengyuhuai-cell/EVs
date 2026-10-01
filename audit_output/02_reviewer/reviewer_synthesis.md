# 跨审综合报告，analysis-v2.1 环境暴露 × EV-enriched 血浆蛋白组学

本综合在三份个别审稿报告全部冻结后独立形成，面向编辑与作者，不回传审稿人。R1 侧重统计与设计严谨性，R2 侧重蛋白组学技术可靠性，R3 侧重新颖性、意义与可复现性。三位审稿人此前互盲，本报告不修改任何一份冻结个别报告。所有数字逐字引自不可变材料包并标注出处。稿件用词按 PROJECT_CONTEXT 统一为 High land 与 Hot-humid，内部键只出现在 frozen 表。

## 综合方法与共识标注规则

把三份报告独立提出的关切归并到共享综合键。共识仅在至少两位审稿人独立提出同一底层关切时标注，并列出各自 concern ID。凡标注为共识的关切，均已回到材料包核对 claim 与 evidence 指针；指针缺失或指向错误者在本报告中点出。

## 共识优势，Consensus strengths

三位审稿人独立肯定了同一组程序性优点，这些优点构成论文可信性的基础。

- 前瞻切分与候选锁定顺序。切分以单一锁定种子 20260925 一次执行，D03 在触碰 hold-out 结局前完成 85 候选锁定，D01_manifest.txt 记录 Validation_protein_outcomes_accessed=NO。R1 称 26 项 integrity assertions 通过，R2 称 D03_A05 no Validation input PASS，R3 称 D03 exactly 85 行带 SHA-256。三位一致。
- 多重性家族显式分离。发现族、复制族、交互族、通路族各自独立 BH，未合并为单一未限定 FDR。C09、C10、C13、C20、C21、C22 在 STATISTICAL_CLAIM_MAP.csv 中分别记录各自家族。
- 复制层级诚实拆分为 85 锁定、85 可估、83 方向一致、29 名义、1 候选族 FDR。M14_replication_hierarchy.csv 每级均标注 reused within-cohort hold-out; NOT external validation。R1、R2、R3 均把这一克制披露视为核心优点。
- 作者方风险登记与声称映射已预置最危险的禁止用语，包括不得把 85 称 validated、把 29 称 FDR-replicated、把 129 称 external validation、把交互写为缺失、把 fixed-85 ML 写为泛化。三位审稿人均认可这一措辞纪律。
- 计算可追溯结构完整，repo-relative 路径、seed、manifest、universe、contract、registry 齐备，样本映射 P1/P2/P3 链路带 sha256。

## 共识阻断项，Consensus blocking concerns

严格按规则，共识阻断项要求至少两位审稿人独立对同一底层关切标注 Blocking Yes。本研究没有满足这一条件的项目。

R1 的五项 Major Concern 全部为 Blocking No。R3 的五项 Major Concern 全部为 Blocking No。仅 R2 标注了两项 Blocking Yes，分别为 R2-M1 站点与进样日完全共线且无去混杂证据，以及 R2-M2 无 contaminant 与 decoy 标记及鉴定 QC 记录。这两项在底层关切上分别与 R1-M5、R1-M2（站点与前分析混杂）以及 R1-m4（上游归一化不可见）存在主题重叠，但 R1 与 R3 均未将其判定为阻断。因此它们是 R2 技术可靠性镜头下单方面上调的严重度，不构成跨审共识阻断。

这一严重度分歧本身是综合阶段最重要的判断之一，详见下文跨审分歧。

## 其他共识重大关切，Other consensus major concerns

下列关切由至少两位审稿人独立提出，底层关切相同，但无人或仅 R2 标注阻断。

### 综合键 A，复制层级弱且 reused hold-out 不构成外部验证

涉及审稿人 ID，R1-M1、R1-M5、R2-M4、R3-M5。

底层关切为 129 人 reused hold-out 与 Discovery 共享同一队列、站点、平台与进样批次，83/85 方向一致与 1/85 FDR 命中不能独立排除批次混杂，也不构成外部验证。证据指针已核对。M14_replication_hierarchy.csv 记录 85、85、83、29、1 五级，每级均标注 NOT external validation。D08_replication_summary.csv 记录 Direction_rate_all=0.97647、Nominal_rate_all=0.34118、FDR_rate_all=0.01176。R05、R19、R26 在 REVIEWER_RISK_REGISTER.csv 中均为 High。指针真实，无缺失。

R1-M1 额外指出协议中无任何功效或最小可检测效应计算，hold-out 每组约 44、47、38 人，只能检出大效应，这是 83/85 高方向一致而 1/85 正式复制的结构性原因。R2-M4 与 R3-M5 在结论上一致，即 1/85 应表述为正式复制的上界而非成功证据。

### 综合键 B，蛋白 universe 分母存在多个相近数字，发现族分母在声称映射中错配

涉及审稿人 ID，R1-M3、R2-m4、R3-m4。

底层关切为文档中并存 3817、1445、1430、1434、1414、3054 等多个蛋白数，若正文不逐一标注口径会混淆。证据指针已核对。D01_manifest.txt 记录 raw_protein_count=3817、eligible_protein_count=1445、historical_1434_used_as_input=NO。M12_FINALIZATION_REPORT.md 第 3 节记录 1434 tested、1414 unambiguous。R2-M2 指出 M08 检测族为 3054。

需要特别指出的指针问题。R1-M3 正确识别 STATISTICAL_CLAIM_MAP.csv 的 C05 行 N 字段写 1430，而 PROJECT_CONTEXT.md 第 2 节与 D01_manifest.txt 一致记录 85 来自 1,445 Discovery-eligible 族。即声称映射表自身的 C05 分母字段与权威 D01 清单不一致。这不是读者混淆的问题，而是权威声称表把发现族分母记错。正文 Methods 必须以 1,445 为锁定 85 的 BH 分母，并把 1,430 标为丰度族、1,434 标为通路映射族、1,414 标为单基因映射数、3,054 标为检测族。

### 综合键 C，fixed-85 机器学习性能接近随机，且存在审计叙事与 frozen 表的列级矛盾

涉及审稿人 ID，R1-M4、R3-M3、R3-M5。

底层关切为 fixed-85 条件外循环 CV 的 AUROC 在测试折约 53 至 55 人上接近随机，strict nested 显示折内 DEP 数在 8 至 618 间摆动，只能作为条件敏感性而非预测效用。证据指针已核对。outer_cv_metrics.csv 表头含 lasso_auroc、en_auroc、xgb_auroc 三列，n_test 列实际取值 53、54、55，15 行 en_auroc 均有值，例如 rep_id 1 fold 1 为 0.6455。R1-M4 引用的 LASSO 0.499 至 0.775、XGBoost 0.509 至 0.786 范围与该文件一致。

需要指出的指针问题。R3-M3 指出 docs/FINAL_ML_RESULT_AUDIT.md 称 outer_cv_metrics.csv 不存在 en_auroc 列，但 frozen CSV 实际存在该列且 15 行齐全。这是审计叙事与权威结果表直接矛盾，R3 的核对属实。正文 headline ML 数字必须从 frozen CSV 重新推导，不能引用审计叙事。

### 综合键 D，软件运行环境未精确锁定

涉及审稿人 ID，R2-m1、R3-M2。

底层关切为 R 包版本与 R 版本未钉牢，Python 侧无 requirements，跨机器位级复现不被保证。R3-M2 另指出 P2/P3 样本映射含人工歧义复核步骤。证据指针来自 docs/SOFTWARE_ENVIRONMENT_REPORT.md 与 R2 对仓库根目录的扫描。此项 R3 列为 Major，R2 列为 Minor，严重度判断不同但底层关切一致。

### 综合键 E，材料身份为 EV-enriched 血浆蛋白组学，无 EV 纯度表征

涉及审稿人 ID，R2-M3，并见 R1 风险节与 R3 缺失材料节。

底层关切为测得蛋白只能称 EV-enriched，不能称 EV-derived，共分离血浆蛋白须按血浆蛋白组解释。REVIEWER_RISK_REGISTER.csv R01 与 R25 均为 High，R25 注明 would strengthen but not block。三位审稿人均认可这一边界，R2 将其单列为 Major，R1 与 R3 在风险与缺失材料中提及。指针真实。

### 综合键 F，通路计数不得跨方法相加，cameraPR 的 195 条中 Reactome 冗余度高

涉及审稿人 ID，R1 风险节、R3-m2。

底层关切为 195 cameraPR、23 ORA、39 fgsea 回答不同问题，不得相加为单一通路数，且 195 中 170 条来自 Reactome，直接报总数会放大发现。证据指针已核对。PROJECT_CONTEXT.md 第 6 节与 C20、C21、C22 均明确禁止相加。M12_FINALIZATION_REPORT.md 第 10 节第 1 条重申不得求和。R3-m2 与 R1 风险节一致。

需要指出的指针问题，见综合键 G 的 fgsea 分桶矛盾。

### 综合键 G，审计文档与 frozen 表之间存在可核验的不一致

涉及审稿人 ID，R1-m2、R3-m6、R3-M3。

底层关切为状态与审计叙事相对当前 frozen 输出过时或矛盾。已核对三处。

第一，M14_frozen_status.csv 仍写 Pathway (frozen D10) NOT_RUN_NO_APPROVED_MAPPING、ML M15 NOT_STARTED、ML M16 NOT_AUTHORIZED，但 M12_pathway_v2.1 输出与 ml_v2.1/results/outer_cv_metrics.csv 均已存在。R1-m2 属实。

第二，PROJECT_CONTEXT.md 第 9 节把 Final reproducibility audit 列为未开始，而 M12_FINALIZATION_REPORT.md 署期 2026-09-29 结论为 PASS_WITH_LIMITATIONS。R3-m6 属实。

第三，fgsea 分桶计数矛盾。M12_FINALIZATION_REPORT.md 第 6 节写 fgsea 39 条为 GO BP=5、GO MF=6、GO CC=11、Reactome=17，而 PROJECT_CONTEXT.md 第 6 节与 C22 写 3 GO BP、8 GO MF、11 GO CC、17 Reactome。总数 39 一致，但 BP 与 MF 分桶在两类权威文档间不一致。R3-M3 属实。正文若引用分桶数须先裁定以哪份为准。

## 跨审分歧，Where emphasis differs across reviewers

三位审稿人共享同一组底层关切，但在严重度与权重上有实质差异，这些差异不是事实分歧而是判断分歧。

- 阻断门槛不同。R2 把测量与鉴定层面的两个问题上调为 Blocking Yes，理由是 85 个 DEP 作为暴露关联信号在站点与进样日完全共线、且无 contaminant 与 decoy 记录时测量有效性未建立。R1 与 R3 认可这些问题存在，但判定它们可通过措辞降级、局限性披露与补充报告关闭，不阻断核心发现。这是本综合与个别报告之间最需要说明的差异。综合不把 R2 的两项阻断转写为共识阻断，因为另外两位审稿人未独立达成同等严重度；同时综合也不弱化 R2 的判断，因为其 evidence pointer（D01_participant_mapping_diagnostics 的进样日前缀、STUDY_DESIGN_AUDIT B3）经核对属实。

- R2-M1 的站点数字有一处小出入。R2 正文概述称 GZ_TH 为 129 人，但 M11_site_composition.csv 按 Control、Low、High 三列相加为 46+31+46=123。R2-M1 证据指针中逐列引用的 XZ_GG 30/66/46 与 GZ_TH 46/31/46 与表一致，故核心关切成立，仅概述总数 129 与表内合计 123 不符，提请作者核对。XZ_GG 合计 30+66+46=142，偏 Low，R2 的方向性判断不受影响。

- R1 独有的交互可识别性关切。R1-M2 指出环境对比完全跨站点，M10 的 2 自由度 Wald 检验把站点异质性与环境效应修饰混杂，"无交互存活阈值"连谨慎的零结果都支持不了。R2-M1 在站点耦合上主题相关，但针对的是批次而非交互可识别性。R3 未单独提出此点。这是 R1 从统计设计镜头发现的独有问题。

- R2 独有的鉴定层面缺口。R2-M2 指出无 Spectronaut 搜库配置、无 FASTA、无 contaminant 注册表、PG.Qvalue 定义未建立。R1 与 R3 均未从鉴定假阳性角度提出关切。这是 R2 蛋白组学技术镜头下的独有阻断项。

- R3 独有的定位与图面执行关切。R3-M1 指出 ANALYSIS_PLAN_v2.1 第 5.1、6.1、6.3 节仍使用 biomarker-development、primary prediction task、primary multivariable prioritization model 等措辞，存在滑向生物标志物或预测建模定位的风险。R3-M4 指出 FIGURE_TEXT_AUDIT.csv 中多条 ACTIVE/MANUSCRIPT 记录尚未执行，图面仍会渲染 Validation 与旧环境词。R1 与 R3 共享 universe 分母关切，但 R1 未触及图面标签执行状态。

- 广度意义的判断。三位一致认为当前 frozen 证据支持的是边界诚实的单队列发现与稳健性研究，而非突破性结果。分歧在于 R1 认为主风险是组装后的措辞，R2 认为测量层面须先补全再谈送审，R3 认为广度意义完全取决于尚未写出的引言与讨论。综合采信三人共同的底线，即广度意义目前不可从所给材料判定。

## 小修清单，Minor revision checklist

跨三位审稿人去重后的小修项，保留原始 ID 以便回查。

- 成对家族 FDR 不得合并。R1-m1，Fig2b 三个成对族 Low-Control、High-Control、High-Low 须分别标注计数与各自 BH，C10 禁止合并。
- 不得引用过时的 M14_frozen_status.csv。R1-m2，改用 ml_v2.1 与 M12_pathway_v2.1 的模块清单，或将该文件标注为已取代。
- Fig4b 展示交互效应估计分布。R1-m3，报告 35.2% 分层方向一致率为描述性，与 0/1430 阈值陈述并列。
- 明确上游归一化。R1-m4，D02_diagnostics.csv 记录 normalization=NONE、imputation=NONE，Methods 须写明是否在 D02 上游做过归一化。
- Table 3 显式列出不可估蛋白数为 0。R1-m5，D08_replication_summary.csv 记录 N_locked=85、N_estimable=85。
- 描述 Boruta-style 实现细节。R1-m6，说明 shadow 变量构造与合并二项确认检验。
- 补 R 软件环境锁。R2-m1 与 R3-M2 合并，附 sessionInfo 或 renv.lock 及 Python requirements。
- 肽段特异性数据不可得须声明。R2-m2，D09_unique_peptide_support.csv 全空且 Peptide_support_status=SOURCE_NOT_AVAILABLE。
- hold-out CI 为正态近似须说明。R2-m3，B10 记录用 abs(log2FC/t) 重构 SE。
- 前分析变量透明报告。R2-m5，Tube_Mixing、Plasma_HoldTime、溶血标记分布与溶血样本保留理由。
- 进样日期作为显式元数据列保留。R2-m6，样本 ID 前缀隐含进样日期。
- Boruta 分支只作健全性标注。R3-m1，85/85 Confirmed 不携带优先级信息。
- 通路只报代表性主题。R3-m2，完整 195 条放补充，绝不跨方法相加。
- 声明 KEGG 未运行及原因。R3-m3，C23 记录 KEGG NOT_RUN。
- 给一张 universe 分母图。R3-m4，列清 1430、1434、1445、1414 四个分母差异。
- 统一用 exposure category，不用 dose。R3-m5，说明整体暴露零结果为何引出 High-vs-Low 对比。
- 对齐可复现性审计状态表述。R3-m6，明确 2026-09-29 那份审计是否即为最终 pre-freeze gate。
- TIFF 导出前完成显示层替换。R3-M4 虽列为 Major，但其动作性质是执行已映射的标签替换，列入此处作为组装前必办动作，消除图面 Validation 与旧环境词。

## 广度兴趣与意义判读，Broad-interest and significance readout

三位审稿人一致认为，环境暴露与血浆蛋白组学交叉读者、队列蛋白组学切分设计方法学读者、以及从事发现到复制统计的读者会对本工作感兴趣。R1 明确指出在外部验证与可推广性缺口由真正新样本闭合之前，看不到非专业广度读者介入的理由。R2 建议把结论降级为 hypothesis-generating，临床与转化读者不应据此寻找生物标志物。R3 判断广度意义取决于尚未写出的引言与讨论能否把环境暴露 × EV-enriched 血浆角度立起来，在所给材料中不可评估。

综合判读为，本工作当前的科学分量是扎实的领域内增量，其方法学价值在于确定性切分、诚实复制层级与多方法稳健性对照，而非 85 个蛋白本身的生物学确定性。1/85 的正式复制上限、约 0.63 至 0.78 的条件 ML AUROC、单队列无外部验证，共同限制了广度意义。任何把论文框架成生物标志物开发、预测面板或机制验证的写法，都会越过证据。

## 建立强有力 Nature 风格论述前必须解决的最重要问题

按对核心声称的影响排序，下列问题须在稿件组装前或组装过程中关闭。

1. 站点与进样日共线的去混杂证据或明确降级。这是 R2 唯一两项阻断之一，且与 R1-M5、R1-M2 主题重叠。作者须至少在多进样日站点子集重做 High-vs-Low、或把进样日与处理变量作协变量、或展示 PCA 按进样日与按 group 的分离；若均不可行，须把 85 明确降级为站点与采集批次未分离的发现集，不得作为暴露关联主结论。

2. 鉴定层面 QC 补全或明确披露缺口。R2-M2 指出无 contaminant 注册表、无 decoy 策略、无鉴定 FDR、无 PG.Qvalue 口径。Methods 须补报搜库数据库、decoy、蛋白鉴定 FDR 阈值、contaminant 移除理由；若记录不可得，须在 Limitations 写明鉴定 QC 不完整，不得暗示已完成标准去除。

3. 发现族分母以 1,445 为准并修正声称映射。C05 的 N=1430 与 D01_manifest.txt 的 eligible_protein_count=1445 矛盾。Methods 须写明 85 由 1,445 Discovery-eligible 族 BH-FDR<0.05 锁定，并分列 1,430 丰度族、1,434 通路族、1,414 映射数、3,054 检测族。

4. 从 frozen CSV 重新推导 ML 与通路 headline 数字，订正审计叙事。包括确认 en_auroc 列可用并按协议报告 fixed-85 Elastic Net 性能，以及裁定 fgsea 分桶以 M12_FINALIZATION_REPORT 的 5 BP、6 MF 还是 PROJECT_CONTEXT 与 C22 的 3 BP、8 MF 为准。

5. 钉牢运行环境并交代人工复核。附 renv.lock 或 sessionInfo 与 Python requirements，Methods 写明 P2/P3 歧义复核规则与被人工裁定行数。

6. 执行图面显示层替换后再导出 TIFF。消除图面 Validation 标签与旧环境词 humid-hot、high-altitude、Dose-defined，使渲染读作 reused hold-out、High land、Hot-humid、exposure-defined。

7. 维持声称映射已强制的克制措辞。85 不得称 validated，29 不得称 FDR-replicated，129 不得称 external validation，交互只写 No interaction survived the prespecified BH-FDR threshold，fixed-85 ML 只作条件分析，通路不跨方法相加，材料身份统一为 EV-enriched plasma proteomics。

## 综合与个别报告的差异说明

本综合未修改任何冻结个别报告。主要差异有二。其一，R2 标注的两项 Blocking Yes 在本综合中不被列为共识阻断，因为 R1 与 R3 均未对同一底层关切标注阻断；本综合改为在跨审分歧中如实呈现这一严重度判断差异，既不转写为共识，也不弱化 R2 的证据指针。其二，本综合在核对材料包时新发现 R2 正文概述中 GZ_TH 总数 129 与 M11_site_composition.csv 合计 123 的小出入，以及 STATISTICAL_CLAIM_MAP C05 分母字段自身与 D01_manifest 不一致这一指针问题；这些是综合阶段独立核验的结果，未回写个别报告。
