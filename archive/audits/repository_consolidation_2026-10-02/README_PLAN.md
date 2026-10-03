# README Plan — Proposed Active README Architecture (Phase 1, read-only proposal)

One README per meaningful scientific/project module, not one per small folder.
This plan lists only the READMEs the final consolidated repository should carry.
Final text is NOT written in Phase 1; this is the placement/purpose/supersession map.

---

## 1. Repository root — `F:\env\README.md`  (NEW — currently MISSING)

- **Purpose**: Human entry point. Points to PROJECT_CONTEXT.md for authority, to
  docs/ for controls, lists the three temporal layers (PRESENT / PAST / FUTURE)
  and the single NEXT_STEPS.md.
- **Authoritative inputs to summarize**:
  - `PROJECT_CONTEXT.md` (project identity, frozen numbers, canonical entrypoints)
  - `docs/CONTROL_DOCUMENT_INDEX.csv` (control-doc registry)
  - `docs/ACTIVE_MAINLINE_MANIFEST.csv` + `docs/SUPPLEMENTARY_ANALYSIS_MANIFEST.csv`
  - `docs/post_v2_1_extended_analysis/POST_V2_1_*` (current closure layer)
  - `docs/NEXT_STEPS.md` (Phase-2 created; the single future-work list)
- **Supersedes**: nothing (no root README exists today; PROJECT_CONTEXT.md remains
  the technical overview, README.md is the entry point).
- **Status**: create in Phase 2.

## 2. `docs/README.md`  (UPDATE — exists, banner stale)

- **Purpose**: docs/ index + authority precedence (who decides what).
- **Must fix**: banner dated 2026-10-01 says `BLOCKED / SAFE_TO_TAG=NO`, which
  contradicts PROJECT_CONTEXT.md banner (2026-10-02, SAFE_TO_TAG qualified) and the
  HEAD state. Refresh to point at PROJECT_CONTEXT.md + FINAL_BLOCKER_STATUS.md.
- **Supersedes**: none (same file, refreshed content).

## 3. `descriptive/RUN_ORDER.md`  (UPDATE — exists, serves as descriptive/ module README)

- **Purpose**: module README for the upstream descriptive bundle (scripts 01–13,
  root results, `figures_nature_v2.2/`, covariate_QC, detection_pattern).
- **Authoritative inputs**: `docs/ACTIVE_MAINLINE_MANIFEST.csv` (Upstream descriptive
  row); `descriptive/figures_nature_v2.2/`; the descriptive root scripts.
- **Must note**: `13a_canonical_256_DEP_master.R` and the historical 256-DEP results
  are superseded (discovery-validation redesign) and must not be cited as current.
- **Supersedes**: none (same file, refreshed).

## 4. `descriptive/discovery_validation/README.md`  (UPDATE — exists)

- **Purpose**: canonical D01–D10 pipeline README (existing, current).
- **Must add** (post-v2.1 layer, missing today): D02_pairwise_completion,
  control_referenced_pathways, environment_stratified_discovery; note that the old
  "Pathway analysis NOT_RUN / no approved mapping" CURRENT STATE block is outdated
  (M12 v2.1 pathway is complete). Update Git checkpoint reference.
- **Authoritative inputs**: `DATA_CONTRACTS.md`, `WORKFLOW.md`, `FIGURE_PLAN.md`,
  `docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md`,
  `docs/post_v2_1_extended_analysis/POST_V2_1_*`.
- **Supersedes**: none (same file, refreshed).

## 5. `descriptive/discovery_validation/D02_pairwise_completion/README.md`  (NEW)

- **Purpose**: document the post-v2.1 pairwise completion as a clean extension of
  the frozen D02 (not a rerun); Level-2 status; prohibited claims.
- **Authoritative inputs**: `D02_pairwise_completion/code/D02_pairwise_completion.R`,
  `D02_pairwise_completion/results/*`, `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv`.
- **Supersedes**: none.

## 6. `descriptive/discovery_validation/control_referenced_pathways/README.md`  (NEW)

- **Purpose**: document the post-v2.1 control-referenced pathway analysis
  (cameraPR primary-within-extension / nominal ORA); Level-3 exploratory; 11-theme
  consolidation is descriptive.
- **Authoritative inputs**: `control_referenced_pathways/results/*`,
  `theme_consolidation/CROSS_CONTRAST_THEME_MATRIX.csv`, POST_V2_1 claim map.
- **Supersedes**: none.

## 7. `descriptive/environment_stratified_discovery/README.md`  (NEW)

- **Purpose**: document the post-v2.1 environment-stratified de novo discovery +
  control-referenced pathway sub-analysis (Level-2 supplementary; HH/HA results
  descriptive; prohibited "environment-specific" claims).
- **Authoritative inputs**: `environment_stratified_discovery/results/*`,
  `pathways_control_referenced/results/*`, POST_V2_1 claim map.
- **Supersedes**: none.

## 8. `descriptive/analysis_v2.0/README.md`  (REWRITE — exists, stale)

- **Purpose**: module README for the v2 abundance/pathway/ML mainline (M05–M17,
  M12/M12B, ml_v2.1, figures_final_v2).
- **Must fix**: current README references `ml/ML_ANALYSIS_SPEC_v2.0.md` and `ml/`
  paths that were archived to `archive/historical_frozen/ml_legacy/`. Rewrite around
  the current `ml_v2.1/` + canonical `code/V2_M0*.R` entries.
- **Also refresh**: `descriptive/analysis_v2.0/PIPELINE_STATUS.md` (dated 09-27,
  describes the old ML-era V2-02..V2-05 freeze status; superseded by
  `docs/PIPELINE_STATUS.md`).
- **Authoritative inputs**: `docs/PIPELINE_STATUS.md`, `docs/ACTIVE_MAINLINE_MANIFEST.csv`,
  `docs/CURRENT_AUTHORITATIVE_RESULTS.md`, module `M12_pathway_v2.1/README_METHODS.md`,
  `M12B/README_METHODS.md`, `ml_v2.1/strict_nested/README_METHODS.md`.
- **Supersedes**: the stale in-file ml/ references; NOT a new duplicate of the
  pathway/ML README_METHODS files.

## 9. Pathway analysis — `descriptive/analysis_v2.0/M12_pathway_v2.1/README_METHODS.md`  (UPDATE — exists)

- **Purpose**: keep as the M12 pathway module README (mapping/ranked/ora/ranked_gsea/
  integration/environment + diagnostics). Refresh for Phase-5 repaired state
  (cameraPR 205 / ORA 23 / fgsea dual 44&41 sensitivity-only / KEGG NOT_RUN;
  three-layer universe; R03 closed).
- **Authoritative inputs**: `docs/R03_FINAL_AUTHOR_DECISION.md`,
  `docs/PATHWAY_UNIVERSE_RECONCILIATION.md`, `docs/FGSEA_REPORTING_FREEZE.md`,
  `docs/CURRENT_AUTHORITATIVE_RESULTS.md`.
- **Supersedes**: the pre-repair README_METHODS.md under `pre_repair_snapshot/`
  (kept as provenance, not current).

## 10. `descriptive/missingness_robustness/README_METHODS.md`  (UPDATE — exists)

- **Purpose**: module README for the early missingness robustness analysis. Mark it
  as early/superseded by M09 KNN sensitivity and D09; record the historical results
  as sensitivity, not primary.
- **Authoritative inputs**: `docs/CURRENT_AUTHORITATIVE_RESULTS.md` (M09 repaired
  values), `docs/ACTIVE_MAINLINE_MANIFEST.csv`.
- **Supersedes**: none (same file, refreshed).

## 11. `descriptive/archive/README.md`  (UPDATE — exists)

- **Purpose**: descriptive/ archive rules; which material is archived; that archived
  files are not current source of truth; git recovery pointer.
- **Supersedes**: none (same file, refreshed to include Phase-2 archive plan).

## 12. `archive/README.md`  (NEW — top-level archive)

- **Purpose** (required by task §10): explain why material is archived; that archived
  files are NOT current scientific source of truth; which historical states they
  represent; how Git recovers older states (`git log`, tags `analysis-v1.0`,
  `analysis-v2.0-final`, `analysis-v2.1` peeled `6d0e004`, HEAD `8695ae6`).
- **Supersedes**: none.

## 13. `manuscript_v2_1/README.md`  (NEW — brief)

- **Purpose**: map the manuscript module: which files are authoritative contracts
  (MANUSCRIPT_RESULTS_NUMERIC_CONTRACT / STATISTICAL_METHODS / LIMITATIONS /
  STATISTICS_HANDOFF) vs audit material (audit/); the relationship to
  `docs/post_v2_1_extended_analysis/POST_V2_1_MANUSCRIPT_HANDOFF.md`.
- **Authoritative inputs**: `manuscript_v2_1/audit/MANUSCRIPT_MODULE_MAP.csv`.
- **Supersedes**: none.

## 14. `descriptive/analysis_v2.0/ml_v2.1/README.md`  (NEW — recommended, optional)

- **Purpose**: short ML module README (fixed-85 + strict-nested; conditional-on-85
  interpretation; not external validation).
- **Authoritative inputs**: `ml_v2.1/results/outer_cv_metrics.csv`,
  `strict_nested/README_METHODS.md`.
- **Supersedes**: none.

---

## Not proposed (explicitly avoided to prevent README sprawl)

- No per-D0x README for D01–D10 (covered by the discovery_validation README +
  existing stage manifests); only the three post-v2.1 modules get their own.
- No README inside `pre_repair_snapshot/` / `pre_p20_fix_snapshot/` dirs (provenance
  only; they keep their existing README_METHODS.md untouched as historical).
- No README in `audit_output/` or `docs/workflow/` (historical/archival layers).
- No README per figure bundle (covered by FIGURE_MANIFEST / figure-plan docs).

## Supersession summary

| Proposed README | Supersedes / absorbs |
|---|---|
| F:\env\README.md (new) | — |
| docs/README.md (update) | its own stale banner |
| descriptive/RUN_ORDER.md (update) | its own stale 256-DEP references |
| discovery_validation/README.md (update) | its own outdated "pathway NOT_RUN" block |
| D02_pairwise_completion/README.md (new) | — |
| control_referenced_pathways/README.md (new) | — |
| environment_stratified_discovery/README.md (new) | — |
| analysis_v2.0/README.md (rewrite) | stale ml/ references in that README |
| M12_pathway_v2.1/README_METHODS.md (update) | pre_repair_snapshot README_METHODS (as provenance) |
| missingness_robustness/README_METHODS.md (update) | its own pre-M09 status wording |
| descriptive/archive/README.md (update) | — |
| archive/README.md (new) | — |
| manuscript_v2_1/README.md (new) | — |
| ml_v2.1/README.md (new, optional) | — |

Every active module README should contain: Purpose / Current status / Inputs /
Active code / Final outputs / Source-of-truth file(s) / Key results / Statistical
contract / Known limitations / Historical-superseded material / Reproducibility /
Next step (NONE — module frozen, or point to the single `docs/NEXT_STEPS.md`).
