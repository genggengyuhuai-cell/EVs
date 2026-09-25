# CODEX workflow

The repository rebuilds from `rawdata/processed.xlsx`,
`rawdata/sample_mapping_FINAL.xlsx`, and source code. Generated outputs are artifacts,
not sources of truth. Codex must not execute analysis unless the user explicitly
requests execution in a later task.

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

Run one stage at a time and inspect it. The scripts are edited but not rerun.
`descriptive/run_all.py` is a thin fail-fast orchestrator reserved for the final clean
test. See `descriptive/RUN_ORDER.md` for exact dependencies and commands.
