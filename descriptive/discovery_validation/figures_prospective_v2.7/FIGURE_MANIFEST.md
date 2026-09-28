# Figure Manifest — figures_prospective_v2.7

Visual revision of the frozen v2.6 bundle. All scientific values, protein
memberships, P/FDR/CI are identical to v2.6; this document proposes a
main-vs-supplement hierarchy based on scientific relevance only.

## Output convention
Each figure group ships:
- `FIG<n>_<name>.pdf` (Cairo PDF, 183×120 mm)
- `FIG<n>_<name>.svg` (svglite)
- `FIG<n>_<name>.tiff` (600-dpi LZW)
- `FIG<n>_<name>_source_data.csv` (frozen values, structurally annotated by
  `set_figure_source`)

## Proposed manuscript hierarchy

### Candidate MAIN figures
These carry the central discovery→replication narrative and should occupy
main-text figure slots:

| Figure | Rationale |
|---|---|
| FIG1 cohort_scope | Establishes the 515-person split and the 3817→1445→85→83→29→1 funnel. |
| FIG2 discovery_primary | The primary Discovery volcano; shows where the 85 candidates sit in the 1,445 tested universe. |
| FIG5 discovery_validation | The core replication scatter: Discovery vs reused-129 effects with the nested 83/29/1 hierarchy. |
| FIG9 historical_discovery_reconciliation | Parallel workflow comparison (Historical 3817→1434→256 vs Frozen 3817→1445→85); addresses reviewer question of how frozen results relate to historical analysis. |
| FIG10 replication_effect_support | Paired 85-protein effects showing attenuation and the nested replication counts. |
| FIG12 environment_effect_forest | Direct comparison of High-altitude vs Humid-hot effects on a shared scale. |

### Candidate SUPPLEMENTARY figures
These provide supporting detail but are not required to read the main claim:

| Figure | Rationale |
|---|---|
| FIG3 dose_trajectories | Three-class trajectory summary; detailed version in FIG11. |
| FIG4 environment_interaction | Formal interaction test (0/85 FDR-supported) — important as a negative result. |
| FIG6 integrated_evidence | 85×5 evidence matrix; useful as a summary but dense. |
| FIG7 site_robustness | LOO site heatmap + boxplot; detailed version in FIG13. |
| FIG8 detection_evidence | Detection rate by split and exposure; threshold gradients. |
| FIG11 trajectory_details | AGRN/NCAN/SERPINA3 representatives + all-85 heatmap. |
| FIG13 site_support | Site composition, representative profiles, LOO forests. |
| FIG15 discovery_ma_rank | MA and rank views of the 1,445-protein universe. |

### Diagnostic / audit-only figures
These document data-quality or provenance checks; they may appear as
supplementary audit figures rather than scientific claims:

| Figure | Rationale |
|---|---|
| FIG14 detection_peptide_status | Detection heatmap + explicit SOURCE_NOT_AVAILABLE for peptide evidence. Diagnostic by design. |

## Source files
All figures read frozen result tables from:
- `D01_discovery_eligibility/`
- `D02_discovery_primary/`
- `D03_candidate_lock/`
- `D04_dose_trajectory/`
- `D05_environment_specific/`
- `D06_environment_interaction/`
- `D07_site_robustness/`
- `D08_validation/`
- `D09_missingness_detection_peptides/`
- `D10_integrated_biology/`
- `descriptive/discovery_validation_split/discovery_validation_assignment.csv`
- Historical: `descriptive/limma_dose_analysis/...`

No scientific file was modified.
