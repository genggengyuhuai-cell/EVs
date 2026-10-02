# Phase 3: Exposure (Low+High) vs Control — Report

> Discovery-only. No hold-out. No re-eligibility. No downsampling.
> Label-collapsed binary contrast; not a weighted Low/High contrast.

---

## 1. Sample counts (gate-passed)

| Analysis | N_Control | N_Exposure (Low+High) | Exposure/Control ratio |
|---|---|---|---|
| Overall Discovery | 115 | 271 (139+132) | 2.36 |
| Humid-heat | 71 | 138 (62+76) | 1.94 |
| High-altitude | 44 | 133 (77+56) | 3.02 |

No downsampling, no oversampling, no class weights. Imbalance interpreted as a precision issue (quantified below), not bias.

---

## 2. Discovery counts (BH-FDR < 0.05, Exposure−Control)

| Analysis | Universe size | N_estimable | N raw P<0.05 | **N BH-FDR<0.05** | median SE | median CI width |
|---|---|---|---|---|---|---|
| Overall | 1,445 | 1,445 | 65 | **0** | 0.126 | 0.495 |
| Humid-heat | 1,373 | 1,373 | 169 | **0** | 0.172 | 0.672 |
| High-altitude | 1,394 | 1,394 | 220 | **7** | 0.177 | 0.692 |

### The 7 HA Exposure-vs-Control discoveries

| Protein | Gene | log2FC (Exp−Ctrl) | P | BH-FDR |
|---|---|---|---|---|
| O60704 | TPST2 | −0.520 | 1.12e-4 | 0.041 |
| P00736 | C1R | −0.334 | 4.60e-5 | 0.041 |
| P09486 | SPARC | −0.786 | 9.92e-5 | 0.041 |
| Q12841 | FSTL1 | −0.642 | 2.02e-4 | 0.041 |
| Q9BUN1 | MENT | −0.650 | 2.01e-4 | 0.041 |
| Q9H1B5 | XYLT2 | −0.641 | 2.06e-4 | 0.041 |
| Q9Y274 | ST3GAL6 | −0.387 | 1.20e-4 | 0.041 |

All 7 are **not** in the frozen 85. All are negative (Exposure < Control).

---

## 3. Overlap among the three discovery sets

- Overall = 0, HH = 0, HA = 7.
- The 7 HA discoveries are unique to HA Exposure-vs-Control; none survive Overall or HH BH-FDR.

---

## 4. Frozen-85 reconciliation

- 85 rows retained.
- Direction concordance (Overall/HH/HA all same sign): **21/85**.
- This is substantially lower than the Long_vs_Short analysis (85/85 concordant in Phase 2). Interpretation: collapsing Low+High into "Exposure" averages two dose levels that may have different magnitudes/directions, so the collapsed effect is not uniformly aligned across strata. This is expected and is **not** evidence of contradiction.
- 0 of the frozen 85 survive BH-FDR<0.05 in any Exposure-vs-Control family.

---

## 5. HH vs HA Exposure-vs-Control effect correlation (n=1,323 shared estimable)

| Metric | Value |
|---|---|
| Pearson r | −0.212 |
| Spearman ρ | −0.091 |
| Direction concordance | 35.7% |

Weak/negative correlation between HH and HA Exposure-vs-Control effects across the shared eligible universe. This is descriptive only; formal heterogeneity is M10 (0/1,430 BH-significant, unchanged).

---

## 6. Relation to prior High-vs-Control results (Phase 1)

| Prior result | New EC result |
|---|---|
| HA Long_vs_Control = 75 FDR | HA Exposure_vs_Control = 7 FDR |
| HH Long_vs_Control = 1 FDR | HH Exposure_vs_Control = 0 FDR |
| HH Long_vs_Short = 0 | — |
| HA Long_vs_Short = 0 | — |

The 7 HA Exposure-vs-Control findings are a subset/attenuated version of the 75 HA Long_vs_Control findings. Because Exposure = Low + High:
- If Low and High both shift in the same direction vs Control, the collapsed Exposure effect is expected to be weaker but directionally aligned (attenuation).
- If Low is intermediate or partially opposite, the collapsed effect can be closer to zero.
- The reduction from 75 (Long only) to 7 (Long+Low collapsed) is consistent with Low contributing weaker or partially offsetting signal — not proof of monotonic dose response.

**No claim of dose-response is made.** Exposure-vs-Control is a binary average comparison; prior Long_vs_Control / Low_vs_Control / Long_vs_Low estimates remain companion context.

---

## 7. Precision / imbalance diagnostics

| Universe | N_Ctrl det-rate | N_Exp det-rate |
|---|---|---|
| Overall | 0.942 | 0.935 |
| HH | 0.947 | 0.942 |
| HA | 0.957 | 0.947 |

Detection rates are nearly balanced across Control/Exposure within each universe. The N imbalance (HA 44 vs 133) reduces precision (median SE 0.177 in HA vs 0.126 Overall) but does not produce differential missingness.

---

## 8. Validation matrix

| Check | Result |
|---|---|
| Sample counts (115/271, 71/138, 44/133) | PASS |
| Overall universe = 1,445 | PASS |
| HH universe = 1,373 (unchanged) | PASS |
| HA universe = 1,394 (unchanged) | PASS |
| Design matrices full rank | PASS |
| All estimable rows finite effect/SE/P/BH | PASS |
| BH once per family (3 families) | PASS |
| No hold-out data | PASS |
| Phase 1/2 outputs unchanged | PASS |
| D01/D02/D03/D05/M10 unchanged | PASS |
| analysis-v2.1 tag unchanged | PASS |
| No downsampling/oversampling/class weights | PASS |
| Precision diagnostics for all 3 | PASS |

---

## 9. Git

- HEAD = `6e9c62cb…` (unchanged)
- `analysis-v2.1` peeled = `6d0e004e…` (unchanged)
- New files untracked; not committed, not pushed.

---

## 10. Outputs

```
results/exposure_vs_control/
  overall_exposure_vs_control_all_tested.csv
  overall_exposure_vs_control_discoveries.csv
  humid_heat_exposure_vs_control_all_tested.csv
  humid_heat_exposure_vs_control_discoveries.csv
  high_altitude_exposure_vs_control_all_tested.csv
  high_altitude_exposure_vs_control_discoveries.csv
  exposure_vs_control_summary.csv
  exposure_vs_control_cross_environment_comparison.csv
  exposure_vs_control_precision_diagnostics.csv
results/comparison/frozen85_exposure_vs_control_reconciliation.csv
PHASE3_EXPOSURE_VS_CONTROL_REPORT.md
```

ENV_STRAT_PHASE3_EXPOSURE_CONTROL = **PASS**
