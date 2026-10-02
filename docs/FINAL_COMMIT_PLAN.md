# FINAL COMMIT PLAN（终局分批提交计划）

> 日期：2026-10-01（Phase 7 / P25）。**本轮不执行任何 commit/push/tag。**
> 输入：GIT_WORKTREE_CLASSIFICATION.csv（A=36 / B=97 / C=402 / D=58 / E=354 / F=123 / G=2 / H=13）。
> 原则：每批语义内聚、可回滚；先删废弃再提代码；tag 只在 Commit1–4（+必要 Commit5）后打。

## 建议分批（顺序固定）

| Commit | 类别 | 内容 | 规模（参考） |
|---|---|---|---|
| **Commit1 — canonical code repairs** | A_CANONICAL_CODE | M12_01/02/03、M12B_all、run_v2_1_ml、strict_nested_sensitivity、V2_M09/M11 修复脚本 + P1/P2/P3（含 hash/fail-closed guard）+ 上游 producer | ~36 文件 |
| **Commit2 — canonical repaired results** | B_CANONICAL_RESULTS | repaired M12/M12B/ml_v2.1/M09/M11 输出 + 上游数据/QC 参数（**不含图、不含历史快照**） | ~97 文件 |
| **Commit3 — main + supplement figures** | C_CANONICAL_FIGURES | figures_final_v2（重建 Fig1–6）+ figures_nature_v2.2 + figures_prospective_v2.7（supplement QC） | ~402 文件 |
| **Commit4 — audit / reproducibility / manifests** | D_CANONICAL_DOCS | docs/（PHASE6/7 状态、blocker、reconciliation、gate、manifests）+ manuscript_v2_1/audit claim map + audit_output + 控制文档 | ~58 文件 |
| **Commit5 — historical / archive cleanup** | E + F + G + H | E_HISTORICAL_SNAPSHOT（limma_dose v1.0 320 + pre_repair/phase6 快照 + .bak，保留作证据）；**F_ARCHIVE_DELETE（删 93 根目录 @{pathway=…} 垃圾文件 + 30 已删 qa_preview PNG）**；G exploratory（candidate_diagnostics_roc、ml_postfreeze_svm_rfe）；H pre-existing unrelated（13 项，逐核） | ~492 文件 |

## 顺序理由
1. **Commit5 中的 F（删除）放最后**：避免在代码/结果/图落地前误删任何仍被引用的文件；
   且 F 已逐条确认 safe-to-remove（93 个 16B 重定向伪影 + 30 个已删 PNG，0 依赖）。
2. E（历史快照）随 Commit5 入库保留为 audit evidence，**不 gitignore**（与 .bak 策略一致）。
3. G/H 待逐核：G 为 freeze 后探索性产物（标 exploratory，不进主链 claim）；H（missingness_robustness 等 13 项）需人工甄别归属，再并入对应批或归档。

## 提交前自检（每批）
- `git diff --check`：canonical 批次期望 0 whitespace（已知 194 行全部在 historical SVG，属 Commit3/E 内 historical 排除项，不阻断）。
- Commit1–4 不包含 F 类垃圾文件；Commit5 才删除。
- 不改任何 frozen 结果值；不重跑分析。

## 建议 tag
- **tag 名：`analysis-v2.1`**（在 Commit4 完成后打；若需区分修复版，可用 `analysis-v2.1.0-repaired`）。
- tag 时机：Commit1–4 全部落地 + Tag_Readiness_Gate 第 1–15 项保持 PASS。
- tag 附注（annotated）："analysis-v2.1 repaired canonical pipeline; OPEN_ANALYSIS=0; tag-with-provenance-limitation (QC gap, Python ML env TBC, R03 deferred); submission still BLOCKED."
- **push/tag 仍禁止在本轮执行**；待人工确认 Commit1–5 后推进。

## 禁止
- 一次性 `git add -A` 全提交（会把 F 垃圾与 G/H 杂项混入）。
- 在 Commit1–4 未完成前打 tag。
- 删除 E 类历史快照 / .bak（保留作证据）。
