# UNRESOLVED_ITEMS.md — Phase 1 (read-only)

Only genuinely open matters are listed. Resolved/closed historical blockers
(XGBoost leakage, EN direction, M09/M11/M12 repairs, R03, fgsea reporting freeze,
etc.) are NOT repeated — they are closed and are documented in
`docs/FINAL_BLOCKER_STATUS.md` and `docs/post_v2_1_extended_analysis/`.

Authority note: OPEN_ANALYSIS = 0. Every item below is reporting / provenance /
git / manuscript / repository-organization — none requires reopening a frozen
scientific result.

---

## Scientific

- **None open at analysis level.** All core analyses are repaired/verified and
  frozen (D01–D10, M05–M11, M12/M12B, M14, ml_v2.1, M17). No SCIENTIFIC_REVIEW_REQUIRED
  item with direct current-file evidence was found in Phase 1.
- **Accepted-limitation (not a defect, kept for reporting discipline):** the reused
  129-person hold-out is same-cohort, not external validation; fixed-85 ML is
  conditional on the frozen panel; environment-stratified count differences are
  descriptive, not interaction. These are reporting constraints, not open science.

## Reproducibility

- **R/Python environment not fully locked.** No renv.lock / R lock file; only a
  Python `requirements.txt` exists. Authoritative `docs/SOFTWARE_ENVIRONMENT_LOCK.md`
  exists but sessionInfo/package-pin provenance is open until tag. (FINAL_BLOCKER_STATUS
  → OPEN_PROVENANCE: "环境锁定 OPEN（tag 前必做）").
- **Strict-nested split generator provenance** not closed (split CSV is reusable;
  the generator provenance is open).
- **Proteomics identification QC gap** (contaminant PARTIALLY_VERIFIED policy-only;
  decoy / protein-FDR UNRESOLVED; peptide/PSM NOT_AVAILABLE) — cannot be closed in
  repository; must be written into Methods as a fixed limitation
  (`docs/PROTEOMICS_QC_PROVENANCE_FINAL.md`).

## Provenance

- **P1/P2/P3 workbook identity binding (P1-7)** open: no hash/identity check on the
  upstream workbooks; `mapping_pass` failure is not fatal. Open until documented as
  Methods limitation.
- **Untracked pre-fix backups**: 6 untracked `.phase7/.phase8` backups
  (ACTIVE_MAINLINE_MANIFEST.csv.phase7.bak, CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md.phase8.bak,
  FINAL_REPRODUCIBILITY_AUDIT.md.phase7.bak, FINAL_REPRODUCIBILITY_MANIFEST.csv.phase7.bak,
  PIPELINE_STATUS.md.phase8.bak, SUPPLEMENTARY_ANALYSIS_MANIFEST.csv.phase7.bak,
  manuscript STATISTICAL_CLAIM_MAP.csv.phase7.bak) are NOT git-recoverable; decision
  needed: archive them (recommended) vs commit vs delete.
- **pre_repair_snapshot / pre_p20_fix_snapshot / phase6_pre_rebuild_snapshot**
  directories: proposed to move under `archive/provenance/` in Phase 2 (safe, all
  git-tracked).

## Documentation

- **Authoritative-commit labeling ambiguity (needs author decision, NOT a scientific
  conflict):** `PROJECT_CONTEXT.md` (at HEAD) banner designates `FROZEN_COMMIT =
  6d0e004` (analysis-v2.1) as THE freeze, while the actual HEAD is `8695ae6`
  (post-v2.1 extended contrast + environment-pathway freeze). `POST_V2_1_EXTENDED_
  ANALYSIS_FREEZE.md` itself references HEAD `6e9c62c`. No frozen numeric changed
  (per commit e15c41a and the post-v2.1 freeze), so this is documentation/provenance
  only. Decide: label HEAD 8695ae6 as the current complete candidate-final commit and
  keep analysis-v2.1 as the historical freeze tag.
- **`docs/README.md` banner is stale** (10-01 `BLOCKED / SAFE_TO_TAG=NO`) vs
  PROJECT_CONTEXT.md (10-02 SAFE_TO_TAG qualified). Refresh.
- **`docs/ACTIVE_MAINLINE_MANIFEST.csv` not yet updated for post-v2.1**: still marks
  M14 and D10 as BLOCKED (both were rebuilt post-v2.1) and does not list
  D02_pairwise_completion / control_referenced_pathways / environment_stratified_discovery.
- **`descriptive/analysis_v2.0/README.md` and its `PIPELINE_STATUS.md` are stale**
  (reference archived `ml/` paths; status dated 09-27). Rewrite.
- **Two claim-map authorities** coexist: `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv`
  (core v2.1) and `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv`
  (post-v2.1 Level 1–4). Designate a single authoritative claim map (recommended:
  POST_V2_1_CLAIM_MAP as the superset) and reconcile.
- **`FINAL_REPRODUCIBILITY_MANIFEST.csv`** content (sha256 rows) should be merged into
  the Phase-2 `FINAL_MAINLINE_MANIFEST.csv` before it is archived.

## Repository organization

- **16 untracked files** to dispose in Phase 2: 6–7 untracked `.bak` (above) +
  `docs/PHASE8_COMMIT1-5_FILELIST.txt`, `docs/PHASE8_GIT_COMMANDS.md`,
  `docs/PHASE8_GIT_EXECUTION_PLAN.md` (historical Phase-8 git planning → archive),
  and `报告模板.docx` / `报告模板.rar` at root (likely the user's own report template,
  not a project artifact — require user decision; do not commit/delete without consent).
- **No post-v2.1 Git tag** exists; `analysis-v2.1` is the last tag. Decide whether
  HEAD 8695ae6 should be tagged (e.g. `analysis-v2.2` / `analysis-final`) once
  OPEN_REPORTING + OPEN_PROVENANCE + OPEN_GIT close. (Tag currently prohibited:
  SAFE_TO_TAG held.)
- **`limma_dose_analysis/` and `missingness_robustness/` disposition** (sensitivity vs
  historical) was assigned provisionally (ARCHIVE_SENSITIVITY) but requires
  confirmation that their content is fully superseded by D01–D10 / M05–M11 / M09 / D09
  before moving (manual review flagged in the inventory).
- **`descriptive/__pycache__/` (2 `.pyc`)** — git-tracked cache files; propose delete.

## Manuscript

- **OPEN_REPORTING (presentation layer only; no rerun):**
  - Fig6 full rebuild (a/c/d buildable; panel b depends on final fgsea wording;
    Reactome must be in main figure; GO-MF/CC go to supplement).
  - Fig3–Fig5 panel rebuild inheriting repaired ML/M09/M11 numbers.
  - M14 presentation rebuild from D08 (current M14 files exist and are rebuilt; the
    manuscript presentation/handoff is pending).
  - D10 integrated-table presentation for manuscript (current table rebuilt; manuscript
    use pending).
- **Manuscript audit docs still carry old pathway numbers (195 / 39)** — must be synced
  to 205 / 23 / 44&41 (`docs/FINAL_BLOCKER_STATUS.md` OPEN_REPORTING row).
- **fgsea wording** (sensitivity-only, dual 44/41) to be written into Methods/Supplement.
- **Proteomics QC limitation fixed sentence** to be written into Methods.
- **Tag gate / submission readiness** = BLOCKED until OPEN_REPORTING + OPEN_PROVENANCE +
  OPEN_GIT close; then manuscript assembly / writing / reviewer simulation.

---

## Phase-2 gating summary

Phase 2 cleanup is SAFE for pure file moves/archives/deletes (all git-tracked and
recoverable). It must NOT change: frozen numbers, thresholds, candidate sets, splits,
FDR procedures, pathway methodology, or any current scientific output. It must obtain
the author decision on: (a) HEAD 8695ae6 labeling/tag, (b) disposal of the user's own
`报告模板` files, (c) single claim-map authority.
