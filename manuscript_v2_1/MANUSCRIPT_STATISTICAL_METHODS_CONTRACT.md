# MANUSCRIPT STATISTICAL METHODS CONTRACT — EV-enriched Plasma Proteomics v2.1

> **Status**: FROZEN · nature-statistics / manuscript preparation
> **Date**: 2026-10-01
> **Analysis version**: analysis-v2.1 (FINAL) · **Frozen commit**: `6d0e004e5025bcf7d564dadaead133809a743a14` · **Tag**: `analysis-v2.1`
> **OPEN_ANALYSIS**: 0 · **CODE_FREEZE**: COMPLETE
> **Nature manuscript ID reference**: s41586-026-11003-7
>
> **Purpose**: This document is the **sole statistical-methods contract** for manuscript writing.
> Every later Methods paragraph must draw its design, denominators, contrasts, multiplicity
> families, sensitivity designations, and allowed interpretation **from this file**.
> It must NOT be reinterpreted, expanded, or silently corrected during nature-writing.
>
> **Source hierarchy** (in priority order, all FROZEN):
> 1. `audit_output/FINAL_ANALYSIS_FREEZE_HANDOFF.md`
> 2. `docs/CURRENT_AUTHORITATIVE_RESULTS.md` (FROZEN_20261001)
> 3. `docs/post_v2_1_extended_analysis/POST_V2_1_EXTENDED_ANALYSIS_FREEZE.md` (current closure freeze)
> 4. `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` (SOLE authoritative claim map)
> 5. Repaired module reports / canonical results
> 6. Final figure source_data
> 7. Provenance / limitations documents
>
> Historical / `archive/provenance/*_pre_repair_snapshot` material may be used ONLY to confirm
> that an old value is deprecated; it is **never** a manuscript statistics source. The older
> claim map `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` and the older
> `docs/FINAL_REPRODUCIBILITY_AUDIT.md` are archived (historical) under
> `archive/audits/manuscript_claim_map/` and `archive/audits/docs_audits/`, respectively, and are
> not active authority.
>
> **Conflict rule**: if two active frozen sources conflict, **STOP** and flag
> `STATISTICAL_CONTRACT_SOURCE_CONFLICT`. Do not silently choose. (Checked 2026-10-01: no conflict.)

---

## 0. Fixed statistical-evidence hierarchy (manuscript role of each layer)

The manuscript's statistical evidence is fixed to **five layers**. Writing must never present a
lower layer more strongly than the layer above it.

| Layer | Module(s) | Manuscript role | What it supports |
|---|---|---|---|
| **Primary discovery** | D02 High vs Low | **Primary inference** | Discovery of exposure-associated proteins |
| **Hold-out** | D08 reused hold-out | Within-cohort replication check | Direction, nominal, candidate-family FDR support |
| **Robustness** | M09 / M11 / interaction | Sensitivity analyses | Whether the primary effect is sensitive to analysis conditions / site removal |
| **ML** | fixed-85 + strict nested | Exploratory discrimination / stability | Discriminative ability under a candidate set; discovery-process stability |
| **Pathway** | cameraPR / ORA / fgsea / M12B | Biological context | Pathway enrichment, NOT mechanism proof |

> **Rule**: pathway, ML, and hold-out results must never be written more strongly than the
> primary discovery result (85 / 1,445).

---

## A. Study population and analytical unit

Frozen (never re-derived):

| Term | Value |
|---|---|
| Initial cohort | **519** |
| Analytical cohort | **515 independent participants** |
| Control | **153** |
| Low exposure | **186** |
| High exposure | **176** |
| Statistical unit | **participant / plasma sample** |

- Analytical cohort = 515 **independent participants**. Do not use "technical replicate" language
  unless the Methods documents repeated-measurement evidence (it does not in v2.1).
- Study material is described as **EV-enriched plasma proteomics** (see Limitations Contract,
  item 11). It is NOT a pure EV proteome.

---

## B. Discovery / hold-out split

**Frozen split** (prespecified, seed-locked; do not re-word as external):

| Subset | n |
|---|---|
| **Discovery** | **386** |
| **Reused hold-out** | **129** |
| Discovery High+Low (ML / ROC subset) | **271** = 132 High + 139 Low |
| Hold-out High+Low (ML / ROC subset) | **91** = 44 High + 47 Low |
| Discovery Control (derived) | **115** |
| Hold-out Control (derived) | **38** |

**Allowed wording**:
- "a prespecified Discovery subset and a reused within-cohort hold-out subset"

**Prohibited wording**:
- "independent validation cohort"
- "external validation"
- "prospective validation cohort"
- "independent test cohort" (if it would imply fully independent external validation)

> **Standard term (use consistently)**: **reused within-cohort hold-out**.

---

## C. Protein eligibility and statistical universes

The following universes are distinct and **must never be conflated**:

| Universe | Value | Definition / use |
|---|---|---|
| **Primary Discovery inferential universe** | **1,445** | Discovery-eligible proteins; the statistical family for the 85 discovery candidates |
| **Full-cohort Q515 abundance-model universe** | **1,430** | M05 / M09 and other full-515 overall-exposure analyses |
| **Pathway mapping input / tested universe** | **1,434** | Pathway mapping input |
| **Unambiguously mapped universe** | **1,414** | Pathway mapping retained (ORA background) |
| **Multi-gene / ambiguous** | **15** | Excluded from unambiguous mapping |
| **Unmapped** | **5** | Excluded from mapping |
| **Rankable mapped universe** | **1,406** | Proteins with a valid canonical ranking statistic (gene-set ranking input) |

**Hard rule**:
- **1,445** = Discovery-eligible primary inferential universe (D02 / D03 / D08 family).
- **1,430** = full-cohort Q515 abundance-model universe (M05 / M09 / M11 / interaction).
- **NEVER write** "85 of 1,430 proteins were discovery DEPs." If 85 is reported against a
  denominator, that denominator is **1,445**.
- **R03 (closed 2026-10-02)**: author accepted the current three-layer universe. Do **not**
  write "pathway mapping started from the complete 1,445 Discovery universe" — that is factually
  false. Use the distinction in §E below. See `docs/R03_FINAL_AUTHOR_DECISION.md`.

### E. Pathway analysis universe wording (mandatory, post-R03-closure)

Write exactly this distinction in Methods:

- **Discovery differential inference** (85 DEPs) used the **1,445-protein Discovery-eligible
  universe** (D01; frozen Discovery n=386).
- **Pathway mapping** used the **existing full-cohort quantitative mapping registry** (1,434
  proteins; derived from the full 515 cohort).
- **Ranked pathway testing** (cameraPR, fgsea) used **D02 moderated statistics among mapped and
  estimable proteins**, yielding **1,406 rankable proteins**.
- **ORA** used the 85 locked candidates as foreground against the 1,406 mapped/estimable
  background.

Do not collapse these into a single number. Do not manufacture a 1,445-row pathway result.

---

## D. Primary High-vs-Low differential-abundance analysis (D02)

**Core Methods block — use this version.**

- **Analysis subset**: Discovery subset.
- **Outcome / exposure groups**: Control / Low / High.
- **Design (model)**: `~ 0 + dose + environment` — **Environment is a covariate adjustment**.
- **Primary contrast**: **High − Low**.
- **Missingness**: **no expression-matrix imputation in the primary discovery analysis.**
  M09 KNN imputation is a **sensitivity** analysis only; do not write "missing values were
  imputed before differential analysis".
- **Primary workflow (limma)**:
  `lmFit` → `contrasts.fit` (or equivalent contrast specification) → `eBayes(trend = TRUE, robust = TRUE)`.
- **Report**: log2 fold-change / contrast effect estimate; moderated test statistic; nominal P;
  BH-adjusted FDR.
- **Primary significance threshold**: **BH FDR < 0.05**.
- **Result**: **85 / 1,445** discovery candidates.

**Recommended body-text terms** (use one of):
- "85 discovery differentially abundant proteins (DEPs)"
- "85 proteins meeting the prespecified Discovery FDR criterion"

**Prohibited**: "85 validated proteins"; "85 replicated proteins".

---

## E. Hold-out evaluation (D08)

- **85 locked Discovery candidates** are evaluated in the **reused within-cohort hold-out**.
- Report the three levels **separately** — they are different evidence strengths:
  - **Direction concordance**: 83 / 85
  - **Nominal replication** (raw P < 0.05): 29 / 85
  - **Candidate-family BH-FDR-supported** (BH across the 85 locked candidates): 1 / 85
- **Multiplicity family**: the 85 locked discovery candidates. State explicitly:
  *"BH correction was applied across the locked 85-candidate family."*

**Recommended Results wording**:
> Of the 85 locked candidates, 83 showed concordant effect directions in the reused within-cohort
> hold-out, 29 had nominal \(P < 0.05\), and one remained significant after BH correction across
> the 85-candidate family.

**Prohibited** (in hold-out context): "external validation"; "independent validation cohort";
"validated biomarker"; merging 83 / 29 / 1 into "29 replicated proteins".

---

## F. Missingness sensitivity analysis (M09)

- **Role**: **sensitivity analysis** (never a validation; never primary).
- **Sample size**: n = 515. **Proteins**: 1,430 (Q515 abundance-model universe).
- **Imputation**: `impute::impute.knn`, `k = 10`, `rowmax = 0.5`, `colmax = 0.8`, `maxp = 1500`.
- **Estimator**: M05 overall-exposure estimator **retained**.
- **Result**: Pearson r = **0.9740605**, Spearman rho = **0.9644384**,
  direction concordance = **1,343 / 1,430 = 93.9161%**,
  primary FDR < 0.05 = **0 / 1,430**, KNN FDR < 0.05 = **0 / 1,430**; unresolved NA = 0.

**Allowed conclusion**:
> Overall-exposure effect estimates were highly concordant under the prespecified KNN missingness
> sensitivity analysis.

**Prohibited conclusion**:
- Do NOT write "overall exposure was strongly associated with the proteome" on the basis of
  r = 0.974. FDR-significant = **0 / 1,430**. This analysis establishes **stability of effect
  estimates under a prespecified imputation**, not evidence of a significant overall-exposure
  signal.

---

## G. Site leave-one-out sensitivity (M11)

- **Role**: **leave-one-site-out sensitivity** (influence diagnostic, not validation).
- **9 site exclusions**, **9 / 9 estimable**, fixed primary M05 estimator.
- **Environment adjustment retained** in all LOO fits (no unadjusted fallback).
- **Primary estimand / universe / weights**: fixed.
- **Result ranges** (current, frozen): Pearson **0.790055–0.982702**;
  Spearman **0.756893–0.979087**; direction concordance **70.77–93.50%**.

**Correct interpretation**:
> Leave-one-site-out analyses showed site-specific sensitivity of the estimated overall-exposure
> effects.

- Ranges may be reported in the text, but do not use "site robust" as a standalone conclusion.

**Prohibited**: "site independent"; "site effect excluded"; "batch effect eliminated";
"validated across sites"; "LOO eliminates site confounding".

---

## H. Fixed-85 machine learning (conditional discrimination)

- Fixed-85 models **condition on the already locked 85 Discovery candidates**.
- Therefore performance = **conditional discrimination** — NOT:
  - unbiased end-to-end pipeline performance
  - clinical prediction
  - diagnostic validation
- **Analysis subset**: Discovery High-vs-Low, **n = 271**.
- **Repaired procedure** (record in Methods): repeated outer CV (5-fold × 3 repeats = 15 folds);
  nested tuning within outer training; **no outer-test early-stopping leakage**.
- **Results (repaired, current)**: see Numeric Contract — Elastic Net mean AUROC 0.668688 /
  median 0.662088; XGBoost mean AUROC 0.648769 / median 0.657967 / range 0.508598–0.786325.
- **Tier1** (algorithmic stability / selection criterion, not "validated biomarker panel"):
  GAL, TSPAN14, DMP1, IGF1, GOLGA3.

**Required framing**:
> Using the locked 85-candidate set, elastic-net and XGBoost models showed **modest** discrimination…

**Keywords**: **modest**. Prohibited: "strong", "accurate", "robust classifier",
"diagnostic performance", "the model achieved an AUROC of 0.67" without stating the candidate set
was pre-locked.

---

## I. Strict nested machine learning (discovery-stability diagnostic)

- **Design** (per outer-training fold): raw 3,817 proteins → fold-local eligibility →
  D02-compatible limma → Environment-adjusted High-vs-Low discovery → BH FDR < 0.05 →
  selected features → model → **untouched outer test**.
- **No** top-N fallback; **no** threshold relaxation.
- **Result**: outer folds = **15**; **zero-feature folds = 7 / 15**; model-fit/evaluable folds =
  **8 / 15**. Feature count (min / Q1 / median / Q3 / max) = **0 / 0 / 3 / 59 / 536**.
- **Interpretation**: discovery was **highly sensitive to training-sample composition**
  (feature-selection instability). Do NOT elevate this to "biological heterogeneity" — resampling
  instability does not prove true biological heterogeneity.

**Performance reporting rule** (mandatory transparency):
- Performance estimates are **conditional on the 8 evaluable outer folds** in which fold-local
  discovery yielded at least one feature.
- **Must also report**: seven of 15 outer folds yielded no proteins at the prespecified FDR
  threshold.
- **NEVER write** "nested AUROC = 0.60 across 15 folds" (7 / 15 folds had no model fit).

**Values**: see Numeric Contract (LASSO / Elastic Net AUROC and AUPRC on evaluable folds).
Stable feature appearance ≥ 0.70: **NONE**.

---

## J. Pathway analyses

**Fixed hierarchy** (never reorder, never overclaim):

| Method | Role |
|---|---|
| **cameraPR** | **PRIMARY PATHWAY INFERENCE** |
| **ORA** | **COMPLEMENTARY** (not a second primary test) |
| **fgsea** | **SENSITIVITY / SUPPORTING** (Supplement; dual-reported) |
| **KEGG** | **NOT_RUN** |

**cameraPR (primary)**:
- Ranking statistic: D02 environment-adjusted moderated t (no imputation).
- **FDR family**: **pooled across the prespecified primary GO-BP + Reactome cameraPR family**.
- GO-BP: 272 tested / **29** FDR-significant; Reactome: 486 tested / **176** FDR-significant;
  total significant = **205**.
- **Main conclusion**: Reactome accounted for **176 / 205** (~86%) of significant primary pathway
  results → placing Reactome in the main figure (Fig6) is justified.

**ORA (complementary)**:
- **Foreground** = 85 locked candidates; **background** = 1,414 mapped proteins.
- GO-BP: **3** significant (background 153); Reactome: **20** significant (background 178); total **23**.
- Methods must state foreground definition, background definition, and BH family separately.
  Do NOT write 85 and 1,414 as a discovery statistical denominator.

**fgsea (sensitivity / supporting)**:
- `PRIMARY_INFERENCE = NONE`; `ROLE = SENSITIVITY / SUPPORTING`;
  `FGSEA_CANONICAL_FDR = DUAL_REPORTED_SENSITIVITY`.
- family-wise: GO-BP 3, GO-MF 8, GO-CC 11, Reactome 22, **total 44**.
- pooled: GO-BP 6, GO-MF 7, GO-CC 10, Reactome 18, **total 41**.
- Report **both** `padj_family` and `padj_pooled` transparently. Do not write
  "44 pathways were significantly enriched" without stating the multiplicity definition.
- Main text may mention fgsea only as a sensitivity analysis; full 44 / 41 counts live in Supplement.

**KEGG**: **NOT_RUN**. Do NOT write KEGG in Methods; do NOT place an empty KEGG table in the
Supplement implying it was run; do NOT write "KEGG pathway analysis showed…" in Discussion.

**Pathway interpretation boundary** (cameraPR / ORA / fgsea / M12B):
- Support: **enrichment**, **pathway-level association**, **biological context**,
  **coordinated pathway signal**.
- Do NOT support: causal mechanism, "mechanism validated", "pathway activation was demonstrated",
  "regulatory network established".
- M12B network-like figures may be called **"contextual association structure"**, never
  "regulatory network".

---

## K. Multiple-testing correction (families)

Explicit family map (recommended for the Methods / statistics checklist):

| Analysis | Multiplicity family |
|---|---|
| D02 primary discovery | 1,445 Discovery-eligible proteins |
| D08 replication | 85 locked candidates |
| M05 / M09 overall-exposure | 1,430 Q515 proteins |
| cameraPR | Prespecified GO-BP + Reactome primary family (pooled) |
| ORA | Prespecified enrichment family (per canonical output) |
| fgsea | Both family-wise and pooled BH shown; sensitivity only |
| ML | No feature-wise FDR used to define predictive performance |

---

## L. Statistical reporting conventions

- Report **exact nominal P** values when available.
- Adjusted values are reported as **BH-adjusted FDR**. Do not write "corrected P" without
  specifying the correction.
- Do not call nominal P < 0.05 "replicated after multiple testing."
- **FDR < 0.05** is the only label for "multiplicity-adjusted statistical support."
- In D08, **29 nominal vs 1 BH-FDR** must always be kept separate.
- For "0 significant" results (e.g., M09, interaction 0 / 1,430):
  - Allowed: "No proteins met the prespecified FDR threshold."
  - Prohibited: "there was no effect"; "exposure did not interact with environment."
  - Not reaching threshold ≠ proving absence of effect.
- Study material is **EV-enriched plasma proteomics**; never "pure EV proteome" / "EV-specific proteins".

---

## M. Software and reproducibility

Frozen environment (from `docs/SOFTWARE_ENVIRONMENT_LOCK.md`, Phase 7):

- R 4.3.1; limma 3.58.1 (cameraPR, eBayes); fgsea 1.28.0 (fgseaMultilevel, eps = 0, exact);
  org.Hs.eg.db 3.18.0; GO.db 3.18.0; reactome.db 1.86.2; clusterProfiler 4.10.1;
  AnnotationDbi 1.64.1; data.table 1.18.4; statmod 1.5.0.
  - ggplot2 / dplyr / impute / glmnet / xgboost / logistf / ranger: version UNKNOWN (figures /
    M09 / ML / M08 rerun only); record as UNKNOWN.
- RNG: mapping/pathway `set.seed(20260928, kind="Mersenne-Twister")`; split `seed = 20260925`;
  fgsea eps = 0.
- **Python / ML execution environment: NOT_LOCATED / TO_CONFIRM** (see Limitations Contract,
  item 16). Before submission, either locate and record it, or state honestly in the
  Methods / reproducibility statement.
- All pathway counts are bound to the annotation package versions above; a Bioconductor upgrade +
  rerun would change counts.

**Reproducibility rule**: The ML (xgboost / glmnet / sklearn) and P1–P3 Python environments are
not within `F:\env`; record the original interpreter and package versions, or disclose the gap.
