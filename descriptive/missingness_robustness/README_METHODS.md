# Missingness robustness analysis

## Analysis status

This directory is a **POST-FREEZE DOWNSTREAM ROBUSTNESS ANALYSIS**. It does not replace or modify the **PRIMARY FROZEN ANALYSIS**. The primary pipeline remains `analysis-v1.0 — FROZEN / VALIDATED`, and the canonical Long-versus-Short result remains the 256 proteins defined by the frozen Stage 07 analysis. This optional module is not called by `run_all.py`.

Frozen source version: commit `a2891a36b8c2837a1cc1990452bb41aa11264856`, tag `analysis-v1.0`.

## Frozen inputs

- `../PRIMARY_dose_log2_expression.csv.gz`
- `../dose_defined_metadata.csv`
- `../limma_dose_analysis/results/01_PRIMARY/PRIMARY_log2_dose_environment__High_vs_Low.csv`
- `../limma_dose_analysis/results/09_DEP_characterization/High_vs_Low_DEP_all.csv`
- `../canonical_protein_annotation.csv` (annotation only)

## Purpose and methods

The analysis tests whether the frozen Long-versus-Short findings remain stable under alternative missing-value assumptions. All four analyses retain the same 1,434 proteins, 515 samples, factor coding, design `~ 0 + dose + environment`, contrast `dosehigh - doselow`, limma fitting, robust trend empirical Bayes moderation, and BH adjustment. They differ only in missing-value handling.

- **D0 PRIMARY FROZEN ANALYSIS**: missing values remain `NA`. This calculation must numerically reproduce Stage 07 before any sensitivity analysis runs.
- **D1 ZERO_REPLACEMENT_STRESS_TEST**: missing entries are replaced by numeric zero in a copy. Zero is a real value on this log2 scale, so this is an intentionally extreme stress test and not a recommended imputation method.
- **D2 LEFT_CENSORED_DOWNSHIFT_GAUSSIAN**: for sample `j`, missing entries are sampled from `Normal(mu_j - 1.8 sigma_j, (0.3 sigma_j)^2)`, using observed sample mean and SD. Seed: `20260925`. This is a sensitivity analysis under a low-abundance/left-censoring assumption; the observed data do not prove that mechanism.
- **D3 KNN_IMPUTATION**: `impute::impute.knn(k=10, rowmax=0.5, colmax=0.8, maxp=1500, rng.seed=20260925)`. KNN estimates missing entries from multivariate similarity structure and represents a different assumption from D2. It is not treated as superior.

No additional normalization is applied. Observed finite values are asserted unchanged in D1–D3. The canonical 256 DEP and frozen Stage 11a 249/7 classification are never redefined.

## Validation gates

The script stops on any mismatch in dimensions, identifiers, missing-cell count, missing fraction, group sizes, per-group detection threshold, canonical result sizes or set identity. D0 is compared protein-by-protein for `logFC`, `AveExpr`, `t`, `P.Value`, `adj.P.Val`, and `B` at an absolute tolerance of `1e-10`; FDR status and DEP-set identity must match exactly. D1–D3 run only after this gate passes. D3 additionally checks actual row and column missingness against its requested limits.

## Missingness diagnostics and interpretation limits

Sample- and protein-level missingness, abundance–missingness Spearman associations, and exposure-group detection imbalances are descriptive. They are not used to label missingness as MCAR, MAR, MNAR, or left-censored. No method is selected by its number of significant proteins, and a smaller FDR after imputation is not interpreted as data improvement.

After execution, quantitative diagnostic results are written to `results/execution_summary.txt`, with detailed tables in `results/` and gate diagnostics in `diagnostics/`. Figures are written only to `figures/`.

## Output overview

- `diagnostics/preflight_assertions.csv`: all hard preflight checks.
- `diagnostics/D0_canonical_comparison.csv` and `D0_numerical_summary.csv`: protein-level and field-level reproduction diagnostics.
- `results/sample_missingness.csv`, `protein_missingness.csv`, and abundance-correlation tables: descriptive missingness results.
- `results/D0_*.csv` through `D3_*.csv`: same-model limma results.
- `results/robustness_summary.csv` and `master_comparison.csv`: primary cross-method comparisons.
- `results/canonical_256_stability_summary.csv` and `canonical_256_sensitivity_flags.csv`: canonical-set stability and transparent flag components.
- `results/stage11a_*`: local frozen-rule reproduction and sensitivity transitions.
- `results/D2_sample_imputation_diagnostics.csv`: sample-wise D2 parameters and imputed-value summaries.
- `figures/`: nine required diagnostic figures in PNG and PDF.

## Execution results (2026-09-25)

All preflight checks and the D0 gate passed. D0 contained 1,434 proteins, 515 samples, and 46,443 missing cells (6.2887%). It reproduced all 1,434 Stage 07 rows and the exact 256-protein DEP set to floating-point precision. Maximum absolute differences were `4.996e-16` for logFC, `4.974e-14` for AveExpr, `5.329e-15` for t, `7.216e-16` for P value, `9.992e-16` for BH FDR, and `6.217e-14` for B; no protein exceeded the `1e-10` tolerance.

Missingness was strongly and inversely associated with observed abundance (Spearman rho `-0.7392` for observed mean and `-0.7365` for observed median). These are descriptive associations only and do not prove MCAR, MAR, MNAR, or a left-censoring mechanism. The median maximum exposure-group detection difference was 0.0155 across all proteins, 0 among the canonical 256, and 0.0201 among the other 1,178 proteins; maxima were 0.2081, 0.1432, and 0.2081, respectively.

Relative to D0, D1/D2/D3 produced 264/310/294 proteins at FDR < 0.05 and retained 206/227/254 canonical proteins, losing 50/29/2 canonical proteins, respectively. Their all-protein Pearson logFC correlations were 0.4969/0.7817/0.9761, Spearman correlations were 0.5532/0.8111/0.9789, and DEP-set Jaccard similarities were 0.6561/0.6696/0.8581.

D1 caused substantial effect-size distortion and confirms that direct `NA`-to-zero replacement is neither used nor recommended as primary handling. All 29 canonical proteins lost under D2 retained their negative Long-versus-Short effect direction; their median absolute delta-logFC was 0.0400, and none had absolute delta-logFC at least 0.5. D2 sensitivity was therefore mainly statistical-significance sensitivity rather than effect-direction reversal. D2 flagged 30 canonical proteins in total: the 29 losses plus LRP2, whose absolute delta-logFC was approximately 0.506, became more negative, and remained significant. D2 produced six sensitivity-derived Stage 11a pattern changes. D3 retained 254/256 canonical proteins, had 100% canonical direction concordance, and retained all 256 Stage 11a patterns. These results do not establish a preferred imputation method; KNN is not designated the best method.

The local D0 pattern rule reproduced 249 Short_peak and 7 Long_suppression proteins. Exact pattern retention was 244/256 for D1, 250/256 for D2, and 256/256 for D3. These sensitivity results do not alter the frozen 249/7 classification.

The seven canonical `Long_suppression` proteins are NRP1, IL7R, ICAM3, BGN, RARRES2, HSP90AB1, and CSF1R. All seven have complete detection in Control, Short, and Long, remain `Long_suppression` under D0–D3, have unchanged Long-versus-Short logFC values because no values require imputation, and remain at FDR < 0.05. Stage 11b independently placed all seven in C3.

## Validated interpretation

The primary no-imputation analysis remains the canonical frozen analysis. The canonical 256 DEP are not redefined as 227, 254, or any sensitivity-derived set, and neither D2 nor D3 is promoted to the primary analysis.

The principal Long-versus-Short effect directions are robust to alternative missing-value assumptions. Statistical significance for a subset of proteins is sensitive to a left-censored imputation assumption, while the seven canonical `Long_suppression` proteins are completely observed and invariant to all evaluated missing-value treatments.

