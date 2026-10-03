# Phase 8 Submission Status Separation

> 日期：2026-10-01。Phase 8 P22。
> 目的：明确区分 CODE/ANALYSIS FREEZE（可推进 tag）与 MANUSCRIPT SUBMISSION READINESS（仍 BLOCKED）。

---

## 1. 两层状态分离

| 层级 | 判定 | 说明 |
|---|---|---|
| **CODE / ANALYSIS FREEZE** | **READY_FOR_TAG (qualified)** | 所有科学核心分析已 RERUN_VERIFIED；canonical outputs 29/29 存在；OPEN_ANALYSIS=0；figures/supplement/claim map 终审通过；provenance gap 已如实登记为 limitation。可在 Commit1–5 完成后打 `analysis-v2.1` tag（TAG_WITH_PROVENANCE_LIMITATION）。 |
| **MANUSCRIPT SUBMISSION READINESS** | **BLOCKED → SUBMISSION_METHODS_GAP** | 即使 tag 门禁 YES，投稿仍未就绪。原因：Methods 未补全、QC provenance gap 需写入 Limitation、表格（M14/D10）未重建、R03 未决策、fgsea sensitivity 措辞未入正文、manuscript_v2_1/audit 旧数未同步。 |

---

## 2. CODE / ANALYSIS FREEZE — 可推进项

- OPEN_ANALYSIS = **0**（4 P0 + 5 P1 + fgsea 裁定全部闭合）
- 核心模块 RERUN_VERIFIED：fixed-85 ML、strict nested、M09、M11、M12、M12B
- canonical outputs 29/29 存在且非零
- Figures 6/6 PASS、Supplement 10/10 PASS
- Claim map 30×17 零错位、BLOCKED_BY_REPAIR=0
- P1/P2/P3 identity frozen、split identity frozen
- Historical outputs isolated（0 数据依赖）

**结论**：代码与数据层面可打 tag（附 documented limitations）。

---

## 3. SUBMISSION READINESS — 阻断项（SUBMISSION_METHODS_GAP）

| 阻断类别 | 具体项 | 状态 |
|---|---|---|
| **Methods 写作** | proteomics identification QC Limitation 固定句（contaminant policy-only / decoy UNRESOLVED / peptide-PSM NOT_AVAILABLE） | OPEN |
| **Methods 写作** | fgsea sensitivity-only 措辞（DUAL_REPORTED_SENSITIVITY，不作 primary） | OPEN |
| **Methods 写作** | Python ML 环境定位（pandas/xgboost not located = TO_CONFIRM） | OPEN_PROVENANCE |
| **表格重建** | M14 demo 重建（P1-6，从 D08 派生） | OPEN_REPORTING |
| **表格重建** | D10 integrated table 重建（P1-8，消除 deprecated peptide 传播） | OPEN_REPORTING |
| **决策** | R03 inferential universe 切 1445（团队裁定，已声明延期） | OPEN（决策项） |
| **manuscript 同步** | manuscript_v2_1/audit 下旧数同步（195→205、39→44&41、8–618→7/15 zero-feature） | OPEN_REPORTING |
| **工程** | Commit1–5 执行 + tag + 环境锁定补全 | OPEN_GIT |

---

## 4. 关键原则

1. **tag ≠ submission ready**：打 analysis-v2.1 代码/数据 tag 仅意味着分析管线已冻结、可复现；不代表稿件可投稿。
2. **即使 SAFE_TO_TAG=YES，也不自动写 SUBMISSION_READY=YES**。
3. **provenance gap 转 Methods Limitation**：proteomics QC gap 不阻断 tag（作为已记录 limitation），但阻断投稿（需写入正文 Methods）。
4. **R03 为决策项，非缺陷**：M12 保持 Q515=1434 口径已如实登记；团队裁定是否最终切 1445。

---

## 5. 终局状态总览

- **FREEZE_READINESS** = BLOCKED（因 OPEN_GIT + OPEN_REPORTING 未闭合）
- **SAFE_TO_TAG_AFTER_COMMITS** = YES (qualified) → TAG_WITH_PROVENANCE_LIMITATION
- **SUBMISSION_READINESS** = BLOCKED → SUBMISSION_METHODS_GAP
- **ANALYSIS_REOPEN_REQUIRED** = NO（OPEN_ANALYSIS=0）
- **SAFE_TO_TAG_ANALYSIS_V2_1** = 待 Commit1–5 执行后 YES
