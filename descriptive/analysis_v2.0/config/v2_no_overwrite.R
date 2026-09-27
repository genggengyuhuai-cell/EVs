# v2_no_overwrite.R — No-Overwrite / Frozen-Output Protection Specification

This file is a **specification only**. It has not been executed.

## Purpose

Prevent accidental overwriting of frozen historical results and v2 outputs.
v2 scripts must never write to historical result directories.
If a v2 output file already exists, the script must stop rather than overwrite it.

## Rules

### 1. v2 must never write to historical directories

The following directories are **read-only** for all v2 scripts:

| Forbidden write target | Reason |
|---|---|
| `descriptive/limma_dose_analysis/` | Frozen v1.0 pipeline outputs |
| `descriptive/discovery_validation/` | Frozen D01–D10 outputs |
| `descriptive/discovery_validation_split/` | Frozen 386/129 assignment |
| `descriptive/missingness_robustness/` | Frozen D0–D3 outputs |
| `rawdata/` | Source data |
| `docs/protocol/` | Frozen protocol documents |

Any v2 script that attempts to write to these paths must raise an error and stop.

### 2. v2 outputs go only to `descriptive/analysis_v2.0/`

All v2 results, intermediate files, manifests, figures, and tables must be written
under `descriptive/analysis_v2.0/`.

### 3. No-overwrite guard

Before writing any output file, v2 must check:

```
IF output_path exists:
    STOP with error: "Output already exists: <path>. Delete manually if re-run is authorized."
```

This mirrors the historical `dv_shared.R::dv_no_overwrite()` pattern.
The historical function is **not modified**; v2 implements its own equivalent.

### 4. Re-run policy

Frozen source and historical outputs must not be modified or overwritten.
Any future reproducibility rerun requires explicit investigator authorization
and must write to a separate verification output location.

For v2 outputs:
- First run: create new file.
- Accidental partial output: delete the specific file manually, then re-run.
- No silent overwrite. No `overwrite=TRUE` default.

### 5. Implementation sketch (not yet coded)

```r
v2_no_overwrite <- function(path) {
  if (file.exists(path)) {
    stop(sprintf(
      "[v2_no_overwrite] Output already exists: %s\n",
      "Delete manually if this re-run is investigator-authorized."
    ), call. = FALSE)
  }
}

v2_check_write_root <- function(path) {
  forbidden <- c(
    "limma_dose_analysis",
    "discovery_validation",
    "discovery_validation_split",
    "missingness_robustness",
    "rawdata"
  )
  for (f in forbidden) {
    if (grepl(f, path)) {
      stop(sprintf("[v2_no_overwrite] v2 must not write to %s", path), call. = FALSE)
    }
  }
}
```

## Reusable historical pattern

| Pattern | Source | Reuse as |
|---|---|---|
| No-overwrite guard | `dv_shared.R::dv_no_overwrite()` | Same logic, v2 path constants |
| Frozen assignment hash check | `dv_shared.R::dv_assignment()` | Same pattern; v2 also checks Utech registry hash |

**Note:** `dv_shared.R` is **not modified**. v2 implements its own guard functions
in `config/v2_no_overwrite.R` when implementation begins.
