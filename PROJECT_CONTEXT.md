# Project context

## Permanent identity architecture

```text
PG.ProteinGroups = stable analytical identity/key
Gene_symbol      = canonical biological gene annotation
Display_label    = final human-readable individual-protein figure label
```

All final figures containing individual protein labels display Gene symbol whenever
available. Missing symbols fall back to the stable protein-group identifier and never
exclude proteins. Duplicate gene symbols do not replace the analytical key.

The authoritative starting point is the two raw workbooks plus source code. Tables,
models, reports and figures are regenerable artifacts and are currently absent.

Stages 01–05 establish descriptive, abundance and binary-detection mother data. Stage
06 is covariate QC; Stage 07 is locked limma. Stages 08a/b/c are abundance branches;
08d integrates required abundance products with the separate Stage 09 detection branch.
Stages 10a/b summarize Stage 07 DEPs. Stages 11a/b are descriptive pattern/clustering
branches and Stage 12 deterministically annotates Stage 11a.

Legacy `low`, `high`, and `High_vs_Low` keys remain where needed for validated
contracts; human-facing language uses Control, Short, Long, and Long vs Short.
Acquisition date remains a proxy, not a confirmed biological or technical batch.

The refactored pipeline has not been executed or runtime validated.
