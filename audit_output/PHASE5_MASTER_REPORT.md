# PHASE 5 总报告 — M12/M12B pathway repair + canonical rerun

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。
> 本轮性质：**允许实际重跑 M12 mapping 与 M12/M12B canonical 链**；禁止修改 D01/D02/D03、D08、repaired ML、repaired strict nested、repaired M09、repaired M11、最终 manuscript；禁止直接重画最终 Fig6；禁止 KEGG 任何执行/联网；禁止 commit/push/tag；禁止事后挑选更有利 FDR family；禁止"修到"1434；禁止无声明的 estimator 切换。
> 所有数字经三重核验：执行管线运行记录 + 独立 QA（从 CSV 只读重数）+ 本总报告撰写前自核，三者一致。

## 0. 判定与总状态

- **PHASE5_M12_REPAIR_PASS**（独立 QA 逐条核对 P36 全部条件成立；P33 输出一致性 QA 通过）。
- 全局权威总状态**维持**：FREEZE_READINESS=BLOCKED / SUBMISSION_READINESS=BLOCKED / ANALYSIS_REOPEN_REQUIRED=YES / SAFE_TO_TAG_ANALYSIS_V2_1=NO（M12 修复不改变全局，strict nested/M09/M11 仍 REPAIR_PENDING）。
- 模块级：**M12 = REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD**；**M12B = REPAIRED_RERUN_COMPLETE**（均**不标 FINAL_FROZEN**）；fgsea Canonical_FDR=UNRESOLVED（HOLD）；KEGG=NOT_RUN；Fig6=NOT_FINAL；历史 195/23/39 仅存于 `pre_repair_snapshot/` 与历史文档，标 HISTORICAL_PRE_REPAIR_OUTPUT。

## 1. P37 逐条结论

### MAPPING
- 重跑成功，**无 MAPPING_REPRODUCIBILITY_FAIL**：tested=1434 / unambiguous(mapped)=1414 / multi-gene ambiguous=15 / unmapped=5（与预期逐项一致；QA 独立计数 total=1434、unambiguous=1414、multi=15、unmapped=5、duplicate=0、mapping rate=98.61%）。
- `M12_MAPPING_DIAGNOSTICS.csv` 已产出（N_input / N_unique_input / N_unambiguous / N_multigene / N_unmapped / duplicate 计数 / mapping_rate）。
- 修复确认：M12_01_mapping.R 已无 nrows=0（仅 KEGG 占位写入用 nrows=0 读空文件，非蛋白读取）；protein ID 来源为 PRIMARY 矩阵行名 + AnnotationDbi/org.Hs.eg.db 映射。
- **N_ranked=1406**：D02 主模型（1,445 Discovery-eligible，Model_status=ESTIMABLE）∩ mapped(1,414) 的有效交集。出入已如实记录：39 个 D02 蛋白不在 mapped set（D01 1,445 vs Q515 1,434 universe 差异的自然结果）、8 个 mapped 基因不在 D02 ESTIMABLE 集。**R03（合同 §4 将 inferential universe 切换到 1,445）为已声明延期项，未执行**——重跑保持 Q515=1,434 口径，模块因此不标 FINAL_FROZEN。

### ESTIMATOR（本轮最关键统计修复）
- **Canonical ranking = D02 主模型的 signed moderated t**：读取 `D02_Long_vs_Short_all_tested.csv`（1,445 行，含 log2FC/SE/Model_status/Gene_symbol），t=log2FC/SE。
- D02 主模型（已核）：design `~0 + dose + environment`（含 Environment 主效应调整）、contrast Long_vs_Short = dosehigh − doselow（= High-vs-Low）、limma `eBayes(trend=TRUE, robust=TRUE)`、**插补=NONE**。
- 修复内容：M12_02_ranked_ora.R 删除自行 lmFit/eBayes、删除 `~group` 无调整模型、删除行中位数插补，改读 D02 统计量；M12_03_integration.R 同样改为 D02 ranking（其原 L28-50 自拟合+插补已移除）。M12B_all.R 同步切换（保留表达矩阵仅用于 85 DEPs 描述性 Spearman，已在修复报告披露）。
- **Environment/trend/robust 全部保留**（来自 D02 主模型本身）；**无隐藏中位数插补进入 ranking**（QA grep 确认无残留；M12B L425 注释"median-imputed"仅指描述性 Spearman 的输入矩阵，非 ranking，已披露）。
- 无 METHOD_CONTRACT_CONFLICT（方法合同 M12_CANONICAL_METHOD_CONTRACT.md 已冻结，执行完全遵循）。

### cameraPR
| Family | 角色 | Tested | Sig (FDR_pooled<0.05) |
|---|---|---|---|
| GO-BP | 主分支 | 272 | **29** |
| Reactome | 主分支 | 486 | **176** |
| 合计 | | 758 | **205** |
| GO-MF | M12B 次要 | 107 | 16（家族内 FDR） |
| GO-CC | M12B 次要 | 151 | 16（家族内 FDR） |
- FDR family：跨 GO-BP+Reactome 合并 BH（FDR_pooled，合同 de facto 确认，运行前固定，无事后选择）。KEGG 不运行。

### ORA
| Family | 角色 | 背景 tested | Sig (FDR_pooled<0.05) |
|---|---|---|---|
| GO-BP | 主分支 | 153 | **3** |
| Reactome | 主分支 | 178 | **20** |
| 合计 | | 331 | **23** |
| GO-MF | M12B 次要 | — | 7（家族内 FDR） |
| GO-CC | M12B 次要 | — | 4（家族内 FDR） |
- Foreground = D03 locked 85（只读引用）；**background 从 repaired mapping 真实派生，未硬编码 1414**（QA 核对 ORA 背景行数 153/178 与 mapping 派生一致）。

### fgsea（双列，KEGG NOT_RUN）
| Family | Tested | padj（家族内 BH）<0.05 | padj_pooled（跨族 BH）<0.05 |
|---|---|---|---|
| GO-BP | 272 | 3 | 6 |
| GO-MF | 107 | 8 | 7 |
| GO-CC | 151 | 11 | 10 |
| Reactome | 486 | 22 | 18 |
| 合计 | 1016 | **44** | **41** |
- 列名事实：族内 CSV 仅含 `padj`；`padj` 与 `padj_pooled` 双列存在于 `M12_fgsea_combined.csv`（实际列名 database/direction/ES/leadingEdge/log2err/NES/padj/padj_pooled/pathway/pval/size）。
- **Canonical_FDR = UNRESOLVED 保持（HOLD_UNTIL_M12_REPAIR_AND_RERUN 未解除）**：两套计数均不标 FINAL_FROZEN，待团队裁定 canonical 列后更新；`FGSEA_FDR_RECONCILIATION.md` 已填入 repaired 双套计数与各历史文档用列对照（PROJECT_CONTEXT §6/claim C22/STATISTICAL_REPORTING_AUDIT:119/Fig6b 用 padj 3/8/11/17；M12_FINALIZATION_REPORT §6/M12_FILE_AUDIT 用 padj_pooled 5/6/11/17——历史值）。

### KEGG
- **KEGG was not run in the canonical repaired analysis.** `ranked/M12_ranked_KEGG.csv` 与 `ora/M12_ORA_KEGG.csv` 均为 0 行占位；PATHWAY_FAMILY_AUDIT 中 KEGG 三行 Was_run=NO/Status=NOT_RUN；今日无 KEGG 相关新文件；`M12_02b_kegg_fix.R` 未执行（HISTORICAL/NON_CANONICAL，保留不删）。无任何联网/下载。

### M12B
- **输入全部为 repaired M12 输出**（M12B_INPUT_PROVENANCE.md 逐项 YES：mapping/cameraPR/ORA/core genes 均指向 M12_pathway_v2.1 当前 repaired 文件；冻结模块 D03/D08/ML/strict nested 仅只读引用）。
- 修复：输入 strict_nested 列名与实际文件对齐（appearance_frequency / lasso_selection_frequency / en_selection_frequency）；M12B 集成表 = 85 行（D03 locked，与 Gate6 一致）。
- 角色边界：M12B=secondary biological context / contextual integration；Spearman 仅称 association/context；network 输出称 contextual correlation structure / pairwise association context；无 WGCNA/regulatory/causal 措辞（P18/P29 遵守）。

### OLD VS NEW（pre-repair 快照对照）
| 指标 | Old | Repaired | 变化原因 |
|---|---|---|---|
| Mapping tested/mapped | 1434/1414/15/5 | 1434/1414/15/5 | 不变（Q515 口径） |
| N_ranked | 1414 | 1406 | D02 ESTIMABLE∩mapped（R03 未执行） |
| cameraPR 合计（pooled） | 195（25+170） | **205（29+176）** | ranking 改为 D02 environment-adjusted moderated t（原 self-fit+插补），+10 |
| ORA 合计（pooled） | 23（3+20） | **23（3+20）** | 稳定（foreground=85 锁定） |
| fgsea 合计（family） | 39（3/8/11/17） | **44（3/8/11/22）** | Reactome 17→22，ranking 统计量变化 |
| fgsea 合计（pooled） | 39（5/6/11/17 历史 M12 口径） | **41（6/7/10/18）** | 同因 |
| KEGG | NOT_RUN | NOT_RUN | 不变 |
| FDR family | 双口径并存未声明 | 双列输出、UNRESOLVED 显式声明 | 透明化 |
| M12B input | 旧 pre-repair 表 | 全 repaired | 修复 |

### FIGURES
- **Fig6 必须 rebuild**（P26/P27 定稿）：a/b/c/d 四 panel 的 source 全部为 M12/M12B 产物，**全部 invalidated**，无 panel 可保留旧坐标。
- **Reactome 必须进 main**：repaired cameraPR 主分析 Reactome 176/205 ≈ 86% 仍绝对主导，当前 Fig6 对其零 curated 面板；建议重建展示 representative GO-BP + representative Reactome（经 redundancy clusters 聚簇）。
- GO-MF/GO-CC：**归 supplement**（M12B 次要分支家族内 FDR，cameraPR MF16/CC16、ORA MF7/CC4）。
- fgsea：**需 supplement 显式可视化**（按家族分面的 NES/leading-edge），且 **Fig6b 散点在 fgsea FDR 口径冻结前不得落图**（padj 44 vs padj_pooled 41，家族拆分差异明显；a/c/d 可先行重建、b 面板挂起）。
- **FIG6_PRESENTATION_GAP = YES**（repaired 复核定稿）：FIG6_PRESENTATION_IS_NOT_REPRESENTATIVE_OF_FULL_PATHWAY_OUTPUT。
- 本轮未重画任何图形。

### INTEGRITY
- D01/D02/D03/D08 结果时间戳 9/26，**未动**；ml_v2.1 今日 0 改动；ML/strict nested 仅只读引用。
- **M09/M11 今日 mtime 异常**（各 3 文件 00:14/00:29）但 manifest 内容=历史冻结值（POST_PHASE3/4_REPAIR_CURRENT），QA 判定为文件重写/同步的时间戳现象、无科学改变、REPAIR_PENDING 状态未变——如实记录，建议后续核实。
- discovery_validation 今日唯一改动为 `code/D10_integrated_biology.R`（Round 2 P20 代码修复，非重跑）。
- 无 KEGG 执行、无联网（gene sets 全部来自本地 Bioconductor：org.Hs.eg.db 3.18.0 / GO.db 3.18.0 / reactome.db 1.86.2）。
- git：M12/M12B 相关 tracked 文件 `git diff --check` exit 0；全树 exit 2 均为**既有** SVG trailing whitespace（非本轮产物）；**未 commit/push/tag**。

## 2. P36 PASS 条件核对（QA 逐条）
mapping rerun 成功 ✅｜universe 可复现 1434/1414/15/5 ✅｜无 nrows=0 ✅｜primary ranking=D02 moderated t（含 Environment/trend/robust）✅｜无 hidden median-imputation 进 ranking ✅｜cameraPR/ORA GO-BP+Reactome canonical 明确 ✅｜fgsea 四族双列明确 ✅｜KEGG NOT_RUN ✅｜FDR families 透明（fgsea UNRESOLVED 已声明）✅｜M12B 读 repaired M12 ✅｜无 stale 进 integration（grep pre_repair_snapshot=0 命中）✅｜software provenance 完整（M12_SOFTWARE_PROVENANCE.md：R 4.3.1、limma 3.58.1、fgsea 1.28.0、org.Hs.eg.db 3.18.0、GO.db 3.18.0、reactome.db 1.86.2、clusterProfiler 4.10.1、AnnotationDbi 1.64.1、data.table 1.18.4、statmod 1.5.0）✅｜output consistency QA 通过 ✅｜D03/D08/ML/M09/M11 科学上未被重跑 ✅。

## 3. 本轮产物清单（Phase 5）
- `M12_pathway_v2.1\`：M12_CANONICAL_METHOD_CONTRACT.md、M12_MAPPING_DIAGNOSTICS.csv、M12_REPAIR_REPORT.md、M12_REPAIR_COMPARISON.csv、FGSEA_FDR_RECONCILIATION.md、PATHWAY_METHOD_OVERLAP.csv、M12_SOFTWARE_PROVENANCE.md、M12_FIG6_REBUILD_REQUIREMENT.md、M12_SUPPLEMENT_REBUILD_REQUIREMENT.md、PATHWAY_FAMILY_AUDIT.csv（更新，含 KEGG NOT_RUN 与 fgsea HOLD 行）、repaired 结果表（mapping/ranked/ora/ranked_gsea/integration/environment/diagnostics 全部重写）、M12_01_mapping.R / M12_02_ranked_ora.R / M12_03_integration.R（修复+`.phase5.bak` 备份）、pre_repair_snapshot/（HISTORICAL_PRE_REPAIR_OUTPUT）
- `M12B_biological_context_v2.1\`：M12B_REPAIR_REPORT.md、M12B_INPUT_PROVENANCE.md、M12B_all.R（修复+备份）、repaired M12B 输出（correlation/network/environment/integration/ranked_gsea）、pre_repair_snapshot/
- `docs\ACTIVE_MAINLINE_MANIFEST.csv`：仅 M12/M12B 行更新为 REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD / REPAIRED_RERUN_COMPLETE（未标 FINAL_FROZEN）

## 4. 剩余事项（不属本轮范围）
1. **fgsea canonical FDR 家族裁定**（team decision）→ 解除 HOLD、更新 Fig6b。
2. **R03：inferential universe 切 1,445（Discovery eligible）** 为已声明延期项；M12 模块不标 FINAL_FROZEN 直至决定。
3. strict nested（Phase 2）、M09（Phase 3）、M11（Phase 4）REPAIR_PENDING 状态维持，待各自 pipeline 收尾。
4. **Fig6 重建**（下阶段，按 M12_FIG6_REBUILD_REQUIREMENT.md；a/c/d 可先重建，b 挂起）。
5. 全局 BLOCKED 解除条件：全模块闭合 + PIPELINE_STATUS 重写 + 终态复现性审计。
