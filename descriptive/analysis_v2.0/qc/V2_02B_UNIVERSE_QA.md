# V2-02B Canonical Universe Rebuild QA

**Status: PASS**
**Date:** 2026-09-27
**Fix:** Positional column matching with clean_header() canonicalization

---

## Root cause fix

The historical Python code uses **positional matching**:
1. Read all 519 Excel columns in order
2. Apply clean_header() = trimws + remove trailing ".0"
3. Verify cleaned Excel headers match cleaned sample_statistics.csv headers position-by-position
4. Select dose-defined samples by column INDEX

The old v2 R code used **name-based matching** against dose_defined_metadata.csv,
which caused sample-column misalignment. Fixed by replicating the historical
positional approach exactly.

**Affected samples (cleaned from raw): 0**
The Excel headers were already clean; the bug was using the wrong metadata source
and name-based matching instead of positional matching.

---

## QA Gates

| Gate | Expected | Actual | Status |
|---|---|---|---|
| Sample matching | 515/515 positional exact | 515/515 | PASS |
| Unmatched samples | 0 | 0 | PASS |
| Duplicate clean IDs | 0 | 0 | PASS |
| Historical parity | 1434=1434 exact | 1434=1434, overlap=1434 | PASS |
| U0 | 3817 | 3817 | PASS |
| Freeze 3 exclusions | 8 | 8 | PASS |
| Exclusions in historical 1434 | 4 | 4 | PASS |
| Utech_primary | 3809 | 3809 | PASS |
| Q515 | 1430 | 1430 | PASS |
| Q515 thresholds | 108/131/124 | 108/131/124 | PASS |
| D515 | (no historical equivalent) | 3054 | N/A |
| Q515 ∩ D515 | — | 733 | — |
| D515-only | — | 2321 | — |
| Q515-only | — | 697 | — |
| Q515-only due N_detected<10 | 0 | 0 | PASS |
| Q515-only due N_not_detected<10 | (explained) | 697 | PASS |
| Q515 TRUE with N_detected<363 | 0 | 0 | PASS |

---

## Canonical universe summary

| Universe | N |
|---|---:|
| U0 | 3,817 |
| Utech_primary | 3,809 |
| Q515 | 1,430 |
| D515 | 3,054 |
| Q515 ∩ D515 | 733 |
| D515-only | 2,321 |
| Q515-only | 697 |

---

## Freeze 3 exclusions (8)

| PG.ProteinGroups | Gene | Historical 1434 member |
|---|---|---|
| P04264 | KRT1 | TRUE |
| P13645 | KRT10 | TRUE |
| P35527 | KRT9 | TRUE |
| P35908 | KRT2 | TRUE |
| O76013 | KRT36 | FALSE |
| O76015 | KRT38 | FALSE |
| Q15323 | KRT31 | FALSE |
| Q9NSB2 | KRT84 | FALSE |

Expected Q515 = 1434 - 4 = 1430. Actual = 1430. PASS.

---

## Invalidated provisional outputs

Previous V2-02 outputs (Q515=1436, D515=3042) were based on incorrect
name-based column matching. They have been overwritten by the canonical
V2-02B rebuild. The old values are superseded and must not be used.

---

## File semantics

- `universes/Utech_primary.csv` — 3,809 rows (Utech members only)
- `universes/Utech_membership_all_U0.csv` — 3,817 rows (U0-level membership flags)
- `universes/V2_universe_membership_master.csv` — 3,817 rows (canonical master registry)
- `universes/Q515.csv` — 1,430 rows
- `universes/D515.csv` — 3,054 rows