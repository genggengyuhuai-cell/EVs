# P0/P1 Repair Plan and Dependency Impact Record

Date recorded: 2026-09-30
Review mode: static, read-only review of code, manifests, documentation, and existing outputs
Execution performed: none
Source or result files modified: none

## Executive summary

The analysis freeze is blocked. All four prescribed P0 findings and all eight prescribed P1 findings are confirmed by the current repository state. The current results must not be described as `PASS_WITH_LIMITATIONS`, `READY_TO_TAG_WITH_LIMITATIONS`, or `ALL_RERUN_READY`.

The minimum safe reopening boundary is selective rather than global. D03's locked set of 85 Discovery DEPs, D08's raw hold-out replication table and hierarchy, and the existing discovery/validation assignment may be retained. Fixed-85 ML, strict-nested ML, M09, M11, M12, M12B, affected candidate diagnostics, derived integration tables, affected figure panels, and final reproducibility/control documents require repair or rebuilding in dependency order.

Final static assessment:

```text
P0_confirmed = 4
P1_confirmed = 8
P2_confirmed = 4
Freeze_readiness_score = 1/10
Analysis_reopen_required = YES
Safe_to_tag_analysis_v2.1 = NO
```

The P2 count records four lower-severity audit observations outside the requested P0/P1 repair boundary: normal-quantile rather than finite-df interval construction in the shared discovery/validation helper; hard-coded presentation assumptions in M17; a recursive output-cleanup helper whose safety depends on correct caller paths; and incomplete environment/package locking. They should be resolved before the final reproducibility claim, but they do not change the rerun boundary below.

## P0 findings

### P0-1 — XGBoost outer-test early-stopping leakage: CONFIRMED_P0

In `descriptive/analysis_v2.0/ml_v2.1/run_v2_1_ml.R`, each outer fold constructs `Xte`/`yte`, converts the outer test data to `dtest`, then supplies `dtest` as the evaluation watchlist to `xgb.train()` with `early_stopping_rounds = 20`. The same outer test labels therefore determine the selected boosting length before the reported outer-test AUROC is calculated.

Required repair contract:

```text
outer train
  -> stratified inner split or inner CV
  -> select hyperparameters and nrounds/early-stopping iteration
  -> refit on the complete outer-train fold using the selected settings
  -> predict the untouched outer-test fold exactly once
```

The outer test fold must not participate in early stopping, round selection, tuning, or feature selection. The affected scope is not limited to AUROC. Fold-level XGBoost gain/rank is also affected because the fitted fold model and its stopping iteration were selected using the outer test set. The separate full-data XGBoost fit is not directly outer-test-leaked, but any frozen interpretation that combines it with the flawed resampling ranks or performance must be rebuilt and re-audited.

### P0-2 — Elastic Net AUC optimization direction: CONFIRMED_P0

The same ML script requests `type.measure = "auc"` but uses `which.min(cv_en$cvm)` in the outer-fold alpha comparison and in the full-data refit. AUC must be maximized. The current code consequently favors the worst mean AUC within each alpha fit and then compares those incorrectly selected values.

Affected outputs include selected EN alpha/lambda, fold coefficients, EN selection frequencies, full-data EN coefficients, the integrated 85-protein table, Tier1 membership, ML intersection audits, ML support/convergence figures, and candidate definitions derived from Tier1. The five-gene Tier1 combination used as candidate ROC model M3 is therefore not frozen evidence.

### P0-3 — M12 mapping entry-point reproducibility break: CONFIRMED_P0

`M12_01_mapping.R` reads the compressed PRIMARY expression CSV using `row.names = 1, nrows = 0`, then sets `tested_prots <- rownames(expr)`. Reading zero data rows cannot populate the 1,434 protein row names.

```text
Can current code reconstruct 1434 tested proteins? NO
```

The existing mapping outputs report 1,434 tested, 1,414 unambiguous one-gene mappings, 15 multi-gene mappings, and 5 unmapped proteins, but the current entry script cannot generate that universe. No alternative active generator for this mapping output was found. Git history for the current path did not identify a committed predecessor that explains the existing output. Provenance status is therefore:

```text
CODE_CURRENT: zero-row header read; tested protein row names are unavailable
OUTPUT_EXISTING: populated 1434/1414/15/5 mapping result
STATUS: PROVENANCE_MISMATCH; exact producing code state not registered in the current mainline
```

The repair must read only the first column or otherwise enumerate all expression row identifiers without loading or altering the abundance matrix, assert 1,434 unique IDs, and then rebuild every downstream M12/M12B product.

### P0-4 — Canonical M12 chain conflicts with KEGG NOT_RUN: CONFIRMED_P0

`PROJECT_CONTEXT.md`, `docs/PIPELINE_STATUS.md`, and `docs/ACTIVE_MAINLINE_MANIFEST.csv` place `M12_02b_kegg_fix.R` in the canonical M12 execution chain. That script performs KEGG-related retrieval and rewrites combined ranked/ORA products. At the same time, `M12_03_integration.R` and project documentation declare KEGG `NOT_RUN`.

```text
Does canonical rerun currently execute KEGG-related code? YES
```

Preferred repair: remove `M12_02b_kegg_fix.R` from the active canonical chain, retain it as historical-only material, and preserve the declared KEGG `NOT_RUN` scope. Alternative repair, requiring explicit user authorization, is to redefine the pathway analysis to include KEGG with a fixed reproducible source and corresponding protocol/document changes. The alternative is not authorized by this plan.

## P1 findings

### P1-1 — Strict nested discovery is not aligned with D02: CONFIRMED_P1

| Model component | D02 primary discovery | Strict nested sensitivity | Match? |
|---|---|---|---|
| Estimator | limma linear model | Welch two-sample `t.test` | No |
| Environment adjustment | Included in `~0 + dose + environment` | Absent | No |
| Empirical-Bayes trend | `trend = TRUE` | Not applicable/absent | No |
| Robust moderation | `robust = TRUE` | Not applicable/absent | No |
| Missingness handling | D01 eligible matrix; no global imputation | Fold-local detection eligibility and complete values for t-test | No |
| Contrast | High minus Low | High versus Low | Directionally yes |
| Weights | No separate observation-weight contract identified in D02 | None | Yes only in the narrow sense of no explicit weights |
| Multiple testing | BH across the D02 tested family | BH within each fold's eligible family | No, family varies by fold |

The reported variation of 8–618 selected features cannot be interpreted solely as resampling instability. It combines resampling with a change of estimator, covariate adjustment, moderation, missingness/tested universe, and multiple-testing family.

### P1-2 — Inner-CV stratification mismatch: CONFIRMED_P1

The strict-nested `cv.glmnet()` calls do not receive a stratified `foldid`, while the manifest describes 5-fold stratified inner CV. This is `DOCUMENTATION_IMPLEMENTATION_MISMATCH`. The fixed-85 EN calls should be checked and repaired under the same explicit fold assignment contract.

### P1-3 — M11 changes the primary estimand: CONFIRMED_P1

M11 removes one site, drops Environment from the model, uses `~0 + Group`, and recomputes group weights in each reduced subset. The comparison with the M05 full-cohort effect therefore changes the sample subset, adjustment set, formula, and weights simultaneously. It cannot be interpreted as pure site robustness. The repaired leave-one-site-out fit must preserve the identifiable primary estimand and explicitly handle folds where adjustment becomes non-estimable.

### P1-4 — M09 code/manifest method mismatch: CONFIRMED_P1

The code z-scores each protein, selects neighboring proteins by correlation, and fills each missing cell with the unweighted median of available neighbor values. It does not implement correlation-weighted Euclidean imputation. It also lacks an explicit contract for NA correlations before neighbor ordering; remaining missing values are filled using a row median. The manifest description `correlation-weighted Euclidean` is therefore inaccurate. The code and protocol must be reconciled before M09 can support a robustness claim.

### P1-5 — M12 pathway estimator differs from D02: CONFIRMED_P1

M12 uses a High/Low-only group design after global row-median imputation. D02 uses the eligible non-imputed matrix, includes Environment, applies the High-minus-Low contrast, and uses limma with `trend = TRUE, robust = TRUE`. The ranking statistic therefore targets a different estimator even when the contrast label is similar.

```text
PATHWAY_ESTIMAND_NOT_ALIGNED_WITH_PRIMARY_DISCOVERY
```

### P1-6 — M14 hard-coded and stale status: CONFIRMED_P1

`V2_M13_M14_reconciliation.R` directly encodes the sequence 85, 85, 83, 29, and 1 rather than deriving it from source tables. It also emits stale pathway/ML status text even though those modules now have outputs. Status is `STALE_AND_HARDCODED_STATUS_OUTPUT`. The numeric hierarchy agrees with the current D08 result but its presentation output is not independently regenerable from its declared inputs.

### P1-7 — P3 input drift and invalid-output persistence risks: CONFIRMED_P1

`code/P3.py` relies on P1-recorded row positions/metadata indices without verifying the source workbook identity or content hash. It writes the FINAL product before evaluating `mapping_pass`; failure is reported but not raised as a fatal error and the already-written final file remains. Status:

```text
INPUT_DRIFT_RISK
INVALID_OUTPUT_PERSISTENCE_RISK
```

P3 is an upstream reproducibility risk. Existing downstream scientific results are not automatically invalidated without evidence of actual workbook drift, so P1–P3 are not placed in the immediate minimum rerun set. They must be repaired and revalidated before claiming full end-to-end regeneration.

### P1-8 — D10 propagates deprecated peptide evidence: CONFIRMED_P1

D10 reads the unique-peptide evidence table and incorporates it into newly written integrated tables, contrary to the v2.1 instruction not to propagate peptide evidence into new outputs. Status is `PROTOCOL_IMPLEMENTATION_CONFLICT`. D10 outputs containing these fields cannot be treated as v2.1-conformant. This does not require rerunning D03 or the raw D08 replication analysis.

## Control-document conflicts

Overall status: `CONTROL_DOC_STALE`.

- `PROJECT_CONTEXT.md` still lists the final reproducibility audit as not started while also describing the project as frozen.
- `docs/README.md` still calls v2.0 the current/highest protocol despite the v2.1 analysis layer.
- `docs/ACTIVE_MAINLINE_MANIFEST.csv` contains incorrect locations/extensions, including D01 and D02–D07 entries that do not match the actual Python/R files.
- `docs/FINAL_REPRODUCIBILITY_AUDIT.md` claims `RERUN_READY` and no blockers despite the confirmed P0/P1 findings.
- The M12 canonical-chain documents include the KEGG fix while simultaneously preserving KEGG `NOT_RUN`.

These documents must be updated only after the repaired outputs and assertions exist; editing them first would conceal rather than resolve the implementation state.

## Split provenance status

The frozen assignment, integrity assertions, and split manifest exist and record the seed, protocol, counts, and hashes needed to identify the existing 515-participant assignment (386 Discovery, 129 Validation).

```text
Can existing split be reused exactly? YES
Can split be regenerated from upstream inputs through the active mainline? NO
Status: REUSABLE_BUT_NOT_FULLY_REGENERABLE
```

An apparent generator exists at `archive/superseded_code/execute_discovery_validation_split.R`. It contains the fixed seed, stratum counts, deterministic ordering, assertions, and output contract, so it is useful provenance evidence. Because it is archived/superseded and absent from the active registered chain, it is not presently a canonical regeneration entry point. Restoration to the active workflow should be a separately reviewed provenance repair; the split itself should not be regenerated for the current analytical repair.

## Keep-unchanged evidence

| Evidence | Status | Basis |
|---|---|---|
| D03 locked 85 Discovery DEPs | KEEP_UNCHANGED | Defined before and independently of the confirmed ML, M09, M11, and M12 defects |
| D08 raw 85-protein hold-out replication table | KEEP_UNCHANGED | Uses the locked candidates and hold-out data; no dependency on EN, XGBoost, M09, M11, or M12 |
| D08 hierarchy 85/85/83/29/1 | KEEP_UNCHANGED as underlying evidence | Raw table supports it; only M14's hard-coded presentation must be rebuilt |
| Discovery/validation assignment | KEEP_UNCHANGED | Frozen assignment and manifest are present; no evidence that the listed defects altered its membership |
| Raw source data and PRIMARY abundance inputs | KEEP_UNCHANGED_FOR_NOW | No P0 finding establishes corruption of these files |

## Do-not-freeze evidence

- XGBoost outer-fold AUROC and fold-derived feature gain/ranks.
- Elastic Net alpha/lambda, coefficients, selection frequency, and any support threshold based on them.
- Tier1 and all ML intersection/convergence claims that include EN or leaked XGBoost evidence.
- Strict-nested feature-count range and any claim that it measures resampling instability alone.
- M09 missingness robustness and M11 pure-site-robustness claims.
- M12 mapping, cameraPR, fgsea, ORA, the reported 195/23/39 pathway counts, M12 integration, and all M12B interpretations.
- Candidate ROC material as final evidence, especially Tier1-derived labels and M1–M5 model definitions.
- Figure 3 as a complete frozen figure because panels a–d take their 85-candidate frame from the ML integrated table; panel c additionally depends directly on M09. The locked candidate IDs may remain, but the figure/source data must be regenerated from repaired inputs.
- Figure 4 panel d because it depends on M11. Panels a–c may be retained if source identity checks confirm no M11 dependency.
- Figure 5 panels b–d because they contain affected ML results. Panel a must be regenerated from a source-derived M14 hierarchy even though the underlying D08 counts remain valid.
- Figure 6 panels a–d because all depend on the unreproducible/misaligned M12 chain.

## ROC diagnostics status

All current files under `candidate_diagnostics_roc/` may be retained physically but are classified as:

```text
EXPLORATORY_DIAGNOSTIC
NOT_FINAL_FROZEN_EVIDENCE
REQUIRES_RELABEL_OR_REBUILD_AFTER_ML_REPAIR
```

The hard-coded candidates are GOLGA3, TSPAN14, GAL, DMP1, IGF1, and CSF1. The first five are labeled Tier1; CSF1 is SVM-specific. Model definitions are M1 = GOLGA3 + TSPAN14; M2 adds GAL; M3 is the five-gene Tier1 set; M4 is CSF1 + GOLGA3 + TSPAN14; and M5 combines all six. Consequently M3, M5, the Tier1/SVM labels, and comparisons framed around them require reconstruction after corrected ML. M1, M2, and M4 still use candidates selected under the same flawed frozen evidence context and therefore remain exploratory until candidate provenance is re-established.

The script also chooses ROC direction independently in validation (`direction = "auto"`) and reports a validation-optimal cutoff. Those quantities are descriptive/optimistic and must not be presented as locked external-validation operating characteristics; the discovery-derived cutoff application is the defensible validation metric.

## Dependency graph

The actual module-level dependencies are:

```text
P1/P2/P3 -> processed abundance and metadata -> frozen split + D01
D01 -> D02 -> D03
D03 + frozen split + PRIMARY matrix -> D08
D03 + D08 + frozen split + PRIMARY matrix -> fixed-85 ML
D01/PRIMARY + split -> strict-nested ML
fixed-85 ML + strict-nested ML -> integrated ML evidence/intersection audits
integrated ML evidence + D03 + PRIMARY + split -> candidate ROC definitions/diagnostics

PRIMARY + Q515 + M05 -> M09
PRIMARY + metadata + Q515 + M05 -> M11
PRIMARY + split + mapping + D03 + ML evidence -> M12
M12 + D03 + ML/strict evidence -> M12B

M09 + ML integrated table + M06 -> Figure 3
M10 + M11 -> Figure 4
D08/M14 + fixed-85 ML + strict-nested ML -> Figure 5
M12 ranked/ORA/integration -> Figure 6
```

This corrects the proposed shorthand: M09 and M11 do not directly depend on D02/D03 in their current implementations; both use the full-cohort M05/PRIMARY branch. M12 uses D03 for candidate foreground/integration but currently refits its own misaligned ranking model.

## Repair phases

1. **Phase 1 — Fixed-85 ML.** Correct EN AUC maximization and XGBoost nested stopping; add explicit fold contracts; rerun only fixed-85 ML; rebuild EN/XGB and integrated ML outputs.
2. **Phase 2 — Strict nested.** Align fold-local discovery with D02's estimand and moderation; implement actual stratified inner CV; rerun nested sensitivity; revise instability interpretation.
3. **Phase 3 — M09.** Choose and document one imputation contract, including weights, distance/similarity, ties, and NA correlations; make code and manifest agree; rerun M09.
4. **Phase 4 — M11.** Preserve the primary estimand under site deletion and define non-estimable-fold behavior; rerun M11.
5. **Phase 5 — M12.** Repair tested-universe loading; remove the KEGG fix from the active chain; align the ranking model with D02; rerun mapping, ranked tests, sensitivity, ORA, integration, and then M12B.
6. **Phase 6 — Downstream rebuild.** Rebuild ML intersection audits, candidate labels/models and ROC diagnostics, M14 presentation, affected integrated tables, affected panels of Figures 3–6, figure source data, control documents, and the final reproducibility audit.
7. **Pre-final provenance repair.** Repair P3's workbook identity/fail-fast behavior, restore or register the split generator, and resolve P2 reproducibility issues before claiming complete end-to-end rerun readiness.

## Rerun boundary

No rerun is needed for D03 or the raw D08 analysis unless a later upstream P1–P3 identity check demonstrates actual data drift. Required reruns are fixed-85 ML, strict nested, M09, M11, M12, and M12B. Required rebuilds without scientific refitting include M14's source-derived summary, ML intersection/integration artifacts, candidate diagnostic labels/models, affected figure panels/source data, and control/reproducibility documents.

## Figure impact

| Figure | Panel | Disposition |
|---|---|---|
| Fig3 | a, b, d | Rebuild after corrected ML integrated table; locked 85 IDs remain usable |
| Fig3 | c | Rebuild after corrected ML integration and M09 rerun |
| Fig4 | a–c | Keep provisionally; verify unchanged source identities during final assembly |
| Fig4 | d | Rebuild after M11 rerun |
| Fig5 | a | Rebuild from D08 source rather than hard-coded M14 values |
| Fig5 | b–d | Rebuild after fixed-85 and strict-nested ML reruns |
| Fig6 | a–d | Rebuild after M12 and M12B repair/rerun |
| Supplementary ML prioritization | all ML-derived panels | Rebuild after ML reruns |
| Candidate ROC PDFs/tables | all | Retain as exploratory only; relabel or rebuild after candidate provenance is repaired |

## Manuscript claim impact

Withdraw or defer claims about comparative XGBoost performance, EN-supported prioritization, Tier1/four-way consensus, strict-nested instability as a pure resampling result, M09 missingness robustness, M11 pure site robustness, pathway enrichment counts/themes, pathway-candidate integration, and final frozen/reproducible readiness. The locked 85-protein Discovery set and raw D08 hold-out replication findings may continue to be reported with their existing design limitations. Do not describe candidate ROC results as final validation evidence until the corrected candidate definitions are available.

## Freeze readiness

The repository is not safe to tag as analysis v2.1. Four confirmed P0 issues directly affect frozen ML/pathway results or their reproducibility, and the downstream artifacts have not yet been rebuilt. Freeze readiness remains `BLOCKED`, with selective analysis reopening required.
