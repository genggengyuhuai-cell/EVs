# M09 Method Contract

Status: `FROZEN_PROTOCOL_IMPLEMENTATION_CONTRACT`.

Authority: `docs/protocol/ANALYSIS_PLAN_v2.0.md`, Module 09.

## Purpose and boundary

M09 evaluates whether the frozen M05 overall-exposure effect estimates change under one prespecified missing-value treatment. It is a sensitivity analysis, not a primary estimator, discovery procedure, validation analysis, or ML preprocessing step.

## Input contract

| Component | Contract |
|---|---|
| Population | Full analytical cohort, n=515 |
| Protein universe | Fixed Q515, n=1,430 |
| Matrix | Q515 rows from `PRIMARY_dose_log2_expression.csv.gz` |
| Scale | Existing log2 abundance scale |
| Missing value | `NA` in the Q515 log2 matrix |
| Imputation orientation | Proteins are rows and participants are columns |
| Observed values | Must remain unchanged exactly |
| Order | Protein and sample order must remain unchanged |

## Prespecified imputation

The canonical implementation is:

```r
impute::impute.knn(
  data,
  k = 10,
  rowmax = 0.5,
  colmax = 0.8,
  maxp = 1500,
  rng.seed = 20260925
)
```

According to the installed `impute` API, `impute.knn` finds neighbors in protein space using a Euclidean metric restricted to columns observed for the target protein. When a candidate neighbor is missing some distance coordinates, distance is averaged over its available coordinates. Missing entries are imputed by the arithmetic mean of the corresponding non-missing entries among the selected neighbors. This is not correlation-neighbor selection, median aggregation, correlation weighting, or an independently reimplemented Euclidean algorithm.

Package behavior retained without alteration:

- `k=10`: use ten nearest protein neighbors where the package algorithm can do so.
- `rowmax=0.5`: a row with more than 50% missing entries is excluded from KNN processing and its missing entries are filled using the package's per-column mean fallback.
- `colmax=0.8`: if any column has more than 80% missing entries, `impute.knn` stops with an error; it does not relax the threshold.
- Neighbor-column fallback: if all selected neighbors are missing for an entry, the package fills that unresolved entry using the overall column mean for the current block.
- `maxp=1500`: blocks larger than 1,500 rows are recursively divided by two-means clustering before KNN imputation. With 1,430 Q515 rows, no split is expected.
- `rng.seed=20260925`: the frozen Module 09 seed is passed explicitly.

## Downstream estimator

The imputed matrix is fitted with the M05 contract: `~0+Group+Environment`, the frozen cohort-weighted overall-exposure contrast E through `contrastAsCoef`, and `eBayes(trend=TRUE, robust=TRUE)`. BH correction is applied across the same 1,430-protein A-E family. The repaired effect is compared protein-for-protein with the existing frozen M05 output.

## Required diagnostics

The run records matrix dimensions, missing counts before and after, rowmax and colmax exceedances, package fallback exposure, unresolved missing values, order preservation, observed-value preservation, package version, parameters, and output comparison counts.

## Interpretation

Agreement supports robustness only under this specific prespecified KNN-imputation sensitivity analysis. M09 does not validate M05 and cannot establish that missingness has no effect.

## Figure dependency

Fig. 3 panel c reads the M09 overall-exposure comparison. It must be assessed for rebuild after repaired M09 values are available; the complete M17 figure pipeline is outside this run.
