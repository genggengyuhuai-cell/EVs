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
```

Legacy `low`, `high`, and `High_vs_Low` keys remain where needed for validated
contracts; human-facing language uses Control, Short, Long, and Long vs Short.
Acquisition date remains a proxy, not a confirmed biological or technical batch.

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
