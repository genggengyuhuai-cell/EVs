# Pathway Theme Consolidation Report

> Interpretation layer only. No enrichment rerun, no BH recomputation. Reads existing cameraPR outputs for LVC (258 sig), HVC (38 sig), frozen HvL (205 sig).

## Cross-contrast theme matrix

| Theme | Low vs Control | High vs Control | High vs Low | Interpretation |
|---|---|---|---|---|
| Complement / innate immune | Up (FDR 0.002) | Up (FDR 1.8e-5) | NS | Shared; strongest at High |
| Adaptive / immunoglobulin | Up (FDR 0.017) | Up (FDR 2.7e-11) | Up (FDR 0.002) | Shared; strongest at High |
| Acute-phase / inflammation | Up (FDR 3.5e-5) | Up (FDR 5.3e-5) | NS | Shared; similar magnitude |
| ECM / adhesion | Up (FDR 0.004) | Down (FDR 0.012) | Down (FDR 0.002) | Direction reversal Low→High |
| Proteasome / proteostasis | Down (FDR 5.5e-6) | NS | Up (FDR 0.002) | **Opposite**: Low suppresses, High elevates |
| Cytoskeleton (actin) | Down (FDR 0.001) | NS | Up (FDR 0.028) | **Opposite**: Low suppresses, High elevates |
| Oxidative stress / redox | Down (FDR 0.005) | NS | Up (FDR 0.013) | **Opposite**: Low suppresses, High elevates |
| Lipid / HDL metabolism | Up (FDR 0.004) | NS | NS | Low-only |
| Cell cycle (mitotic) | Down (FDR 0.010) | NS | NS | Low-only |
| Phosphorylation / signaling | Down (FDR 0.004) | NS | Up (FDR 0.015) | **Opposite**: Low suppresses, High elevates |
| Skeletal / developmental | Up (FDR 0.037) | NS | Down (FDR 0.0007) | HvL-driven directional reversal |

## 1. Shared themes (Low and High vs Control, same direction)

- **Complement / innate immune** — Up in both; stronger at High (FDR 1.8e-5 vs 0.002).
- **Adaptive / immunoglobulin response** — Up in both; dramatically stronger at High (FDR 2.7e-11).
- **Acute-phase / inflammatory response** — Up in both at similar magnitude.

These three immune/inflammatory themes represent a **shared exposure response** that strengthens from Low to High but is already present at Low.

## 2. Low-dominant themes

- **Lipid / HDL remodeling** — Up only at Low.
- **Mitotic cell cycle suppression** — Down only at Low.

## 3. High-dominant themes

- No theme is uniquely High-only vs Control; the immune themes are already present at Low but are stronger/broader at High.

## 4. High-vs-Low transition themes

- **ECM / adhesion** — Up at Low, Down at High, Down in HvL. This is a true direction reversal along the exposure gradient.
- **Skeletal / developmental** — Up at Low, Down in HvL (High not independently significant vs Control).

## 5. Truly opposite-direction themes (Low vs HvL)

Four themes show **Low vs Control in opposite direction to High vs Low**:

- **Proteasome / proteostasis**: Low Down, HvL Up
- **Cytoskeleton / actin**: Low Down, HvL Up
- **Oxidative stress / redox**: Low Down, HvL Up
- **Phosphorylation / signaling**: Low Down, HvL Up

In all four, High vs Control is **not independently significant**, meaning the HvL "Up" direction is driven primarily by Low being below Control rather than High being above it. This is consistent with a model where:

- **Low exposure** suppresses proteasome, cytoskeleton, oxidative-stress response, and phosphorylation relative to Control.
- **High exposure** returns these modules toward or slightly above Control.
- The High-vs-Low "Up" signal reflects the rebound from Low-suppressed baseline, not High activation per se.

## 6. Biological model (descriptive)

The pathway evidence supports a **two-phase exposure response** rather than a monotonic dose response:

1. **Shared inflammatory/immune activation** (complement, acute-phase, adaptive Ig) that is present at Low and strengthens at High.
2. **Low-specific suppression** of proteostasis, cytoskeletal, redox, and phosphorylation modules.
3. **High-specific ECM/adhesion reversal** (Low Up → High Down).

This is compatible with a **state transition** from Control → Low (immune activation + proteostatic/cytoskeletal suppression) → High (stronger immune activation + proteostatic rebound + ECM suppression), rather than a linear Low=weak, High=strong scaling.

This model is **pathway-level and descriptive**. It does not establish formal Low-vs-High interaction (M10: 0/1,430 BH-significant), nor does it prove dose response or mechanism.

## Outputs

```
theme_consolidation/
  PATHWAY_THEME_MASTER.csv
  PATHWAY_THEME_SUMMARY.csv
  CROSS_CONTRAST_THEME_MATRIX.csv
  PATHWAY_THEME_CONSOLIDATION_REPORT.md
```

PATHWAY_THEME_CONSOLIDATION = PASS
