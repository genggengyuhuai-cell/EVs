# Discovery–Validation Split Implementation Specification

> **SPECIFICATION FROZEN BEFORE SPLIT EXECUTION.**
>
> **SPLIT EXECUTED EXACTLY ONCE AND FROZEN.**

## 1. Status and scope

- Protocol identifier: `DiscoveryValidationProtocol_v1.0`
- Prospective random seed: `20260925`
- Population: 515 independent participants
- Split unit: participant
- Global target: Discovery = 386; Validation = 129
- Primary stratification: Environment × Dose
- Site is not a stratification variable.

This document prospectively defined the exactly-once deterministic assignment. The
frozen procedure was executed exactly once on 2026-09-26 at 01:09:30 PDT. The seed is
a reproducibility identifier and was not optimized, compared with alternative seeds,
or evaluated against site balance, protein data, missingness, detection, candidate
counts, differential-expression results, or biological outcomes.

## 2. Canonical input authority

The sole participant eligibility/metadata authority for the future split is:

```text
F:/env/descriptive/dose_defined_metadata.csv
```

Exact source columns and their roles are:

| Role | Canonical column | Authorized source values | Specification label |
|---|---|---|---|
| Participant identifier | `UniqueSampleID` | 515 non-missing unique ASCII identifiers | unchanged |
| Environment | `condition` | `湿热`, `高海拔` | `Humid-hot`, `High-pressure/high-altitude` |
| Dose | `TREAT1_clean` | `control`, `low`, `high` | `Control`, `Short`, `Long` |
| Site/location | `group` | `FJ_FQ`, `FJ_PT`, `FJ_QZ`, `GZ_TH`, `XZ_GG`, `XZ_YA`, `XZ_YB`, `XZ_YC`, `XZ_YD` | unchanged |

The mappings above are fixed, one-to-one label translations; they are not inferred
from outcomes. In the future assignment file, the canonical repository column names
are retained and their values remain byte-for-byte equal to the authority file.
`Stratum` supplies the human-readable specification label.

Evidence for authority status is that this is the Stage 05 primary
dose-defined metadata output, excluding only the four samples without an authorized
control/low/high dose and otherwise excluding no sample at that step. It is the direct
metadata input to the frozen primary limma analysis and multiple validated downstream
modules. Read-only inspection found exactly 515 rows, 515 unique non-missing
`UniqueSampleID` values, Dose totals 153/186/176, Environment totals 279/236, and the
six Environment × Dose totals 95/83/101/58/103/75 in the order fixed below.
QC and detection metadata files containing the same participants are downstream
derivatives and are not alternative authorities. The authority file must not be
modified for split generation.

## 3. Fixed strata, order, and targets

The six authorized `Stratum` values, processing order, source-value mappings, and
targets are exactly:

| Order | `condition` | `TREAT1_clean` | `Stratum` | Total | Discovery | Validation |
|---:|---|---|---|---:|---:|---:|
| 1 | `湿热` | `control` | `Humid-hot / Control` | 95 | 71 | 24 |
| 2 | `湿热` | `low` | `Humid-hot / Short` | 83 | 62 | 21 |
| 3 | `湿热` | `high` | `Humid-hot / Long` | 101 | 76 | 25 |
| 4 | `高海拔` | `control` | `High-pressure/high-altitude / Control` | 58 | 44 | 14 |
| 5 | `高海拔` | `low` | `High-pressure/high-altitude / Short` | 103 | 77 | 26 |
| 6 | `高海拔` | `high` | `High-pressure/high-altitude / Long` | 75 | 56 | 19 |
|  |  |  | **Total** | **515** | **386** | **129** |

## 4. Exact deterministic assignment algorithm

The future implementation must use R and the following frozen semantics:

### Locale-independent implementation clarification

The canonical `condition` column remains the authoritative Environment metadata and
must be preserved unchanged in the future assignment output. Because the execution
host may be unable to establish a UTF-8 locale, internal validation and stratification
use the already-frozen site-to-Environment relationship as an encoding-safe bridge:
`FJ_FQ`, `FJ_PT`, `FJ_QZ`, and `GZ_TH` map to ASCII key `HumidHot`; `XZ_GG`, `XZ_YA`,
`XZ_YB`, `XZ_YC`, and `XZ_YD` map to ASCII key `HighPressure`. Combined with the
fixed Dose mapping, the six internal keys are `HumidHot_Control`, `HumidHot_Short`,
`HumidHot_Long`, `HighPressure_Control`, `HighPressure_Short`, and
`HighPressure_Long`.

The original `condition` is not ignored. Its exact UTF-8 bytes must agree with the
Environment implied by `group`: `湿热` is hexadecimal UTF-8 `e6b9bfe783ad`, and
`高海拔` is `e9ab98e6b5b7e68b94`. An unexpected site, a missing or ambiguous mapping,
a byte-level `condition` disagreement, or an incorrect six-stratum count must fail
before RNG initialization. These ASCII keys are internal only and do not redefine
Environment or change any statistical-design decision.

The initial execution attempt stopped before RNG initialization because direct
Chinese-label comparison was not reliable when the host failed to establish its
requested UTF-8 locale. That attempt made zero `set.seed()` calls, zero `sample()`
calls, generated zero random numbers and zero participant assignments, and created no
split outputs. The split was subsequently executed once under separate authorization;
that failed pre-randomization attempt did not consume the authorized RNG execution.

1. Read the canonical authority once without altering strings, trimming identifiers,
   coercing identifiers to factors, or changing source values.
2. Evaluate input assertions A01–A09. Stop before RNG initialization if any fails.
3. Map `condition` and `TREAT1_clean` through the fixed table in Section 3 to construct
   `Stratum`. Each row must map to exactly one authorized stratum.
4. Within each stratum, order rows by `UniqueSampleID` in ascending raw UTF-8 byte
   lexicographic order. All current identifiers are ASCII, so this is equivalently
   ascending ASCII order. The implementation must use a locale-independent comparison
   and must not rely on incoming row order.
5. Initialize the R RNG exactly once for the entire run, immediately before the first
   permutation, with integer seed `20260925`. Use R RNG kind `Mersenne-Twister`,
   normal kind `Inversion`, and `sample.kind = "Rejection"`.
6. Process the six strata once in the exact order in Section 3. For each ordered
   stratum vector, call base R `sample(x, size = length(x), replace = FALSE)` exactly
   once to obtain one permutation. No other RNG-consuming operation may occur between
   RNG initialization and completion of all six permutations.
7. Assign the first stratum-specific Validation target in the permutation to
   `Validation`; assign every remaining identifier in that stratum to `Discovery`.
8. Rejoin the assignment to the canonical metadata by exact `UniqueSampleID`, preserve
   canonical metadata values, and write rows in ascending Section 3 stratum order and,
   within stratum, ascending `UniqueSampleID` order. Output row order has no effect on
   membership.
9. Evaluate A10–A26. Any failure stops the freeze procedure.

The implementation compatibility contract is base R's documented
`RNGkind("Mersenne-Twister", "Inversion", "Rejection")`, `set.seed(20260925)`, and
`sample(..., replace = FALSE)` semantics as available in R 3.6.0 or later. The exact R
version used must be recorded in the manifest. A second implementation must reproduce
the same ordered inputs, the same single RNG stream, the same six calls, and the same
membership. There is no rerandomization and no adjustment for site balance, protein
abundance, missingness, detection, candidate count, DE results, biological outcomes,
or any other post-assignment characteristic.

## 5. Future assignment file schema

The future `discovery_validation_assignment.csv` must be UTF-8 CSV with one header and
exactly one row per participant. It must contain these columns in this order:

| Column | Type | Nullable | Constraint |
|---|---|---:|---|
| `UniqueSampleID` | character | No | Exact canonical participant ID; unique |
| `condition` | character | No | Exact authority value: `湿热` or `高海拔` |
| `TREAT1_clean` | character | No | Exact authority value: `control`, `low`, or `high` |
| `group` | character | No | Exact authority site/location value |
| `Stratum` | character | No | Exactly one of the six values in Section 3 |
| `Split` | character | No | Exactly `Discovery` or `Validation` |
| `Seed` | integer | No | Exactly `20260925` on every row |
| `Protocol_version` | character | No | Exactly `DiscoveryValidationProtocol_v1.0` on every row |

Empty strings count as missing. CSV readers must preserve `UniqueSampleID`, `condition`,
`TREAT1_clean`, `group`, `Stratum`, `Split`, and `Protocol_version` as character data
and `Seed` as an integer.

## 6. Integrity assertions

Exactly 26 required assertions must be reported individually as PASS or FAIL:

| ID | PASS condition |
|---|---|
| A01 | Input row count equals 515. |
| A02 | Count of unique `UniqueSampleID` values equals 515. |
| A03 | Missing or empty `UniqueSampleID` count equals 0. |
| A04 | Missing or empty `condition` count equals 0. |
| A05 | Missing or empty `TREAT1_clean` count equals 0. |
| A06 | Every `condition` value is exactly `湿热` or `高海拔`. |
| A07 | Every `TREAT1_clean` value is exactly `control`, `low`, or `high`. |
| A08 | Every participant maps to exactly one authorized `Stratum`. |
| A09 | Ordered six-stratum input counts equal 95, 83, 101, 58, 103, 75. |
| A10 | Assignment row count equals 515. |
| A11 | Count of unique assigned `UniqueSampleID` values equals 515. |
| A12 | `Split == "Discovery"` count equals 386. |
| A13 | `Split == "Validation"` count equals 129. |
| A14 | `Humid-hot / Control`: Discovery 71 and Validation 24. |
| A15 | `Humid-hot / Short`: Discovery 62 and Validation 21. |
| A16 | `Humid-hot / Long`: Discovery 76 and Validation 25. |
| A17 | `High-pressure/high-altitude / Control`: Discovery 44 and Validation 14. |
| A18 | `High-pressure/high-altitude / Short`: Discovery 77 and Validation 26. |
| A19 | `High-pressure/high-altitude / Long`: Discovery 56 and Validation 19. |
| A20 | Missing or empty `Split` count equals 0. |
| A21 | Every `Split` value is exactly `Discovery` or `Validation`. |
| A22 | Every canonical input participant occurs exactly once in the assignment. |
| A23 | No assignment participant is outside the canonical input. |
| A24 | Every `Seed` value is the integer 20260925. |
| A25 | Every `Protocol_version` is exactly `DiscoveryValidationProtocol_v1.0`. |
| A26 | For each `UniqueSampleID`, `condition`, `TREAT1_clean`, and `group` agree exactly with the canonical authority. |

All 26 assertions must PASS before freezing. If any assertion fails, stop; report
diagnostics where possible; do not rerandomize, automatically repair, or generate a
replacement assignment. Investigator review is required.

## 7. Future outputs (defined, not created)

The dedicated future directory is:

```text
F:/env/descriptive/discovery_validation_split/
```

The exact future files are:

```text
F:/env/descriptive/discovery_validation_split/discovery_validation_assignment.csv
F:/env/descriptive/discovery_validation_split/split_integrity_assertions.csv
F:/env/descriptive/discovery_validation_split/split_manifest.txt
```

`split_integrity_assertions.csv` will contain one row per assertion with at least
`Assertion_ID`, `Description`, `Observed`, `Expected`, and `Status` fields.
`split_manifest.txt` will record protocol version, seed, canonical input path,
algorithm and fixed stratum order, row and stratum counts, creation timestamp with
time zone, R/software version, RNG kind, normal kind, sample kind, permutation
function, assignment-file SHA-256, and canonical-input SHA-256 when feasible.

## 8. Future exactly-once freeze procedure

After separately authorized generation:

1. Generate the six permutations and participant memberships exactly once.
2. Run A01–A26 and require 26/26 PASS.
3. Write the assignment CSV and integrity report to the paths in Section 7.
4. Compute the SHA-256 of the bytes of the completed assignment CSV.
5. Compute the SHA-256 of the canonical authority file if feasible.
6. Write the manifest, including hashes and all required execution metadata.
7. Review exact Git status and diff to verify only intended files changed.
8. Commit the protocol/specification, assignment, integrity report, and manifest.
9. Create an annotated Git tag identifying the frozen split.

The future execution authorization may select the commit message and tag name. No
commit or tag is selected or created here.

## 9. Descriptive site-balance QC

Only after the assignment is frozen, report `group × Split` counts and
`group × TREAT1_clean × Split` counts. These are descriptive QC summaries only. They
must not trigger rerandomization, reassignment, seed changes, or alteration of the
frozen targets. They are not calculated in this specification task.

## 10. Frozen execution record and boundary

- Status: **SPLIT EXECUTED AND FROZEN**
- Execution timestamp: `2026-09-26 01:09:30 PDT`
- Seed: `20260925`
- R: `R version 4.3.1 (2023-06-16 ucrt)`
- RNG: `Mersenne-Twister` / `Inversion` / `Rejection`
- RNG initialization: one `set.seed()` call
- Permutations: six `sample()` calls, one per frozen stratum
- Assignment: 515 total; 386 Discovery; 129 Validation
- Integrity: A01–A26 = 26 PASS / 0 FAIL
- Canonical input SHA-256: `aceb1e2cd1f2e73de8fb19badcd16c1b91e9be466aa4c3bfcf508806dc548487`
- Assignment SHA-256: `062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791`
- Assignment: `F:/env/descriptive/discovery_validation_split/discovery_validation_assignment.csv`
- Integrity report: `F:/env/descriptive/discovery_validation_split/split_integrity_assertions.csv`
- Manifest: `F:/env/descriptive/discovery_validation_split/split_manifest.txt`

No rerandomization, reassignment, alternative-seed testing, or post-QC optimization is
permitted. Discovery analysis requires separate authorization. No Git commit or tag
was created during split execution.
