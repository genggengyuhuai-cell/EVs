# LIMITATIONS

**Accepted unresolved limitations only.** Repaired bugs and closed blockers are NOT listed here.
Each item is an accepted limitation of the current scientific state at HEAD
`8695ae640a324a3bd0541aa96792d5ec2c2d244b`. Manuscript text may state these as limitations;
none should be silently dropped or "fixed" by reinterpretation.

## Design / inference
1. **Reused within-cohort hold-out is not external validation.** The hold-out (n=129) is a
   reused subset of the same cohort; replication evidence is within-cohort only.
2. **Only 1/85 candidate-family BH-FDR-supported** in the reused hold-out (29/85 nominal,
   83/85 direction concordant). Replication support is partial.
3. **Environment-stratified discovery counts are descriptive/supplementary**, not environment-
   specific effects. HA HvC 75 and HA EC 7 are stratum-level, not externally validated.
4. **No formal Group × Environment interaction** survived prespecified BH-FDR (0/1,430);
   cross-environment count differences are not interaction evidence.
5. **Low-vs-Control and High-vs-Control have 0 protein-level BH-FDR discoveries.** All
   control-referenced claims must be pathway-level or descriptive, not protein-level DEP claims.
6. **Post-v2.1 secondary/exploratory analyses were not pre-registered** as primary endpoints.
7. **No hold-out protein outcomes were accessed** in post-v2.1 environment-stratified or
   control-referenced pathway work.

## Pathway
8. **Control-referenced pathway results (LVC 258, HVC 38) are exploratory ranked analyses** on
   1,406 mapped+estimable genes; hypothesis-generating, not primary endpoints.
9. **fgsea is sensitivity only**; KEGG was not run.
10. **GO-BP and Reactome pathways are highly redundant**; significant pathway counts are not
    counts of independent biological mechanisms.
11. **No fold-change cutoff** was used in ranked or ORA analyses; nominal-P ORA sets (114 LVC /
    145 HVC) are not FDR-significant protein sets.
12. **cameraPR direction reflects ranked gene-set shift**, not mechanistic activation/inhibition.
13. **Pathway theme consolidation (11 themes) is an interpretation layer**, not 11 independent
    mechanisms. "Opposite-direction" proteasome/cytoskeleton/redox/phosphorylation themes reflect
    Low-down vs HvL-up; High-vs-Control is non-significant (a Low-suppression pattern, not High
    activation).

## ML
14. **Fixed-85 ML is conditional on the frozen candidate set** — conditional discrimination,
    not unbiased end-to-end performance, clinical prediction, or diagnostic validation.
15. **Strict-nested feature-selection instability**: 7/15 outer folds yielded no features;
    discovery is highly sensitive to training-sample composition (resampling instability does not
    prove biological heterogeneity). Stable feature appearance ≥0.70: NONE.

## Provenance / environment
16. **Proteomics identification/QC provenance gaps**: contaminant policy-level, decoy status,
    and protein-level FDR provenance are unresolved. Study material is EV-enriched plasma
    proteomics (not a pure EV proteome).
17. **P1/P2/P3 workbook identity-binding limitation**: the identity binding between these
    workbooks and the current analysis is not fully resolved.
18. **Python / ML execution environment NOT_LOCATED / TO_CONFIRM.** Before submission, either
    locate and record the original interpreter/package versions (xgboost, glmnet, sklearn) or
    disclose the gap honestly. R environment is frozen (see
    `docs/SOFTWARE_ENVIRONMENT_LOCK.md`).
19. **Environment lock / provenance** for some reproducibility layers remains incomplete (site/
    acquisition confounding, strict-nested generator reproducibility).
20. **Pathway counts are bound to annotation package versions** (org.Hs.eg.db 3.18.0, GO.db
    3.18.0, reactome.db 1.86.2, etc.); a Bioconductor upgrade + rerun would change counts.

## Editorial
21. **Manuscript presentation layer for Fig3–6 and M14/D10 rebuild is still pending** (see
    `docs/NEXT_STEPS.md`); current figures do not yet reflect all post-v2.1 presentation updates.
