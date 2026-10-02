# Phase 8 Final Tag Gate

> 日期：2026-10-01。P21 终局判定。
> 输入：TAG_READINESS_GATE.md（Phase 7）+ PHASE8_COMMIT_QA_REPORT.md（本轮五份 QA 全部 PASS）+ FINAL_BLOCKER_STATUS.md + CURRENT_AUTHORITATIVE_RESULTS.md。

---

## 1. 逐项勾选（Phase 8 更新版）

| # | 门禁项 | 状态 | 证据 |
|---|---|---|---|
| 1 | OPEN_ANALYSIS = 0 | **PASS** | 4 P0 + 5 P1 + fgsea 裁定全部闭合 |
| 2 | fgsea reporting frozen | **PASS** | FROZEN_AS_DUAL_REPORTED_SENSITIVITY（44 family / 41 pooled，sensitivity-only） |
| 3 | pathway universe reconciled | **PASS** | 1445 inferential / 1434 mapping / 1406 rankable；R03 延期已声明 |
| 4 | P1/P2/P3 identity frozen | **PASS** | Hash bound + fail-closed guard |
| 5 | split identity frozen | **PASS** | REUSED_FROZEN_SPLIT, SHA256 完整 |
| 6 | software environment documented | **PARTIAL** | R 4.3.1 + 包版本完整；Python ML 环境 TO_CONFIRM（limitation） |
| 7 | canonical outputs exist | **PASS** | 29/29 存在且非零 |
| 8 | figures reconciled | **PASS** | 6/6 main + 10/10 supplement；Fig6b readable names 8/8 |
| 9 | supplement reconciled | **PASS** | 10/10 PASS |
| 10 | claim map clean | **PASS** | 30×17 零错位；BLOCKED_BY_REPAIR=0；SAFE=12 / SAFE_WITH_LIMITATION=17 / SUPPLEMENT_ONLY=1 |
| 11 | historical outputs isolated | **PASS** | 0 数据依赖 |
| 12 | proteomics provenance gap documented | **PASS（limitation）** | QC GAP=ACTIVE → Methods limitation 转交 |
| 13 | git worktree cleanup planned | **PASS** | 5 commits 分批计划 + QA 全部 PASS |
| 14 | git diff --check acceptable | **PASS（条件）** | 194 行全部 historical SVG（figures_nature_v2.2）；canonical 批次 0 |
| 15 | commit QA（5 份） | **PASS** | P8/P10/P12/P14/P16 全部 PASS（见 PHASE8_COMMIT_QA_REPORT.md） |

---

## 2. 最终判定

### SAFE_TO_TAG_AFTER_COMMITS = **YES (qualified)** → 类型：**TAG_WITH_PROVENANCE_LIMITATION**

理由：
- 五份 commit QA 全部 PASS；OPEN_ANALYSIS=0；核心分析 RERUN_VERIFIED；canonical outputs 29/29 存在；figures/supplement/claim map 终审通过；historical 隔离 PASS；P1/P2/P3 与 split 身份已 frozen。
- 残留项均为已如实记录的 limitation / reporting / provenance 项，不阻断代码与数据 tag。

### 随 tag 必须附 documented limitations：
1. proteomics identification QC provenance gap（contaminant policy-only、decoy/protein FDR UNRESOLVED、peptide/PSM NOT_AVAILABLE）→ Methods Limitation
2. Python ML 环境未定位（pandas/xgboost not located = TO_CONFIRM）→ 复现环境待补
3. R03 inferential universe 切换（1434→1445）为已声明延期决策项
4. M14 demo / D10 表尚未从 frozen 源重建（reporting 项，不阻断 tag）
5. H 类 missingness_robustness 13 项归属 NEEDS_REVIEW

---

## 3. 推荐 Tag

- **Tag name**: `analysis-v2.1`
- **Tag message**: `Validated repaired EV-enriched plasma proteomics analysis pipeline v2.1`
- **Tag 类型**: annotated tag
- **执行时机**: Commit1–5 全部完成后
- **注意**: 本文件仅为判定，不执行 tag 命令

---

## 4. Submission Readiness 仍 BLOCKED

- **SUBMISSION_READINESS = BLOCKED → SUBMISSION_METHODS_GAP**
- 投稿仍需闭合：Methods 写作（QC Limitation 句、fgsea sensitivity 措辞、Python 环境定位）、表格重建（M14/D10）、R03 团队裁定、manuscript_v2_1/audit 旧数同步。
- **tag ≠ submission ready**。
