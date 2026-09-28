# Visual QC — figures_prospective_v2.7

Inspected rendered PNG previews (downsampled from 600-dpi LZW TIFF) at
`qa_preview/`. Each row records PASS / NEEDS_REVISION and the fix applied.

## Design-system invariants applied
- Font: Arial throughout; base 7.5 pt, axis/legend 6.8 pt, panel tags 9 pt bold.
- No bold strip text or plot titles (v2.6 used bold strip.text).
- Fixed semantic palette: Control #6E6E6E, Low #4C9BB8, High #C4573B,
  Humid-hot #A64D6A, High-altitude #3D8B7A, Discovery #2E6FA8, Validation #C49A3D.
- Reference lines unified to dashed #9A9A9A.
- Background/non-significant points rendered in neutral gray (#C4C4C4).

## Per-figure QC

| Figure | Verdict | Notes |
|---|---|---|
| FIG1_cohort_scope | PASS | Legend repositioned inside panel a (no longer floating mid-plot); "1/85" label no longer collides with its dot; Discovery (blue) vs Validation (gold) semantically consistent. |
| FIG2_discovery_primary | PASS | Volcano: 85 candidates split into their own layer (size 1.1, alpha .95, deep blue) over 1,445 gray background points (size .7, alpha .55); reference lines at x=0 and y=-log10(.05); inline "n=1,445 tested; 85 locked candidates" annotation. |
| FIG3_dose_trajectories | PASS | Three trajectory classes as free-y facets; median overlay in High-exposure color; individual proteins in light gray; zero line present. |
| FIG4_environment_interaction | PASS | Panel a: concordance scatter with y=x dashed reference; panel b: interaction volcano with explicit "0 / 85 interaction FDR < 0.05" annotation (was empty-looking in v2.6). Colors: both-FDR green, Humid-hot-only pink, High-altitude-only teal. |
| FIG5_discovery_validation | PASS | Scatter on equal aspect; summary bars 83/85, 29/85, 1/85; evidence palette matches FIG6. |
| FIG6_integrated_evidence | PASS | 85×5 tile matrix; symmetric categorical palette; row order preserved from D10/D03; no clustering introduced. |
| FIG7_site_robustness | PASS | LOO heatmap + boxplot; site colors from restrained non-rainbow palette; zero line present. |
| FIG8_detection_evidence | PASS | y-limit narrowed to [0.65, 1.01] so sub-80% variation is visible (v2.6 wasted vertical space); 80% threshold line annotated. |
| FIG9_historical_discovery_reconciliation | PASS | Two branches (Historical gray, Frozen Discovery blue) stacked vertically; label dodging (`label_dodge`) eliminates the v2.6 overlap of 1434/1445 and 256/85; overlap bars 1426/8/19 clear; agreement scatter with y=x. |
| FIG10_replication_effect_support | PASS | 85-row paired effects split into two logical panels (1–43, 44–85) for readability without removing any protein; Discovery (blue) vs Validation (gold) paired lines show attenuation; hierarchy bars 85/85/83/29/1. |
| FIG11_trajectory_details | PASS | Representative proteins AGRN, NCAN, SERPINA3 retained exactly as frozen; all-85 heatmap in D03 order; category counts 75/6/4. |
| FIG12_environment_effect_forest | PASS | **Key fix:** both environment facets now share x-axis [−1.6, 0.2] (v2.6 had different scales); CIs visible; gene labels readable; zero line dashed. |
| FIG13_site_support | PASS | Site composition heatmap shows imbalance and missing cells explicitly; LOO forests on shared scale; restrained non-rainbow site palette. |
| FIG14_detection_peptide_status | PASS | **Key fix:** detection fill scale narrowed to [0.70, 1.0] with squish so sub-100% rows are visible (v2.6 was nearly uniform dark green); panel b "SOURCE_NOT_AVAILABLE" rendered in subdued gray, not bold, with "85/85 candidates" and "Peptide evidence not inferred" — does not read as a biological negative. |
| FIG15_discovery_ma_rank | PASS | 85 candidates split into own layer (size 1.0, alpha .95, deep blue) over 1,445 gray background; zero line present; all proteins preserved. |

## Cross-cutting checks
- Text clipping: none observed at 183×120 mm.
- Label collisions: none in inspected panels (FIG9 dodging applied).
- Legend collisions: none; legends moved to top/bottom or inside panels where appropriate.
- Panel alignment: consistent across figures via shared theme.
- Color semantics: no color reuse across meanings; Discovery=blue, Validation=gold throughout.
- Grayscale robustness: categorical encodings use luminance separation in addition to hue.
- 600-dpi TIFF render: inspected via downsampled PNG; glyphs sharp.

## Known limitation (documented, not chased)
Cairo nominal 1-pt PDF operator artifact remains. Per task instructions, this is not
chased; configured text size (7.5 pt base) and rendered SVG/TIFF are the source of
truth.
