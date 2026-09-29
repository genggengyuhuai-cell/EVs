# Discovery--Validation pipeline status

**CURRENT AUTHORITY --- D01--D10 analytical execution and staged audit
completed through Git checkpoint `d46aee3`.**

  --------------------------------------------------------------------------------------------------------------------------------------------
  Stage          Purpose                    Execution      Audit / freeze Key result
                                                           status         
  -------------- -------------------------- -------------- -------------- --------------------------------------------------------------------
  D01            Discovery-only 70%         EXECUTED       PASS           Discovery n=386; 1,445 eligible proteins; no imputation
                 eligibility                                              

  D02            Discovery Long vs Short    EXECUTED       PASS           1,445/1,445 estimable; 365 raw P\<0.05; 85 BH-FDR\<0.05
                 primary limma                                            

  D03            BH-FDR\<0.05 candidate     EXECUTED       FROZEN         85 locked candidates; all Higher_in_Short; candidate SHA-256
                 lock                                                     `14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2`

  D04            Control--Short--Long       EXECUTED       PASS /         75 Reversal_after_short_increase; 6 Transient_short_peak; 4
                 trajectories                              supportive     Delayed_decrease

  D05            Environment-stratified     EXECUTED       PASS /         Environment-specific Discovery characterization completed
                 contrasts                                 supportive     

  D06            Dose × Environment         EXECUTED       PASS /         Secondary BH-FDR\<0.05: 0/85 for all three interaction contrasts
                 interactions                              supportive     

  D07            Leave-one-major-site-out   EXECUTED       PASS /         5 major-site LOO scenarios per candidate; 85/85 direction stable
                 robustness                                supportive     

  D08            Locked-family Validation   EXECUTED       PASS / frozen  85/85 estimable; 83/85 direction concordant; 29/85 nominal
                                                           protocol       replication; 1/85 FDR-supported replication

  D09            Missingness, detection,    EXECUTED       PASS /         85/85 reach ≥70% detection in every Discovery/Validation Dose
                 peptide evidence                          supportive     stratum; 81/85 reach ≥80%; peptide source unavailable

  D10            Integrated biological      EXECUTED       PASS           85-row, 67-column supportive evidence master; no candidate
                 evidence                                                 redefinition; pathway work not run without approved mapping
  --------------------------------------------------------------------------------------------------------------------------------------------

## Validation protocol

Validation access was authorized only after D03 locking and D04--D07
Discovery characterization were complete. The prespecified primary
Validation contrast is Long vs Short over all 85 locked candidates.
Nominal replication requires direction concordance and Validation
P\<0.05; FDR-supported replication requires direction concordance and
candidate-family BH-FDR\<0.05, with BH applied across all 85 locked
candidates. Non-estimable candidates remain in the primary denominator.
Environment-specific Validation is secondary characterization only.

The Validation protocol was committed before outcome inspection as
`eb3de2f` (`protocol: authorize locked-candidate validation`).

## D08 interpretation

The independent Validation split contains 129 participants. Of the 85
locked candidates, 83 were directionally concordant, 29 met the
prespecified nominal replication definition, and 1 met the
candidate-family FDR-supported replication definition.

Discovery-to-Validation effects show strong family-level directional
concordance but weak protein-specific effect-size/rank concordance and
limited multiplicity-controlled single-protein replication. The
85-protein family must not be described as 85 individually validated
proteins.

Environment-specific Validation is secondary only. Humid-hot: 83
negative and 2 positive Long-vs-Short effects, 14 raw P\<0.05 and 0
BH-FDR\<0.05. High-pressure/high-altitude: 78 negative and 7 positive
effects, 11 raw P\<0.05 and 0 BH-FDR\<0.05.

## D09--D10 evidence status

D09 keeps quantitative missingness/detection and peptide evidence
distinct. Unique-peptide support is not available in the currently
traced project sources and is recorded as `SOURCE_NOT_AVAILABLE` for all
85 candidates; it is not inferred or fabricated.

D10 integrates D04 trajectory, D05 environment-specific Long-vs-Short
evidence, D06 interaction evidence, D07 site-robustness summaries,
frozen D08 Validation evidence, and D09 Dose detection/peptide status
into the exact D03 locked universe. D10 performs no filtering, ranking,
candidate promotion, or candidate redefinition.

Pathway analysis remains `NOT_RUN_NO_APPROVED_MAPPING` for all 85
candidates because no investigator-approved pathway mapping/universe has
been supplied.

## Current Git checkpoint

``` text
d46aee3 analysis: integrate and audit D10 candidate evidence
44847df analysis: execute and audit D09 evidence layers
4135364 analysis: execute and audit D08 locked-candidate validation
eb3de2f protocol: authorize locked-candidate validation
59599da analysis: execute and audit D07 site robustness
db72e65 analysis: execute and audit D06 environment interaction
```

At the last confirmed checkpoint, `git status --short` was clean.

## Next permitted action

D01--D10 are complete. Do not create a D11 analytical stage by
inference. Before generating final figures, statically audit
`code/figures_prospective.R` against the executed D01--D10 output
schemas, especially the revised 67-column D10 master. Figure generation
must consume finalized outputs only and must not refit models,
recalculate FDR, alter candidates, or select proteins post hoc from
visual appearance.

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

