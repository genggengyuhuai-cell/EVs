# Discovery–Validation Figure Plan

**Status:** FROZEN SCIENTIFIC-CONTENT PLAN after completion and audit of D01–D10.  
**Scope:** Main Figures 1–6 and Supplementary Figures S1–S11.  
**Visual styling remains editable:** fonts, colors, panel layout, legend placement, dimensions, and limited movement of panels between main and supplementary figures may be revised without changing the scientific content plan.

## 1. Governing principles

This figure plan is downstream of the frozen Discovery–Validation analysis and must not redefine it.

The following are fixed and must not be changed for figure construction:

- Discovery n = 386; Validation n = 129.
- Discovery eligibility universe entering D02 = 1,445 proteins.
- D03 locked candidate family = 85 proteins.
- D03 locking rule = Discovery Long vs Short BH-FDR < 0.05.
- Candidate membership cannot be changed using Validation results.
- D04 trajectory classifications are supportive characterizations, not candidate-selection rules.
- D05 environment-stratified analyses and D06 formal interaction analyses remain distinct.
- D07 supports site robustness / influence stability; it must not be described as proof of absence of site heterogeneity.
- D08 primary denominator remains all 85 locked candidates.
- D08 direction concordance, nominal replication, and FDR-supported replication retain their prespecified definitions.
- D08 environment-specific Validation remains secondary characterization.
- D09 detection thresholds remain 0.50, 0.60, 0.70, and 0.80.
- No imputation is introduced for figure generation.
- No post-hoc effect-size cutoff, Validation-driven protein selection, evidence score, composite ranking, arbitrary responder definition, or new statistical endpoint may be introduced for visualization.
- Unique-peptide support is currently unavailable and must not be invented.
- Pathway analysis is not run without an approved mapping/universe.

Figures must consume finalized result tables. Figure code must not refit statistical models, recalculate multiplicity-adjusted inference, or silently overwrite existing figure outputs.

---

# 2. Main Figures

## Figure 1 — Study design, cohort split, and analytical framework

**Scientific question:** How was the prospective Discovery–Validation study designed, frozen, and executed?

### Panel 1A — Cohort and frozen split

Show the participant flow:

- Total prospective cohort: 515 participants.
- Discovery: 386 participants.
- Validation: 129 participants.

The figure must make clear that the split was frozen before Validation outcome inspection.

### Panel 1B — Discovery eligibility and candidate locking

Show:

- D01: 1,445 Discovery-eligible proteins.
- D02: primary Discovery Long vs Short analysis.
- D03: 85 locked candidates.
- Locking rule: Discovery Long vs Short BH-FDR < 0.05.

Validation must not appear as an input into candidate selection.

### Panel 1C — Analysis architecture

Show the locked 85-candidate family feeding:

- D04 dose trajectory.
- D05 environment-specific Discovery analysis.
- D06 Dose × Environment interaction.
- D07 site robustness.
- Investigator-authorized Validation unlock.
- D08 locked-candidate Validation.
- D09 missingness/detection/peptide evidence.
- D10 integrated supportive evidence.

### Panel 1D — Dose composition by split

Show Control / Short / Long participant composition separately for Discovery and Validation.

### Panel 1E — Environment composition by split

Show Humid-hot and High-pressure/high-altitude participant composition separately for Discovery and Validation.

### Required interpretation

Figure 1 is a design/provenance figure. It must emphasize:

- frozen split;
- Discovery-only candidate selection;
- locked candidate family before Validation;
- no imputation;
- supportive analyses cannot add or remove candidates.

---

## Figure 2 — Discovery signal and locked candidate family

**Scientific question:** What was observed in the primary Discovery analysis, and how was the 85-protein family locked?

### Panel 2A — Global Discovery effect–significance landscape

Plot all 1,445 eligible proteins:

- x-axis: Discovery Long vs Short log2FC.
- y-axis: −log10(BH-FDR).

Visually distinguish the 85 D03 locked candidates from the remaining tested proteins.

No new threshold may be introduced.

### Panel 2B — Prespecified candidate-lock flow

Show the descriptive sequence:

- 1,445 tested.
- 365 raw P < 0.05.
- 85 BH-FDR < 0.05.
- 85 locked candidates.

This panel summarizes existing D02/D03 results; it does not create a new filtering hierarchy.

### Panel 2C — Discovery effect distribution among the 85 candidates

Display the distribution of the 85 locked-candidate Discovery log2FC values.

Required context:

- all 85 candidates were `Higher_in_Short`.

### Panel 2D — Candidate effect overview

Display all 85 Discovery effects using an ordered dot/forest-style visualization.

Ordering may be used only for display. It must not alter candidate membership or imply a new ranking criterion.

---

## Figure 3 — Dose-response architecture of the locked candidates

**Scientific question:** What Control–Short–Long response structures characterize the locked candidate family?

### Panel 3A — All 85 candidate trajectories

Plot modeled abundance across:

`Control → Short → Long`

Show individual protein trajectories with an overall descriptive median trajectory.

### Panels 3B–3D — Trajectory classes

Display the three finalized D04 classes separately:

- Reversal_after_short_increase: 75.
- Transient_short_peak: 6.
- Delayed_decrease: 4.

These classes are descriptive/supportive and do not redefine candidate importance.

### Panel 3E — Trajectory-class composition

Show counts and/or proportions for the three D04 trajectory classes.

### Panel 3F — Candidate × Dose heatmap

Display the 85 locked candidates across the three dose states using the finalized modeled abundance information.

No clustering or ordering scheme may be used to imply a new evidence ranking unless explicitly declared as display-only and independent of Validation outcomes.

---

## Figure 4 — Environmental context and site robustness

**Scientific question:** How do environment-stratified effects, formal interaction tests, and site-influence analyses contextualize the Discovery signal?

### Panel 4A — Environment-specific Long vs Short effects

Display the 85 candidate Long vs Short effects separately for:

- Humid-hot.
- High-pressure/high-altitude.

Source: D05.

### Panel 4B — Cross-environment effect comparison

Plot:

- x-axis: Humid-hot Long vs Short log2FC.
- y-axis: High-pressure/high-altitude Long vs Short log2FC.

This is a descriptive cross-environment comparison and must not be presented as a formal interaction test.

### Panel 4C — Formal Dose × Environment interaction

Display the D06 `Interaction_Long_vs_Short` results.

Required result context:

- raw P < 0.05: 2/85.
- secondary BH-FDR < 0.05: 0/85.

The figure and caption must preserve the distinction between D05 stratified results and D06 formal interaction inference.

### Panel 4D — Leave-one-major-site-out stability

Display the five major-site leave-one-out scenarios across the 85 candidates.

Finalized major-site LOO universe:

- 5 sites.
- 85 candidates.
- 425 estimates.

### Panel 4E — Site influence distribution

Display finalized effect-change/influence measures from D07, such as absolute Δlog2FC and/or the audited relative effect-change metric.

Required interpretation:

- no LOO scenario showed >50% relative effect change;
- this supports site robustness / influence stability;
- it must not be described as demonstrating absence of site heterogeneity.

---

## Figure 5 — Independent locked-candidate Validation

**Scientific question:** To what extent did the locked Discovery candidate family reproduce in the independent Validation split?

### Panel 5A — Discovery vs Validation effects

Plot all 85 locked candidates:

- x-axis: Discovery log2FC.
- y-axis: Validation log2FC.
- include identity/reference lines.

Use mutually exclusive Validation evidence states:

- Direction discordant: 2.
- Direction concordant only: 54.
- Nominal replication only: 28.
- FDR-supported replication: 1.

### Panel 5B — Prespecified replication hierarchy

Show:

- 85 locked.
- 85 estimable.
- 83 direction concordant.
- 29 nominal replication.
- 1 FDR-supported replication.

The primary denominator remains all 85 locked candidates.

### Panel 5C — Effect attenuation

Display:

`Validation log2FC − Discovery log2FC`

Finalized descriptive summaries include:

- median: +0.06630.
- mean: +0.08478.

Because all Discovery candidate effects were negative, the positive shift is interpreted descriptively as overall attenuation toward zero.

### Panel 5D — Absolute Validation/Discovery effect ratio

Display:

`|Validation log2FC| / |Discovery log2FC|`

Finalized summaries:

- Q1: 0.58521.
- median: 0.78357.
- Q3: 0.99928.
- 70/85 ≥ 0.50.
- 48/85 ≥ 0.75.
- 21/85 ≥ 1.00.

These are descriptive effect-size characterizations and are not replication criteria.

### Panel 5E — Protein-specific effect-size concordance

Report or visually annotate the finalized cross-protein correlations:

- Pearson r = 0.1114157.
- Spearman rho = 0.05411374.

Required interpretation:

**Strong group-level directional concordance, but weak protein-specific effect-size/rank concordance and limited multiplicity-controlled single-protein replication.**

Do not state that “85 proteins were validated” or that “effect sizes replicated well.”

### Panel 5F — Environment-specific Validation

Display the secondary environment-specific Validation characterization.

Humid-hot:

- 85 estimable.
- 83 negative / 2 positive.
- raw P < 0.05: 14.
- BH-FDR < 0.05: 0.
- mean log2FC: −0.3117.

High-pressure/high-altitude:

- 85 estimable.
- 78 negative / 7 positive.
- raw P < 0.05: 11.
- BH-FDR < 0.05: 0.
- mean log2FC: −0.2125.

This panel remains secondary characterization and must not be promoted to a new primary Validation endpoint.

---

## Figure 6 — Integrated evidence landscape

**Scientific question:** How do the finalized supportive evidence layers align across the locked 85-candidate family?

### Panel 6A — Candidate × evidence matrix

Use finalized D10 fields to display, without scoring:

- D04 trajectory.
- D06 formal Long vs Short interaction support.
- D07 site-direction stability.
- D08 Validation evidence class.
- D09 all-dose ≥80% detection robustness.

Candidate rows must preserve a declared locked/display order. They must not be ranked by the number or apparent strength of supportive evidence layers.

### Panel 6B — Evidence-layer summaries

Summarize key finalized counts, including:

- D07 all-direction-stable: 85/85.
- D08 direction concordant: 83/85.
- D08 nominal replication: 29/85.
- D08 FDR-supported replication: 1/85.
- D09 all-dose ≥80% detection: 81/85.
- D06 Long vs Short interaction secondary BH-FDR < 0.05: 0/85.

### Excluded from the current Figure 6

**Unique-peptide evidence**

- `SOURCE_NOT_AVAILABLE`: 85/85.
- Do not create an artificial peptide-support panel.

**Pathway evidence**

- `NOT_RUN_NO_APPROVED_MAPPING`: 85/85.
- Do not run or display pathway enrichment without an approved mapping/universe.

### Required interpretation

Figure 6 is an integrated descriptive evidence landscape. It must not create:

- an evidence score;
- a composite P value;
- a candidate ranking;
- a “best protein” subset;
- a new candidate definition.

---

# 3. Supplementary Figures

## Figure S1 — Discovery/Validation cohort composition

Provide detailed participant composition across:

- split;
- Dose;
- Environment;
- relevant site structure.

Purpose: transparent documentation of the frozen design and imbalance.

## Figure S2 — D01 eligibility and detection diagnostics

Show the Discovery-only eligibility process and detection diagnostics supporting the 1,445-protein D02 universe.

Purpose: document the protein-universe gate rather than introduce new filtering.

## Figure S3 — D02 primary-model diagnostics

Show finalized D02 design/model diagnostics, including estimability and relevant QC summaries.

Purpose: demonstrate the technical validity of the primary Discovery model.

## Figure S4 — Full 85-candidate dose trajectory heatmap

Provide a detailed version of the D04 candidate × dose structure, including all locked candidates.

Purpose: complement the summarized trajectory architecture in Main Figure 3.

## Figure S5 — Full D05 environment-specific contrast results

Display all six Environment × Contrast result families:

- Humid-hot Short vs Control.
- Humid-hot Long vs Control.
- Humid-hot Long vs Short.
- High-pressure/high-altitude Short vs Control.
- High-pressure/high-altitude Long vs Control.
- High-pressure/high-altitude Long vs Short.

Preserve the finalized secondary multiplicity treatment.

## Figure S6 — Full D06 interaction results

Display all three formal interaction contrasts:

- Interaction_Long_vs_Short.
- Interaction_Short_vs_Control.
- Interaction_Long_vs_Control.

Finalized secondary BH-FDR-supported counts are 0/85 for all three contrasts.

## Figure S7 — Complete D07 leave-one-major-site-out analysis

Display all 425 LOO estimates and associated stability/influence metrics across the five major sites.

Purpose: provide full robustness transparency beyond Main Figure 4.

## Figure S8 — Detailed Validation effect attenuation

Provide detailed distributions for:

- Validation − Discovery effect difference.
- absolute Validation/Discovery effect ratio.

This expands Main Figure 5 without creating new Validation criteria.

## Figure S9 — Detailed environment-specific Validation

Provide the complete D08 environment-specific Validation estimates for both environments.

This remains secondary characterization.

## Figure S10 — D09 detection gradient

Display the prespecified detection thresholds:

- 50%.
- 60%.
- 70%.
- 80%.

Across Dose and split as supported by the finalized D09 tables.

Relevant locked-candidate summary:

- all 85 meet ≥50%, ≥60%, and ≥70% across Dose strata;
- 81/85 meet ≥80% across all Dose strata.

## Figure S11 — Candidate missingness/detection by stratum

Display candidate-level missingness/detection across:

- Dose.
- Environment.
- Site.
- Discovery/Validation split where applicable.

Purpose: document data support and missingness patterns without converting detection into a new candidate-selection rule.

---

# 4. D01–D10 to figure mapping

| Analysis stage | Main figure(s) | Supplementary figure(s) |
|---|---|---|
| Frozen split/design | Figure 1 | S1 |
| D01 Discovery eligibility | Figure 1 | S2 |
| D02 Discovery primary | Figure 2 | S3 |
| D03 candidate lock | Figures 1–2 | — |
| D04 dose trajectory | Figures 3, 6 | S4 |
| D05 environment-specific Discovery | Figure 4 | S5 |
| D06 environment interaction | Figures 4, 6 | S6 |
| D07 site robustness | Figures 4, 6 | S7 |
| D08 locked-candidate Validation | Figures 5, 6 | S8–S9 |
| D09 missingness/detection/peptide evidence | Figure 6 | S10–S11 |
| D10 integrated evidence | Figure 6 | — |

---

# 5. Figure-plan freeze boundary

## Frozen scientific content

The following require explicit scientific-plan revision before they may change:

- which analytical stage supports each figure;
- the distinction between Discovery, supportive Discovery analyses, and Validation;
- candidate universe and candidate-lock rule;
- Validation endpoints and denominator;
- interaction interpretation;
- site-robustness interpretation;
- D09 detection thresholds;
- exclusion of unavailable peptide evidence;
- pathway gate;
- prohibition on evidence scoring/ranking and Validation-driven candidate redefinition.

## Editable visual implementation

The following remain editable without unfreezing the scientific plan:

- typography;
- color palette;
- point/line sizes;
- panel dimensions;
- legend position;
- panel lettering;
- axis-label wording that does not alter interpretation;
- exact arrangement of panels;
- movement of a supporting panel between a main figure and its corresponding supplementary figure when no scientific claim is changed.

---

# 6. Status of the existing `figures_prospective_v1` outputs

The previously generated FIG2–FIG6 SVG/PDF/TIFF files are retained only as a **figure-generation smoke test** demonstrating that finalized result tables can be consumed successfully.

They are **not frozen manuscript figures** and should not be treated as the final Main Figures 2–6.

Future manuscript figure generation should follow this frozen scientific-content plan.

---

# 7. Next permitted action

After this plan is reviewed and committed:

1. build a unified manuscript-figure module against finalized D01–D10 result tables;
2. implement Main Figures 1–6 according to this plan;
3. perform visual and scientific QA;
4. implement Supplementary Figures S1–S11;
5. perform cross-figure consistency QA;
6. only then freeze manuscript figure outputs.

No additional inferential analysis is authorized merely to improve figure appearance.

## ACTIVE V2.1 AMENDMENT — 2026-09-28
Forward-looking analysis and manuscript work are now governed by `docs/protocol/ANALYSIS_PLAN_v2.1.md`.
Key changes:
- Unique-peptide evidence is removed from active project scope. Historical frozen D09/D10 fields may remain physically present but are ignored downstream.
- The main biomarker-development target is High exposure vs Low exposure.
- The main biomarker candidate space is the 85 Discovery-only locked High-vs-Low DEPs.
- The 29 same-direction + nominal-P replicated proteins are replication evidence only and are not ML inputs.
- DEP-driven ML uses Elastic Net as the primary sparse model, Boruta as feature-relevance robustness, and XGBoost as nonlinear robustness.
- A strict fold-local differential-screening + ML nested sensitivity is required to assess the complete discovery-to-model pipeline.
- Existing completed all-proteome M15/M16 results remain frozen historical/supplementary evidence and must not be retuned or re-evaluated on the same 129 as though it were a new independent test.
- Site/heterogeneity/LOO remain required robustness analyses.
- Pathway/enrichment remains required and blocked pending an approved reproducible mapping/resource contract.
- Manuscript integrated reporting combines abundance, detection, missingness robustness, Environment/Site robustness, replication, ML and pathway evidence; no Unique-peptide axis and no composite evidence score.

