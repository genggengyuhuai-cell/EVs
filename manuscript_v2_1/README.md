# manuscript_v2_1 — README

## Module
Manuscript preparation for the EV-enriched plasma proteomics v2.1 analysis.

## Purpose
Holds the manuscript-facing contracts and audit material that bind nature-writing to the frozen
statistical state.

## Status
ACTIVE (manuscript preparation in progress — see `docs/NEXT_STEPS.md`).

## Authoritative contracts (active)
- `MANUSCRIPT_STATISTICAL_METHODS_CONTRACT.md` — manuscript statistical-methods contract
  (binds to `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md`).
- `MANUSCRIPT_RESULTS_NUMERIC_CONTRACT.md` — manuscript numeric results contract.
- `MANUSCRIPT_LIMITATIONS_CONTRACT.md` — manuscript limitations (folded into
  `docs/LIMITATIONS.md`).
- `MANUSCRIPT_STATISTICS_HANDOFF.md` — statistics handoff.
- Upstream claim authority: `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` (sole
  claim map) and `POST_V2_1_MANUSCRIPT_HANDOFF.md`.

## Audit / review material (`audit/`)
- `MANUSCRIPT_MODULE_MAP.csv`, `REVIEWER_RISK_REGISTER.csv`, `STATISTICAL_REPORTING_AUDIT.md`,
  `WHOLE_PROJECT_SCIENTIFIC_REVIEW.md`, `EXPERIMENTAL_DESIGN_REVIEW.md`,
  `PROJECT_RECONSTRUCTION_PLAN.md`, `FIGURE_TEXT_AUDIT.csv`,
  `FIGURE_TEXT_STANDARDIZATION_REPORT.md`.
- These are current manuscript QA/audit documents (active supporting).
- The older claim map `audit/STATISTICAL_CLAIM_MAP.csv` was archived (historical) under
  `archive/audits/manuscript_claim_map/`; the active claim authority is
  `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv`.

## Source of truth
- Claims: `POST_V2_1_CLAIM_MAP.csv`.
- Numbers: `MANUSCRIPT_RESULTS_NUMERIC_CONTRACT.md` + `docs/CURRENT_AUTHORITATIVE_RESULTS.md`
  + `docs/post_v2_1_extended_analysis/POST_V2_1_EXTENDED_ANALYSIS_FREEZE.md`.
- Methods: `MANUSCRIPT_STATISTICAL_METHODS_CONTRACT.md` + `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md`.

## Next Step
See `docs/NEXT_STEPS.md` (figures, pathway-count sync, nature-writing/polishing/reviewer,
pre-submission, release/tag).
