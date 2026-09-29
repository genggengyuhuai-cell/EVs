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
Discovery n = 386 and Validation n = 129. The deterministic participant assignment
was subsequently generated exactly once, audited, Git-frozen, and must not be
rerandomized or modified.

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
analyses are robustness analyses. Before execution, secondary multiplicity handling was
fixed as separate BH families by Environment/contrast for D05 and by interaction contrast
for D06. These secondary analyses cannot redefine the D03 candidate family.

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

## Discovery–Validation execution completion

The prospective Discovery–Validation analytical branch is now **EXECUTED AND AUDITED
THROUGH D10**. The previous prospective handover state (“implemented/static review only”)
is superseded.

The completed sequence is:

1. Split feasibility analysis. **COMPLETED**
2. Validation success-criteria design audit. **COMPLETED**
3. Investigator statistical-design decisions. **COMPLETED**
4. Prospective Discovery–Validation protocol. **COMPLETED / FROZEN**
5. Deterministic split specification and integrity checks. **COMPLETED / FROZEN**
6. Generate the split exactly once. **COMPLETED**
7. Freeze participant assignments. **COMPLETED**
8. D01 Discovery-only eligibility. **EXECUTED / AUDITED / PASS**
9. D02 Discovery primary Long-vs-Short analysis. **EXECUTED / AUDITED / PASS**
10. D03 Discovery candidate lock. **EXECUTED / AUDITED / FROZEN**
11. D04 dose trajectory characterization. **EXECUTED / AUDITED / PASS**
12. D05 Environment-specific Discovery analysis. **EXECUTED / AUDITED / PASS**
13. D06 Dose × Environment interaction analysis. **EXECUTED / AUDITED / PASS**
14. D07 site robustness / leave-one-major-site-out. **EXECUTED / AUDITED / PASS**
15. Validation protocol authorization before outcome inspection. **COMPLETED / FROZEN**
16. D08 locked-candidate Validation. **EXECUTED / AUDITED / PASS**
17. D09 missingness, detection and peptide evidence. **EXECUTED / AUDITED / PASS**
18. D10 integrated candidate evidence. **EXECUTED / AUDITED / PASS**

No D11 analytical stage is defined by the prospective workflow. The next downstream
task is static audit of `descriptive/discovery_validation/code/figures_prospective.R`
against the finalized D01–D10 schemas before first figure generation.

## D01–D03 Discovery results

D01 re-executed the frozen eligibility algorithm using only the 386 Discovery
participants, starting from all 3,817 raw protein groups. Detection was finite abundance
greater than zero and each Discovery dose group independently had to reach 70%.
No imputation was used. The resulting Discovery-only eligible universe contained
**1,445 proteins**.

D02 used `log2(PG.Quantity)`, no additional primary normalization, no imputation,
`abundance ~ dose + environment`, and Long vs Short as the primary contrast. All
1,445 eligible proteins were estimable; 365 had raw P < 0.05 and **85 had
BH-FDR < 0.05**.

D03 locked exactly those 85 Discovery Long-vs-Short BH-FDR < 0.05 candidates. All 85
were `Higher_in_Short`. Candidate membership is frozen and cannot be changed by
trajectory, Environment, interaction, site, Validation, detection, peptide or pathway
evidence.

```text
D03 candidate N = 85
Candidate-list SHA-256 =
14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2
```

## D04–D07 supportive Discovery characterization

D04 classified the 85 locked candidates without changing membership:

```text
Reversal_after_short_increase = 75
Transient_short_peak = 6
Delayed_decrease = 4
```

D05 performed Environment-stratified Discovery analyses. For the locked family,
secondary BH-FDR < 0.05 counts were:

```text
Humid-hot:
  Short vs Control = 2/85
  Long vs Control  = 0/85
  Long vs Short    = 78/85

High-pressure/high-altitude:
  Short vs Control = 1/85
  Long vs Control  = 25/85
  Long vs Short    = 44/85
```

These differing Environment-specific counts do not by themselves establish formal
heterogeneity.

D06 formally tested Dose × Environment interaction. Raw P < 0.05 counts were 2, 19,
and 5 for the Long-vs-Short, Short-vs-Control, and Long-vs-Control interaction contrasts,
respectively, but **0/85 reached secondary BH-FDR < 0.05 for every interaction
contrast**. D05 therefore must not be interpreted as proof of formal Environment
interaction.

D07 evaluated five major Discovery sites by leave-one-major-site-out analysis:
XZ_GG, GZ_TH, FJ_FQ, FJ_QZ, and XZ_YC. There were 425 candidate-scenario estimates
(85 × 5). All 85 candidates were direction stable in all five LOO scenarios. This
supports site/influence robustness but does not establish absence of site heterogeneity.

## Validation authorization and D08 results

Validation access was authorized only after D03 candidate locking and D04–D07 Discovery
characterization were complete. The authorization was committed before Validation
outcome inspection as:

```text
eb3de2f protocol: authorize locked-candidate validation
```

The frozen primary Validation contrast is Long vs Short over all 85 locked candidates.
Direction concordance requires the same Discovery/Validation log2FC direction. Nominal
replication requires direction concordance and Validation P < 0.05. FDR-supported
replication requires direction concordance and candidate-family BH-FDR < 0.05, with BH
across all 85 locked candidates. Non-estimable candidates remain in `N_locked`; the
estimable-only rate is a companion summary. Environment-specific Validation is
secondary characterization only.

D08 used the independent Validation split (n = 129) and preserved the exact D03 family:

```text
N_locked = 85
N_estimable = 85
Direction concordant = 83/85 (97.65%)
Nominal replication = 29/85 (34.12%)
FDR-supported replication = 1/85 (1.18%)
```

The single FDR-supported candidate was Q08378 / GOLGA3. The two direction-discordant
candidates were Q92752 / TNR and Q9Y624 / F11R; their Validation effects were close to
zero rather than strong opposite effects.

Discovery-to-Validation effect behavior was characterized descriptively:

```text
Mean |log2FC|: Discovery = 0.34435; Validation = 0.26224
Median absolute Validation/Discovery effect ratio = 0.78357
Ratio >= 0.50 = 70/85
Ratio >= 0.75 = 48/85
Ratio >= 1.00 = 21/85
Median (Validation - Discovery) = +0.06630
Pearson effect correlation = 0.1114
Spearman effect correlation = 0.0541
```

Because all Discovery effects were negative, the positive median signed difference
indicates overall attenuation toward zero in Validation. The supported interpretation is
**strong family-level directional concordance, but weak protein-specific effect-size/rank
concordance and limited multiplicity-controlled single-protein replication**. Do not
state that all 85 proteins were validated.

Environment-specific D08 characterization remained secondary:

```text
Humid-hot:
  85/85 estimable
  negative log2FC = 83
  positive log2FC = 2
  raw P < 0.05 = 14
  BH-FDR < 0.05 = 0

High-pressure/high-altitude:
  85/85 estimable
  negative log2FC = 78
  positive log2FC = 7
  raw P < 0.05 = 11
  BH-FDR < 0.05 = 0
```

## D09 evidence layers

D09 retained missingness/detection evidence separately from quantitative abundance
inference and did not impute the primary analysis. Across the six Discovery/Validation
Dose strata:

```text
All-dose detection >=50% = 85/85
All-dose detection >=60% = 85/85
All-dose detection >=70% = 85/85
All-dose detection >=80% = 81/85
```

No approved unique-peptide source was found in the traced project sources.
`Peptide_support_status = SOURCE_NOT_AVAILABLE` for all 85 candidates. Peptide support
must not be invented or inferred from unavailable data.

## D10 integrated evidence completion

D10 was revised before first execution so that the integrated master safely summarizes
multi-row D05, D06, D07 and D09 evidence rather than silently keeping the first duplicated
protein row. The executed D10 master contains exactly:

```text
Rows = 85
Unique PG.ProteinGroups = 85
Columns = 67
D07 LOO scenarios per candidate = 5
D07 all-direction-stable = 85/85
D08 direction concordant = 83/85
D08 nominal replication = 29/85
D08 FDR-supported replication = 1/85
D09 all-dose >=70% detection = 85/85
D09 all-dose >=80% detection = 81/85
D09 peptide status SOURCE_NOT_AVAILABLE = 85/85
```

D10 is supportive evidence integration only. It performs no candidate filtering,
ranking, promotion or redefinition. Pathway analysis remains
`NOT_RUN_NO_APPROVED_MAPPING` for all 85 candidates because no investigator-approved
pathway mapping/universe has been supplied.

The D10 code revision and first audited outputs were committed together:

```text
d46aee3 analysis: integrate and audit D10 candidate evidence
```

The immediately preceding prospective checkpoints include:

```text
44847df analysis: execute and audit D09 evidence layers
4135364 analysis: execute and audit D08 locked-candidate validation
eb3de2f protocol: authorize locked-candidate validation
59599da analysis: execute and audit D07 site robustness
db72e65 analysis: execute and audit D06 environment interaction
```

At the last confirmed D10 checkpoint, `git status --short` was clean.

## Current Discovery–Validation authority

```text
Discovery participants = 386
Validation participants = 129
D01 eligible proteins = 1,445
D03 locked candidates = 85
D01–D10 execution = COMPLETED
D01–D10 staged audit = COMPLETED / PASS
Validation protocol = FROZEN BEFORE OUTCOME INSPECTION
Unique-peptide support = SOURCE_NOT_AVAILABLE
Pathway analysis = NOT RUN — NO APPROVED MAPPING/UNIVERSE
D10 integrated master = 85 rows × 67 columns
Current analytical checkpoint = d46aee3
```

The Discovery–Validation analytical stage sequence ends at D10.
`figures_prospective.R` is a downstream visualization module, not D11. It must be
statically audited against the finalized executed schemas before first use. Figure
generation may summarize finalized evidence but must not refit models, recalculate FDR,
change the candidate universe, add post-hoc effect cutoffs, or select proteins based on
visual appearance.

## Documentation classification

- **CURRENT AUTHORITY:** this file; `descriptive/discovery_validation/README.md`,
  `PIPELINE_STATUS.md`, `DATA_CONTRACTS.md`, `WORKFLOW.md`;
  `docs/protocol/ANALYSIS_PLAN_v2.0.md`;
  `docs/protocol/STUDY_DESIGN_AUDIT.md`;
  `docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md`;
  `docs/protocol/DISCOVERY_VALIDATION_SPLIT_SPEC.md`.
-
- **WORKFLOW & STATUS:** `docs/workflow/CODEX_WORKFLOW.md`,
  `docs/workflow/FILE_STATUS.md`,
  `docs/workflow/MASTER_PROJECT_AUDIT_BACKLOG.md`,
  `docs/task/TASK_CURRENT.md`.

**HISTORICAL:** versioned READMEs under `docs/archive/` (legacy_framework_v2.0/, maintenance_logs/, early_plans/) and frozen analysis-v1.0 / Stage
  13A methods documents. They remain valid for the historical branch only.
- **SUPERSEDED:** older handover or task text saying the split is undecided/unexecuted,
  the seed is unselected, only D01 exists, or D01 static review is the next task.

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

