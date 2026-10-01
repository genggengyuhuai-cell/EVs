# M11 Pre-repair Snapshot Status

Status: `HISTORICAL_INVALIDATED_BY_ESTIMAND_MISMATCH`.

These files preserve the M11 outputs that existed immediately before the Phase 4 repair. The old LOO implementation removed Environment adjustment, recomputed Low/High contrast weights after each Site deletion, and evaluated direction consistency across LOO columns rather than directly against frozen M05. Its results are not interpretable as pure one-Site-deletion influence under the M05 contract.

The snapshot contains only the directly affected M11 outputs/manifest and the old Fig. 4c/4d source-data rows. It is retained for audit and old-versus-repaired comparison, not current interpretation.
