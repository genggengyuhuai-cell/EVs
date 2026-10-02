# TAG READINESS GATE（终局 tag 门禁判定）

> 日期：2026-10-01（Phase 7 / P23）。输入：git 工作树分类（GIT_WORKTREE_CLASSIFICATION.csv，1085 条基线）、
> STALE_ARTIFACT_ACTIONS.csv、CANONICAL_OUTPUT_EXISTENCE_AUDIT.csv、PROTEOMICS_QC_PROVENANCE_FINAL.md、
> FGSEA_REPORTING_FREEZE.md、FINAL_BLOCKER_STATUS.md、FINAL_REPRODUCIBILITY_AUDIT.md。
> 本文件只做逐项勾选与判定，不执行 commit/tag。

## 1. 逐项勾选表

| # | 门禁项 | 状态 | 证据 / 说明 |
|---|---|---|---|
| 1 | OPEN_ANALYSIS = 0 | PASS | 4 P0 + 5 P1 + fgsea 裁定全部闭合；核心分析 RERUN_VERIFIED |
| 2 | fgsea reporting frozen | PASS | FGSEA_REPORTING_FREEZE = FROZEN_AS_DUAL_REPORTED_SENSITIVITY（44 family/41 pooled，sensitivity-only） |
| 3 | pathway universe reconciled | PASS | PATHWAY_UNIVERSE_RECONCILIATION：1445 inferential / 1434 mapping / 1406 rankable；R03 延期已声明 |
| 4 | P1/P2/P3 identity frozen | PASS | Hash bound=YES + Fail-closed=YES（P1/P2 本轮补 guard；P3 同） |
| 5 | split identity frozen | PASS | REUSED_FROZEN_SPLIT，SHA256 062E5102…；386/129/515；seed 20260925 |
| 6 | software environment documented | PARTIAL | R 4.3.1 + 包版本完整；Python 3.14.7 confirmed，但 pandas/xgboost 未在项目/默认 Python 定位 = TO_CONFIRM |
| 7 | canonical outputs exist | PASS | CANONICAL_OUTPUT_EXISTENCE_AUDIT 29/29 存在且非零（D03=85、D10=85×67、M09/M11=1430、ML=15 折） |
| 8 | figures reconciled | PASS | main 6/6、supplement 10/10（figures_final_v2 + nature_v2.2 + prospective_v2.7） |
| 9 | supplement reconciled | PASS | SUPPLEMENTARY_ANALYSIS_MANIFEST 终态化；legacy=HISTORICAL |
| 10 | claim map clean | PASS | STATISTICAL_CLAIM_MAP 30 行；C05 指针已修；C16–C22 状态已降级 |
| 11 | historical outputs isolated | PASS | HISTORICAL_ISOLATION=PASS；0 数据依赖；manifest 仅 HISTORICAL 声明行 |
| 12 | proteomics provenance gap documented | PASS（作为 limitation） | QC GAP=ACTIVE → Methods limitation 转交；contaminant policy-only / decoy & protein FDR UNRESOLVED / peptide-PSM NOT_AVAILABLE |
| 13 | git worktree cleanup planned | PASS | GIT_WORKTREE_CLASSIFICATION + FINAL_COMMIT_PLAN（本轮不执行） |
| 14 | git diff --check acceptable | PASS（条件） | 194 行 whitespace 全部在 historical SVG（figures_nature_v2.2/*.svg + detection_pattern）；canonical 批次 0；未改 SVG |
| 15 | final reproducibility audit current | PASS | FINAL_REPRODUCIBILITY_AUDIT Phase 7 终态版 |
| 16 | 93 root junk files pending removal | OPEN（文档） | @{pathway=…} fgsea 重定向伪影各 16B + 30 已删 qa_preview PNG = F_ARCHIVE_DELETE 123，确认 safe-to-remove，随 Commit5 删 |
| 17 | M14 demo rebuild（P1-6） | OPEN_REPORTING | 由 D08 派生；D08 85/83/29/1 有效；不阻断代码 tag，阻断 submission 表格 |
| 18 | D10 integrated table rebuild（P1-8） | OPEN_REPORTING | 消除 deprecated peptide 传播；不阻断核心 repaired 结果 tag，阻断 submission |
| 19 | R03 inferential universe 切 1445 | OPEN（已声明延期决策） | M12 保持 Q515=1434；团队裁定；非缺陷 |

## 2. 判定

### SAFE_TO_TAG = **YES（qualified）** → 类型：**TAG_WITH_PROVENANCE_LIMITATION**

理由：
- 代码 + 数据层面，所有科学核心（M12/M12B/ML fixed-85/strict nested/M09/M11）已 RERUN_VERIFIED，
  canonical outputs 29/29 存在，historical 隔离 PASS，claim map clean，P1/P2/P3 与 split 身份已 frozen，
  OPEN_ANALYSIS=0。这些是打 analysis-v2.1 代码/数据 tag 的充分条件。
- 残留 OPEN_REPORTING 项（M14 demo / D10 表重建 / R03 决策）均为**下游表格/稿件派生**，
  其数值来源（D08/D03）已 frozen 有效，且当前 stale 产物已标 BLOCKED/rebuild-pending、不被任何主结论读取。
  它们**不阻断代码/数据 tag**，但**阻断投稿**。

**随 tag 必须附 documented limitations：**
1. proteomics identification QC provenance gap（contaminant policy-only、decoy/protein FDR UNRESOLVED、peptide/PSM NOT_AVAILABLE）→ Methods Limitation。
2. Python ML 环境未定位（pandas/xgboost not located = TO_CONFIRM）→ 复现环境待补。
3. 93 个根目录垃圾文件（+30 已删 PNG = F 类 123）待 Commit5 清理。
4. R03 inferential universe 切换（1434→1445）为已声明延期决策项。
5. M14 demo / D10 表尚未从 frozen 源重建。

### SUBMISSION_READINESS = **BLOCKED** → 类型：**SUBMISSION_METHODS_GAP**

投稿仍需闭合：
- Methods：proteomics QC Limitation 固定句、Python ML 环境定位、fgsea sensitivity-only 措辞。
- 表格：M14 演示重建、D10 整合表重建、Fig6/M14/Fig3-5 图终审。
- 决策：R03 团队裁定。
- 工程：Commit1–5 完成 + tag + 环境锁定补全。

> 结论：**代码/数据 tag 可在 Commit1–4 完成后推进（TAG_WITH_PROVENANCE_LIMITATION）；投稿（submission）仍 BLOCKED。**
