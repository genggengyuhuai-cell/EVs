# Prospective Discovery-Validation Protocol

## Protocol declaration

> **Protocol frozen before participant assignment and before Validation outcomes are accessed.**

**Protocol status: SPLIT EXECUTED AND FROZEN.**

**Protocol identifier: `DiscoveryValidationProtocol_v1.0`.**

**Prospectively locked random seed: `20260925` (executed exactly once).**

The deterministic split implementation is frozen in
`DISCOVERY_VALIDATION_SPLIT_SPEC.md`. The participant assignment was generated exactly
once on 2026-09-26 at 01:09:30 PDT and is now frozen.

This protocol prospectively defines the Discovery-Validation design for the EV
proteomics project. It was created before any participant assignment was generated
and before any future Validation outcome was accessed. The seed was subsequently
selected prospectively in the pre-execution implementation specification.
It governs the prospective Discovery-Validation branch and does not reopen or modify
the frozen full-cohort reference analysis.

## 1. Study population and split unit

- The canonical eligible population contains 515 samples from 515 independent
  participants.
- The split unit is the participant.
- One and only one global Discovery/Validation assignment will be used.
- The same locked split will support the overall, Humid-hot, and
  High-pressure/high-altitude analyses.
- Separate Environment-specific splits will not be created.

## 2. Design structure

Environment and site are defined as follows:

```text
Humid-hot: FJ_FQ, FJ_PT, FJ_QZ, GZ_TH
High-pressure/high-altitude: XZ_GG, XZ_YA, XZ_YB, XZ_YC, XZ_YD
```

The variable `group` represents sampling site/location. Site is nested within
Environment. Site is not the primary validation holdout unit, and site-level analyses
are secondary robustness analyses. Acquisition and sample-processing dates must not
automatically be interpreted as independent mass-spectrometry (MS) batches.

## 3. Target split ratio and size

The prospectively selected target split is 75% Discovery and 25% Validation. For 515
participants, the fixed target sizes are:

```text
Discovery = 386
Validation = 129
```

These targets do not constitute an assignment. No participant assignment is generated
by this protocol.

## 4. Primary stratification and target allocation

The primary stratification variables are Environment × Dose, producing six strata.
The target allocation is fixed as follows:

| Environment | Dose | Total | Discovery | Validation |
|---|---:|---:|---:|---:|
| Humid-hot | Control | 95 | 71 | 24 |
| Humid-hot | Short | 83 | 62 | 21 |
| Humid-hot | Long | 101 | 76 | 25 |
| High-pressure/high-altitude | Control | 58 | 44 | 14 |
| High-pressure/high-altitude | Short | 103 | 77 | 26 |
| High-pressure/high-altitude | Long | 75 | 56 | 19 |
| **Total** |  | **515** | **386** | **129** |

Site is not a mandatory stratification variable. After the future split is generated,
site composition will be checked only as balance quality control. No post-hoc
reassignment is allowed merely to improve site balance unless a constrained procedure
is explicitly added to and frozen in this protocol before the split.

## 5. Primary Discovery contrast and candidate locking

The primary Discovery contrast is **Long vs Short**. Future candidate selection will
use only the Discovery participants and the Discovery-only eligible protein universe.
A protein enters the locked primary candidate set when its Discovery-only Long-vs-Short
test has Benjamini-Hochberg false discovery rate (BH-FDR) < 0.05.

Effect-size thresholds do not define primary candidate membership. The number of
future Discovery candidates is unknown and must remain unknown until the Discovery-only
analysis is run. It will not be forced to equal 256.

## 6. Supportive Control contrasts and trajectory characterization

Short vs Control and Long vs Control are locked as supportive trajectory contrasts.
They do not independently generate primary Validation candidates. They may characterize
Control -> Short -> Long behavior, including transient/recovery, partial attenuation,
persistent, progressive, delayed, or reversal patterns where supported by the future
Discovery analysis.

These contrasts will not enlarge the primary candidate family.

## 7. Discovery-only protein eligibility

Protein eligibility and filtering must be rebuilt using Discovery participants only.
Validation data must not determine protein eligibility, the quantitative-availability
threshold, the missingness threshold, the normalization choice, or candidate
membership.

The Discovery-only protein eligibility algorithm will reproduce the frozen primary
eligibility methodology exactly, with all eligibility thresholds and calculations
applied using Discovery participants only. No eligibility-method change will be
introduced for the prospective Discovery-Validation branch.

The historical full-cohort 1,434-protein universe must not be taken as a fixed list and
then subset after the split. Instead, the already-frozen protein-eligibility algorithm
must be re-executed using only the 386 Discovery participants. Validation participants
will not influence eligibility. The historical 1,434-protein universe remains a
reference benchmark, and the Discovery-only eligible protein count may differ from
1,434 because the same frozen algorithm is applied to a different participant set.
Eligibility thresholds must not be tuned after the split. No alternative filtering
rule may be chosen because it produces a more desirable number of eligible proteins or
candidates.

## 8. Primary confirmatory Validation question

The primary confirmatory question is: **Do Discovery-selected Long-vs-Short proteins
reproduce their Long-vs-Short effect in independent Validation participants?**

Primary Validation is restricted to the locked Discovery candidate set. No new
candidate discovery will be performed in Validation.

## 9. Mandatory protein-level replication evidence

For every locked Discovery candidate, reporting must include:

- Discovery log2 fold change (log2FC);
- Validation log2FC;
- direction concordance;
- Validation 95% confidence interval (CI);
- Validation raw P value;
- Validation BH-adjusted P value across the locked primary candidate family; and
- estimable or non-estimable status.

Where appropriate, reporting will also include the signed and absolute
Discovery-Validation effect differences, descriptive effect attenuation, detection
behavior, and missingness/sensitivity evidence. No weighted replication score will be
created.

## 10. Direction concordance

Direction concordance means that the Discovery and Validation Long-vs-Short log2FC
estimates have the same sign. A direction reversal is discordant. A Validation point
estimate exactly equal to zero is not directionally concordant.

No arbitrary near-zero numerical threshold is imposed. Near-zero same-sign effects
must be reported transparently through the actual effect estimate and CI and must not
be presented as strong replication solely because their signs match.

## 11. Statistical replication evidence hierarchy

Replication evidence is reported using the following locked hierarchy:

1. **Directional support:** Discovery and Validation log2FC have the same sign.
2. **Nominal statistical replication:** direction is concordant and the Validation
   raw P value is < 0.05.
3. **FDR-supported replication:** direction is concordant and the Validation BH-FDR
   is < 0.05 within the locked primary candidate family.

FDR-supported replication is a stronger subset of statistical replication, not a
separate candidate family. BH-FDR < 0.05 is not the sole definition of all replication,
and replication will not be defined by a P value without direction concordance.

## 12. Effect size and confidence interval

Discovery and Validation log2FC values must always be reported. A Validation 95% CI
must be reported for every estimable candidate. No arbitrary minimum absolute log2FC,
fixed Validation/Discovery effect ratio, or fixed percent-attenuation threshold is
imposed as a binary replication gate.

Many expected effects may be small, and ratios or percent attenuation are unstable
when the Discovery effect is near zero. Effect-size concordance therefore remains an
important reported evidence dimension rather than a hard binary criterion.

Where effect-difference reporting is used, the two descriptive quantities are:

```text
Effect_difference_signed
= Validation log2FC - Discovery log2FC

Effect_difference_absolute
= abs(Validation log2FC - Discovery log2FC)
```

The signed difference describes whether the Validation estimate is numerically
stronger, weaker, or shifted relative to Discovery. The absolute difference describes
the magnitude of disagreement between the two estimates regardless of direction. Both
quantities are descriptive and supportive. Neither has a numerical cutoff, and neither
is a binary replication gate. No effect-ratio or attenuation threshold is introduced.
CI overlap must not be interpreted as a formal test of effect equality.

## 13. Primary replication summary

For the locked primary candidate family, report at minimum:

- number of locked candidates;
- number estimable in Validation;
- number non-estimable;
- direction-concordant count and rate;
- nominal statistical replication count and rate;
- FDR-supported replication count and rate; and
- discordant count and rate.

The primary replication-rate denominator is `N_locked`, the complete Discovery-locked
primary Long-vs-Short candidate family. The following primary all-locked rates must be
reported:

```text
Direction_concordance_rate_all
= N_direction_concordant / N_locked

Nominal_replication_rate_all
= N_nominal_replicated / N_locked

FDR_supported_replication_rate_all
= N_FDR_supported / N_locked

Discordant_rate_all
= N_discordant / N_locked
```

Non-estimable candidates remain in `N_locked` and must not be silently removed from
these primary denominators.

The following secondary estimable-only companion rates must also be reported, with
`N_estimable` stated explicitly:

```text
Direction_concordance_rate_estimable
= N_direction_concordant / N_estimable

Nominal_replication_rate_estimable
= N_nominal_replicated / N_estimable

FDR_supported_replication_rate_estimable
= N_FDR_supported / N_estimable

Discordant_rate_estimable
= N_discordant / N_estimable
```

Both denominator views are mandatory: the primary view includes all locked candidates,
and the secondary companion view includes estimable candidates only. The existing
replication evidence hierarchy is unchanged.

## 14. Non-estimable Validation candidates

A Discovery candidate that cannot be reliably estimated in Validation will be labeled
**Non-estimable**. It will remain in candidate-family reporting and will not be
silently excluded. The numbers locked, estimable, and non-estimable must be stated.
The reason for non-estimability will be recorded where identifiable, such as
insufficient observed abundance or model-estimation failure. Non-estimable candidates
will not automatically be classified as directionally discordant. They cannot
contribute to direction-concordant, nominally replicated, FDR-supported, or discordant
numerators unless the corresponding effect is estimable.

## 15. Environment-specific Validation

Environment-specific Validation is a secondary analysis using the same global split.
Long-vs-Short effects will be evaluated separately within Humid-hot and
High-pressure/high-altitude participants. For each Environment, report where estimable:

- Discovery Environment-specific log2FC;
- Validation Environment-specific log2FC;
- direction;
- Validation 95% CI;
- nominal P value; and
- adjusted evidence if a multiplicity family is prospectively defined.

Environment-specific validation is not required for primary overall replication. A
protein is not called Environment-specific merely because it is significant in one
Environment and not significant in the other.

## 16. Dose × Environment interaction

Dose × Environment interaction is a secondary inferential heterogeneity question. Its
purpose is to test whether the dose effect differs between Environments. This question
is statistically distinct from within-Environment replication, and a difference in
significance status between Environments is not evidence of a significant interaction.

The exact interaction model and multiplicity family must be implemented prospectively
without using Validation outcomes to choose the method. No interaction analysis is
performed as part of this protocol-writing task.

## 17. Site robustness

Site-level analysis is secondary robustness analysis and not a primary confirmatory
Validation endpoint. Potential future analyses may include site-specific effect
estimates, leave-one-major-site-out sensitivity, forest plots, and heterogeneity
summaries. Small or structurally incomplete sites must not be forced into independent
three-Dose replication units.

## 18. Missingness and detection

The primary abundance analysis will continue to preserve `NA` under the frozen primary
methodology. Detection behavior and missingness sensitivity are distinct evidence and
robustness layers and must remain separate from the primary abundance model.

For Validation candidates, missing abundance must not be silently imputed in the
primary analysis. Estimability must be recorded, detection behavior should be
summarized, and any Validation missingness sensitivity analysis must be specified
consistently. Such sensitivity analysis cannot redefine primary candidate membership.

## 19. Multiplicity

For primary Validation, the multiplicity family is the Discovery-locked primary
Long-vs-Short candidate set tested in Validation. BH adjustment will be performed
across that locked family. The two supportive Control contrasts do not enlarge it.

Environment-specific and interaction multiplicity handling must be reported separately
and must not be silently merged with the primary family. Their exact secondary
multiplicity structures remain pending and must be prospectively fixed before the
corresponding secondary inferential analyses are executed.

## 20. Relationship to the frozen full-cohort reference

The existing analysis

```text
515 -> 1,434 -> 256
```

is the frozen **FULL-COHORT REFERENCE BENCHMARK**. Its canonical 256 Long-vs-Short
differentially expressed proteins (DEP) are not the future Discovery candidate set.
The future prospective branch is:

```text
515 eligible participants
-> locked 386/129 Discovery/Validation assignment
-> Discovery-only protein eligibility
-> Discovery-only modeling
-> Discovery-only candidate locking
-> Validation-only replication
```

The future Discovery candidate set must be regenerated using Discovery participants
only and is not required to reproduce the full-cohort 256. Validation participants
must not contribute to Discovery-only protein eligibility, filtering, model fitting,
candidate selection, threshold selection, or protocol modification.

The full-cohort 256 may later be compared descriptively with the Discovery candidates.
It must not be used to alter the split, alter candidate thresholds, rescue Discovery
candidates, add Validation candidates, or tune Validation-success criteria.

## 21. Prospective separation and access restrictions

Until the Discovery candidate set has been locked, Validation participants and their
outcomes remain unavailable for all Discovery decisions. Substantive statistical-design
review is complete. No further statistical-design changes are authorized before the
split except correction of a demonstrable documentation error.

## 22. Split-freeze procedure (documented, not executed)

The future split will be frozen through the following procedure:

1. The investigator reviews and approves this protocol.
2. Use the prospectively locked random seed `20260925`.
3. Implement and review the deterministic stratified assignment defined in
   `DISCOVERY_VALIDATION_SPLIT_SPEC.md`.
4. Exactly one assignment is generated.
5. Integrity checks confirm 515 participants exactly once, 386 Discovery participants,
   129 Validation participants, the exact Environment × Dose target counts, no
   duplicated participant IDs, and no missing participant IDs.
6. The assignment file is written.
7. The assignment file checksum/hash is recorded.
8. The split is committed, tagged, and frozen.
9. Discovery analysis begins.
10. Validation outcomes remain unused for candidate selection or protocol modification.

No rerandomization is allowed because a different random split produces more desirable
biological or statistical results.

This procedure was executed exactly once on 2026-09-26 at 01:09:30 PDT using the
prospectively locked seed. All 26 integrity assertions passed. No rerandomization was
performed.

## 23. Protocol status after split

**SPLIT EXECUTED AND FROZEN**

Substantive statistical-design review is complete, and the decisions below are frozen.
No statistical-design decision was changed during execution. The frozen assignment
contains 386 Discovery and 129 Validation participants.

### LOCKED

- 515 independent participants;
- participant-level split;
- one global split;
- 75/25 ratio;
- Discovery n = 386;
- Validation n = 129;
- Environment × Dose stratification;
- Long-vs-Short primary Discovery contrast;
- Discovery-only BH-FDR < 0.05 candidate rule;
- Control contrasts as supportive/trajectory contrasts only;
- overall Validation as primary;
- direction concordance definition;
- nominal replication definition;
- FDR-supported replication definition;
- Validation 95% CI reporting;
- no hard effect-size attenuation threshold;
- non-estimable reporting rule;
- Environment-specific Validation as secondary;
- Dose × Environment interaction as secondary inferential analysis;
- site as robustness; and
- the primary Validation multiplicity family.

### EXECUTION PROVENANCE

- Execution timestamp: `2026-09-26 01:09:30 PDT`
- Seed: `20260925`
- Discovery: 386
- Validation: 129
- Integrity: A01–A26 = 26 PASS / 0 FAIL
- Canonical input SHA-256: `aceb1e2cd1f2e73de8fb19badcd16c1b91e9be466aa4c3bfcf508806dc548487`
- Assignment SHA-256: `062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791`
- Assignment: `F:/env/descriptive/discovery_validation_split/discovery_validation_assignment.csv`
- Integrity report: `F:/env/descriptive/discovery_validation_split/split_integrity_assertions.csv`
- Manifest: `F:/env/descriptive/discovery_validation_split/split_manifest.txt`

### STILL PENDING BEFORE RELEVANT SECONDARY ANALYSIS

- exact multiplicity handling for Environment-specific secondary tests; and
- exact Dose × Environment interaction model and its multiplicity handling.

The pending secondary-analysis items do not block the primary participant split. No
split may be generated until the remaining pre-split implementation specifications
have been prospectively fixed.
