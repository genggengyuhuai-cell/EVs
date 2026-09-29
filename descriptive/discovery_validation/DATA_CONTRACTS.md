# Discovery--Validation data contracts

Status: **CURRENT AUTHORITY --- D01--D10 executed and audited. Contracts
remain authoritative for downstream interpretation and figure
generation.**

Global keys are `UniqueSampleID` for participants and `PG.ProteinGroups`
for proteins. Internal Dose tokens are exactly `control`, `low`, `high`;
reporting labels are Control, Short, Long. Environment labels are
exactly `Humid-hot` and `High-pressure/high-altitude`. Missing numeric
results are empty CSV fields read as `NA`; failed contrasts retain rows
and use `Model_status = NON_ESTIMABLE`.

  -----------------------------------------------------------------------------------------------------------------------
  Producer       Canonical output                             Grain            Required downstream      Consumer
                                                                               columns / executed role  
  -------------- -------------------------------------------- ---------------- ------------------------ -----------------
  Frozen split   `discovery_validation_assignment.csv`        participant      `UniqueSampleID`,        D01--D09
                                                                               `TREAT1_clean`, `group`, 
                                                                               `Split`,                 
                                                                               `Protocol_version`       

  D01            `D01_discovery_eligible_expression.csv.gz`   protein ×        first column             D02, D04--D07,
                                                              Discovery        `PG.ProteinGroups`;      D09
                                                              participant      exactly 386 participant  
                                                                               columns                  

  D01            `D01_discovery_eligible_proteins.csv`        protein          canonical annotation     D02--D03
                                                                               plus dose detection      
                                                                               counts/rates             

  D02            `D02_Long_vs_Short_all_tested.csv`           D01 protein      key, contrast, log2FC,   D03, figures
                                                                               SE, CI, P, BH-FDR,       
                                                                               status                   

  D03            `D03_locked_candidates.csv`                  locked protein   D02 effects, annotation, D04--D10
                                                                               D01 detection fields,    
                                                                               direction; executed N=85 

  D03            `D03_candidate_lock_manifest.csv`            key/value        D01 hash, D02 hash,      D04--D10
                                                                               candidate hash, rule,    
                                                                               timestamp, code hash     

  D04            contrasts/means/trajectory                   candidate ×      estimates, intervals,    D10, figures
                                                              contrast or Dose P/FDR, `Trajectory`      

  D05            environment results                          candidate ×      estimates, intervals, P, D10, figures
                                                              Environment ×    secondary BH, status     
                                                              contrast                                  

  D06            interaction results                          candidate ×      estimate, CI, P,         D10, figures
                                                              interaction      separate secondary BH    
                                                                               family, status           

  D07            site summaries/LOO                           candidate ×      abundance/detection      D10, supplement
                                                              site/Dose or     summary, sign stability, 
                                                              removed site     delta effect, status     

  D08            Validation results                           locked candidate Validation               D09--D10, figures
                                                                               effect/CI/P/family BH,   
                                                                               Discovery effect,        
                                                                               replication hierarchy,   
                                                                               signed/absolute          
                                                                               difference               

  D09            evidence layers                              candidate ×      detection/missingness;   D10, figures
                                                              split × stratum  threshold attainment;    
                                                              plus             peptide source status    
                                                              peptide-status                            
                                                              table                                     

  D10            integrated evidence                          locked candidate executed 85-row,         interpretation,
                                                                               67-column source-backed  figures
                                                                               supportive master; no    
                                                                               candidate redefinition   
  -----------------------------------------------------------------------------------------------------------------------

Every stage verifies the frozen assignment hash and/or exact upstream
hashes. Candidate-focused stages verify the D03 candidate-list hash. D08
additionally required the investigator-created
`VALIDATION_UNLOCKED.txt`; no bypass is implemented. D10 rejects
candidate row expansion or loss.

## Executed contract checkpoints

-   Frozen split: 386 Discovery / 129 Validation.
-   D03 locked candidate family: N=85; SHA-256
    `14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2`.
-   D08 raw locked Validation matrix: 85 protein rows × 129 participant
    columns.
-   D09 peptide support status: `SOURCE_NOT_AVAILABLE` for all 85
    candidates because no approved source table was available.
-   D10 integrated candidate evidence: exactly 85 proteins × 67 columns.
-   D10 pathway membership: `NOT_RUN_NO_APPROVED_MAPPING` for all 85
    candidates unless an investigator-approved mapping/universe is
    supplied in a future explicitly authorized extension.

Downstream figures and interpretation must consume these finalized
outputs without refitting models, recalculating FDR, changing the
candidate universe, or inventing unavailable peptide/pathway evidence.

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

