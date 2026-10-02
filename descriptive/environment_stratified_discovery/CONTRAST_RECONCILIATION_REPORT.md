# Contrast Reconciliation Report

> READ-ONLY. No model refit. No BH recompute. No hold-out access.

## Master matrix (BH-FDR<0.05 / estimable universe)

| Population | Low vs Control | High vs Control | High vs Low | Exposure vs Control |
|---|---|---|---|---|
| **Overall Discovery (n=386, 1,445 proteins)** | NA (not exported from D02) | NA (not exported from D02) | **85 / 1,445** | **0 / 1,445** |
| Full cohort Q515 (n=515, 1,430) — reference only | 13 / 1,430 | 0 / 1,430 | 257 / 1,430 | 0 / 1,430 |
| **Humid-heat Discovery (n=209, 1,373)** | 0 / 1,373 | 1 / 1,373 | 0 / 1,373 | 0 / 1,373 |
| **High-altitude Discovery (n=177, 1,394)** | 0 / 1,394 | **75 / 1,394** | 0 / 1,394 | **7 / 1,394** |

---

## What the three key sets are

### The frozen 85 (Overall High vs Low, D02)
- Source: `D02_discovery_primary/D02_Long_vs_Short_all_tested.csv`
- Model: log2 abundance ~ dose + environment on 386 Discovery samples, 1,445 D01-eligible proteins.
- Contrast: High (long-duration) − Low (short-duration). Environment is a covariate.
- BH family: 1,445 D01-eligible proteins. **85 survive BH-FDR<0.05.**
- This is the primary frozen candidate set. It asks: "within dose, does high exposure differ from low exposure?"

### The HA 75 (High-altitude High vs Control, Phase 1)
- Source: `high_altitude/high_altitude_all_tested.csv` (Long_vs_Control contrast)
- Model: log2 abundance ~ 0 + dose on 177 HA Discovery samples, 1,394 Q_HA proteins.
- Contrast: High − Control, within high-altitude only.
- BH family: 1,394 Q_HA proteins. **75 survive BH-FDR<0.05.**
- This asks: "in high-altitude participants, does high exposure differ from control?" It is a different scientific question from the frozen 85 (which compares High vs Low after adjusting for environment).

### The HA 7 (High-altitude Exposure vs Control, Phase 3)
- Source: `exposure_vs_control/high_altitude_exposure_vs_control_all_tested.csv`
- Model: log2 abundance ~ 0 + ExposureGroup on 177 HA samples, 1,394 Q_HA proteins.
- Contrast: (Low + High) − Control, within high-altitude.
- BH family: 1,394 Q_HA proteins. **7 survive BH-FDR<0.05.**
- This asks: "in high-altitude participants, does any exposure (low or high combined) differ from control?"

---

## Why these three sets answer different questions

| Set | Population | Contrast | Universe |
|---|---|---|---|
| Frozen 85 | Overall Discovery 386 | High − Low (env-adjusted) | 1,445 |
| HA 75 | HA only 177 | High − Control | 1,394 |
| HA 7 | HA only 177 | (Low+High) − Control | 1,394 |

- The frozen 85 compare two *exposed* groups (High vs Low). They do **not** compare exposed vs control.
- The HA 75 compare High vs Control within high altitude.
- The HA 7 collapse Low+High and compare the pooled exposed group vs Control within high altitude.

These are not nested subsets of one another by design. They happen to overlap (the 7 HA Exposure-vs-Control proteins are all within the 75 HA High-vs-Control set, because collapsing Low+High attenuates the signal), but they test different null hypotheses.

---

## Set overlap (descriptive)

| Comparison | Intersection | Set A | Set B |
|---|---|---|---|
| Overall HvL 85 vs M07 LVC 13 (Q515 ref) | 1 | 85 | 13 |
| Overall HvL 85 vs M07 HVC 0 (Q515 ref) | 0 | 85 | 0 |
| **HA HvC 75 vs HA EC 7** | **7** | 75 | 7 |
| HA EC 7 in Overall HvL 85 | 1 | 7 | 85 |
| HA EC 7 in M07 HVC (Q515 ref) | 0 | 7 | 0 |
| HA EC 7 in M07 LVC (Q515 ref) | 0 | 7 | 13 |

All 7 HA Exposure-vs-Control discoveries are also in the 75 HA High-vs-Control set. One of the 7 is in the frozen 85.

---

## Critical interpretation rules

1. **"High vs Control significant" + "Low vs Control not significant" ≠ High differs from Low.** The formal High-vs-Low contrast is the only direct test of that question. In HA, both High-vs-Control (75) and High-vs-Low (0) are BH-significant counts; these are different BH families and cannot be compared as if they were the same test.
2. **"HA significant" + "HH not significant" ≠ environment-specific.** Formal Group×Environment interaction is M10 (0/1,430 BH-significant). Cross-environment significance differences reflect power/precision, not proven heterogeneity.
3. **"Exposure vs Control significant" ≠ dose-response.** Exposure collapses Low and High; a significant pooled effect can arise from High alone, Low alone, or both. The trajectory descriptor is purely descriptive.
4. **Overall LVC/HVC on the frozen 386/1,445 universe were not exported.** M07 numbers (13 LVC, 0 HVC) come from the full-cohort Q515/1,430 universe (515 samples including hold-out) and are **not** the frozen Discovery 386 results. Do not conflate.

---

## Outputs

```
results/contrast_reconciliation/
  ALL_CONTRAST_MASTER_MATRIX.csv
  OVERALL_CONTRAST_SUMMARY.csv
  SIGNIFICANT_SET_OVERLAP.csv
  FROZEN85_ALL_CONTRAST_RECONCILIATION.csv
  HA75_HA7_RECONCILIATION.csv
CONTRAST_RECONCILIATION_REPORT.md
```

CONTRAST_RECONCILIATION = PASS
