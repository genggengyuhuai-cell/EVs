# M11 Site Leave-one-out Repair Report

Status: `PHASE4_M11_REPAIR_PASS` / `POST_PHASE4_REPAIR_CURRENT`.

## Contract

M11 is a full-515, fixed-Q515 sensitivity analysis referenced to the frozen M05 overall-exposure effect E. Each fit removes one Site while retaining `~0+Group+Environment`, the full-cohort E weights, observed-value limma, `contrastAsCoef`, `eBayes(trend=TRUE, robust=TRUE)`, and the fixed Q515 family. No fallback model or eligibility reselection is used.

## Estimability

- Prespecified Site deletions: 9; participant-level design-estimable: 9; non-estimable: 0.
- Protein-Site comparisons: 12870; estimable: 12870; non-estimable: 0.
- Every deletion records remaining Group/Environment levels, sample counts, design rank, and failure reason.

## Effect sensitivity

- Pearson correlation range: 0.790055-0.982702.
- Spearman correlation range: 0.756893-0.979087.
- Direction concordance range: 70.77-93.50%.
- Total sign flips across estimable protein-Site comparisons: 2073.
- Most influential deletion by median absolute effect change: FJ_QZ.
- Lowest overall concordance: GZ_TH (Pearson 0.790055; Spearman 0.756893; direction 70.77%; 418 sign flips).
- Largest single-protein absolute change: XZ_GG (0.502352).
- Primary FDR-supported proteins: 0; LOO FDR-supported range: 0-107.

No binary stability threshold was prespecified. Effect estimates were sensitive to exclusion of specific Sites under the primary model contract; the influential Site depends on whether influence is summarized by median shift, global concordance, or the largest single-protein shift. LOO FDR changes are descriptive sensitivity diagnostics, not new discoveries.

## Interpretation boundary

LOO answers: how sensitive are estimated effects to exclusion of one Site under the primary analysis model contract? It does not show that a Site effect was removed, that batch confounding was eliminated, that effects transport across Sites, or that findings were replicated across Sites. Site, Environment, and acquisition era remain coupled in the observed design.

## Scope

Only M11 was rerun. D01-D03, D08, fixed-85 ML, strict nested ML, repaired M09, M12/M12B, and the M17 figure pipeline were not run or modified. Fig. 4 was not redrawn.
