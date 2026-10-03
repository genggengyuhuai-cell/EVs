# PHASE1_CONSOLIDATION_REPORT.md — EV / Plasma Proteomics Repository

Read-only Phase 1 inventory and single-source-of-truth reconstruction. No file in
`F:\env` was modified, moved, renamed, or deleted. Git baseline was verified and is
unchanged. Only the authorized `cleanup_plan/` files were created.

---

## 1. Current repository condition

- **Files (excluding `.git`)**: 2,347. **Total size**: ~366 MB.
- **Git status**: HEAD `8695ae6` (2026-10-02, "freeze post-v2.1 extended contrast and
  environment pathway analyses"); 0 / 0 ahead-behind vs `origin/main`; tag
  `analysis-v2.1` (annotated) peels to `6d0e004`. 2,294 tracked / 22 untracked /
  31 ignored. Working tree clean except the 22 untracked files.
- **Layers present**: PRESENT (active mainline D01–D10 + M05–M17 + post-v2.1
  extensions + manuscript contracts), PAST (archive/, historical_frozen, superseded
  code, phase/audit reports, .bak snapshots), FUTURE (scattered in multiple
  status/TODO docs — to be collapsed into a single `docs/NEXT_STEPS.md` in Phase 2).
- **Current scientific mainline (HEAD)**: 85 High-vs-Low discovery DEPs (D02/D03);
  hold-out hierarchy 85/83/29/1 (D08, reused within-cohort, NOT external validation);
  M10 interaction 0/1430; M12 HvL cameraPR 205 (primary) / ORA 23 (complementary) /
  fgsea 44&41 (sensitivity-only) / KEGG NOT_RUN; M12B context; ml_v2.1 fixed-85 +
  strict-nested; post-v2.1 Level-2/3/4 (environment-stratified, pairwise vs control,
  control-referenced pathways, 11-theme consolidation).
- **Source-of-truth precedence applied**: current code/outputs at HEAD > author
  decision records (R03) > current manifests/contracts > module README > historical
  freeze/audit reports > .bak > superseded outputs.

## 2. Classification totals (all 2,347 files, exactly one class each)

| Class | Count | Meaning |
|---|---|---|
| KEEP_ACTIVE | 370 | Current scientific/project source of truth |
| KEEP_SUPPORTING | 716 | Current but not primary (supplementary/upstream QC/module controls) |
| ARCHIVE_SENSITIVITY | 632 | Valid sensitivity/early-descriptive, not primary (limma_dose, missingness) |
| ARCHIVE_HISTORICAL | 347 | Superseded/historical material (incl. already-archived) |
| ARCHIVE_PROVENANCE | 125 | Pre-fix snapshots + untracked backups (preserve evidence) |
| ARCHIVE_AUDIT | 68 | Old audit/phase/status docs (provenance only) |
| ARCHIVE_DIAGNOSTIC | 68 | Diagnostic-only outputs (not manuscript-primary) |
| DELETE_CANDIDATE | 19 | Redundant .bak / cache, all git-recoverable or regenerable |
| REVIEW_REQUIRED | 2 | `报告模板.docx` / `报告模板.rar` (untracked user files) |

- **Active source-of-truth files**: 370 (KEEP_ACTIVE); with supporting current: 1,086.
- **Proposed for archive** (Phase 2 move, all recoverable): 1,240.
- **Delete candidates**: 19 (none deleted in Phase 1).

## 3. Duplicate / overlapping control-document families

Mapped in `CONTROL_DOCUMENT_DUPLICATION_MAP.csv` (63 rows). Principal families:

1. **FINAL_REPRODUCIBILITY_AUDIT / MANIFEST** — current info lives in
   `FINAL_BLOCKER_STATUS.md` + `TAG_READINESS_GATE.md`; audit files → archive.
2. **Blocker status** — `FINAL_BLOCKER_STATUS.md` (current) vs
   `AUDIT_BLOCKER_CLOSURE_STATUS.md` + `STATUS_OVERRIDE` (historical).
3. **Mainline manifests** — `ACTIVE_MAINLINE_MANIFEST.csv` (+ 4 .bak) and
   `SUPPLEMENTARY_ANALYSIS_MANIFEST.csv` (+ 2 .bak); need post-v2.1 update.
4. **PIPELINE_STATUS** — `docs/PIPELINE_STATUS.md` (current) vs
   `descriptive/discovery_validation/PIPELINE_STATUS.md` (module) vs
   `descriptive/analysis_v2.0/PIPELINE_STATUS.md` (09-27 stale ML-era).
5. **Control-doc registry** — `CONTROL_DOCUMENT_INDEX.csv` (master) vs
   `CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md` vs `FINAL_REPOSITORY_RECONSTRUCTION_AUDIT.md`.
6. **Claim maps** — `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` (core) +
   `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` (post-v2.1 superset);
   single authority to be designated.
7. **PHASE*/handoff** — `audit_output/PHASE5-8/ROUND2/PHASE10/PHASE11`, `PHASE8_*`
   git plans (historical) vs `FINAL_ANALYSIS_FREEZE_HANDOFF.md` +
   `POST_V2_1_MANUSCRIPT_HANDOFF.md` + `MANUSCRIPT_STATISTICS_HANDOFF.md` (current).
8. **Freeze/contract docs** — FGSEA / SPLIT / PREANALYTICAL / PATHWAY_UNIVERSE /
   TAG_GATE / SOFTWARE_ENVIRONMENT / PROTEOMICS_QC / R03 — each distinct, no merge.
9. **.bak families** — tracked .bak → delete (git-recoverable); untracked
   `.phase7/.phase8` → archive/provenance.

Content to merge before archival: FINAL_REPRODUCIBILITY_MANIFEST sha256 rows →
`FINAL_MAINLINE_MANIFEST.csv`; POST_V2_1_SOURCE_MANIFEST rows → mainline manifests.

## 4. Unresolved issues

- **Scientific**: none open (OPEN_ANALYSIS = 0). No SCIENTIFIC_REVIEW_REQUIRED item
  with direct current-file evidence. See `UNRESOLVED_ITEMS.md`.
- **Non-scientific (open)**: environment lock, P1/P2/P3 workbook identity, split
  generator provenance, proteomics-QC gap (→ Methods limitation); stale
  PROJECT_CONTEXT/README/manifest banners; dual claim-map authority; 16 untracked
  files; no post-v2.1 tag; Fig3–6 & M14/D10 manuscript presentation rebuild; manuscript
  old pathway numbers (195/39) to sync.

## 5. Special files reviewed

- **D02 pairwise completion** — clean post-v2.1 extension of frozen D02; KEEP_ACTIVE;
  not a rerun. ✔
- **D10 integrated biology** — current D10 files rebuilt from frozen sources; deprecated
  peptide evidence removed (M14_frozen_status: "unique-peptide evidence deprecated");
  `pre_p20_fix_snapshot/` → `archive/provenance/`. ✔
- **R03** — `R03_FINAL_AUTHOR_DECISION.md` = author decision record (CLOSED_ACCEPT_...),
  no conflicting implementation; KEEP_ACTIVE. ✔
- **M14** — current reconciliation files (`M14_frozen_status.csv`,
  `M14_replication_hierarchy.csv`) rebuilt post-v2.1, distinct from historical M13/M14;
  `.orig.bak` → provenance. ✔
- **Old audits (Phase 5/6/7/8/10/11)** → historical provenance (archive/audits). ✔
- **Untracked backups + PHASE8 git plans** — classified; none auto-added to Git. ✔

## 6. Phase 2 recommendation

**SAFE_TO_CONSOLIDATE_WITH_MANUAL_EXCEPTIONS**

Phase 2 may safely perform pure file moves/archives/deletes (all proposed archive and
delete items are git-tracked and recoverable, or untracked-but-preserved). It MUST
preserve every frozen numeric / threshold / candidate / split / FDR / pathway result
unchanged, and must obtain author decisions on:
(a) labeling/tagging HEAD `8695ae6` as the current complete candidate-final state
    (analysis-v2.1 remains the historical freeze tag);
(b) disposal of `报告模板.docx` / `报告模板.rar` (user's own files);
(c) single authoritative claim map (POST_V2_1_CLAIM_MAP as superset).
No scientific conflict was found that would block consolidation.

Phase 1 output files (all under `F:\env\cleanup_plan\`):
`REPOSITORY_INVENTORY.csv`, `CONTROL_DOCUMENT_DUPLICATION_MAP.csv`, `README_PLAN.md`,
`ARCHIVE_PLAN.csv`, `DELETE_CANDIDATES.csv`, `UNRESOLVED_ITEMS.md`,
`PROPOSED_FINAL_REPOSITORY_TREE.txt`, and this report.
