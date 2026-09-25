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

Immediate next analytical task: build the canonical 256-DEP master biological
characterization table integrating primary statistics, Control/Short/Long profiles,
Stage 11a pattern, Stage 11b cluster, and missingness-robustness flags. This task has
not started.
