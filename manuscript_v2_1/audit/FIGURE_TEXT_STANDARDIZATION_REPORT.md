# Figure Text Standardization Report

## Files scanned

- Scanned 110 repository files with extensions `.R`, `.Rmd`, or `.py`.
- Identified 25 figure-generating or figure-support scripts for focused review.
- Classified `descriptive/analysis_v2.0/code/V2_M17_figures_v2.R` and `descriptive/discovery_validation/code/figures_prospective_v2.7.R` as active manuscript-facing pipelines.
- The pre-repair audit is recorded in `FIGURE_TEXT_AUDIT.csv`.

## Active figure scripts modified

- `descriptive/analysis_v2.0/code/V2_M17_figures_v2.R`
- `descriptive/discovery_validation/code/figures_prospective_v2.7.R`
- Added the display-only helper `descriptive/figure_display_labels.R`.

Only labels, display variables, plot margins, and export devices were changed. Statistical keys used by filters, joins, model outputs, and frozen result contracts were retained unchanged.

## Figures regenerated

- Regenerated M17 Figures 1-6 in `descriptive/analysis_v2.0/figures_final_v2`.
- Regenerated prospective Figures 1-15 in `descriptive/discovery_validation/figures_prospective_v2.7`.
- Prospective figures now include PDF, SVG, 300 dpi PNG, 600 dpi TIFF, and source-data CSV outputs.

## Terminology replacements

- `高压` -> `High land`
- `High-pressure` -> `High land`
- `湿热` -> `Hot-humid`
- `High-altitude` and `high-altitude` display labels -> `High land`
- `Humid-hot` and `humid-hot` display labels -> `Hot-humid`
- Figure-facing `Validation` terminology -> `Reused hold-out`
- `Dose-defined` -> `Exposure-defined`
- `Descriptive dose architecture` -> `Descriptive exposure architecture`
- Replication wording remains 83 direction concordant, 29 nominally replicated, and 1 FDR-supported.
- No protein-level `DEG` misuse was present in the active manuscript figures.

## Historical files intentionally left unchanged

- Chinese text was found in 14 historical, archived, or non-mainline files: 153 lines and 3,677 Han characters in total.
- Sixteen case-insensitive `High-pressure` occurrences were found repository-wide before repair. Fifteen are in frozen, historical, or internal analysis code. The remaining active occurrence is the exact internal value `High-pressure/high-altitude` required to match finalized D05 data.
- These findings are marked `NO_ACTION_ARCHIVE` or `INTERNAL_VALUE_NO_CHANGE` in the audit. No frozen analysis key was renamed.

## Font/export changes

- Active figures use Arial.
- PDF export uses `grDevices::cairo_pdf`.
- PNG export uses `ragg::agg_png`; the prospective pipeline retains its existing 600 dpi LZW TIFF export.
- PDF resource inspection confirmed embedded Arial fonts. `SymbolMT` is used only for mathematical symbols.

## Verification results

- All modified R files parsed successfully.
- All 21 figures regenerated successfully after one display-only ggplot2 compatibility repair for a discrete annotation coordinate in Figure 8.
- All 15 prospective source-data tables retained identical row counts and identical values in every numeric column shared with the pre-repair outputs.
- Text extracted from all 21 regenerated PDFs contained no Chinese characters, `High-pressure`, `High-altitude`, `Humid-hot`, or manuscript-facing `Validation` labels.
- PNG and rendered-PDF visual checks found no missing glyphs, square boxes, clipped labels, overlapping labels, broken legends, or incorrect wrapping after margin repairs to Figures 10 and 14.
- No statistical model, threshold, FDR definition, sample split, DEP result, ML result, pathway result, environment/site analysis, or numerical result was changed.

## Remaining issues

- The active prospective script still contains the internal source value `High-pressure/high-altitude` in a D05 filter. This is intentional and is never shown in manuscript output; changing it would break matching to frozen finalized results.
- Historical and archived figures were audited but not regenerated or repaired.
