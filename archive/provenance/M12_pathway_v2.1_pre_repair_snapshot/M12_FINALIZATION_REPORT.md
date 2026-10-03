# M12 — Pathway / Enrichment Finalization Audit Report

Audit date: 2026-09-29.
Scope: `descriptive/analysis_v2.0/M12_pathway_v2.1/` (recursive).
No statistics, mapping contract, thresholds, seeds, or outputs were modified. No pathway was re-run, no new database was added, KEGG was not re-attempted.

---

## 1. Authoritative scripts

| Role | Script |
|---|---|
| Entry 1 — mapping contract | `M12_01_mapping.R` |
| Entry 2 — cameraPR (primary ranked) + ORA (complementary) | `M12_02_ranked_ora.R` |
| Entry 2b — KEGG resource attempt / final NOT_RUN provenance | `M12_02b_kegg_fix.R` |
| Entry 3 — integration (core genes, env-stratified, ML membership, redundancy, manifest) | `M12_03_integration.R` |
| Entry 4 (M12B companion; lives in M12B dir but writes M12 secondary outputs) | `../M12B_biological_context_v2.1/M12B_all.R` (writes `ranked/M12_ranked_GO_MF|CC.csv`, `ranked/M12_ranked_GO_ALL_plus_Reactome_FDR.csv`, `ora/M12_ORA_GO_MF|CC.csv`, `ora/M12_ORA_GO_ALL_plus_Reactome_FDR.csv`, `ranked_gsea/*`) |

There is no separate figure-generation script in M12; figures live under `code/V2_M17_figures_v2.R` / `figures_final_v2/` and are explicitly out of scope for this audit.

## 2. Execution order

1. `M12_01_mapping.R` → writes `mapping/M12_gene_mapping_contract.csv`, `mapping/M12_gene_mapping_summary.csv`.
2. `M12_02_ranked_ora.R` → writes `ranked/M12_ranked_GO_BP.csv`, `ranked/M12_ranked_Reactome.csv`, `ranked/M12_ranked_combined_FDR.csv`, `ranked/M12_ranked_sensitivity_cor005.csv`, `ora/M12_ORA_GO_BP.csv`, `ora/M12_ORA_Reactome.csv`, `ora/M12_ORA_combined_FDR.csv`.
3. `M12_02b_kegg_fix.R` → attempts KEGG via `clusterProfiler::download_KEGG("hsa")`; because the KEGG REST list was incomplete, writes `ranked/M12_ranked_KEGG.csv` and `ora/M12_ORA_KEGG.csv` as `KEGG_NOT_RUN` placeholders and rewrites the combined FDR files without KEGG rows.
4. `M12_03_integration.R` → writes `ranked/M12_pathway_core_genes.csv`, `environment/*`, `integration/*`, `diagnostics/*`.
5. `../M12B_biological_context_v2.1/M12B_all.R` → writes the secondary GO MF/CC cameraPR + ORA, the GO_ALL+Reactome pooled FDR files, and all `ranked_gsea/*` fgsea outputs.

No `source()` calls anywhere; each script is self-contained and reads the CSVs produced by earlier steps.

## 3. Mapping contract

- Starting universe: 1434 tested protein groups in `PRIMARY_dose_log2_expression.csv.gz`.
- Annotation source: `descriptive/canonical_protein_annotation.csv` (3817 groups).
- Deterministic rules: split `;`-delimited accessions and genes; UNAMBIGUOUS_ONE_GENE = 1414 (98.6%); MULTI_GENE_AMBIGUOUS = 15; UNMAPPED = 5. Duplicate-gene groups = 0 (tested universe already gene-unique, so no representative tie-break needed).
- Gene id type: **gene symbol** (Entrez resolved via `org.Hs.eg.db` but not used as the pathway key).
- Downstream scripts strictly filter `contract$representative_status %in% c("REPRESENTATIVE","SINGLE") & mapping_status=="UNAMBIGUOUS_ONE_GENE"` → 1414 genes used for pathway analysis.
- Mapping summary count: `retained_representative_genes=1414` (cosmetic bug resolved 2026-09-29; the summary now filters `mapping_status=="UNAMBIGUOUS_ONE_GENE"` consistently with the downstream pipeline).

## 4. cameraPR (primary ranked competitive test)

- Ranked statistic: signed moderated t from `limma::lmFit` + `eBayes`, contrast `High_vs_Low` (High=132, Low=139, n=271, controls excluded). Median-imputed per-row before fit.
- Method: `limma::cameraPR` with `use.ranks=FALSE`, `inter.gene.cor=0.01` (primary), `0.05` (sensitivity).
- Gene sets: gene-symbol level, filtered to pathway size 10–500 after intersecting with background.
- Tested pathway counts after 10–500 filter: GO BP = 274, Reactome = 487. (GO MF = 108, GO CC = 151 are secondary, added in M12B_all.R.)
- Multiple testing: BH pooled across GO BP + Reactome (KEGG absent) → `FDR_pooled` in `ranked/M12_ranked_combined_FDR.csv`.
- Direction: cameraPR `Direction` field (Up/Down) interpreted as coordinated shift of member genes' t-statistics relative to the competitive null; no "activation" claim.
- **Primary PATH-R FDR_pooled<0.05 = 195 pathways**: GO BP = 25, Reactome = 170. This is the "~195" number referenced in the project; it is the **cameraPR combined-family count**, not a sum across methods.

## 5. ORA (complementary)

- Foreground: 85 locked D03 DEP genes (after gene-symbol mapping).
- Background: 1414 mapped tested-universe genes.
- Test: one-sided Fisher exact (`alternative="greater"`), enrichment ratio + odds ratio.
- Multiplicity: BH pooled across GO BP + Reactome in `ora/M12_ORA_combined_FDR.csv`.
- **PATH-O FDR_pooled<0.05 = 23 pathways**: GO BP = 3, Reactome = 20. ORA is explicitly complementary, not the primary inference.

## 6. fgsea (sensitivity / ranked GSEA)

- Method: `fgsea::fgseaMultilevel`, `minSize=10`, `maxSize=500`, `scoreType="std"`.
- Ranked statistic: same signed moderated t as cameraPR.
- Families: GO BP (274), GO MF (108), GO CC (151), Reactome (487).
- Multiplicity: pooled BH across all four families in `ranked_gsea/M12_fgsea_combined.csv` (`padj_pooled`).
- **fgsea padj_pooled<0.05 = 39 pathways**: GO BP = 5, GO MF = 6, GO CC = 11, Reactome = 17. 130 pathways have `padj=NA` (123 Reactome + 4 GO CC + 3 GO MF + 3 GO BP) due to unbalanced sign distribution; recorded, not imputed.
- Leading edge is the formal GSEA leading edge (`ranked_gsea/M12_fgsea_leading_edge.csv`, 20,588 rows). The cameraPR "core genes" in `ranked/M12_pathway_core_genes.csv` are a separate top-quartile |t| descriptive set and are **not** called leading-edge.
- cameraPR remains primary; fgsea is sensitivity.

## 7. Pathway databases

| Database | Source | Version | Status |
|---|---|---|---|
| GO Biological Process | org.Hs.eg.db | 3.18.0 | Primary (274 after size filter) |
| GO Molecular Function | org.Hs.eg.db | 3.18.0 | Secondary (108) |
| GO Cellular Component | org.Hs.eg.db | 3.18.0 | Secondary (151) |
| Reactome | reactome.db | 1.86.2 (per manifest) | Primary (487) |
| KEGG | — | — | **NOT_RUN** (KEGG REST returned incomplete pathway list; no reproducible local source). Placeholder CSVs retained as resource-gap provenance. |

KEGG is **still NOT_RUN**. It was not re-attempted by this audit.

## 8. Final result files

- **FINAL_RESULT (manuscript-facing)**:
  - `ranked/M12_ranked_combined_FDR.csv` (PATH-R primary; 195 sig)
  - `ora/M12_ORA_combined_FDR.csv` (PATH-O complementary; 23 sig)
  - `ranked_gsea/M12_fgsea_combined.csv` (fgsea sensitivity; 39 sig)
  - `mapping/M12_gene_mapping_contract.csv`
- **SUPPORTING_RESULT**: per-family CSVs (GO BP/MF/CC, Reactome), sensitivity cor=0.05, GO_ALL+Reactome pooled secondary FDR, core genes, env-stratified ranked + concordance, ML-candidate membership, redundancy clusters, fgsea per-family + leading edge + cameraPR-fgsea concordance.
- **REPRODUCIBILITY_REQUIRED**: `diagnostics/M12_run_manifest.csv`, `M12_database_versions.csv`, `M12_mapping_diagnostics.csv`, KEGG NOT_RUN placeholders.

## 9. Reproducibility

- All active scripts use **repo-relative** paths (`descriptive/...`). No `F:\` / `C:\` / `Users\` / `Desktop` / `Downloads` / `temp` / `tmp` in any active `.R` file.
- Hard-coded absolute paths exist **only** in `00_probe.R` (F:/env/...), which is classified DEBUG_ONLY and is not being tracked.
- Packages: `limma` 3.58.1, `fgsea` 1.28.0, `org.Hs.eg.db` 3.18.0, `reactome.db` 1.86.2, `AnnotationDbi`, `GO.db`, `clusterProfiler` (KEGG attempt only). Recorded in `diagnostics/M12_run_manifest.csv`.
- Random seed: `set.seed(20260928)` in M12_02, M12_03, and M12B_all.R. cameraPR and Fisher test are deterministic given the inputs; fgsea multilevel is deterministic with default eps=0.
- No external GMT downloads in the active path. GO/Reactome come from Bioconductor annotation packages pinned to the versions above.
- No active script reads from `archive/`, desktop, Downloads, temp, or manually edited spreadsheets.

## 10. Limitations

1. The 195 / 23 / 39 figures are **method-specific** (cameraPR PATH-R / ORA PATH-O / fgsea sensitivity). They must not be summed or presented as a single "enriched pathways" count.
2. Reactome is heavily redundant; `integration/M12_pathway_redundancy_clusters.csv` (greedy Jaccard>0.5) is the dedup view. Manuscript should quote representative themes, not the raw 170 Reactome cameraPR hits.
3. Environment-stratified results (Humid-hot n=138 vs High-pressure/high-altitude n=133) are descriptive concordance only; no interaction test is performed here.
4. ~~The mapping summary CSV has a cosmetic count bug (`retained_representative_genes=0`)~~ **RESOLVED 2026-09-29**: the summary now reports 1414, matching the downstream filter. The mapping contract and the 1414 retained genes were never altered.
5. KEGG is a documented resource gap, not a scientific exclusion.
6. "Core contributing genes" from cameraPR are top-quartile |t| descriptors, not formal GSEA leading-edge.

## 11. Recommended Git files (whitelist)

Stage explicitly:
- `M12_01_mapping.R`, `M12_02_ranked_ora.R`, `M12_02b_kegg_fix.R`, `M12_03_integration.R`
- `README_METHODS.md`
- `mapping/M12_gene_mapping_contract.csv`, `mapping/M12_gene_mapping_summary.csv`
- `ranked/` (all 9 CSVs, including KEGG NOT_RUN placeholder)
- `ora/` (all 7 CSVs, including KEGG NOT_RUN placeholder)
- `ranked_gsea/` (all 7 CSVs)
- `environment/` (3 CSVs)
- `integration/` (2 CSVs)
- `diagnostics/` (3 CSVs)
- `M12_FILE_AUDIT.csv`
- `M12_FINALIZATION_REPORT.md`

## 12. Archive candidates (not staged)

- `00_probe.R`, `probe2.R`, `probe3.R` (DEBUG_ONLY; one has hard-coded F:/env paths)
- `check_anchors_fgsea.R` (read-only anchor diagnostic)
- `install_msigdbdf.R` (INSTALL_HELPER; active pipeline does not use msigdbr/msigdbdf)
- `m01.log`, `m02.log`, `m02b.log`, `m03.log`, `probe.log` (LOG_ONLY)

## 13. Blocking issues

None.

---

## Final M12 status: **PASS_WITH_LIMITATIONS**
