# PHASE 8 主报告 — Git Cleanup + Staged Commit Preparation + Final Tag Gate

- 日期：2026-10-01
- 范围：`F:\env`（Windows / PowerShell 5.1）
- 执行模式：**PLAN_AND_PREPARE_ONLY**——本轮未执行任何删除/移动/git add/commit/push/tag；全部动作以清单与命令文档形式登记，等待用户显式授权
- 上游：Phase 7（SAFE_TO_TAG=YES qualified，TAG_WITH_PROVENANCE_LIMITATION）→ 本轮 Phase 8

---

## 1. 总判定

| 判定 | 值 |
|---|---|
| **SAFE_TO_TAG_AFTER_COMMITS** | **YES（qualified）→ `TAG_WITH_PROVENANCE_LIMITATION`** |
| 推荐 tag | `analysis-v2.1`（tag message："Validated repaired EV-enriched plasma proteomics analysis pipeline v2.1"） |
| 执行时机 | Commit1–5 全部完成并各自 QA PASS 后；**本轮不执行，等用户显式授权** |
| CODE/ANALYSIS FREEZE | READY_FOR_TAG (qualified) |
| **SUBMISSION_READINESS** | **BLOCKED → `SUBMISSION_METHODS_GAP`（tag ≠ submission ready，绝不自动写 SUBMISSION_READY=YES）** |
| 本轮是否执行 git 写操作 | **否**（删除/移动/staging/commit/push/tag 全部零执行） |

核心逻辑：canonical 主线（A/B/C/D）经 5 个引用源核查全部受保护；唯一可删集合 = F_ARCHIVE_DELETE（123 项：93 根目录垃圾文件 + 30 已删 qa_preview）经核实零依赖；5 个 commit 批次 filelist 齐备且 5/5 QA PASS；历史隔离策略确认（历史移动=0，快照就地随批入库作证据）；SVG whitespace 执行 HISTORICAL_EXCLUDE。残留均为 limitation/reporting 层，不阻断代码 tag。

---

## 2. P23 逐条回答

### 2.1 CLEANUP
- **已登记确认安全删除**：93 个根目录 `@{pathway=R-HSA-*}` 垃圾文件（只读复核：仍在根目录、各 16 B、PowerShell fgsea 数据行重定向伪影；5 个 active 引用源 0 命中）→ Action=`DELETE_ON_AUTHORIZATION`；30 个 qa_preview PNG（git D 状态，工作树已删，有 v2.7 final bundle 替换）→ `KEEP_DOCUMENTED`。合计登记 **123 项**（docs\PHASE8_DELETION_MANIFEST.csv）。**本轮未执行删除**。
- **planned moves = 0**：历史资产（.bak / pre_repair_snapshot / limma_dose_analysis v1.0 等）均已在明确快照/历史目录，决策就地随 Commit5 入库作证据，不移出、不 gitignore。
- **误删风险项**：H 类 13 项（`descriptive/missingness_robustness/`）归属未定 → NEEDS_REVIEW，Commit5 内标记，QA 不判其自动 safe。
- **历史隔离 = PASS**：historical/exploratory 输出不被 active manifest / final figures / claim map / rerun commands / existence audit 引用（P2 核查 + HISTORICAL_ISOLATION_AUDIT 延续）。

### 2.2 COMMIT1–5（filelist 与 QA 全部就绪，未执行）
| Commit | filelist | 文件数 | QA | 关键排除 |
|---|---|---|---|---|
| C1 code repairs | PHASE8_COMMIT1_FILELIST.txt | **37**（含补入的 code/P2.py，git 状态=M 已核实） | **PASS** | 不含 results/figures/audit docs/historical/.bak |
| C2 repaired results | PHASE8_COMMIT2_FILELIST.txt | **97** | **PASS** | 不含 pre_repair_snapshot、旧输出 |
| C3 figures | PHASE8_COMMIT3_FILELIST.txt | **402** | **PASS**（注记） | 不含 phase6_pre_rebuild_snapshot、figures_nature_v2.2 历史 SVG |
| C4 docs/audit/manifests | PHASE8_COMMIT4_FILELIST.txt | **59**（+2 份 STALE 文档同步后补入 CONTROL_DOCUMENT_CONSOLIDATION_REPORT） | **PASS** | 不含 .bak；已剔除 STALE_ACTIVE 旧数 |
| C5 historical/archive cleanup | PHASE8_COMMIT5_FILELIST.txt | **492**（E354+F123+G2+H13） | **PASS**（注记） | 30 个 missing=已删 PNG（预期）；H 类 NEEDS_REVIEW；无 canonical science 变更 |

- 建议 commit message：C1 "repair: finalize canonical analysis pipeline v2.1"；C2 "results: freeze repaired analysis outputs v2.1"；C3 "figures: rebuild main and supplementary figures from repaired outputs"；C4 "docs: reconcile reproducibility, provenance, and reporting status"；C5 "chore: isolate historical outputs and remove stale artifacts"。
- **STALE_ACTIVE 同步**（P14 要求，已执行）：`docs/PIPELINE_STATUS.md`（L25 旧 corr=0.931 → Pearson 0.9740605/Spearman 0.9644384/1343-1430；L28 旧 195/39 → 205/44&41）与 `docs/CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md`（L101 旧 195/39 → 205/44&41）已备份（.phase8.bak）后改为冻结值；PIPELINE_STATUS.md 本就在 Commit4，CONTROL_DOCUMENT 补入 Commit4（58→59）。

### 2.3 GIT
- **当前 status**：`git status --short` = **1119**（基线 1105 + 本轮 11 份 PHASE8 产物 + 2 份文档修改）；`git diff --check` trailing whitespace = **194**（全部在历史 figures_nature_v2.2/*.svg + detection_pattern 同包，策略 HISTORICAL_EXCLUDE，未改任何 SVG；canonical 新图 0 白空格）。
- **投影 5 个 commit 后**：覆盖分类基线 1085（37/97/402/59/490）；预期残留 = H 类 13 项（NEEDS_REVIEW）+ 本轮新建本地文档；UNRESOLVED = ML Python 环境定位、R03 裁定、M14/D10 重建、QC provenance gap（reporting/provenance 层，非 git 层）。**不声称 clean**。
- **git 命令文档**：docs\PHASE8_GIT_COMMANDS.md 已生成——每 commit 含 `git add --pathspec-from-file=<filelist>`（需先剔除 `#` 注释行）、`git diff --cached --check`、`git diff --cached --stat`、`git status --short`、`git commit -m "..."`；附删除/移动节（93 垃圾文件 rm 命令、30 qa_preview 保持 D 状态、历史移动=0），全部标注 **ON_AUTHORIZATION**。

### 2.4 TAG
- **SAFE_TO_TAG_AFTER_COMMITS = YES（qualified）→ TAG_WITH_PROVENANCE_LIMITATION**（docs\PHASE8_FINAL_TAG_GATE.md）。
- 门禁逐项：OPEN_ANALYSIS=0 ✅；OPEN_REPORTING=accepted/closed（M14/D10/R03/manuscript 同步为已知开放项，非阻断）✅；OPEN_PROVENANCE=limitation-only ✅；OPEN_GIT=prepared/cleanable ✅；figures 6/6 PASS ✅；supplement 10/10 PASS ✅；claim map 30×17 PASS ✅；canonical outputs 29/29 PASS ✅。
- **随 tag 的 documented limitations（5 条）**：① proteomics identification QC provenance gap（ACTIVE，Methods limitation）；② ML Python 环境未定位（TO_CONFIRM）；③ R03 universe 切换延期（团队裁定）；④ M14/D10 表待重建；⑤ H 类 missingness_robustness NEEDS_REVIEW。
- **SUBMISSION_READY = NO**（docs\PHASE8_SUBMISSION_STATUS.md）：tag（代码/分析冻结）与投稿就绪严格分离；QC provenance gap + Methods 措辞 + 表格重建完成后才可评估 SUBMISSION。

### 2.5 COMMANDS
- PHASE8_GIT_COMMANDS.md 已创建 ✅；5 份 filelist 已创建 ✅；**已执行 git add/commit/push/tag：0 次**（全程只读 git：status/diff --check 仅）。

---

## 3. 待用户授权清单（下一步可选动作，均未执行）
1. 授权删除 93 个根目录垃圾文件（+30 已删 qa_preview 保持 D 状态）；
2. 授权 staging + 按序执行 Commit1→Commit5（每批 commit 前跑 PHASE8_GIT_COMMANDS.md 中的 diff --cached --check/--stat 并参照 PHASE8_COMMIT_QA_REPORT.md 复核）；
3. Commit1–5 完成后（可选）执行 `git tag -a analysis-v2.1 -m "Validated repaired EV-enriched plasma proteomics analysis pipeline v2.1"`；
4. push 须另行显式授权。

## 4. 产物清单（docs\ 下，11 份新建 + 2 份修改）
PHASE8_GIT_EXECUTION_PLAN.md、PHASE8_DELETION_MANIFEST.csv（123 项）、PHASE8_GIT_COMMANDS.md、PHASE8_COMMIT1..5_FILELIST.txt（37/97/402/59/492）、PHASE8_COMMIT_QA_REPORT.md（5/5 PASS）、PHASE8_FINAL_TAG_GATE.md（SAFE_TO_TAG_AFTER_COMMITS=YES qualified）、PHASE8_SUBMISSION_STATUS.md（SUBMISSION=BLOCKED/METHODS_GAP）；修改（.phase8.bak 备份）：docs/PIPELINE_STATUS.md、docs/CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md（STALE_ACTIVE 旧数 → 冻结值）。

## 5. 纪律声明
本轮零 git 写操作、零删除、零移动、零分析运行、未联网、未改任何 repaired 数值/阈值/候选/通路选择、未改 D03/D08、未改任何图；全部结论来自只读核查与既有 repaired 产物。
