# M09 Pre-repair Snapshot Status

Status: `HISTORICAL_INVALIDATED_BY_PROTOCOL_IMPLEMENTATION_MISMATCH`.

These files preserve the M09 outputs that existed immediately before the Phase 3 repair. The old canonical script selected protein neighbors by raw correlation, used a sample-wise unweighted median, and silently filled remaining values with a target-row median. That implementation did not match frozen `ANALYSIS_PLAN_v2.0` Module 09 and must not be used as the current protocol result.

The snapshot contains only directly affected M09 output/manifest files and the old Fig. 3c source-data rows. It is retained for old-versus-repaired comparison and audit, not interpretation.
