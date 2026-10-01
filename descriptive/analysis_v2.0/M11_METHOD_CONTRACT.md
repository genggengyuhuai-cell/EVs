# M11 Site Leave-one-out Method Contract

Status: `FROZEN_PROTOCOL_IMPLEMENTATION_CONTRACT`.

Authority: `docs/protocol/ANALYSIS_PLAN_v2.0.md`, Module 11, with the scientific role retained by `ANALYSIS_PLAN_v2.1` section 9.

## Purpose

M11 asks how sensitive the frozen M05 overall-exposure effect estimates are to exclusion of one Site while preserving the primary analysis contract as far as the reduced design permits. It is a descriptive influence/robustness analysis, not candidate generation, independent replication, validation, transportability testing, or proof that Site/batch confounding has been removed.

## Reference contract

| Component | Contract |
|---|---|
| Primary reference | M05 overall-exposure abundance analysis |
| Population | Full analytical cohort, n=515 before deletion |
| Protein universe | Fixed Q515 parent universe, 1,430 protein groups |
| Abundance scale | Existing log2 abundance matrix |
| Missingness | Observed-value limma modeling; no imputation |
| Exposure coding | Control, Low, High from `TREAT1_clean` |
| Site | Metadata field `group`; nine prespecified Sites |
| Environment | `Humid_hot` for FJ/GZ Sites; `High_altitude` for XZ Sites |
| Primary design | `~0 + Group + Environment` |
| Target estimand | M05 cohort-weighted overall-exposure effect E |
| Fixed contrast | `(186/362) × mu_Low + (176/362) × mu_High − mu_Control` |
| Weighting rule | Fixed mathematical contrast coefficients from the full 515-person M05 contract; they are not recomputed after Site deletion |
| Exact contrast implementation | `limma::contrastAsCoef` followed by refitting |
| Moderation | `limma::eBayes(trend=TRUE, robust=TRUE)` |
| Primary family | A-E BH across fixed Q515; LOO creates no new confirmatory significance family |
| LOO unit | Remove one entire Site at a time; nine deletion fits |
| Eligibility | `FIXED_UNIVERSE`; Q515 membership is not recomputed in reduced subsets |

For descriptive P/FDR comparison, each estimable LOO fit applies the same BH operation across the fixed 1,430-protein Q515 family. These LOO-adjusted values are sensitivity diagnostics and do not constitute a new inferential discovery family.

## Estimability contract

For every Site deletion, the run records sample counts, remaining Sites, remaining Group and Environment levels, design rank, design columns, and contrast availability. A protein is estimable only when the M05 group-support rule remains satisfied (at least ten observed values in Control, Low, and High), the model result is finite, and the reduced fit provides residual information.

If a deletion loses a required Group or Environment level, produces a rank-deficient design, aliases the E contrast, or otherwise prevents the primary estimator from being fitted, its status is `NONESTIMABLE_UNDER_PRIMARY_CONTRACT`. No `~Group` fallback, weight recomputation, universe reselection, imputation, or other rescue is permitted.

## Outputs and figure dependency

Required outputs are per-protein × Site comparisons, per-Site summaries, an old-versus-repaired comparison, the method/reporting audit, and a Fig. 4 impact note. Fig. 4c reads M11 Site composition and Fig. 4d reads the LOO stability summary. The final figure pipeline is not run in Phase 4.

The locked 85 candidates are not the M11 analysis universe. Fig. 4 source data may carry a candidate-membership display flag, but this does not redefine M11 or require candidate-specific inference.
