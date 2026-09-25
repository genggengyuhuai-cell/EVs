# File status

Generated analytical outputs are regenerable artifacts. Analytical pipeline version
**v1.0** is **FROZEN**.

| Files | Type | Status |
|---|---|---|
| `descriptive/01_describe_proteomics.py`–`12_pattern_protein_annotation.R` | FROZEN v1.0 SOURCE | MANUAL STAGE VALIDATION PASS; FULL END-TO-END VALIDATION PASS 17/17 |
| `descriptive/run_all.py` | FROZEN v1.0 ORCHESTRATOR | FINAL POST-FIX RUN_ALL PASS 17/17 |
| `descriptive/08d_integrated_results.R` | FROZEN v1.0 SOURCE | DISPLAY-LABEL FIX TARGETED RUNTIME VALIDATION PASSED; ALL 18 AFFECTED SVG TITLES VERIFIED |
| `descriptive/11b_protein_clustering.R` | FROZEN v1.0 SOURCE | GROUP-RESPONSE CLUSTERING FIX TARGETED RUNTIME VALIDATION PASSED |
| `descriptive/v21_common.R`, `nature_plotting.py` | SHARED UTILITY | ACTIVE; INCLUDED IN PRIOR FULL-RUN VALIDATION AS APPLICABLE |
| `descriptive/stage05_normalization_helper.py`, `stage05_detection_helper.py` | STAGE 05 INTERNAL UTILITY | NOT INDEPENDENT PIPELINE STAGES |
| `descriptive/archive/` | LEGACY / ARCHIVED SOURCE | NON-PIPELINE; DO NOT EXECUTE |
| Canonical Markdown control files and `descriptive/RUN_ORDER.md` | DOCUMENTATION | UPDATED |
| Generated CSV/CSV.GZ/RDS/JSON/reports/figures | GENERATED OUTPUT | REGENERABLE; MAY BE REPLACED ONLY BY THE OWNING STAGE |

Raw inputs under `rawdata/` remain read-only source data.

Validation status:

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
```

Stages 01–12 are frozen. Changes require a verified bug, explicit authorization, a
version increment, affected-stage revalidation, and end-to-end reproducibility when
required. Cosmetic cleanup, deduplication, refactoring, warning suppression, or style
changes alone do not justify source modification. Prefer downstream modules for new
biological analyses.
