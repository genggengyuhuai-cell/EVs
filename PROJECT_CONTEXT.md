# PROJECT_CONTEXT.md — analysis-v2.1 authoritative overview

This file is the top-level authoritative entry point for the current project state.
It supersedes the historical v1.0 / v2.0 long-form narrative that previously lived here.
For frozen analytical detail, read the protocol and module manifests listed below.

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
| Discovery-validation | D01–D10 | `descriptive/discovery_validation/code/D0*.py` |
| v2 abundance | M05–M11 | `descriptive/analysis_v2.0/code/V2_M0[5-11]_*.R` (Firth / KNN / corrected-interaction variants are canonical) |
| M12 pathway | M12 v2.1 | `M12_01_mapping.R -> M12_02_ranked_ora.R -> M12_02b_kegg_fix.R -> M12_03_integration.R` |
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
cameraPR (primary, competitive)        195 FDR-significant pathways
                                        GO BP 25; Reactome 170
ORA (complementary, one-sided Fisher)  23 pathways
                                        GO BP 3; Reactome 20
fgsea (sensitivity, ranked)             39 pathways
                                        GO BP 3; GO MF 8; GO CC 11; Reactome 17
KEGG                                   NOT_RUN (placeholder CSVs only)
Mapping universe:
  tested protein groups                1434
  unambiguous one-gene mappings        1414
  multi-gene ambiguous                 15
  unmapped                              5
```

Do NOT add 195 + 23 + 39 and call it a single pathway count. The three methods answer
different questions; they are primary / complementary / sensitivity.

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

## 9. Remaining tasks (not started)

- Final reproducibility audit.
- analysis-v2.1 freeze tag.
- Manuscript assembly: captions, tables, methods prose, TIFF export.
- Nature-style writing / polishing / ref-verifier / reviewer simulation / pre-submission review.

All M01–M17 statistical analysis is frozen. Do not rerun, retune, or reopen unless a
verified bug is found.

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
