# Final Analysis Freeze Handoff — EV-enriched Plasma Proteomics v2.1

| Field | Value |
|---|---|
| Repository | EVs (git@github.com:genggengyuhuai-cell/EVs.git) |
| Branch | main |
| Frozen commit | 6d0e004e5025bcf7d564dadaead133809a743a14 |
| Tag | analysis-v2.1 |
| Tag object | 9e09e19767c58e165b07e69787dc63d492abe370 (annotated) |
| Tag peeled target | 6d0e004e5025bcf7d564dadaead133809a743a14 |
| Tag message | Validated repaired EV-enriched plasma proteomics analysis pipeline v2.1 |
| Freeze status | FROZEN_REMOTE |
| OPEN_ANALYSIS | 0 |
| CODE_FREEZE | COMPLETE |
| ANALYSIS_V2_1 | FINAL |
| SUBMISSION_READY | NO |

Commit chain (frozen tip to baseline):
- 6d0e004 chore: isolate historical outputs and remove stale artifacts
- 18fd103 docs: reconcile reproducibility, provenance, and reporting status
- f932f8e figures: rebuild main and supplementary figures from repaired outputs
- c8b2c38 results: freeze repaired analysis outputs v2.1
- 96ea08c repair: finalize canonical analysis pipeline v2.1
- 633745d audit: finalize reproducibility and freeze readiness

## Authoritative repaired results (verbatim)
- Discovery 85 locked candidates.
- Holdout 83 direction-concordant / 29 nominally significant / 1 candidate-family BH-FDR-supported.
- M09 Pearson 0.9740605, Spearman 0.9644384, 1343/1430 direction concordant, Primary FDR<0.05=0, KNN FDR<0.05=0.
- Fixed-85 ML EN mean AUROC 0.668688, XGB mean AUROC 0.648769.
- Strict nested 15 outer folds, 7/15 zero-feature folds, 8/15 evaluable/model-fit folds, no feature appearance >=0.70.
- M11 repaired leave-one-site-out under primary M05 estimator, 9/9 site exclusions estimable, interpretation = site-specific sensitivity, not site independence.
- M12 cameraPR=205 (GO-BP 29, Reactome 176), ORA=23 (GO-BP 3, Reactome 20), fgsea family-wise=44 / pooled=41 (dual-reported sensitivity only), KEGG=NOT_RUN.

## Manuscript limitations (15, verbatim)
1. holdout is reused within-cohort, not external validation.
2. only 1/85 candidate-family FDR-supported in holdout.
3. EV-enriched plasma proteomics, not pure EV proteome.
4. site/environment and acquisition-era effects cannot be fully separated.
5. processing time not recorded.
6. freeze-thaw not recorded.
7. storage duration not recorded.
8. injection order not recorded.
9. MS batch recorded but not modeled.
10. contaminant exclusion execution evidence only partial/policy-level.
11. decoy exclusion unresolved.
12. protein FDR provenance unresolved.
13. peptide/PSM-level FDR export unavailable.
14. ML Python environment not located/to confirm.
15. ~~R03 pathway-universe wording remains a reporting/provenance issue, not an analysis blocker.~~ **CLOSED 2026-10-02**: author accepted current three-layer universe (1445 discovery inferential / 1434 mapping registry / 1406 rankable tested); no rerun. See `docs/R03_FINAL_AUTHOR_DECISION.md`. Methods wording must preserve the three-layer distinction.

## Manuscript-stage workflow (verbatim)
- NO MORE ANALYSIS AUDIT.
- Proceed with nature-statistics -> nature-writing -> nature-polishing -> nature-ref-verifier -> nature-reviewer -> pre-submission-reviewer.
- Any future change to frozen numerical results requires a new version/tag.
- Do not silently modify analysis-v2.1 outputs.
