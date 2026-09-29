# M17 Finalization Report

Scope: `descriptive/analysis_v2.0/M17_probe.R`, `descriptive/analysis_v2.0/code/V2_M17_figures_v2.R`, `descriptive/analysis_v2.0/figures_final_v2/`.

## 1. Authoritative M17 script

- `descriptive/analysis_v2.0/code/V2_M17_figures_v2.R` (29,934 bytes) is the sole authoritative figure-assembly script.
- It `source()`s the already-tracked display-label helper `descriptive/figure_display_labels.R` (which maps internal keys `High-pressure/high-altitude` → **High land**, `Humid-hot` → **Hot-humid**, `Validation` → **Reused hold-out**).
- It reads only frozen result tables: M05 overall exposure, M06 adjusted means + architecture class, M07 three pairwise contrasts, M08 Firth detection, M09 KNN sensitivity, M10 pure interaction, M11 site composition + LOO, M14 replication hierarchy, `ml_v2.1/results/integrated_table_85.csv`, `ml_v2.1/results/outer_cv_metrics.csv`, `ml_v2.1/strict_nested/strict_nested_outer_metrics.csv`, and M12 ranked / cameraPR-fgsea concordance / ORA combined FDR / candidate pathway membership.
- No model is refit; no FDR is recomputed; no candidate is re-selected.
- Export: `svglite::svglite` (SVG) + `grDevices::cairo_pdf` (PDF) + `ragg::agg_png` (300 dpi QA preview only), all at 183 mm width.
- No random seed is set (rendering-only, no stochastic step).

## 2. Figure 1–6 status matrix

| Figure | Output (PDF/SVG) | Source data | Traceable | Terminology OK | Visual QC | Status |
|---|---|---|---|---|---|---|
| Fig 1 cohort_design | yes / yes | yes (50 rows) | yes (519→515→386/129; 153/186/176; site; protein gates 3817/3054/1430/1445/85) | yes | no clipping per VISUAL_QC | PASS |
| Fig 2 proteome_associations | yes / yes | yes (6462 rows) | yes (1430 proteins; pairwise 3×1430; detection 3054; architecture sums to 1430) | yes | PASS | PASS |
| Fig 3 candidate_biology | yes / yes | yes (428 rows; 85 unique candidates) | yes (85 locked; 255 profile rows = 85×3) | yes | PASS | PASS |
| Fig 4 environment_site | yes / yes | yes (2891 rows) | yes (1430 env/LOO; interaction bins sum to 1430; site = 515) | yes | PASS | PASS |
| Fig 5 replication_ml | yes / yes | yes (409 rows; hierarchy 85/85/83/29/1 confirmed) | yes (fixed-85 conditional vs strict nested branches shown separately; no composite score) | yes | PASS | PASS |
| Fig 6 pathway_integration | yes / yes | yes (909 rows; 8 ranked GO-BP + 3 ORA GO-BP + network edges) | yes (cameraPR primary; fgsea sensitivity; ORA complementary; KEGG not plotted) | yes | PASS | PASS |

## 3. Source-data status

All six `*_source_data.csv` files exist and are row-linked to panels via a `panel` column. No display-driven re-ranking, no manuscript-only value, no hidden re-selection. Row counts match VISUAL_QC.md assertions.

## 4. Table status

NOT_PRESENT_YET. No Table 1–4, no supplementary tables, no tabular output files exist under `figures_final_v2/` or elsewhere in M17 scope. Not fabricated per instructions.

## 5. Caption status

NOT_PRESENT_YET. No caption text files exist. FIGURE_MANIFEST.md carries panel definitions and reading order but not printable captions.

## 6. Methods / reporting status

Partial. FIGURE_MANIFEST.md and VISUAL_QC.md provide export contract, panel definitions, statistical scope and QA record. A standalone methods prose paragraph for the manuscript is NOT_PRESENT_YET.

## 7. Terminology audit

- Display layer uses authoritative terms: **High land**, **Hot-humid**, **Discovery**, **reused hold-out**, **DEP/DEPs** (via `display_environment()` / `display_split()`).
- Internal keys `Humid-hot`, `High-pressure/high-altitude` appear only as arguments to the label helper and never reach the plot.
- One negation note in `Fig5_replication_ml_source_data.csv` (`terminology_note = "reused within-cohort hold-out; NOT external validation"`) contains the string "external validation" only as an explicit disclaimer; it is not plotted and does not reintroduce the deprecated term as a positive claim. No other deprecated display strings found in script, manifests, or source CSVs.
- No Chinese characters in plotted output (Chinese strings exist only as internal map keys in `figure_display_labels.R`).

## 8. Visual QA

Per VISUAL_QC.md: static preflight 17 PASS / 0 FAIL / 3 WARN. Warnings are expected (no TIFF requested; PNG is QA preview not submission raster; Cairo 1-pt Tf transform encoding artifact). No clipping, no truncated legends, no broken panel letters, no unreadably small text reported. No layout change needed in this audit.

## 9. Reproducibility

- Paths: constructed via `normalizePath(getwd())` + `file.path`; repo-relative. No `F:\`, `C:\`, `Users\`, `Desktop`, `Downloads`, `temp`, `tmp`, `setwd()` found in the script.
- Dependencies: ggplot2, patchwork, dplyr, tidyr, ggrepel, scales, svglite, cairo_pdf (grDevices), ragg.
- Inputs consumed are all frozen result tables already staged or planned for mainline (M05–M14, ml_v2.1, M12). No dependency on `M17_probe.R`, on archive, on hidden/manually edited files, on Desktop/temp.
- No seed required (rendering only).

## 10. Probe / debug classification

- `M17_probe.R`: DEBUG_ONLY / ARCHIVE_CANDIDATE / DO_NOT_TRACK. 4-line package availability check. Not sourced, no output, no hard-coded path. Left untracked; not deleted.

## 11. Remaining missing manuscript components (NOT_PRESENT_YET, not fabricated)

- Printable figure captions.
- Table 1–4 and supplementary tables.
- Standalone methods prose paragraph for figures.
- Submission-raster TIFF at journal resolution (manifest explicitly notes TIFF not requested).

## 12. Recommended Git files (whitelist)

Stage only:
- `descriptive/analysis_v2.0/code/V2_M17_figures_v2.R`
- `descriptive/analysis_v2.0/figures_final_v2/Fig{1..6}_*.pdf` (6)
- `descriptive/analysis_v2.0/figures_final_v2/Fig{1..6}_*.svg` (6)
- `descriptive/analysis_v2.0/figures_final_v2/Fig{1..6}_*_source_data.csv` (6)
- `descriptive/analysis_v2.0/figures_final_v2/FIGURE_MANIFEST.md`
- `descriptive/analysis_v2.0/figures_final_v2/VISUAL_QC.md`
- `descriptive/analysis_v2.0/M17_FILE_AUDIT.csv`
- `descriptive/analysis_v2.0/M17_FINALIZATION_REPORT.md`

Do NOT stage: `M17_probe.R`, the six `*_preview.png` QA previews.

## 13. Archive candidates (untracked, intentionally not staged)

- `descriptive/analysis_v2.0/M17_probe.R` (DEBUG_ONLY).

## 14. Blocking issues

None.

## Final M17 status

**PASS_WITH_LIMITATIONS** — figures, source data, manifests and QA record are complete and traceable; limitations are: (a) captions / Table 1–4 / methods prose / submission TIFF are NOT_PRESENT_YET and were not fabricated; (b) PNG previews are QA-only and excluded from mainline; (c) one disclaimer note in Fig5 source data contains the string "external validation" in a negation only.
