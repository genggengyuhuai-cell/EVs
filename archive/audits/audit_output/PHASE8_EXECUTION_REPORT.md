# PHASE 8 授权执行报告 — Git Freeze 完成

- 日期：2026-10-01
- 执行模式：用户显式授权执行（删除 93 垃圾文件、Commit1–5、tag analysis-v2.1）；**PUSH=NOT_YET（未执行、确认未 push）**
- 范围：`F:\env`（Windows / PowerShell 5.1 / git）

---

## 1. 总状态

| 项 | 值 |
|---|---|
| ANALYSIS_V2_1 | **FROZEN** |
| OPEN_ANALYSIS | 0 |
| CODE_FREEZE | **COMPLETE** |
| TAG | **analysis-v2.1 已创建（annotated，指向冻结提交）** |
| PUSH | **NOT_YET（0 次 push，本地 ahead 5）** |
| SUBMISSION_READY | **NO（未改写）** |
| 工作树 | `git status --short` 剩余 32 项，全部 `??`（EXPECTED_REMAINING） |

---

## 2. 执行结果

### 2.1 删除垃圾文件
**93 个根目录 `@{pathway=R-HSA-*}` 垃圾文件已删除**（纯 untracked、各 16 B，删除前已核零依赖），复核在盘数=0。

### 2.2 Commit1–5（顺序正确，均在基线 633745d 之上）
| Commit | Hash | 文件数 | cached --check | message |
|---|---|---|---|---|
| C1 repair | `96ea08c` | 37 | 0 错误 | repair: finalize canonical analysis pipeline v2.1 |
| C2 results | `c8b2c38` | 97 | 0 错误 | results: freeze repaired analysis outputs v2.1 |
| C3 figures | `f932f8e` | 429 | 194 行白空格，**逐行核对全部 ∈ 历史前缀**（descriptive/figures_nature_v2.2 与 detection_pattern 同包），非历史错误=0 | figures: rebuild main and supplementary figures from repaired outputs |
| C4 docs | `18fd103` | 80 | 0 错误（含 1 项披露偏差，见 §3） | docs: reconcile reproducibility, provenance, and reporting status |
| C5 chore | `6d0e004` | 534 | 0 错误；30 个 qa_preview 删除已随批提交；93 垃圾路径已从 pathspec 剔除（文件已删、未跟踪） | chore: isolate historical outputs and remove stale artifacts |

`git log --oneline -6`：`6d0e004 → 18fd103 → f932f8e → c8b2c38 → 96ea08c → 633745d` ✓

### 2.3 Tag
- 既有同名旧 tag `analysis-v2.1`（annotated，目标=633745d 冻结前基线，message 旧文案 "Frozen EV-enriched plasma proteomics analysis v2.1"）为审计前陈旧"frozen"标记，与授权指令冲突 → 已删除并**按授权在冻结提交重建**：
- **新 tag**：`analysis-v2.1`（annotated）→ 目标提交 `6d0e004e5025bcf7d564dadaead133809a743a14`（C5），tag object `9e09e197…`，message = **"Validated repaired EV-enriched plasma proteomics analysis pipeline v2.1"** ✓

### 2.4 终检
- 分支：`main...origin/main [ahead 5]`——5 个本地提交，**未 push**（全程 0 次 push，无任何 remote 操作）。
- 工作树 `diff --check` = 0（历史 SVG 白空格已随 C3 提交，符合 HISTORICAL_EXCLUDE 口径）。
- 剩余 `git status --short` = **32，全部 `??` 未跟踪**，分类为 **EXPECTED_REMAINING**：Phase 7 审计交付物（GIT_WORKTREE_CLASSIFICATION.csv、HISTORICAL_ISOLATION_AUDIT.md、STALE_ARTIFACT_ACTIONS.csv、GIT_WHITESPACE_POLICY.md、CANONICAL_OUTPUT_EXISTENCE_AUDIT.csv 等）、Phase 8 规划/QA/filelist 文档、`.phase7.bak/.phase8.bak` 本地备份、PHASE8_MASTER_REPORT/本执行报告——均不在授权 filelist 内，按授权不 commit 之外的新东西。**不声称工作树 clean**（保留本地未入库项属预期）。
- 既有其它 tag（analysis-plan-v2.0 / analysis-v1.0 / analysis-v2.0-final / discovery-validation-split-v1.0 / prospective-pipeline-v1.0 / v2-ml-* 等）未动。

---

## 3. 执行偏差披露（均透明记录）

1. **陈旧锁 + 残留暂存恢复**：首次 add 遇 4 小时前陈旧 `.git/index.lock`（无 git 进程）+ 暂存区残留 40 个与 filelist 不符的混合文件（先前未完成会话遗留）。做了非破坏性恢复：删陈旧锁 + `git reset`（仅取消暂存，不动工作树内容），索引还原到 HEAD 后按 filelist 精确重建。未丢失任何工作树内容。
2. **C3/C4/C5 staged 计数 ≠ filelist 行数**（429/80/534 vs 402/59/399）：因 `git status` 折叠未跟踪目录为单行、`git add` 展开所致；已逐类核对——C3 全部属 figure 家族（含 M12 supplement_figures S-PATH 图，确认非结果文件）、C4 全属 docs、C5 全属历史隔离/删除（含 30 个 qa_preview 删除、G 类目录 candidate_diagnostics_roc/ 与 ml_postfreeze_svm_rfe/ 内容核对无误）。无超范围暂存。
3. **C4 单文件白空格清理**：`docs/P0_P1_REPAIR_PLAN.md`（P25 已归类 HISTORICAL 的历史计划文档）有 8 行 trailing whitespace，不在授权的两类历史图前缀内；为满足 cached check=0 做了**纯行尾空格清理（零内容改动）**后提交。如不认可可回退该提交单独处理。
4. **Tag 替换**：既有陈旧同名 tag 已删并在冻结提交重建（见 §2.3）——执行代理未擅自处理，由本层按授权指令核验后执行，已如实披露。

## 4. 结论

- **Git 冻结完成**：5 个语义内聚提交 + annotated tag `analysis-v2.1` 指向冻结状态（`6d0e004`）；CODE_FREEZE=COMPLETE。
- **未 push**：本地 ahead 5，等待另行授权。
- **SUBMISSION_READY=NO**：tag（代码/分析冻结）与投稿就绪严格分离，QC provenance gap、ML Python 环境定位、R03 裁定、M14/D10 重建、manuscript 同步仍未闭合，属 SUBMISSION_METHODS_GAP。
- 后续可选：`git push origin main --follow-tags`（或单独 `git push origin analysis-v2.1`）——**需你另行显式授权**。
