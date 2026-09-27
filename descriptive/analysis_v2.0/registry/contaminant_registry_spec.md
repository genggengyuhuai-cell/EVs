# Contaminant Registry Specification (V2-01)

**Status: DESIGN ONLY — no registry has been generated yet.**
**Protocol authority:** `docs/protocol/ANALYSIS_PLAN_v2.0.md`, Module 03 and Freeze 3.
**Freeze 3 status:** OPEN — source flags unavailable; requires external cRAP mapping.

---

## 1. Purpose

Build a deterministic, auditable registry that classifies each of the 3,817
protein groups into one of three categories:

- **Category A** — technical/search contaminants → **exclude** from Utech
- **Category B** — endogenous plasma proteins → **retain** (not contaminants)
- **Category C** — preanalytical/cellular contamination markers → **retain + annotate**

Unresolved entries are retained with flags, not silently classified as clean.

---

## 2. Category definitions (from v2 plan Module 03)

### Category A — Technical contaminants (EXCLUDE)

Explicit decoy/reverse or contaminant database entries, confirmed exogenous
trypsin/BSA, documented laboratory contaminants and technical keratins.

**Exclude from:** all new biological, Unique, pathway and ML universes.

**Key rule from protocol:** "Technical keratin evidence must be explicit;
a `KRT*` prefix alone is insufficient."

**Key rule from protocol:** "All-technical multi-accession groups are excluded;
mixed human/technical groups remain unresolved and enter the declared
ambiguous-group sensitivity."

### Category B — Endogenous plasma proteins (RETAIN)

Endogenous albumin, immunoglobulins, apolipoproteins, complement and fibrinogen.

**Retain in primary analysis.** Do not exclude just because they are high-abundance.
One exclusion-of-B influence summary may be added as a sensitivity only if
justified before execution.

### Category C — Preanalytical / cellular contamination markers (RETAIN + ANNOTATE)

Erythrocyte/hemolysis, platelet and coagulation/processing markers.

**Retain with annotations.** They may reflect biology or handling.
Category C adjustment is an explicitly potentially overadjusted sensitivity,
never assumed confounder control.

---

## 3. Registry schema

The registry will be a CSV file at:
`descriptive/analysis_v2.0/registry/contaminant_registry.csv`

| Column | Type | Description |
|---|---|---|
| `PG.ProteinGroups` | string | Stable row key (semicolon-separated multi-accession) |
| `Accession` | string | Canonical/first accession |
| `Gene_symbol` | string | Gene symbol from annotation |
| `Display_label` | string | Display label from annotation |
| `Contaminant_category` | enum | `A` / `B` / `C` / `unresolved` |
| `Contaminant_subcategory` | string | e.g. `decoy`, `keratin_technical`, `exogenous_trypsin`, `endogenous_ALB`, `erythrocyte`, `platelet`, `coagulation` |
| `Exclude_from_Utech` | bool | `TRUE` for Category A; `FALSE` otherwise |
| `Evidence_source` | string | e.g. `source_flag`, `cRAP_vX.Y`, `protocol_C_category`, `manual_review` |
| `Evidence_version` | string | e.g. `cRAP_2024_01` or `source_export_2026` |
| `Rule_id` | string | e.g. `A-DEC-001`, `B-ALB-001`, `C-RBC-001` |
| `Manual_review` | bool | `TRUE` if a human investigator manually classified this entry |
| `Notes` | string | Free text |

---

## 4. Multi-accession exclusion rule

**Protocol-stated rule (from v2 plan):**
> "All-technical multi-accession groups are excluded; mixed human/technical groups
> remain unresolved and enter the declared ambiguous-group sensitivity."

This means:

| Scenario | Action |
|---|---|
| All accessions in the group are Category A (technical) | Exclude from Utech |
| At least one accession is human endogenous and at least one is technical | **Unresolved** — retain in Utech with flag; include in ambiguous-group sensitivity |
| All accessions are human endogenous (B or C) | Retain normally |
| No clear evidence either way | **Unresolved** — retain with flag |

**This rule is already specified by the protocol. No investigator decision needed
on the multi-accession exclusion policy itself.**

---

## 5. Evidence source hierarchy

When classifying a protein group, evidence is evaluated in this order:

1. **Source metadata flags** (if available): decoy/reverse/contaminant columns
   from the Spectronaut export. **Status: NOT AVAILABLE** (see DATA_SOURCE_AUDIT.md).
2. **Fixed-version cRAP mapping**: exact accession match against a pinned cRAP release.
   **Status: REQUIRED** — investigator must choose cRAP version.
3. **Protocol-defined Category B/C markers**: endogenous plasma proteins and
   preanalytical markers listed in Module 03.
4. **Manual review**: unresolved entries require investigator decision.

---

## 6. What this registry is NOT

- It is **not** a protein filter that deletes data.
- It is a **classification table** that Utech will reference.
- It does **not** modify `processed.xlsx` or any frozen file.
- It does **not** exclude based on gene name alone (per protocol: KRT* prefix is insufficient).
- It does **not** exclude based on protein abundance or detection frequency.

---

## 7. Open items for investigator decision

1. **cRAP version**: Which release of cRAP should be used? (e.g., cRAP 2019_05,
   cRAP 2024_01, or another pinned release). This is Freeze 3.
2. **Keratin policy**: The protocol says "technical keratin evidence must be explicit."
   If cRAP does not list human keratins as contaminants (cRAP typically lists
   bovine/porcine trypsin, BSA, etc., not human KRTs), do human keratins in this
   dataset require manual review to distinguish lab contamination from endogenous
   epithelial expression?
3. **Mixed-group handling**: The protocol says mixed human/technical groups are
   "unresolved" and enter an "ambiguous-group sensitivity." Should these be
   excluded from the primary Utech or retained? The protocol implies retained
   with flag, but this should be confirmed.
