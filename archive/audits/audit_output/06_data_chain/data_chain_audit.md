# 数据链路与可复现性审计（doubao-data-analysis 原则，静态）

- 审计对象：`F:\env`（环境暴露 × EV-enriched 血浆蛋白组学，analysis-v2.1）
- 审计方式：**纯静态、只读**。未运行该技能包任何脚本（delivery_guard.py / analysis_toolkit.py / final_facts.py / evidence_audit.py 等一律未运行），未运行项目任何 R/Python 分析脚本；xlsx 仅以 openpyxl read-only 读取；未修改 `F:\env` 任何既有文件。
- 判定框架：`doubao-data-analysis` 的证据接地、frozen 数字核验、跨层对账、claim→evidence 映射、发现→影响披露、口径一致原则；把"对账/映射/口径"作为人工静态核查执行。
- 审计日期：2026-10-01。
- 术语：稿件措辞用 **High land / Hot-humid**；内部键 `High-pressure/high-altitude` / `Humid-hot` 与 `Short/Long dose` 仅出现在 frozen 结果表。

---

## 1. 审计范围与材料（含对账清单）

### 1.1 逐附件读取回执

| 材料 | 类型 | 读取结果 | 实际读到的关键 sheet/字段/位置 |
|---|---|---|---|
| `PROJECT_CONTEXT.md` | 权威 frozen 总纲 | 成功 | §2 队列数字、§3 上游链路、§5 解释边界、§6 通路数字 |
| `descriptive/discover_validation_split/discovery_validation_assignment.csv` | 切分表 | 成功 | 515 行；Split/TREAT1_clean/Stratum/Seed 列 |
| `…/discover_validation_split/split_manifest.txt` | 切分清单 | 成功 | Seed=20260925；Discovery 386/Validation 129；六层 stratum 计数 |
| `…/discover_validation_split/split_integrity_assertions.csv` | 切分断言 | 成功 | A01–A26 全 PASS |
| `D01_discovery_eligibility/D01_manifest.txt`、`D01_integrity_assertions.csv` | D01 | 成功 | Discovery_n=386；Validation_n=129；eligible_protein_count=1445；raw=3817 |
| `D02_discovery_primary/D02_manifest.csv`、`D02_diagnostics.csv` | D02 | 成功 | participants=386；proteins=1445；candidate_lock=NOT_PERFORMED |
| `D03_candidate_lock/D03_candidate_lock_manifest.csv` | D03 | 成功 | candidate_count=85；rule="Discovery Long vs Short BH-FDR<0.05" |
| `D08_validation/D08_manifest.csv`、`D08_replication_summary.csv` | D08 | 成功 | N_locked=85；direction=83；nominal=29；FDR=1 |
| `M07_pairwise_contrasts/M07_manifest.csv` + 三个对比 CSV | M07 | 成功 | universe=Q515；n_proteins=1430；n_samples=515 |
| `M10_environment_interaction/M10_manifest.csv`、`corrected_pure_interaction/M10_corrected_manifest.csv`、两个结果 CSV | M10 | 成功 | 父表 interaction_FDR_lt_0.05=1034；corrected n_sig=0 |
| `M14_frozen_replication/M14_frozen_status.csv`、`M14_replication_hierarchy.csv` | M14 | 成功 | 层级 85/85/83/29/1；status 表 ML=NOT_STARTED |
| `M12_pathway_v2.1/M12_FINALIZATION_REPORT.md`、`mapping/M12_gene_mapping_summary.csv`、`diagnostics/M12_mapping_diagnostics.csv`、`diagnostics/M12_run_manifest.csv` | M12 | 成功 | 1434/1414/15/5；KEGG NOT_RUN；fgsea 分项 5/6/11/17 |
| `M12…/ranked_gsea/M12_fgsea_combined.csv`、`ranked/M12_ranked_combined_FDR.csv`、`ora/M12_ORA_combined_FDR.csv` | M12 结果 | 成功（只读行数回读） | 见 §2 对账表 |
| `ml_v2.1/M15_FINALIZATION_REPORT.md`、`results/outer_cv_metrics.csv`、`strict_nested/strict_nested_outer_metrics.csv`、`pre_P0_repair_snapshot/SNAPSHOT_STATUS.md` | ML | 成功 | 15 折；271；strict n_universe=1434；DEP 8–618 |
| `code/P1.py`、`P2.py`、`P3.py` | 上游代码 | 成功（读代码不运行） | 519 硬断言；依赖链 |
| `M12_pathway_v2.1/M12_01_mapping.R`、`ml_v2.1/run_v2_1_ml.R` | 代码 | 成功（读代码不运行） | nrows=0 bug；which.max/inner early-stopping 已修复 |
| `rawdata/sample_mapping_FINAL.xlsx`（read-only） | 上游映射 | 成功 | 00_FINAL_SUMMARY：519/519/519 |
| `descriptive/dose_defined_metadata.csv` | 切分输入 | 成功 | 515 行 |
| `docs/FINAL_REPRODUCIBILITY_AUDIT.md`、`P0_P1_REPAIR_PLAN.md`、`P0_P1_RERUN_PLAN.csv`、`PIPELINE_STATUS.md` | 控制文档 | 成功 | PASS vs BLOCKED 矛盾 |
| `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv`、`REVIEWER_RISK_REGISTER.csv` | claim 映射 | 成功 | C01–C30；R01–R30 |

未读或只读未覆盖：`rawdata/processed.xlsx`、`rawdata.xlsx`（大体积原始矩阵，未逐格读）；`descriptive/analysis_v2.0/code/` 下 V2_M05–M11、M12B、M17 R 脚本仅按 PROJECT_CONTEXT/M12/M15 终稿报告间接核对，未逐行通读；`docs/` 下 ML_ALGORITHM_*、FINAL_ML_PROTEIN_MAP、REPOSITORY_RISK_REGISTER、SOFTWARE_ENVIRONMENT_REPORT 等仅按其在 P0/P1 计划与 PIPELINE_STATUS 中的引用间接核对。

### 1.2 审计重点清单（对应任务）

① frozen 数字全链路对账；② 多重比较族标签（1,445 / 1,430 / 85 复制族）；③ claim→evidence 映射抽查；④ 口径一致（High land/Hot-humid、通路三方法不可相加、universe 1,414/1,434/15/5）；⑤ P0/P1 修复闭合性；⑥ P1/P2/P3→sample_mapping_FINAL 依赖链；⑦ 既有审计遗漏/未闭合风险。

---

## 2. 独立判定（frozen 数字对账表）

下表逐项把 `PROJECT_CONTEXT.md` 的 frozen 数字定位到结果表原文出处并判定一致性。"实际回读"列为本次静态只读回读冻结 CSV 的行数/值（计数仅为回读核对，不重算统计量）。

| frozen 数字 | 出处文件 + 位置 | 一致性 | 备注 |
|---|---|---|---|
| 519 初始队列 | `code/P1.py` 末段打印 "all 519 samples…"；`code/P3.py` L152 `len(old)!=519` 硬断言、L661 `n_sheet1==519`；`rawdata/sample_mapping_FINAL.xlsx` 00_FINAL_SUMMARY "Sheet1 sample columns=519" | ✅ 一致 | 519 来自 Sheet1 样本列/Sheet2 元数据行 |
| 515 最终分析队列 | `split_manifest.txt` Input_row_count=515；`split_integrity_assertions.csv` A01=515；`discovery_validation_assignment.csv` 实测 515 行；`dose_defined_metadata.csv` 实测 515 行 | ✅ 一致 | 519→515 差 4 例，见次要发现 m3 |
| 153 Control（全队列） | `discovery_validation_assignment.csv` TREAT1_clean=control 实测 153 | ✅ 一致 | — |
| 186 Low（全队列） | 同上 TREAT1_clean=low 实测 186 | ✅ 一致 | — |
| 176 High（全队列） | 同上 TREAT1_clean=high 实测 176 | ✅ 一致 | 153+186+176=515 闭合 |
| 386 Discovery 子集 | `D01_manifest.txt` Discovery_n=386；`D01_integrity_assertions.csv` A03；`split_manifest.txt` Discovery_n=386；assignment 实测 Discovery=386 | ✅ 一致 | Discovery 内部分组 control115/low139/high132（D01 A11） |
| 129 复用 hold-out | `D01_manifest.txt` Validation_n=129；`D01_integrity_assertions.csv` A04；`M14_replication_hierarchy.csv` "NOT external validation"；assignment 实测 Validation=129 | ✅ 一致 | 文案严格为 reused hold-out，非 external/independent |
| seed 20260925 | `split_manifest.txt` Seed=20260925；assignment.csv 全部 515 行 Seed=20260925 | ✅ 一致 | — |
| 1,445 Discovery 可入蛋白族 | `D01_manifest.txt` eligible_protein_count=1445；`D01_integrity_assertions.csv` A23；`D02_diagnostics.csv` proteins=1445 | ✅ 一致 | raw protein universe=3817（D01 A12） |
| 85 DEPs（BH-FDR<0.05） | `D03_candidate_lock_manifest.csv` candidate_count=85；`D08_replication_summary.csv` N_locked=85；`M14_replication_hierarchy.csv` Locked D03=85 | ✅ 一致 | rule="Discovery Long vs Short BH-FDR<0.05"（内部键 Long/Short=High/Low） |
| 83/85 方向一致 | `D08_replication_summary.csv` N_direction_concordant=83；`M14_replication_hierarchy.csv` Same direction=83 | ✅ 一致 | Direction_rate=0.9765 |
| 29/85 名义复制 | `D08_replication_summary.csv` N_nominal_replication=29；`M14_replication_hierarchy.csv` Nominal P<0.05=29 | ✅ 一致 | raw P<0.05，非 FDR |
| 1/85 FDR 支持复制 | `D08_replication_summary.csv` N_FDR_supported=1；`M14_replication_hierarchy.csv` Candidate-family BH-FDR=1 | ✅ 一致 | 85 蛋白族内 BH |
| 0/1,430 Group×Env 交互 | `corrected_pure_interaction/M10_corrected_manifest.csv` n_sig=0；`M10_pure_interaction.csv` 实测 1430 行、interaction_BH<0.05=0 | ✅ 一致（canonical） | 但父表 M10_manifest.csv=1034，见重大发现 M4 |
| 195 cameraPR（主） | `M12_FINALIZATION_REPORT.md` §4；回读 `ranked/M12_ranked_combined_FDR.csv` FDR_pooled<0.05 实测 195 | ✅ 一致 | — |
| 25 GO BP（cameraPR） | 回读 ranked_combined FDR_pooled<0.05，database=GO_BP 实测 25 | ✅ 一致 | — |
| 170 Reactome（cameraPR） | 同上 database=Reactome 实测 170 | ✅ 一致 | 25+170=195 |
| 23 ORA（补） | `M12_FINALIZATION_REPORT.md` §5；回读 `ora/M12_ORA_combined_FDR.csv` FDR_pooled<0.05 实测 23 | ✅ 一致 | — |
| 3 GO BP（ORA） | 回读 ORA_combined database=GO_BP 实测 3 | ✅ 一致 | — |
| 20 Reactome（ORA） | 回读 ORA_combined database=Reactome 实测 20 | ✅ 一致 | 3+20=23 |
| 39 fgsea（敏感）总数 | 回读 `ranked_gsea/M12_fgsea_combined.csv` padj_pooled<0.05 实测 39 | ✅ 一致（总数） | — |
| 3 GO BP（fgsea） | PROJECT_CONTEXT §6 写 3；**回读 CSV database=GO_BP 实测 5**；`M12_FINALIZATION_REPORT.md` §6 也写 5 | ❌ **不一致** | 见重大发现 M1 |
| 8 GO MF（fgsea） | PROJECT_CONTEXT §6 写 8；**回读 CSV database=GO_MF 实测 6**；M12 终稿报告写 6 | ❌ **不一致** | 见重大发现 M1 |
| 11 GO CC（fgsea） | 回读 CSV database=GO_CC 实测 11 | ✅ 一致 | — |
| 17 Reactome（fgsea） | 回读 CSV database=Reactome 实测 17 | ✅ 一致 | — |
| KEGG NOT_RUN | `M12_run_manifest.csv` KEGG_source="NOT_RUN_NO_REPRODUCIBLE_KEGG_SOURCE"；`M12_FINALIZATION_REPORT.md` §7 | ✅ 一致（声明） | 但 canonical 链仍含 kegg_fix，见阻断发现 B1/P0-4 |
| 1,434 tested protein groups | `mapping/M12_gene_mapping_summary.csv` total_protein_groups_tested=1434；M12_mapping_diagnostics.csv 同 | ✅ 一致 | 但代码无法重建该宇宙，见 B1 |
| 1,414 单基因无歧义 | `M12_gene_mapping_summary.csv` unambiguous_one_gene=1414 | ✅ 一致 | — |
| 15 多基因歧义 | 同 multi_gene_ambiguous=15 | ✅ 一致 | — |
| 5 未映射 | 同 unmapped=5 | ✅ 一致 | — |
| 多重比较族标签 1,445 / 1,430 / 85 | 1,445=Discovery 可入族（D01）；1,430=Q515 全队列丰度族（M07/M10 manifest n_proteins=1430）；85=复制候选族（D03 lock） | ✅ 一致（三族可区分） | claim C05 把 85 锁记成 N=1430，见 M3 |

**对账小结**：frozen 数字共 30 项左右；**28 项核对一致、0 项无出处、2 项分项不一致**（fgsea GO BP 3→实测 5；fgsea GO MF 8→实测 6；总数 39 与 CC11/Reactome17 不受影响）。

---

## 3. 分级发现清单

### 3.1 阻断（Blocking）

- **[阻断] B1：M12 mapping 入口不可复现——全部通路数字（195/23/39）与 1,434/1,414/15/5 无当前主线代码可重建**
  - 证据指针：`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R` L15–L17：`read.csv(gzfile("…/PRIMARY_dose_log2_expression.csv.gz"), row.names=1, check.names=FALSE, nrows=0)` 后 `tested_prots <- rownames(expr)`。`nrows=0` 只读取表头、无数据行，`rownames(expr)` 为空向量，无法枚举 1,434 个蛋白。但 `mapping/M12_gene_mapping_summary.csv` 已落盘 1434/1414/15/5。`docs/P0_P1_REPAIR_PLAN.md` P0-3 已定性为 `PROVENANCE_MISMATCH`。
  - 影响：现有 195/23/39 通路计数与 mapping 宇宙数字虽数值冻结，但"从当前主线代码可重建"这一可复现性前提不成立。任何"analysis-v2.1 可端到端重跑"的声明都不覆盖 M12。这是 P0_P1_REPAIR_PLAN 列的 4 个 P0 之一。
  - 建议：按 RERUN_PLAN Phase 5-8，改为只读首列枚举全部 1,434 个 PG.ProteinGroups 并 `assert` 计数后重建 mapping contract 与下游 M12/M12B；在此之前通路数字只能称"数值冻结、provenance 待修复"。

- **[阻断] B2：冻结状态自相矛盾——同日相邻两份审计给出相反结论（READY vs BLOCKED）**
  - 证据指针：`docs/FINAL_REPRODUCIBILITY_AUDIT.md`（2026-09-29）§18"Freeze blockers: None"、§19"PASS_WITH_LIMITATIONS / READY_TO_TAG_WITH_LIMITATIONS"、§14"No numerical conflicts"；`docs/P0_P1_REPAIR_PLAN.md`（2026-09-30）§Executive summary"The analysis freeze is BLOCKED…Freeze_readiness_score=1/10…Safe_to_tag_analysis_v2.1=NO"。
  - 影响：仓库同时对外呈现"可打 tag"与"不可打 tag"两种状态。按 skill 的"跨层对账"要求，控制文档与实际修复状态未对齐；后一份审计（更新、更细粒度）应优先，但前一份仍留在控制文档索引中，稿件方法学若引用前者会高估可复现性。
  - 建议：在 P0/P1 全部 Phase 完成前，冻结 `READY_TO_TAG` 表述；以 P0_P1_REPAIR_PLAN 为当前事实状态，将 FINAL_REPRODUCIBILITY_AUDIT.md 标注为 superseded 或重写。

- **[阻断] B3：P0/P1 修复仅部分闭合——ML Phase 1 已修，M12/严格嵌套/M09/M11 与控制文档未修**
  - 证据指针：
    - 已修（代码级）：`ml_v2.1/run_v2_1_ml.R` L239 `i_best <- which.max(cv_en$cvm)`（P0-2 EN AUC 方向已纠正）；L281–L291 XGBoost 早停在 `dtrain_inner/dval_inner`、refit 全 outer-train 后才构造 `dtest` 仅用于预测（P0-1 已修复）；`ml_v2.1/pre_P0_repair_snapshot/SNAPSHOT_STATUS.md` 标记旧产物 HISTORICAL_INVALIDATED，`results/` 文件大小与快照不同（outer_cv_metrics 852→1530 字节）。
    - 未修：`M12_01_mapping.R` 仍 `nrows=0`（B1）；`docs/PIPELINE_STATUS.md` L28 canonical 链仍含 `M12_02b_kegg_fix.R`（P0-4）；`M15_FINALIZATION_REPORT.md` §4 仍描述严格嵌套为 Welch t-test、无 Environment 调整（P1-1 未对齐 D02）；`docs/PIPELINE_STATUS.md` 全表仍标 FROZEN_COMPLETE，未按 RERUN_PLAN Phase 6-16 重写。
  - 影响：fixed-85 ML 结果可视为已重跑，但严格嵌套敏感性、M09、M11、M12/M12B 及其下游图（Fig3–Fig6）与控制文档仍停留在修复前状态。当前仓库不存在一份"修复后全链路闭合"的终态报告。
  - 建议：按 RERUN_PLAN 顺序完成 Phase 2–6，并产出一份取代 FINAL_REPRODUCIBILITY_AUDIT 的终态复现性审计；在完成前，稿件不得引用 strict-nested 8–618 为"纯重采样不稳定"、不得引用通路主题/集成结论为冻结证据。

### 3.2 重大（Major）

- **[重大] M1：fgsea 分项口径不一致——PROJECT_CONTEXT / claim map / 复现审计三处写"3 BP + 8 MF"，冻结 CSV 实为"5 BP + 6 MF"**
  - 证据指针：`PROJECT_CONTEXT.md` §6"GO BP 3; GO MF 8; GO CC 11; Reactome 17"；`manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` C22 允许措辞"3 GO BP + 8 GO MF + 11 GO CC + 17 Reactome"；`docs/FINAL_REPRODUCIBILITY_AUDIT.md` §14 同；但回读 `M12_pathway_v2.1/ranked_gsea/M12_fgsea_combined.csv`（padj_pooled<0.05）实测 GO_BP=5（GO:0007155/0007601/0030198/0070374/0001525）、GO_MF=6、GO_CC=11、Reactome=17；`M12_FINALIZATION_REPORT.md` §6 亦写 5/6/11/17。
  - 影响：fgsea 总数 39 与 CC11/Reactome17 一致，但 BP 与 MF 分项在权威总纲、claim 映射与结果表之间错位（3↔5 BP，8↔6 MF）。若按 claim map C22 写"3 BP + 8 MF"，将与结果表逐行可查的 5 BP/6 MF 矛盾，审稿人回读 CSV 即可发现。
  - 建议：以冻结 CSV 与 M12 终稿报告为准（5 BP + 6 MF + 11 CC + 17 Reactome），回改 PROJECT_CONTEXT §6、STATISTICAL_CLAIM_MAP C22、FINAL_REPRODUCIBILITY_AUDIT §14；或在稿件中只引用 fgsea 总数 39、不展开 BP/MF 分项。

- **[重大] M2：M14_frozen_status.csv 为陈旧状态表，与主线模块状态矛盾**
  - 证据指针：`M14_frozen_replication/M14_frozen_status.csv` 写"ML M15 = NOT_STARTED"、"Pathway (frozen D10) = NOT_RUN_NO_APPROVED_MAPPING"；但 `PROJECT_CONTEXT.md` §4 将 ml_v2.1 与 M12 v2.1 列为 ACTIVE_MAINLINE，`docs/PIPELINE_STATUS.md` L32–L33 标 M15 PASS_WITH_LIMITATIONS、M12 FROZEN_COMPLETE。
  - 影响：该 status 文件会被误读为"ML 未开始、通路未跑"，与事实相反。P0_P1_REPAIR_PLAN P1-6 已指出 M14 状态"STALE_AND_HARDCODED"。
  - 建议：按 RERUN_PLAN Phase 6-14，M14 状态应由 D08 源表派生并重生成，删除 NOT_STARTED/NO_APPROVED_MAPPING 等陈旧文本。

- **[重大] M3：claim 映射 C05 把 85 DEP 锁定的宇宙误标为 N=1,430 / 族"A-E"，与 Discovery 1,445 宇宙混淆**
  - 证据指针：`STATISTICAL_CLAIM_MAP.csv` C05"Discovery DEP lock … N=1430 … Multiplicity_family=A-E"；但 `D03_candidate_lock_manifest.csv` 的 D01_universe_sha256 指向 `D01_discovery_eligible_proteins.csv`（=1,445，D01_manifest eligible_protein_count=1445），`PROJECT_CONTEXT.md` §2 明确"85 on 1,445 Discovery-eligible proteins"。1,430 是 Q515 全队列丰度族（`M07_manifest.csv` n_proteins=1430）。
  - 影响：85 的允许措辞"85 discovery DEPs locked in D03"本身安全，但 C05 的 N=1430/族 A-E 元数据把"Discovery 1,445 宇宙"与"Q515 1,430 丰度宇宙"混为一谈。若按 N=1,430 写方法学，会与 D01/D03 的实际锁定宇宙不符。
  - 建议：将 C05 的 N 改为 1,445、族改为 Discovery Long-vs-Short（BH across 1,445），与 D03 manifest 对齐；保留允许措辞不变。

- **[重大] M4：M10 父子两份 manifest 给出相反的"交互显著数"（1034 vs 0）**
  - 证据指针：`M10_environment_interaction/M10_manifest.csv` interaction_FDR_lt_0.05=1034（回读 `M10_environment_interaction.csv` 1430 行中 interaction_BH<0.05=1034）；`M10_environment_interaction/corrected_pure_interaction/M10_corrected_manifest.csv` n_sig=0（回读 `M10_pure_interaction.csv` 1430 行中 interaction_BH<0.05=0）。两表对同一蛋白的 interaction_BH 取值不同（如 A0A075B6J9：父表 0.0379 vs corrected 0.1857）。`docs/PIPELINE_STATUS.md` L26 指定 corrected_pure_interaction 为 canonical。
  - 影响：PROJECT_CONTEXT §5 的"0/1,430"对应 corrected 模型；但父目录 M10_manifest.csv 仍落盘 1034，未标注 superseded。读者若打开父 manifest 会误读为"1,034 个交互显著"。
  - 建议：将父 `M10_manifest.csv`/`M10_environment_interaction.csv` 标注为 superseded/不同模型版本，或在文件名/manifest 中显式指向 corrected_pure_interaction 为唯一 canonical。

### 3.3 次要（Minor）

- **[次要] m1：M12 mapping_diagnostics 与 mapping_summary 的 retained_representative_genes 不一致（0 vs 1414）**
  - 证据指针：`diagnostics/M12_mapping_diagnostics.csv` retained_representative_genes=0；`mapping/M12_gene_mapping_summary.csv`=1414。`M12_FINALIZATION_REPORT.md` §3 称该 cosmetic bug 已于 2026-09-29 在 summary 修复，但 diagnostics CSV 仍保留 0。
  - 影响：不改变 1,414 下游过滤与通路结果，仅为 diagnostics 表残留；跨表对账会出现 0/1414 两个值。
  - 建议：重建 mapping 时同步重生成 diagnostics，使其 retained=1414 与 summary 一致。

- **[次要] m2：M07 全队列 pairwise 数（HL 257 / HC 0 / LC 13）与 headline 85 易混淆**
  - 证据指针：回读 `M07_pairwise_contrasts/M07_High_vs_Low.csv` BH_FDR<0.05=257、High_vs_Control=0、Low_vs_Control=13；`docs/PIPELINE_STATUS.md` L23 记录"LC 13 / HC 0 / HL 257"。这是 Q515 全队列 1,430 蛋白丰度对比，非 Discovery 1,445 宇宙的 85 DEP。
  - 影响：257（全队列 HL）与 85（Discovery HL）来自不同宇宙/队列，若稿件未区分会引发"到底多少个 DEP"的混淆。
  - 建议：稿件方法学显式区分 1,445 Discovery 宇宙（85 DEP）与 1,430 Q515 丰度宇宙（M07 pairwise）；M07 数仅作全队列背景，不进 R3 主线。

- **[次要] m3：519→515 的 4 例剔除原因在所审控制文档中未定位**
  - 证据指针：`sample_mapping_FINAL.xlsx`=519，`dose_defined_metadata.csv`=515（切分输入），差 4 例；`split_manifest.txt` Input_row_count=515。所审文件未给出这 4 例的剔除规则/名单。
  - 影响：519→515 数字闭合，但剔除依据不在本次所审控制文档中，读者无法从仓库复算"为何是 515"。
  - 建议：在数据描述/方案文档中补一行 519→515 的排除规则（QC/缺失/重复等）与例数。

### 3.4 提示（Advisory）

- **[提示] a1：R/Python 环境版本未锁定**
  - 证据指针：`docs/FINAL_REPRODUCIBILITY_AUDIT.md` §10/§17 自述无 renv.lock/sessionInfo、无 requirements.txt；M12 manifest 固定了 limma/fgsea/org.Hs.eg.db 等版本，但整体环境未锁定。
  - 影响：已知限制，非数字冲突；不阻断当前静态结论。
  - 建议：冻结 tag 时补 sessionInfo/renv.lock。

- **[提示] a2：P2/P3 人工歧义解析步骤**
  - 证据指针：`sample_mapping_FINAL.xlsx` 00_FINAL_SUMMARY：P1 unique-name mappings=452、block-resolved=67（452+67=519）；P2/P3 依赖人工审阅 AMBIGUOUS 行。
  - 影响：可复现性限制，已在 P0_P1_REPAIR P1-7 与 FINAL_REPRODUCIBILITY_AUDIT §3 披露。
  - 建议：保留 block 规则（XZ_YB/YC/YD）的显式文档化。

- **[提示] a3：M14 层级数值为硬编码、非源表派生**
  - 证据指针：`docs/P0_P1_REPAIR_PLAN.md` P1-6 指出 `V2_M13_M14_reconciliation.R` 直接编码 85/85/83/29/1；`M14_replication_hierarchy.csv` 数值与 D08 一致。
  - 影响：数值对，但不可由声明输入独立重生成；已列入 RERUN_PLAN Phase 6-14。
  - 建议：修复时由 D08_replication_summary.csv 直接派生 M14 hierarchy。

---

## 4. 可进入稿件的安全措辞要点

以下措辞已与 `STATISTICAL_CLAIM_MAP.csv`（Allowed_wording / Prohibited_wording）及 `REVIEWER_RISK_REGISTER.csv` 对齐：

- 队列：初始 n=519；最终分析队列 n=515；Discovery 子集 n=386（确定性切分，seed 20260925）；复用 hold-out n=129。**禁止**称 129 为 external/independent/prospective validation cohort。
- 复制层级：85 discovery DEPs locked in D03 → 83/85 direction-concordant → 29/85 nominal（raw P<0.05）→ 1/85 FDR-supported（85 蛋白族内 BH）。**禁止**把 85 称 validated proteins、29 称 FDR-replicated、1 称 validated biomarker；1/85 应作为正式复制的上限而非成功证据。
- 交互："No exposure × environment interaction survived the prespecified BH-FDR threshold (0/1,430)"。**禁止**写"there was no interaction"；环境分层结果仅为描述性 concordance，不是交互检验。
- 通路：分别报告 cameraPR 195（25 GO BP + 170 Reactome，主）、ORA 23（3 GO BP + 20 Reactome，补）、fgsea 39（敏感）。**禁止**把 195+23+39 相加；KEGG 明确 NOT_RUN。fgsea 分项须以冻结 CSV 为准（**5 GO BP + 6 GO MF + 11 GO CC + 17 Reactome**），或只写总数 39，不得沿用 PROJECT_CONTEXT 的 3 BP/8 MF。
- 宇宙口径：1,430 = Q515 全队列丰度族（M05–M11/M10）；1,445 = Discovery 可入蛋白族（D01–D03）；1,434 = 通路 tested protein groups；1,414 = 通路单基因无歧义背景。三者不可互换。
- ML：fixed-85 预测性能是**条件于冻结 85 面板**的、同 Discovery 队列内反复 outer CV，不是无偏泛化估计；strict-nested fold-local DEP 8–618 反映特征选择不稳定，**不得**写成生物学异质性或主 ML 结果；Boruta-style 仅为 ranger+shadow 近似；XGBoost importance 为 post-selection 描述。
- 术语：稿件统一 High land / Hot-humid；内部键 High-pressure/high-altitude、Humid-hot、Short/Long dose 不出现在正文。
- 现状提示：在 B1–B3 闭合前，通路主题/集成结论与 strict-nested 结论应标注为"待复现性修复后确认"，fixed-85 ML 可按条件性结果呈现。

---

## 5. 未覆盖 / 无法判定的边界

1. **未运行任何统计/复算**：按任务约束，未运行 delivery_guard/analysis_toolkit/final_facts/evidence_audit，也未运行项目 R/Python；本报告所有"实际回读"均为对冻结 CSV 的只读行数/取值核对，不构成重新计算或重跑。
2. **processed.xlsx / rawdata.xlsx 未逐格读取**（14 MB / 46 MB 原始矩阵）；519 的原始列数来自 P1/P3 代码硬断言与 FINAL mapping 摘要，未直接打开 rawdata.xlsx 校验。
3. **M05–M11、M12B、M17 的 R 脚本未逐行通读**；其数字一致性来自 PIPELINE_STATUS、各模块 finalization report 与本次抽样回读的结果 CSV。M09/M11 是否已按 P1-3/P1-4 修复，未逐行核对代码（仅据控制文档仍标 SUPPLEMENTARY 推断未闭合）。
4. **严格嵌套 Phase 2 是否按 D02 对齐重跑**：本次仅据 M15_FINALIZATION_REPORT §4 仍描述 Welch t-test 推断未重跑；未逐行读 `strict_nested_sensitivity.R`。
5. **519→515 的 4 例排除规则**在所审文件中未定位（见 m3），无法判定排除是否合理。
6. **既有审计的"修复后终态"**：本仓库未提供一份取代 FINAL_REPRODUCIBILITY_AUDIT.md 的终态复现性报告；P0/P1 是否全部闭合，无法从现有材料判定为"是"，只能判定为"部分闭合、M12/控制文档未闭合"。
7. **git 历史/时间戳**未用于推断修复先后；结论基于文件当前内容与文档自述日期。
