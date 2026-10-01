# M09 Repair Report

Status: `PHASE3_M09_REPAIR_PASS` / `POST_PHASE3_REPAIR_CURRENT`.

## Contract

Frozen `ANALYSIS_PLAN_v2.0` Module 09 is authoritative. The pre-repair custom correlation-neighbor, unweighted-median procedure was removed. The repaired run uses `impute::impute.knn` on the 1,430 × 515 Q515 log2 matrix with `k=10`, `rowmax=0.5`, `colmax=0.8`, `maxp=1500`, and `rng.seed=20260925`.

The downstream model preserves the frozen M05 population, sample order, Group and Environment coding, design, cohort-weighted overall-exposure E contrast, `contrastAsCoef` implementation, `eBayes(trend=TRUE, robust=TRUE)`, and A-E BH family. M05 itself was not rerun or modified.

## Imputation diagnostics

- Input dimensions: 1430 proteins × 515 samples.
- Missing values: 46443 before; 0 after.
- Rows exceeding rowmax: 0; columns exceeding colmax: 0.
- Rowmax fallback rows/cells: 0/0.
- Neighbor-column-mean fallback cells/rows/columns: 171/117/16.
- Recursive maxp block split used: NO.
- Sample order, protein order, and all observed values were unchanged.

## Effect comparison

- Proteins compared: 1430.
- Pearson correlation: 0.974061.
- Spearman correlation: 0.964438.
- Direction concordance: 1343/1430 (93.92%); sign flips: 87.
- Median absolute effect change: 0.006330; maximum: 0.188332.
- FDR<0.05: primary only 0; KNN only 0; both 0; primary total 0; KNN total 0.

## Old versus repaired M09

- Pearson correlation increased from 0.931147 to 0.974061, a change of +0.042914.
- Spearman correlation increased from 0.913236 to 0.964438, a change of +0.051203.
- Direction concordance increased from 1320/1430 (92.31%) to 1343/1430 (93.92%), an increase of 23 proteins.
- Repaired `E_knn` differs numerically from the old invalidated value for 953/1430 proteins. The median and maximum absolute old-to-repaired changes are 0.007791 and 0.371880.
- The old output did not contain inferential P/FDR fields, so old significant counts are `NOT_AVAILABLE`; repaired primary and KNN FDR-supported counts are both 0.

## Interpretation

The primary overall-exposure effect estimates were compared with estimates obtained after the prespecified KNN-imputation sensitivity analysis. Agreement is evidence only about robustness to this specific missing-value treatment; M09 is not validation and does not establish that missingness has no effect.

## Scope

Only M09 was rerun. D03, D08, fixed-85 ML, strict nested ML, SVM-RFE, M11, M12/M12B, and the M17 figure pipeline were not run or modified. Fig. 3c was not redrawn.

## Integrity QA

- `impute` version: 1.76.0.
- All 1,430 protein IDs are unique and estimable in both frozen M05 and repaired M09.
- No infinite effect, P-value, or FDR values and no unresolved silent NA propagation were found.
- Fig. 3c numerical content changed and is marked `FIG3_REBUILD_REQUIRED`; caption and Methods wording must also change.

## Repository QA

- Phase 3 scoped `git diff --check`: PASS, exit 0. Line-ending notices are warnings only.
- Repository-wide `git diff --check`: exit 2 because 194 trailing-whitespace findings remain in unrelated pre-existing SVG files outside the Phase 3 scope.
- `git status --short`: 882 entries repository-wide and 15 entries in the Phase 3 scope. Direct M05, D03, D08, and M11 paths are clean.
- No commit, push, or tag was performed.
