# M12 — Pathway / enrichment (v2.1 §10)

Protocol: `docs/protocol/ANALYSIS_PLAN_v2.1.md` §10.
Run date: 2026-09-28.
Location: `descriptive/analysis_v2.0/M12_pathway_v2.1/`.

## Scope

Primary contrast: Discovery **High vs Low** exposure (n=271, High=132, Low=139).
Control excluded. Same sign convention as D03: negative log2FC = lower in High exposure.

## Inputs (frozen, read-only)

- `descriptive/PRIMARY_dose_log2_expression.csv.gz` — 1434 proteins × 515 samples
- `descriptive/canonical_protein_annotation.csv` — 3817 protein groups with accessions/genes
- `descriptive/discovery_validation_split/discovery_validation_assignment.csv`
- `descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv` (85 DEPs)
- `descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv` (M15-v2.1, read-only)

## Gene mapping contract

- Starting universe: 1434 tested protein groups.
- Unambiguous one-gene: 1414 (98.6%).
- Multi-gene ambiguous: 15.
- Unmapped: 5.
- Duplicate-gene groups: 0 (tested universe already gene-unique).
- Representative genes used for pathway analysis: 1414.
- Tie-break: highest overall detection rate; lexical PG.ProteinGroups.

## Databases

| Database | Source | Version | Pathways tested (10-500 genes) |
|---|---|---|---|
| GO BP | org.Hs.eg.db | 3.18.0 | 274 |
| KEGG | — | NOT_RUN_NO_REPRODUCIBLE_SOURCE (KEGG REST incomplete) | 0 |
| Reactome | reactome.db | Bioconductor | 487 |

## Methods

- **Ranked statistic**: signed moderated t from `lmFit` + `eBayes` (limma), High vs Low.
- **Ranked competitive test**: `cameraPR` (limma), inter-gene correlation = 0.01 (primary), 0.05 (sensitivity).
- **ORA**: Fisher exact (one-sided greater), 85 DEPs as foreground, mapped tested universe as background.
- **Multiplicity**: BH-FDR pooled across GO BP + Reactome (KEGG absent) for each family (PATH-R ranked, PATH-O ORA).
- **Core genes**: top quartile of pathway members by |t| (cameraPR has no native leading-edge; explicitly labeled).
- **Environment stratified**: separate limma fits on Humid-hot (n=138) and High-pressure/high-altitude (n=133); direction concordance reported without inferring interaction.

## Outputs

```
mapping/
  M12_gene_mapping_contract.csv
  M12_gene_mapping_summary.csv
ranked/
  M12_ranked_GO_BP.csv
  M12_ranked_KEGG.csv  (placeholder: NOT_RUN)
  M12_ranked_Reactome.csv
  M12_ranked_combined_FDR.csv
  M12_ranked_sensitivity_cor005.csv
  M12_pathway_core_genes.csv
ora/
  M12_ORA_GO_BP.csv
  M12_ORA_KEGG.csv  (placeholder: NOT_RUN)
  M12_ORA_Reactome.csv
  M12_ORA_combined_FDR.csv
environment/
  M12_env_ranked_HumidHot.csv
  M12_env_ranked_HighAltitude.csv
  M12_env_pathway_concordance.csv
integration/
  M12_ML_candidate_pathway_membership.csv
  M12_pathway_redundancy_clusters.csv
diagnostics/
  M12_run_manifest.csv
  M12_database_versions.csv
  M12_mapping_diagnostics.csv
```

## Sensitivity: fgsea multilevel GSEA

CameraPR remains the **primary** ranked competitive test. fgsea is a **sensitivity** layer
run on the exact same gene-mapped High-vs-Low tested universe and signed moderated t statistic.

- Method: `fgsea::fgseaMultilevel`, minSize=10, maxSize=500, scoreType="std".
- Gene sets: GO BP (274), GO MF (108), GO CC (151), Reactome (487).
- KEGG: NOT_RUN (no reproducible local source).
- Outputs under `ranked_gsea/`:
  - `M12_fgsea_GO_BP.csv`, `M12_fgsea_GO_MF.csv`, `M12_fgsea_GO_CC.csv`,
    `M12_fgsea_Reactome.csv`, `M12_fgsea_combined.csv`
  - `M12_fgsea_leading_edge.csv` (20,588 gene-pathway rows, expanded)
  - `M12_cameraPR_fgsea_concordance.csv`
- 123 Reactome pathways had unbalanced sign distribution → fgsea pval=NA (recorded,
  cameraPR primary unaffected).
- The previous cameraPR "core genes" (top-quartile |t|) remain **descriptive** and are
  NOT called GSEA leading-edge. The fgsea leading-edge set is the formal GSEA leading-edge
  and is reported separately.

### Anchor 5 in fgsea leading-edge
| Gene | Leading-edge rows | padj range (best) | Notable pathways |
|---|---|---|---|
| GOLGA3 | 10 | 0.013 | Golgi apparatus, membrane |
| TSPAN14 | 11 | 1.3e-05 | plasma membrane, membrane raft |
| GAL | 14 | 3.8e-04 | extracellular region, apoptotic signaling |
| DMP1 | 15 | 1.7e-05 | ECM proteoglycans, ECM organization |
| IGF1 | 35 | 3.8e-04 | extracellular region, growth factor activity, regulation of signaling |

All five anchors appear in at least one significant fgsea leading-edge set.

## Interpretation boundaries

- Neutral language: "pathway enrichment", "coordinated shift", "core contributing genes".
- No causal claim, no "activation" claim unless direction/method supports it.
- No final biomarker panel derived here.
- KEGG is recorded as unavailable; this is a resource gap, not a scientific exclusion.
