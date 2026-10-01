# FINAL GIT CLEANUP PLAN（终局 git 清理计划）

> 日期：2026-10-01。**本轮不 commit / push / tag**（SAFE_TO_TAG=NO）。
> 当前 `git status --porcelain` 总量 1077：M=842 / ??=198 / D=30 / MM=3 / AM=3 / A=1。
> 本计划把这些变更按语义分类，建议未来**分多个 commit**，而非一次全提交。

## 分类定义（建议未来分 commit 批次）

| 类 | 含义 | 典型文件 | 建议 commit |
|---|---|---|---|
| **A canonical code repair** | 修复后的 canonical 脚本（逻辑修复，非结果） | `M12_01/02/03*.R`、`M12B_all.R`、`run_v2_1_ml.R`、`strict_nested_sensitivity.R`、`V2_M09/M11*.R`、`D10*.R` | 1 commit "fix: canonical estimator/imputation/provenance repairs" |
| **B canonical result rebuild** | repaired 重跑产物 | M12_pathway_v2.1/{mapping,ranked,ora,ranked_gsea,integration,diagnostics}/、M12B repaired 输出、ml_v2.1/{results,strict_nested}/、M09/M11 repaired | 1 commit "data: repaired rerun outputs (M12/M12B/ML/M09/M11)" |
| **C figure rebuild** | 重建后的图（**本轮未重画，待图管线**） | figures_final_v2/ Fig3–6 | 待 Fig6 重建后单独 commit |
| **D audit / control docs** | 本轮及历史审计/状态文档 | docs/PHASE6_STATUS_BASELINE、FINAL_BLOCKER_STATUS、CURRENT_AUTHORITATIVE_RESULTS、reconciliation、checklist、manifest 更新、PROJECT_CONTEXT/README 更新、audit_output/* | 1 commit "docs: final status baseline + blocker registry" |
| **E historical snapshot** | pre-repair 快照（保留，不删） | `M12_pathway_v2.1/pre_repair_snapshot/`、`M12B.../pre_repair_snapshot/`、`pre_P0_repair_snapshot/`、`*.phase*.bak`、`*.bak` | 单独 commit 或 .gitignore（建议保留为 audit evidence，不 gitignore） |
| **F archive-delete** | 确认废弃、可删除 | 30 个 D（deleted）文件，多为旧 v1/v0 脚本与 superseded 输出 | 1 commit "chore: remove superseded v1 artifacts"（删除前逐文件核对 archive/） |
| **G exploratory-postfreeze** | 冻结后探索性产物（不进主链） | 候选 ROC M1–M5、Boruta/XGB importance 探索表 | 标记 exploratory，进 supplement commit 或单独 |
| **H unrelated-pre-existing** | 与本修复无关的既有改动 | 工作区长期未提交的杂项、文档草稿、预览 PNG | 逐个甄别后并入 D 或归档 |

## 分批提交顺序建议
1. **F**（先删废弃）→ 2. **A**（代码修复）→ 3. **B**（repaired 结果）→
4. **D**（审计/控制文档）→ 5. **E**（历史快照归档）→ 6. **G/H**（探索与杂项）→
7. **C**（图重建，待 Fig6）。每批 commit 前跑 `git diff --check`（已知既有 SVG trailing whitespace 为历史问题，非本轮产物）。

## 注意
- `.bak` / `.phase*.bak` 备份：建议随 E 类保留在库（作为修复证据），或加 .gitignore——二选一，需一致。
- 30 个 D：删除前确认已在 `archive/historical_frozen/` 有副本，避免误删 frozen 证据。
- 本轮**不执行**任何 git 写操作；本文件仅为计划。
- tag 仍禁止；待 OPEN_REPORTING/OPEN_PROVENANCE/OPEN_GIT 全部闭合后。
