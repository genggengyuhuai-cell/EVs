# v2_provenance.md — Provenance Manifest Helper Specification

This file is documentation only and is not executable R.
It describes the structure and behavior of the v2 provenance manifest that
every v2 output must carry.

## Purpose

Every v2 output file must be accompanied by a machine-readable provenance manifest
that records: what input was used, what script produced it, what the output is,
and how to verify it.

## Manifest schema

Each v2 module writes a `<output_stem>.manifest.json` alongside its result files.

### Required fields

| Field | Type | Description |
|---|---|---|
| `module_id` | string | e.g. `V2-05`, `V2-08` |
| `module_name` | string | e.g. `E_contrast_abundance` |
| `analysis_plan_version` | string | e.g. `2.0` |
| `analysis_plan_date` | string | e.g. `2026-09-26` |
| `script_path` | string | Relative path to the script that produced the output |
| `script_version` | string | Git short hash or "uncommitted" |
| `git_commit` | string | Full Git commit hash at execution time |
| `execution_timestamp` | ISO 8601 | When the script was run |
| `seed` | int or null | Random seed if applicable |
| `package_session` | object | R session info (see below) |

### Input files (array of objects)

Each input file entry:

| Field | Type | Description |
|---|---|---|
| `path` | string | Relative path from repo root |
| `sha256` | string | SHA-256 hex digest |
| `rows` | int | Row count (if tabular) |
| `columns` | int | Column count (if tabular) |
| `sample_count` | int or null | Number of samples (if sample-level) |
| `protein_count` | int or null | Number of protein groups (if protein-level) |
| `description` | string | Human-readable description |

### Output files (array of objects)

Each output file entry:

| Field | Type | Description |
|---|---|---|
| `path` | string | Relative path from repo root |
| `sha256` | string | SHA-256 hex digest |
| `rows` | int | Row count |
| `columns` | int | Column count |
| `description` | string | Human-readable description |

### Upstream dependencies (array of strings)

List of `module_id`s whose outputs this module consumed.
Example: `["V2-02", "V2-04"]` means this module depends on the universe registry
and the QC module.

### Package / session information

| Field | Description |
|---|---|
| `r_version` | R version string |
| `limma_version` | limma package version |
| `imports` | List of other loaded packages with versions |

**Note:** The historical `dv_shared.R::dv_manifest()` pattern is directly reusable
for the SHA-256 and input/output hashing logic. The missing piece is
`sessionInfo()` / `packageVersion()` recording, which v2 must add.

## Manifest example (illustrative, not executed)

```json
{
  "module_id": "V2-05",
  "module_name": "E_contrast_abundance",
  "analysis_plan_version": "2.0",
  "analysis_plan_date": "2026-09-26",
  "script_path": "descriptive/analysis_v2.0/abundance/V2-05_E_contrast.R",
  "script_version": "abc1234",
  "git_commit": "abc1234def567890...",
  "execution_timestamp": "2026-09-28T10:00:00+08:00",
  "seed": null,
  "inputs": [
    {
      "path": "rawdata/processed.xlsx",
      "sha256": "...",
      "rows": 3817,
      "columns": 526,
      "sample_count": 519,
      "protein_count": 3817,
      "description": "Spectronaut PG.Quantity export"
    }
  ],
  "outputs": [
    {
      "path": "descriptive/analysis_v2.0/abundance/V2-05_E_contrast_results.csv",
      "sha256": "...",
      "rows": 1400,
      "columns": 15,
      "description": "E contrast results on Q515"
    }
  ],
  "upstream_dependencies": ["V2-02", "V2-03"],
  "package_session": {
    "r_version": "4.x.x",
    "limma_version": "3.x.x",
    "imports": ["dplyr", "readxl"]
  }
}
```

## Reusable historical patterns

| Pattern | Source | Reuse as |
|---|---|---|
| SHA-256 file hashing | `dv_shared.R::dv_manifest()` | Direct function |
| Input/output manifest writing | `dv_shared.R::dv_manifest()` | Direct function |
| Frozen assignment hash verification | `dv_shared.R::dv_assignment()` | Pattern; v2 adds Utech registry hash check |

## Gaps to fill in v2

1. **Session/package recording**: No historical script records `sessionInfo()` or `packageVersion()`. v2 must add this.
2. **Cross-stage dependency DAG**: Historical manifest is per-stage only. v2 must record `upstream_dependencies` to enable a dependency graph.
3. **Seed recording**: Historical scripts hard-code seeds in comments. v2 must record the actual seed used in the manifest.
