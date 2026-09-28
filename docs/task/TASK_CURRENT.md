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
MISSINGNESS / IMPUTATION ROBUSTNESS ANALYSIS: COMPLETED
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

## Completed post-freeze analysis

`descriptive/missingness_robustness/` is a completed **POST-FREEZE DOWNSTREAM
ROBUSTNESS ANALYSIS** and is not called by `run_all.py`. D0 reproduced frozen Stage
07 to floating-point precision using 1,434 proteins, 515 samples, and 46,443 missing
cells (6.2887%), including exact identity of the 256 Long-vs-Short DEP set.

Missingness had a strong inverse descriptive association with observed abundance
(mean-abundance Spearman rho approximately -0.739), without establishing MCAR, MAR,
MNAR, or another missingness mechanism. D1 retained 206/256 canonical DEP and showed
substantial zero-replacement distortion. D2 retained 227/256; its 29 losses retained
negative effect direction and had median absolute delta-logFC approximately 0.040,
so the sensitivity was mainly statistical rather than directional. D3 retained
254/256, had 100% canonical direction concordance, and retained all 256 Stage 11a
patterns. The frozen 256 remain canonical.

All seven canonical `Long_suppression` proteins—NRP1, IL7R, ICAM3, BGN, RARRES2,
HSP90AB1, and CSF1R—are completely observed in all three exposure groups, remain
`Long_suppression` under D0–D3, retain unchanged Long-vs-Short logFC values, remain
FDR < 0.05, and were independently assigned to Stage 11b C3.

## Immediate next analytical task

Build the canonical 256-DEP master biological characterization table integrating
primary statistics, Control/Short/Long profiles, Stage 11a pattern, Stage 11b cluster,
and missingness-robustness flags. Do not begin this analysis until separately
authorized.

---

## 2026-09-28 update

Active status file is now `docs/workflow/MASTER_PROJECT_STATUS_2026-09-28.md`.

Archived this phase:
- figures_prospective_v1/v2.3/v2.4/v2.5 -> descriptive/archive/figures_render_history/
- root scratch logs (t*.txt, tb.txt, v2_05u_FINAL.log, git.txt, "tatus --short") -> descriptive/archive/diagnostics/
- code/P1-P3.py RETAINED (frozen sample-mapping provenance, "REUSE AS-IS").

Next: v2 implementation M05 (Overall Exposure vs Control). M16 not authorized.

## M06 complete (2026-09-28)

M06 ordered/omnibus/architecture = CODE_COMPLETE / EXECUTION_COMPLETE / AUDIT_PASS.
Next: M07 pairwise LC/HC/HL contrasts (NOT STARTED, awaiting go-ahead).
