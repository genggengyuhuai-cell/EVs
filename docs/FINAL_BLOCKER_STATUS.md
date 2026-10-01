# FINAL BLOCKER STATUS（Phase 7 终局分类）

> 日期：2026-10-01（Phase 7 更新）。全局：**FREEZE_READINESS=BLOCKED · SUBMISSION_READINESS=BLOCKED · SAFE_TO_TAG=NO**。
> 分类：CLOSED_ANALYSIS / OPEN_REPORTING / OPEN_PROVENANCE / OPEN_GIT / OPEN_MANUSCRIPT_ONLY。
> **OPEN_ANALYSIS = 0**（核心分析全部 repaired/verified）。fgsea dual-reporting 已被 FGSEA_REPORTING_FREEZE 接受为终态，不再是 blocker。

## CLOSED_ANALYSIS（分析缺陷全部闭合，仅登记）
| 项 | 原 severity | 闭合证据 |
|---|---|---|
| P0-1 XGBoost outer-test 早停泄漏 | P0 | fixed-85 重跑，mean AUROC LASSO 0.6651/EN 0.6687/XGB 0.6488 |
| P0-2 EN which.min 方向错 | P0 | 改 which.max 重跑 |
| P0-3 M12 mapping nrows=0 | P0 | Phase 5 修复重跑；1434/1414/15/5 可复现 |
| P0-4 canonical 含 kegg_fix | P0 | kegg_fix=HISTORICAL_NON_CANONICAL；KEGG=NOT_RUN |
| P1-1/P1-2 strict nested 估计量+foldid | P1 | 15 folds/7 zero-feature/8 evaluable |
| P1-3 M11 LOO estimand/公式/权重 | P1 | fixed Q515、Environment retained |
| P1-4 M09 imputation 契约 | P1 | impute.knn k=10 |
| P1-5 M12 ranking 未对齐 D02 | P1 | ranking=D02 moderated t |
| fgsea canonical FDR 家族裁定 | — | **已闭合**：FGSEA_REPORTING_FREEZE = FROZEN_AS_DUAL_REPORTED_SENSITIVITY（44 family / 41 pooled 双列 sensitivity-only，不做 primary） |

## OPEN_REPORTING（需稿件/报告动作，非分析缺陷）
| 项 | 状态 | 说明 |
|---|---|---|
| Fig6 整图重建 | OPEN | a/c/d 可建；b label 待 Fig6b 重导出；Reactome 进主图；GO-MF/CC 归 supplement。图管线负责 |
| M14 演示重建（P1-6） | OPEN | 由 D08 派生（D08 85/83/29/1 有效），消除硬编码 |
| Fig3–Fig5 面板重建 | OPEN | 继承 repaired ML/M09/M11 数值 |
| D10 整合表重建（P1-8） | OPEN | 消除 deprecated peptide 传播 |
| manuscript_v2_1/audit 文档旧数 195/39 | OPEN | 待稿件/措辞管线同步为 205/23/44&41 |
| R03 inferential universe 切 1445 | OPEN（已声明延期决策项） | M12 保持 Q515=1434；团队裁定是否最终执行。不要求重跑，不计分析缺陷 |

## OPEN_PROVENANCE（无法在仓库内闭合，转 Methods limitation）
| 项 | 状态 | 说明 |
|---|---|---|
| P1/P2/P3 workbook 身份绑定（P1-7） | OPEN | 无 hash/身份校验；mapping_pass 失败不 fatal |
| proteomics identification QC gap | **OPEN_PROVENANCE / MANUSCRIPT_LIMITATION（不可闭合）** | 见 PROTEOMICS_QC_PROVENANCE_FINAL.md：contaminant=PARTIALLY_VERIFIED policy-only（no protein actually excluded）、decoy=UNRESOLVED、protein FDR=UNRESOLVED、peptide/PSM=NOT_AVAILABLE；GAP=ACTIVE。按固定 Limitation 句写入 Methods，**不得**从软件默认推断 |
| strict-nested split generator | OPEN | split 可复用但 generator 待 provenance 修复 |
| R/Python 环境锁定 | OPEN（tag 前必做） | 无 renv.lock/requirements；补 sessionInfo |

## OPEN_GIT
| 项 | 状态 | 说明 |
|---|---|---|
| 未提交/未跟踪文件 | OPEN | 1077 项（M842/??198/D30/MM3/AM3/A1）；本轮不 commit；按 FINAL_GIT_CLEANUP_PLAN.md 分批 |
| tag | 禁止 | SAFE_TO_TAG=NO；全部 OPEN 闭合后方可 |

## OPEN_MANUSCRIPT_ONLY（纯稿件写作，不影响分析/复现）
| 项 | 状态 |
|---|---|
| captions / tables / methods prose / TIFF 导出 | OPEN |
| fgsea 措辞（sensitivity-only、双列）入 Methods/Supplement | OPEN |
| proteomics QC Limitation 固定句入 Methods | OPEN |

## 汇总
- CLOSED_ANALYSIS：4 P0 + 5 P1 + fgsea 裁定 = 全部闭合；**OPEN_ANALYSIS = 0**。
- OPEN_REPORTING：Fig6/M14/Fig3-5/D10 重建 + manuscript 文档同步 + R03 决策。
- OPEN_PROVENANCE：P1/P2/P3 + proteomics QC gap（转 limitation）+ split + 环境锁定。
- OPEN_GIT：分批提交 + 暂缓 tag。
- OPEN_MANUSCRIPT_ONLY：纯写作。
- 解除 BLOCKED = OPEN_REPORTING 闭合 + OPEN_PROVENANCE 闭合 + OPEN_GIT 清理完成（OPEN_MANUSCRIPT_ONLY 随投稿流程）。
