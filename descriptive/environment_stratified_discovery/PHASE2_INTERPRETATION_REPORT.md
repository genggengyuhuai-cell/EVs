# Phase 2 Interpretation Report
## Environment-Stratified De Novo Discovery — Reconciliation with Frozen Results

> Discovery-only. No hold-out materialized. No frozen result modified.
> Generated post Phase 1; primary Long_vs_Short discovery sets are empty in both environments.

---

## 1. Hold-out status

**ENV_STRAT_PRIMARY_HOLDOUT_REPLICATION = NOT_APPLICABLE_ZERO_DISCOVERIES**

Reason: prospectively defined environment-specific primary discovery sets (Long_vs_Short BH-FDR < 0.05) are empty in HH (0) and HA (0). No 1,445×129 hold-out matrix was materialized; no Validation outcomes were opened. Evidence chronology preserved.

---

## 2. Factual anchors

| Item | Value |
|---|---|
| Pooled D02 Long_vs_Short discovery | 85 proteins (frozen) |
| HH de novo Long_vs_Short BH-FDR<0.05 | 0 |
| HA de novo Long_vs_Short BH-FDR<0.05 | 0 |
| Canonical M10 Group×Environment BH-FDR<0.05 | 0 / 1,430 (whole universe) |
| M10 BH-FDR<0.05 among frozen 85 | 0 / 85 |
| M10 nominal P<0.05 among frozen 85 | 13 / 85 |

---

## 3. Effect stability (frozen 85, Long_vs_Short)

| Metric | Value |
|---|---|
| HH vs D02 Pearson r | 0.590 |
| HH vs D02 Spearman ρ | 0.477 |
| HA vs D02 Pearson r | 0.683 |
| HA vs D02 Spearman ρ | 0.615 |
| HH vs HA Pearson r | −0.178 |
| HH vs HA Spearman ρ | −0.289 |
| HH same sign as D02 | 85/85 (100%) |
| HA same sign as D02 | 85/85 (100%) |
| Both HH & HA same sign as D02 | 85/85 (100%) |
| HH and HA same sign with each other | 85/85 (100%) |
| median |log2FC| D02 | 0.330 |
| median |log2FC| HH | 0.408 |
| median |log2FC| HA | 0.264 |
| median SE HH | 0.155 |
| median SE HA | 0.118 |

**Interpretation**: Within the frozen 85, direction is 100% concordant across pooled D02 and both environment strata. Effect magnitudes correlate moderately with the pooled estimate (r=0.59 HH, r=0.68 HA). The HH-vs-HA correlation is near zero/slightly negative despite 100% sign agreement — i.e., the *ranking* of effect magnitudes differs across environments, but all 85 move in the same direction. This is **not** evidence of heterogeneity; it is expected when within-stratum power is reduced and residual variance differs.

---

## 4. Why no environment-stratified FDR discovery despite 85 pooled hits?

- Pooled D02 models 386 samples with environment as a covariate; it borrows power across both environments.
- Stratified HH model uses 209 samples; stratified HA uses 177. Per-environment BH correction over 1,373 / 1,394 tests.
- Median SE rises (HH 0.155, HA 0.118) versus pooled; raw P<0.05 counts are 207 (HH) and 231 (HA) but none survive BH-FDR<0.05 for Long_vs_Short.
- This is a **power/precision** statement, not evidence that the 85 are false positives or that effects vanish. Direction is 100% preserved.

---

## 5. Formal heterogeneity (M10)

- 0/1,430 whole-universe Group×Environment interactions survive BH-FDR.
- 0/85 frozen-85 interactions survive BH-FDR.
- 13/85 frozen-85 have nominal P<0.05; these are **not** labeled environment-specific. They are flagged for descriptive reference only.
- No ranking-based biological claim is made from nominal P.

---

## 6. Supportive HA Long_vs_Control (75 proteins)

- HA Long_vs_Control: 75 BH-FDR<0.05 (supportive contrast, not primary).
- HH Long_vs_Control: 1 BH-FDR<0.05.
- Trajectory descriptors (descriptive only, from already-fitted contrasts):
  - 52 / 75: "Long shifted vs Control, Low intermediate" (monotonic dose trend in HA)
  - 22 / 75: "Long shifted vs Control, Low similar to Control"
  - 1 / 75: "Low and Long similar"
- These are **not** labeled dose-response, biomarker, or environment-specific. M10 interaction evidence for these proteins is tabulated but 0/75 are BH-significant.
- This contrast does not enlarge the primary Long_vs_Short discovery set.

---

## 7. Cross-environment effect comparison (all eligible shared proteins, n=1,323)

| Contrast | N compared | Pearson | Spearman | Direction concordance |
|---|---|---|---|---|
| Long_vs_Short | 1,323 | 0.030 | 0.064 | 70.9% |
| Long_vs_Control | 1,323 | −0.197 | −0.080 | 53.1% |
| Short_vs_Control | 1,323 | −0.130 | −0.059 | 36.2% |

Across the full eligible universe, environment-stratified effect estimates are weakly correlated (near-zero Pearson) with direction concordance only slightly above chance for Short_vs_Control (36%). This is descriptive; formal heterogeneity is assessed only by M10 (0 BH-significant).

---

## 8. Interpretation boundaries

**Facts**:
- Pooled D02 identified 85 Long_vs_Short proteins.
- Environment-stratified de novo Long_vs_Short identified 0 HH and 0 HA FDR discoveries.
- M10 identified 0/1,430 BH-significant Group×Environment interactions.
- Within the 85, direction is 100% concordant across strata.

**Do NOT conclude**:
- The pooled 85 are false positives.
- Effects exist only because environments were combined.
- Effects are environment-specific.
- Proven homogeneity (M10 is underpowered, not a homogeneity proof).
- There is no environment effect (absence of BH-significant interaction ≠ no effect).
- HA Long_vs_Control = dose-response (supportive contrast only; not promoted).

**What the data support**:
- The 85 pooled hits have directionally concordant effects in both environments; reduced within-stratum power explains the absence of stratified FDR discoveries.
- No protein has formal BH-significant evidence of Group×Environment interaction.

---

## 9. Outputs

```
results/comparison/frozen85_environment_effect_reconciliation.csv   (85 rows)
results/comparison/frozen85_effect_stability_summary.csv
results/comparison/frozen85_M10_interaction_summary.csv
results/comparison/allprotein_cross_environment_effect_summary.csv
results/comparison/HA_Long_vs_Control_75_supportive.csv            (75 rows)
results/comparison/HA_Long_vs_Control_trajectory_summary.csv
```

Frozen files (D02/D03/D05/M10, split assignment, D01 eligible matrix) read-only; hashes unchanged.
