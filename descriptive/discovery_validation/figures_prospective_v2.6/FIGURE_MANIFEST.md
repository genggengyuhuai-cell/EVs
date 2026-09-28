# Prospective discovery-validation figure manifest

This bundle is plotting-only. All numerical quantities come from frozen historical or D01-D10 result tables. No model was fit or refit, and no P value or BH-FDR value was calculated or recalculated while producing these figures.

All figures are exported as PDF, SVG, 600 dpi TIFF, and an exact source-data CSV. Display labels use `Gene_symbol` or `Display_label` where individual proteins are named. Protein identifiers remain in the source-data CSVs.

## FIG1 — Cohort scope

- Scientific question: How are the 515 participants distributed across the frozen Discovery and reused Validation splits, environments, and exposure groups, and how does the prospective protein workflow narrow?
- Source files: `descriptive/discovery_validation_split/discovery_validation_assignment.csv`; finalized counts encoded from D01, D03, and D08 frozen outputs.
- Analysis branch: Frozen prospective Discovery/Validation workflow.
- Universe: 515 participants; 3,817 raw protein groups; 1,445 Discovery-eligible proteins; 85 D03 locked candidates.
- Contrast: Descriptive split composition and workflow counts.
- Display-selection rule: All split-by-environment-by-exposure cells and all prespecified workflow stages.
- Statistical quantities shown: Counts only.
- Outputs: `FIG1_cohort_scope.{pdf,svg,tiff}`; `FIG1_cohort_scope_source_data.csv`.
- Known limitations: Workflow counts are descriptive and are not a participant-flow causal diagram.

## FIG2 — Frozen Discovery primary contrast

- Scientific question: Which proteins constitute the frozen D03 candidate family within the complete D02 Discovery contrast?
- Source files: `D02_discovery_primary/D02_Long_vs_Short_all_tested.csv`; `D03_candidate_lock/D03_locked_candidates.csv`.
- Analysis branch: Frozen Discovery D02/D03.
- Universe: All 1,445 Discovery-eligible proteins; 85 frozen candidates highlighted.
- Contrast: High exposure vs Low exposure.
- Display-selection rule: All 1,445 tests; highlighting uses frozen D03 membership only.
- Statistical quantities shown: Frozen log2FC and BH-FDR.
- Outputs: `FIG2_discovery_primary.{pdf,svg,tiff}`; `FIG2_discovery_primary_source_data.csv`.
- Known limitations: The volcano view does not show average abundance or confidence intervals.

## FIG3 — D04 dose trajectories

- Scientific question: What are the Control-to-Low-to-High modeled trajectories of all 85 locked candidates within the finalized D04 categories?
- Source files: `D04_dose_trajectory/D04_modeled_abundance_by_dose.csv`; `D04_dose_trajectory/D04_trajectory_classification.csv`; `D04_dose_trajectory/D04_candidate_contrasts.csv`.
- Analysis branch: Frozen Discovery D04.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: Low exposure vs Control; High exposure vs Control.
- Display-selection rule: All 85 candidates, grouped only by finalized D04 category.
- Statistical quantities shown: Modeled abundance change from Control; source data retain frozen CI, P value, BH-FDR, and Model_status where applicable.
- Outputs: `FIG3_dose_trajectories.{pdf,svg,tiff}`; `FIG3_dose_trajectories_source_data.csv`.
- Known limitations: Protein-level lines are intentionally unlabeled; medians summarize categories without replacing individual trajectories.

## FIG4 — Environment concordance and formal interaction

- Scientific question: Are candidate effects concordant between Humid-hot and High-altitude environments, and do finalized D06 interaction results support heterogeneity?
- Source files: `D05_environment_specific/D05_candidate_environment_results.csv`; `D06_environment_interaction/D06_candidate_interaction_results.csv`.
- Analysis branch: Frozen Discovery D05/D06.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: High exposure vs Low exposure within each environment; exposure-by-environment interaction.
- Display-selection rule: All 85 candidates in both D05 strata and all 85 D06 interaction tests.
- Statistical quantities shown: Frozen log2FC and secondary BH-FDR.
- Outputs: `FIG4_environment_interaction.{pdf,svg,tiff}`; `FIG4_environment_interaction_source_data.csv`.
- Known limitations: Different within-stratum significance states are not interpreted as heterogeneity; formal interaction evidence is shown separately.

## FIG5 — Discovery versus reused hold-out evidence

- Scientific question: How do all 85 Discovery effects compare with reused 129 hold-out effects, and how many meet the finalized replication criteria?
- Source file: `D08_validation/D08_validation_results.csv`.
- Analysis branch: Frozen Discovery D03 and reused 129 hold-out D08.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: High exposure vs Low exposure.
- Display-selection rule: All 85 candidates; no labels or protein selection based on Validation P value, BH-FDR, direction, or effect.
- Statistical quantities shown: Discovery and Validation log2FC; finalized counts for direction concordance, nominal replication, and FDR-supported replication.
- Outputs: `FIG5_discovery_validation.{pdf,svg,tiff}`; `FIG5_discovery_validation_source_data.csv`.
- Known limitations: Confidence intervals and signed effect differences are provided in FIG10 rather than this overview.

## FIG6 — Integrated frozen evidence matrix

- Scientific question: What finalized D04, D06, D07, D08, and D09 evidence state does each locked candidate carry?
- Source file: `D10_integrated_biology/D10_integrated_candidate_evidence.csv`.
- Analysis branch: Frozen integrated D10 summary of D04-D09.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: Trajectory, formal interaction, site robustness, hold-out replication, and detection support.
- Display-selection rule: All 85 candidates in original D10/D03 order; no evidence score or evidence-based rank.
- Statistical quantities shown: Finalized categorical states; source data retain D06/D07/D08/D09 quantitative fields where applicable.
- Outputs: `FIG6_integrated_evidence.{pdf,svg,tiff}`; `FIG6_integrated_evidence_source_data.csv`.
- Known limitations: The matrix is a descriptive evidence inventory, not a composite score.

## FIG7 — Leave-one-site-out effect shifts

- Scientific question: How much do frozen Discovery effects shift when each major site is omitted?
- Source file: `D07_site_robustness/D07_leave_one_major_site_out.csv`.
- Analysis branch: Frozen Discovery D07.
- Universe: 85 candidates × 5 finalized leave-one-major-site-out scenarios.
- Contrast: High exposure vs Low exposure.
- Display-selection rule: All 425 candidate-scenario rows in source order.
- Statistical quantities shown: Leave-one-site-out log2FC, primary log2FC, signed shift, direction-stability state, CI, P value, BH-FDR, and Model_status in source data.
- Outputs: `FIG7_site_robustness.{pdf,svg,tiff}`; `FIG7_site_robustness_source_data.csv`.
- Known limitations: Protein labels are suppressed in the dense heatmap; FIG13 provides CI forests.

## FIG8 — Detection evidence and threshold gradient

- Scientific question: How complete is detection across Discovery/Validation exposure strata, and how does support change across the prespecified 50/60/70/80% thresholds?
- Source files: `D09_missingness_detection_peptides/D09_missingness_detection_by_stratum.csv`; `D09_missingness_detection_peptides/D09_detection_gradients.csv`.
- Analysis branch: Frozen D09 across Discovery and reused 129 hold-out.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: Detection by split and exposure.
- Display-selection rule: All 85 candidates in all six split-by-exposure strata and all prespecified thresholds.
- Statistical quantities shown: Finalized detection rates and counts of candidates reaching each threshold.
- Outputs: `FIG8_detection_evidence.{pdf,svg,tiff}`; `FIG8_detection_evidence_source_data.csv`.
- Known limitations: Distributions do not identify which candidate occupies each row; FIG14 supplies the row-level heatmap.

## FIG9 — Historical versus frozen Discovery reconciliation

- Scientific question: How do the historical full-cohort and frozen Discovery workflows differ in eligibility and final evidence sets, and how closely do common-protein effects agree?
- Source files: `descriptive/limma_dose_analysis/analysis_manifest.csv`; `descriptive/limma_dose_analysis/results/01_PRIMARY/PRIMARY_log2_dose_environment__High_vs_Low.csv`; `descriptive/limma_dose_analysis/results/13A_canonical_256_DEP_master/Stage13A_canonical_256_DEP_master.csv`; `D01_discovery_eligibility/D01_integrity_assertions.csv`; `D02_discovery_primary/D02_Long_vs_Short_all_tested.csv`; `D03_candidate_lock/D03_locked_candidates.csv`.
- Analysis branch: Historical full-cohort versus frozen Discovery; branches remain visually distinct.
- Universe: 3,817 raw groups in each workflow; 1,434 historical eligible, 1,445 Discovery eligible; 1,426 shared, 8 historical-only, 19 Discovery-only.
- Contrast: High exposure vs Low exposure.
- Display-selection rule: Every workflow stage, all three exact membership classes, and all 1,426 common proteins.
- Statistical quantities shown: Frozen counts and paired historical/Discovery log2FC; no correlation coefficient was calculated.
- Outputs: `FIG9_historical_discovery_reconciliation.{pdf,svg,tiff}`; `FIG9_historical_discovery_reconciliation_source_data.csv`.
- Known limitations: Differences reflect cohort and eligibility changes; the plot does not assign a causal reason for disagreement.

## FIG10 — Replication hierarchy, paired effects, and effect differences

- Scientific question: How does the full locked family progress through the finalized replication hierarchy, and how do paired Discovery and hold-out effects differ candidate by candidate?
- Source file: `D08_validation/D08_validation_results.csv`.
- Analysis branch: Frozen Discovery D03 to reused 129 hold-out D08.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: High exposure vs Low exposure.
- Display-selection rule: All 85 candidates in frozen D03 order; no Validation-driven selection or labeling.
- Statistical quantities shown: Locked/estimable/same-direction/nominal-P/BH-FDR counts; paired Discovery and Validation log2FC; frozen signed effect difference.
- Outputs: `FIG10_replication_effect_support.{pdf,svg,tiff}`; `FIG10_replication_effect_support_source_data.csv`.
- Known limitations: The histogram is descriptive and does not test attenuation; candidate labels are omitted to keep the all-85 paired display readable.

## FIG11 — D04 representative trajectories, all-85 heatmap, and category counts

- Scientific question: What do the finalized D04 categories look like in representative proteins and across the entire locked family?
- Source files: `D03_candidate_lock/D03_locked_candidates.csv`; `D04_dose_trajectory/D04_modeled_abundance_by_dose.csv`; `D04_dose_trajectory/D04_trajectory_classification.csv`.
- Analysis branch: Frozen Discovery D04.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: Control, Low exposure, and High exposure modeled abundance changes.
- Display-selection rule: Heatmap includes all 85 in D03 order. Representatives are the first D03-order protein in each finalized trajectory class: AGRN, NCAN, and SERPINA3. No Validation information or effect-size ranking is used.
- Statistical quantities shown: Finalized modeled abundance change from Control and category counts.
- Outputs: `FIG11_trajectory_details.{pdf,svg,tiff}`; `FIG11_trajectory_details_source_data.csv`.
- Known limitations: Representatives illustrate existing category shapes and are not claimed to be uniquely typical or biologically privileged.

## FIG12 — Environment-stratified effect forest

- Scientific question: What are the frozen candidate effect estimates and confidence intervals within Humid-hot and High-altitude environments?
- Source file: `D05_environment_specific/D05_candidate_environment_results.csv`.
- Analysis branch: Frozen Discovery D05.
- Universe: 85 candidates × 2 environments.
- Contrast: High exposure vs Low exposure within environment.
- Display-selection rule: All candidates in both environments in frozen D03 order; no subgroup-significance selection.
- Statistical quantities shown: Frozen log2FC and 95% CI; source data retain P value, primary BH-FDR, secondary BH-FDR, and Model_status.
- Outputs: `FIG12_environment_effect_forest.{pdf,svg,tiff}`; `FIG12_environment_effect_forest_source_data.csv`.
- Known limitations: Protein labels are suppressed for density; cross-environment heterogeneity must be judged from FIG4's formal D06 interaction panel, not differing CI/significance states.

## FIG13 — Site composition, representative site profiles, and LOO forests

- Scientific question: Is exposure composition balanced across sites, how do prespecified representatives behave within sites, and how stable are all candidate effects after omitting each major site?
- Source files: `D07_site_robustness/D07_site_dose_composition.csv`; `D07_site_robustness/D07_candidate_site_summaries.csv`; `D07_site_robustness/D07_leave_one_major_site_out.csv`; D03/D04 tables used only for frozen-order representative selection.
- Analysis branch: Frozen Discovery D07.
- Universe: 386 Discovery participants; three D03-order D04 representatives across all sites; 85 candidates × 5 LOO scenarios.
- Contrast: Site-by-exposure composition; site-specific descriptive abundance; LOO High exposure vs Low exposure.
- Display-selection rule: All site-exposure count cells; AGRN, NCAN, and SERPINA3 selected by the same D03-order rule as FIG11; all 425 LOO rows.
- Statistical quantities shown: Participant counts, observed median log2 abundance, LOO log2FC and 95% CI; source data retain P value, BH-FDR, Model_status, primary effect, and effect shift.
- Outputs: `FIG13_site_support.{pdf,svg,tiff}`; `FIG13_site_support_source_data.csv`.
- Known limitations: Six representative site-exposure medians are unavailable because the frozen table has no observed value; these remain explicit missing rows and appear as line gaps.

## FIG14 — Detection heatmap and peptide-source status

- Scientific question: Which locked candidates have lower detection in particular split/exposure strata, and is peptide-support evidence available?
- Source files: `D09_missingness_detection_peptides/D09_missingness_detection_by_stratum.csv`; `D09_missingness_detection_peptides/D09_unique_peptide_support.csv`.
- Analysis branch: Frozen D09 across Discovery and reused 129 hold-out; separate peptide-source audit.
- Universe: Frozen D03 candidate family, n=85.
- Contrast: Detection by split and exposure; peptide-source availability.
- Display-selection rule: All 85 candidates and all six split-by-exposure strata; all 85 peptide-status rows.
- Statistical quantities shown: Finalized detection/missingness rates and source status only.
- Outputs: `FIG14_detection_peptide_status.{pdf,svg,tiff}`; `FIG14_detection_peptide_status_source_data.csv`.
- Known limitations: Unique-peptide source is unavailable for all 85 candidates; the panel states `SOURCE_NOT_AVAILABLE` and no peptide evidence is inferred.

## FIG15 — Discovery MA and effect-rank supplements

- Scientific question: Are frozen Discovery effects related to average abundance, and where do locked candidates lie across the complete effect distribution?
- Source files: `D02_discovery_primary/D02_Long_vs_Short_all_tested.csv`; `D03_candidate_lock/D03_locked_candidates.csv`.
- Analysis branch: Frozen Discovery D02/D03.
- Universe: All 1,445 Discovery-eligible proteins.
- Contrast: High exposure vs Low exposure.
- Display-selection rule: All 1,445 tests; highlighting uses frozen D03 membership only. Rank orders all proteins by the existing D02 effect and selects none.
- Statistical quantities shown: Frozen log2FC and average abundance; source data retain CI, P value, BH-FDR, and Model_status.
- Outputs: `FIG15_discovery_ma_rank.{pdf,svg,tiff}`; `FIG15_discovery_ma_rank_source_data.csv`.
- Known limitations: The rank is a display coordinate, not a new score or inferential analysis. The existing FIG2 volcano is not duplicated.

## Requested items not drawn as additional figures

- All-85 Discovery-versus-Validation scatter: already present as FIG5a.
- Humid-hot-versus-High-altitude concordance scatter and formal interaction plot: already present as FIG4a-b.
- Leave-one-site-out effect-shift heatmap: already present as FIG7a.
- 50/60/70/80% detection-threshold gradient: already present as FIG8b.
- Discovery volcano for the frozen primary contrast: already present as FIG2.
- Additional volcano panels for D04-D09 were not created because these stages are candidate-level supporting analyses and adding repeated volcanoes would duplicate the frozen quantities already shown in trajectory, forest, interaction, validation, robustness, and detection figures.
- A candidate annotation summary was not added because the frozen tables contain identifiers and technical metadata but no finalized biological annotation categories suitable for a scientifically interpretable summary.
- Peptide-support evidence could not be drawn because the frozen D09 table records `SOURCE_NOT_AVAILABLE` for all candidates; FIG14b reports that status explicitly.

## Figure contract and visual QA

- Core conclusion: The frozen 85-candidate family can be traced from its historical context through Discovery, reused hold-out evidence, dose trajectories, environment and site robustness, and detection support without altering any frozen statistical result.
- Archetype: Quantitative grid and supporting supplemental figures.
- Backend: R only (`ggplot2`, `patchwork`, `svglite`, Cairo PDF, and `ragg`).
- Final size: 183 mm × 120 mm for every figure.
- Color and terminology: Consistent exposure/environment labels and restrained palette across panels.
- Visual inspection: Every new panel and assembled figure was inspected from R-generated previews at final aspect ratio; label clipping, legend fit, panel collisions, shared axes, and uncertainty rendering were checked.
- R parse: PASS.
- Static source preflight: 19 PASS, 0 FAIL; the validator's single syntax WARN reflects its delimiter-only R parser and was superseded by successful `Rscript parse()`.
- D03 integrity: PASS, exactly 85 rows and 85 unique nonmissing `PG.ProteinGroups` values.
- Prohibited analysis search: PASS, no model-fitting, limma, Firth, `p.adjust`, or q-value calculation call was introduced.
- Source-data schema: PASS for all seven new CSVs, including identifiers, branch, universe, contrast, effect, CI, P value, BH-FDR, Model_status, and display-selection rule fields.
- Export completeness: PASS for all seven new figures in PDF, SVG, TIFF, and CSV formats.
- TIFF resolution: PASS, 4,322 × 2,834 pixels at 600 × 600 dpi for each new figure.
- PDF text audit: the Cairo files expose the known nominal `1 Tf` operator warning. Per the task instruction, no further effort was spent on that operator because configured source text is at least 5.8 pt and final-size SVG/TIFF previews are readable.
