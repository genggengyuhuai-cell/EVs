# PHASE 8 GIT EXECUTION PLAN（Git 清理执行规划）

> 日期：2026-10-01。**PLAN_AND_PREPARE_ONLY：本轮不执行任何删除/移动/git add/commit/push/tag。**
> 基线：`git status --short` = **1105**；`git diff --check` trailing whitespace = **194**（2026-10-01 只读复核值）。
> 输入：GIT_WORKTREE_CLASSIFICATION.csv（A=36/B=97/C=402/D=58/E=354/F=123/G=2/H=13，合计 1085 分类基线）、STALE_ARTIFACT_ACTIONS.csv、HISTORICAL_ISOLATION_AUDIT.md、GIT_WHITESPACE_POLICY.md、CANONICAL_OUTPUT_EXISTENCE_AUDIT.csv、FINAL_COMMIT_PLAN.md。

---

## 1. 工作单（P1）

| Commit | 类别 | 文件数(参考) | Action | Risk | Needs_manual_review |
|---|---|---|---|---|---|
| **Commit1** | A_CANONICAL_CODE | 36 | `git add` 精确脚本清单 → commit "repair: finalize canonical analysis pipeline v2.1" | 低（纯脚本；不重跑） | 0 |
| **Commit2** | B_CANONICAL_RESULTS | 97 | `git add` repaired 输出清单 → commit "results: freeze repaired analysis outputs v2.1" | 低（冻结结果，不改值） | 0 |
| **Commit3** | C_CANONICAL_FIGURES | 402 | `git add` figures_final_v2 + supplement_figures + figures_nature_v2.2 + figures_prospective_v2.7 → commit "figures: rebuild main and supplementary figures from repaired outputs" | 中（含历史上游 SVG；whitespace 见 §6） | 0 |
| **Commit4** | D_CANONICAL_DOCS | 58 | `git add` docs/ + claim map + audit_output + 控制文档 → commit "docs: reconcile reproducibility, provenance, and reporting status" | 低 | 0 |
| **Commit5** | E(354)+F(123)+G(2)+H(13) | 492 | E 历史快照随批保留入库；**F 删除 93 根目录垃圾 + 记录 30 已删 qa_preview**；G 标 exploratory；H 逐核 → commit "chore: isolate historical outputs and remove stale artifacts" | 中（唯一删除批；已逐条 safe 核实） | H=13（missingness_robustness 等待 provenance 甄别） |

- 顺序固定：C1→C2→C3→C4→C5（先删废弃在 C5 末，避免代码/结果落地前误删）。
- 禁止 `git add -A`；每批用精确 filelist（见 PHASE8_GIT_COMMANDS.md）。

---

## 2. Canonical 主线保护核查（P2，只读）

对 A/B/C/D 类中 Keep=YES 的项核查是否被引用；任一 YES 即 **NOT deletable**。

| 引用源 | 结果 |
|---|---|
| ACTIVE_MAINLINE_MANIFEST 引用 | YES（D01–M17/P1–P3 全部 canonical entry/output） |
| final figures / source_data 依赖 | YES（Fig3c←M09、Fig4d←M11、Fig5←outer_cv/strict_nested、Fig6←M12/M12B） |
| STATISTICAL_CLAIM_MAP 引用 | YES（C01–C30 全部指向 repaired current 产物） |
| CANONICAL_RERUN_COMMANDS 引用 | YES（canonical 链命令；kegg_fix=DO_NOT_RUN/HISTORICAL） |
| CANONICAL_OUTPUT_EXISTENCE_AUDIT 登记 | YES（29/29 存在且非零） |

**NOT deletable 列表 = 全部 A_CANONICAL_CODE(36) + B_CANONICAL_RESULTS(97) + C_CANONICAL_FIGURES(402) + D_CANONICAL_DOCS(58) 中 Keep=YES 项。**
结论：本批**唯一可删除集合 = F_ARCHIVE_DELETE(123)**（93 垃圾 + 30 已删预览），且全部已核实 0 active dependency（§3）。E/G/H 不删除（E 保留作证据；G/H 隔离/待核）。

---

## 3. 删除/移动清单源（P3）

`docs\PHASE8_DELETION_MANIFEST.csv`，登记 **123 行**：
- **93 个根目录 `@{pathway=R-HSA-*}` 垃圾文件**：只读复核仍在根目录（各 16 B），5 个 active 引用源 0 命中 → Action=DELETE_ON_AUTHORIZATION。
- **30 个 qa_preview PNG**：git D 状态（工作树已删），替换为 v2.7 final bundle → Action=KEEP_DOCUMENTED（记录已删）。
- 无其它 safe-to-remove 项。

---

## 4. Historical snapshot 隔离规划（P4，只读 + 规划）

- 既有历史资产**已位于明确目录**：M09/M11/M12/M12B/ml_v2.1 的 `*pre_repair_snapshot/`、figures_final_v2/`phase6_pre_rebuild_snapshot/`、`limma_dose_analysis/`（config=HIST_FULL_PIPE 冻结 v1.0）、全部 `.bak/.phase*.bak`。
- 散落在 active 目录需 relocate 的历史文件：**0**（HISTORICAL_ISOLATION_AUDIT 已确认无 active 目录混入历史产物；.bak 按 FINAL_COMMIT_PLAN 决策**就地随 E 批入库作 audit evidence，不移出、不 gitignore**）。
- **planned moves = 0**（决策：原地保留）。若后续改判 .bak 需集中，目标 `archive/historical/pre_repair_snapshot/`，需同时更新 provenance 指针——本轮不执行。
- 历史输出标记：全部 pre_repair/旧 M09/M11/M12/ML 输出已属 E_HISTORICAL_SNAPSHOT / HISTORICAL_ONLY；active 链只读 repaired current 目录。

---

## 5. Exploratory / post-freeze 隔离（P5）

- `ml_postfreeze_svm_rfe/`、`candidate_diagnostics_roc/` = **G_EXPLORATORY_POSTFREEZE**。
- 核查 ACTIVE_MAINLINE_MANIFEST：**未**将二者标为 canonical（无对应 active 行）；claim map 0 引用。
- 处置：Commit5 统一标 SUPPLEMENTARY_OR_DIAGNOSTIC，不进主链 claim；保留或归档待人工，**不删除**。

---

## 6. SVG whitespace 策略确认（P6）

- 执行 Phase 7 `docs\GIT_WHITESPACE_POLICY.md`：**HISTORICAL_EXCLUDE**。
- 194 行 trailing whitespace 全部在 `descriptive/figures_nature_v2.2/*.svg` + `detection_pattern` 同包（历史上游 descriptive/QC）；**不进任何 canonical commit 的 must-fix 门禁**。
- canonical 新 figures（figures_final_v2 / supplement_figures）`diff --check` = **clean**。
- 口径：global `git diff --check` 194 行 = known-historical excluded SVG，非阻断；每批 `git diff --cached --check` 期望对 canonical 改动为 0（历史 SVG 随 C3/E 入库时的既有 whitespace 不视为新引入错误）。

---

## 7. 最终工作树目标投影（P19，只读投影）

基线 1105。5 个 commit 覆盖分类基线 1085（A36+B97+C402+D58+E354+F123+G2+H13）。差量 ~20 = Phase 7/8 新建文档（含本批规划文档）与并行变更。

| 类别 | Commit 后预期 |
|---|---|
| EXPECTED_REMAINING（untracked local-only / 未入 filelist） | 本轮新建规划文档（PHASE8_*、本计划）+ 任意本地草稿 |
| UNRESOLVED（非 git，reporting/provenance 层） | ML Python 环境定位(TO_CONFIRM)、R03 universe 团队裁定(延期)、M14/D10 表重建、proteomics QC gap(转 Methods limitation) |
| UNRELATED / 待人工 | H_PREEXISTING_UNRELATED(13，missingness_robustness 等)待 provenance 甄别后再并入对应批或归档 |

**明确不声称 clean**：5 批落地后仍预计残留 H(13) + 本地新建文档；git 层目标是"分类内聚、无 F 垃圾、历史隔离"，而非零 status。

---

## 8. 纪律声明

本轮只读 + 规划；未执行删除/移动/git add/commit/push/tag；未运行分析；未改任何 frozen 结果与图。全部动作待用户显式授权后按 PHASE8_GIT_COMMANDS.md 执行。
