# Freeze 3C — Accession-Level cRAP Reconciliation

**Status: CANDIDATE REGISTRY — awaiting investigator review. No exclusion applied.**
**Date:** 2026-09-27 (Freeze 3C revision)
**cRAP source:** GPM common Repository of Adventitious Proteins (cRAP), version 2012.01.01
**Method:** True UniProt accession exact-intersection of U0 (3,817 protein groups) against fixed cRAP accession table.
**Protocol authority:** `docs/protocol/ANALYSIS_PLAN_v2.0.md`, Module 03.

---

## 0. Freeze 3B error correction

Freeze 3B classified 10 keratins as "A3_CONFIRMED_SOURCE" based on gene-symbol reasoning rather than true accession-level cRAP membership. Freeze 3C corrects this:

| Freeze 3B label | Freeze 3C correction | Count |
|---|---|---:|
| KRT5, KRT6A, KRT6B, KRT14, KRT16, KRT19 marked as exact | **Demoted to A3_KERATIN_NOT_IN_CRAP** — these are NOT confirmed in cRAP dust/contact | 6 |
| Hair keratins (KRT31, KRT36, KRT38, KRT84) labeled "KRT-only" | **Promoted to A3_EXACT_HAIR_CONTACT** — these ARE cRAP entries under old names (K1H1/K1H8/K1HB/KRHB4) | 4 |
| Missed salivary contact proteins | **Newly detected: A3_EXACT_SALIVARY_CONTACT** (AMY1 salivary amylase + PRH2 salivary proline-rich) | 2 |

---

## 1. cRAP source definition (corrected)

| Item | Value |
|---|---|
| External reference | GPM cRAP 2012.01.01 |
| Source membership | Preserves original cRAP semantics, including Category 4 human UPS |
| Project exclusion eligibility | Separated from source membership |
| Human UPS proteins | Are cRAP source members, but V2_technical_exclusion_eligible = FALSE (no spike-in evidence) |
| Repository UPS spike-in evidence | **NONE FOUND** |
| Method | UniProt accession exact-match; no gene-symbol or description matching for cRAP membership |

---

## 2. Exact cRAP intersection with U0

### 2.1 A1 — Non-human laboratory reagents: **0**
BSA, trypsin, caseins, egg white, Lys-C, chymotrypsin — none found.

### 2.2 A2 — Non-human standards: **0**
Horse cytochrome c, equine myoglobin — none found.

### 2.3 A3_EXACT_SKIN_CONTACT (4 protein groups)

| PG.ProteinGroups | Accession | Gene | cRAP entry name |
|---|---|---|---|
| P04264 | P04264 | KRT1 | KRT1_HUMAN |
| P35908 | P35908 | KRT2 | KRT2_HUMAN |
| P35527 | P35527 | KRT9 | K1C9_HUMAN |
| P13645 | P13645 | KRT10 | K1C10_HUMAN |

### 2.4 A3_EXACT_HAIR_CONTACT (4 protein groups)

| PG.ProteinGroups | Accession | Gene | cRAP old entry name |
|---|---|---|---|
| Q15323 | Q15323 | KRT31 | K1H1_HUMAN |
| O76013 | O76013 | KRT36 | K1H8_HUMAN |
| O76015 | O76015 | KRT38 | K1HB_HUMAN |
| Q9NSB2 | Q9NSB2 | KRT84 | KRHB4_HUMAN |

### 2.5 A3_EXACT_SALIVARY_CONTACT (2 protein groups)

| PG.ProteinGroups | Accession(s) | Gene(s) | cRAP entry name |
|---|---|---|---|
| P0DTE7;P0DTE8;P0DUB6 | 3 accessions | AMY1A/AMY1B/AMY1C | AMY1A/B/C_HUMAN (salivary alpha-amylase) |
| P02810 | P02810 | PRH2 | PRP1_HUMAN (salivary proline-rich phosphoprotein) |

The AMY1 group is the only multi-accession technical candidate (ALL_TECHNICAL_CANDIDATE = 1).

### 2.6 A3_KERATIN_NOT_IN_CRAP (26 protein groups)
Human keratins whose accessions are NOT in the cRAP 2012.01.01 dust/contact list.
Includes: KRT3, KRT4, KRT5, KRT7, KRT8, KRT13, KRT14, KRT16, KRT17, KRT18, KRT19,
KRT20, KRT23, KRT25, KRT27, KRT28, KRT71, KRT72, KRT76, KRT77, KRT78, KRT79, KRT80,
plus KRTDAP. Retained in primary.

### 2.7 A3_OTHER_AMBIGUOUS (5 protein groups)
FLG, HRNR, KPRP, KCT2, SPRR3 — epidermal proteins not confirmed as cRAP contact.

---

## 3. Summary table

| Category | Count | Primary exclusion? |
|---|---:|---|
| A1 non-human reagent | 0 | — |
| A2 non-human standard | 0 | — |
| A3 exact skin contact | 4 | YES (pending investigator) |
| A3 exact hair contact | 4 | YES (pending investigator) |
| A3 exact salivary contact | 2 | YES (pending investigator) |
| A3 keratin not in cRAP | 26 | No (retain) |
| A3 other ambiguous | 5 | No (retain) |
| B endogenous plasma | 5 | — |
| B UPS reference (cRAP member, not exclusion target) | 55 | No (retain by context) |
| C preanalytical markers | 34 | No (retain + annotate) |
| **Total candidate rows** | **135** | |

---

## 4. Projected Utech sizes (proposed, NOT generated)

| Scenario | Excluded count | Projected Utech |
|---|---:|---:|
| Primary: exact A1+A2+A3 contact (skin+hair+salivary) | 10 | **3,807** |
| Sensitivity: retain all human A3 (keep keratins not in cRAP) | 0 | 3,817 |
| Extreme: exclude all A3 candidates (41 total) | 41 | 3,776 |

---

## 5. Sensitivity universe names

| Name | Definition |
|---|---|
| `Utech_primary` | U0 minus exact cRAP contact (A1+A2+skin+hair+salivary) = ~3,807 |
| `Utech_sensitivity_retain_A3` | U0 minus exact A1+A2 only = 3,817 |
| `Utech_sensitivity_exclude_all_A3` | U0 minus all 41 A3 candidates = 3,778 (extreme, never default) |

---

## 6. What was NOT done

- No Utech list was generated
- No Q515 or D515 was computed
- No protein was actually excluded
- No inferential analysis was run
- No frozen source was modified
- No historical result was overwritten