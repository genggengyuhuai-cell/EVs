# Reproducibility guide

The current canonical execution guide is [`descriptive/RUN_ORDER.md`](../descriptive/RUN_ORDER.md).

The pipeline starts from `rawdata/processed.xlsx` and
`rawdata/sample_mapping_FINAL.xlsx`. Begin with:

```powershell
cd descriptive
python 01_describe_proteomics.py
```

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
```

`PG.ProteinGroups` is the analytical key. Stage 01 creates
`canonical_protein_annotation.csv` with `Gene_symbol` and `Display_label`; visible
individual-protein labels use `Display_label`.

The locked primary analysis contains 1,434 proteins across 515 dose-defined samples
at the primary threshold of at least 70% detection in each exposure group, with
approximately 6.29% residual missingness. It uses log2 abundance, retains missing
values as `NA`, performs no primary imputation or `NA -> 0`, and treats median
normalization as sensitivity-only. The raw input contains 3,817 protein groups and 519
samples; 3,810 gene symbols are mapped and 7 labels use the stable-ID fallback.

The DEP universe is 256. Canonical Stage 11a assigns 249 `Short_peak` and 7
`Long_suppression`. Exploratory Stage 11b clusters protein-wise z-scored observed
Control/Short/Long group means in a 256 × 3 matrix with no sample-level imputation,
producing C1=130,
C2=96, C3=7, and C4=23. K-means K=2–6 is sensitivity-only; no optimal biological K
is claimed. All 7 `Long_suppression` proteins map to C3; the 249 `Short_peak`
proteins map to C1/C2/C4 as 130/96/23.

Reasonable regression checks and downstream derivations are retained.

Stages 01–12 constitute the frozen v1.0 analytical pipeline. Do not modify frozen
analytical source unless a verified scientific or software bug is identified, the
modification is explicitly authorized, the analytical version is incremented,
affected stages are revalidated, and end-to-end reproducibility is re-established
when required. Cosmetic cleanup, code deduplication, refactoring, warning suppression,
or style improvement alone is not sufficient reason to modify frozen v1.0 analytical
source. New biological analyses should preferentially be implemented as downstream
modules rather than by modifying the frozen primary pipeline.
