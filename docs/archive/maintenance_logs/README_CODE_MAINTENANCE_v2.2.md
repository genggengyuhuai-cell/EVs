# README — Code Maintenance v2.2

Date: 2026-09-23  
Status: CLOSED / COMPLETE

## Purpose and scope

This maintenance round completed a static Nature-style figure, naming, and consistency cleanup for the active plotting code. It was code and documentation maintenance only: no scientific workflow was rerun and no new analysis module was introduced.

The work focused on existing figures, shared export helpers, display terminology, and traceable figure/source-data pairing. It did not redesign the analytical architecture.

## Files reviewed or updated

### Shared helpers and descriptive Python outputs

- `nature_plotting.py`: confirmed the shared single-figure theme and PDF/SVG/600 dpi PNG export contract; batch saving now accepts matching source data for each independent figure.
- `v21_common.R`: reviewed without further code change; shared R exposure labels, restrained theme, independent-figure export, and `_source.csv` pairing remain consistent.
- `describe_proteomics.py`: standardized independent descriptive output names to `Figure_01_` and `Figure_02_`; added explicit source-data pairing for batch-saved figures and removed legacy panel-letter descriptions.
- `detection_gradient.py`: standardized independent detection-gradient output names to `Figure_03_`; retained matching source-data exports and clarified group/environment titles.
- `design_composition.py`: standardized independent composition output names to `Figure_04_`; display text now uses the current exposure terminology and acquisition-date proxy wording.

### Active R figure modules

- `06b_limma_robustness.R` and `06c_run_replication.R`: formal figure and source-data naming standardized; remaining legacy B1/B2/B3 or C1/C2 section comments are cosmetic only.
- `06d_integrated_results.R`: reviewed and standardized independent MA, effect-rank, forest, single-protein profile, abundance × detection, outside-core, and evidence-count outputs under `Figure_06d_` names.
- `04_covariate_QC.R`: reviewed independent completeness, raw-token, missingness, numeric-distribution, categorical-balance, and QC-association outputs; formal names use `Figure_04_covariate_QC_`.
- `08_detection_pattern_analysis.R`: reviewed independent model-status, effect/CI, and acquisition-date sensitivity outputs; formal names use `Figure_08_detection_`.
- `DEP_effect_size_summary.R`: reviewed independent threshold-count and all-tested-protein log2FC-distribution outputs; formal names use `Figure_DEP_effect_size_summary_`.
- `09_DEP_characterization.R`: reviewed independent direction-count and two top-DEP outputs; formal names use `Figure_09_DEP_characterization_`.
- `10_protein_clustering.R`: reviewed independent all-DEP and top-50 heatmaps, hierarchical cluster summaries, and exploratory K-means sensitivity outputs; formal names use `Figure_10_protein_clustering_`.

## Figure and terminology conventions applied

- One figure is saved as one independent output unless tightly linked panels are required by one question.
- Formal filenames use descriptive `Figure_...` prefixes, and each source-data export uses the same stem plus `_source.csv`.
- Shared plotting helpers provide editable PDF/SVG output and a 600 dpi PNG preview with consistent typography and restrained styling.
- Display terminology uses `Control`, `Short exposure`, and `Long exposure`; historical internal keys remain only for compatibility where needed.
- Acquisition date is described as an acquisition-date, MS run-date, or run-date proxy/sensitivity variable. It is not described as a confirmed technical batch.
- Detection and quantitative abundance figures retain their separate evidence meanings. Detection-model failure, separation, and non-estimability remain explicit where applicable.

## Analytical decisions retained

This maintenance round did not change:

- the primary abundance model, contrasts, FDR threshold, DEP definition, or effect-size thresholds;
- detection thresholds, logistic models, robustness definitions, or the distinction between detection and abundance analysis;
- primary missing-value handling: limma retains NA and does not set missing abundance to zero;
- clustering-specific preprocessing: NA -> 0 remains limited to the explicitly defined exploratory clustering visualization, with protein-wise z-scores, hierarchical clustering, and K-means sensitivity settings unchanged;
- covariate-QC definitions or the distinction among literal `0`, `Unknown`, `NA`, and missing values.

## Execution and file-status record

- No R or Python script, model, analysis, figure generation, or pipeline was run in this maintenance round.
- No raw data were modified.
- No deprecated or HOLD file was re-enabled, moved, or incorporated into the active workflow.
- No scientific design change occurred; therefore `PROJECT_CONTEXT.md` and `FILE_STATUS.md` were not revised for this round.

## Final consistency conclusion

The reviewed figure/helper scope is internally consistent for independent output, display terminology, export formats, filenames, and source-data pairing. This v2.2 maintenance cleanup is formally closed.

`06a_limma_core_figures.R` remains `PARTIAL / REVIEW` in the live breakpoint table and was not reopened or represented here as completed.
