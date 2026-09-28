# Discovery–Validation figure plan and QA

## Figure contract

- **Core conclusion:** The 85 Discovery candidates show strong family-level direction concordance in independent Validation, but weak protein-specific effect agreement and limited multiplicity-controlled single-protein replication. The family-level direction is robust to leave-one-major-site-out analysis, and candidate detection is generally high.
- **Archetype:** Quantitative grid with a Discovery-to-Validation agreement hero panel and supporting cohort, trajectory, environment, robustness, detection and integrated-evidence panels.
- **Backend:** R only (`ggplot2`, `patchwork`, `ggrepel`, `svglite`, Cairo PDF and `ragg`).
- **Final size:** 183 × 120 mm. PDF width is rounded to the nearest realizable PostScript point (183.092 mm); SVG and TIFF retain the declared physical dimensions.
- **Exports:** Editable SVG, embedded-font PDF and 600 dpi LZW-compressed TIFF. PNG files under `preview_png/` are review previews only.

## Data-to-figure mapping

| Data stage | Scientific role | Selected display | Output |
|---|---|---|---|
| Frozen participant assignment + D01 eligibility | Show cohort balance and analytical scope | Grouped participant bars by Environment × Dose; analysis/evidence lollipop | FIG1 |
| D02 primary Discovery model + D03 lock | Show the primary Long-vs-Short signal and the exact locked family | FDR volcano with all 1,445 tested proteins and 85 locked candidates highlighted | FIG2 |
| D04 trajectory characterization | Separate the three candidate response shapes without abundance-level confounding | Per-protein change from Control with category-specific median profile | FIG3 |
| D05 environment estimates + D06 formal interaction | Distinguish environment-stratified effects from formal heterogeneity evidence | Paired environment-effect scatter plus interaction effect/FDR panel | FIG4 |
| D08 locked-family Validation | Show effect agreement and the prespecified replication hierarchy | Discovery–Validation effect scatter plus nested evidence counts | FIG5 |
| D10 integrated candidate master | Show evidence states without creating a score or ranking | Candidate-by-evidence tile matrix in locked order | FIG6 |
| D07 leave-one-major-site-out results | Show influence robustness and the magnitude of site-removal shifts | Candidate × site delta-log2FC heatmap plus per-site distributions | FIG7 |
| D09 detection and missingness evidence | Show stratum-level detection and threshold sensitivity | Detection-rate distributions plus threshold-retention curves | FIG8 |

Design matrices, manifests and integrity-assertion tables were used for audit only. They were not plotted because they do not add a distinct biological or statistical claim. Unique-peptide support was not plotted because the approved source is unavailable for every candidate. Pathway results were not plotted because no approved mapping/universe was supplied.

## Interpretation guardrails

- The 85 candidates are the frozen D03 family; no figure refits models, recalculates FDR, changes thresholds or selects proteins by visual appearance.
- FIG3 subtracts each protein's modeled Control mean only for display. It does not change the D04 trajectory classification.
- D05 environment-specific significance is descriptive/supportive. FIG4 separately displays D06, where 0/85 Long-vs-Short interaction tests reached secondary BH-FDR < 0.05.
- D08 results are reported as 83/85 direction concordant, 29/85 nominally replicated and 1/85 FDR-supported. The figure must not be described as “85 proteins validated.”
- FIG6 preserves the locked candidate order and does not compute an evidence score.
- Missing values were not converted to zero or imputed by the figure code.

## Final QA

| Check | Result |
|---|---|
| R syntax | PASS (`Rscript parse`) |
| Source preflight | 19 PASS, 1 informational warning asking for an R parse; the parse was run successfully |
| Frozen counts/contracts | PASS: 515 = 386 Discovery + 129 Validation; 1,445 eligible; 85 locked; 83/29/1 Validation hierarchy |
| Final-size visual inspection | PASS for every panel and assembled figure; no clipping or label collisions observed |
| SVG text | PASS: editable Arial text detected |
| PDF fonts | PASS: Arial/Arial Bold embedded |
| TIFF | PASS: 4322 × 2834 px, 600 dpi, RGB, LZW compression |
| Physical size | PASS: SVG ≈183 × 120 mm; PDF 183.092 × 119.944 mm; TIFF ≈182.965 × 119.973 mm |
| Figure titles/captions | Kept outside the image; only axes, legends, facets, direct labels and panel tags are on canvas |
| Backend exclusivity | PASS: all drawing, export and preview conversion used R |

The PDF text scanner reports 1 pt `Tf` operators for Cairo and base R PDF output because these devices encode glyph size through transformation matrices. The scanner explicitly does not account for those transforms. Source sizes are 5.8–8 pt, SVG text is editable, PDF fonts are embedded, and final-size TIFF/SVG/PDF visual inspection was completed. This is recorded as a tooling limitation rather than a true 1 pt rendered-text finding.

