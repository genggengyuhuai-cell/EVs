# Code Maintenance v2.3

Date: 2026-09-24

This round repaired active source code only. **NO ANALYSIS WAS EXECUTED.**

## Repairs

- Removed the deprecated continuous `control=0`, `low=1`, `high=2` exposure-trend implementation from `05_limma_dose_analysis.R`; categorical contrasts and limma mean-variance `eBayes(trend = TRUE)` remain unchanged.
- Updated `run_all.py` to validate the explicit current upstream figure and source-data filenames.
- Removed the hard Arial dependency from `v21_common.R` and the `05_limma_dose_analysis.R` plotSA diagnostic in favour of generic `sans`.
- Made `09_DEP_characterization.R`, `DEP_effect_size_summary.R`, and `10_protein_clustering.R` resolve paths from their script locations, with `getwd()` only as an interactive fallback.
- Added strict clustering protein/sample ID and metadata-alignment checks while retaining clustering-only `NA -> 0`.
- Made effect-size threshold flags NA safe without changing FDR or fold-change thresholds.
- Standardized acquisition-date factor levels across sample diagnostics, PCA, UMAP, heatmap annotation, and `RUN_PALETTE`.
- Added `run_full_upstream.py` and `run_active_r.R` as explicit-whitelist future runners. `run_all.py` remains the canonical descriptive plus quantitative-filtering upstream entry point.

## Safe reruns

No runner deletes outputs. `v21_output()` continues to reject non-empty output
directories. For a future rerun, use new empty destinations or manually archive
only the exact reproducible output directories after review. Never broadly
delete directories, and never clean raw data, mapping files, frozen inputs,
curated metadata, archived scripts, or project-control files.

## Pending validation

Runtime validation remains pending. Manually run the Python upstream sequence,
then the approved R whitelist, inspect logs and generated outputs, and resolve
any runtime errors before treating the pipeline as validated. This maintenance
round produced no new scientific results.
