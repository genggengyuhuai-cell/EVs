# MANUSCRIPT RESULTS NUMERIC CONTRACT — EV-enriched Plasma Proteomics v2.1

> **Status**: FROZEN · nature-statistics / manuscript preparation
> **Date**: 2026-10-01
> **Analysis version**: analysis-v2.1 (FINAL) · **Frozen commit**: `6d0e004e5025bcf7d564dadaead133809a743a14` · **Tag**: `analysis-v2.1`
>
> **Rule**: **ONLY THE NUMBERS IN THIS DOCUMENT MAY BE USED AS CURRENT MANUSCRIPT RESULTS.**
> Every numeric claim in the manuscript must come from this file. Each value carries its
> meaning, denominator, analysis, multiplicity family (where relevant), and the **allowed**
> manuscript interpretation.
>
> Historical / pre-repair values are listed at the end under `DO_NOT_USE_STALE_NUMBERS` and
> **must not** appear as current results.

---

## 1. COHORT

| Value | Meaning | Denominator | Analysis | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|---|
| **519** | Initial cohort | whole study | Fig1 flow / M01–M11 | — | "Initial cohort n = 519" |
| **515** | Analytical cohort (independent participants) | analytical | Fig1 flow / M11 | — | "Final analytical cohort n = 515" |
| **153** | Control | analytical | design | — | Control group size |
| **186** | Low exposure | analytical | design | — | Low-exposure group size |
| **176** | High exposure | analytical | design | — | High-exposure group size |

Statistical unit = **participant / plasma sample**. Do not use "technical replicate" language.

---

## 2. DISCOVERY / HOLD-OUT SPLIT

| Value | Meaning | Denominator | Allowed interpretation |
|---|---|---|---|
| **386** | Discovery subset | analytical | "Discovery subset n = 386" |
| **129** | Reused hold-out subset | analytical | "reused hold-out subset n = 129"; NOT external validation |
| **271** | Discovery High+Low (ML subset) = 132 High + 139 Low | Discovery High+Low | ML / ROC subset |
| **91** | Hold-out High+Low (ML subset) = 44 High + 47 Low | hold-out High+Low | ML / ROC subset |
| **115** | Discovery Control (derived) | Discovery | = 386 − 271 |
| **38** | Hold-out Control (derived) | hold-out | = 129 − 91 |

---

## 3. PRIMARY DISCOVERY

| Value | Meaning | Denominator | Analysis | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|---|
| **1,445** | Discovery-eligible primary inferential universe | Discovery eligible | D01 eligibility + D03 lock | BH across 1,445 eligible | Denominator for the 85 discovery DEPs |
| **85** | Discovery differentially abundant proteins (DEPs), BH FDR < 0.05 | **1,445** | D02 High−Low, ~0 + dose + environment, eBayes(trend, robust) | BH across 1,445 | "85 discovery DEPs" / "85 proteins meeting the prespecified Discovery FDR criterion" |

> **Hard rule**: 85 is reported against **1,445**, never against 1,430.
> Do NOT write "85 of 1,430 proteins were discovery DEPs."

---

## 4. HOLD-OUT (85 → 83 → 29 → 1)

| Value | Meaning | Denominator | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|
| **85** | Locked discovery candidates evaluated | locked candidates | — | "85 locked candidates evaluated in the reused within-cohort hold-out" |
| **83 / 85** | Direction-concordant | 85 locked | — (descriptive) | "83 showed concordant effect directions" |
| **29 / 85** | Nominal replication (raw P < 0.05) | 85 locked | uncorrected within family | "29 had nominal \(P<0.05\)" |
| **1 / 85** | Candidate-family BH-FDR-supported | 85 locked | BH across the 85-candidate family | "one remained significant after BH correction across the 85-candidate family" |

> Keep 83 / 29 / 1 separate. Do NOT merge into "29 replicated proteins."
> Do NOT call 1 / 85 a "validated biomarker" by itself.

---

## 5. M09 — KNN MISSINGNESS SENSITIVITY

| Value | Meaning | Denominator | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|
| **1,430** | Proteins evaluated | Q515 abundance-model universe | — | Full-cohort Q515 overall-exposure analysis universe |
| **Pearson r = 0.9740605** | Correlation of effect estimates (primary vs KNN) | 1,430 | — | Stability of estimates under the prespecified KNN sensitivity |
| **Spearman rho = 0.9644384** | Same, rank-based | 1,430 | — | Same |
| **1,343 / 1,430 = 93.9161%** | Direction concordance | 1,430 | — | Same |
| **0 / 1,430** | Primary model FDR < 0.05 | 1,430 | BH (1,430) | No proteins met the prespecified FDR threshold |
| **0 / 1,430** | KNN model FDR < 0.05 | 1,430 | BH (1,430) | No proteins met the prespecified FDR threshold |

**Parameters**: `impute::impute.knn`, k = 10, rowmax = 0.5, colmax = 0.8, maxp = 1500;
M05 estimator retained; n = 515; unresolved NA = 0.

**Allowed interpretation**: "Overall-exposure effect estimates were highly concordant under the
prespecified KNN missingness sensitivity analysis."
**Prohibited**: "overall exposure was strongly associated with the proteome" (FDR-significant = 0 / 1,430).

---

## 6. M11 — SITE LEAVE-ONE-OUT SENSITIVITY

| Value | Meaning | Denominator | Allowed interpretation |
|---|---|---|---|
| **9 / 9** site exclusions estimable | Leave-one-site-out fits | 9 sites | Site-specific sensitivity of estimated effects |
| **Pearson 0.790055–0.982702** | Range of effect-estimate correlation across LOO | 1,430 | Sensitivity range; report in text if used |
| **Spearman 0.756893–0.979087** | Range, rank-based | 1,430 | Same |
| **Direction concordance 70.77–93.50%** | Range | 1,430 | Same |

**Interpretation**: leave-one-site-out = **influence diagnostic / sensitivity**, NOT validation,
NOT proof of site independence, NOT exclusion of site confounding. Do not use "site robust" alone.

---

## 7. FIXED-85 MACHINE LEARNING (conditional discrimination)

Discovery High-vs-Low subset n = **271**. Repeated outer CV (5 × 3 = 15 folds).

| Value | Meaning | Denominator | Allowed interpretation |
|---|---|---|---|
| **Elastic Net mean AUROC 0.668688** | Repeated outer CV, mean | 271 / 15 folds | Modest conditional discrimination on the locked 85 candidates |
| **Elastic Net median AUROC 0.662088** | same, median | 271 / 15 folds | same |
| **XGBoost mean AUROC 0.648769** | repeated outer CV, mean | 271 / 15 folds | Modest conditional discrimination on the locked 85 candidates |
| **XGBoost median AUROC 0.657967** | same, median | 271 / 15 folds | same |
| **XGBoost range 0.508598–0.786325** | outer CV range | 271 / 15 folds | spread across folds |
| **LASSO mean AUROC 0.6651** (range 0.4987–0.7749) | repeated outer CV, mean | 271 / 15 folds | supplementary; same conditional framing |

**Tier1** (algorithmic stability / selection criterion — NOT "validated biomarker panel"):
**GAL · TSPAN14 · DMP1 · IGF1 · GOLGA3**

Repaired XGBoost Top10:
**GOLGA3 · NCAM1 · ST3GAL6 · APOD · QSOX2 · HSPG2 · TSPAN14 · APOA5 · TAC3 · GAL**

Top10 intersection (with Tier1): **GAL · GOLGA3 · TSPAN14**
Top20 intersection: **IGF1 · GAL · GOLGA3 · TSPAN14**

**Interpretation**: **conditional** on the already-locked 85 candidates. NOT unbiased end-to-end
pipeline performance, NOT clinical prediction, NOT diagnostic validation.
Keywords: **modest**. Prohibited: strong / accurate / robust classifier / diagnostic performance.

---

## 8. STRICT NESTED MACHINE LEARNING (discovery-stability diagnostic)

| Value | Meaning | Denominator | Allowed interpretation |
|---|---|---|---|
| **15** | Total outer folds | Discovery full | design |
| **7 / 15** | Zero-feature folds (MODEL_NOT_FIT_NO_FEATURES) | 15 | **Must report** — discovery highly sensitive to training-sample composition |
| **8 / 15** | Evaluable / model-fit folds | 15 | Denominator for performance estimates |
| **0 / 0 / 3 / 59 / 536** | Feature count (min / Q1 / median / Q3 / max) | 8 evaluable folds | Fold-local DEP distribution; selection instability |

**LASSO (evaluable folds, conditional on 8):**
- AUROC mean **0.596663** · median **0.596230** · range **0.489418–0.668956**
- AUPRC mean **0.590299** · median **0.580538** · range **0.451429–0.692491**

**Elastic Net (evaluable folds, conditional on 8):**
- AUROC mean **0.593731** · median **0.598341** · range **0.465608–0.662088**
- AUPRC mean **0.582644** · median **0.617635** · range **0.436835–0.650321**

**Feature stability**:
- Appearance ≥ 0.70: **NONE**
- Tier1 nested appearances: GAL **3 / 15 (20.0%)** · TSPAN14 **7 / 15 (46.7%)** ·
  DMP1 **7 / 15 (46.7%)** · IGF1 **6 / 15 (40.0%)** · GOLGA3 **4 / 15 (26.7%)**

**Interpretation**: discovery was highly sensitive to training-sample composition
(feature-selection instability). Do NOT elevate to "biological heterogeneity."

**Mandatory performance wording**:
> Performance estimates were conditional on the eight outer folds in which fold-local discovery
> yielded at least one feature.
> **AND** report: "seven of 15 outer folds yielded no proteins at the prespecified FDR threshold."

**NEVER** write "nested AUROC = 0.60 across 15 folds" (7 / 15 folds had no model fit).

---

## 9. PATHWAY ANALYSES

**cameraPR — PRIMARY PATHWAY INFERENCE**
| Value | Meaning | Denominator | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|
| **GO-BP: 272 tested / 29 significant** | cameraPR, pooled BH-FDR < 0.05 | 1,406 ranked | Prespecified GO-BP + Reactome cameraPR family (pooled) | Primary pathway enrichment |
| **Reactome: 486 tested / 176 significant** | cameraPR, pooled BH-FDR < 0.05 | 1,406 ranked | same | Primary pathway enrichment |
| **Total 205** (29 + 176) | cameraPR significant | — | same | Reactome = 176 / 205 (~86%) of primary pathway results |

**ORA — COMPLEMENTARY**
| Value | Meaning | Denominator | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|
| **GO-BP: 3 significant** | ORA, BH-FDR < 0.05 | foreground 85 / background 1,414 (GO-BP background 153) | Prespecified enrichment family | Complementary enrichment |
| **Reactome: 20 significant** | ORA | same (Reactome background 178) | same | Complementary enrichment |
| **Total 23** | ORA significant | — | same | Complementary, not a second primary test |

**fgsea — SENSITIVITY / SUPPORTING (dual-reported)**
| Value | Meaning | Denominator | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|
| **family-wise 44** (BP 3 / MF 8 / CC 11 / Reactome 22) | padj < 0.05, family-wise | 1,406 ranked / tested 1,016 | family-wise BH | Sensitivity only; Supplement |
| **pooled 41** (BP 6 / MF 7 / CC 10 / Reactome 18) | padj_pooled < 0.05, pooled | same | pooled BH | Sensitivity only; Supplement |

`FGSEA_CANONICAL_FDR = DUAL_REPORTED_SENSITIVITY` · `PRIMARY_INFERENCE = NONE`.

**KEGG = NOT_RUN.**

**Pathway universes (never conflate):**
| Universe | Value |
|---|---|
| Primary Discovery inferential universe | **1,445** |
| Pathway mapping input / tested | **1,434** |
| Unambiguously mapped (ORA background) | **1,414** |
| Multi-gene / ambiguous | **15** |
| Unmapped | **5** |
| Rankable mapped (valid ranking statistic) | **1,406** |

---

## 10. INTERACTION (M10 corrected pure-interaction, sensitivity)

| Value | Meaning | Denominator | Multiplicity family | Allowed interpretation |
|---|---|---|---|---|
| **0 / 1,430** | Exposure × environment interaction FDR-significant | 1,430 (Q515) | Interaction BH | "No exposure × environment interaction survived the prespecified BH-FDR threshold" |

**Prohibited**: "there was no interaction"; "Environment had no modifying effect."
(Not reaching threshold ≠ absence of effect. Parent M10_manifest 1,034 value is superseded.)

---

## 11. DO_NOT_USE_STALE_NUMBERS

These are **historical only** (pre-repair / pre-freeze). They must never appear as current
manuscript results. If found in any draft, replace with the current contract value above.

| Stale value | Deprecated meaning | Replacement (current) |
|---|---|---|
| **M09 Pearson 0.931147** | Pre-repair M09 correlation | **0.9740605** |
| **XGB mean AUROC 0.710294** | Pre-P0 (leakage / direction bug) | **0.648769** |
| **XGB median AUROC 0.686813** | Pre-P0 | **0.657967** |
| **strict nested old 8–618** | Historical fold-local DEP range | **0 / 0 / 3 / 59 / 536** (feature counts) |
| **strict nested old ~0.634 / ~0.629** | Historical AUROC | **LASSO 0.596663 / EN 0.593731** (evaluable folds, conditional) |
| **cameraPR 195** (25 BP + 170 Reactome) | Pre-repair | **205** (29 + 176) |
| **cameraPR 25 + 170** | Pre-repair split | **29 + 176** |
| **old fgsea 39** (3/8/11/17) | Pre-repair family-wise | **44** (family-wise) / **41** (pooled), sensitivity-only |
| **M09 "correlation-weighted Euclidean"** | Pre-Phase-3 repair | Pearson / Spearman as above |
| **M11 old estimand** | Pre-Phase-4 repair | Site-specific sensitivity ranges above |
| **pre-P0 fixed-85 leakage values** | Leakage / which.min direction error | Current fixed-85 values above |

> These values exist only in `pre_repair_snapshot/` / `pre_P0_repair_snapshot/` and are HISTORICAL.
