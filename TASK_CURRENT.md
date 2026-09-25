# Current task state

Documentation synchronization records the successful final post-fix end-to-end run.
No analytical source changes are part of this task.

Current status:

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
```

The locked analysis state is 3,817 raw protein groups, 519 raw samples, 3,810 mapped
gene symbols plus 7 fallback/unmapped labels, 515 dose-defined samples, 1,434 primary
quantitative proteins at the primary threshold of at least 70% detection in each
exposure group, approximately 6.29% residual missingness, and 256 DEPs.
Primary data remain log2 with missing values retained as `NA`; primary imputation and
`NA -> 0` are both absent, while median normalization is sensitivity-only. Stage 11a
has 249 `Short_peak` and 7 `Long_suppression`; exploratory Stage 11b has C1=130,
C2=96, C3=7, and C4=23 from the 256 × 3 observed group-mean matrix, with no
sample-level imputation. All 7 `Long_suppression` proteins map to C3; the 249
`Short_peak` proteins map to C1/C2/C4 as 130/96/23.

Stages 01–12 constitute the frozen v1.0 analytical pipeline. Changes require a
verified scientific or software bug, explicit authorization, a version increment,
affected-stage revalidation, and end-to-end reproducibility when required. Cosmetic
cleanup, deduplication, refactoring, warning suppression, or style improvement alone
is not sufficient. Prefer downstream modules for new biological analyses.
