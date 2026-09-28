# MASTER PROJECT STATUS — 2026-09-28

This is the authoritative current-state file after the 2026-09-28 project-logic
audit and conservative archival. It supersedes scattered status notes.

## 1. Repository state

```
F:/env/
├── PROJECT_CONTEXT.md                       HIGHEST AUTHORITY
├── .gitignore
├── .nature-figure.json                       local figure backend config (r)
├── execute_discovery_validation_split.R     FROZEN_HISTORICAL split executor
├── rawdata/                                 READ-ONLY (processed.xlsx, sample_mapping_FINAL.xlsx)
├── code/P1.py P2.py P3.py                   FROZEN sample-mapping provenance (REUSE AS-IS; do NOT move)
├── docs/
│   ├── protocol/   ANALYSIS_PLAN_v2.0 (authoritative), STUDY_DESIGN_AUDIT,
│   │               DISCOVERY_VALIDATION_PROTOCOL, SPLIT_SPEC, V2_IMPLEMENTATION_GAP_AUDIT
│   ├── workflow/   CODEX_WORKFLOW, FILE_STATUS, MASTER_BACKLOG,
│   │               PROJECT_LOGIC_AUDIT_2026-09-28, MASTER_PROJECT_STATUS_2026-09-28 (this file)
│   ├── task/TASK_CURRENT.md
│   └── archive/    historical only
└── descriptive/
    ├── 01..13a stages + run_all.py           FROZEN v1.0 pipeline
    ├── limma_dose_analysis/                  FROZEN_HISTORICAL (1434 -> 256, Stage 13A)
    ├── figures_nature_v2.2/                 FROZEN_HISTORICAL descriptive figures
    ├── missingness_robustness/              FROZEN post-freeze D0-D3
    ├── discovery_validation_split/          FROZEN deterministic 386/129 split
    ├── discovery_validation/
    │   ├── D01..D10/                        FROZEN_PROSPECTIVE results
    │   ├── code/dv_shared.R, D02..D10       FROZEN_PROSPECTIVE scripts
    │   ├── code/figures_prospective.R       v2.6 plotter (frozen baseline)
    │   ├── code/figures_prospective_v2.7.R  CURRENT publication plotter
    │   ├── figures_prospective_v2.6/        FROZEN visual baseline (61 files)
    │   └── figures_prospective_v2.7/        CURRENT publication visual authority (64 files)
    ├── analysis_v2.0/                       FUTURE v2 (M01-M04 partially complete; M05+ next)
    └── archive/
        ├── figures_render_history/          v1, v2.3, v2.4, v2.5 (render-only, moved)
        └── diagnostics/                      root scratch logs (moved)
```

## 2. Archive locations (this phase)

| From | To |
|---|---|
| descriptive/discovery_validation/figures_prospective_v1 | descriptive/archive/figures_render_history/figures_prospective_v1 |
| descriptive/discovery_validation/figures_prospective_v2.3 | descriptive/archive/figures_render_history/figures_prospective_v2.3 |
| descriptive/discovery_validation/figures_prospective_v2.4 | descriptive/archive/figures_render_history/figures_prospective_v2.4 |
| descriptive/discovery_validation/figures_prospective_v2.5 | descriptive/archive/figures_render_history/figures_prospective_v2.5 |
| t1.txt t2.txt t3.txt tb.txt | descriptive/archive/diagnostics/ |
| v2_05u_FINAL.log | descriptive/archive/diagnostics/ |
| "tatus --short" | descriptive/archive/diagnostics/git_status_short_snapshot.txt |
| git.txt | descriptive/archive/diagnostics/git_push_scratch_note.txt |

NOT archived (correction from prior audit): `code/P1.py P2.py P3.py` are the
frozen sample-mapping provenance scripts ("REUSE AS-IS"); they produce
`sample_mapping_FINAL.xlsx` and are protected.

## 3. Module status (v2 implementation)

States: CODE_COMPLETE | EXECUTION_COMPLETE | AUDIT_PASS | FROZEN | NOT_STARTED.

| Module | Description | State |
|---|---|---|
| M01 | Metadata / provenance | FROZEN (in analysis_v2.0/registry) |
| M02 | Contaminant registry | FROZEN (Freeze 3) |
| M03 | Canonical universes D515/Q515/Utech | FROZEN (V2-02) |
| M04 | Universe QC | AUDIT_PASS (V2_02_QA) |
| M05 | Overall Exposure vs Control | **NEXT — CODE_IN_PROGRESS** |
| M06 | Control/Low/High ordered + omnibus | NOT_STARTED |
| M07 | LC/HC/HL pairwise contrasts | NOT_STARTED |
| M08 | Detection / Unique proteins | NOT_STARTED |
| M09 | Missingness sensitivity | NOT_STARTED |
| M10 | Environment + formal interaction | NOT_STARTED |
| M11 | Site + robustness / heterogeneity | NOT_STARTED |
| M12 | Pathway / enrichment | NOT_STARTED |
| M13 | Historical 256 reconciliation | NOT_STARTED (read-only reuse) |
| M14 | Frozen 85->129 reconciliation | NOT_STARTED (read-only reuse) |
| M15 | Discovery-only ML biomarker | NOT_STARTED (model lock = stop gate) |
| M16 | Reused-129 hold-out evaluation | NOT_STARTED / NOT AUTHORIZED |

## 4. Hard stop gates

- M15 model lock is the end of this phase.
- M16 requires separate explicit investigator authorization.
- No v2 module may use the 129 hold-out for feature selection, hyperparameter
  choice, panel-size choice, threshold tuning, recalibration, or model ranking.
- No frozen historical script or result may be modified.
- D03 remains exactly 85; v2.7 figures remain untouched.

## 5. Verification (this phase)

- D03 = 85 rows / 85 unique (R-verified).
- v2.7 = 64 files present; v2.6 = 61 files present.
- No active runner references moved paths.
- Git diff = file moves + documentation only.

## M05 execution note (2026-09-28)

- Code: descriptive/analysis_v2.0/code/V2_M05_overall_exposure.R
- Output: analysis_v2.0/M05_overall_exposure/M05_overall_exposure_AE_results.csv + M05_manifest.csv
- Design: ~0+Group+Environment; E = (186/362)*mu_L + (176/362)*mu_H - mu_C
- fit: limma lmFit + eBayes(trend=TRUE, robust=TRUE); exact contrastAsCoef refit
- Universe: Q515 = 1430 proteins; 515 samples (153/186/176)
- Result: 0/1430 proteins A-E BH-FDR < 0.05; 0 non-estimable
- State: CODE_COMPLETE / EXECUTION_COMPLETE / AUDIT_PASS
- M06-M15: NOT_STARTED (next sequential module)

### Reused-129 firewall scope (wording correction)

M05-M12 are prespecified full-cohort biological analyses using all 515
participants, which includes the 129 reused hold-out individuals. The
reused-129 firewall applies specifically to M15 Discovery-only ML development
and M16 once-only hold-out evaluation. It does NOT restrict M05-M12 full-cohort
biological analyses.

## M06 execution note (2026-09-28)

- Code: descriptive/analysis_v2.0/code/V2_M06_ordered_omnibus_architecture.R
- Output: analysis_v2.0/M06_ordered_omnibus_architecture/ (5 CSVs)
- Design: ~0+Group+Environment; contrasts a=Low-Control, b=High-Low via contrastAsCoef
- Omnibus: 2-df moderated F (a=0 AND b=0), BH family A-G across Q515
- Ordered: bidirectional IUT p_inc=max(p_a+,p_b+), p_dec=max(p_a-,p_b-),
  p_order=min(1,2*min(p_inc,p_dec)); BH family A-O across Q515
- Descriptive architecture: epsilon=0.05 log2, v2 rules over ALL 1430 proteins
- Result:
  * Omnibus A-G FDR<0.05: 172/1430
  * Ordered inc A-O FDR<0.05: 0
  * Ordered dec A-O FDR<0.05: 0
  * Architecture: High-sel dec 190, High-sel inc 39, Low-sel elev 199,
    Low-sel supp 32, Mono dec 135, Mono inc 177, Nonmono Low-peak 536,
    Nonmono Low-trough 23, Uncertain/other 99
- State: CODE_COMPLETE / EXECUTION_COMPLETE / AUDIT_PASS
- M07-M15: NOT_STARTED

## M07-M14 batch complete (2026-09-28)

| Module | Code | Exec | Audit | Key result |
|---|---|---|---|---|
| M07 pairwise | OK | OK | PASS | LC 13, HC 0, HL 257 FDR<0.05 |
| M08 detection | OK | OK | PASS | 3/3054 Group LR FDR<0.05 (2321 non-OK) |
| M09 sensitivity | OK | OK | PASS | corr E vs median-imputed=0.994; dir agree=98.7%; KNN unavailable |
| M10 environment | OK | OK | PASS | 1034/1430 interaction FDR<0.05; dir concordance 35.2% |
| M11 site | OK | OK | PASS | 9 sites; LOO dir consistent 33.3%; median max shift 0.16 log2 |
| M12 pathway | BLOCKED | n/a | n/a | No approved gene-set mapping contract; frozen D10 NOT_RUN |
| M13 historical | read-only | OK | PASS | universe reconciliation table written |
| M14 replication | read-only | OK | PASS | 85/85/83/29/1 hierarchy preserved |

Frozen branches untouched: v2.6=61, v2.7=64, D03=85.
M15 NOT auto-started. M16 NOT AUTHORIZED.

## M08/M09/M10 status corrections (2026-09-28)

- M08 = CURRENT_IN_PROGRESS / NOT_FROZEN. Reason: frozen protocol specifies Firth
  logistic (logistf); current run used standard logistic (logistf unavailable).
  Retained as diagnostic/sensitivity, NOT final M08 primary.
- M09 = AUDIT_PASS_WITH_INCOMPLETE_SENSITIVITY / NOT_FROZEN. Primary no-imputation
  analysis stands; KNN sensitivity unavailable (DMwR not installed). Median-imputation
  sensitivity complete.
- M10 = AUDIT_FAIL / NOT_FROZEN. Current joint test includes Environment main-effect
  coefficient; reported 1034/1430 must NOT be treated as formal Group x Environment
  interaction. Preserved as invalidated provenance; refit required later.
- M11 = AUDIT_PASS_WITH_LIMITATIONS.
- M12 = BLOCKED (no gene-set mapping).
- M13/M14 = FROZEN_COMPLETE (read-only).

## M15 Discovery-only ML complete (2026-09-28)

- Script: descriptive/analysis_v2.0/code/V2_M15_ml_discovery.R
- Population: 386 Discovery only (Control=115, Exposure=271)
- Strategy B primary (no global screen); 5 outer x 5 inner x 3 repeats
- Final locked model: alpha=0.50, k=20, 20 proteins
- Nested CV AUROC=0.559; Brier=0.256
- Result: weak discrimination; no stable small (3-10) panel selected;
  k=20 is the smallest supported panel in this implementation.
- 129 firewall: DISJOINT(Disc,Val) asserted; no Validation IDs loaded during training.
- M16 = READY_BUT_NOT_AUTHORIZED.

## M15 pre-holdout lock audit (2026-09-28)

Audit result: M15 = INCOMPLETE (not FROZEN_LOCKED).
- Strategy B OOF: AUROC=0.559 (bootstrap CI computed), AUPRC, Brier=0.256,
  calibration intercept/slope computed.
- 2000-rep stratified participant bootstrap executed.
- Null benchmark (fold-prevalence Brier) computed.
- 129 firewall: PASS (disjoint asserted; never loaded).

Outstanding gaps blocking FROZEN_LOCKED:
1. Strategy A (fold-local limma screen BH<0.10) NOT executed.
2. Exact frozen one-SE rule not implemented (used inner Brier proxy instead).
3. Manifest missing Discovery imputation medians, scaling means/SDs,
   package versions, input/code hashes, threshold/abstention policy.
4. Feature-selection frequency and coefficient-sign-consistency tables not saved.

Model is NOT changed. M16 = READY_BUT_NOT_AUTHORIZED.

## M15v2 repair complete (2026-09-28)

Old M15 run: INVALIDATED_PREAUDIT_RUN (preserved at ml/models/INVALIDATED_PREAUDIT_RUN.txt).
Corrected run: ml/m15v2/.
- Strategy B: AUROC=0.538 (95% CI 0.499-0.578), Brier=0.219 (CI 0.207-0.230),
  cal_int=0.05, cal_slope=1.15
- Strategy A: AUROC=0.499 (95% CI 0.473-0.527), Brier=0.212
- Inner selection: mean log loss + exact one-SE rule
- Final locked model: alpha=1.0 (LASSO), k=3, 3 proteins
  P58335 (+0.415), Q9Y566 (-0.334), Q8TC71 (-0.295)
- Reproduction max |p1-p2| = 2.22e-16 (PASS)
- 129 firewall: PASS (disjoint asserted; never loaded)

M15 = FROZEN_LOCKED. M16 = READY_BUT_NOT_AUTHORIZED.

## M16 once-only hold-out evaluation (2026-09-28)

- Script: descriptive/analysis_v2.0/code/V2_M16_holdout.R
- Model: locked M15v2 (alpha=1, k=3, P58335/Q9Y566/Q8TC71), no refit
- Hold-out: 129 (Control=38, Exposure=91); disjoint from Discovery=386
- Results:
  AUROC=0.665 (95% CI 0.533-0.792)
  AUPRC=0.788 (95% CI 0.688-0.896); prevalence baseline ~0.705
  Brier=0.199 (95% CI 0.167-0.233); null prevalence Brier=0.211
  Calibration intercept=-1.65 slope=3.76 (poorly calibrated/overconfident)
  @0.5 reference: sens=0.871 spec=0.296 bacc=0.584 PPV=0.740 NPV=0.500 F1=0.800
  Subgroup mean prob: Control=0.614 Low=0.714 High=0.694
- 2000 bootstrap, seed 20260930; no abstentions (0/129 missing)
- M15 unchanged. No recalibration. No threshold tuning.
- M16 = COMPLETE_ONCE_ONLY_EVALUATION.

## Calibration interpretation correction (2026-09-29)

M16 calibration: intercept=-1.65, slope=3.76.
Correct interpretation: calibration was poor. The negative calibration intercept
indicates systematic overprediction, while the slope substantially greater than 1
indicates insufficient dispersion of predicted probabilities. No recalibration was
performed. (Earlier "overconfident/extreme" wording was incorrect.)

## Final freeze (2026-09-29)

Repaired modules:
- M08 Firth primary: 2/3054 Group LR FDR<0.05 (logistf installed)
- M09 KNN sensitivity: corr(E,primary vs KNN)=0.931, spearman=0.913, dir agree=92.3%
- M10 corrected pure 2-df interaction: 0/1430 FDR<0.05 (old 1034 result invalidated)
- M12: still BLOCKED (no approved gene-set mapping contract)

Final status matrix:
M01-M07 FROZEN_COMPLETE
M08 FROZEN_COMPLETE (Firth primary)
M09 FROZEN_COMPLETE (Gaussian + KNN)
M10 FROZEN_COMPLETE (corrected pure interaction)
M11 FROZEN_COMPLETE_WITH_LIMITATIONS
M12 BLOCKED
M13-M14 HISTORICAL_FROZEN
M15 FROZEN_LOCKED
M16 COMPLETE_ONCE_ONLY_EVALUATION

Figures: descriptive/analysis_v2.0/figures_final_v1/ (Fig1-6 PDFs).
