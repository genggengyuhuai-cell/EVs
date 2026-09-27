# V2 Analysis Input Contract

**Effective from:** V2-02 freeze (2026-09-27)
**Authority:** This contract is mandatory for all v2 modules.

## 1. Canonical input files

All v2 downstream scripts MUST read universe membership from these frozen files:

| File | Rows | Contents |
|---|---:|---|
| `universes/V2_universe_membership_master.csv` | 3,817 | U0-level canonical registry: Freeze3_category, Primary_exclusion, Utech_primary, Q515, D515, failure reasons, flags |
| `universes/Utech_primary.csv` | 3,809 | Utech member protein groups only |
| `universes/Utech_membership_all_U0.csv` | 3,817 | U0-level membership flags (renamed from old Utech_primary.csv) |
| `universes/Q515.csv` | 1,430 | Q515 members |
| `universes/D515.csv` | 3,054 | D515 members |
| `universes/Q515_eligibility_all_Utech.csv` | 3,809 | Full Utech Q515 eligibility with detection counts |
| `universes/D515_eligibility_all_Utech.csv` | 3,809 | Full Utech D515 eligibility with detection counts |
| `universes/Utech_primary_exclusions.csv` | 8 | Freeze 3 exclusion audit |

## 2. Prohibited re-computation

Downstream modules MUST NOT:
- Recompute Utech from scratch
- Recompute Q515 eligibility
- Recompute D515 eligibility
- Apply additional contaminant filters
- Use historical 1434, 256, or 85-candidate lists as universe

If a downstream module needs a universe different from the canonical one (e.g., Mfold for ML),
it must derive it FROM the canonical master, not from raw data.

## 3. Abundance matrix contract

- Source: `rawdata/processed.xlsx`
- 3,817 protein groups × 519 sample columns
- First 7 columns are annotation (PG.ProteinGroups, PG.Genes, etc.)
- Sample columns use POSITIONAL matching via `clean_header()` (trimws + remove trailing ".0")
- Canonical sample metadata: `descriptive/sample_statistics.csv` (519 rows, positional order)
- Dose-defined samples: 515 (Control=153, Low=186, High=176)
- Detection definition: finite AND > 0
- No imputation for Q515/D515 eligibility
- log2 transform is NOT learned; abundance values are already log2 in processed.xlsx

## 4. Annotation contract

- Analytical key: `PG.ProteinGroups` (UniProt accession)
- Gene symbol: `PG.Genes`
- Display label: Gene_symbol (for now)
- Group labels: Control / Low / High (from TREAT1_clean: control/low/high)
- Environment: Humid-hot / High-altitude
- Site: nested within Environment

## 5. Error handling

If any script reads these files and finds:
- Row count mismatch
- Missing PG.ProteinGroups
- Unexpected TRUE/FALSE counts
- Annotation join that changes row count

The script MUST STOP and report discrepancy. No silent regeneration.