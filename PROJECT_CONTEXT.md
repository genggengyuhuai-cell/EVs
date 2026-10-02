# PROJECT_CONTEXT.md — analysis-v2.1 authoritative overview

This file is the top-level authoritative entry point for the current project state.
It supersedes the historical v1.0 / v2.0 long-form narrative that previously lived here.
For frozen analytical detail, read the protocol and module manifests listed below.

> ## ✅ 权威总状态（2026-10-02 Phase 7 终局；覆盖本文件及 PIPELINE_STATUS 中一切旧 BLOCKED/READY/FROZEN 表述）
>
> ```
> FREEZE_READINESS          = CODE_FREEZE_COMPLETE
> SUBMISSION_READINESS      = BLOCKED（仅剩 manuscript/provenance 派生层）
> ANALYSIS_REOPEN_REQUIRED  = NO
> SAFE_TO_TAG_ANALYSIS_V2_1 = YES (qualified, TAG_WITH_PROVENANCE_LIMITATION)
> OPEN_ANALYSIS             = 0
> ANALYSIS_V2_1             = FINAL
> FROZEN_COMMIT             = 6d0e004 (annotated tag analysis-v2.1 peeled to 6d0e004)
> ```
>
> 模块级（2026-10-02 Phase 7 终态）：
> fixed-85 ML=REPAIRED_AND_VERIFIED（mean outer AUROC LASSO 0.6651 / EN 0.6687 / XGB 0.6488）；
> strict nested=REPAIRED_AND_VERIFIED（15 outer folds / 7 zero-feature / 8 evaluable）；
> M09=REPAIRED_AND_VERIFIED（Pearson 0.9741 / Spearman 0.9644）；
> M11=REPAIRED_AND_VERIFIED（9 sites LOO；Pearson 0.790–0.983）；
> M12=REPAIRED_RERUN_COMPLETE（cameraPR 205 / ORA 23 / fgsea dual 44 family + 41 pooled）；
> M12B=REPAIRED_RERUN_COMPLETE；D03 85 candidates retained；D08 85→83→29→1 retained；
> Fig6=REBUILT_PASS（6/6 main figures pass integrity audit；Fig6b Reactome 8/8 readable）；
> fgsea=FROZEN_AS_DUAL_REPORTED_SENSITIVITY（44 family / 41 pooled；sensitivity-only，永不作 primary）；
> KEGG=NOT_RUN；历史 195/23/39=PRE_REPAIR（仅存于 pre_repair_snapshot，不引用）。
>
> 冻结 split：386 discovery / 129 reused within-cohort hold-out（seed 20260925，SHA256 062E5102…B6791）。
> Hold-out 为同队列 reused，**非外部/独立验证**。
>
> 全局 BLOCKED 仅剩 submission 层（非分析）：OPEN_REPORTING（M14/D10 派生表重建、R03 universe 决策）、
> OPEN_PROVENANCE（Python ML 环境补录、proteomics QC gap 转 Methods limitation）、OPEN_GIT（关闭文档分批提交）。
> 本状态优先于 `docs/FINAL_REPRODUCIBILITY_AUDIT.md`（2026-09-29，已 SUPERSEDED）。
> 逐项证据见 `docs/FINAL_BLOCKER_STATUS.md`、`docs/TAG_READINESS_GATE.md`、
> `docs/FINAL_FIGURE_INTEGRITY_AUDIT.md`、`docs/FGSEA_REPORTING_FREEZE.md`、
> `audit_output/FINAL_ANALYSIS_FREEZE_HANDOFF.md`。

> Terminology rule: manuscript-facing wording uses **High land** and **Hot-humid**.
> The internal keys `High-pressure/high-altitude` and `Humid-hot` (and `Short`/`Long`
> dose labels) appear only inside frozen result tables and are **internal keys only**.

## 1. Study identity

- **Primary identity**: environmental-exposure EV-enriched plasma proteomics study.
- **Material wording**: EV-enriched plasma proteomics (NOT pure EV proteome; co-isolated
  plasma proteins and preanalytical effects are acknowledged limitations).
- **NOT supported as primary identity**: biomarker discovery study, predictive
  modeling study, mechanism/validation study. ML is secondary/supporting; no causal or
  mechanistic claim is made.

## 2. Cohort and frozen numbers

```
Initial cohort            519
Final analytical cohort   515   (153 Control / 186 Low / 176 High exposure)
Discovery subset          386   (prospective deterministic split, seed 20260925)
Reused hold-out subset    129   (same cohort; NOT external / independent validation)
Discovery High-vs-Low DEPs  85   (BH-FDR < 0.05 on 1,445 Discovery-eligible proteins)
Direction concordant       83 / 85
Nominal replication        29 / 85   (raw P < 0.05 on reused hold-out)
FDR-supported replication   1 / 85   (candidate-family BH-FDR across the 85)
```

Do not describe the 85 as "validated proteins", the 29 as "FDR-replicated proteins",
or the 129 as "external / independent validation cohort".

## 3. Raw-data processing (upstream, reproducibility-required)

```
code/P1.py  rawdata/processed.xlsx -> rawdata/sample_mapping_audit.xlsx
code/P2.py  rawdata/sample_mapping_audit.xlsx -> rawdata/sample_mapping_ambiguous_context.xlsx
code/P3.py  processed.xlsx + audit -> rawdata/sample_mapping_FINAL.xlsx
```

All three are **ACTIVE_MAINLINE / REPRODUCIBILITY_REQUIRED / RAW_DATA_PROCESSING**.
Relative paths only. Protected; do not archive, move, or rename.

## 4. Current analysis mainline (canonical entrypoints)

| Layer | Module | Canonical entry |
|---|---|---|
| Upstream raw data | P1/P2/P3 | `code/P{1,2,3}.py` |
| Discovery-validation | D01–D10 | D01 = `descriptive/discovery_validation/D01_discovery_eligibility.py`（根目录 Python）；D02–D10 = `descriptive/discovery_validation/code/D0*.R`（R；D08 另有 `D08_prepare_validation.py`） |
| v2 abundance | M05–M11 | `descriptive/analysis_v2.0/code/V2_M0[5-11]_*.R` (Firth / KNN / corrected-interaction variants are canonical) |
| M12 pathway | M12 v2.1 | `M12_01_mapping.R -> M12_02_ranked_ora.R -> M12_03_integration.R`（**REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD**；`M12_02b_kegg_fix.R` 已移出 canonical 链，标 HISTORICAL/NON_CANONICAL——修复见 M12_REPAIR_REPORT.md；KEGG=NOT_RUN，canonical 重跑不得依赖 KEGG download/API/enrichment/term merge；fgsea canonical FDR 家族 UNRESOLVED 待团队裁定） |
| M12B context | M12B v2.1 | `M12B_all.R` |
| M14 replication | M14 | `V2_M13_M14_reconciliation.R` -> `M14_frozen_replication/` |
| M15 ML | ml_v2.1 | `ml_v2.1/run_v2_1_ml.R` (fixed-85) + `ml_v2.1/strict_nested_sensitivity.R` (sensitivity) |
| M17 figures | M17 | `code/V2_M17_figures_v2.R` -> `figures_final_v2/` |

Older paths (`analysis_v2.0/ml/`, `figures_final_v1/`, `figures_prospective_v2.6/`,
`M12_pathway_enrichment/`, `code/V2_M12_pathway.R`, root `execute_discovery_validation_split.R`)
are **HISTORICAL_FROZEN** under `archive/` and are not current entrypoints.

## 5. Frozen statistical interpretation boundaries

- **Replication hierarchy**: 85 discovery DEPs -> 83 direction concordant -> 29 nominal
  -> 1 FDR-supported. The 1 is the only multiplicity-controlled single-protein replication
  on the reused hold-out.
- **Interaction**: 0 / 1,430 Group × Environment interactions survived BH-FDR < 0.05.
  Wording: "No interaction survived the prespecified BH-FDR threshold." Do not write
  "there was no interaction". Environment-stratified concordance is descriptive, not
  an interaction test.
- **Site LOO**: robustness analysis, NOT replication / external validation.
- **ML fixed-85 conditional analysis**: predictive performance is **conditional on the
  frozen 85-protein discovery panel**; not an unbiased generalization estimate.
- **ML strict nested sensitivity**: fold-local DEP count range 8–618 reflects
  feature-selection instability under resampling; do not describe as biological
  heterogeneity or as the primary ML result.
- **Boruta-style**: hand-rolled ranger-based feature-importance procedure; manuscript
  wording is "Boruta-style random-forest feature importance analysis".
- **XGBoost importance**: descriptive, post-selection; not causal, not a biomarker effect.

## 6. Pathway frozen numbers

```
cameraPR (primary, competitive)        205 FDR-significant pathways (FDR_pooled<0.05, GO-BP+Reactome)
                                        GO BP 29; Reactome 176
ORA (complementary, one-sided Fisher)    23 pathways (FDR_pooled<0.05)
                                        GO BP 3; Reactome 20
fgsea (sensitivity, ranked, dual-col)   family padj<0.05 = 44 ; pooled padj_pooled<0.05 = 41
                                        family: GO BP 3; GO MF 8; GO CC 11; Reactome 22
                                        pooled: GO BP 6; GO MF 7; GO CC 10; Reactome 18
                                        Canonical_FDR = UNRESOLVED (reporting HOLD)
KEGG                                   NOT_RUN (placeholder CSVs only)
Mapping universe:
  tested protein groups                1434
  unambiguous one-gene mappings        1414
  multi-gene ambiguous                 15
  unmapped                              5
  rankable gene-set subset (N_ranked)  1406  (= mapped 1414 ∩ D02 ESTIMABLE; R03 见下)
```

> 历史值（pre-repair，仅存于 `pre_repair_snapshot/`）：cameraPR 195（25 BP+170 Reactome）、
> ORA 23（不变）、fgsea family 39（3/8/11/17）。这些不得再作为 current 数字引用。
> 三层 universe 语义见 `docs/PATHWAY_UNIVERSE_RECONCILIATION.md`。

Do NOT add 205 + 23 + 44 and call it a single pathway count. The three methods answer
different questions; they are primary / complementary / sensitivity. fgsea 44 vs 41 为双列口径，
未裁定前两套都不标 FINAL_FROZEN。

## 7. Repository layers

- **ACTIVE_MAINLINE**: P1/P2/P3; D01–D10; M05–M11 canonical; M12 v2.1; M14;
  ml_v2.1 entry + final required outputs; M17 `V2_M17_figures_v2.R` +
  `figures_final_v2/`; upstream config/contracts/universes/manifests/registry.
- **SUPPLEMENTARY / ACTIVE_SUPPORTING**: M08 Firth details, M09 KNN, M10 stratified
  detail, M11 LOO per-protein, D04/D05/D07/D09/D10, ORA full, fgsea full, M12B
  correlation/network/annotation, ML full CV tables, strict-nested full split tables,
  Boruta/XGBoost importance, upstream descriptive figures under
  `descriptive/figures_nature_v2.2/` (11 dirs, ~649 files; producers 06–11 +
  nature_plotting.py).
- **HISTORICAL_FROZEN** (under `archive/historical_frozen/`): `figures_final_v1/`,
  `figures_prospective_v2.6/`, `M12_pathway_enrichment_v1/`, `ml_legacy/`,
  M13 historical reconciliation, KEGG placeholder CSVs.
- **ARCHIVE** (`archive/debug|installers|logs|superseded_code|historical_frozen/`):
  see `archive/ARCHIVE_MANIFEST.csv` and `archive/HISTORICAL_MANIFEST.csv`.

## 8. Manuscript framing (current)

R1 cohort/universe -> R2 proteome landscape -> R3 85 High-vs-Low discovery DEPs ->
R4 reused-hold-out hierarchy (85/83/29/1) -> R5 robustness summary ->
R6 representative pathway themes. ML and full pathway tables are supplementary.
M12B is biological context / interpretation, not mechanistic validation.

## 9. Remaining tasks (as of 2026-10-01 Phase 6)

> **状态变更（2026-10-01 Phase 6）**：分析侧修复已基本闭合——fixed-85 ML、strict nested、
> M09、M11 均已 REPAIRED_AND_VERIFIED；M12/M12B 已 canonical 重跑（fgsea FDR 家族 HOLD）。
> 全局仍 BLOCKED，剩余项为 reporting / provenance / git，不再要求重跑核心分析：

1. **OPEN_REPORTING**：fgsea canonical FDR 家族团队裁定（解除 44/41 HOLD）；Fig6 整图重建
   （a/c/d 可先建，b 待 fgsea 口径冻结；Reactome 必须进主图；GO-MF/CC 归 supplement）。
2. **OPEN_PROVENANCE**：P1/P2/P3 workbook 身份绑定（P1-7）；proteomics QC provenance；
   strict-nested split generator  provenance。
3. **OPEN_GIT**：仓库大量未跟踪/未提交文件，需按 `docs/FINAL_GIT_CLEANUP_PLAN.md` 分类分批提交；
   本轮不 commit。
4. 全部闭合后，才进入：analysis-v2.1 freeze tag（当前 **NO**）；Manuscript assembly；
   Nature-style writing / polishing / reviewer simulation / pre-submission review。

在上述完成前，不得 rerun Discovery/D08，不得改 frozen 结果值、通路阈值或 GO/Reactome 数据库，不得 git tag。

## 10. Canonical control documents

- `docs/PIPELINE_STATUS.md` — per-module status table.
- `docs/CONTROL_DOCUMENT_INDEX.csv` — classification of every control document.
- `docs/ACTIVE_MAINLINE_MANIFEST.csv`, `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv`,
  `docs/REPOSITORY_RISK_REGISTER.csv`, `docs/FINAL_REPOSITORY_RECONSTRUCTION_AUDIT.md`.
- `manuscript_v2_1/audit/STATISTICAL_REPORTING_AUDIT.md`,
  `STATISTICAL_CLAIM_MAP.csv`, `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`,
  `EXPERIMENTAL_DESIGN_REVIEW.md`, `PROJECT_RECONSTRUCTION_PLAN.md`,
  `REVIEWER_RISK_REGISTER.csv`, `MANUSCRIPT_MODULE_MAP.csv`.
- `docs/FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md`.

Older status/task files under `docs/workflow/` and `docs/task/` are HISTORICAL snapshots
unless listed above as current.
