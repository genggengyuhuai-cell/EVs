# Phase 8 Commit QA Report

> 日期：2026-10-01。P8/P10/P12/P14/P16 五份 commit QA。
> 方法：只读检查（文件存在性、git diff --check 只读、filelist 内容核对）；不执行任何 commit。

---

## COMMIT1_QA = PASS

- **文件数**：37（canonical repair scripts + upstream producers + fail-closed guards）
- **P2.py 存在**：✅（code/P2.py 在 filelist 中，git status=M）
- **文件存在性**：37/37 全部存在，0 missing
- **git diff --check**：0 真实 trailing whitespace 错误（仅 LF→CRLF 行尾警告，Windows 正常）
- **无 stale/旧结果混入**：filelist 仅含 .py/.R 脚本，不含结果表
- **阻断项**：无

---

## COMMIT2_QA = PASS

- **文件数**：97（repaired results）
- **文件存在性**：97/97 全部存在，0 missing
- **pre_repair_snapshot 混入**：✅ 无（0 命中）
- **阻断项**：无

---

## COMMIT3_QA = PASS（带注记）

- **文件数**：402（figures_final_v2 + supplement_figures + figures_nature_v2.2 QC/Methods figures）
- **文件存在性**：402/402 全部存在，0 missing
- **phase6_pre_rebuild_snapshot 混入**：✅ 无（0 命中）
- **注记**：filelist 含 306 个 figures_nature_v2.2 文件（covariate_QC 等 Methods/QC 图）。SVG whitespace 策略已登记为 HISTORICAL_EXCLUDE（194 行全部位于此包，canonical 冻结批次 0）。主图 figures_final_v2 与 supplement_figures 均在列且干净。
- **阻断项**：无（figures_nature_v2.2 whitespace 已按 GIT_WHITESPACE_POLICY.md 登记排除）

---

## COMMIT4_QA = PASS

- **文件数**：58（docs/audit/manifests）
- **文件存在性**：58/58 全部存在，0 missing
- **.bak 文件混入**：✅ 无（0 命中）
- **阻断项**：无

---

## COMMIT5_QA = PASS（带注记）

- **文件数**：492（E354 historical + F123 archive cleanup + G2 exploratory + H13 unrelated）
- **文件存在性**：462/492 存在；30 missing = 已删除的 qa_preview PNG（git D 状态，预期内）
- **H 类 missingness_robustness**：✅ 在列，标记 NEEDS_REVIEW（归属未定，不判自动 safe）
- **G 类 exploratory**：
  - `candidate_diagnostics_roc/`：✅ exploratory/diagnostic（ROC 曲线诊断，非 canonical science）
  - `ml_postfreeze_svm_rfe/`：✅ exploratory/post-freeze SVM-RFE 探索
- **93 根目录垃圾文件**：在 F 类 123 safe-to-remove 中
- **canonical science 变更**：✅ 无（Commit5 仅含 historical/archive/exploratory/unrelated）
- **阻断项**：无（H 类 13 项 NEEDS_REVIEW 已登记，不阻断 commit）

---

## 汇总

| Commit | QA 结果 | 关键证据 |
|---|---|---|
| Commit1（37 code repairs） | **PASS** | P2.py 在列；37/37 存在；0 whitespace 错误 |
| Commit2（97 repaired results） | **PASS** | 97/97 存在；无 pre_repair_snapshot |
| Commit3（402 figures） | **PASS**（带注记） | 402/402 存在；无旧 snapshot；figures_nature_v2.2 whitespace 已登记排除 |
| Commit4（58 docs） | **PASS** | 58/58 存在；无 .bak |
| Commit5（492 historical/cleanup） | **PASS**（带注记） | 30 missing = 已删 PNG（预期）；H 类 NEEDS_REVIEW 已登记；无 canonical 变更 |

**总判定：五份 commit QA 全部 PASS。**
