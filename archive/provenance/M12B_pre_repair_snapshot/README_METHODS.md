# M12B — Supplementary Biological Context (v2.1)

Protocol: `docs/protocol/ANALYSIS_PLAN_v2.1.md` §10 + supplementary M12B spec.
Run date: 2026-09-29.
Location: `descriptive/analysis_v2.0/M12B_biological_context_v2.1/`.

## Scope

Post-M12 supplementary layer only. Does not rerun D01–D10, does not redefine the 85 DEPs,
does not retune M15-v2.1, does not use the 129 reused hold-out.

## Components

### A. Pathway–protein bipartite network
- Input: M12 significant pathways (pooled PATH-R FDR<0.05).
- Edges: pathway–protein membership table with core/contributor flag and ML stability columns.
- Nodes: PATHWAY / PROTEIN.
- No PPI inferred from shared pathway membership.

### B. Environment concordance
- Reads `M12_env_ranked_HumidHot.csv` and `M12_env_ranked_HighAltitude.csv`.
- Classifies each pathway into:
  SHARED_SAME_DIRECTION / ONE_ENV_SIGNIFICANT_SAME_DIRECTION /
  BOTH_NONSIGNIFICANT_SAME_DIRECTION / OPPOSITE_DIRECTION / NOT_ESTIMABLE.
- No interaction claim inferred from significance differences.

### C. Protein annotation
- Localization/tissue/protein-class annotations from `canonical_protein_annotation.csv`
  plus a transparent gene-symbol heuristic.
- Heuristic is descriptive, not proof of tissue origin.
- All 85 DEPs retained even when annotation is missing.

### D. 85-DEP correlation structure
- Discovery High+Low (n=271), pairwise-complete Spearman.
- Per-protein: median/max |rho|, counts at 0.5/0.7/0.8.
- No significance filtering on 3570 pairs.
- Descriptive only; not called WGCNA modules.

### E. Integrated candidate context
- One row per 85 DEP.
- Columns: Discovery log2FC/FDR, strict-nested DEP frequency, LASSO/EN conditional and
  strict-nested stability, XGBoost rank, D08 status, GO/Reactome pathway membership,
  core-contributor flag, localization, tissue, correlation summary.
- No composite score, no final panel selection.

## Companion M12 additions

- GO MF and GO CC ranked cameraPR + ORA added (secondary).
- fgsea::fgseaMultilevel GSEA sensitivity (cameraPR primary unchanged).
- Combined GO_ALL (BP+MF+CC) + Reactome pooled BH as secondary sensitivity.

## Outputs

```
M12_pathway_v2.1/
  ranked_gsea/
    M12_fgsea_GO_BP.csv / GO_MF / GO_CC / Reactome
    M12_fgsea_combined.csv
    M12_fgsea_leading_edge.csv
    M12_cameraPR_fgsea_concordance.csv
  ranked/M12_ranked_GO_MF.csv / M12_ranked_GO_CC.csv
  ranked/M12_ranked_GO_ALL_plus_Reactome_FDR.csv
  ora/M12_ORA_GO_MF.csv / M12_ORA_GO_CC.csv
  ora/M12_ORA_GO_ALL_plus_Reactome_FDR.csv
M12B_biological_context_v2.1/
  network/   M12B_pathway_protein_edges.csv / _nodes.csv
  environment/ M12B_environment_pathway_concordance.csv / _summary.csv
  annotation/ M12B_protein_annotation.csv
  correlation/ M12B_DEP85_spearman_correlation.csv / _pairs.csv / _collinearity_summary.csv
  integration/ M12B_integrated_candidate_context.csv
  diagnostics/ M12B_run_manifest.csv / M12B_annotation_sources.csv
```

## Interpretation boundaries

- Neutral language only.
- No causal claim, no "activation" claim, no final biomarker panel.
- KEGG remains NOT_RUN (no reproducible local source).
- Annotation is heuristic and descriptive.
