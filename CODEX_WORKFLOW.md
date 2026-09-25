# CODEX workflow

The repository rebuilds from `rawdata/processed.xlsx`,
`rawdata/sample_mapping_FINAL.xlsx`, and source code. Generated outputs are artifacts,
not sources of truth. Codex must not execute analysis unless the user explicitly
requests execution in a later task.

Generated analytical outputs may be deterministically replaced at their canonical
paths by the stage that owns them. This replacement policy applies only to generated
outputs; raw data, curated inputs, source code and documentation remain protected.

## Identity and display contract

- `PG.ProteinGroups` is the stable key for rows, joins, models and checks.
- `Gene_symbol` is established by Stage 01 from the validated source annotation.
- `Display_label` is `Gene_symbol` when available, otherwise `PG.ProteinGroups`.
- Missing genes never remove proteins; duplicated gene symbols are acceptable annotation.
- Final figures visibly labeling individual proteins use `Display_label`.

## Architecture and validation

The active stages are `01_describe_proteomics.py` through
`12_pattern_protein_annotation.R`, including parallel lettered stages. Python and R
form one pipeline. `nature_plotting.py`, `v21_common.R`, and `stage05_*_helper.py` are
utilities, not independent numbered stages.

Stage 05 produces abundance and binary-detection mother data. Stage 09 is a separate
detection branch, not abundance limma. Stage 07 feeds Stage 08 and Stage 10. Stage 11a
and 11b are downstream descriptive branches; Stage 12 consumes Stage 11a.

Stage 11a is the canonical rule-based pattern classification. Stage 11b is explicitly
exploratory unsupervised clustering of protein-wise z-scored observed Control, Short,
and Long group-mean response profiles. It performs no sample-level imputation.
K-means K=2–6 is sensitivity-only; no optimal biological K is claimed.

## Locked core analysis state

- Raw input: 3,817 protein groups and 519 samples.
- Annotation: 3,810 mapped `Gene_symbol`; 7 fallback/unmapped labels.
- Dose-defined analysis: 515 samples.
- Primary quantitative matrix: 1,434 proteins, approximately 6.29% residual missingness.
- Primary threshold: at least 70% detection in each exposure group.
- Primary values remain `NA`; primary imputation is none and `NA -> 0` is prohibited.
- Primary abundance input is log2 only; median normalization is sensitivity-only.
- DEP universe: 256 proteins.
- Stage 11a: `Short_peak = 249`; `Long_suppression = 7`.
- Stage 11b: exploratory unsupervised response-profile clustering of the 256 × 3
  observed group-mean matrix; `C1 = 130`, `C2 = 96`, `C3 = 7`, `C4 = 23`; no
  sample-level imputation.
- Stage 11a × Stage 11b: all 7 `Long_suppression` proteins map to C3; the 249
  `Short_peak` proteins map to C1/C2/C4 as 130/96/23.

```text
ANALYTICAL PIPELINE VERSION: v1.0
STATUS: FROZEN
MANUAL STAGE VALIDATION: PASS
FULL END-TO-END RUN_ALL: PASS 17/17
FINAL POST-FIX RUN_ALL: PASS 17/17
FINAL OUTPUT AUDIT: PASS
CATEGORY 4 DANGEROUS COMPETING SOURCE-OF-TRUTH: NONE
```

Reasonable regression checks and downstream derivations are retained.

## Frozen-source policy

Stages 01–12 constitute the frozen v1.0 analytical pipeline. Do not modify frozen
analytical source unless a verified scientific or software bug is identified, the
modification is explicitly authorized, the analytical version is incremented,
affected stages are revalidated, and end-to-end reproducibility is re-established
when required. Cosmetic cleanup, code deduplication, refactoring, warning suppression,
or style improvement alone is not sufficient reason to modify frozen v1.0 analytical
source. New biological analyses should preferentially be implemented as downstream
modules rather than by modifying the frozen primary pipeline.

See `descriptive/RUN_ORDER.md` for exact dependencies.
