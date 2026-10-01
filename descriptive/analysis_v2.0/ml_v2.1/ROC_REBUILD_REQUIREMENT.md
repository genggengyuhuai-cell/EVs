# ROC Rebuild Requirement

Status: REBUILD_REQUIRED_AFTER_P0_REPAIR.

Old Tier1: IGF1;GAL;GOLGA3;DMP1;TSPAN14.
New Tier1: IGF1;GAL;GOLGA3;DMP1;TSPAN14.
Numeric candidate definitions: UNCHANGED. Provenance/status labels must still be refreshed from PRE_P0_REPAIR_INVALIDATED to POST_P0_REPAIR_CURRENT.

Candidate labels depending on the old Tier1 definition: GOLGA3, TSPAN14, GAL, DMP1, and IGF1 (`Frozen_Tier1` and `Tier1_flag`). CSF1 is not Tier1-dependent.

Multigene dependencies: M3 is the direct five-gene Tier1 model; M5 contains the full Tier1 plus CSF1. M1 and M2 contain Tier1 subsets but their numeric gene sets also remain unchanged.

Overlays to rebuild or revalidate: the univariate Discovery/Validation overlay (labels/provenance) and the multigene Discovery/Validation overlay (M3/M5 provenance). Do not overwrite existing ROC files in this phase.
