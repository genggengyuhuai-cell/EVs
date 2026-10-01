#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))]))), "dv_shared.R"))

dv_require("digest")
hash <- dv_assert_candidate_hash()
stage <- "D10_integrated_biology"
outdir <- dv_stage_dir(stage)

files <- c(
  D03 = file.path(dv_stage_dir("D03_candidate_lock"), "D03_locked_candidates.csv"),
  D04 = file.path(dv_stage_dir("D04_dose_trajectory"), "D04_trajectory_classification.csv"),
  D05 = file.path(dv_stage_dir("D05_environment_specific"), "D05_candidate_environment_results.csv"),
  D06 = file.path(dv_stage_dir("D06_environment_interaction"), "D06_candidate_interaction_results.csv"),
  D07 = file.path(dv_stage_dir("D07_site_robustness"), "D07_leave_one_major_site_out.csv"),
  D08 = file.path(dv_stage_dir("D08_validation"), "D08_validation_results.csv"),
  D09_detection = file.path(dv_stage_dir("D09_missingness_detection_peptides"), "D09_missingness_detection_by_stratum.csv")
  # [P20 FIX] v2.1 protocol: unique-peptide evidence shall NOT enter new canonical outputs.
  # D09_peptide (unique_peptide_support) is HISTORICAL_ONLY and no longer propagated.
  # Historical output files are preserved on disk but excluded from D10 canonical master.
  # D09_peptide = file.path(dv_stage_dir("D09_missingness_detection_peptides"), "D09_unique_peptide_support.csv")
)
missing <- files[!file.exists(files)]
if (length(missing)) {
  dv_stop("D10 gate: missing finalized evidence table(s): ", paste(names(missing), collapse = ", "))
}

base <- dv_read_csv(files["D03"], "PG.ProteinGroups")
dv_assert_keys(base, "PG.ProteinGroups", "D03 lock")
locked_ids <- base$PG.ProteinGroups

assert_locked_universe <- function(x, label) {
  if (!"PG.ProteinGroups" %in% names(x)) dv_stop(label, ": missing PG.ProteinGroups")
  if (anyDuplicated(x$PG.ProteinGroups)) dv_stop(label, ": duplicate PG.ProteinGroups")
  if (nrow(x) != length(locked_ids) || !setequal(x$PG.ProteinGroups, locked_ids)) {
    dv_stop(label, ": candidate universe differs from D03 locked candidates")
  }
  invisible(TRUE)
}

add_locked_summary <- function(master, summary, label) {
  assert_locked_universe(summary, label)
  add_cols <- setdiff(names(summary), "PG.ProteinGroups")
  duplicated_names <- intersect(add_cols, names(master))
  if (length(duplicated_names)) {
    dv_stop(label, ": duplicate output column name(s): ", paste(duplicated_names, collapse = ", "))
  }
  idx <- match(master$PG.ProteinGroups, summary$PG.ProteinGroups)
  if (anyNA(idx)) dv_stop(label, ": failed to match all locked candidates")
  cbind(master, summary[idx, add_cols, drop = FALSE])
}

safe_token <- function(x) gsub("[^A-Za-z0-9]+", "_", x)

# D04: one trajectory classification per locked candidate.
d04 <- dv_read_csv(files["D04"], "PG.ProteinGroups")
dv_assert_keys(d04, "PG.ProteinGroups", "D04 trajectory")
d04 <- d04[, intersect(c("PG.ProteinGroups", "Trajectory"), names(d04)), drop = FALSE]
if (!"Trajectory" %in% names(d04)) dv_stop("D04 trajectory: missing Trajectory")
assert_locked_universe(d04, "D04 trajectory summary")

# D05: retain only the prespecified Long_vs_Short environment-specific evidence;
# reshape environment rows to one row per locked candidate without creating a new support flag.
d05 <- dv_read_csv(files["D05"], "PG.ProteinGroups")
required_d05 <- c("PG.ProteinGroups", "Contrast", "Environment", "log2FC", "Secondary_BH_FDR")
if (!all(required_d05 %in% names(d05))) dv_stop("D05: missing required column(s)")
d05 <- d05[d05$Contrast == "Long_vs_Short", required_d05, drop = FALSE]
if (!nrow(d05)) dv_stop("D05: no Long_vs_Short rows")
environments <- unique(d05$Environment)
if (anyNA(environments) || any(environments == "")) dv_stop("D05: missing Environment label")
d05_parts <- lapply(environments, function(env) {
  z <- d05[d05$Environment == env, c("PG.ProteinGroups", "log2FC", "Secondary_BH_FDR"), drop = FALSE]
  dv_assert_keys(z, "PG.ProteinGroups", paste0("D05 Long_vs_Short / ", env))
  assert_locked_universe(z, paste0("D05 Long_vs_Short / ", env))
  token <- safe_token(env)
  names(z)[2:3] <- c(
    paste0("D05_", token, "_Long_vs_Short_log2FC"),
    paste0("D05_", token, "_Long_vs_Short_Secondary_BH_FDR")
  )
  z
})
d05_summary <- Reduce(function(a, b) merge(a, b, by = "PG.ProteinGroups", all = TRUE, sort = FALSE), d05_parts)
assert_locked_universe(d05_summary, "D05 environment-specific summary")

# D06: reshape every existing interaction contrast to one row per locked candidate.
d06 <- dv_read_csv(files["D06"], "PG.ProteinGroups")
required_d06 <- c("PG.ProteinGroups", "Contrast", "log2FC", "Secondary_BH_FDR")
if (!all(required_d06 %in% names(d06))) dv_stop("D06: missing required column(s)")
interaction_contrasts <- unique(d06$Contrast)
if (length(interaction_contrasts) != 3L) dv_stop("D06: expected exactly 3 interaction contrasts")
d06_parts <- lapply(interaction_contrasts, function(ct) {
  z <- d06[d06$Contrast == ct, c("PG.ProteinGroups", "log2FC", "Secondary_BH_FDR"), drop = FALSE]
  dv_assert_keys(z, "PG.ProteinGroups", paste0("D06 / ", ct))
  assert_locked_universe(z, paste0("D06 / ", ct))
  token <- safe_token(ct)
  names(z)[2:3] <- c(
    paste0("D06_", token, "_log2FC"),
    paste0("D06_", token, "_Secondary_BH_FDR")
  )
  z
})
d06_summary <- Reduce(function(a, b) merge(a, b, by = "PG.ProteinGroups", all = TRUE, sort = FALSE), d06_parts)
assert_locked_universe(d06_summary, "D06 interaction summary")

# D07: summarize the existing leave-one-major-site-out rows only; do not invent new metrics.
d07 <- dv_read_csv(files["D07"], "PG.ProteinGroups")
required_d07 <- c("PG.ProteinGroups", "Direction_stable", "Delta_log2FC")
if (!all(required_d07 %in% names(d07))) dv_stop("D07: missing required column(s)")
if (!setequal(unique(d07$PG.ProteinGroups), locked_ids)) dv_stop("D07: candidate universe differs from D03 locked candidates")
d07_split <- split(d07, d07$PG.ProteinGroups)
d07_summary <- do.call(rbind, lapply(locked_ids, function(id) {
  z <- d07_split[[id]]
  if (is.null(z) || !nrow(z)) dv_stop("D07: missing LOO rows for ", id)
  stable <- as.character(z$Direction_stable) %in% c("TRUE", "T", "1")
  delta <- suppressWarnings(as.numeric(z$Delta_log2FC))
  data.frame(
    PG.ProteinGroups = id,
    D07_N_LOO_scenarios = nrow(z),
    D07_N_direction_stable = sum(stable),
    D07_All_direction_stable = all(stable),
    D07_Max_abs_Delta_log2FC = if (all(is.na(delta))) NA_real_ else max(abs(delta), na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}))
rownames(d07_summary) <- NULL
assert_locked_universe(d07_summary, "D07 site-robustness summary")

# D08: preserve the frozen validation fields; do not recalculate or redefine replication.
d08 <- dv_read_csv(files["D08"], "PG.ProteinGroups")
dv_assert_keys(d08, "PG.ProteinGroups", "D08 validation")
d08_fields <- c(
  "log2FC", "Candidate_family_BH_FDR", "Direction_concordant",
  "Nominal_replication", "FDR_supported_replication",
  "Effect_difference_signed", "Effect_difference_absolute"
)
if (!all(d08_fields %in% names(d08))) dv_stop("D08: missing frozen validation field(s)")
d08_summary <- d08[, c("PG.ProteinGroups", d08_fields), drop = FALSE]
names(d08_summary)[-1] <- paste0("D08_", names(d08_summary)[-1])
assert_locked_universe(d08_summary, "D08 validation summary")

# D09: summarize ONLY Dose-stratified detection across Discovery and Validation.
d09_detection <- dv_read_csv(files["D09_detection"], "PG.ProteinGroups")
required_d09 <- c("PG.ProteinGroups", "Split", "Stratifier", "Level", "Detection_rate")
if (!all(required_d09 %in% names(d09_detection))) dv_stop("D09 detection: missing required column(s)")
d09_dose <- d09_detection[d09_detection$Stratifier == "Dose", required_d09, drop = FALSE]
if (!nrow(d09_dose)) dv_stop("D09 detection: no Dose rows")
if (!setequal(unique(d09_dose$PG.ProteinGroups), locked_ids)) dv_stop("D09 Dose detection: candidate universe differs from D03 locked candidates")
d09_split <- split(d09_dose, d09_dose$PG.ProteinGroups)
d09_detection_summary <- do.call(rbind, lapply(locked_ids, function(id) {
  z <- d09_split[[id]]
  if (is.null(z) || !nrow(z)) dv_stop("D09 Dose detection: missing rows for ", id)
  rates <- suppressWarnings(as.numeric(z$Detection_rate))
  complete_rates <- length(rates) > 0L && all(is.finite(rates))
  data.frame(
    PG.ProteinGroups = id,
    D09_Min_Dose_detection_rate = if (complete_rates) min(rates) else NA_real_,
    D09_All_Dose_GE_50pct = complete_rates && all(rates >= 0.50),
    D09_All_Dose_GE_60pct = complete_rates && all(rates >= 0.60),
    D09_All_Dose_GE_70pct = complete_rates && all(rates >= 0.70),
    D09_All_Dose_GE_80pct = complete_rates && all(rates >= 0.80),
    stringsAsFactors = FALSE
  )
}))
rownames(d09_detection_summary) <- NULL
assert_locked_universe(d09_detection_summary, "D09 Dose-detection summary")

# [P20 FIX] v2.1 protocol: unique-peptide evidence (Unique_peptide_count,
# Single_unique_peptide, Peptide_support_status) shall NOT be propagated into
# new canonical outputs. The D09_peptide file and any historical output containing
# these fields are retained as HISTORICAL_ONLY on disk.
# The following block is disabled to prevent propagation into D10_integrated_candidate_evidence.csv.
#
# d09_peptide <- dv_read_csv(files["D09_peptide"], "PG.ProteinGroups")
# dv_assert_keys(d09_peptide, "PG.ProteinGroups", "D09 peptide support")
# d09_peptide_fields <- c("Unique_peptide_count", "Single_unique_peptide", "Peptide_support_status")
# if (!all(d09_peptide_fields %in% names(d09_peptide))) dv_stop("D09 peptide: missing required field(s)")
# d09_peptide_summary <- d09_peptide[, c("PG.ProteinGroups", d09_peptide_fields), drop = FALSE]
# names(d09_peptide_summary)[-1] <- paste0("D09_", names(d09_peptide_summary)[-1])
# assert_locked_universe(d09_peptide_summary, "D09 peptide summary")

# Build the 85-row supportive evidence master. No filtering, ranking, or candidate redefinition.
master <- base
master <- add_locked_summary(master, d04, "D04 trajectory")
master <- add_locked_summary(master, d05_summary, "D05 environment-specific")
master <- add_locked_summary(master, d06_summary, "D06 interaction")
master <- add_locked_summary(master, d07_summary, "D07 site robustness")
master <- add_locked_summary(master, d08_summary, "D08 validation")
master <- add_locked_summary(master, d09_detection_summary, "D09 Dose detection")
# [P20 FIX] Removed: master <- add_locked_summary(master, d09_peptide_summary, "D09 peptide")
# v2.1 protocol: unique-peptide fields are HISTORICAL_ONLY, not in new canonical outputs.
assert_locked_universe(master, "D10 integrated candidate evidence")
if (!identical(master$PG.ProteinGroups, locked_ids)) dv_stop("D10: locked candidate order changed")

# Pathway membership must be investigator-supplied before execution; no online enrichment or hidden universe.
pathmap <- file.path(DV_BASE, "D10_pathway_mapping.csv")
if (file.exists(pathmap)) {
  pm <- dv_read_csv(pathmap, c("PG.ProteinGroups", "Pathway"))
  pathway <- merge(base["PG.ProteinGroups"], pm, by = "PG.ProteinGroups", all.x = TRUE, sort = FALSE)
  inputs <- c(files, pathmap)
} else {
  pathway <- data.frame(
    PG.ProteinGroups = base$PG.ProteinGroups,
    Pathway = NA_character_,
    Status = "NOT_RUN_NO_APPROVED_MAPPING",
    stringsAsFactors = FALSE
  )
  inputs <- files
}

paths <- file.path(outdir, c(
  "D10_integrated_candidate_evidence.csv",
  "D10_pathway_membership.csv",
  "D10_manifest.csv"
))
dv_no_overwrite(paths)
dv_write(master, paths[1])
dv_write(pathway, paths[2])
dv_write(
  dv_manifest(
    stage,
    inputs,
    paths[1:2],
    list(
      candidate_hash = hash,
      interpretation = "supportive; no candidate redefinition",
      pathway_gate = "approved mapping/universe required"
    )
  ),
  paths[3]
)
