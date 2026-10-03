# PATHWAY_FAMILY_AUDIT — README

Audit date: 2026-10-01. Static read-only audit; no statistics were recomputed.

## Purpose

Maps each pathway method (cameraPR / ORA / fgsea) × each database family
(GO BP / GO MF / GO CC / Reactome / KEGG) to: whether it was actually run,
which script produced it, how many gene sets were tested, how many survived
FDR < 0.05 under which FDR column, and where it appears in figures/supplement.

## Key findings

1. **cameraPR primary branch (M12_02_ranked_ora.R) runs only GO BP + Reactome.**
   GO MF and GO CC cameraPR were added later by M12B_all.R as secondary
   analyses. The canonical 195 = 25 GO-BP + 170 Reactome is supported by
   `ranked/M12_ranked_combined_FDR.csv` (which contains only GO_BP=274 +
   Reactome=487 rows; no MF/CC).

2. **ORA primary branch (M12_02_ranked_ora.R) runs only GO BP + Reactome.**
   The canonical 23 = 3 GO-BP + 20 Reactome is supported by
   `ora/M12_ORA_combined_FDR.csv` (which contains only GO_BP=154 +
   Reactome=178 rows). GO MF/CC ORA are secondary M12B outputs.

3. **fgsea has two FDR columns coexisting in `M12_fgsea_combined.csv`:**
   - `padj` = per-family BH from `fgseaMultilevel` (default):
     GO BP=3, GO MF=8, GO CC=11, Reactome=17 (total=39)
   - `padj_pooled` = cross-family BH computed by M12B_all.R line 204:
     GO BP=5, GO MF=6, GO CC=11, Reactome=17 (total=39)
   Total is 39 either way; only BP/MF split differs.
   - Fig6b (scatter) uses `padj` (per-family) per V2_M17_figures_v2.R line 289.
   - PROJECT_CONTEXT §6, STATISTICAL_CLAIM_MAP C22, STATISTICAL_REPORTING_AUDIT
     use the 3/8/11/17 split (per-family padj).
   - M12_FINALIZATION_REPORT §6 uses the 5/6/11/17 split (padj_pooled).
   - **FGSEA_FROZEN_FAMILY = HOLD_UNTIL_M12_REPAIR_AND_RERUN.** This audit does
     not decide which column is canonical; it only traces provenance.

4. **KEGG = NOT_RUN** across all three methods (resource gap, not a scientific
   exclusion). Placeholder CSVs record provenance.

5. **Module-level trust status:**
   - M12 = BLOCKED_PENDING_RERUN (per global freeze-readiness directive)
   - M12B = BLOCKED_BY_M12
   - All existing counts are PRE_REPAIR_EXISTING_OUTPUT, not FINAL_FROZEN.
   - Historical 195/23/39 numbers are pre-repair existing output.

## Freeze readiness

FREEZE_READINESS = BLOCKED
SUBMISSION_READINESS = BLOCKED
ANALYSIS_REOPEN_REQUIRED = YES
SAFE_TO_TAG_ANALYSIS_V2_1 = NO
