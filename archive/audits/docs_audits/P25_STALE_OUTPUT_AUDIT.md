# P25 Stale Output 审计表（2026-10-01）

> 范围：全项目，排除 `pre_repair_snapshot/`、`audit_output/`、`*.bak`/`*.phase6.bak`/`*.phase5.bak`。
> 分类：HISTORICAL_SNAPSHOT（历史快照，保留）/ STALE_ACTIVE（当前生效文件中的旧值，已修）/
> VALID_CURRENT_CONTEXT（旧数字在上下文中仍成立）/ INVALID_CURRENT（错误，已修）。
> 短数字（195/39/25/170）均在"通路/ML claim"上下文中判定，不误抓日期/计数。

## 一、STALE_ACTIVE（已修复，改前均 .phase6.bak 备份）

| 文件 | 位置 | 旧值 | 新值 | 处理 |
|---|---|---|---|---|
| docs/FINAL_REPRODUCIBILITY_MANIFEST.csv | L22 M12 行 | canonical 链含 `M12_02b_kegg_fix.R`；Notes "cameraPR 195 / ORA 23 / fgsea 39"；Rerun_status=RERUN_READY | 链去掉 kegg_fix；Notes "205(29+176)/23(3+20)/fgsea 44&41 dual/KEGG NOT_RUN"；Rerun_status=REPAIRED_VERIFIED_WITH_FGSEA_HOLD | 已改 |
| docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv | L21 fgsea_full 行 | "39 fgsea pathways" | "dual counts family 44 / pooled 41 (UNRESOLVED)" | 已改 |
| docs/PROJECT_CONTEXT.md | §6 通路节 | cameraPR 195(25+170)、fgsea 39(3/8/11/17) | 205(29+176)、fgsea 44&41 dual | 已改（P1） |
| docs/README.md | 状态横幅 | M12=BLOCKED、旧通路数 | repaired 状态 + current 通路数 | 已改（P1） |

## 二、STALE_ACTIVE_REQUIRING_MANUSCRIPT_PIPELINE（登记，本轮不改 manuscript claim-evidence 正文）

> 这些是 `manuscript_v2_1/audit/` 下仍把 195/39 当 current 的审查/综述文档。权威 claim map
> `STATISTICAL_CLAIM_MAP.csv` C20/C22 已在 Phase 5 改为 205/44&41；以下文档应随稿件/措辞管线同步，
> 本轮不改以免越权改 claim-evidence 叙述：

| 文件 | 位置 | 旧值 | 建议 |
|---|---|---|---|
| manuscript_v2_1/audit/STATISTICAL_REPORTING_AUDIT.md | L117,119,122 | cameraPR 195=25+170；fgsea 39=3+8+11+17；"do not sum 195+23+39" | 改为 205/23/44&41；保留"勿相加"原则 |
| manuscript_v2_1/audit/EXPERIMENTAL_DESIGN_REVIEW.md | L107-108 | cameraPR 195；fgsea 39 | 改 205 / 44&41 |
| manuscript_v2_1/audit/WHOLE_PROJECT_SCIENTIFIC_REVIEW.md | L53,71 | cameraPR 195；fgsea 39；8–618 | 改 205；fgsea 44&41 |
| manuscript_v2_1/audit/MANUSCRIPT_MODULE_MAP.csv | L21 | fgsea "39 pathways" | 改 dual 44/41 |
| manuscript_v2_1/audit/PROJECT_RECONSTRUCTION_PLAN.md | L54,93 | fgsea 39；cameraPR 195 | 改 repaired 值 |
| manuscript_v2_1/audit/REVIEWER_RISK_REGISTER.csv | L15-16 | 195 / "do not sum 195+23+39" | 数字改 205；保留勿相加 |

## 三、VALID_CURRENT_CONTEXT（旧数字在其上下文中仍成立，不改）

| 文件 | 位置 | 数字 | 为何保留 |
|---|---|---|---|
| PROJECT_CONTEXT §5 / checklist / P0_P1_REPAIR_PLAN L94 | — | fold-local DEP 8–618 | 历史 strict nested 描述，反映 feature-selection instability，措辞正确 |
| docs/PIPELINE_STATUS.md L33 | M15 strict nested | "Fold-local DEP range 8–618" | 描述性，非通路 claim |
| docs/CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md L103 | ML summary | "range 8–618" | 历史上下文 |
| M09_manifest / M11_manifest | — | Pearson 0.9740605 / range | repaired 当前值，正确 |
| FINAL_REPRODUCIBILITY_MANIFEST L19 M09 | — | impute 参数 k=10 等 | repaired 契约，正确 |

## 四、HISTORICAL_SNAPSHOT（保留，不得当 current）

- `pre_repair_snapshot/`（M12/M12B）：195/23/39 原始值，已标 HISTORICAL_PRE_REPAIR_OUTPUT。
- `docs/P0_P1_REPAIR_PLAN.md`、`P0_P1_RERUN_PLAN.csv`、`P0_P1_AFFECTED_OUTPUTS.csv`、
  `P0_P1_DEPENDENCY_IMPACT_MAP.csv`：历史计划/问题登记，含 "correlation-weighted Euclidean"、
  RERUN_READY 批评、8–618——描述问题本身，保留。
- `docs/FINAL_ML_RESULT_AUDIT.md`：历史 ML 审计（8–618），保留。
- 所有 `*.bak` / `*.phase*.bak`：本轮与历史备份，忽略。
- 图文件（figures_final_v2/、figures_prospective_v2.7/）内旧数字：**只登记不改**，由图重建管线负责。

## 五、未命中项
- "0.710294 / 0.686813 / 0.931147"（旧 ML AUROC）：除备份与历史审计外，当前生效文件 0 命中。
- "site robust" 作为陈旧术语：D07/M11 已 reconciled，无 active 误用。
- "ML NOT_STARTED / Pathway NOT_RUN" 作为陈旧状态：M14_frozen_status.csv 历史值已随 Phase 5 流程处理（claim map 已标 REBUILD_FROM_D08）。

## 分类计数
- STALE_ACTIVE（已修）：4。
- STALE_ACTIVE_REQUIRING_MANUSCRIPT_PIPELINE（登记）：6。
- VALID_CURRENT_CONTEXT：5 条。
- HISTORICAL_SNAPSHOT：4 类目录/文件组。
- INVALID_CURRENT：0（无科学错误残留，均为状态/数字口径陈旧）。
