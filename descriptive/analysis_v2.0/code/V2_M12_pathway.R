#!/usr/bin/env Rscript
# V2 M12 — Pathway / enrichment.
# Status: BLOCKED — no approved gene-set mapping contract for v2 Q515.
# This script writes an explicit block record; it does NOT fabricate results.

root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out_dir <- file.path(v2,"M12_pathway_enrichment")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)

block <- data.frame(
  item=c("module","status","reason","database","method","timestamp"),
  value=c("M12_pathway","BLOCKED",
    "No approved v2 gene-set mapping contract (GO BP/Reactome/KEGG) installed; protocol requires explicit mapping criterion before cameraPR/ORA. Frozen D10 status: NOT_RUN_NO_APPROVED_MAPPING. Not fabricating results.",
    "GO BP / Reactome / KEGG (pending mapping)",
    "cameraPR primary, ORA secondary (not run)",
    format(Sys.time(),"%Y-%m-%d %H:%M:%S %z")))
out_csv <- file.path(out_dir,"M12_block_record.csv")
if (file.exists(out_csv)) stop("M12 overwrite")
write.csv(block, out_csv, row.names=FALSE)
cat("M12 BLOCKED: no approved gene-set mapping contract. Read-only M13/M14 continue.\n")
