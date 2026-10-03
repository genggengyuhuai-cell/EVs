# NEXT_STEPS

**THE only active project-level future-work list.** No other file acts as a competing TODO.
Completed items are kept below in a short completed-history section and are not listed as open.
Items here are reporting / provenance / manuscript / git — none reopens a frozen scientific result
(OPEN_ANALYSIS = 0).

Each open item has: **status** · **scope** · **allowed modifications** · **completion criterion**.

---

## Completed history

The repository consolidation and its integrity verification are complete (sign-off 2026-10-03).
The Phase 1 / Phase 2 planning and execution records are preserved (contents unmodified) at:

`archive/audits/repository_consolidation_2026-10-02/`

- **Repository consolidation** — COMPLETED. Moves + control-document set + module README system
  + single claim-map authority; `cleanup_plan/` archived to the location above.
- **Verify cleanup integrity** — COMPLETED. Gates A–L pass; HEAD unchanged; no scientific file
  content changed; archive isolated; active references intact. `PHASE2_VERIFICATION_REPORT.md`
  (in the archived consolidation folder) records the full result.

---

## 1. Resolve documentation/provenance-only residuals where possible
- **status**: OPEN
- **scope**:
  - R/Python environment lock: add/recover `sessionInfo` / package pins; record or honestly
    disclose the Python/ML environment (xgboost, glmnet, sklearn) before submission.
  - Strict-nested split-generator provenance: close or document as limitation.
  - Proteomics identification/QC gap: write fixed Methods limitation sentence (contaminant
    policy-only, decoy/protein-FDR unresolved).
  - P1/P2/P3 workbook identity binding: document as Methods limitation if cannot be closed.
  - Check stale active-doc pathway counts 195/39 → 205/23/44&41 anywhere still unfixed in active
    (non-archived) documentation.
- **allowed**: documentation edits only; archived history left historically faithful.
- **completion**: all provenance items either closed or stated in Methods/LIMITATIONS; no active
  doc carries superseded pathway counts.

## 2. Rebuild/update manuscript presentation layer (Fig3–6)
- **status**: OPEN (presentation only; no rerun)
- **scope**: Fig6 rebuild (a/c/d buildable; panel b depends on final fgsea wording; Reactome must
  be in main figure; GO-MF/CC to supplement); Fig3–Fig5 panel rebuild inheriting repaired
  ML/M09/M11 numbers.
- **allowed**: rebuild figures from existing source_data / current numbers; NO re-running of
  statistical analyses.
- **completion**: current Fig3–6 reflect frozen accepted numbers.

## 3. Synchronize M14 / D10 manuscript presentation
- **status**: OPEN
- **scope**: M14 presentation rebuild from D08; D10 integrated-table presentation for manuscript
  (current files rebuilt; manuscript use pending). Deprecated peptide evidence stays inactive.
- **allowed**: presentation/handoff only.
- **completion**: manuscript figure/table references match current M14/D10 outputs.

## 4. Synchronize current pathway counts in manuscript text/captions
- **status**: OPEN
- **scope**: 205/23/44&41, KEGG NOT_RUN, cameraPR PRIMARY / ORA COMPLEMENTARY / fgsea
  SENSITIVITY-ONLY wording; fgsea dual 44/41 into Methods/Supplement.
- **allowed**: text/caption edits per `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md`.
- **completion**: no manuscript text uses 195/39 or claims fgsea primary or reports KEGG.

## 5. nature-statistics (statistical methods/figures review)
- **status**: OPEN
- **scope**: statistical-check and figure-check passes per manuscript contracts.
- **allowed**: review/edits only; frozen numbers unchanged.
- **completion**: manuscript statistics checklist passes.

## 6. Final figures
- **status**: OPEN
- **scope**: final figure set + source_data + supplement per `docs/FINAL_MAINLINE_MANIFEST.csv`.
- **allowed**: figure assembly from frozen source data.
- **completion**: figure bundle consistent with accepted counts.

## 7. nature-writing
- **status**: OPEN
- **scope**: write manuscript using `POST_V2_1_MANUSCRIPT_HANDOFF.md` allowed prose + contracts.
- **allowed**: prose per claim map/contracts; prohibited claims never used.
- **completion**: complete draft bound to sole claim map `POST_V2_1_CLAIM_MAP.csv`.

## 8. nature-polishing
- **status**: OPEN
- **scope**: editorial polish, consistent terminology ("reused within-cohort hold-out",
  "EV-enriched plasma proteomics").
- **allowed**: editorial only.
- **completion**: polished draft.

## 9. Reference verification
- **status**: OPEN
- **scope**: verify all citations.
- **allowed**: reference-only edits.
- **completion**: reference list verified.

## 10. nature-reviewer (reviewer simulation)
- **status**: OPEN
- **scope**: pre-submission risk review per `manuscript_v2_1/audit/REVIEWER_RISK_REGISTER.md`.
- **allowed**: review simulation; fixes still constrained to allowed-prose/figures.
- **completion**: reviewer-sim report produced.

## 11. Pre-submission review
- **status**: OPEN
- **scope**: manuscript + figures + supplement final QA against contracts.
- **allowed**: QA/edits.
- **completion**: pre-submission sign-off.

## 12. Final release / tag
- **status**: OPEN (tag occurs after verification + close of OPEN_REPORTING / OPEN_PROVENANCE /
  OPEN_GIT and after the approved cleanup is committed)
- **scope**: create the post-v2.1 closure release tag for HEAD `8695ae6...` (e.g. a candidate
  final-release tag); `analysis-v2.1` remains the historical repaired-core freeze tag (untouched).
- **allowed**: git tag + commit of approved cleanup; NO scientific rerun.
- **completion**: HEAD `8695ae6` tagged; submission-ready.

---

## Explicitly NOT planned
- **No new exploratory analyses** will be added. OPEN_ANALYSIS = 0.
- No reopening of frozen analyses, no threshold/FDR/split/candidate/pathway-methodology changes.
