# PHASE 6 状态基线（Status Baseline）

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。
> 用途：统一登记 Phase 6 时点每个模块的**权威当前状态**、权威产物、已失效旧状态、所需动作。
> 全局：**FREEZE_READINESS=BLOCKED · SUBMISSION_READINESS=BLOCKED · SAFE_TO_TAG_ANALYSIS_V2_1=NO**
> （分析侧已修复闭合，剩余阻断为 reporting / provenance / git，不再要求重跑核心分析）。

## 1. 模块状态表

| Module | Current authoritative status | Authoritative output | Old stale status (superseded) | Action needed |
|---|---|---|---|---|
| D01 discovery eligibility | FROZEN_INPUT（未重跑） | `D01_discovery_eligibility/` raw 3817 / eligible 1445 | — | 无（frozen） |
| D02 discovery primary | FROZEN_INPUT（未重跑；M12 ranking 来源） | `D02_discovery_primary/D02_Long_vs_Short_all_tested.csv`（1445，moderated t） | — | 无（frozen） |
| D03 candidate lock | FROZEN_KEEP（85 retained） | `D03_candidate_lock/D03_locked_candidates.csv`（85 行） | — | 无（frozen） |
| D08 validation | FROZEN_KEEP（85→83→29→1 retained） | `D08_validation/D08_replication_summary.csv` | — | 无（frozen） |
| D10 integrated biology | BLOCKED_REBUILD（P1-8） | `D10_integrated_biology/` | — | 重建（非 D03/D08 重跑） |
| M05–M08 / M10 | ACTIVE（frozen 未动） | 各 `M0*_*/`；M10 pure interaction 0/1430 | — | 无 |
| M09 missingness sensitivity | **REPAIRED_AND_VERIFIED** | `M09_missingness_sensitivity/`（Pearson 0.9740605 / Spearman 0.9644384 / 1343/1430 / 0 primary FDR / 0 KNN FDR） | REPAIR_PENDING | Fig3c 重建（图管线） |
| M11 site robustness | **REPAIRED_AND_VERIFIED** | `M11_site_robustness/`（9 sites；Pearson 0.790055–0.982702；Spearman 0.756893–0.979087；direction 70.77–93.50%） | REPAIR_PENDING | Fig4d 重建（图管线） |
| M12 pathway v2.1 | **REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD** | `M12_pathway_v2.1/`（cameraPR 205=29+176；ORA 23=3+20；fgsea family 44 / pooled 41；KEGG NOT_RUN；mapping 1434/1414/15/5；N_ranked 1406） | BLOCKED / BLOCKED_PENDING_RERUN | fgsea canonical FDR 家族裁定；Fig6 重建 |
| M12B context v2.1 | **REPAIRED_RERUN_COMPLETE** | `M12B_biological_context_v2.1/`（integrated 85 行；读 repaired M12） | BLOCKED_BY_M12 | 随 Fig6/Fig7 supplement |
| M14 replication | REBUILD_FROM_D08（数值有效，演示待重建） | `M14_frozen_replication/` | STALE_AND_HARDCODED | 由 D08 派生重建（D08 不重跑） |
| fixed-85 ML (run_v2_1_ml.R) | **REPAIRED_AND_VERIFIED** | `ml_v2.1/results/outer_cv_metrics.csv`（n=15；mean AUROC LASSO 0.6651 / EN 0.6687 / XGB 0.6488） | P0_REPAIRED（旧措辞） | 随 Fig5b-d 重建 |
| strict nested ML | **REPAIRED_AND_VERIFIED** | `ml_v2.1/strict_nested/`（15 outer folds；7 zero-feature；8 evaluable；evaluable mean LASSO 0.5967 / EN 0.5937；LASSO+EN only） | REPAIR_PENDING | 随 Fig5b-d 重建 |
| M17 figures | BLOCKED_REBUILD_FIGS（Fig1/2 keep；Fig3–6 rebuild） | `figures_final_v2/` | NOT_FINAL | 图管线重建（本轮只登记不改图） |
| P1/P2/P3 upstream | ACTIVE_PROVISIONAL（P1-7 无 workbook 身份绑定） | `rawdata/sample_mapping_FINAL.xlsx` | — | provenance 修复（OPEN_PROVENANCE） |
| KEGG | NOT_RUN（占位 CSV only） | `ranked|ora/M*_KEGG.csv`（0 行） | — | 无（不得跑） |

## 2. 本轮（Phase 6）统一改写的陈旧状态

- `PROJECT_CONTEXT.md` 顶部权威总状态节：模块级从 "strict nested/M09/M11=REPAIR_PENDING；M12=BLOCKED；M12B=BLOCKED_BY_M12" 改为上表权威状态；§4 M12 行由 BLOCKED_PENDING_RERUN 改为 REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD；§6 通路数由旧 195/23/39 改为 repaired 205/23/(44&41)；§9 剩余任务重写为 reporting/provenance/git。
- `docs/README.md` 横幅：同上模块状态与 current 通路数。
- `docs/ACTIVE_MAINLINE_MANIFEST.csv`：M15_ml_v2.1 行由 "REPAIRED (fixed-85) / REPAIR_PENDING (strict nested)" 改为 REPAIRED_AND_VERIFIED；M09、M11 行 Repair_Gate 由 REPAIRED 改为 REPAIRED_AND_VERIFIED 并补真实数值。
- `docs/AUDIT_BLOCKER_CLOSURE_STATUS.md`：strict nested/M09/M11/P0-3 行状态随 Phase 5/6 更新（见该文件 Phase 6 追加节）。
- `docs/FINAL_REPRODUCIBILITY_AUDIT.md`：Phase 6 重建版（原版 .phase6.bak 保留）。

## 3. X1 — FROZEN 协议陈旧术语（superseded 注释项，不改 frozen 文件）

- 问题：两份自标 **PROTOCOL FROZEN** 的文档写 "Plasma, not EV-enriched plasma"，与 PROJECT_CONTEXT §1 权威身份（**EV-enriched plasma proteomics**，co-isolated plasma proteins acknowledged）冲突。
- 真实位置（交接件所指 `descriptive/analysis_v2.0/code/` 路径不存在，已更正）：
  - `docs/protocol/STUDY_DESIGN_AUDIT.md`，"Material and unit" 行（约 L18）。
  - `docs/protocol/ANALYSIS_PLAN_v2.0.md`，"Material / unit" 行（约 L15）。
- 处理：**不改写 frozen 协议正文**（遵守全局"禁止改 frozen 文件"）。仅在此登记为 superseded 注释项：
  `FROZEN_PROTOCOL_STALE_TERMINOLOGY：材料身份以 PROJECT_CONTEXT.md §1 口径（EV-enriched plasma proteomics）为准；
  上述两份 frozen 协议中的 "Plasma, not EV-enriched" 为历史措辞，不构成当前权威定义。`
- 影响范围：仅材料身份措辞；不影响样本数 515/519、分析口径、统计模型。稿件写作一律用 PROJECT_CONTEXT 口径。
