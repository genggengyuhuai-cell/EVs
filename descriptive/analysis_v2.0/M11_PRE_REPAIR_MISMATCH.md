# M11 Pre-repair Mismatch

Status: `PRE_REPAIR_NOT_INTERPRETABLE_AS_PURE_SITE_LOO_ROBUSTNESS`.

## Confirmed old implementation

| Component | Old implementation | Mismatch |
|---|---|---|
| Reference effect | Frozen M05 `E_full` | Reference itself was correct |
| LOO formula | `~0 + Group` | Environment adjustment was removed |
| Environment included | No | Primary M05 uses `~0 + Group + Environment` |
| Low/High weights | Recomputed after every Site deletion | Frozen M05 contrast weights should remain 186/362 and 176/362 |
| Protein universe | Fixed Q515, 1,430 proteins | No universe mismatch |
| Eligibility | Not recomputed | Correct for fixed-parent LOO |
| Contrast | Exposed-mixture-minus-Control form, but coefficients changed with each deletion | Target estimand changed through weight drift |
| Moderation | `eBayes(trend=TRUE, robust=TRUE)` | Matched M05 |
| Multiple testing | No LOO P/FDR fields were exported | FDR-status comparisons were not assessable |
| Direction summary | Compared LOO signs with the first LOO column | Did not directly require agreement with frozen M05 direction |

## Interpretation consequence

Each old LOO estimate mixed three changes: deletion of one Site, removal of Environment adjustment, and alteration of the E contrast weights. The observed shifts therefore cannot be attributed solely to Site exclusion.

The old fixed Q515 universe did not add a fourth source of variation: it was retained and eligibility was not recomputed. The invalidated interpretation concerns estimator and weighting changes, not hidden universe reselection.

All pre-repair M11 values and Fig. 4d source values must be treated as historical until replaced by the repaired primary-contract LOO results.
