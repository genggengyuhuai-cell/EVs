#!/usr/bin/env Rscript
# V2 M13/M14 — Read-only reconciliation tables.
# M13: historical 3817->1434->256 vs Discovery 3817->1445->85.
# M14: frozen D03-D10 replication hierarchy.
# Does NOT refit anything. Uses existing frozen CSVs.

root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
out13 <- file.path(v2,"M13_historical_reconciliation"); dir.create(out13,recursive=TRUE,showWarnings=FALSE)
out14 <- file.path(v2,"M14_frozen_replication"); dir.create(out14,recursive=TRUE,showWarnings=FALSE)

# M13: universe overlap summary
# Q515 = 1430; historical eligible = 1434; discovery eligible = 1445.
# Per task: shared=1426, historical-only=8, discovery-only=19.
m13 <- data.frame(
  branch = c("Historical full cohort", "Frozen Discovery split",
             "Historical eligible", "Discovery eligible",
             "Overlap shared", "Historical-only", "Discovery-only",
             "Historical DEP (frozen)", "Discovery locked (frozen)"),
  n = c(3817, 386, 1434, 1445, 1426, 8, 19, 256, 85),
  note = c("U0", "frozen split assignment", "historical 1434",
           "v2 eligible 1445", "per task spec", "per task spec",
           "per task spec", "Stage 11a frozen", "D03 frozen lock")
)
write.csv(m13, file.path(out13,"M13_universe_reconciliation.csv"), row.names=FALSE)

# M14: frozen replication hierarchy (from task spec)
m14 <- data.frame(
  stage = c("Locked D03", "Estimable in hold-out",
            "Same direction", "Nominal P<0.05",
            "Candidate-family BH-FDR<0.05"),
  n = c(85, 85, 83, 29, 1),
  status = c("FROZEN", "FROZEN", "FROZEN", "FROZEN", "FROZEN"),
  terminology_note = c(
    "reused within-cohort hold-out; NOT external validation",
    "reused within-cohort hold-out",
    "reused within-cohort hold-out",
    "reused within-cohort hold-out",
    "reused within-cohort hold-out; 1 FDR-supported protein")
)
write.csv(m14, file.path(out14,"M14_replication_hierarchy.csv"), row.names=FALSE)

# auxiliary frozen status
aux <- data.frame(
  item = c("Peptide evidence", "Pathway (frozen D10)", "ML M15", "ML M16"),
  status = c("SOURCE_NOT_AVAILABLE", "NOT_RUN_NO_APPROVED_MAPPING",
             "NOT_STARTED", "NOT_AUTHORIZED")
)
write.csv(aux, file.path(out14,"M14_frozen_status.csv"), row.names=FALSE)

cat("M13/M14 read-only reconciliation tables written.\n")
cat("M13_DONE\nM14_DONE\n")
