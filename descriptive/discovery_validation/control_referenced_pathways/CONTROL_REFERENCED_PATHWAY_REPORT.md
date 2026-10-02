# Control-Referenced Exploratory Pathway Report

> EXPLORATORY / SUPPORTIVE. Does not replace frozen M12 High-vs-Low pathway analysis.
> Discovery 386 only. No hold-out. Reuses frozen M12 mapping contract (1,414 representative genes) and gene-set construction (GO-BP via org.Hs.eg.db, Reactome via reactome.db, set size 10–500, cameraPR cor=0.01, pooled BH FDR across GO-BP + Reactome).

## Summary matrix (pooled BH-FDR<0.05)

| Analysis | Method | GO-BP | Reactome | Total |
|---|---|---|---|---|
| **Low vs Control** | cameraPR (moderated t) | **21** | **237** | **258** |
| **High vs Control** | cameraPR (moderated t) | **10** | **28** | **38** |
| Low vs Control | ORA (raw P<0.05, no FC cutoff) | 0 | 0 | 0 |
| High vs Control | ORA (raw P<0.05, no FC cutoff) | 1 | 11 | 12 |
| Frozen High vs Low (reference) | cameraPR | 29 | 176 | 205 |

## Protein inputs

| Contrast | Estimable | Raw P<0.05 | UP | DOWN | BH-FDR<0.05 |
|---|---|---|---|---|---|
| Low vs Control | 1,445 | 114 | 108 | 4 | 0 |
| High vs Control | 1,445 | 145 | 14 | 129 | 0 |

Ranked genes (mapped + estimable): 1,406 for both contrasts.

## Top pathways

### Low vs Control (cameraPR)
- proteasome-mediated ubiquitin-dependent catabolic process — **Down**
- acute-phase response — **Up**
- complement activation (classical) — **Up**
- ECM organization — **Up**
- actin/microtubule cytoskeleton organization — **Down**
- response to oxidative stress — **Down**

### High vs Control (cameraPR)
- immunoglobulin production — **Up**
- adaptive immune response — **Up**
- complement activation (classical + alternative) — **Up**
- acute-phase response — **Up**
- cell adhesion — **Down**

## Direction comparison Low vs High

- Comparable pathways: 758
- **Same direction: 576 (76%)**
- **Opposite direction: 182 (24%)**

Immune/complement/acute-phase pathways are **Up in both** Low and High vs Control — not opposite. Proteasome/cytoskeleton are Down in Low but less pronounced in High.

## Interpretation of the "opposing Low/High shifts" hypothesis

The frozen 85 High-vs-Low proteins show a bidirectional pattern at the protein level (66/85 have opposite Low and High deviations vs Control). At the pathway level:

- **Most comparable pathways (76%) move in the same direction** in Low-vs-Control and High-vs-Control. This is consistent with a shared exposure response that strengthens from Low to High (immune/complement/acute-phase Up).
- **24% show opposite directions**, enriched for proteasome/cytoskeleton/oxidative-stress modules that are Down in Low but closer to Control in High.
- The absence of protein-level BH-FDR discoveries for both Low-vs-Control and High-vs-Control, despite strong pathway-level cameraPR signals, indicates a **coordinated but distributed** signal: individual proteins do not survive 1,445-p correction, but coordinated gene-set shifts are detectable.

This is compatible with (but does not prove) a model where Low and High exposure produce overlapping immune activation plus partially opposing proteostasis/cytoskeletal changes. It does **not** by itself demonstrate formal Low-vs-High interaction; that remains M10 (0/1,430 BH-significant).

## Relation to frozen M12 High-vs-Low

- Frozen HvL: 205 pathways.
- LVC: 258 pathways; HVC: 38 pathways.
- The LVC pathway set is broader than frozen HvL despite 0 protein-level discoveries — cameraPR on the full ranked list is more sensitive than protein-level FDR for distributed coordinated signals.
- ORA on raw-P<0.05 sets (114 LVC, 145 HVC) is much weaker: 0 and 12 pathways respectively, because the nominal protein sets are small and uncoordinated enough at the individual-protein level.

## Outputs

```
descriptive/discovery_validation/control_referenced_pathways/
  code/control_referenced_pathways.R
  results/low_vs_control_cameraPR_all.csv
  results/low_vs_control_cameraPR_significant.csv
  results/high_vs_control_cameraPR_all.csv
  results/high_vs_control_cameraPR_significant.csv
  results/low_vs_control_ORA_all.csv
  results/low_vs_control_ORA_significant.csv
  results/high_vs_control_ORA_all.csv
  results/high_vs_control_ORA_significant.csv
  results/low_vs_control_ORA_directional_summary.csv
  results/high_vs_control_ORA_directional_summary.csv
  results/control_contrast_pathway_reconciliation.csv
  results/high_vs_low_pathway_comparison.csv
  results/pathway_summary_matrix.csv
  diagnostics/analysis_validation.csv
```

## Boundaries

- "258 / 38 significant pathways" = coordinated pathway-level signal, **not** protein-level DEPs.
- No FC cutoff was used; ORA foreground = raw P<0.05 only.
- KEGG = NOT_RUN (frozen contract).
- fgsea sensitivity for these contrasts = NOT_RUN (cameraPR is primary).
- Hold-out not accessed. Frozen M12 / D01 / D02 / D03 untouched.

CONTROL_REFERENCED_PATHWAYS = PASS
