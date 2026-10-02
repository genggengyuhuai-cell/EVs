# Post-v2.1 Extended Analysis Freeze

**Date**: 2026-10-02
**HEAD**: `6e9c62cb5014369f9b4e64f3e442277f577624da`
**Frozen tag**: `analysis-v2.1` peeled at `6d0e004e5025bcf7d564dadaead133809a743a14`
**Mode**: Documentation freeze only. No new statistical analysis authorized.

## Scope

This freeze consolidates all post-v2.1 secondary/exploratory analyses completed after the canonical `analysis-v2.1` tag:

- **A.** Environment-stratified de novo Discovery (Phase 1)
- **B.** Environment-stratified interpretation/reconciliation (Phase 2)
- **C.** Exposure (Low+High) vs Control (Phase 3)
- **D.** Overall Discovery pairwise completion (LVC/HVC on 386/1445)
- **E.** Control-referenced pathway analysis (cameraPR + nominal ORA)
- **F.** Pathway theme consolidation (11 themes)

## Authoritative numeric results

### Overall Discovery (n=386 / 1,445)

| Contrast | Estimable | Raw P<0.05 | BH-FDR<0.05 |
|---|---|---|---|
| Low vs Control | 1,445 | 114 | **0** |
| High vs Control | 1,445 | 145 | **0** |
| High vs Low (frozen) | 1,445 | 365 | **85** |
| Exposure vs Control | 1,445 | 65 | **0** |

Frozen-85 trajectory: 66/85 bidirectional, 18/85 High-only, 1/85 unclear.

### Environment-stratified (Discovery only)

| Stratum | LVC | HVC | HvL | EC |
|---|---|---|---|---|
| Humid-heat (n=209, Q_HH=1,373) | 0 | 1 | 0 | 0 |
| High-altitude (n=177, Q_HA=1,394) | 0 | **75** | 0 | **7** |

HA Exposure-vs-Control 7: TPST2, C1R, SPARC, FSTL1, MENT, XYLT2, ST3GAL6 (all negative; all within HA HvC 75; 1/7 in frozen 85).

### Formal interaction
- M10 Group × Environment: **0/1,430 BH-FDR significant**; 0/85 frozen-85.

### Pathway (cameraPR, pooled BH GO-BP+Reactome, 1,406 mapped+estimable genes)

| Contrast | GO-BP | Reactome | Total |
|---|---|---|---|
| Low vs Control | 21 | 237 | **258** |
| High vs Control | 10 | 28 | **38** |
| High vs Low (frozen) | 29 | 176 | **205** |

Nominal-P ORA (no FC cutoff): LVC=0 enriched; HVC=12 enriched (1 GO-BP + 11 Reactome).

## Claim hierarchy

- **Level 1 (frozen primary)**: Overall HvL 85 proteins; M12 HvL 205 pathways; hold-out replication; M10 interaction; ML.
- **Level 2 (secondary/supportive)**: environment-stratified estimates; HA HvC 75; HA EC 7; Overall LVC/HVC pairwise (0 FDR); Overall EC (0 FDR).
- **Level 3 (exploratory pathway)**: LVC cameraPR 258; HVC cameraPR 38; nominal-P ORA.
- **Level 4 (descriptive interpretation)**: 11-theme consolidation; bidirectional frozen-85 trajectory; shared immune activation; state-transition model.

## Prohibited claims

- "Low has no biological effect" / "High alone causes the response"
- "85 proteins are Exposure-vs-Control DEPs" / "85 show monotonic dose response"
- "258 independent pathways altered"
- "High activates proteasome/cytoskeleton/redox" (HVC non-significant for these)
- "HA 7 are high-altitude-specific biomarkers"
- "HA significant + HH non-significant proves interaction"
- "Environment has no effect" / "Low and High are biologically opposite overall"
- "Pathway enrichment proves mechanism" / "Two-phase dose-response is proven"

## Allowed core model

> "The primary protein-level distinction was between the Low and High exposure groups rather than between either exposure group and Controls. Although no individual Low-vs-Control or High-vs-Control proteins survived BH correction in the pooled Discovery analysis, ranked pathway analysis identified coordinated biological shifts relative to Controls. Low and High shared immune, complement, and acute-phase pathway activation, while selected proteostasis, cytoskeletal, redox, signaling, and extracellular-matrix programs differed in magnitude or direction across exposure states. These patterns are compatible with pathway-level remodeling across Low and High exposure states rather than a simple monotonic exposure response."

## Outputs

```
docs/post_v2_1_extended_analysis/
  POST_V2_1_EXTENDED_ANALYSIS_FREEZE.md (this file)
  POST_V2_1_CLAIM_MAP.csv
  POST_V2_1_RESULT_MATRIX.csv
  POST_V2_1_MULTIPLICITY_FAMILIES.csv
  POST_V2_1_LIMITATIONS.md
  POST_V2_1_SOURCE_MANIFEST.csv
  POST_V2_1_MANUSCRIPT_HANDOFF.md
```

POST_V2_1_EXTENDED_FREEZE = PASS
