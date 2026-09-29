# M17 figure QA — v2

## Visual review

- All six 183-mm-wide PNG previews were inspected at final physical scale after the last render.
- No clipped panel titles, axis labels, legends, count labels or panel letters remain.
- White background, restrained palette, charcoal text, consistent Group colors, minimal grid lines and no decorative effects are used throughout.
- Control/Low/High colors are stable across figures. Directional pathway colors are stable within Figure 6.
- The figures do not rely on a red/green-only distinction. Position and sign remain visible independently of color.
- Figure 6 network is restricted to four top pathway themes to avoid an unreadable hairball.

## Source-data and statistical QA

- R parse: PASS.
- Source-data assertions: PASS.
- Figure 1 Group total = 515 and Site total = 515.
- Figure 2 overall abundance = 1,430 proteins; three pairwise families = 3 × 1,430 rows; architecture counts sum to 1,430.
- Figure 3 = 85 unique locked candidates and 255 adjusted profile values.
- Figure 4 Environment and LOO panels = 1,430 proteins; interaction bins sum to 1,430; Site total = 515.
- Figure 5 candidate convergence = 85 × 4 method rows; replication hierarchy retains 85/85/83/29/1.
- Figure 6 contains eight ranked GO-BP terms, three FDR-supported GO-BP ORA terms and source rows for every displayed pathway-candidate edge.
- No subgroup-significance comparison is used as an interaction test; Figure 4 uses the corrected pure 2-df interaction result.
- Missingness, detection, null results and the reused-hold-out terminology are shown rather than hidden.

## Automated preflight

- Static source preflight: 17 PASS, 0 FAIL, 3 WARN.
- The warnings are expected for this delivery: no TIFF was requested, PNG is a 300 dpi QA preview rather than a submission raster, and the validator asks for a separate R parse (which passed).
- The PDF text scanner reports 1-pt `Tf` operations for all Cairo-generated R PDFs. This is a Cairo transform encoding artifact: the text is scaled by the PDF transformation matrix. The source validator found a 5.9-pt minimum and final-size visual inspection confirmed readability. The scanner result is retained as an unresolved tool-compatibility warning rather than reported as a pass.

## Export inventory

- Six single-page PDFs at 183 mm width.
- Six SVGs with editable text.
- Six paired source-data CSV files.
- Six PNG previews for QA only.
