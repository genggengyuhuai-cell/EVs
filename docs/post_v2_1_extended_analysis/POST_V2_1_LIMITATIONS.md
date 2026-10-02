# Post-v2.1 Extended Analysis — Limitations

## Frozen primary limitations (already established)
- Reused within-cohort hold-out (n=129), NOT external validation.
- Only 1/85 candidate-family BH-FDR-supported in hold-out.
- Strict-nested feature-selection instability demonstrated.
- Fixed-85 ML is conditional on frozen feature selection.
- No Group × Environment interaction survived prespecified BH-FDR (0/1,430).
- Site LOO is robustness, not independent replication.
- fgsea is sensitivity only; KEGG not run.
- Proteomics QC provenance gaps (contaminant policy-level, decoy status, protein-level FDR provenance unresolved).

## New post-v2.1 limitations
1. **Overall Low-vs-Control and High-vs-Control have 0 protein-level BH-FDR discoveries.** All claims about Low/High vs Control must be pathway-level or descriptive, not protein-level DEP claims.
2. **HA High-vs-Control 75 and HA Exposure-vs-Control 7 are stratum-level discoveries** within 177 HA samples; they are not externally validated and do not establish high-altitude specificity. M10 interaction is null.
3. **Environment-stratified High-vs-Low is 0 FDR in both HH and HA.** No stratum replicated the frozen 85 High-vs-Low signal after stratum-specific BH.
4. **Control-referenced pathway results (LVC 258, HVC 38) are exploratory ranked analyses** on 1,406 mapped+estimable genes. They are hypothesis-generating, not primary endpoints.
5. **Nominal-P ORA sets (114 LVC, 145 HVC) are not FDR-significant protein sets.** ORA on these is explicitly exploratory.
6. **No fold-change cutoff was used** in either ranked or ORA analyses.
7. **Pathway theme consolidation is an interpretation layer.** The 11 themes do not represent 11 independent mechanisms; they group redundant GO-BP/Reactome terms.
8. **"Opposite direction" proteasome/cytoskeleton/redox/phosphorylation themes** reflect Low-down vs HvL-up; High-vs-Control is non-significant. This is a Low-suppression pattern, not High activation.
9. **Post-v2.1 analyses were not pre-registered** as primary endpoints; they are supportive/supplementary.
10. **No hold-out protein outcomes were accessed** in post-v2.1 environment-stratified or control-referenced pathway work.

## Amendment 2026-10-03 — environment-stratified control-referenced pathways

11. Pathway-count differences between environments (HH 328/172 vs HA 78/11) are descriptive, not formal interaction tests. Canonical M10 (0/1,430) remains authoritative for environment heterogeneity.
12. GO-BP and Reactome pathways are highly redundant; significant pathway counts are not counts of independent biological mechanisms.
13. Ranked pathway significance can occur without protein-level BH-FDR discoveries (e.g., HH LVC: 0 protein hits, 328 pathways) because cameraPR assesses coordinated shifts across many proteins.
14. cameraPR "Up"/"Down" direction reflects ranked gene-set shift and should not be equated with mechanistic activation/inhibition.
15. Environment-stratified pathway analyses are secondary/exploratory and do not replace the canonical primary High-vs-Low or M10 interaction analyses.
