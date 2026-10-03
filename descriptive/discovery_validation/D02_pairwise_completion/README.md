# D02_pairwise_completion — README

## Module
Post-v2.1 pairwise-completion extension of the frozen D02 discovery analysis.

## Purpose
Complete the frozen D02 High-vs-Low primary analysis with the Low-vs-Control, High-vs-Control,
and Exposure (Low+High)-vs-Control pairwise contrasts on the same 386/1,445 Discovery universe.
This is a **clean final extension** of the frozen D02 analysis, **not a rerun** and not a change
to the frozen High-vs-Low result.

## Status
ACTIVE_COMPLETE (post-v2.1 extension; supplementary Level-2 evidence).

## Inputs
- Frozen D02 Discovery fit / estimable set (1,445).
- No imputation; model `~ 0 + dose + environment`.

## Active Code
- `code/D02_pairwise_completion.R`

## Final Outputs (source of truth)
- `results/` — per-contrast `all_tested` tables and summaries.
- `D02_PAIRWISE_COMPLETION_REPORT.md`

## Key Results
- Low vs Control: 0 BH-FDR<0.05 (114 raw P<0.05).
- High vs Control: 0 BH-FDR<0.05 (145 raw P<0.05).
- Exposure vs Control: 0 BH-FDR<0.05.
- Frozen High-vs-Low (85) was numerically reconciled; unchanged.
- Frozen-85 trajectory (descriptive): 66/85 bidirectional, 18/85 High-only, 1/85 unclear.

## Statistical Contract
Per `docs/FINAL_STATISTICAL_AND_REPORTING_CONTRACT.md` (§4, §13) and
`docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` (claims A1–A5).

## Limitations
- Pairwise-vs-Control contrasts have 0 protein-level FDR discoveries; all control-referenced
  claims must be pathway-level or descriptive.

## Do Not Use
- Do not call the 85 "exposed-vs-control DEPs".
- Do not claim dose-response / monotonicity from pairwise patterns.
- Do not state "Low has no effect" or "High has no effect".

## Reproducibility
Code + results are deterministic; inputs are the frozen D02 Discovery universe. Git-tracked at
HEAD `8695ae6`.

## Next Step
See `docs/NEXT_STEPS.md` (manuscript presentation sync).
