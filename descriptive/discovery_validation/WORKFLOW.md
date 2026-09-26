# Prospective workflow and gates

Status: **CURRENT AUTHORITY — code complete, static review complete, analytical execution not started**.

```text
RAW PROTEOMICS -> 515 CANONICAL PARTICIPANTS
        |
        +---- HISTORICAL REFERENCE: 1,434 -> DE -> 256 -> Stage 13A (FROZEN)
        |
        v
FROZEN 75/25 ASSIGNMENT (386 Discovery / 129 Validation)
        |
        +--> Discovery: D01 -> [Gate 1] -> D02 -> [Gate 2] -> D03 lock -> [Gate 3]
        |                                            |
        |                                            +--> D04 trajectory --+
        |                                            +--> D05 environment -+
        |                                            +--> D06 interaction -+--> [Gate 4]
        |                                            +--> D07 site --------+
        |                                                                  |
        +--> Validation (outcomes inaccessible)                            |
                                                                           v
                                                        [Gate 5 investigator unlock]
                                                                           |
                                                                           v
                                            D03 exact locked family + Validation -> D08
                                                                           |
                                                                    [Gate 6 review]
                                                                           v
                                          D01/D03/(reviewed D08) -> D09 -> [Gate 7]
                                                                           v
                                                     D02–D09 evidence -> D10 -> [Gate 8]
```

The driver accepts exactly one `--stage D01` … `--stage D10`; it never chains stages. D08 never follows D03 automatically and has no bypass flag.

## Review gates

1. Review D01 protein universe, detection diagnostics and integrity assertions.
2. Review D02 design rank, residual degrees of freedom, missingness, model and QC diagnostics.
3. Review D03 rule and manifest, then freeze the candidate CSV and hash in Git.
4. Review D04–D07 as supportive Discovery analyses. They cannot add/drop candidates.
5. Create `VALIDATION_UNLOCKED.txt` only after explicit investigator authorization.
6. Review D08 estimability, both denominators, replication hierarchy and subgroup limitations.
7. Review D09 missingness/detection and actual peptide-source availability.
8. Review D10 evidence integration and biological claims; keep association distinct from causation.

## Design feasibility and limitations

All six Environment × Dose cells are nonempty in both splits, supporting the predeclared overall, stratified and interaction designs. Sites are nested within Environment and imbalanced. XZ_YB has control only; several site × Dose cells are absent or contain one participant. Site-specific three-dose models are therefore not required. D07 uses descriptive site summaries and leave-one-major-site-out overall models, returning `NON_ESTIMABLE` when rank or exposure representation fails.

Acquisition/processing dates align with some sites and cannot always be separated from site effects. They are not automatically independent MS batches. Secondary subgroup analyses have smaller n, more missingness and possible non-estimability. Unique-peptide support is unavailable in the currently traced project sources and remains `SOURCE_NOT_AVAILABLE` unless an approved table is supplied. Exact Environment-specific and interaction multiplicity families require investigator approval before those stages run; the implementation keeps BH families separate by Environment/contrast or interaction contrast.

## Freeze and provenance

Seed `20260925`; assignment SHA-256 `062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791`; split commit `86a29ce1b7bff68b57f7c039397d48dd577d2ef3`; tag `discovery-validation-split-v1.0`. Stages write input/output hashes and refuse silent overwrite. No rerandomization, hidden candidate expansion or Validation-driven tuning is permitted.
