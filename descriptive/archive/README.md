# descriptive/archive/ — Archived descriptive material

Files under this directory (and under the top-level `archive/`) are **legacy, superseded,
diagnostic, sensitivity, provenance, or backup** material retained only for historical
auditability. They are **not** active pipeline stages and are **not** current scientific source
of truth.

- Do not execute them as active stages or use them to satisfy missing upstream outputs.
- Current source of truth is defined by `docs/FINAL_MAINLINE_MANIFEST.csv` and
  `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md`.
- Phase-2 archived material (sensitivity / provenance / diagnostics / backups) moved to
  `archive/`; see `archive/README.md` for the directory-class guide and Git recovery.
- Historical numeric differences inside archived files are left historically faithful — do not
  rewrite them to match current numbers.
