# ROC Post-Repair Reconciliation

> 日期：2026-10-01（Phase 6）。性质：只读对账；未重新选择 multigene panel、未重新拟合 ROC、未改 frozen abundance。
> 对象：`descriptive/analysis_v2.0/candidate_diagnostics_roc/`。

## 1. 结论一览

| 项目 | 结论 |
|---|---|
| Numeric ROC changed (YES/NO) | **NO** |
| Labels / provenance framing changed (YES/NO) | **YES** |
| Multigene M1–M5 refit? | NO（candidate definitions 未变） |
| New panel selected? | NO |

## 2. 为什么 numeric ROC 不变

- ROC/AUC 直接来自 **frozen protein abundance**（Discovery n=271, High=132/Low=139；Validation = reused within-cohort hold-out n=91, High=44/Low=47）。
- Phase 5/6 修复对象是 M12/M12B 通路 ranking、M09 imputation sensitivity、M11 LOO、ML outer-CV 报告值；**均不重估蛋白丰度、不改 Discovery/hold-out 分组**。
- 既有 `CANDIDATE_ROC_AUDIT.md` 已从同一 frozen abundance 复核 AUC（容差内匹配）。故本轮不重算曲线。

## 3. 保留的 figures（numeric 不变，直接沿用）

- Univariate：GOLGA3 0.693→0.703、TSPAN14 0.681→0.617、GAL 0.653→0.660、DMP1 0.662→0.595、IGF1 0.622→0.539、CSF1 0.639→0.631（Disc→Val）。
- Overlay ROC（univariate）保留 GOLGA3/TSPAN14/GAL/DMP1/IGF1/CSF1。
- Multigene M1–M5（GOLGA3+TSPAN14 / +GAL / +DMP1+IGF1 / +CSF1 / all6）保留原系数与 AUC；candidate definitions 未变，无需重拟合。

## 4. 必须更新的 provenance / label

- **Tier1 = 5 个基因（GAL、TSPAN14、DMP1、IGF1、GOLGA3），成员未变**，仍标 `Frozen_Tier1`。
- **provenance 标签改为 repaired fixed-85**：Tier1 现归属 repaired fixed-85 ML 报告（`ml_v2.1/results/`），不再引用旧 pre-repair 版本。
- **不得写 “all 5 Tier1 genes are XGB Top20-supported”**：repaired fixed-85 三算法 Top20 intersection = **4**（GAL、GOLGA3、TSPAN14、IGF1）；**DMP1 不在 XGB Top20 intersection**（repaired nested appearance DMP1=7/15，但不属 XGB Top20 交集）。Tier1=5 是 frozen 集合，但其 XGB-Top20 支持覆盖只能陈述为 4/5。
- 措辞：ROC 为 **diagnostic separation**，非 validated classifier / clinical model / diagnostic panel；Validation 95% CI 均不排除 0.5。

## 5. 被 invalidate 的旧声称（需从图注/正文删除）

- “5-gene Tier1 all supported by XGB Top20” → 改为 “4 of 5 Tier1 genes in the repaired XGB Top20 three-algorithm intersection; DMP1 retained as frozen Tier1 candidate.”
- 任何把 Validation AUC 描述为 external validation 的措辞 → 保持 “reused within-cohort hold-out; NOT external validation.”

## 6. 未做事项

- 未重算 ROC 曲线、未重拟合 M1–M5、未选新 multigene panel、未改 `candidate_diagnostics_roc/` 内既有图与 CSV（仅新增本对账文档）。
