# CURRENT AUTHORITATIVE RESULTS（FROZEN_20261001）

> **FROZEN_20261001** — 本快照为 analysis-v2.1 当前权威数字，供稿件/表格引用。
> 日期：2026-10-01。**只列 repaired / current 数字**；pre-repair 旧值（195/23/39、0.710294、
> 0.686813、8–618 旧 ML、correlation-weighted Euclidean 等）一律不进入本文件。
> 每个数字逐字引自 repaired 产物并标出处。旧值仅存于 `pre_repair_snapshot/`，标 HISTORICAL。
> Phase 7 更新：fgsea reporting hold 已解除（DUAL_REPORTED_SENSITIVITY 终态，见 FGSEA_REPORTING_FREEZE.md）；
> fgsea 44/41 为 sensitivity-only 双列，非 primary。

## 1. 队列与 Discovery（frozen）
- 519 initial → 515 final（153 Control / 186 Low / 176 High）。
- Discovery 386 / reused hold-out 129。
- **85** High-vs-Low DEPs（BH-FDR<0.05 on 1,445）；83/83→direction-concordant **83/85**；
  nominal replication **29/85**；FDR-supported replication **1/85**。
  出处：`PROJECT_CONTEXT.md §2`、`D03_candidate_lock/D03_locked_candidates.csv`、`D08_validation/D08_replication_summary.csv`。

## 2. M09 missingness sensitivity（repaired）
- Pearson = **0.974060507337**；Spearman = **0.964438407112**；direction concordance = **1343/1430**；
  primary FDR<0.05 = **0**；KNN FDR<0.05 = **0**；unresolved NA = 0。
- 出处：`M09_missingness_sensitivity/M09_manifest.csv`（POST_PHASE3_REPAIR_CURRENT）。

## 3. M11 site LOO robustness（repaired）
- n=515，9 sites，9 estimable design fits，0 non-estimable。
- Pearson range = **0.790055–0.982702**；Spearman range = **0.756893–0.979087**；
  direction concordance range = **70.77–93.50%**。
- 出处：`M11_site_robustness/M11_manifest.csv`（POST_PHASE4_REPAIR_CURRENT）。

## 4. ML fixed-85（repaired，P0-1/P0-2 闭合）
- outer 5-fold × 3 repeat = **15 folds**（n_train 216–218 / n_test 53–55）。
- mean outer AUROC：LASSO **0.6651**（range 0.4987–0.7749）；Elastic Net **0.6687**（0.5053–0.7721）；
  XGBoost **0.6488**（0.5086–0.7863）。
- 出处：`ml_v2.1/results/outer_cv_metrics.csv`（15 行；均值为本 QA 只读计算）。

## 5. ML strict nested（repaired，P1-1/P1-2 闭合）
- 15 outer folds；**7 zero-feature**（MODEL_NOT_FIT_NO_FEATURES）；**8 evaluable**。
- evaluable mean outer AUROC：LASSO **0.5967**（0.4894–0.6690）；EN **0.5937**（0.4656–0.6621）。
- 模型 = LASSO + Elastic Net only；无 XGBoost / Boruta / SVM-RFE / top-N rescue。
- 出处：`ml_v2.1/strict_nested/strict_nested_outer_metrics.csv`、`strict_nested_manifest.csv`（POST_PHASE2_REPAIR_CURRENT）。

## 6. M12 pathway（repaired，Phase 5）
- Mapping：tested **1,434** / unambiguous **1,414** / multi-gene ambiguous **15** / unmapped **5** / duplicate 0 / coverage 98.61%。
- Rankable universe N_ranked = **1,406**。
- cameraPR（FDR_pooled<0.05）：GO-BP 272 tested / **29** sig；Reactome 486 / **176**；合计 **205**。
- ORA（FDR_pooled<0.05）：GO-BP 153 背景 / **3** sig；Reactome 178 / **20**；合计 **23**。
- fgsea（双列）：family padj<0.05 = **44**（BP3/MF8/CC11/Reactome22）；pooled padj_pooled<0.05 = **41**（BP6/MF7/CC10/Reactome18）；tested=1016。
- KEGG = **NOT_RUN**。
- 出处：`M12_pathway_v2.1/mapping/M12_gene_mapping_summary.csv`、`ranked/M12_ranked_combined_FDR.csv`、
  `ora/M12_ORA_combined_FDR.csv`、`ranked_gsea/M12_fgsea_combined.csv`、`PATHWAY_FAMILY_AUDIT.csv`。

## 7. M12B context（repaired）
- integrated candidate context = **85 rows**（= D03 locked）；读 repaired M12 全链。
- secondary cameraPR GO-MF 107/16、GO-CC 151/16；secondary ORA GO-MF 7、GO-CC 4（家族内 FDR）。
- 出处：`M12B_biological_context_v2.1/integration/M12B_integrated_candidate_context.csv`、`M12B_REPAIR_REPORT.md`。

## 8. 不得作为 current 引用的旧值（仅登记）
- cameraPR 195（25 BP+170 Reactome）、fgsea family 39（3/8/11/17）= pre-repair，仅 `pre_repair_snapshot/`。
- fixed-85 ML 旧 AUROC（泄漏/which.min 方向错）= pre-P0 repair，仅 `pre_P0_repair_snapshot/`。
- M09 旧 "correlation-weighted Euclidean" / M11 旧 estimand = pre-Phase3/4 repair。
- fold-local DEP 8–618 为历史 strict nested 描述，不得作为生物学结论。
