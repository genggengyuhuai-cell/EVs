# ROUND 2 阻断闭合 + 完整通路展示/来源审计 — 总报告

> 日期：2026-10-01。对象：`F:\env`（环境暴露 × EV-enriched 血浆蛋白组学研究，analysis-v2.1）。
> 方式：只读审计 + 确定性代码/文档修复。未运行任何分析/R/python 项目脚本；未 rerun Discovery/D08/ML/M09/M11/M12/M12B；未重算通路；未修改任何 frozen 结果数值；未重绘图形；未改 GO/Reactome 数据库；未加 KEGG；未改通路阈值；未执行 git commit/push/tag。
> 所有数字逐字引自 F:\env 文件原文并标注出处（文件+位置）。

## 0. 权威总状态（本轮统一写入所有输出）

```
FREEZE_READINESS          = BLOCKED
SUBMISSION_READINESS      = BLOCKED
ANALYSIS_REOPEN_REQUIRED  = YES
SAFE_TO_TAG_ANALYSIS_V2_1 = NO
```
模块级：fixed-85 ML = P0_REPAIRED；strict nested = REPAIR_PENDING；M09 = REPAIR_PENDING；M11 = REPAIR_PENDING；M12 = BLOCKED（BLOCKED_PENDING_RERUN）；M12B = BLOCKED_BY_M12；Fig6 = NOT_FINAL；历史 195/23/39 = PRE_REPAIR_EXISTING_OUTPUT（不得标 FINAL_FROZEN）；FGSEA_FROZEN_FAMILY = HOLD_UNTIL_M12_REPAIR_AND_RERUN；KEGG = NOT_RUN。

## 1. P26 逐条结论

### 1.1 Reproducibility（P1/P23）
- **陈旧声明**：全仓库定位 16 条 READY_TO_TAG / RERUN_READY / PASS / NO_BLOCKERS / FROZEN_COMPLETE 类陈旧表述，核心在 `docs/FINAL_REPRODUCIBILITY_AUDIT.md` §4/§14/§16/§18/§19（逐条见 `audit_output/STATUS_OVERRIDE_2026-10-01.md`）。
- **统一动作**：`PROJECT_CONTEXT.md` 顶部加权威总状态节（§0）；`docs/README.md` 顶部加 BLOCKED 横幅；`docs/FINAL_REPRODUCIBILITY_AUDIT.md` 顶部加 SUPERSEDED 横幅（原文保留，注明 2026-09-30 P0_P1_REPAIR_PLAN 已判定 BLOCKED 且 Freeze_readiness_score=1/10，见 `docs/P0_P1_REPAIR_PLAN.md:20`）；`PIPELINE_STATUS.md` 全表 FROZEN_COMPLETE 标记为待 Phase 6 终态重写（未擅改）。
- **剩余 P0/P1**（对照 `docs/P0_P1_REPAIR_PLAN.md`，4 P0 + 8 P1 确认）：P0-1/P0-2 已修（fixed-85 ML=P0_REPAIRED，`run_v2_1_ml.R` 已改，见计划 L29-45）；P0-3 未闭合（M12 mapping，见 1.2）；P0-4 文档侧已闭合（kegg_fix 移出 canonical 链，见 1.2）。P1-1/P1-2（strict nested）、P1-3（M11）、P1-4（M09）REPAIR_PENDING；P1-5（M12 estimand）随 M12 BLOCKED；P1-6（M14 演示）REBUILD_FROM_D08；P1-7（P3 身份绑定）OPEN（本轮已加契约，需重跑落 hash）；P1-8（D10 peptide）BLOCKED_REBUILD。**结论：不再有任何模块可标 READY_TO_TAG/ALL_RERUN_READY/PASS_WITH_LIMITATIONS。**

### 1.2 M12（P2/P3）
- **zero-row 确认**：是。`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R` 原 L15-16 以 `nrows=0` 读取 PRIMARY 矩阵，`tested_prots` 为空向量（P0-3 复证）。
- **修复（未运行）**：移除 `nrows=0` 完整读矩阵；加 4 条 `stopifnot` 文档化预期断言 tested=1434 / mapped=1414 / multi=15 / unmapped=5（L136-139，标注"预期值，重跑后核验"）；备份 `M12_01_mapping.R.orig.bak`；修复笔记 `M12_MAPPING_REPAIR_NOTE.md`（old behavior / root cause / code repair / expected universe / requires_rerun=YES / outputs not revalidated）。
- **universe**：历史 1434/1414/15/5 为 PRE_REPAIR_EXISTING_OUTPUT，重跑后核验。
- **KEGG**：仍 NOT_RUN（占位 CSV only，`PROJECT_CONTEXT.md` §6）。
- **kegg_fix 是否移出 canonical**：是。确认 `M12_02b_kegg_fix.R` L42 含 `download_KEGG("hsa")`、L90-132 重写 combined FDR，原属 active canonical（旧 M12_FILE_AUDIT 标 KEEP_ACTIVE）；本轮在三处移出：`PROJECT_CONTEXT.md` §4（canonical 链= M12_01_mapping.R → M12_02_ranked_ora.R → M12_03_integration.R）、`docs/ACTIVE_MAINLINE_MANIFEST.csv`、`M12_FILE_AUDIT.csv`（kegg_fix 行改 HISTORICAL_NON_CANONICAL）。脚本保留不删；canonical 重跑不得依赖 KEGG download/API/enrichment/term merge。

### 1.3 cameraPR（P5）
| Family | Was_run | Tested | Significant | FDR 列 | 结果文件 |
|---|---|---|---|---|---|
| GO-BP | YES（主分支 M12_02_ranked_ora.R，L82 硬编码 BP） | 274 | **25** | FDR_pooled（跨 BP+Reactome 合并 BH） | `ranked/M12_ranked_GO_BP.csv`、`M12_ranked_combined_FDR.csv` |
| GO-MF | YES（M12B_all.R 次要分支） | 108 | 15 | FDR（家族内 BH，未合并） | `ranked/M12_ranked_GO_MF.csv` |
| GO-CC | YES（M12B_all.R 次要分支） | 151 | 19 | FDR（家族内 BH） | `ranked/M12_ranked_GO_CC.csv` |
| Reactome | YES（主分支） | 487 | **170** | FDR_pooled | `ranked/M12_ranked_Reactome.csv`、`M12_ranked_combined_FDR.csv` |
| KEGG | NO | 0 | 0 | — | 占位 CSV |

- **195 = 25 + 170 是否文件支撑**：是。`ranked/M12_ranked_combined_FDR.csv` 仅含 GO_BP(274)+Reactome(487) 两族，FDR_pooled<0.05 计数 25+170=195。
- **准确表述**："GO-MF/GO-CC were not part of the cameraPR primary branch"（主分支仅 BP+Reactome）；MF/CC 由 M12B 次要分支补跑，显著性用家族内 FDR，不计入主 PATH-R 的 195。

### 1.4 ORA（P6）
| Family | Was_run | Tested | Significant | FDR 列 | 结果文件 |
|---|---|---|---|---|---|
| GO-BP | YES（主分支） | 154 | **3** | FDR_pooled | `ora/M12_ORA_GO_BP.csv`、`M12_ORA_combined_FDR.csv` |
| GO-MF | YES（M12B 次要分支） | 53 | 7（家族内 FDR） | FDR | `ora/M12_ORA_GO_MF.csv` |
| GO-CC | YES（M12B 次要分支） | 81 | 4（家族内 FDR） | FDR | `ora/M12_ORA_GO_CC.csv` |
| Reactome | YES（主分支） | 178 | **20** | FDR_pooled | `ora/M12_ORA_Reactome.csv`、`M12_ORA_combined_FDR.csv` |
| KEGG | NO | 0 | 0 | — | 占位 CSV |

- **23 = 3 + 20 是否文件支撑**：是。`ora/M12_ORA_combined_FDR.csv` 仅含 GO_BP(154)+Reactome(178)，FDR_pooled<0.05 计数 3+20=23。

### 1.5 fgsea（P7/P22）
| Family | Tested | `padj`（家族内 BH）显著 | `padj_pooled`（M12B_all.R L204 合并 BH）显著 |
|---|---|---|---|
| GO-BP | 274 | 3 | 5 |
| GO-MF | 108 | 8 | 6 |
| GO-CC | 151 | 11 | 11 |
| Reactome | 487 | 17 | 17 |
| 合计 | 1020 | **39** | **39** |

- **列来源**：`padj` = fgseaMultilevel 默认家族内 BH（每家族 CSV 与 combined CSV 均含）；`padj_pooled` = M12B_all.R L204 `p.adjust(fg_all$pval, method="BH")` 跨 4 族合并（仅 combined CSV 含）。
- **哪套在哪些文档/Fig6/Supplement**：`PROJECT_CONTEXT.md` §6、`STATISTICAL_CLAIM_MAP.csv` C22（其声明族为 pooled，本轮已按其家族改引 5/6/11/17 并标 HOLD）、`STATISTICAL_REPORTING_AUDIT.md:119`、Fig6b 散点（`V2_M17_figures_v2.R` L289 `fgsea_fdr = padj`）用 **padj（3/8/11/17）**；`M12_FINALIZATION_REPORT.md` §6、`M12_FILE_AUDIT.csv` L35-39（文字写 padj 但数字实为 padj_pooled）用 **padj_pooled（5/6/11/17）**。
- **本轮决定**：不裁定哪列为 frozen 口径；不改 counts/列/总数 39；标记 **FGSEA_FROZEN_FAMILY=HOLD_UNTIL_M12_REPAIR_AND_RERUN**（写入 `PATHWAY_FAMILY_AUDIT.csv` Current_trust_status 与 README）。

### 1.6 Fig6（P9）
逐 panel 数据源（`FIG6_PATHWAY_PRESENTATION_AUDIT.md`）：a_ranked = cameraPR GO-BP top 8（25 条显著中取 8，FDR_pooled 排序）；b_sensitivity = cameraPR×fgsea 一致性散点 887 点（concordance 表 1020 行剔非有限，x=cameraPR FDR，y=fgsea padj）；c_ora = ORA GO-BP 3 条；d_network = M12B GO-BP top-4 通路 × 11 边。
逐项判定：GO-BP **YES**；GO-MF **NO**（仅散点 105 点）；GO-CC **NO**（仅散点 147 点）；Reactome **NO**（仅散点 364 点）；cameraPR **YES（仅 GO-BP curated）**；ORA **YES（仅 GO-BP）**；fgsea **PARTIAL**（仅散点 y 轴）；M12B **PARTIAL**（仅 GO-BP top-4 网络）。
**已明确记录 FIG6_PRESENTATION_IS_NOT_REPRESENTATIVE_OF_FULL_PATHWAY_OUTPUT**：主分析 195 条中 170 条 Reactome 无任何 curated 面板。Fig6 = NOT_FINAL。

### 1.7 Supplement（P10）
- **MAIN**：仅 Fig6（GO-BP cameraPR 8/25、GO-BP ORA 3/3、GO-BP M12B 网络 top4）。
- **SUPPLEMENT**：**零通路图**。`figures_nature_v2.2`（193 文件）、`figures_prospective_v2.7` 按文件名检索 0 通路图命中；M12/M12B 目录 0 图形文件（34 CSV + 4 R + 2 md）。
- **RESULT_TABLE_ONLY**：Reactome cameraPR 170、Reactome ORA 20、fgsea 全族 39、ORA GO-MF/GO-CC——全部仅存在于 CSV。
- **NOT_DISPLAYED**：M12B Spearman 相关（3 CSV）、M12B 环境一致性（2 CSV）。
- **NOT_RUN**：KEGG；cameraPR 主分支未跑 GO-MF/GO-CC。

### 1.8 Proteomics QC（P12）
- **Contaminant exclusion = NO（执行层）**：cRAP 2012.01.01 政策纸面冻结（8 角蛋白组 KRT1/2/9/10/31/36/38/84），但 `registry/FREEZE3_CANDIDATE_REVIEW.md:122-125` 明示 "No Utech list / No Q515 / No protein was actually excluded"；frozen 主宇宙 1,434（`dose_quantitative_filtering_report.md:55`，70% 阈值）直接来自 U0=3,817，零污染扣除。层级：仅 protein-group 计划，执行层未落。
- **Decoy exclusion = UNRESOLVED**：导出 7 注释字段无 PG.Decoy/Reverse/Contaminant（`DATA_SOURCE_AUDIT:31-38`）；仓库无 FASTA；PG.Qvalue 列存在但定义/阈值未建立；PSM/peptide 层无导出（无 unique peptide）。三层均无可核验证据，不推测"软件通常处理"。
- 详见 `docs/PROTEOMICS_IDENTIFICATION_QC_AUDIT.md`。

### 1.9 Claims（P13/P14）
- **C05 两分母语义**：1445 = D01 Discovery-eligible 资格宇宙（`D01_discovery_eligibility/D01_manifest.txt` L23 eligible_protein_count=1445，raw 3817），是 85 DEP 的 BH 族（**正确分母**）；1430 = Q515 全队列丰度 tested universe（`M07_manifest.csv` n_proteins=1430，属 M05-M10 abundance 模型）。**最终选用 1445**。
- **C05 修复**：`STATISTICAL_CLAIM_MAP.csv` C05 行 N 1430→1445，证据指针 M03/M05（不存在的模块）→ D01 eligibility + D03 lock；Notes 引用 `docs/CLAIM_C05_RECONCILIATION.md`。
- **C16–C22 降级**（本轮新增 Blocking_module / Reason_20261001 / Required_action 三列，不删 claim 内容）：C16 fixed-85 → REPAIRED_PROVISIONAL；C17（strict nested）/ C20/C21/C22（M12/fgsea）/ C25-C27（M12B）/ C29（Fig6）→ BLOCKED_BY_REPAIR；C12（M09）/C15（M11）/C18/C19（XGBoost）→ REVIEW_REQUIRED；C22 措辞改引其声明族（pooled）实测 5/6/11/17 并标 HOLD_UNTIL_M12_REPAIR_AND_RERUN。C01-C04、C06-C11、C13/C14、C23/C24/C28/C30 保留。

### 1.10 Design（P15/P16）
- **site×date 共线是否 metadata 支持**：是，直接支持。XZ_GG≈20260527：`descriptive/group_by_MS_batch_proxy_counts.csv`（XZ_GG 行 20260527=143、其余=0）、`design_confounding_tables.xlsx`（XZ_GG 仅 20260527=142）；GZ_TH≈20260717：同两文件 GZ_TH 仅 20260717=123。M11 剂量拆分 XZ_GG 30/66/46=142、GZ_TH 46/31/46=123（`M11_site_composition.csv` L5-6）。另：8 个采集日中 6 个单一环境纯批；主模型 `07:603 ~0+dose+environment` 不含批次，批次仅敏感性 `07:623/894 SENS_add_MS_batch_proxy`。
- **允许/禁止措辞**：结论为 "site/environment and acquisition-era effects cannot be fully separated"；未写 "the 85 DEPs are caused by batch"。
- **P16 逐项**：已建模（主分析）仅 Environment；RECORDED_BUT_NOT_MODELED（主模型）= MS_batch_proxy / 进样时间（仅敏感性纳入）、Tube_Mixing、WoleBlood_oldTime、Plasma_HoldTime_h；NOT_RECORDED = processing time、time to centrifugation、freeze-thaw cycles、storage duration/temperature、injection order、run order、sample prep batch。风险：Tube_Mixing=Insufficient 随暴露 4.6%→7.5%→13.1% 单调上升。
- 详见 `docs/SITE_ACQUISITION_CONFOUNDING_AUDIT.md`、`docs/PREANALYTICAL_METADATA_AUDIT.md`。

### 1.11 Code（P2/P18/P19/P20/P21）
- **P3.py（P18）**：已加 validation gates（全部映射门 FAIL → raise fatal error 且不写 FINAL；PASS 才写）与 SHA256 provenance contract（运行期计算 processed.xlsx 与 sample_mapping_audit.xlsx 哈希写入 provenance，已有则校验、不一致 fatal；旧无哈希不伪造）。静态确认链路闭合：P1.py: processed.xlsx→sample_mapping_audit.xlsx；P3.py: processed.xlsx+audit→FINAL。备份 `P3.py.orig.bak`。未运行。
- **v21_common.R（P19）**：确认 `v21_output()` 含 `unlink(recursive=TRUE)`；已加 5 层 guard（resolve absolute path / reject drive root / reject project root / reject outside project root / reject parent traversal）。备份 `v21_common.R.orig.bak`。未做 destructive test。
- **D10（P20）**：确认 unique-peptide 传播（D09_peptide 读取→summary→merge→写 `D10_integrated_candidate_evidence.csv`）；已注释移除该传播，历史输出标 HISTORICAL_ONLY。备份 `D10_integrated_biology.R.orig.bak`。未运行。
- **M14（P21）**：确认 hard-code `n = c(85, 85, 83, 29, 1)`（原 L32）；改为从 `discovery_validation/D08_validation/D08_validation_results.csv` 动态派生（85/ESTIMABLE 85/Direction_concordant 83/Nominal 29/FDR_supported 1，数字不变）；`M14_frozen_status.csv` L3-4 状态更新为 Pathway=BLOCKED_PENDING_RERUN、ML M15=fixed-85 ML=P0_REPAIRED / strict nested=REPAIR_PENDING。备份两份。未运行。
- **active manifest（P17）**：`docs/ACTIVE_MAINLINE_MANIFEST.csv` 逐行修正真实路径（D01=根目录 `D01_discovery_eligibility.py`（Python）；D02–D10=`code/D0*.R`；M05–M17=`analysis_v2.0/code/V2_Mxx_*.R`；M15 去 `code/../../` 怪路径）并追加 Repair_Gate_20261001 状态列。
- 全部修改日志：`docs/P2_P18_P19_P20_P21_DETERMINISTIC_FIX_LOG.md`（old→new 对照）。

### 1.12 Final status
- **本轮仅 code/doc repair**：P1、P3、P13、P14、P17、P18、P19、P20、P21 + 审计文档 P5-P10、P12、P15、P16、P22、P23、P24。
- **必须未来 rerun**：M12 全链（P0-3，含 M12_02/M12_03 与 M12B 依赖，重跑后核定 195/23/39、universe、fgsea 口径并解 HOLD）；strict nested Phase 2（P1-1/P1-2）；M09（P1-4）、M11（P1-3）敏感性；M14 从 D08 重建（P1-6）；P3 身份绑定落 hash（P1-7）。
- **必须 rebuild 的 figures**：Fig6（M12 重跑后重建，Fig6=NOT_FINAL，且按 P9 结论需扩充 Reactome 呈现方可代表完整通路证据）；通路 Supplement 目前为零图，若稿件需要 MF/CC/Reactome/fgsea 全输出展示需新建。
- **是否允许 tag**：**否**。SAFE_TO_TAG_ANALYSIS_V2_1=NO；须完成 RERUN_PLAN Phase 2–6、重写 PIPELINE_STATUS、出终态复现性审计后方可解除 BLOCKED。

## 2. git 检查（P26，只读）
- `git status --short`：本轮改动 12 个既有文件（M）+ 13 个新增文件（??）；另有大量**既有**未提交改动（SVG/图形/数据/脚本，非本轮产生）。新增文件含 `docs/` 下 7 份审计/修复文档、`M12_pathway_v2.1/` 下 5 份通路专项文件、`audit_output/STATUS_OVERRIDE_2026-10-01.md`、各 `.orig.bak` 备份。
- `git diff --check`：本轮改动文件全部通过（check_exit=0，仅 CRLF 提示）；全树 diff 的 trailing whitespace 报错全部来自既有 SVG 生成文件（非本轮文件）。
- 未执行任何 git 写操作。

## 3. 本轮产物清单

| 类别 | 路径 |
|---|---|
| 本总报告 | `F:\env\audit_output\ROUND2_MASTER_REPORT.md` |
| 状态统一 | `PROJECT_CONTEXT.md`（状态节+§4/§9）、`docs/README.md`（横幅）、`docs/FINAL_REPRODUCIBILITY_AUDIT.md`（SUPERSEDED 横幅）、`audit_output/STATUS_OVERRIDE_2026-10-01.md` |
| KEGG canonical | `PROJECT_CONTEXT.md` §4、`docs/ACTIVE_MAINLINE_MANIFEST.csv`、`M12_FILE_AUDIT.csv`（kegg_fix→HISTORICAL_NON_CANONICAL） |
| M12 修复 | `M12_01_mapping.R`（修复+断言）、`M12_pathway_v2.1/M12_MAPPING_REPAIR_NOTE.md`、`M12_01_mapping.R.orig.bak` |
| 通路 family | `M12_pathway_v2.1/PATHWAY_FAMILY_AUDIT.csv`、`PATHWAY_FAMILY_AUDIT_README.md` |
| Fig6/补充展示 | `M12_pathway_v2.1/FIG6_PATHWAY_PRESENTATION_AUDIT.md`、`PATHWAY_PRESENTATION_INVENTORY.md` |
| 鉴定 QC / 混杂 / 前分析 | `docs/PROTEOMICS_IDENTIFICATION_QC_AUDIT.md`、`docs/SITE_ACQUISITION_CONFOUNDING_AUDIT.md`、`docs/PREANALYTICAL_METADATA_AUDIT.md` |
| Claims | `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv`（C05 修复+C16-22 降级+3 新列）、`docs/CLAIM_C05_RECONCILIATION.md` |
| 代码修复 | `code/P3.py`、`descriptive/v21_common.R`、`discovery_validation/code/D10_integrated_biology.R`、`analysis_v2.0/code/V2_M13_M14_reconciliation.R`、`M14_frozen_status.csv`、`docs/P2_P18_P19_P20_P21_DETERMINISTIC_FIX_LOG.md`（含全部备份路径） |
| 状态总表 | `docs/AUDIT_BLOCKER_CLOSURE_STATUS.md` |

## 4. 未覆盖/无法判定边界
- M12 修复与断言未运行验证（requires_rerun=YES）；195/23/39、universe、fgsea 口径均未重跑核定。
- strict nested Phase 2、M09/M11 重跑状态依据 RERUN_PLAN 记录，未实际执行。
- decoy/target-decoy 层证据在仓库中不存在（UNRESOLVED，未推测）。
- P3 hash 契约需下次运行才落盘；历史无哈希，未伪造。
- PIPELINE_STATUS 全表重写、终态复现性审计留待 Phase 6。
