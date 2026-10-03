# Project Logic Audit — 2026-09-28

Repository: `F:/env`. Read-only logical audit + conservative archival.
No model was rerun, no P/FDR recalculated, no frozen output or raw data modified.

## 1. Current scientific mainline

The project studies whether target exposure is associated with the plasma
proteome in 515 independent participants. The authoritative hierarchy is:

1. **Study / cohort / QC** — 3,817 raw protein groups, 519 raw samples, 515
   dose-defined participants; no repeats; Environment nested within Site
   (Humid-hot: FJ_FQ/FJ_PT/FJ_QZ/GZ_TH; High-altitude: XZ_GG/XZ_YA/XZ_YB/
   XZ_YC/XZ_YD).
2. **Ordered exposure architecture** — Control < Low exposure < High exposure
   (no equal spacing; not duration). Short/Long are legacy code identifiers only.
3. **Abundance as the primary inference axis** — log2, no imputation, NA retained,
   ≥70% detection per exposure group eligibility.
4. **Detection as a separate evidence axis** — never conflated with abundance.
5. **Environment / Site as secondary and robustness** — Environment-specific
   results are stratified estimates, not proof of interaction; Site is
   leave-one-out robustness, not proof of geographic biology.
6. **Historical full-cohort branch (reference only)** — 515 → 1,434 eligible →
   256 DEP (Long-vs-Short), Stage 11a/11b, Stage 13A master. CLOSED.
7. **Frozen Discovery–Validation branch (current supportive evidence)** —
   deterministic 75/25 split (386 Discovery / 129 reused hold-out) → 1,445
   Discovery-eligible → 85 locked BH-FDR candidates → D04–D10 characterization.
   Replication hierarchy: 85 locked / 85 estimable / 83 same-direction /
   29 nominal / 1 FDR-supported (GOLGA3). The reused 129 is NOT external
   validation.
8. **Future v2 whole-proteome branch (NOT STARTED)** — `analysis_v2.0/` defines
   D515/Q515 universes and an Elastic-Net panel spec, but full-cohort v2
   abundance inference is NOT STARTED and V2-05 results are NOT CURRENTLY VALID.

## 2. Historical branch (preserved, not mainline)

- `descriptive/limma_dose_analysis/` + Stages 01–12 + Stage 13A: frozen v1.0
  pipeline producing the 256-DEP reference. FROZEN_HISTORICAL.
- `descriptive/missingness_robustness/`: post-freeze D0–D3 sensitivity. COMPLETED.
- `descriptive/figures_nature_v2.2/`: v1.0 descriptive figure bundle.
- `docs/archive/legacy_framework_v2.0/`, `maintenance_logs/`, `early_plans/`.

## 3. Frozen Discovery–Validation branch

- `descriptive/discovery_validation_split/`: deterministic split (frozen SHA-256).
- `descriptive/discovery_validation/D01_…`–`D10_…`: frozen results.
- `descriptive/discovery_validation/code/dv_shared.R` + D02–D10 scripts.
- `figures_prospective_v2.6/`: frozen scientific/visual baseline.
- `figures_prospective_v2.7/`: current publication visual authority.

## 4. Current v2 analysis branch

- `descriptive/analysis_v2.0/`: future whole-proteome + ML. Universes frozen
  (D515=3,054, Q515=1,430); V2-04 ready; V2-05 NOT CURRENTLY VALID; full v2
  abundance NOT STARTED. This is future work, not current mainline.

## 5. Current figure hierarchy

| Bundle | Role |
|---|---|
| `discovery_validation/figures_prospective_v2.7/` | **Current publication visual authority** (15 groups, PDF/SVG/600-dpi TIFF/source CSV). |
| `discovery_validation/figures_prospective_v2.6/` | **Frozen scientific/visual baseline** (preserved; not to be overwritten). |
| `limma_dose_analysis/figures_final/` | Historical v1.0 figure outputs. |
| `figures_nature_v2.2/` | Historical v1.0 descriptive QC figure bundle. |
| `archive/figures_render_history/figures_prospective_v1,v2.3,v2.4,v2.5` | Superseded render-only iterations (moved this audit). |

## 6. Legacy logic that caused confusion (and how it is now contained)

| Legacy logic | Why no longer authoritative | Current replacement |
|---|---|---|
| Starting from the historical 256 DEP and generalizing | 256 is a closed full-cohort reference, not the new candidate set | D03 locks 85 Discovery-only candidates; historical 256 is reference only |
| Short_peak / Long_suppression from selected DEP as whole-proteome biology | Stage 11a acts on the 256-DEP universe, not the proteome | D04 trajectory classes act only on the 85 locked candidates |
| High-vs-Long as "the entire biological question" | Ordered exposure is Control<Low<High; the primary contrast is High vs Low | Display language is Low/High exposure; Short/Long are code IDs only |
| Candidate-only Environment analyses read as whole-proteome Environment biology | D05 is on the 85-candidate family | D05 labeled "candidate family"; D06 formal interaction = 0/85 FDR |
| "Significant in one Environment, not the other" read as interaction | D05 counts are stratified estimates | D06 explicitly reports 0/85 FDR-supported interaction |
| Acquisition date as confirmed MS batch | Samples were searched together | Date = processing/timing proxy, explicitly NOT a confirmed batch |
| Arbitrary comparator thresholds for detection specificity | Detection-specificity rule needs a frozen comparator | D09 reports 50/60/70/80% grid descriptively |
| Reused 129 called "external validation" | Same cohort, deterministic split | Always called "reused 129 hold-out" |
| Peptide evidence implied | No approved peptide source | SOURCE_NOT_AVAILABLE rendered explicitly, not a negative result |
| Pathway results implied | No approved mapping | NOT_RUN_NO_APPROVED_MAPPING |
| ROC/biomarker interpretation | V2-05 not currently valid | No ML biomarker claim in v2.7 figures |
| "1/85 FDR-supported" protein over-promoted | It is 1 of 85, weak single-protein replication | FIG1/FIG5/FIG10 present it at family level, not hero shot |

## 7. File classification table (counts)

| Category | Count | Examples |
|---|---|---|
| A. CURRENT_MAINLINE | 2 | `figures_prospective_v2.7.R`, `figures_prospective_v2.7/` |
| B. CURRENT_SUPPORTIVE | ~12 | D02–D10 scripts, D01–D10 result dirs, `figures_prospective_v2.6/`, v2.7 docs |
| C. FROZEN_HISTORICAL | ~25 | Stages 01–13A, run_all.py, limma_dose_analysis/, figures_nature_v2.2/, missingness_robustness/, root `execute_discovery_validation_split.R` |
| D. FROZEN_PROSPECTIVE | 12 | D01–D10 dirs, discovery_validation_split/, `dv_shared.R`, D03 lock CSV |
| E. REUSABLE_INFRASTRUCTURE | 4 | `nature_plotting.py`, `v21_common.R`, `stage05_*_helper.py`, `dv_shared.R` |
| F. SUPERSEDED | 0 (no analytic script superseded without keeping frozen) | — |
| G. DUPLICATE | 0 | — |
| H. OFF_MAINLINE | 3 | `code/P1.py`,`P2.py`,`P3.py` (one-off sample-mapping audits, already consumed; left in place, not moved) |
| I. TEMPORARY_DIAGNOSTIC | 7 moved | t1/t2/t3/tb.txt, v2_05u_FINAL.log, "tatus --short", git.txt |
| J. UNKNOWN_REVIEW_REQUIRED | 0 | — |

Old figure render dirs (v1, v2.3, v2.4, v2.5) classified as render-history
superseded visual design → moved to `archive/figures_render_history/`.

## 8. Files archived this audit (moved, not deleted)

```
descriptive/discovery_validation/figures_prospective_v1   -> descriptive/archive/figures_render_history/figures_prospective_v1
descriptive/discovery_validation/figures_prospective_v2.3  -> descriptive/archive/figures_render_history/figures_prospective_v2.3
descriptive/discovery_validation/figures_prospective_v2.4 -> descriptive/archive/figures_render_history/figures_prospective_v2.4
descriptive/discovery_validation/figures_prospective_v2.5  -> descriptive/archive/figures_render_history/figures_prospective_v2.5

t1.txt            -> descriptive/archive/diagnostics/t1.txt
t2.txt            -> descriptive/archive/diagnostics/t2.txt
t3.txt            -> descriptive/archive/diagnostics/t3.txt
tb.txt            -> descriptive/archive/diagnostics/tb.txt
v2_05u_FINAL.log  -> descriptive/archive/diagnostics/v2_05u_FINAL.log
"tatus --short"   -> descriptive/archive/diagnostics/git_status_short_snapshot.txt
git.txt           -> descriptive/archive/diagnostics/git_push_scratch_note.txt
```

## 9. Retained despite looking old (and why)

- `figures_prospective_v2.6/` — frozen scientific/visual baseline; preserved by mandate.
- `limma_dose_analysis/` and Stages 01–13A — closed historical reference; must stay intact for provenance.
- `figures_nature_v2.2/` — historical v1.0 descriptive figures.
- `analysis_v2.0/` — future v2 universes/ML spec; V2-05 invalidated results already self-marked in `ml/invalidated/`.
- `code/P1–P3.py` — one-off sample-mapping audits; not on any active runner path; left in place rather than risk breaking a forgotten handoff.
- root `execute_discovery_validation_split.R` — provenance of the frozen split.

## 10. Broken / redundant workflow references

- No active runner (`run_all.py`, `run_discovery_validation_pipeline.py`) references
  the moved render dirs or root scratch files.
- `docs/README.md` hierarchy already points to `docs/protocol/` as authority; no
  path update needed.
- The pre-existing modification to `code/figures_prospective.R` (+1306/−57,
  adding `_source_data.csv` export) was made during v2.6 figure production and
  is retained; it does not change scientific content.

## 11. Recommended canonical reading order

1. `PROJECT_CONTEXT.md` → current authority.
2. `docs/protocol/ANALYSIS_PLAN_v2.0.md` + `STUDY_DESIGN_AUDIT.md` → what v2 should be.
3. `descriptive/discovery_validation/README.md`, `PIPELINE_STATUS.md`, `WORKFLOW.md` → D01–D10 branch.
4. `descriptive/discovery_validation/figures_prospective_v2.7/` → current figures.
5. `descriptive/limma_dose_analysis/` + Stage 13A → historical reference.
6. `descriptive/analysis_v2.0/` → future v2/ML (not yet executed).
7. `docs/archive/` → historical only; never as current authority.
