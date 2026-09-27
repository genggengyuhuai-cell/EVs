# v2_config.md — Canonical V2 Project Configuration Specification

This file is documentation only and is not executable R. Future executable helpers
must be implemented as separate, syntax-valid `.R` files.

## What it must define

### 1. Input paths (canonical, read-only)

| Constant | Value | Notes |
|---|---|---|
| `V2_ROOT` | `descriptive/analysis_v2.0/` | All v2 outputs go here |
| `RAW_PROCESSED` | `rawdata/processed.xlsx` | PG.Quantity matrix, 3817 × 519 |
| `RAW_RAW` | `rawdata/rawdata.xlsx` | Original export (if needed) |
| `SAMPLE_MAPPING` | `rawdata/sample_mapping_FINAL.xlsx` | Final sample position mapping |
| `DOSE_METADATA` | `descriptive/dose_defined_metadata.csv` | 515 dose-defined participants |
| `PROTEIN_ANNOT` | `descriptive/canonical_protein_annotation.csv` | 3817 × (PG + Gene_symbol + Display_label) |
| `DV_ASSIGNMENT` | `descriptive/discovery_validation_split/discovery_validation_assignment.csv` | Frozen 386/129 split |
| `DV_ASSIGNMENT_SHA256` | `062e51026b7420dca207bfdaa760ac08ac5f19a9af98cf89da2b7b6791` | Verified hash of assignment CSV |

### 2. Frozen historical paths (read-only, never write here)

| Constant | Value |
|---|---|
| `HIST_FULL_PIPE` | `descriptive/limma_dose_analysis/` |
| `HIST_DV` | `descriptive/discovery_validation/` |
| `HIST_MISS` | `descriptive/missingness_robustness/` |
| `HIST_SPLIT` | `descriptive/discovery_validation_split/` |

### 3. Canonical analytical keys

| Constant | Value |
|---|---|
| `ROW_KEY` | `PG.ProteinGroups` — stable protein-group row key |
| `ANNOT_GENE` | `Gene_symbol` — biological annotation (not a join key) |
| `ANNOT_DISPLAY` | `Display_label` — display label (not a join key) |
| `SAMPLE_KEY` | `UniqueSampleID` — positional sample mapping |

### 4. Canonical exposure levels (internal keys)

Ordered: Control < Low exposure < High exposure

| Internal key | v2 display label | Legacy token |
|---|---|---|
| `Control` | `Control` | `control`, `Control`, `Short` |
| `Low` | `Low exposure` | `low`, `Short` |
| `High` | `High exposure` | `high`, `Long` |

**Rule:** Internal keys are used in model formulas and output filenames.
Display labels are applied only at the figure/table rendering layer.
Never modify frozen files' internal string tokens.

### 5. Canonical Environment levels

| Internal key | v2 display label | Legacy token |
|---|---|---|
| `Humid_hot` | `Humid-hot` | `high_temperature`, `湿热` |
| `High_altitude` | `High-altitude` | `high_stress`, `高海拔`, (legacy `high-pressure` corrected) |

### 6. Site nesting

Site is nested within Environment. No Site spans both Environments.

| Environment | Sites |
|---|---|
| Humid-hot | FJ_FQ, FJ_PT, FJ_QZ, GZ_TH |
| High-altitude | XZ_GG, XZ_YA, XZ_YB, XZ_YC, XZ_YD |

### 7. Fixed populations

| Population | N |
|---|---|
| Full analytical cohort | 515 |
| Discovery (frozen) | 386 |
| Reused within-cohort hold-out (frozen) | 129 |
| Original export samples | 519 |

**Rule:** The 386/129 assignment is read-only. Never rerandomize.
The 129 is a **reused within-cohort hold-out**, never "external validation."

### 8. Group weights (for E contrast)

- Control: 153
- Low: 186
- High: 176
- Exposed total (Low+High): 362
- E weights: Low = 186/362, High = 176/362

### 9. Random seeds registry

| Seed | Purpose |
|---|---|
| `20260925` | Historical missingness D0–D3 + Discovery D01 split |
| `20260926` | ML outer repeat 1 |
| `20260927` | ML outer repeat 2 |
| `20260928` | ML outer repeat 3 |
| `20260929` | Final ML model lock on all 386 |
| `20260930` | Reused hold-out bootstrap CI (2000 replicates) |

Inner CV seeds derive deterministically from repeat × outer fold. No seed search.

### 10. Output subdirectories (under V2_ROOT)

```
metadata/    qc/    abundance/    detection/    environment/
site/        pathway/    ml/    tables/    figures/
registry/    contracts/    config/
```

### 11. Version constants

| Constant | Value |
|---|---|
| `V2_PLAN_VERSION` | `2.0` |
| `V2_PLAN_DATE` | `2026-09-26` |
| `GIT_CHECKPOINT` | (to be recorded at execution time) |

---

## Implementation notes

- Implementations must follow this specification; this Markdown file must not be
  passed to `source()`.
- No v2 script may hard-code paths, labels, seeds, or weights that are defined here.
- Frozen historical files are read-only; v2 never writes to them.
- The `DV_ASSIGNMENT_SHA256` must be verified before any v2 script reads the assignment CSV.
