# Freeze 3 — Final Contaminant Policy

**Status: FROZEN — Investigator approved 2026-09-26**
**Date:** 2026-09-27
**cRAP source:** GPM common Repository of Adventitious Proteins (cRAP), version 2012.01.01
**Protocol authority:** `docs/protocol/ANALYSIS_PLAN_v2.0.md`, Module 03

---

## 1. Source / version

| Item | Value |
|---|---|
| External source | GPM cRAP 2012.01.01 |
| Reference table | `registry/crap_2012_01_01_project_reference.csv` (11 accessions — project-relevant intersection only, NOT complete cRAP) |
| Matching rule | UniProt accession exact-intersection; no gene-symbol or description matching for cRAP membership |
| UPS spike-in evidence | NONE FOUND in repository |

---

## 2. Primary exclusion rule (Category A)

**Primary EXCLUDE** only:
1. Exact non-human laboratory reagent accessions (A1) — **0 found in U0**
2. Exact non-human standard accessions (A2) — **0 found in U0**
3. Exact cRAP human skin-contact keratin accessions — **4** (KRT1, KRT2, KRT9, KRT10)
4. Exact cRAP human hair-contact keratin accessions — **4** (KRT31, KRT36, KRT38, KRT84)

**Total primary exclusion: 8 protein groups.**

**NOT excluded by rule:**
- "Any cRAP human contact → automatically exclude" is NOT a rule.
- AMY1 (salivary amylase): cRAP member but RETAIN with contact flag (plasma/EV biology plausible).
- PRH2 (salivary proline-rich): NOT cRAP; RETAIN with contact flag.
- Non-cRAP human keratins: RETAIN.
- Human UPS overlap: RETAIN_BY_CONTEXT.
- Category B endogenous plasma: RETAIN.
- Category C preanalytical markers: RETAIN + annotate.

---

## 3. Multi-accession rule

- Protein group excluded only if **all** constituent accessions are confirmed primary exclusion targets.
- Mixed human biological + cRAP contact: MIXED_SOURCE_MATCH → RETAIN primary.
- AMY1 group (P0DTE7;P0DTE8;P0DUB6): all 3 accessions are human salivary amylase variants. Status: MIXED_SOURCE_MATCH. Not primary exclusion (project policy).

---

## 4. Special handling

| Protein | Source fact | Project action | Reason |
|---|---|---|---|
| AMY1 (P0DTE7/P0DTE8/P0DUB6) | cRAP member (HUMAN_SALIVA) | RETAIN_WITH_CONTACT_FLAG | Salivary amylase is biologically plausible in plasma/EV; not definite technical contaminant. SENS-2 candidate. |
| PRH2 (P02810) | NOT cRAP | RETAIN_WITH_CONTACT_FLAG | Salivary protein but not in cRAP 2012.01.01. |
| Human UPS (55 groups) | cRAP Category 4 member | RETAIN_BY_CONTEXT | No spike-in evidence; endogenous plasma proteins. |

---

## 5. Sensitivity universes (defined, NOT generated)

| Name | Definition | Projected N |
|---|---|---:|
| `Utech_primary` | U0 minus 8 primary exclusion (skin+hair keratins) | **3,809** |
| `Utech_sens1_retain_A3` | U0 minus A1+A2 only (= all human A3 retained) | 3,817 |
| `Utech_sens2_exclude_cRAP_contact` | Primary 8 + AMY1 (9 total) | 3,808 |
| `Utech_sens3_exclude_all_A3` | All 41 A3 candidates (extreme) | 3,776 |

---

## 6. Final counts

| Metric | Value |
|---|---:|
| U0 | 3,817 |
| Primary exclusion N | 8 |
| Projected Utech_primary | 3,809 |
| SENS-1 | 3,817 |
| SENS-2 | 3,808 |
| SENS-3 | 3,776 |
| Unresolved (MIXED_UNRESOLVED) | 0 |
| cRAP source members in U0 | 11 accessions (8 primary + 3 AMY1) |
| UPS reference (retain) | 55 groups |

---

## 7. Freeze 3 status

**READY_TO_FREEZE** — pending investigator approval.

Investigator must confirm:
1. 8 primary exclusion keratins (4 skin + 4 hair) are approved
2. AMY1 retain-with-flag policy is approved
3. SENS-2 / SENS-3 definitions are approved
4. Utech_primary = 3,809 is approved as the starting universe for V2-02

Upon investigator approval, this policy becomes FROZEN.

## 8. AMY1 provenance correction

cRAP 2012.01.01 source entry uses historical accession **P04745 / AMYS_HUMAN**.
Current data accessions **P0DTE7, P0DTE8, P0DUB6** are recorded as:
*mapped to cRAP source entry P04745 through documented accession equivalence*.

These are not literal exact cRAP accession matches; they are current UniProt
accessions that map to the historical cRAP entry. Source fact and project
action remain strictly separated. This does not change any exclusion decision.