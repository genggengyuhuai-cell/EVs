# V2 Universe Data Contract (V2-02 Specification)

**Status: DESIGN ONLY — no universe has been generated yet.**
**Protocol authority:** `docs/protocol/ANALYSIS_PLAN_v2.0.md`, Section 2 "Identity, inputs and universes."

---

## 1. Overview

This contract defines the deterministic rules for each v2 protein universe.
No universe has been computed. The rules below are the frozen specification
that V2-02 will implement when authorized.

---

## 2. Universe definitions

### U0 — All exported protein groups

| Property | Value |
|---|---|
| Definition | All exported protein-group identities, before technical exclusions |
| Expected size | 3,817 |
| Source | `rawdata/processed.xlsx` → `PG.ProteinGroups` column |
| Purpose | Descriptive denominator only; not used for inferential analysis |
| Rule | All rows in the export, no filtering |

### Utech — Technical-filtered universe

| Property | Value |
|---|---|
| Definition | U0 minus definite Category A technical/search contaminants |
| Rule | Exclude protein groups where `Contaminant_category == "A"` (from contaminant registry). Mixed human/technical groups are retained with flag (unresolved). |
| Dependency | Requires Freeze 3 (contaminant registry built) |
| Expected size | Not known until registry is built. Historical 3,817 → likely ~3,780–3,815 depending on cRAP matches. |
| Purpose | This is the starting point for all Q515, D515, Qenv, Denv, and Mfold. |

**Key rule:** Unresolved mixed groups are **retained** in Utech with a flag.
They are not silently classified as clean. They enter the ambiguous-group sensitivity.

### Q515 — Quantitative abundance universe

| Property | Value |
|---|---|
| Definition | Utech with finite positive quantity in ≥70% **separately** in Control, Low, and High among the fixed 515 participants |
| Rule | For each protein group: count positive observations in Control (n=153), Low (n=186), High (n=176). Protein qualifies if: Control ≥ 0.70×153 = 108 (ceiling), Low ≥ 0.70×186 = 131 (ceiling), High ≥ 0.70×176 = 124 (ceiling). |
| Thresholds (integer ceiling) | Control: 108; Low: 131; High: 124 |
| Missing value policy | NA retained after log2. Non-positive quantities are missing, never zero. |
| Expected size | Not known until Utech is built. Historical v1.0 had 1,434 (from 3,817 without Utech filter). v2 Q515 will differ because Utech removes Category A. |
| Purpose | Primary inferential universe for all abundance analyses (E, omnibus, ordered, pairwise). |

**Sensitivity thresholds:** Also report common-abundance universes at ≥50%, ≥60%,
≥70%, and ≥80% separately per Group as prespecified sensitivity summaries.
The ≥70% rule remains primary; other thresholds are not selected by discovery count.

**Critical:** Q515 is a **quantitative abundance** universe. It does **not**
restrict D515, detection, or enriched-detection analyses.

### D515 — Detection universe

| Property | Value |
|---|---|
| Definition | Utech with ≥10 detected and ≥10 non-detected observations **overall** among the 515 |
| Rule | For each protein group: count detected (positive quantity) and non-detected (NA or non-positive) across all 515 samples. Protein qualifies if: detected ≥ 10 AND non-detected ≥ 10. |
| Group independence | D515 eligibility is **independent of Group labels**. It does not require per-group detection. |
| Expected size | Not known until Utech is built. Likely larger than Q515 because it includes proteins with variable detection across samples. |
| Purpose | Primary universe for all detection analyses (Firth logistic, differential detection, unique proteins). |

**Critical:** D515 is independent of Q515. A protein can be in D515 but not Q515
(or vice versa). Detection analyses are never restricted to Q515.

### Qenv — Environment-specific quantitative universe

| Property | Value |
|---|---|
| Definition | Q515 plus ≥10 observed values in every one of the six Group × Environment cells, with full-rank observed design and ≥5 residual df |
| Cells | Control×Humid-hot, Low×Humid-hot, High×Humid-hot, Control×High-altitude, Low×High-altitude, High×High-altitude |
| Purpose | Supports both Environment stratum-specific analyses and direct interaction tests |

### Denv — Environment-specific detection universe

| Property | Value |
|---|---|
| Definition | D515 with all six participant cells ≥10, full-rank design, ≥10 total detections and non-detections within each Environment |
| Purpose | Detection interaction analysis |

### Mfold — ML training-fold universe

| Property | Value |
|---|---|
| Definition | Utech intersected with training-fold eligibility only |
| Rule | Quantitative features require ≥70% detection in each relevant original Group in that fold. All-missing/zero-variance features excluded. |
| Critical | Mfold is recomputed **within every training split**. Never subset Q515 for ML. |

---

## 3. Key distinctions

| Distinction | Why it matters |
|---|---|
| Q515 ≠ D515 | Q515 requires per-group ≥70% positive. D515 requires overall ≥10 detected AND ≥10 non-detected. A protein with high overall detection but uneven per-group coverage can be in D515 but not Q515. |
| Utech ≠ U0 | Utech removes Category A technical contaminants. U0 is the raw 3,817. |
| Q515 ≠ historical 1,434 | Historical 1,434 was computed without Utech (no contaminant filtering). v2 Q515 will differ because Utech removes Category A entries. |
| D515 ≠ Q515 detection subset | Detection analysis uses D515, not Q515. Never restrict detection to Q515. |
| Mfold ≠ Q515 | ML uses fold-local eligibility (Mfold), not the global Q515 list. |

---

## 4. Eligibility sensitivity gradients

Per protocol, report detection gradients at ≥50%, ≥60%, ≥70%, ≥80% separately
in Control, Low, and High. These are prespecified sensitivity summaries,
not alternative primary universes.

---

## 5. Output contract for V2-02

When V2-02 is implemented, it will produce:

| Output file | Description |
|---|---|
| `registry/Utech_proteins.csv` | One row per protein group in Utech, with `Exclude_from_Utech` flag |
| `registry/Q515_proteins.csv` | One row per protein group in Q515, with per-group detection counts |
| `registry/D515_proteins.csv` | One row per protein group in D515, with overall detected/non-detected counts |
| `registry/universe_flow.md` | Text summary: U0 → Utech → Q515 / D515 flow with counts |
| `registry/universe_flow.png` | Visual flow diagram (future) |

Each output will carry a provenance manifest (see `config/v2_provenance.R`).

---

## 6. Blockers

| Blocker | Status |
|---|---|
| Freeze 2 (Spectronaut normalization) | OPEN — does not block Utech/Q515/D515 computation directly, but ML deployability is limited |
| Freeze 3 (contaminant registry) | **OPEN — blocks Utech generation** |
| Freeze 4 (canonical registry/universes) | Rules fixed; lists not generated until Freeze 3 is resolved |

**V2-02 cannot execute until Freeze 3 is resolved** (i.e., until the contaminant
registry is built with a pinned cRAP reference).
