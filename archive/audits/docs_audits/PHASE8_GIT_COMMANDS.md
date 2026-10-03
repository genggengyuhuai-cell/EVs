# PHASE 8 GIT COMMANDS（Git 执行命令草案）

> **⚠ 默认 PLAN_AND_PREPARE_ONLY。以下任何命令未经用户显式授权不得执行。**
> `git add` 仅当用户授权 staging **且**对应 commit 的 QA（`git diff --cached --check` / `--stat` / 目检）PASS 后才可进行。
> 日期：2026-10-01。基线 `git status --short`=1105；`git diff --check`=194（全部 known-historical SVG，HISTORICAL_EXCLUDE）。

## 用法约定（pathspec-from-file）

- 各 filelist 位于 `docs/PHASE8_COMMIT{N}_FILELIST.txt`，文件内含 `#` 注释行。
- `git add --pathspec-from-file=<file>` **不会**跳过 `#` 注释行，需先产出"纯路径"临时列表：
  ```powershell
  # 只读生成纯路径清单（示例；不执行 add）
  Get-Content docs\PHASE8_COMMIT1_FILELIST.txt | Where-Object { $_ -notmatch '^\s*#' -and $_.Trim() -ne '' } |
      Set-Content docs\.commit1_paths.tmp -Encoding utf8
  ```
- 然后用 `git add --pathspec-from-file=docs\.commit1_paths.tmp`（路径含空格/中文时加 `--` 分隔）。
- 每批完成后删除 `.commit*_paths.tmp`。
- 备选：直接 `git add -- <逐路径>`（路径多时不推荐）。

---

## Commit 1 — canonical code repairs

```powershell
# [ON_AUTHORIZATION] 1) stage
git add --pathspec-from-file=docs\.commit1_paths.tmp
# 2) QA
git diff --cached --check
git diff --cached --stat
git status --short
# 3) commit（QA PASS 后）
git commit -m "repair: finalize canonical analysis pipeline v2.1"
```
范围：A_CANONICAL_CODE（~36 脚本；P2.py fail-closed guard 后约 37）。期望 `--check`=0。

## Commit 2 — canonical repaired results

```powershell
# [ON_AUTHORIZATION]
git add --pathspec-from-file=docs\.commit2_paths.tmp
git diff --cached --check
git diff --cached --stat
git status --short
git commit -m "results: freeze repaired analysis outputs v2.1"
```
范围：B_CANONICAL_RESULTS（~97）。不含图、不含历史快照。期望 `--check`=0。

## Commit 3 — main + supplement figures

```powershell
# [ON_AUTHORIZATION]
git add --pathspec-from-file=docs\.commit3_paths.tmp
git diff --cached --check
git diff --cached --stat
git status --short
git commit -m "figures: rebuild main and supplementary figures from repaired outputs"
```
范围：C_CANONICAL_FIGURES（~402），含 figures_nature_v2.2 历史上游 SVG。
注：本批 `git diff --cached --check` 可能仍报历史 SVG trailing whitespace（194 行口径）；按 GIT_WHITESPACE_POLICY=HISTORICAL_EXCLUDE **不阻断**，但 figures_final_v2/supplement_figures 新图必须 clean。

## Commit 4 — audit / reproducibility / manifests

```powershell
# [ON_AUTHORIZATION]
git add --pathspec-from-file=docs\.commit4_paths.tmp
git diff --cached --check
git diff --cached --stat
git status --short
git commit -m "docs: reconcile reproducibility, provenance, and reporting status"
```
范围：D_CANONICAL_DOCS（~58，docs/ + claim map + audit_output + 控制文档）。期望 `--check`=0。

## Commit 5 — historical / archive cleanup

```powershell
# [ON_AUTHORIZATION]
git add --pathspec-from-file=docs\.commit5_paths.tmp
git diff --cached --check
git diff --cached --stat
git status --short
git commit -m "chore: isolate historical outputs and remove stale artifacts"
```
范围：E(354，历史快照/.bak 保留入库) + F(123，见下节) + G(2 exploratory) + H(13 待核)。

---

## 删除 / 移动节（全部 ON_AUTHORIZATION，本轮不执行）

### 93 个根目录垃圾文件（`@{pathway=R-HSA-*}`，各 16 B）
已核实：仍在根目录、5 个 active 引用源 0 命中。计划删除：
```powershell
# [ON_AUTHORIZATION] 不执行
Get-ChildItem -LiteralPath . -Filter '@{pathway=*' | Remove-Item -Force
# 删除后确认：
(Get-ChildItem -LiteralPath . -Filter '@{pathway=*' | Measure-Object).Count   # 期望 0
```

### 30 个 qa_preview PNG（git D 状态，工作树已删）
这些文件**已从工作树删除**（status=D），随 Commit5 的 `git add -A` 该目录或显式 `git add` 对应路径即会记录 deletion。**保持 D 状态即可，无需额外 `git rm`**。若要显式暂存删除：
```powershell
# [ON_AUTHORIZATION] 备选：显式暂存 qa_preview 删除（已在工作树删除时通常多余）
git add descriptive/discovery_validation/figures_prospective_v2.7/qa_preview/
```
替换物：v2.7 final bundle（PDF/SVG/PNG/TIFF + source_data.csv），已在 Commit3。

### 历史文件移动（planned moves = 0）
按 FINAL_COMMIT_PLAN 决策：pre_repair_snapshot / .bak **就地随 E 批入库作 audit evidence，不移出、不 gitignore**。故本轮无 Move 命令。若后续改判：
```powershell
# [ON_AUTHORIZATION] 仅备选，当前不执行
# Move-Item <scattered-historical> archive/historical/pre_repair_snapshot/
# 并同步更新 provenance 指针（Provenance_path_update=需要）
```

---

## 禁止
- `git add -A` / `git add .` 一次性全提（会混入 F 垃圾与 G/H 杂项）。
- Commit1–4 未完成前打 tag。
- 删除 E 类历史快照 / .bak（保留作证据）。
- 在无授权情况下执行本文件任何命令。
