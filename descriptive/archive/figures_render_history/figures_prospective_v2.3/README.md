# Discovery–Validation figures v2.3

## 1. Purpose

This directory contains the final expanded figure set for the prospective Discovery–Validation proteomics analysis.

The figures summarize finalized D01–D10 result tables only. The plotting workflow does not fit models, recalculate FDR values, change the candidate family, tune thresholds, impute missing values or inspect raw biological data.

The central conclusion is:

> The 85 locked Discovery candidates show strong family-level directional concordance in independent Validation, but weak protein-specific effect agreement and limited multiplicity-controlled single-protein replication. Their direction is robust to leave-one-major-site-out analysis, and candidate detection is generally high.

## 2. Authoritative inputs

The analytical results under the following directories are the figure sources:

```text
descriptive/discovery_validation/D01_discovery_eligibility/
descriptive/discovery_validation/D02_discovery_primary/
descriptive/discovery_validation/D03_candidate_lock/
descriptive/discovery_validation/D04_dose_trajectory/
descriptive/discovery_validation/D05_environment_specific/
descriptive/discovery_validation/D06_environment_interaction/
descriptive/discovery_validation/D07_site_robustness/
descriptive/discovery_validation/D08_validation/
descriptive/discovery_validation/D09_missingness_detection_peptides/
descriptive/discovery_validation/D10_integrated_biology/
descriptive/discovery_validation_split/discovery_validation_assignment.csv
```

The authoritative plotting script is:

```text
descriptive/discovery_validation/code/figures_prospective.R
```

Do not substitute historical full-cohort results, the historical 256-protein DEP set or any invalidated analysis-v2.0/ML output for these sources.

## 3. Figure inventory

| Figure | Main source | What it shows |
|---|---|---|
| FIG1 | Frozen split + D01 | Discovery/Validation sample composition and the analytical/evidence scope |
| FIG2 | D02 + D03 | Discovery Long-vs-Short signal across 1,445 tested proteins, with 85 candidates highlighted |
| FIG3 | D04 | Candidate dose trajectories expressed as modeled change from Control |
| FIG4 | D05 + D06 | Environment-specific effects and the separate formal Dose × Environment interaction test |
| FIG5 | D08 | Discovery–Validation effect agreement and the prespecified replication hierarchy |
| FIG6 | D10 | Integrated candidate evidence states without scoring or ranking |
| FIG7 | D07 | Leave-one-major-site-out effect shifts and direction robustness |
| FIG8 | D09 | Detection-rate distributions and threshold-retention behavior |

Each figure is delivered as:

- `.svg`: editable vector output;
- `.pdf`: embedded-font vector output;
- `.tiff`: 600 dpi LZW-compressed publication raster;
- `preview_png/*.png`: review preview, not the preferred submission format.

See `figure_manifest.csv` for the compact machine-readable inventory and `FIGURE_PLAN_AND_QA.md` for the full design and QA record.

## 4. Reproducing a figure

Required R packages:

```r
ggplot2
patchwork
ggrepel
svglite
ragg
scales
```

Run from any working directory by supplying a figure ID and a new output stem:

```powershell
Rscript F:/env/descriptive/discovery_validation/code/figures_prospective.R `
  FIG5 `
  F:/env/descriptive/discovery_validation/figures_prospective_next/FIG5_discovery_validation
```

Valid IDs are `FIG1` through `FIG8`.

The script intentionally refuses to overwrite an existing `.svg`, `.pdf` or `.tiff`. Use a new versioned output directory for a deliberate revision. Do not delete or replace v2.3 merely to test a cosmetic change.

## 5. Locked analytical facts

The following contracts are asserted by the figure code or were checked during delivery:

```text
Total participants = 515
Discovery participants = 386
Validation participants = 129
Discovery eligible proteins = 1,445
Locked candidates = 85
Direction concordant in Validation = 83/85
Nominal replication = 29/85
FDR-supported replication = 1/85
D06 Long-vs-Short interaction at secondary BH-FDR < 0.05 = 0/85
D07 direction-stable candidates across five LOO scenarios = 85/85
All-dose detection >=80% = 81/85
```

If a future source table changes any of these values, the corresponding assertion may stop figure generation. Do not weaken an assertion merely to make the script run. First determine whether the analytical authority, protocol or source schema legitimately changed.

## 6. Interpretation guardrails

- Do not write that all 85 candidates were validated.
- Distinguish direction concordance from nominal and FDR-supported replication.
- The two direction-discordant candidates are TNR and F11R. Their Validation effects are close to zero rather than strong opposite effects.
- GOLGA3 is the only candidate with FDR-supported replication in the locked family.
- Environment-specific significant counts from D05 are not proof of heterogeneity. The formal D06 interaction analysis found 0/85 FDR-supported Long-vs-Short interactions.
- Leave-one-site-out stability supports robustness to influential major sites; it does not prove absence of site heterogeneity.
- FIG3 subtracts each protein's modeled Control mean for display only. It does not change D04 classification or the underlying model estimates.
- FIG6 preserves the locked candidate order and does not create an evidence score or ranking.
- Unique-peptide support is not displayed because no approved source is available.
- Pathway results are not displayed because no approved mapping and universe were supplied.

## 7. Visual and export contract

```text
Backend: R only
Layout: quantitative evidence figures
Final size: approximately 183 × 120 mm
Base font: Arial
Minimum configured text size: 5.8 pt
Panel tags: lowercase bold, 8 pt
Raster resolution: 600 dpi
Background: white
Primary palette: restrained blue, rose, green and neutral grey
```

Figure-level titles, captions, statistical explanations and provenance are kept outside the image. They should be added in the manuscript or figure legend rather than baked into the plot.

## 8. QA status

Completed checks:

- R syntax parse passed;
- all eight figures rendered successfully in SVG, PDF and TIFF;
- final-size panel-by-panel visual inspection passed;
- no observed label or legend clipping in the final version;
- SVG text remained editable;
- PDF Arial fonts were embedded;
- TIFF files were RGB, 4322 × 2834 pixels and 600 dpi;
- frozen participant, candidate and Validation evidence counts were verified;
- no raw-data or frozen-result file was modified.

The PDF text scanner reports 1 pt `Tf` operators because R PDF devices encode final glyph size using transformation matrices that the scanner does not resolve. This is a tool limitation, not a rendered 1 pt font finding. The configured text sizes, editable SVG, embedded PDF fonts and final-size raster previews were checked separately.

## 9. Recommended handover order

For a new analyst or manuscript author:

1. Read the project-level `PROJECT_CONTEXT.md`.
2. Read `descriptive/discovery_validation/README.md` for the analytical workflow.
3. Read this file for the figure bundle.
4. Review `FIGURE_PLAN_AND_QA.md` for figure-specific decisions and limitations.
5. Open the PNG previews for a quick visual review.
6. Use SVG for editing, PDF for review and TIFF for raster submission when required by the target journal.
7. Before manuscript submission, write external figure legends that define the comparison, sample sizes, model, multiple-testing correction and the meaning of each evidence category.

## 10. Current handover state

```text
Figure set: COMPLETE
Version: v2.3
Figures: FIG1–FIG8
Analytical inputs: finalized D01–D10 outputs
Models/FDR recalculated by plotting code: NO
Candidate family changed: NO
Final-size visual QA: PASS
Next task: manuscript figure selection and external legend drafting
```
