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

# M14: frozen replication hierarchy
# [P21 FIX] Originally hard-coded as c(85, 85, 83, 29, 1).
#           Now dynamically derived from canonical D08 output file:
#           discovery_validation/D08_validation/D08_validation_results.csv
#派生源说明：
#   - Locked D03            = nrow(D08) [总候选数]
#   - Estimable in hold-out = sum(Model_status == "ESTIMABLE")
#   - Same direction        = sum(Direction_concordant == TRUE)
#   - Nominal P<0.05        = sum(Nominal_replication == TRUE)
#   - FDR<0.05              = sum(FDR_supported_replication == TRUE)
# 数字本身不变（预期仍为 85/85/83/29/1），仅改为动态读取。
d08_path <- file.path(root, "descriptive", "discovery_validation",
                      "D08_validation", "D08_validation_results.csv")
if (!file.exists(d08_path)) {
  stop("[P21 FIX] D08 results file not found: ", d08_path)
}
d08 <- read.csv(d08_path, stringsAsFactors = FALSE, check.names = FALSE)

n_locked_d03 <- nrow(d08)
n_estimable <- sum(d08$Model_status == "ESTIMABLE", na.rm = TRUE)
n_same_dir <- sum(d08$Direction_concordant == TRUE, na.rm = TRUE)
n_nominal <- sum(d08$Nominal_replication == TRUE, na.rm = TRUE)
n_fdr <- sum(d08$FDR_supported_replication == TRUE, na.rm = TRUE)

m14 <- data.frame(
  stage = c("Locked D03", "Estimable in hold-out",
            "Same direction", "Nominal P<0.05",
            "Candidate-family BH-FDR<0.05"),
  n = c(n_locked_d03, n_estimable, n_same_dir, n_nominal, n_fdr),
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
# [P21 FIX] Updated stale status values per module-level authoritative state:
#   - Pathway: M12 v2.1 has produced 195/23/39 but M12=BLOCKED, KEGG=NOT_RUN
#     → BLOCKED_PENDING_RERUN (not NOT_RUN_NO_APPROVED_MAPPING)
#   - ML M15: fixed-85 ML = P0_REPAIRED; strict nested = REPAIR_PENDING
#     → reflects current module-level state, not NOT_STARTED
aux <- data.frame(
  item = c("Peptide evidence", "Pathway (frozen D10)", "ML M15", "ML M16"),
  status = c("SOURCE_NOT_AVAILABLE", "BLOCKED_PENDING_RERUN",
             "fixed-85 ML=P0_REPAIRED / strict nested=REPAIR_PENDING", "NOT_AUTHORIZED")
)
write.csv(aux, file.path(out14,"M14_frozen_status.csv"), row.names=FALSE)

cat("M13/M14 read-only reconciliation tables written.\n")
cat("M13_DONE\nM14_DONE\n")
