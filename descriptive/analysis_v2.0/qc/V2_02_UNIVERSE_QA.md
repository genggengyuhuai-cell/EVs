# V2-02 Universe QA Report

**Date:** 2026-09-27
**Script:** `code/V2_02_build_universes.R`
**Freeze 3 status:** FROZEN (approved 2026-09-26)

---

## 1. Sample gates

| Gate | Expected | Actual | Result |
|---|---:|---:|---|
| Total analytical samples | 515 | 515 | PASS |
| Control | 153 | 153 | PASS |
| Low | 186 | 186 | PASS |
| High | 176 | 176 | PASS |

## 2. U0 gate

| Gate | Expected | Actual | Result |
|---|---:|---:|---|
| U0 protein groups | 3817 | 3817 | PASS |
| Unique PG.ProteinGroups | 3817 | 3817 | PASS |

## 3. Freeze 3 gate

| Gate | Expected | Actual | Result |
|---|---:|---:|---|
| Primary exclusion N | 8 | 8 | PASS |
| Utech_primary | 3809 | 3809 | PASS |

Excluded protein groups (8):

| Accession | Gene |
|---|---|
| P04264 | KRT1 |
| P35908 | KRT2 |
| P35527 | KRT9 |
| P13645 | KRT10 |
| Q15323 | KRT31 |
| O76013 | KRT36 |
| O76015 | KRT38 |
| Q9NSB2 | KRT84 |

## 4. Q515 gates

| Gate | Expected | Actual | Result |
|---|---:|---:|---|
| Control threshold | 108 (ceiling(0.70*153)) | 108 | PASS |
| Low threshold | 131 (ceiling(0.70*186)) | 131 | PASS |
| High threshold | 124 (ceiling(0.70*176)) | 124 | PASS |
| Q515 N | — | 1436 | — |

All Q515 proteins satisfy all three group thresholds simultaneously.

## 5. D515 gates

| Gate | Expected | Actual | Result |
|---|---:|---:|---|
| N_detected >= 10 | all D515 | verified | PASS |
| N_not_detected >= 10 | all D515 | verified | PASS |
| D515 independent of Q515 | yes | yes (734 overlap, 2308 D515-only, 702 Q515-only) | PASS |

## 6. Universe intersections

| Set | N |
|---|---:|
| U0 | 3817 |
| Utech_primary | 3809 |
| Q515 | 1436 |
| D515 | 3042 |
| Q515 ∩ D515 | 734 |
| D515 only | 2308 |
| Q515 only | 702 |

## 7. Historical reconciliation

| Comparison | v2 | Historical | Overlap | Historical-only | v2-only |
|---|---:|---:|---:|---:|---:|
| Q515 vs historical 1434 | 1436 | 1434 | computed in registry | computed | computed |

Difference sources:
- Freeze 3 excluded 8 keratin protein groups from Utech
- v2 uses frozen 70% rule from Utech_primary, not from U0
- Historical 1434 was v1.0 full-cohort without Freeze 3
- D515: No directly equivalent historical universe

## 8. Identity gates

- All universes have unique PG.ProteinGroups
- No duplicate analytical keys
- Annotation join preserves row count
- Exclusion join produces no duplicates

## 9. Output files

| File | Description |
|---|---|
| universes/Utech_primary.csv | U0 with exclusion flags |
| universes/Utech_primary_exclusions.csv | 8 excluded proteins |
| universes/Q515.csv | Q515 pass list (1436) |
| universes/Q515_eligibility_all_Utech.csv | All 3809 Q515 eligibility |
| universes/D515.csv | D515 pass list (3042) |
| universes/D515_eligibility_all_Utech.csv | All 3809 D515 eligibility |
| universes/V2_universe_membership_master.csv | Master registry (3817 rows) |
| manifests/V2_02_universe_manifest.csv | SHA-256 provenance manifest |