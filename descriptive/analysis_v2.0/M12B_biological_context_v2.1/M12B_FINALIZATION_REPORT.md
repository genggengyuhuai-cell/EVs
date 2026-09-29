# M12B — Supplementary Biological Context Finalization Audit Report

Audit date: 2026-09-29.
Scope: `descriptive/analysis_v2.0/M12B_biological_context_v2.1/` (recursive).
No statistics, mappings, or outputs were modified. No new biological claim was introduced.

---

## 1. Authoritative inputs

M12B is a post-M12 interpretation layer. It reads (read-only):
- `../M12_pathway_v2.1/mapping/M12_gene_mapping_contract.csv`
- `../M12_pathway_v2.1/ranked/M12_ranked_combined_FDR.csv` (PATH-R FDR<0.05)
- `../M12_pathway_v2.1/ranked/M12_pathway_core_genes.csv`
- `../M12_pathway_v2.1/environment/M12_env_ranked_HumidHot.csv` and `_HighAltitude.csv`
- `descriptive/PRIMARY_dose_log2_expression.csv.gz`
- `descriptive/discovery_validation_split/discovery_validation_assignment.csv`
- `descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv` (85 DEPs)
- `descriptive/discovery_validation/D08_validation/D08_replication_summary.csv`
- `descriptive/canonical_protein_annotation.csv`
- `descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv` (M15-v2.1)
- `descriptive/analysis_v2.0/ml_v2.1/strict_nested/strict_nested_feature_stability.csv`

It does **not** re-run D01–D10, does not redefine the 85 DEPs, does not retune M15, and does not use the 129 reused hold-out.

## 2. Authoritative workflow

Single entry: `M12B_all.R` (also writes the M12 secondary GO MF/CC + fgsea outputs under `../M12_pathway_v2.1/`).

Sections in order:
1. Load mapping contract + expression + meta; recompute the same limma High-vs-Low t-statistic used by M12.
2. Build GO BP/MF/CC and Reactome gene sets from `org.Hs.eg.db` / `reactome.db`.
3. cameraPR for GO MF and GO CC (cor=0.01 + 0.05); write secondary ranked + ORA GO_ALL+Reactome pooled FDR.
4. `fgsea::fgseaMultilevel` sensitivity across BP/MF/CC/Reactome; write per-family + combined + leading-edge + cameraPR-fgsea concordance.
5. **M12B-A** pathway–protein bipartite network (edges + nodes).
6. **M12B-B** environment concordance classification (SHARED_SAME_DIRECTION / ONE_ENV_SIGNIFICANT_SAME_DIRECTION / BOTH_NONSIGNIFICANT_SAME_DIRECTION / OPPOSITE_DIRECTION / NOT_ESTIMABLE).
7. **M12B-C** 85-DEP protein annotation (canonical + transparent gene-symbol heuristic).
8. **M12B-D** 85×85 Spearman correlation on Discovery High+Low (n=271); full matrix + 3570 pairs + per-protein collinearity summary.
9. **M12B-E** integrated candidate context (one row per 85 DEP).
10. Manifest.

## 3. Evidence classes (per biological theme)

M12B does not introduce new literature claims. Each output column traces to one of:

| Class | Where it appears |
|---|---|
| **DIRECT_DATA** | Discovery log2FC / BH-FDR (from D03); D08 nominal / FDR-supported replication; Spearman rho on the 85 DEPs (n=271); strict-nested DEP frequency from M15-v2.1. |
| **PATHWAY_SUPPORTED** | GO BP/MF/CC and Reactome memberships from M12 cameraPR PATH-R FDR<0.05; core-contributor flag (top-quartile |t|); fgsea leading-edge membership; environment concordance class. |
| **ANNOTATION_SUPPORTED** | Localization class (ECM / secreted / membrane / intracellular) and tissue context from `canonical_protein_annotation.csv` plus the transparent gene-symbol heuristic. Marked `annotation_confidence="heuristic_descriptive"`. |
| **INTERPRETIVE_ONLY** | Network topology (bipartite edges only; no PPI inferred from shared membership); "other/unknown" tissue fallback; no composite score, no panel selection. |

## 4. Final outputs

- **FINAL_RESULT (manuscript-facing)**:
  - `integration/M12B_integrated_candidate_context.csv` (85 rows; one per DEP)
  - `environment/M12B_environment_pathway_summary.csv` (counts per concordance class)
  - `correlation/M12B_DEP85_collinearity_summary.csv` (per-protein median/max |rho|)
- **SUPPORTING_RESULT**:
  - `network/M12B_pathway_protein_edges.csv`, `_nodes.csv`
  - `environment/M12B_environment_pathway_concordance.csv`
  - `annotation/M12B_protein_annotation.csv`
  - `correlation/M12B_DEP85_spearman_correlation.csv`, `_pairs.csv`
- **REPRODUCIBILITY_REQUIRED**:
  - `diagnostics/M12B_run_manifest.csv`, `M12B_annotation_sources.csv`
  - `README_METHODS.md`

## 5. Interpretation limits

- M12B is a **biological context / interpretation layer**, not a mechanistic validation. It supports the language "pathway enrichment", "coordinated shift", "core contributing genes", "biological context". It does **not** support "causal mechanism", "mechanistic proof", "validated mechanism", "pathway activation".
- Environment-stratified concordance is descriptive; no interaction claim is inferred from significance differences (the code explicitly records `formal_interaction_evidence = "see M10; not inferred from env stratified analysis"`).
- Annotation is heuristic and descriptive; tissue-class labels are not tissue-of-origin proof.
- Correlation block is descriptive pairwise Spearman; not called WGCNA modules.
- The integrated table has no composite score and no final panel selection.
- KEGG remains NOT_RUN.

## 6. Manuscript-safe claims

Use:
- "Discovery High vs Low", "Discovery High", "Discovery Low", "reused hold-out", "DEPs".
- "Pathway enrichment", "coordinated shift", "core contributing genes", "biological context".

Avoid (do not reintroduce):
- "High-pressure", "High-altitude", "Humid-hot" as display-layer labels (the frozen internal key `Stratum` may still appear in code; display should use the current authoritative terminology — note that the M12B env column names `_HH` / `_HA` are internal; the manuscript should refer to the two strata by their protocol names).
- "external validation", "Validation cohort", "DEG / DEGs", "85 validated proteins".

## 7. Reproducibility

- Active script uses repo-relative paths only. No hard-coded `F:\` / `C:\` / `Users\` / `Desktop` / `Downloads` / `temp` / `tmp` in `M12B_all.R`. The only absolute path in the module is inside `run.log` (console echo of `cd F:\env`).
- Seed: `set.seed(20260928)`.
- Packages recorded in `diagnostics/M12B_run_manifest.csv` (limma 3.58.1, fgsea 1.28.0, org.Hs.eg.db 3.18.0, reactome.db 1.86.2).
- No external downloads; no archive dependency; no untracked hidden input.

## 8. Recommended Git files (whitelist)

- `M12B_all.R`
- `README_METHODS.md`
- `network/M12B_pathway_protein_edges.csv`, `_nodes.csv`
- `environment/M12B_environment_pathway_concordance.csv`, `_summary.csv`
- `annotation/M12B_protein_annotation.csv`
- `correlation/M12B_DEP85_spearman_correlation.csv`, `_pairs.csv`, `_collinearity_summary.csv`
- `integration/M12B_integrated_candidate_context.csv`
- `diagnostics/M12B_run_manifest.csv`, `M12B_annotation_sources.csv`
- `M12B_FILE_AUDIT.csv`
- `M12B_FINALIZATION_REPORT.md`

## 9. Archive candidates (not staged)

- `run.log` (LOG_ONLY; console capture).

## 10. Blocking issues

None.

---

## Final M12B status: **PASS_WITH_LIMITATIONS**
