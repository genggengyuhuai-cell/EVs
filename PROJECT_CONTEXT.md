# PROJECT_CONTEXT.md

Short machine/human context for the EV-enriched plasma proteomics repository. This is the
top-level project-state entry point after Phase 2 consolidation. It deliberately stays short and
does not duplicate the statistical contract (`docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md`).

## State fields

```
CURRENT_SCIENTIFIC_HEAD          = 8695ae640a324a3bd0541aa96792d5ec2c2d244b
CURRENT_BRANCH                   = main
CURRENT_REMOTE                   = origin/main
ANALYSIS_CORE                    = CLOSED
OPEN_ANALYSIS                    = 0
CURRENT_RELEASE_STATUS           = POST_V2_1_CLOSURE_COMPLETE_PENDING_FINAL_RELEASE_TAG
HISTORICAL_CORE_FREEZE_TAG       = analysis-v2.1
HISTORICAL_CORE_FREEZE_COMMIT    = 6d0e004e5025bcf7d564dadaead133809a743a14
MANUSCRIPT_STATUS                = IN_PROGRESS
SUBMISSION_READY                 = NO
```

## Interpretation (must not be misread)

- **`8695ae6` is the current complete scientific HEAD** (post-v2.1 extended contrast +
  environment-pathway closure). No final release tag exists yet; tagging happens only after
  Phase 2 verification and closure of reporting/provenance/git items (see `docs/NEXT_STEPS.md`).
- **`analysis-v2.1` → `6d0e004` is a valid historical repaired-core freeze**, NOT the current
  complete scientific state. It must not be moved, rewritten, deleted, or retargeted, and must
  not be relabeled as the current final version.
- No scientific analysis is open. The remaining work is reporting / provenance / manuscript /
  git / repository only.

## Authoritative controls (read these, in this order)

1. `README.md` — human entry point.
2. `docs/FINAL_MAINLINE_MANIFEST.csv` — single active file registry.
3. `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` — sole statistical/reporting contract.
4. `docs/LIMITATIONS.md` — accepted unresolved limitations.
5. `docs/NEXT_STEPS.md` — the only project-level future-work list.
6. `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` — sole authoritative claim map.
7. `docs/CURRENT_AUTHORITATIVE_RESULTS.md`, `docs/FINAL_BLOCKER_STATUS.md`,
   `docs/R03_FINAL_AUTHOR_DECISION.md` — frozen results / status / decision records.
8. `audit_output/FINAL_ANALYSIS_FREEZE_HANDOFF.md` — analysis-freeze handoff (the only active
   file kept from the old audit set).

## Repository layers

- **ACTIVE**: current scientific + project-control source of truth (see
  `docs/FINAL_MAINLINE_MANIFEST.csv` Status `ACTIVE_PRIMARY` / `ACTIVE_SUPPORTING`).
- **ARCHIVE** (`archive/`): historical / provenance / sensitivity / diagnostic / backup
  material only. **Nothing under `archive/` is current scientific source of truth** unless the
  active manifest explicitly references it for provenance (see `archive/README.md`).
- **FUTURE**: `docs/NEXT_STEPS.md` (single authoritative remaining-work list).

## Core frozen results (summary only — see contract for exact wording)

- 85 / 1,445 High-vs-Low discovery candidates (n=386; reused within-cohort hold-out 85/83/29/1,
  NOT external validation).
- M10 interaction 0 / 1,430 (pure 2-df).
- Pathway: cameraPR 205 (29 GO-BP + 176 Reactome) PRIMARY · ORA 23 (3 + 20) COMPLEMENTARY ·
  fgsea 44 family / 41 pooled SENSITIVITY ONLY · KEGG NOT_RUN.
- Universes (R03 closed by author decision): 1445 discovery inferential / 1434 mapping
  registry / 1406 rankable tested (plus 1414 ORA background, 1430 Q515).
