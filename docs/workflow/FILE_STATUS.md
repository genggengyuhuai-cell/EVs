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
| `descriptive/missingness_robustness/` | POST-FREEZE DOWNSTREAM ROBUSTNESS MODULE | COMPLETED; OPTIONAL; NOT CALLED BY `run_all.py`; DOES NOT REDEFINE FROZEN PRIMARY RESULTS |
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
MISSINGNESS / IMPUTATION ROBUSTNESS ANALYSIS: COMPLETED
```

Stages 01–12 are frozen. Changes require a verified bug, explicit authorization, a
version increment, affected-stage revalidation, and end-to-end reproducibility when
required. Cosmetic cleanup, deduplication, refactoring, warning suppression, or style
changes alone do not justify source modification. Prefer downstream modules for new
biological analyses.

The completed missingness module validated D0 against Stage 07 to floating-point
precision (1,434 proteins, 515 samples, 46,443 missing cells; 6.2887%) with exact
identity of the canonical 256 DEP set. D1/D2/D3 retained 206/227/254 canonical DEP,
respectively. These sensitivity-derived sets do not replace the frozen 256, and no
imputation method is promoted to primary analysis. All seven canonical
`Long_suppression` proteins are completely observed, invariant under D0–D3, remain
FDR < 0.05, and map independently to Stage 11b C3.
