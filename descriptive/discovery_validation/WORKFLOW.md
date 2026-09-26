# Discovery--Validation workflow and gates

Status: **CURRENT AUTHORITY --- D01--D10 executed and audited; Gate
1--Gate 8 completed.**

``` text
RAW PROTEOMICS -> 515 CANONICAL PARTICIPANTS
        |
        +---- HISTORICAL REFERENCE: 1,434 -> DE -> 256 -> Stage 13A (FROZEN)
        |
        v
FROZEN 75/25 ASSIGNMENT (386 Discovery / 129 Validation)
        |
        +--> Discovery: D01 -> [Gate 1 PASS] -> D02 -> [Gate 2 PASS] -> D03 LOCK -> [Gate 3 PASS]
        |                                                           |
        |                                                           +--> D04 trajectory --+
        |                                                           +--> D05 environment -+
        |                                                           +--> D06 interaction -+--> [Gate 4 PASS]
        |                                                           +--> D07 site --------+
        |                                                                                 |
        +--> Validation outcomes protected until protocol authorization                  |
                                                                                          v
                                                              [Gate 5 AUTHORIZED / eb3de2f]
                                                                                          |
                                                                                          v
                                                    D03 exact locked family + Validation -> D08
                                                                                          |
                                                                                   [Gate 6 PASS]
                                                                                          v
                                                        D01/D03/reviewed D08 -> D09 -> [Gate 7 PASS]
                                                                                          v
                                                             D03–D09 evidence -> D10 -> [Gate 8 PASS]
                                                                                          |
                                                                                          v
                                                                     85-row evidence master
```

The driver accepts exactly one `--stage D01` ... `--stage D10`; it never
chains stages. D08 never follows D03 automatically and has no bypass
flag.

## Completed review gates

1.  **Gate 1 --- PASS:** D01 Discovery protein universe, detection
    diagnostics and integrity assertions reviewed. Discovery n=386;
    1,445 proteins entered D02.
2.  **Gate 2 --- PASS:** D02 design/model output reviewed. Primary model
    was `abundance ~ dose + environment`; primary contrast Long vs
    Short; 1,445 estimable proteins; 85 BH-FDR\<0.05.
3.  **Gate 3 --- PASS/FROZEN:** D03 locked exactly those 85 Discovery
    Long-vs-Short BH-FDR\<0.05 candidates. Candidate-list SHA-256:
    `14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2`.
4.  **Gate 4 --- PASS:** D04--D07 reviewed as supportive Discovery
    analyses. None could add or drop candidates. D06 found no
    secondary-FDR-supported interaction among the 85 candidates; D07
    showed direction stability across all five major-site LOO scenarios
    for all 85 candidates.
5.  **Gate 5 --- AUTHORIZED:** `VALIDATION_UNLOCKED.txt` was
    investigator-created after candidate locking and Discovery
    characterization, with replication rules fixed before Validation
    outcome inspection. Protocol commit: `eb3de2f`.
6.  **Gate 6 --- PASS:** D08 reviewed. Validation n=129; 85/85
    estimable; 83/85 direction concordant; 29/85 nominal replication;
    1/85 FDR-supported replication. Environment-specific Validation
    remained secondary.
7.  **Gate 7 --- PASS:** D09 reviewed. Detection evidence was retained
    separately from abundance inference. All 85 candidates reached ≥70%
    detection in every Discovery/Validation Dose stratum; 81/85 reached
    ≥80%. Unique-peptide source was unavailable and remained
    `SOURCE_NOT_AVAILABLE`.
8.  **Gate 8 --- PASS:** D10 reviewed. Final integrated evidence master
    contains exactly 85 locked proteins and 67 columns. It integrates
    supportive D04--D09 evidence without candidate redefinition. Pathway
    analysis remains not run without an approved mapping/universe.

## Design feasibility and limitations

All six Environment × Dose cells are nonempty in both splits, supporting
the predeclared overall, stratified and interaction designs. Sites are
nested within Environment and imbalanced. XZ_YB has control only;
several site × Dose cells are absent or contain one participant.
Site-specific three-dose models were therefore not required. D07 used
descriptive site summaries and leave-one-major-site-out overall models.

Acquisition/processing dates align with some sites and cannot always be
separated from site effects; they are not automatically independent MS
batches. Secondary subgroup analyses have smaller n and should not be
interpreted as replacements for the primary overall contrast.

D05 differences in the number of significant environment-specific
results do not themselves establish environment interaction. Formal
interaction was tested in D06, where no candidate reached secondary
BH-FDR\<0.05 for the three interaction contrasts.

Validation evidence must retain its hierarchy. Family-level directional
concordance was high, but protein-specific effect-size/rank concordance
was weak and only one candidate met multiplicity-controlled
FDR-supported replication. Do not state that all 85 proteins were
validated.

Unique-peptide support is unavailable in the currently traced project
sources and remains `SOURCE_NOT_AVAILABLE` unless an approved source
table is supplied.

## Freeze and provenance

Seed `20260925`; assignment SHA-256
`062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791`;
split commit `86a29ce1b7bff68b57f7c039397d48dd577d2ef3`; tag
`discovery-validation-split-v1.0`.

D03 candidate SHA-256:
`14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2`.

Validation protocol commit: `eb3de2f`.

D10 execution/audit checkpoint: `d46aee3`.

Stages record input/output hashes and refuse silent overwrite. No
rerandomization, hidden candidate expansion, Validation-driven tuning,
post-hoc effect cutoff, or candidate redefinition is permitted.

## Next workflow action

The analytical stage sequence ends at D10. `figures_prospective.R` is a
downstream visualization module, not D11. It must be statically audited
against the executed output schemas before first figure generation.
Figures may summarize finalized evidence but may not refit models,
recalculate multiplicity, or redefine/select candidates.
