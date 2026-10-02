# MANUSCRIPT STATISTICS HANDOFF — EV-enriched Plasma Proteomics v2.1

> **Status**: FROZEN · nature-statistics → nature-writing handoff
> **Date**: 2026-10-01
> **Analysis version**: analysis-v2.1 (FINAL) · **Frozen commit**: `6d0e004e5025bcf7d564dadaead133809a743a14` · **Tag**: `analysis-v2.1`
>
> This file is an **index + precedence rule**. It does not itself carry statistics.

---

## 1. The three sole statistical contracts

| # | File | Role |
|---|---|---|
| 1 | `manuscript_v2_1/MANUSCRIPT_STATISTICAL_METHODS_CONTRACT.md` | Design, denominators, contrasts, multiplicity families, sensitivity designations, allowed interpretation for **Methods** |
| 2 | `manuscript_v2_1/MANUSCRIPT_RESULTS_NUMERIC_CONTRACT.md` | The **only** numbers permitted as current manuscript results; includes `DO_NOT_USE_STALE_NUMBERS` |
| 3 | `manuscript_v2_1/MANUSCRIPT_LIMITATIONS_CONTRACT.md` | Fixed limitation statements + wording whitelist / blacklist |

**nature-writing must use these three files as the sole statistical contract.**
No other document may supply statistics, denominators, wording, or limitations to the manuscript.

---

## 2. Precedence rule

- These three contracts take precedence over any historical or working file
  (including `pre_repair_snapshot/`, phase reports, drafts), **provided** they do not conflict
  with the analysis-v2.1 frozen canonical outputs.
- If a conflict arises **between** the three contracts and the frozen canonical outputs
  (freeze handoff / CURRENT_AUTHORITATIVE_RESULTS / claim map), **STOP**:
  `STATISTICAL_CONTRACT_SOURCE_CONFLICT`. Do not silently choose.
- A discrepancy between these contracts and an **older** file is resolved in favor of these
  contracts (the older file is stale).

---

## 3. Hard STOP rule

Any proposed **new numerical result** not present in the Numeric Contract:

> **STOP. Requires a new analysis version / tag.**

- No new statistics, no re-computation of canonical outputs, no re-opening of the statistical
  audit, no new biomarker calculations, and no silent resolution of provenance gaps.
- A change to any frozen numerical result requires a new analysis version + tag, outside
  nature-writing scope.

---

## 4. Frozen headline state (verbatim from analysis-v2.1)

- **PRIMARY INFERENCE** High-vs-Low Discovery: **85 / 1,445**
- **WITHIN-COHORT HOLD-OUT**: **85 → 83 → 29 → 1**
- **ROBUSTNESS**: M09 = sensitivity only · M11 = site-specific sensitivity only
- **ML**: fixed-85 = conditional discrimination · strict nested = discovery stability /
  generalization diagnostic; **7 / 15 zero-feature folds is mandatory reporting**
- **PATHWAY**: cameraPR = primary · ORA = complementary · fgsea = dual-reported sensitivity ·
  KEGG = NOT_RUN
- **OPEN_ANALYSIS = 0**

---

## 5. Non-negotiable wording constraints (carried from contracts)

- 85 uses denominator **1,445**; **1,430** is only the full-cohort Q515 abundance-model universe.
- Hold-out = **reused within-cohort hold-out**; never "external validation" / "validated biomarker."
- Fixed-85 and strict nested are **separate**; performance is **conditional on the 8 evaluable folds**
  and must report the 7 zero-feature folds.
- cameraPR **205** (29 + 176) current; ORA **23** (3 + 20); fgsea **44 / 41** dual; KEGG **NOT_RUN**.
- Pathway universes **1,445 / 1,434 / 1,414 / 1,406** are never conflated.
- Material = **EV-enriched plasma proteomics**.
- QC / provenance limitations are retained; no historical result is promoted to current.
