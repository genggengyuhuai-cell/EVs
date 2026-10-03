# Discovery--Validation EV proteomics pipeline

## Current authority and objective

This is the canonical technical README for the executed prospective
Discovery--Validation branch. The primary question is whether Discovery
Long vs Short (`high` vs `low`) quantitative protein effects replicate
in an independent frozen Validation set. The historical full-cohort
analysis remains a benchmark, not a source of prospective eligibility,
candidates or thresholds.

The frozen split contains 386 Discovery and 129 Validation participants
and must never be regenerated or modified.

**Current state:** D01--D10 have been executed, reviewed and committed. The
D01--D10 core is frozen; the current repository scientific HEAD is `8695ae6`
(which also carries the post-v2.1 extended analyses). The exact D03 candidate
family remains fixed at 85 proteins.

**Post-v2.1 additions in this module:** `D02_pairwise_completion/` (pairwise vs-Control
completion), `control_referenced_pathways/` (cameraPR + nominal ORA), and
`descriptive/environment_stratified_discovery/` (environment-stratified de novo discovery).
All are secondary/exploratory Level-2/3; the frozen 85 and frozen High-vs-Low results are
unchanged. The old `D06_environment_interaction/` outputs were archived to
`archive/historical_results/`; the authoritative environment-interaction analysis is M10
(corrected pure 2-df, 0/1,430) under `descriptive/analysis_v2.0/`.

## Stage architecture and executed results

-   **D01 --- Discovery eligibility.** Eligibility was rebuilt from the
    raw protein universe using Discovery only. Detection was finite
    abundance \>0 and each of Control/Short/Long independently had to
    reach 70%. No transformation, normalization or imputation was used
    for eligibility. Result: 1,445 eligible proteins from 386 Discovery
    participants.
-   **D02 --- Primary Discovery model.** `log2(PG.Quantity)`, no
    additional normalization, no imputation; limma model
    `abundance ~ dose + environment`; primary contrast Long vs Short.
    All 1,445 proteins were estimable; 365 had raw P\<0.05 and 85 had
    BH-FDR\<0.05.
-   **D03 --- Candidate lock.** Candidates were locked solely by
    Discovery Long-vs-Short BH-FDR\<0.05. No effect cutoff, Control
    result, subgroup result, site result or historical membership
    altered this rule. Result: 85 candidates, all `Higher_in_Short`.
    Candidate SHA-256:
    `14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2`.
-   **D04 --- Dose trajectory.** Supportive characterization only: 75
    `Reversal_after_short_increase`, 6 `Transient_short_peak`, 4
    `Delayed_decrease`.
-   **D05 --- Environment-specific Discovery.** Three contrasts were
    estimated within each Environment. This is secondary/supportive
    evidence and does not change candidate membership.
-   **D06 --- Formal Environment interaction.**
    Difference-in-differences interaction testing was performed.
    Secondary BH-FDR\<0.05 results were 0/85 for each of the three
    interaction contrasts. Differences in D05 significant-count totals
    must therefore not be presented as proof of formal interaction.
    (Historical; superseded by the corrected pure 2-df M10 interaction —
    0/1,430 — under `descriptive/analysis_v2.0/`.)
-   **D07 --- Site robustness.** Leave-one-major-site-out analysis used
    five major sites. All 85 candidates were direction stable across all
    five LOO scenarios. This supports influence/site robustness but is
    not evidence of absence of site heterogeneity.
-   **D08 --- Locked-family Validation.** Validation was restricted to
    the exact D03 family after investigator authorization and protocol
    freeze. All 85 were estimable; 83/85 were direction concordant,
    29/85 met nominal direction-concordant replication, and 1/85 met
    candidate-family FDR-supported replication.
-   **D09 --- Missingness/detection/peptide evidence.** Detection
    evidence remained distinct from quantitative abundance inference.
    All 85 candidates reached ≥70% detection in every
    Discovery/Validation Dose stratum; 81/85 reached ≥80%. No approved
    unique-peptide source was found, so peptide support remains
    `SOURCE_NOT_AVAILABLE` for all 85.
-   **D10 --- Integrated evidence.** The final supportive master
    contains exactly 85 locked candidates and 67 columns, integrating
    D04 trajectory, D05 environment-specific Long-vs-Short evidence, D06
    interaction evidence, D07 site-robustness summaries, frozen D08
    Validation evidence, and D09 Dose detection/peptide status. D10 does
    not rank, filter, promote or redefine candidates. Pathway analysis
    for the frozen High-vs-Low contrast is complete under
    `descriptive/analysis_v2.0/M12_pathway_v2.1/` (cameraPR 205 primary / ORA 23
    complementary / fgsea 44&41 sensitivity / KEGG NOT_RUN); control-referenced
    pathway analysis lives in `control_referenced_pathways/`.

## Validation firewall and frozen replication definitions

Before D08, no module was permitted to read, summarize, rank or plot
Validation protein outcomes. D08 required both the hash-verified frozen
D03 list and investigator-created `VALIDATION_UNLOCKED.txt`.

The frozen primary Validation contrast is Long vs Short over all 85
locked candidates. Direction concordance requires the Validation and
Discovery log2FC to have the same direction. Nominal replication
requires direction concordance and Validation P\<0.05. FDR-supported
replication requires direction concordance and candidate-family
BH-FDR\<0.05, with BH across all 85 locked candidates. Non-estimable
candidates remain in the primary denominator; estimable-only rates are
companion summaries. Environment-specific Validation is secondary
characterization only.

Validation results cannot discover, promote or remove proteins.

## Interpretation of Validation

The principal Validation result is not "85 proteins were validated." The
evidence is layered:

-   83/85 showed the same Long-vs-Short direction in Validation.
-   29/85 met the prespecified nominal replication definition.
-   1/85 met the prespecified candidate-family FDR-supported replication
    definition.
-   Discovery-to-Validation effects were generally attenuated toward
    zero.
-   Protein-specific effect-size/rank concordance was weak despite
    strong family-level directional concordance.

Accordingly, reporting should distinguish family-level directional
reproducibility from multiplicity-controlled single-protein replication.

## Figure architecture

`code/figures_prospective.R` is a downstream visualization module, not
an analytical stage. It was designed to consume finalized CSVs without
refitting models or recalculating FDR. Because D01--D10 have now been
executed and D10 was revised into a 67-column integrated evidence
master, the figure code must be statically audited against the actual
finalized schemas before first execution.

Planned main figures remain conceptually: cohort/split/QC; Discovery
primary signal; candidate trajectories; Environment effects/interaction;
Discovery--Validation agreement; and integrated
abundance/detection/peptide evidence. Final figure selection must remain
source-backed and must not select proteins post hoc from visual
appearance.

## Output and reproducibility rules

Generated results belong under `D01_discovery_eligibility/` ...
`D10_integrated_biology/`. Code refuses silent overwrite and records
SHA-256 provenance manifests. Keys and terminology are fixed by
`DATA_CONTRACTS.md`. Missing estimates are `NA` with explicit
`NON_ESTIMABLE` status, never zero. Raw data and frozen outputs are
read-only.

Prohibited shortcuts include using historical 1,434 proteins for D01,
historical 256 DEPs for D03, inspecting Validation before unlock,
discovering in Validation, changing candidates through
Environment/interaction/site results, replacing the primary analysis
with imputation, rerandomizing the split, adding post-hoc effect
cutoffs, or selecting display proteins from visual appearance.

## Documentation reading order

1.  `F:/env/PROJECT_CONTEXT.md`
2.  `F:/env/descriptive/discovery_validation/README.md`
3.  `F:/env/descriptive/discovery_validation/PIPELINE_STATUS.md`
4.  `F:/env/descriptive/discovery_validation/DATA_CONTRACTS.md`
5.  `F:/env/descriptive/discovery_validation/WORKFLOW.md`
6.  `F:/env/docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md`
7.  `F:/env/docs/protocol/DISCOVERY_VALIDATION_SPLIT_SPEC.md`

## CURRENT STATE

``` text
Historical analysis-v1.0: FROZEN
Stage 13A: COMPLETED AND FROZEN
Discovery–Validation participant split: EXECUTED AND FROZEN (386 / 129)
D01–D10 analytical execution: COMPLETED
D01–D10 staged audit: COMPLETED / PASS
D03 candidate family: FROZEN (N=85)
Validation protocol: FROZEN BEFORE OUTCOME INSPECTION
Validation outcomes: ACCESSED ONLY AFTER AUTHORIZATION; D08 COMPLETED
D09 evidence layers: COMPLETED
D10 integrated master: COMPLETED (85 rows × 67 columns)
Pathway analysis: COMPLETE (M12 v2.1: cameraPR 205 / ORA 23 / fgsea 44&41 sensitivity / KEGG NOT_RUN)
Control-referenced pathways: COMPLETE (post-v2.1, Level-3 exploratory)
Environment-stratified discovery: COMPLETE (post-v2.1, Level-2 supplementary)
Unique-peptide support: SOURCE_NOT_AVAILABLE (deprecated; not active)
Git checkpoint / scientific HEAD: 8695ae6
NEXT ACTION: see docs/NEXT_STEPS.md (manuscript presentation sync; no analysis rerun).
```

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

