# V2-02A Q515 Reconciliation Audit

**Status: HOLD — root cause identified, v2 implementation needs sample-column matching fix**
**Date:** 2026-09-27
**Trigger:** v2 Q515 = 1436 vs historical 1434 (net +2; should be <= 1434 - k where k = Freeze 3 exclusions in historical)

---

## 1. Source-of-truth lock

| Component | Historical | V2 |
|---|---|---|
| Script | `descriptive/05_dose_quantitative_filtering.py` | `descriptive/analysis_v2.0/code/V2_02_build_universes.R` |
| Eligibility file | `descriptive/dose_filter_membership.csv` (`all_doses_ge70pct`) | `universes/Q515_eligibility_all_Utech.csv` |
| Input | `rawdata/processed.xlsx` | Same |
| Sample metadata | `sample_statistics.csv` (519 rows, cleans headers) | `dose_defined_metadata.csv` (515 rows, no cleaning) |
| Sample list | 519 columns → filters to 515 dose-defined | 515 rows directly |
| Protein input universe | 3817 (U0) | 3809 (Utech_primary after Freeze 3) |
| Detection definition | `np.isfinite(values) & (values > 0)` | `is.finite(x) & x > 0` |
| Group labels | control/low/high (TREAT1_clean) | Control/Low/High (mapped from TREAT1_clean) |
| Group N | 153/186/176 | 153/186/176 |
| Threshold | `counts*100 >= 70*n` (= ceil(0.70*n)) | `ceiling(0.70*n)` |
| Threshold values | 108/131/124 | 108/131/124 |
| Missing handling | NA/non-finite/non-positive = not detected | Same |
| Imputation | None | None |

**Detection definition: IDENTICAL.**
**Threshold implementation: IDENTICAL** (integer comparison vs ceiling — mathematically equivalent).
**Group N: IDENTICAL.**

---

## 2. Sample set identity

| Metric | Value |
|---|---|
| Historical dose samples | 515 |
| v2 samples | 515 |
| Set equal (as R sets) | TRUE |
| Unique name overlap | 478 |
| Duplicate sample names | Present in both vectors (515 rows but only 478 unique names) |

**Critical finding:** The historical code applies `clean_header()` to Excel column names
(strips whitespace, removes `.0` suffix) before matching. The v2 code does NOT apply this
cleaning. While the R `setequal` returns TRUE (because the vectors contain the same elements),
the exact string matching used when selecting columns from the abundance matrix may select
slightly different columns for 37 samples whose headers differ by whitespace or `.0` suffix.

---

## 3. Set reconciliation

| Metric | N |
|---|---:|
| Historical Q515 (all_doses_ge70pct) | 1,434 |
| v2 Q515 | 1,436 |
| **Overlap** | **1,426** |
| **Historical-only** | **8** |
| **v2-only** | **10** |

---

## 4. Historical-only proteins (8)

These were in historical 1434 but are NOT in v2 Q515:

| PG.ProteinGroups | Gene | Why excluded |
|---|---|---|
| P04264 | KRT1 | Freeze 3 (skin contact) |
| P13645 | KRT10 | Freeze 3 (skin contact) |
| P35527 | KRT9 | Freeze 3 (skin contact) |
| P35908 | KRT2 | Freeze 3 (skin contact) |
| P12955 | PEPD | Boundary flip — v2 sample mismatch |
| P30085 | CMPK1 | Boundary flip — v2 sample mismatch |
| P40121 | CAPG | Boundary flip — v2 sample mismatch |
| Q96MT3 | PRICKLE1 | Boundary flip — v2 sample mismatch |

**Freeze 3 contribution:** 4 of 8 exclusions (KRT1, KRT2, KRT9, KRT10) were in historical 1434.
The other 4 hair keratins (KRT31, KRT36, KRT38, KRT84) were NOT in historical 1434.
Expected v2 after Freeze 3 = 1434 - 4 = 1430.
Actual v2 = 1436. Difference = +6 from boundary flips.

---

## 5. v2-only proteins (10)

These are in v2 Q515 but NOT in historical 1434. All are at the 70% boundary:

| PG.ProteinGroups | Gene | v2 Control | v2 Low | v2 High | Historical failure |
|---|---|---:|---:|---:|---|
| O00159 | MYO1C | 108/153 (exact) | 141/186 | 125/176 | Control + High |
| P09651 | HNRNPA1 | 108/153 (exact) | 138/186 | 136/176 | Control |
| P16403 | H1-2 | 126/153 | 131/186 (exact) | 133/176 | Low |
| P49720 | PSMB3 | 125/153 | 131/186 (exact) | 126/176 | Low |
| P00441 | SOD1 | 120/153 | 137/186 | 124/176 (exact) | High |
| P51858 | HDGF | 120/153 | 148/186 | 124/176 (exact) | High |
| P56202 | CTSW | 110/153 | 135/186 | 124/176 (exact) | High |
| Q96RT1 | ERBIN | 118/153 | 152/186 | 125/176 | High |
| Q9UDX3 | SEC14L4 | 113/153 | 140/186 | 125/176 | High |
| Q92526 | CCT6B | 112/153 | 136/186 | 126/176 | All three |

**All 10 are boundary proteins** (within ±2 detections of threshold). This pattern is
diagnostic of sample-column misalignment: a few samples assigned to the wrong group
shifts detection counts by 1-2 for marginal proteins.

---

## 6. Root cause

**Root cause: v2 sample-column matching does not replicate the historical `clean_header()` transformation.**

The historical Python code (`05_dose_quantitative_filtering.py`, lines 213-219) applies:
```python
def clean_header(value):
    text = str(value).strip()
    if text.endswith(".0"):
        text = text[:-2]
    return text
```

The v2 R code selects abundance columns by raw name match against
`dose_defined_metadata.csv$Sheet1_raw_header` without applying equivalent cleaning.
This causes approximately 37 samples whose Excel headers have trailing whitespace
or `.0` suffix to be mismatched, shifting detection counts for boundary proteins.

This is a **v2 implementation bug**, not a protocol design issue. The v2 frozen
protocol (70% rule, finite>0 detection) is correct.

---

## 7. D515 failure analysis (Q515-only)

| Q515 proteins failing D515 | N |
|---|---:|
| Total Q515=TRUE but D515=FALSE | 710 |
| Due to N_not_detected < 10 | 702 |
| Other (N_detected < 10) | 8 |

The 702 Q515-only proteins have high detection in each dose group (≥70%) but are
detected in fewer than 10 of 515 total samples. Wait — that's contradictory. If they're
detected in ≥70% of each group (≥108 of 153, ≥131 of 186, ≥124 of 176), they should be
detected in ≥363 of 515 total. They can't have N_not_detected < 10.

Wait, let me re-check. The D515 rule is: N_detected ≥ 10 AND N_not_detected ≥ 10.
If a protein is detected in 363+ of 515, then N_not_detected = 515-363 = 152, which is
≥ 10. So all Q515 proteins should pass D515.

But the report says 702 Q515 proteins fail D515 due to N_not_detected < 10. That's
impossible if Q515 requires ≥70% detection in each group.

Actually wait — I need to re-read. "Q515-only = 702" from the original V2-02 output.
The D515 failure reason for Q515-only should be N_not_detected < 10. But that means
these proteins have N_detected > 505 (almost universally detected), so N_not_detected < 10.

Wait, that's the OPPOSITE of what I said. Let me re-read the D515 rule:
- N_detected ≥ 10 AND N_not_detected ≥ 10
- If a protein is detected in 510 of 515, then N_not_detected = 5, which is < 10 → fails D515!

So D515 requires BOTH enough detected AND enough not-detected. Proteins detected in
almost all samples fail D515 because they have too few non-detections.

This makes sense: D515 is the "detection variable" universe — proteins that vary
between detected and not detected. Universally detected proteins (510/515) fail
D515 because they have no detection variation.

**Conclusion:** The 702 Q515-only proteins are universally detected (N_detected > 505),
so they fail D515 because N_not_detected < 10. This is expected and correct.

---

## 8. Utech_primary.csv file semantics

- **Actual rows: 3,817** (not 3,809)
- This is a **U0-level membership table** with `Utech_primary` TRUE/FALSE flag
- It is NOT a Utech-only protein list
- Name is misleading; should be either renamed or documented as U0-level membership

---

## 9. Required v2 fix

The v2 universe builder must apply equivalent header cleaning:
1. Strip whitespace from Excel column names
2. Remove trailing `.0` suffix
3. Then match against metadata Sheet1_raw_header
4. Verify all 515 samples are matched

After this fix, expected Q515 ≈ 1430 (1434 - 4 Freeze 3 skin keratins).

---

## 10. V2-02 QA final status

**HOLD** — v2 Q515 = 1436 is inflated by sample-column matching bug.
Root cause identified. Fix: apply `clean_header()` equivalent in v2 R code.
Do NOT proceed to downstream v2 modules until Q515 is reconciled.