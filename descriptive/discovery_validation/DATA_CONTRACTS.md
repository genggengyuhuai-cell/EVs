# Prospective data contracts

Status: **CURRENT AUTHORITY — implemented, statically reviewed, not executed**.

Global keys are `UniqueSampleID` for participants and `PG.ProteinGroups` for proteins. Internal Dose tokens are exactly `control`, `low`, `high`; reporting labels are Control, Short, Long. Environment labels are exactly `Humid-hot` and `High-pressure/high-altitude`. Missing numeric results are empty CSV fields read as `NA`; failed contrasts retain rows and use `Model_status = NON_ESTIMABLE`.

| Producer | Canonical output | Grain | Required downstream columns | Consumer |
|---|---|---|---|---|
| Frozen split | `discovery_validation_assignment.csv` | participant | `UniqueSampleID`, `TREAT1_clean`, `group`, `Split`, `Protocol_version` | D01–D09 |
| D01 | `D01_discovery_eligible_expression.csv.gz` | protein × Discovery participant | first column `PG.ProteinGroups`; exactly 386 participant columns | D02, D04–D07, D09 |
| D01 | `D01_discovery_eligible_proteins.csv` | protein | canonical annotation plus dose detection counts/rates | D02–D03 |
| D02 | `D02_Long_vs_Short_all_tested.csv` | D01 protein | key, contrast, log2FC, SE, CI, P, BH-FDR, status | D03, figures |
| D03 | `D03_locked_candidates.csv` | locked protein | D02 effects, annotation, D01 detection fields, direction | D04–D10 |
| D03 | `D03_candidate_lock_manifest.csv` | key/value | D01 hash, D02 hash, candidate hash, rule, timestamp, code hash | D04–D10 |
| D04 | contrasts/means/trajectory | candidate × contrast or Dose | estimates, intervals, P/FDR, `Trajectory` | D10, figures |
| D05 | environment results | candidate × Environment × contrast | n support, estimates, intervals, P, secondary BH, status | D10, figures |
| D06 | interaction results | candidate × interaction | estimate, CI, P, separate BH family, status | D10, figures |
| D07 | site summaries/LOO | candidate × site/Dose or removed site | n, abundance/detection summary, sign stability, delta effect, status | D10, supplement |
| D08 | Validation results | locked candidate | Validation effect/CI/P/family BH, Discovery effect, replication hierarchy, signed/absolute difference | D09–D10, figures |
| D09 | evidence layers | candidate × split × stratum | detection/missingness; peptide source status | D10, figures |
| D10 | integrated evidence | locked candidate | joined, source-backed evidence only | interpretation, figures |

Every stage verifies the frozen assignment hash and/or exact upstream hashes. Candidate-focused stages verify the D03 candidate-list hash. D08 additionally requires the investigator-created `VALIDATION_UNLOCKED.txt`; no bypass is implemented. D10 rejects candidate row expansion or loss.
