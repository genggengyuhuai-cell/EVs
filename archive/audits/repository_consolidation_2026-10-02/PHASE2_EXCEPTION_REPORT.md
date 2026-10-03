# PHASE2_EXCEPTION_REPORT

**NO_PHASE2_EXCEPTIONS**

No scientific conflict was found during Phase 2. No frozen numeric result, threshold, FDR
procedure, candidate set, discovery/validation split, statistical model, or pathway methodology
was changed. No `SCIENTIFIC_CONFLICT_FOUND` was recorded.

## Transparency notes (non-scientific consolidation decisions, not exceptions)

These deliberate actions were taken per the Phase-2 task itself and are fully logged in
`PHASE2_CONTROL_DOC_MERGE_LOG.csv` / `PHASE2_MOVE_LOG.csv`:

1. **Old mainline manifests archived**: `docs/ACTIVE_MAINLINE_MANIFEST.csv` and
   `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv` were Phase-1 `KEEP_ACTIVE` but were archived to
   `archive/audits/docs_audits/` and their content merged into the single
   `docs/FINAL_MAINLINE_MANIFEST.csv`, per task Section 17 ("exactly one authoritative manifest
   after Phase 2") and Section 6 ("stale active-mainline/supplementary manifests"). Also
   `docs/CONTROL_DOCUMENT_INDEX.csv` archived (superseded by `docs/README.md` precedence).
2. **9 `.bak` files in active module dirs moved to `archive/backups/`**: these were Phase-1
   `KEEP_ACTIVE` but are backup files; moved per task Section 7 ("do not leave `.phase*.bak`
   files in active directories"; "move `.bak` files"). Content unchanged (hashes recorded);
   canonical non-`.bak` files remain in place.
3. **Report templates moved unchanged** to `external_templates/` per Section 3.2; not inspected,
   not modified, not committed.
4. **`archive/superseded_code` renamed to `archive/historical_code`** per the final tree.

None of the above alters scientific content or the Git baseline.
