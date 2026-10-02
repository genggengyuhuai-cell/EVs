# D02 Pairwise Completion Report

> Computes Overall Low-vs-Control and High-vs-Control on the SAME frozen D02 framework (386 Discovery, 1,445 proteins, `~0+dose+environment`, eBayes trend=TRUE robust=TRUE). Frozen High-vs-Low 85 result untouched.

## Overall Discovery 4-contrast matrix (BH-FDR<0.05 / estimable)

| Contrast | N_estimable | N raw P<0.05 | **N BH-FDR<0.05** | median log2FC | median |log2FC| |
|---|---|---|---|---|---|
| Low vs Control | 1,445 | 114 | **0** | +0.067 | 0.110 |
| High vs Control | 1,445 | 145 | **0** | −0.105 | 0.135 |
| High vs Low (frozen D02) | 1,445 | 365 | **85** | −0.156 | — |
| Exposure vs Control (Phase 3) | 1,445 | 65 | **0** | −0.018 | — |

## Model consistency check

- Long_vs_Short recomputed from this script matches frozen D02 to machine precision: max|Δlog2FC| = 5.0e-16, max|ΔP| = 7.8e-16. The model, design, and expression matrix are identical to frozen D02.
- Frozen D02 output SHA unchanged: `27FA732C…`.

## Frozen-85 trajectory (descriptive only)

Among the 85 frozen High-vs-Low proteins:

| Trajectory descriptor | Count |
|---|---|
| Low and High in opposite directions vs Control | 66 |
| High-only shift (Low ≈ Control) | 18 |
| Other/unclear | 1 |

Interpretation: the 85 frozen proteins are predominantly **bidirectional** (Low shifts one way, High shifts the other) or **High-only** shifts. This explains why neither Low-vs-Control nor High-vs-Control survives BH-FDR on its own: the signal in most frozen proteins is the *difference* between Low and High, not a uniform shift away from Control.

## Overlap with environment results

| Comparison | Intersection | Set A | Set B |
|---|---|---|---|
| Overall LVC discoveries (0) ∩ frozen HvL 85 | 0 | 0 | 85 |
| Overall HVC discoveries (0) ∩ frozen HvL 85 | 0 | 0 | 85 |
| Overall LVC (0) ∩ HA HvC 75 | 0 | 0 | 75 |
| Overall HVC (0) ∩ HA HvC 75 | 0 | 0 | 75 |
| Overall LVC (0) ∩ HA EC 7 | 0 | 0 | 7 |
| Overall HVC (0) ∩ HA EC 7 | 0 | 0 | 7 |
| HA EC 7 ∩ Overall LVC | 0 | 7 | 0 |
| HA EC 7 ∩ Overall HVC | 0 | 7 | 0 |
| HA EC 7 ∩ frozen HvL 85 | 1 | 7 | 85 |

## Interpretation boundaries

- 0 Overall LVC / HVC BH discoveries does **not** mean "Low has no effect" or "High has no effect" — it means neither contrast survives BH-FDR correction across 1,445 proteins on its own.
- The 85 frozen HvL proteins represent High-vs-Low differences; they are not exposed-vs-control hits.
- "HA HvC = 75" + "Overall HvC = 0" is a power/stratification statement, not proof of high-altitude specificity.
- Trajectory classification is descriptive; it is not a new inferential test.

## Outputs

```
descriptive/discovery_validation/D02_pairwise_completion/
  code/D02_pairwise_completion.R
  results/overall_low_vs_control_all_tested.csv
  results/overall_low_vs_control_discoveries.csv   (0 rows)
  results/overall_high_vs_control_all_tested.csv
  results/overall_high_vs_control_discoveries.csv  (0 rows)
  results/overall_pairwise_summary.csv
  results/frozen85_overall_pairwise_reconciliation.csv
  results/HA75_HA7_overall_overlap.csv
  diagnostics/model_validation.csv
  diagnostics/input_hashes.csv
```

D02_PAIRWISE_COMPLETION = PASS
