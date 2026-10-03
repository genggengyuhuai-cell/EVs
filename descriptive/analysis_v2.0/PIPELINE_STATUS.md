# V2 Pipeline Status (analysis_v2.0)

**Last updated:** 2026-10-03 (Phase 2 refresh)

> **Supersession note**: This module-local status file is a summary only. The authoritative
> current status is `docs/FINAL_BLOCKER_STATUS.md` (`OPEN_ANALYSIS = 0`) and
> `docs/FINAL_MAINLINE_MANIFEST.csv` (file-level registry). The pre-repair ML-era status
> (V2-02..V2-05 freeze states, "Primary Discovery Model NOT LOCKED", "129 Hold-out CLOSED")
> is **historical** and superseded by the repaired canonical mainline (M05–M11, M12/M12B, M14,
> ml_v2.1).

## Current module status

| Component | Status |
|---|---|
| M05 overall-exposure estimator | REPAIRED_AND_VERIFIED |
| M08 detection (Firth) | REPAIRED / Firth primary |
| M09 KNN missingness sensitivity | REPAIRED_AND_VERIFIED (r=0.974) |
| M10 corrected pure 2-df interaction | 0/1,430 BH-FDR |
| M11 site LOO | REPAIRED_AND_VERIFIED (9 sites) |
| M12 pathway v2.1 | REPAIRED_RERUN_COMPLETE (cameraPR 205 / ORA 23 / fgsea 44&41 / KEGG NOT_RUN) |
| M12B biological context | REPAIRED_RERUN_COMPLETE |
| M14 frozen replication | REBUILT |
| ml_v2.1 (fixed-85 + strict nested) | REPAIRED_AND_VERIFIED |
| figures_final_v2 | REBUILT (phase6 snapshot archived as provenance) |

## Canonical universes (R03 closed by author decision)

U0=3,817 | Q515=1,430 | Discovery-eligible=1,445 | Mapping registry=1,434 | Rankable=1,406 | ORA background=1,414

## Next Step
See `docs/NEXT_STEPS.md` (the only active future-work list).
