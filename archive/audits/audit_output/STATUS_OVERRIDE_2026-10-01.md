# 状态覆盖登记（STATUS_OVERRIDE）— 2026-10-01

> 本文件**不改写任何历史报告正文**，仅逐条登记仓库中仍成立的
> READY / RERUN_READY / PASS_WITH_LIMITATIONS / NO_BLOCKERS / FROZEN_COMPLETE 类陈旧声明，
> 及其在 2026-10-01 阻断闭合轮后的新状态。权威总状态：
> FREEZE_READINESS=BLOCKED · SUBMISSION_READINESS=BLOCKED · ANALYSIS_REOPEN_REQUIRED=YES · SAFE_TO_TAG_ANALYSIS_V2_1=NO。
>
> 历史报告（含 `audit_output/06_data_chain/data_chain_audit.md`）保持原文；此处只做覆盖说明。

| # | 文件 | 位置 | 原文（逐字） | 新状态（2026-10-01） |
|---|---|---|---|---|
| 1 | docs/FINAL_REPRODUCIBILITY_AUDIT.md | §18 L169–173 | "## 18. Freeze blockers — **None.** No missing canonical script, missing required input/output, active->archive dependency, untracked required artifact, numerical inconsistency…" | **⛔ SUPERSEDED**：阻断存在（4 P0 + 8 P1）。顶部已加 SUPERSEDED 横幅。 |
| 2 | docs/FINAL_REPRODUCIBILITY_AUDIT.md | §19 L175–185 | "**PASS_WITH_LIMITATIONS.** Freeze readiness: **READY_TO_TAG_WITH_LIMITATIONS.** …The analysis-v2.1 tag can be cut…" | **⛔ SUPERSEDED**：READY_TO_TAG=NO。禁止据此打 tag。 |
| 3 | docs/FINAL_REPRODUCIBILITY_AUDIT.md | §4 L44 | "M12 v2.1 (4-script chain) … 40 files … **PASS**" | **⛔ SUPERSEDED**：M12=BLOCKED（P0-3 nrows=0；P0-4 kegg_fix 在链）。 |
| 4 | docs/FINAL_REPRODUCIBILITY_AUDIT.md | §14 L132–139 | "fgsea 39 (3 BP + 8 MF + 11 CC + 17 Reactome)… **No numerical conflicts.**" | **⛔ SUPERSEDED**：fgsea 分项实为 5 BP + 6 MF（冻结 CSV）；"No numerical conflicts" 不成立。 |
| 5 | docs/FINAL_REPRODUCIBILITY_AUDIT.md | §16 L149–157 | "M12 / M12B | **RERUN_READY**；ML v2.1 | **RERUN_READY**；M17 | **RERUN_READY**" | **⛔ SUPERSEDED**：M12=BLOCKED；strict nested=REPAIR_PENDING；M17 Fig6=NOT_FINAL。 |
| 6 | docs/PIPELINE_STATUS.md | 全表 | 多模块标 **FROZEN_COMPLETE**（M12/M15/M17 等） | **⛔ STALE**：本文件尚未逐行重写；以 PROJECT_CONTEXT 顶部权威总状态为准。M12=M12B=Fig6 BLOCKED；strict nested/M09/M11 REPAIR_PENDING。 |
| 7 | docs/PIPELINE_STATUS.md | L28（M12 链） | canonical = "M12_01 -> M12_02 -> **M12_02b_kegg_fix** -> M12_03" | **⛔ 已纠正方向**：kegg_fix 移出 canonical。PROJECT_CONTEXT §4 与 ACTIVE_MAINLINE_MANIFEST 已改；PIPELINE_STATUS 待 Phase 6 重写。 |
| 8 | PROJECT_CONTEXT.md | §9 L127–135（改前） | "All M01–M17 statistical analysis is frozen. Do not rerun, retune, or reopen…" | **✅ 本轮已改写**为阻断任务清单（P0-3/P0-4、strict nested/M09/M11、控制文档重建后方可 tag）。 |
| 9 | PROJECT_CONTEXT.md | §4 M12 行（改前） | "M12_01 -> M12_02 -> **M12_02b_kegg_fix** -> M12_03_integration" | **✅ 本轮已改写**为 M12_01 -> M12_02 -> M12_03，标 BLOCKED_PENDING_RERUN。 |
| 10 | docs/ACTIVE_MAINLINE_MANIFEST.csv | L19（M12 行，改前） | canonical_entry 含 "M12_02b_kegg_fix.R -> M12_03_integration.r"，Status=ACTIVE_MAINLINE | **✅ 本轮已改写**：kegg_fix 移出；追加 Repair_Gate_20261001=BLOCKED。 |
| 11 | docs/ACTIVE_MAINLINE_MANIFEST.csv | L2–L23（D01–M17 路径，改前） | D01 写成 `code/D01*.py`、D02–D07 写成 `D0*.py`、M05–M17 写成 `code/V2_Mxx.r`（小写 .r、缺 analysis_v2.0 前缀） | **✅ 本轮已改写**：按真实文件清单逐行修正（D01=根目录 .py；D02–D10=code/*.R；M05–M17=analysis_v2.0/code/*.R）。 |
| 12 | M12_PATHWAY_v2.1/M12_FILE_AUDIT.csv | L4（改前） | M12_02b_kegg_fix.R = ACTIVE_FINAL / Used_by_active_pipeline=Yes / KEEP_ACTIVE | **✅ 本轮已改写**为 HISTORICAL_NON_CANONICAL / Execute_not。 |
| 13 | manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv | C05（改前） | N=**1430**，Multiplicity_family="A-E"，Evidence_source="M03/M05 D03" | **✅ 本轮已改写**：N=1445（D01 资格宇宙），family=Discovery Long-vs-Short across 1,445，指针→D01+D03。 |
| 14 | STATISTICAL_CLAIM_MAP.csv | C12/C15/C17/C20/C21/C22/C25–C27/C29（改前） | M09/M11/strict nested/M12/M12B/Fig6 相关 claim 标 SAFE/REWORD | **✅ 本轮已降级**为 REVIEW_REQUIRED 或 BLOCKED_BY_REPAIR；C16 fixed-85 标 REPAIRED_PROVISIONAL。 |
| 15 | docs/README.md | 顶部（改前） | 无项目级阻断横幅，仅权威层级 | **✅ 本轮已加** 🚧 BLOCKED 横幅，指向 AUDIT_BLOCKER_CLOSURE_STATUS。 |
| 16 | docs/P0_P1_DEPENDENCY_IMPACT_MAP.csv | L20 CONTROL_DOC_STALE | "current RERUN_READY and frozen claims are **false**, update last after verification" | ✅ 一致（本文件即按此执行）；控制文档更新已在本轮做状态覆盖，科学重跑待 Phase 2–6。 |

## 仍待 Phase 6 重写（本轮未动，因科学重跑未完成）

- `docs/PIPELINE_STATUS.md` 全表 FROZEN_COMPLETE —— 待 M12/strict nested/M09/M11 重跑后重写为终态。
- `docs/CONTROL_DOCUMENT_INDEX.csv`、`docs/REPOSITORY_RISK_REGISTER.csv`、`docs/FINAL_REPRODUCIBILITY_MANIFEST.csv` 中的 READY/冻结表述 —— 待终态复现性审计。
- 任何 manuscript_v2_1/audit/ 下引用 "ready to tag / frozen pathway / strict-nested instability" 的正文 —— 随 claim map 降级同步。
