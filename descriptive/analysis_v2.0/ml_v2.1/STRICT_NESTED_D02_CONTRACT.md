# Strict Nested D02 Contract

Status: contract frozen for the Phase 2 strict-nested repair before code changes.

## Reference sources

- `descriptive/discovery_validation/code/D02_discovery_primary.R`
- `descriptive/discovery_validation/code/dv_shared.R`
- `descriptive/discovery_validation/D01_discovery_eligibility.py`
- `descriptive/discovery_validation/DATA_CONTRACTS.md`
- `docs/protocol/ANALYSIS_PLAN_v2.1.md`, section 7

## D02 primary contract

| Item | D02 contract | Strict-nested implementation | Classification |
|---|---|---|---|
| Input abundance | Raw `PG.Quantity` from `rawdata/processed.xlsx`, with finite positive values treated as detected | Read the frozen raw workbook and static participant-to-column mapping; do not use the globally filtered D01 expression matrix | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Sample inclusion | Frozen Discovery participants | Frozen Discovery High/Low participants assigned to the unchanged 15 outer splits; discovery uses outer-train participants only | EXACTLY_REPLICABLE_INSIDE_FOLD for the active High-vs-Low task |
| High/Low subset | Primary contrast is `high - low` | Only outer-train High and Low samples enter fold-local eligibility and limma | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Environment | Derived deterministically from site and included in the primary model | Re-derived from the frozen site-to-Environment map inside every outer fold | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Design matrix | `~0 + dose + environment`; full-rank design required | `~0 + dose + environment` with dose levels Low/High; a rank-deficient fold is flagged `DISCOVERY_MODEL_NONESTIMABLE`, with no fallback | EXACTLY_REPLICABLE_INSIDE_FOLD, adapted only to the prespecified two-class outer task |
| Contrast | `dosehigh - doselow` (`Long_vs_Short`) | Same High-minus-Low contrast | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Estimator | `limma::lmFit`, then `limma::contrasts.fit` | Same | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Empirical Bayes | `limma::eBayes(trend=TRUE, robust=TRUE)` | Same | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Weights | No array weights, observation weights, or quality weights | None | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Missing values | Non-positive/non-finite raw values become `NA`; no imputation before limma; limma uses available observations | Same for discovery. ML imputation occurs only after candidate selection and is fitted on outer train | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Minimum estimability | No arbitrary minimum count is imposed after eligibility; a result is estimable only when logFC, SE and P value are finite | Same finite-result rule; model/design failures are recorded, not replaced by a simpler model | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Protein eligibility | D01: detected count ×100 >=70×n separately in each relevant dose group; all groups must pass | Recomputed from raw abundance within each outer train, separately for High and Low, both >=70%; no global D01/D03 eligibility is reused | EXACTLY_REPLICABLE_INSIDE_FOLD for the two-class task |
| Multiple testing | BH over the D01/D02 tested family (`p.adjust(..., method="BH", n=family_n)`) | BH within each fold-local eligible/tested universe, with `n=N_eligible` | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Candidate threshold | `BH_FDR < 0.05`; no effect-size threshold, nominal-P fallback or top-N rescue | Same | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Transformation | `log2(PG.Quantity)` | Same after non-positive/non-finite values are set to `NA` | EXACTLY_REPLICABLE_INSIDE_FOLD |
| Normalization | None | None in discovery | EXACTLY_REPLICABLE_INSIDE_FOLD |

## Global quantities forbidden inside folds

The following are `GLOBAL_PRECOMPUTED_AND_MUST_NOT_BE_REUSED` for fold-local discovery because they were calculated using participants that become outer-test samples:

- D01 eligible-protein membership and the globally filtered D01 expression matrix;
- D02 coefficients, P values, BH-FDR values, estimability calls and significant-protein membership;
- the D03 locked 85-protein list;
- historical 1,434-protein quantitative eligibility and fixed-85 ML outputs.

Static, outcome-independent contracts may be reused: the frozen assignment, participant identifiers, participant-to-raw-column mapping, raw protein identifiers, canonical annotations, and the deterministic site-to-Environment mapping.

## Important adaptation

D02 was fitted to the full Discovery cohort with Control, Low and High levels, whereas the active v2.1 strict-nested prediction task and its outer splits contain High and Low only. Controls are not injected into outer training. Therefore, the estimator, Environment adjustment, contrast, missing-value handling, empirical-Bayes settings, BH rule and threshold are reproduced exactly, while eligibility and the dose design are evaluated on the prespecified two-class outer-training sample set. This avoids using participants outside the outer resampling definition and is the closest leakage-free D02-compatible implementation for the active task.

## ML preprocessing boundary

Fold-local discovery receives raw abundance and performs no imputation or scaling. After candidate selection, median imputation, centering, scaling and zero-variance assessment are fitted using the complete outer-training matrix and applied unchanged to outer test. Outer-test data never estimate a preprocessing parameter. A deterministic outcome-stratified five-fold `foldid` is passed explicitly to every LASSO and Elastic Net `cv.glmnet` fit.
