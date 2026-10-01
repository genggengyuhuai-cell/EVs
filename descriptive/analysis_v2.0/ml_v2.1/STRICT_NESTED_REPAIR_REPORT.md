# Strict Nested Sensitivity Repair Report

Status: `PHASE2_REPAIR_PASS` / `POST_PHASE2_REPAIR_CURRENT`.

This report is based only on the authoritative outputs from the completed second repaired execution. No analysis was rerun during final QA.

## Scope and method

- Outer resampling: 3 repeats × 5 folds = 15 outer folds; seeds `20260928`, `20260929`, and `20260930`.
- Input: each outer discovery step starts from 3,817 raw protein groups.
- Eligibility: finite positive detection is recomputed within each outer-training set; High and Low must each reach 70%.
- Discovery: raw positive quantities are log2-transformed, with no discovery imputation, then tested using D02-compatible limma with `abundance ~ dose + Environment`, High-minus-Low contrast, and `eBayes(trend=TRUE, robust=TRUE)`.
- Multiplicity: BH adjustment is applied within the fold-local tested universe; candidates require BH-FDR < 0.05.
- Rescue rules: none. There is no top-N fallback and no threshold relaxation.
- ML preprocessing: training-only median imputation, centering, and scaling are applied after discovery and transferred unchanged to the outer test set.
- Inner CV: one explicit, outcome-stratified five-fold `foldid` is shared by LASSO and all Elastic Net candidates in each outer fold.
- SVM-RFE is outside this repair.

## Numeric QA

### Discovery and fold accounting

- Non-estimable discovery folds: 0/15.
- Zero-feature folds: 7/15.
- Folds entering ML fitting: 8/15.
- Selected-feature distribution across all 15 folds, min/Q1/median/Q3/max: **0 / 0 / 3 / 59 / 536**.
- Inner folds: 75 total; **75/75 contain both High and Low**.

The seven zero-feature folds are valid statistical outcomes under the prespecified discovery threshold. They are not technical failures and were not rescued. Consequently, performance summaries below are conditional on the **8 outer folds in which the prespecified D02-aligned discovery step yielded at least one feature**. They are not complete 15-fold nested-performance estimates.

### Conditional predictive performance

| Model | Evaluable folds | Metric | Mean | Median | Range |
|---|---:|---|---:|---:|---:|
| LASSO | 8 | AUROC | 0.596663 | 0.596230 | 0.489418–0.668956 |
| LASSO | 8 | AUPRC | 0.590299 | 0.580538 | 0.451429–0.692491 |
| Elastic Net | 8 | AUROC | 0.593731 | 0.598341 | 0.465608–0.662088 |
| Elastic Net | 8 | AUPRC | 0.582644 | 0.617635 | 0.436835–0.650321 |

### Feature stability

Appearance frequency is `appearance_count / 15 outer folds`. The seven zero-feature folds remain in the denominator.

| Threshold | N | Gene list |
|---|---:|---|
| ≥0.70 | 0 | NONE |
| ≥0.80 | 0 | NONE |
| ≥0.93 | 0 | NONE |

### Fixed-85 Tier1 descriptive comparison

This comparison is descriptive only. It does not define a new final panel or a new nested-frequency threshold.

| Gene | Fixed85 LASSO frequency | Fixed85 EN frequency | Repaired nested appearance |
|---|---:|---:|---:|
| GAL | 1.000000 | 1.000000 | 3/15 (0.200000) |
| TSPAN14 | 1.000000 | 1.000000 | 7/15 (0.466667) |
| DMP1 | 0.866667 | 0.933333 | 7/15 (0.466667) |
| IGF1 | 0.800000 | 0.800000 | 6/15 (0.400000) |
| GOLGA3 | 0.733333 | 0.866667 | 4/15 (0.266667) |

## Methodology QA

| Check | Result | Evidence |
|---|---|---|
| Welch t-test removed from primary nested discovery | PASS | Primary discovery calls limma; no `t.test()` call is present. |
| D02-compatible limma used | PASS | `lmFit`, `contrasts.fit`, High-minus-Low contrast, and empirical Bayes are used. |
| Environment retained | PASS | Design is `~0 + dose + environment`; there is no unadjusted fallback. |
| `trend=TRUE` retained | PASS | Explicit in `eBayes`. |
| `robust=TRUE` retained | PASS | Explicit in `eBayes`. |
| Outer-test excluded from discovery | PASS | Eligibility and discovery receive outer-training data only. |
| Fold-local eligibility recomputed | PASS | Recomputed separately within every outer-training set. |
| No discovery imputation | PASS | Nonpositive/nonfinite values become missing; limma uses available observations. |
| BH within fold-local tested universe | PASS | `p.adjust(..., method="BH", n=length(eligible_ids))`. |
| Inner CV genuinely stratified | PASS | Class-wise fold assignment is used. |
| Explicit `foldid` passed to `cv.glmnet` | PASS | Passed to LASSO and every Elastic Net candidate. |
| Outer splits unchanged | PASS | Seeds match the snapshot; all 8 successful-fold prediction groups retain the old rep/fold sample order and labels. |
| No post-hoc rescue rule | PASS | No top-N fallback or threshold relaxation is used. |

## Old versus repaired result

The historical 8–618 feature-count range, old stable-feature lists, and old strict-nested AUROC/AUPRC summaries came from a Welch-based discovery method that did not match D02. They are formally marked `PRE_REPAIR_NOT_INTERPRETABLE_AS_PURE_RESAMPLING_INSTABILITY` and are superseded by the D02-aligned results.

The repaired feature-selection instability is more severe, not less severe: 7/15 folds select no feature, the median selected count is 3, and no gene reaches 0.70 appearance frequency across all 15 folds. This supports the interpretation that candidate discovery is highly sensitive to training-sample composition. It does **not** establish biological heterogeneity, and this analysis is **not** external validation.

## Scope preservation and downstream use

- D02, D03, and D08 were not modified.
- Phase-1 fixed-85 repaired ML was not modified or rerun in Phase 2.
- SVM-RFE was not run or modified.
- Fig5 and supplementary ML panels or tables that use old strict-nested metrics require rebuilding from the repaired outputs.
- See `STRICT_NESTED_REPAIR_COMPARISON.csv`, `STRICT_NESTED_VS_FIXED85.csv`, and `STRICT_NESTED_DOWNSTREAM_IMPACT.md` for the tabular comparison and impact boundary.

## Final repository checks

- `git diff --check -- descriptive/analysis_v2.0/ml_v2.1`: PASS, exit 0. The emitted messages are line-ending warnings, not whitespace errors.
- Repository-wide `git diff --check`: exit 2 because unrelated pre-existing SVG files outside `ml_v2.1` contain trailing whitespace. Those files were not changed in this repair.
- `git status --short`: 840 entries repository-wide and 33 entries under `descriptive/analysis_v2.0/ml_v2.1`. D02/D03/D08 paths are clean.
- No commit, push, or tag was performed.
