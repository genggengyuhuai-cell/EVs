# Contaminant Data Source Audit (Static Repository Audit)

**Date:** 2026-09-27
**Method:** Static inspection only. No inference. No contamination classification performed.

---

## 1. Question

Can Category A technical contaminants be identified directly from existing
source metadata in `processed.xlsx`, or is an external cRAP mapping required?

---

## 2. What was checked

### 2.1 Columns in `rawdata/processed.xlsx`

The export has these annotation columns:

| Column | Description |
|---|---|
| `PG.ProteinGroups` | Semicolon-separated UniProt accessions (row key) |
| `PG.Genes` | Gene symbols |
| `PG.ProteinDescriptions` | Protein descriptions |
| `PG.ProteinNames` | UniProt entry names (e.g., `ALBU_HUMAN`) |
| `PG.CV` | Coefficient of variation |
| `PG.Qvalue` | Protein group Q-value |
| `PG.MolecularWeight` | Molecular weight |

**Missing columns:**
- No `PG.Contaminant` flag
- No `PG.Decoy` flag
- No `PG.Reverse` flag
- No `PG.ProteinGroups` column with contaminant markers
- No species column (human vs. bovine vs. porcine)

**Conclusion:** Source metadata does **not** contain explicit contaminant/decoy flags.

### 2.2 Accession token search in `PG.ProteinGroups`

Searched for: `contaminant`, `reverse`, `decoy`, `BSA`, `trypsin`, `keratin`,
`KRT`, `cRAP`, `CRAP`, `spike`, `Bos taurus`, `Bovin`, `Sus scrofa`, `pig trypsin`.

**Result:** Zero hits in the accession column itself.
All 3,817 accessions are standard UniProt accession format (e.g., `A0A024R1R8`,
`P01615`, `Q9Y2S6`). No recognizable non-human spike-in accessions.

### 2.3 Description token search in `PG.ProteinDescriptions`

| Token | Hits | Interpretation |
|---|---|---|
| `trypsin` | 9 | All are endogenous trypsin **inhibitors** (AAT, AACT, ITIH family). **Not** exogenous trypsin enzyme. |
| `keratin` | 36 | Human keratins (KRT family). Could be endogenous epithelial or lab contamination. **Per protocol: KRT* prefix alone is insufficient.** |
| `ALB` (description) | 5 | Includes albumin + reticulocalbin (false positive). Albumin is Category B (endogenous). |

### 2.4 Gene symbol search (Category B/C markers)

| Marker class | Genes found | Category |
|---|---|---|
| Albumin | ALB (1) | B |
| Immunoglobulins | IGH (42), IGK (29), IGL (35) | B |
| Apolipoproteins | APOA (4), APOB (2), APOC (4), APOE (1), APOH (1) | B |
| Complement | C1QA/B/C, C2, C3, C4A/B, C5-C9, C8A/B | B |
| Fibrinogen | FGA (2), FGB (1), FGG (1) | B |
| Erythrocyte/hemolysis | HBB (2), HBA (1), GYPA (1) | C |
| Platelet | PF4 (1), PPBP (1), ITGA2B (1), ITGB3 (1), GP1BA (1) | C |
| Coagulation | VWF (1), F8 (4), F9 (3) | C |

These are all present in the 3,817 protein groups. They are **not** contaminants
to be excluded; they are Category B (retain) and Category C (retain + annotate).

### 2.5 Source FASTA / database

Searched the entire repository for:
- `*.fasta`, `*.fa`, `*.faa` files
- Any file containing "contaminant" in its name
- Any cRAP accession list

**Result:** No FASTA files. No contaminant registry file. No cRAP list.

### 2.6 Existing contaminant code or documentation

Grep across all `.R`, `.py`, `.csv`, `.md`, `.txt` files found contaminant
references **only** in:
- `docs/protocol/ANALYSIS_PLAN_v2.0.md` (protocol specification)
- Output CSV data files (which contain keratin proteins as data, not as a registry)

**No existing contaminant classification code or registry exists.**

---

## 3. Conclusion

**Answer: Case C — Must introduce fixed-version external cRAP mapping.**

Rationale:

1. **No source metadata flags** exist in `processed.xlsx` (no decoy/reverse/contaminant column).
2. **No source FASTA** is saved in the repository.
3. **No BSA/exogenous trypsin** accessions are identifiable from the export.
4. **Human keratins exist** (36 entries) but the protocol explicitly says
   "KRT* prefix alone is insufficient" — we cannot classify them as Category A
   based on gene name alone.
5. **Category B and C markers** are identifiable from gene symbols/descriptions
   and can be annotated as such, but this is annotation, not exclusion.

Therefore, to build Utech:

- **We cannot fully construct Category A from existing source metadata.**
- **We must introduce a fixed-version external cRAP reference mapping**
  (per protocol: "use a fixed release of a documented contaminant reference such as cRAP").
- **Investigator must decide:** which cRAP release version to pin,
  and how to handle ambiguous human keratin entries.

This is Freeze 3 and it is **OPEN**.

---

## 4. What we CAN do without external mapping

We can already:

1. Annotate all Category B proteins (endogenous plasma) with their subcategory.
2. Annotate all Category C proteins (preanalytical markers) with their subcategory.
3. Flag unresolved entries as `unresolved` rather than `clean`.

What we **cannot** do without external mapping:

1. Determine which (if any) of the 3,817 are true technical contaminants.
2. Generate the Utech protein list.
3. Compute Q515 or D515.

---

## 5. Recommended next step

Investigator decision needed:

> Which cRAP release should be pinned as the Category A reference?
> (Options: cRAP 2019_05, cRAP 2024_01, or another dated release.)

Once pinned, the registry can be built by exact accession matching against
the chosen cRAP list, with manual review for ambiguous cases.
