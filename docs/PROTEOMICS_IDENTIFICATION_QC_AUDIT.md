# 蛋白质组学鉴定 QC 来源审计（P12，静态）

> 视角：proteomics identification provenance 静态审计。
> 方式：只读 grep / 读表 / 读代码；未运行任何脚本，未修改任何 frozen 文件。
> 权威总状态：FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED；ANALYSIS_REOPEN_REQUIRED=YES；SAFE_TO_TAG_ANALYSIS_V2_1=NO。
> 数字逐字引自仓库文件并标注出处。

## 1. 结论速览

| 判定项 | 结论 | 层级 |
|---|---|---|
| Contaminant exclusion（污染物排除） | **NO（执行层）**：cRAP 政策已起草并纸面冻结（8 个角蛋白组），但**未实际作用于 frozen 宇宙** | 仅 protein-group；projected，未执行 |
| Decoy exclusion（诱饵/反库排除） | **UNRESOLVED**：导出无 decoy/reverse 字段、仓库无 FASTA、无 target-decoy FDR 阈值记录 | PSM / peptide / protein 三层均无可核验证据 |

一句话：**冻结的 1,434 定量宇宙直接来自 3,817 原始导出按检出阈值筛选，上游未执行任何污染物或 decoy 排除步骤**；Freeze3 仅产出一份"候选清单+投影数"，未生成 Utech、未排除任何蛋白。

## 2. 证据指针清单

### 2.1 导出层（Spectronaut → PG.Quantity）

- `docs/protocol/STUDY_DESIGN_AUDIT.md:247`：主导出 = 3,817 protein groups × 519 abundance columns；7 个注释字段为 `PG.ProteinGroups, PG.Genes, PG.ProteinDescriptions, PG.ProteinNames, PG.CV, PG.Qvalue, PG.MolecularWeight`；**"No explicit contaminant/decoy field appears there."**
- `descriptive/analysis_v2.0/registry/DATA_SOURCE_AUDIT.md:31-38`：导出**缺失** `PG.Contaminant` / `PG.Decoy` / `PG.Reverse` 字段、无物种列；结论 "Source metadata does not contain explicit contaminant/decoy flags."
- 同文件 `:75-80`：全仓库检索 `*.fasta/*.fa/*.faa` 与 contaminant 命名文件 → **No FASTA files. No contaminant registry file. No cRAP list.**（该审计写于 registry 建立前，后续 cRAP 参考表系外部引入，见 2.3）
- 同文件 `:40-47`：对 accession 列检索 contaminant/reverse/decoy/BSA/trypsin/KRT/cRAP/spike/物种 → accession 列本身零命中，3,817 均为标准 UniProt accession。
- `STUDY_DESIGN_AUDIT.md:249`：导出**不提供 peptide counts / precursor counts / peptide lengths / retention times / unique-peptide evidence**；`PG.CV` 计算总体未知、`PG.Qvalue` 的定义与聚合方式未建立。
- `docs/protocol/ANALYSIS_PLAN_v2.0.md:158`：RAW MS 未提供 → Spectronaut DIA 处理（作者确认；版本/数据库/定量设置不可得）→ 上游归一化不可完全复原 → 导出 `PG.Quantity`。
- 同文件 `:169`：仓库盘点无 Spectronaut 工程、无搜库/归一化配置、无 FASTA；"Recover… identification q-value settings and search/library scope"。

### 2.2 冻结宇宙层（3,817 → 1,434 / 1,445 / 85）

- `descriptive/dose_quantitative_filtering_report.md:51-56`：按每剂量组检出率阈值筛选，**70% 主阈值 = 1,434 protein groups（is_primary=True）**；50%=1,935、60%=1,670、80%=1,214。该报告全文**无任何污染物排除步骤**，输入即 3,817 导出，输出即检出阈值宇宙。
- `PROJECT_CONTEXT.md:27`：85 DEPs 在 **1,445 Discovery-eligible proteins** 上 BH-FDR<0.05；`:94` 路径映射 universe = tested protein groups **1,434**。
- 即 frozen 主定量宇宙 1,434 与 Discovery 合格 1,445 均**不含 cRAP/角蛋白扣除**：U0=3,817 经检出阈值直接得 1,434。

### 2.3 Freeze3 污染物政策（纸面冻结，但未执行）

- `descriptive/analysis_v2.0/registry/FREEZE3_FINAL_POLICY.md:21-29`：cRAP 2012.01.01；主排除仅 8 组（4 皮肤角蛋白 KRT1/KRT2/KRT9/KRT10 + 4 毛发角蛋白 KRT31/KRT36/KRT38/KRT84）；A1 非人试剂=0、A2 非人标准=0。
- 同文件 `:64`：`Utech_primary` projected = U0 减 8 = **3,809**（标注 projected）。
- **但** `registry/FREEZE3_CANDIDATE_REVIEW.md:122-126`（Freeze3C，状态 "CANDIDATE REGISTRY — awaiting investigator review. No exclusion applied."）明确：
  - "No Utech list was generated"
  - "No Q515 or D515 was computed"
  - "**No protein was actually excluded**"
  - "No inferential analysis was run"
- 同文件 `:88-90`：8 个接触角蛋白 + 2 唾液接触蛋白（AMY1、PRH2）均标 "YES (pending investigator)"；`:104` projected Utech 3,807，均为 proposed。
- `registry/contaminant_registry_spec.md:3`：Status "DESIGN ONLY — no registry has been generated yet."
- `docs/protocol/V2_IMPLEMENTATION_GAP_AUDIT.md:144`："**No contaminant registry, no cRAP mapping, no keratin filtering. The 3,817 protein groups enter analysis without any technical-exclusion step.**"（该 gap audit 与 registry 目录并存：registry 内为候选清单，未进入执行链。）

### 2.4 Decoy / target-decoy 证据

- 全仓库 grep `decoy|reverse|REV__|CON__|target-decoy|PSM FDR|peptide FDR`：除协议规范文（ANALYSIS_PLAN_v2.0:194 定义 Category A 含 "explicit decoy/reverse entries"）与本类审计文档外，**无任何导出列、R/Python 脚本或结果表实现 decoy 标记或反库过滤**。
- `STUDY_DESIGN_AUDIT.md:233`（F. Contaminant/QC plan）：Decoy/reverse entries "Remove before revised… eligibility" 系**未来计划**措辞，非已执行动作。
- `PG.Qvalue` 虽为 Spectronaut 蛋白组 q 值字段（`DATA_SOURCE_AUDIT:28`），但 `STUDY_DESIGN_AUDIT.md:249` 要求"在设定鉴定过滤前先建立其定义与聚合方式"——即**未据此设阈值、未据此过滤**。

## 3. 判定表

| 层级 | Contaminant 证据 | Decoy / FDR 证据 | 判定 |
|---|---|---|---|
| PSM 层 | 无 PSM 级导出（`:249` 明示无 peptide/precursor 计数） | 无 PSM FDR / 无 PEP 过滤记录 | UNRESOLVED |
| Peptide 层 | 无 peptide 级导出（Unique-peptide 已从 v2.1 scope 移除，ANALYSIS_PLAN_v2.1:§4） | 无 peptide FDR / 无 unique peptide 证据 | UNRESOLVED |
| Protein group 层 | 7 注释字段无 contaminant 标记（`:247`）；cRAP 8 角蛋白清单纸面冻结但 `No protein was actually excluded`（FREEZE3_CANDIDATE_REVIEW:124）；frozen 1,434 直接来自 3,817 检出阈值 | 有 `PG.Qvalue` 列但定义/阈值未建立、未据此过滤；无 reverse/decoy 列 | Contaminant=NO（未执行）；Decoy=UNRESOLVED |

## 4. 影响与建议

- **影响**：1,434 宇宙中是否混入 keratin / trypsin / BSA / 共分离高丰度血浆蛋白无法从仓库核验；鉴定假阳性率（PSM/peptide/protein FDR）无据可查，FDR 族分母（1,445 / 1,434）的鉴定层可信度未建立。此与既有 `audit_output/02_reviewer/reviewer_R2.md` R2-M2（Blocking）一致。
- **建议（报告补全，不需重新采集）**：Methods 补报搜库数据库/物种、decoy 策略、PSM/peptide/protein 鉴定 FDR 阈值、contaminant 注册表（cRAP 版本、精确 accession 匹配数、移除数、保留数）、`PG.Qvalue` 与 `PG.CV` 的计算口径；若搜库配置确不可得，须在 Limitations 明示"鉴定层面 QC 记录不完整"，不得暗示已完成标准 contaminant/decoy 去除。
- **边界**：本审计只判定"仓库内有无证据"，不推断 Spectronaut 默认行为；不写"通常软件会自动去 decoy"。
