# Project context

## Permanent identity architecture

```text
PG.ProteinGroups = stable analytical identity/key
Gene_symbol      = canonical biological gene annotation
Display_label    = final human-readable individual-protein figure label
```

All final figures containing individual protein labels display Gene symbol whenever
available. Missing symbols fall back to the stable protein-group identifier and never
exclude proteins. Duplicate gene symbols do not replace the analytical key.

The authoritative starting point is the two raw workbooks plus source code. Tables,
models, reports and figures are regenerable artifacts rather than source-of-truth.
An owning stage may deterministically replace its own generated outputs at the
canonical path during a rerun. It must not clean outputs owned by another stage.

Stages 01–05 establish descriptive, abundance and binary-detection mother data. Stage
06 is covariate QC; Stage 07 is locked limma. Stages 08a/b/c are abundance branches;
08d integrates required abundance products with the separate Stage 09 detection branch.
Stages 10a/b summarize Stage 07 DEPs. Stages 11a/b are descriptive pattern/clustering
branches and Stage 12 deterministically annotates Stage 11a.

Stage 11a is the canonical rule-based classification: 249 `Short_peak` and 7
`Long_suppression` proteins from a 256-protein DEP universe. Stage 11b is exploratory
unsupervised response-profile clustering. It uses observed Control, Short, and Long
group means, then protein-wise z-scores the three-group profile. It does not impute
sample-level missing values or convert primary `NA` values to zero. The validated
hierarchical clusters are C1=130, C2=96, C3=7, and C4=23. K-means K=2–6 is a
sensitivity analysis only and does not establish an optimal biological K.

## Locked core invariants

```text
Raw protein groups = 3817
Raw samples = 519
Gene_symbol mapped = 3810
Gene_symbol fallback/unmapped = 7
Dose-defined samples = 515
Primary quantitative proteins = 1434
Primary threshold = >=70% detection in EACH exposure group
Primary residual missingness ≈ 6.29%
Primary missing values retained as NA
Primary imputation = NONE
Primary NA -> 0 = NO
Primary abundance input = log2 only
Median normalization = sensitivity only
DEP universe = 256
Stage 11a: Short_peak = 249; Long_suppression = 7
Stage 11b: exploratory unsupervised response-profile clustering
Stage 11b matrix = 256 × 3 observed group means
Stage 11b sample-level imputation = NONE
Stage 11b: C1 = 130; C2 = 96; C3 = 7; C4 = 23
Stage 11a × Stage 11b: Long_suppression -> C3 = 7/7
Stage 11a × Stage 11b: Short_peak -> C1/C2/C4 = 130/96/23
Post-freeze missingness / imputation robustness analysis = COMPLETED
```

Legacy `low`, `high`, and `High_vs_Low` keys remain where needed for validated
contracts; human-facing language uses Control, Short, Long, and Long vs Short.
Acquisition dates represent sample-processing/acquisition timing structure. Samples
were ultimately searched together, so these dates must not automatically be treated
as independent LC-MS batches.

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
```

Stages 01–12 constitute the frozen v1.0 analytical pipeline. Frozen analytical source
may be modified only for a verified scientific or software bug, with explicit
authorization, an analytical version increment, affected-stage revalidation, and
end-to-end reproducibility re-established when required. Cosmetic cleanup, code
deduplication, refactoring, warning suppression, or style improvement alone is not
sufficient. New biological analyses should preferentially be downstream modules.

## Post-freeze downstream robustness analysis

`descriptive/missingness_robustness/` is an optional **POST-FREEZE DOWNSTREAM
ROBUSTNESS ANALYSIS**. It is not part of Stages 01–12, is not called by `run_all.py`,
and does not alter `analysis-v1.0 — FROZEN / VALIDATED`.

D0 used 1,434 proteins and 515 samples with 46,443 missing cells (6.2887%) and
reproduced frozen Stage 07 to floating-point precision. Its 256 Long-vs-Short DEP were
exactly identical to the frozen canonical set. Missingness had a strong inverse
descriptive association with observed mean abundance (Spearman rho approximately
-0.739), but this does not prove MCAR, MAR, MNAR, or a left-censoring mechanism.

Sensitivity results were:

- D1 `ZERO_REPLACEMENT_STRESS_TEST`: 264 proteins at FDR < 0.05; 206/256 canonical
  DEP retained and 50 lost, with substantial effect-size distortion. Direct
  `NA`-to-zero replacement is not used or recommended as primary handling.
- D2 `LEFT_CENSORED_DOWNSHIFT_GAUSSIAN`: 310 proteins at FDR < 0.05; 227/256
  retained and 29 lost. All 29 retained their negative effect direction, their median
  absolute delta-logFC was approximately 0.040, and none reached 0.5. D2 sensitivity
  was mainly statistical-significance sensitivity. Thirty canonical proteins had a
  D2 `Any_sensitivity_flag`; the additional protein was LRP2, which became more
  negative (absolute delta-logFC approximately 0.506) and remained significant. Six
  sensitivity-derived Stage 11a patterns changed.
- D3 `KNN_IMPUTATION`: 294 proteins at FDR < 0.05; 254/256 retained and 2 lost, with
  100% canonical direction concordance and 256/256 Stage 11a pattern retention. KNN
  is not designated the best method and is not promoted to primary analysis.

The seven canonical `Long_suppression` proteins—NRP1, IL7R, ICAM3, BGN, RARRES2,
HSP90AB1, and CSF1R—have complete Control/Short/Long detection. All remain
`Long_suppression` and FDR < 0.05 under D0–D3; their Long-vs-Short logFC values are
unchanged because no values require imputation. Stage 11b independently placed all
seven in C3.

The primary no-imputation analysis and its 256 DEP remain canonical. The sensitivity
sets of 227 or 254 do not redefine the primary result. The validated conclusion is:
the principal Long-vs-Short effect directions are robust to alternative missing-value
assumptions; statistical significance for a subset is sensitive to a left-censored
imputation assumption, while the seven canonical `Long_suppression` proteins are
completely observed and invariant to all evaluated missing-value treatments.

## Stage 13A completion and full-cohort closure

Stage 13A, the canonical 256-DEP master biological characterization table, is
**COMPLETED and PASSED**. It was executed exactly once with exit status 0. All 30
integrity assertions passed and none failed. The canonical master contains 256 rows
and 256 unique `PG.ProteinGroups`.

```text
Pattern: Short_peak = 249; Long_suppression = 7
Cluster: C1 = 130; C2 = 96; C3 = 7; C4 = 23
Any_sensitivity_flag: TRUE = 60; FALSE = 196
FDR05: TRUE = 256
FC05: TRUE = 3
FC10: TRUE = 0
```

Stage 13A outputs:

- `descriptive/limma_dose_analysis/results/13A_canonical_256_DEP_master/Stage13A_canonical_256_DEP_master.csv`
- `descriptive/limma_dose_analysis/results/13A_canonical_256_DEP_master/Stage13A_integrity_assertions.csv`

The full-cohort reference pipeline is now **CLOSED**. The frozen v1.0 analytical
pipeline and its completed downstream reference outputs must not be modified for the
future Discovery/Validation work.

## Discovery-Validation design audit

The Discovery-Validation Design Audit is **COMPLETED**. The 515 canonical analytical
samples represent 515 independent participants; there are no repeated participants.
`group` denotes sampling site/location, and sites are nested within Environment:

```text
Humid-hot: FJ_FQ, FJ_PT, FJ_QZ, GZ_TH
High-pressure/high-altitude: XZ_GG, XZ_YA, XZ_YB, XZ_YC, XZ_YD
```

Environment and site are therefore not independent crossed factors. Confirmed
canonical counts are:

```text
Dose: Control = 153; Short = 186; Long = 176
Environment: Humid-hot = 279; High-pressure/high-altitude = 236

Environment x Dose:
Humid-hot: Control = 95; Short = 83; Long = 101
High-pressure/high-altitude: Control = 58; Short = 103; Long = 75
```

The previously identified acquisition dates represent sample-processing/acquisition
timing structure and must not automatically be called independent MS batches.

## Split feasibility status

The read-only arithmetic feasibility audit compared 80/20, 75/25, and 70/30 without
generating a split or assigning any participant. Validation-size targets were rounded
to the nearest integer with exact halves rounded upward; Discovery was the complement
to 515. Environment x Dose integer allocations used the largest-remainder method to
match each global target exactly.

```text
Ratio   Discovery   Validation   Smallest Environment x Dose Validation cell
80/20         412          103                                             12
75/25         386          129                                             14
70/30         360          155                                             17
```

Following investigator review, the 75/25 target was selected prospectively:
Discovery n = 386 and Validation n = 129. No Discovery/Validation participant
assignment has yet been created or locked.

## Validation Success Criteria Design Audit and investigator decisions

The Validation Success Criteria Design Audit is **COMPLETED**. It was a read-only
statistical-design audit: no participant assignment was generated, no Validation
outcome was inspected, and no model was fitted or rerun. The subsequent investigator
statistical-design decisions are also **COMPLETED**.

The selected design uses one participant-level global split, stratified by Environment
× Dose. The same split supports the primary overall analysis and the secondary
Humid-hot and High-pressure/high-altitude analyses. Site is not a primary holdout or
mandatory stratification variable; it is a robustness dimension.

Long vs Short is the primary Discovery and Validation contrast. Discovery candidates
will be selected using BH-FDR < 0.05 within the Discovery-only eligible protein
universe. Short vs Control and Long vs Control are supportive trajectory contrasts and
do not create primary candidate families.

The Discovery eligibility methodology is frozen exactly to the existing primary
eligibility algorithm, applied using Discovery participants only. The historical
1,434-protein universe will not be treated as a fixed list and subset after the split.
The frozen algorithm will instead be re-executed using only the 386 Discovery
participants, so the resulting eligible-protein count may differ from 1,434.

The primary replication evidence hierarchy is locked: directional support requires
same-sign Discovery and Validation log2FC; nominal statistical replication additionally
requires Validation raw P < 0.05; and FDR-supported replication additionally requires
Validation BH-FDR < 0.05 across the locked primary candidate family. Validation 95%
confidence intervals and estimability must be reported. No weighted score, hard
minimum effect size, fixed effect ratio, or fixed attenuation threshold is used.

The primary replication-rate denominator is all locked candidates (`N_locked`).
Non-estimable candidates remain in this denominator and are separately counted, but
they do not enter an evidence numerator unless the corresponding effect is estimable.
Estimable-only rates using `N_estimable` are mandatory secondary companion summaries.

Signed and absolute Discovery-Validation effect differences are distinguished:
`Effect_difference_signed = Validation log2FC - Discovery log2FC`, whereas
`Effect_difference_absolute = abs(Validation log2FC - Discovery log2FC)`. Both remain
descriptive/supportive quantities without numerical cutoffs or binary replication roles.

Overall Validation is primary. Environment-specific Validation is secondary. Dose ×
Environment interaction is a secondary inferential heterogeneity question. Site-level
analyses are robustness analyses. Exact multiplicity handling for the Environment-
specific and interaction analyses remains pending before those secondary inferential
analyses are executed.

## Prospective Discovery-Validation protocol status

`DISCOVERY_VALIDATION_PROTOCOL.md` has passed final substantive review. The three final
clarifications distinguish signed from absolute effect differences, lock the primary
all-candidate and secondary estimable-only replication-rate denominators, and freeze
the Discovery-only eligibility algorithm exactly to the existing primary methodology.
The protocol status is **SPLIT EXECUTED AND FROZEN** under protocol identifier
`DiscoveryValidationProtocol_v1.0`. Substantive statistical-design decisions remain
frozen. The prospective random seed `20260925` was executed exactly once on
2026-09-26 at 01:09:30 PDT.

The existing full-cohort `515 -> 1,434 -> 256` analysis remains a frozen historical
reference benchmark. Its 256 proteins are not the future Discovery candidate set.
Future protein eligibility, modeling, and candidate locking must use Discovery
participants only.

The deterministic split implementation is frozen in
`DISCOVERY_VALIDATION_SPLIT_SPEC.md`. The frozen assignment contains 386 Discovery and
129 Validation participants. A01–A26 passed 26/26. The canonical input SHA-256 is
`aceb1e2cd1f2e73de8fb19badcd16c1b91e9be466aa4c3bfcf508806dc548487`; the assignment
SHA-256 is `062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791`.

Frozen split outputs are:

- `descriptive/discovery_validation_split/discovery_validation_assignment.csv`
- `descriptive/discovery_validation_split/split_integrity_assertions.csv`
- `descriptive/discovery_validation_split/split_manifest.txt`

## Next project sequence

1. Complete Split Feasibility Analysis. **COMPLETED**
2. Complete Validation Success Criteria Design Audit. **COMPLETED**
3. Complete investigator statistical-design decisions. **COMPLETED**
4. Complete and approve the prospective Discovery-Validation protocol. **COMPLETED**
5. Complete Split Specification: lock the random seed, deterministic assignment
   algorithm, split-file schema, integrity assertions, and checksum/hash and Git freeze
   procedure. **COMPLETED**
6. Generate the split exactly once. **COMPLETED**
7. Freeze participant assignments. **COMPLETED**
8. Rebuild protein eligibility using Discovery participants only.
9. Run Discovery-only overall dose analysis.
10. Run Discovery-only Environment-specific analyses.
11. Test Dose × Environment interaction under a prospectively fixed secondary model
    and multiplicity plan.
12. Lock Discovery candidates.
13. Evaluate locked candidates in Validation only.
14. Perform site heterogeneity/robustness analyses.
15. Integrate missingness, detection, and unique-peptide evidence.
16. Perform biological interpretation last.

Do not execute Steps 8-16 until the relevant step is separately authorized. The split
must not be rerandomized or modified. The immediate next analytical step is Step 8,
but it was not authorized by the split-execution task.
