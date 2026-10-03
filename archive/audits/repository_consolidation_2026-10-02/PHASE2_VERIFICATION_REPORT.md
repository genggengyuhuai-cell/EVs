# PHASE2_VERIFICATION_REPORT

**Date**: 2026-10-03
**Phase 2**: Execute repository cleanup, archive historical material, establish single source of truth.

## Git baseline unchanged
- HEAD = `8695ae640a324a3bd0541aa96792d5ec2c2d244b` (unchanged)
- origin/main = `8695ae640a324a3bd0541aa96792d5ec2c2d244b` (unchanged)
- ahead/behind = `0 / 0` (unchanged)
- No commit, no tag, no push.

## Files moved / archived / deleted
- **Moved (archived)**: 925 files/dirs recorded in `PHASE2_MOVE_LOG.csv` (916 initial + 9 in-module
  `.bak`). All `Hash_before == Hash_after` (0 mismatches) — content preserved.
  - By class: ARCHIVE_AUDIT 68, ARCHIVE_PROVENANCE 125, ARCHIVE_DIAGNOSTIC 61, ARCHIVE_SENSITIVITY 632,
    ARCHIVE_HISTORICAL 7 (non-already-archived), ARCHIVE_BACKUP 25 (16+9 .bak), USER_TEMPLATE 2.
  - `archive/superseded_code` → `archive/historical_code` (rename).
- **Deleted**: 2 files, both cache (`descriptive/__pycache__/*.pyc`), recorded in
  `PHASE2_DELETED_FILES.csv` (approved, regenerable, git-recoverable). No other deletion.

## Authoritative controls created
- `docs/FINAL_MAINLINE_MANIFEST.csv` — single active mainline manifest (65 rows; all cited paths verified to exist).
- `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` — sole statistical/reporting contract.
- `docs/LIMITATIONS.md` — accepted unresolved limitations.
- `docs/NEXT_STEPS.md` — the only project-level future-work list.
- `README.md` (root, new), `PROJECT_CONTEXT.md` (rewritten, 14 state fields), `docs/README.md`
  (updated, precedence), `archive/README.md` (new), `external_templates/README.md` (new).

## README coverage (Phase-1 plan)
All 14 proposed READMEs implemented (see `PHASE2_README_LOG.csv`): root, docs, PROJECT_CONTEXT,
archive, external_templates, descriptive/RUN_ORDER, discovery_validation, D02_pairwise_completion,
control_referenced_pathways, environment_stratified_discovery, analysis_v2.0 (+PIPELINE_STATUS),
M12_pathway_v2.1, ml_v2.1, missingness_robustness, descriptive/archive, manuscript_v2_1.

## Claim-map authority
- Sole authoritative claim map = `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv`.
- Older `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` archived to
  `archive/audits/manuscript_claim_map/` (valid claims represented; historical content preserved).
- Path recorded in root README, PROJECT_CONTEXT, FINAL_MAINLINE_MANIFEST, manuscript_v2_1/README.

## Broken active references
- `FINAL_MAINLINE_MANIFEST.csv` path check: 0 missing (fixed 2 stale RUN_ORDER paths).
- Updated moved-path references in active docs: CURRENT_AUTHORITATIVE_RESULTS.md,
  FGSEA_REPORTING_FREEZE.md, docs/protocol/STUDY_DESIGN_AUDIT.md,
  manuscript_v2_1/MANUSCRIPT_STATISTICAL_METHODS_CONTRACT.md (source hierarchy → sole claim map).
- No `.bak` remains in active directories (0). No `__pycache__` remains (0).

## Scientific hash invariance
- Modified tracked files (13) are all documentation (.md/.csv controls + READMEs); no scientific
  result/code file content changed. 913 git-renames are pure moves (hashes preserved).

## Unresolved items
- No scientific items open. Remaining items (all non-scientific) are in `docs/NEXT_STEPS.md`
  (provenance lock, manuscript presentation sync, pathway-count sync, figures, writing/polish/
  reviewer, pre-submission, final release/tag). See also `cleanup_plan/UNRESOLVED_ITEMS.md`.

## Gates
- Gate A (Git identity): PASS. Gate B (no rerun): PASS. Gate C (no frozen numeric change): PASS.
  Gate D (one mainline manifest): PASS. Gate E (one contract): PASS. Gate F (one NEXT_STEPS): PASS.
  Gate G (one claim map): PASS. Gate H (README coverage): PASS. Gate I (archive isolation): PASS.
  Gate J (active-path integrity): PASS. Gate K (scientific invariants: 85 / 85-83-29-1 / 0-1430 /
  205 / 23 / 44&41 / KEGG NOT_RUN / 1445-1434-1406): PASS. Gate L (no uncontrolled deletion): PASS.

## Result
Cleanup succeeded. Working tree contains only intended cleanup changes (13 doc edits + 913 renames +
27 untracked new/control files); nothing is committed. Ready for reviewer sign-off and Phase-2
result reporting. `cleanup_plan/` planning infrastructure is retained for review and should be
archived/removed after approval.
