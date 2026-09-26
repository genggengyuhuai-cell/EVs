# Prospective pipeline status

**CURRENT AUTHORITY. All prospective analytical stages are NOT EXECUTED.** Static parsing is not analytical execution.

| Stage | Purpose | Code | Static review | Execution | Freeze | Blocking gate / next permitted action |
|---|---|---|---|---|---|---|
| D01 | Discovery-only 70% eligibility | implemented | reviewed | NOT EXECUTED | method frozen | investigator-authorized D01 |
| D02 | Discovery Long vs Short primary limma | implemented | reviewed | NOT EXECUTED | no outputs | reviewed D01 output |
| D03 | BH-FDR <0.05 candidate lock | implemented | reviewed | NOT EXECUTED | no lock yet | reviewed D02 diagnostics; then Git-freeze lock |
| D04 | Control–Short–Long trajectories | implemented | reviewed | NOT EXECUTED | no outputs | frozen D03 hash |
| D05 | Environment-stratified contrasts | implemented | reviewed | NOT EXECUTED | no outputs | D03 hash; secondary multiplicity approval |
| D06 | Dose × Environment interactions | implemented | reviewed | NOT EXECUTED | no outputs | D03 hash; interaction multiplicity approval |
| D07 | site summaries and leave-one-major-site-out | implemented | reviewed | NOT EXECUTED | no outputs | D03 hash |
| D08 | locked-family Validation | implemented | reviewed | NOT EXECUTED | no outputs | D03 hash **and** investigator-created unlock marker |
| D09 | missingness, detection, peptide evidence | implemented | reviewed | NOT EXECUTED | no outputs | reviewed D08 when Validation evidence is included |
| D10 | integrated biological evidence | implemented | reviewed | NOT EXECUTED | no outputs | finalized D03–D09 tables and pathway-source approval |

D01 has 28 explicit integrity assertions. D03 has 7 tabulated assertions. D02 and D04–D10 use shared fail-closed runtime assertions for hashes, keys, exact participant/protein universes, categorical values, rank, stage gates, no overwrite, and candidate-family preservation; these guards are not reported as runtime PASS before execution.

Current next action: investigator-authorized staged execution beginning with D01, followed by Gate 1 review. No stage may be inferred complete from code presence.
