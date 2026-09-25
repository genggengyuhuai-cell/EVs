# Reproducibility guide

The current canonical execution guide is [`descriptive/RUN_ORDER.md`](../descriptive/RUN_ORDER.md).

The pipeline starts from `rawdata/processed.xlsx` and
`rawdata/sample_mapping_FINAL.xlsx`. Begin with:

```powershell
cd descriptive
python 01_describe_proteomics.py
```

During manual validation, run exactly one stage and inspect its outputs before the
next. `run_all.py` is reserved for the final clean test and has not been executed or
runtime validated after the structural refactor.

`PG.ProteinGroups` is the analytical key. Stage 01 creates
`canonical_protein_annotation.csv` with `Gene_symbol` and `Display_label`; visible
individual-protein labels use `Display_label`.
