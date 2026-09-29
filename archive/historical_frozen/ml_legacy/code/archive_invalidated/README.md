# Invalidated Strategy B runners

These files are retained only as audit provenance. None belongs to the executable
pipeline graph.

| File | Known defect / invalidation reason |
|---|---|
| `V2_ML_RUN_STRATEGY_B.R` | Original ad hoc runner; did not implement real 3/5/10/20 panel candidates or the complete frozen artifact contract. |
| `V2_ML_RUN_STRATEGY_B_v2.R` | Post-hoc panel handling and defective prediction path; not a frozen-spec implementation. |
| `V2_ML_RUN_STRATEGY_B_v3.R` | Introduced a post-selection refit not defined by the frozen specification. |
| `V2_ML_RUN_STRATEGY_B_v4.R` | Used a post-hoc small-ridge refit not prespecified by the frozen specification. |
| `V2_ML_RUN_STRATEGY_B_v5.R` | Used native untruncated predictions instead of evaluating real capped candidates; final tuning preprocessing was fitted before its validation split; artifact hashes diverged. |

The only future runner is the sibling `../V2_ML_RUN_STRATEGY_B.R`. It remains
fail-closed until the investigator freezes the top-k coefficient-estimation rule.
