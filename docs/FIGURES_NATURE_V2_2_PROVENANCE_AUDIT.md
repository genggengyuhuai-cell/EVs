# figures_nature_v2.2 Final Provenance Audit

Date: 2026-09-29
Scope: narrow — only `figures_nature_v2.2/` directories and their direct producer scripts.
No analysis was rerun, no paths changed, no outputs modified.

## 1. Core question

> Should `figures_nature_v2.2/` be ACTIVE_SUPPORTING, SUPPLEMENTARY, HISTORICAL_FROZEN, or MIXED_BUNDLE_REQUIRING_SPLIT?

**Final classification: SUPPLEMENTARY.**

The directory name contains "v2.2" but it is not a superseded manuscript-figure bundle. It is the upstream descriptive/QC figure layer produced by the tracked upstream descriptive pipeline (06–11). M17 (`V2_M17_figures_v2.R` → `figures_final_v2/`) does NOT source, read, or reference any file under `figures_nature_v2.2/`. The two layers serve different purposes:

- `figures_nature_v2.2/` — pre-M17 descriptive QC, MS batch proxy, normalization diagnostics, detection landscape, design-overlap, dose-pattern and protein-clustering figures. Supports Methods/QC narrative and reproducibility.
- `figures_final_v2/` — M17 manuscript Figures 1–6 (cohort, proteome associations, candidate biology, environment/site, replication+ML, pathway integration).

No split is required: every output in the bundle belongs to the same descriptive-QC layer.

## 2. Producer audit

10 producers, all tracked. None are sourced by M17.

| # | Producer (tracked) | Classification | Output directory (relative to repo root) | Scientific role | Manuscript role | Still needed |
|---|---|---|---|---|---|---|
| 1 | `descriptive/06_covariate_QC.R` | upstream descriptive (SUPPORT) | `descriptive/figures_nature_v2.2/` (top-level, 193 files) | Covariate / MS-batch-proxy QC | Methods/QC supplementary | Yes |
| 2 | `descriptive/nature_plotting.py` | upstream descriptive (SUPPORT) | `descriptive/figures_nature_v2.2/` (top-level) | Descriptive coverage / missingness / detection-gradient / design-composition figures | Methods/QC supplementary | Yes |
| 3 | `descriptive/07_limma_dose_analysis.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/diagnostics/figures_nature_v2.2/` (21 files) | limma plotSA / diagnostic PDFs | QC diagnostics | Yes |
| 4 | `descriptive/08b_limma_robustness.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/figures_final/06b_robustness/figures_nature_v2.2/` (51 files) | Robustness descriptive figures | Supplementary robustness | Yes |
| 5 | `descriptive/08c_run_replication.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/figures_final/06c_run_replication/figures_nature_v2.2/` (20 files) | Replication descriptive figures | Supplementary replication context | Yes |
| 6 | `descriptive/09_detection_pattern_analysis.R` | upstream descriptive (SUPPORT) | `descriptive/detection_pattern/figures_nature_v2.2/` (8 files) | Detection pattern descriptive figures | Supplementary detection | Yes |
| 7 | `descriptive/10a_DEP_characterization.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/figures_final/09_DEP_characterization/figures_nature_v2.2/` (12 files) | DEP characterization descriptive figures | Supplementary candidate characterization | Yes |
| 8 | `descriptive/10b_DEP_effect_size_summary.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/results/09_DEP_threshold_summary/figures_nature_v2.2/` (8 files) | Effect-size / threshold summary figures | Supplementary effect-size | Yes |
| 9 | `descriptive/11a_dose_pattern_classification.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/figures_final/10_dose_pattern_classification_v2/figures_nature_v2.2/` (16 files) | Dose-pattern classification figures | Supplementary pattern description | Yes |
| 10 | `descriptive/11b_protein_clustering.R` | upstream descriptive (SUPPORT) | `descriptive/limma_dose_analysis/figures_final/10_protein_clustering/figures_nature_v2.2/` (36 files) | Protein clustering figures | Supplementary clustering description | Yes |

Producer status:
- Current/canonical producers: 10 / 10 (all tracked, none archived, none superseded).
- Historical/legacy producers: 0.
- The upstream descriptive layer is itself SUPPLEMENTARY per the reconstruction plan; it supports the v2.0 analysis universe and QC narrative but does not produce M17 main-text figures.

## 3. Output audit

Total files across all 11 `figures_nature_v2.2/` directories: **649**.

Breakdown by directory:

| Directory | Files |
|---|---|
| `descriptive/figures_nature_v2.2/` (top-level) | 193 |
| `descriptive/covariate_QC/figures_nature_v2.2/` | 224 |
| `descriptive/detection_pattern/figures_nature_v2.2/` | 8 |
| `descriptive/limma_dose_analysis/diagnostics/figures_nature_v2.2/` | 21 |
| `descriptive/limma_dose_analysis/figures_final/06b_robustness/figures_nature_v2.2/` | 51 |
| `descriptive/limma_dose_analysis/figures_final/06c_run_replication/figures_nature_v2.2/` | 20 |
| `descriptive/limma_dose_analysis/figures_final/09_DEP_characterization/figures_nature_v2.2/` | 12 |
| `descriptive/limma_dose_analysis/figures_final/10_dose_pattern_classification_v2/figures_nature_v2.2/` | 16 |
| `descriptive/limma_dose_analysis/figures_final/10_protein_clustering/figures_nature_v2.2/` | 36 |
| `descriptive/limma_dose_analysis/results/09_DEP_threshold_summary/figures_nature_v2.2/` | 8 |
| `descriptive/limma_dose_analysis/results/10_detection_pattern_analysis/figures_nature_v2.2/` | 60 |

Top-level (`descriptive/figures_nature_v2.2/`) composition: 57 PDF + 57 PNG + 57 SVG + 22 CSV = 193.
- 22 CSVs are source-data companions (Figure_01..04 + Quantitative_filter_*).
- Figure stems: Figure_01 descriptive coverage (environment/protein/region/sample depth), Figure_02 missingness (abundance/matrix/protein), Figure_03 detection gradient, Figure_04 design composition, Figure6 coverage-by-date/exposure, Figure7-9 condition/group/TREAT1 batch-proxy QC, Figure10 MS-batch-proxy, Figure11 detection landscape, Figure12 normalization diagnostics, Figure13 before/after medians, Figure14 PCA, Figure15 design overlap.

Classification of every output: **DESCRIPTIVE_SUPPORT / SUPPLEMENTARY QC**. None is a M17 main-text figure.

## 4. M17 overlap

| Dimension | figures_nature_v2.2/ | figures_final_v2/ |
|---|---|---|
| Layer | Upstream descriptive / QC | M17 manuscript assembly |
| Figures | ~57 descriptive stems (coverage, missingness, detection gradient, design composition, batch-proxy, normalization, PCA, clustering) | Fig1 cohort, Fig2 proteome landscape, Fig3 candidate biology, Fig4 environment/site, Fig5 replication+ML, Fig6 pathway |
| Source data | 22 upstream CSV companions | 6 M17 source_data CSVs |
| Consumed by M17? | No (V2_M17_figures_v2.R contains zero references to figures_nature_v2.2) | n/a |
| Scientific info overlap | None on main-text panels. M17 Fig1 (cohort design) is a manuscript redraw; figures_nature_v2.2 Figure_04 design composition and Figure15 design overlap are the upstream descriptive versions, not the same panel. |

Verdict: **PARTIALLY_SUPERSEDED** only in the trivial sense that M17 Fig1 redraws cohort/design; the underlying descriptive QC figures still carry information M17 does not show (MS batch proxy, normalization diagnostics, PCA, detection gradient by group threshold). These are legitimate Supplementary/QC outputs, not duplicates.

## 5. Producer status vs output path

All 10 producers are tracked, current, and still produce these outputs. No producer is itself legacy/superseded. Therefore the output directories must NOT be archived as HISTORICAL_FROZEN — doing so would orphan the producers' output and break reproducibility of the upstream QC layer.

## 6. Split decision

**No split required.** All 649 outputs across the 11 directories belong to the same upstream descriptive/QC layer. There is no subset that is "historical only" or "fully superseded by M17".

## 7. Action

- **Do not move** `figures_nature_v2.2/` (any of the 11 directories).
- **Do not archive** producer scripts.
- Mark the bundle as **SUPPLEMENTARY** in `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv` and resolve R37 in `docs/REPOSITORY_RISK_REGISTER.csv`.
- Producers remain active SUPPORT scripts; they feed the upstream descriptive layer that supports the v2.0 analysis universe.

## 8. Scope note

The user-specified path `descriptive/analysis_v2.0/figures_nature_v2.2/` does not exist on disk. The actual top-level bundle is `descriptive/figures_nature_v2.2/` (193 files). The remaining 10 nested `figures_nature_v2.2/` directories live under `descriptive/covariate_QC/`, `descriptive/detection_pattern/`, and `descriptive/limma_dose_analysis/...`. This audit covers all 11.
