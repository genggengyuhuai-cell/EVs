
# M17 manuscript figures — v2

## Export contract

- Backend: R only (`ggplot2`, `patchwork`, `svglite`, `cairo_pdf`, `ragg`).
- Final width: 183 mm.
- Outputs per figure: editable PDF, editable SVG, paired source-data CSV, and a 300 dpi PNG used only for visual QA.
- Source script: `descriptive/analysis_v2.0/code/V2_M17_figures_v2.R`.
- The script reads finalized result tables only. It does not refit models, recalculate multiplicity adjustments, alter thresholds, or redefine candidates.

## Figure contracts

### Figure 1 — Cohort, workflow and proteome landscape

- Core message: cohort chronology, Discovery/hold-out separation, site nesting and protein gates were defined before downstream inference.
- Panels: frozen chronology; Group counts; Site x Group composition; protein-universe gates.
- Reading order: a → b → c → d.
- Main-figure rationale: detailed Environment and covariate composition remain supporting material; the main figure retains only information needed to understand the design.

### Figure 2 — Proteome-wide exposure associations

- Core message: abundance, detection and descriptive dose architecture show heterogeneous exposure-associated patterns under prespecified FDR families.
- Panels: overall exposure effect landscape; pairwise effect distributions; Firth detection results; descriptive architecture counts.
- Statistical scope: overall abundance family A-E, pairwise A-LC/A-HC/A-HL families, detection family A-Det-Firth. Architecture is descriptive and is not a selection rule.

### Figure 3 — Discovery High-vs-Low candidate biology

- Core message: the locked 85-protein family has a coherent High-vs-Low effect landscape with heterogeneous Control/Low/High profiles and explicit missingness sensitivity.
- Panels: all 85 Discovery effects; all 85 adjusted profiles; overall-exposure KNN sensitivity restricted to the locked family; candidate architecture.
- Ordering: alphabetical candidate index. No figure-derived candidate rank is created.

### Figure 4 — Environment, Site heterogeneity and LOO

- Core message: Environment and Site analyses quantify effect heterogeneity and influence without equating subgroup significance differences with interaction.
- Panels: Environment-stratified effects; corrected pure 2-df interaction FDR distribution; Site x Group composition; leave-one-site-out maximum shifts.
- Statistical scope: corrected pure interaction result (0/1,430 at BH-FDR < 0.05); LOO is robustness evidence, not proof of absent heterogeneity.

### Figure 5 — Replication and DEP-driven ML prioritization

- Core message: replication, fixed-85 conditional ML and strict nested ML are complementary evidence streams; no algorithm is treated as the winner.
- Panels: frozen 85/85/83/29/1 hierarchy; outer-fold AUROC by branch; all 85 candidate-level method evidence; separate method-specific support counts.
- Statistical scope: hold-out denominator remains 85; CV points are outer folds; no composite score or new candidate definition is introduced.

### Figure 6 — Pathway and integrated biological interpretation

- Core message: ranked pathway analysis, fgsea sensitivity, ORA and candidate mapping converge on a compact set of biological themes.
- Panels: top eight GO-BP cameraPR results by prespecified pooled FDR; cameraPR/fgsea concordance; all three FDR-supported GO-BP ORA terms; four top pathway themes linked to candidate proteins.
- Selection rule: pathway panels are ordered by the finalized pooled FDR. Candidate membership is not re-ranked by the figure.
