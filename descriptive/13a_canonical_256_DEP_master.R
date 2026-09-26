# STAGE 13A: canonical 256-DEP master biological characterization table.
#
# This post-freeze downstream stage integrates existing frozen outputs only.
# It does not refit a model, reclassify a pattern, recluster proteins, or
# recompute any analytical quantity. Stage 10a exclusively owns membership of
# the canonical 256-protein universe. Stage 10b is used only for existing
# effect-size flags and validation.

rm(list = ls())
gc()

get_script_dir <- function() {
    arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
    if (length(arg) != 1L) stop("Run this stage with Rscript so --file= is available.")
    dirname(normalizePath(sub("^--file=", "", arg), winslash = "/", mustWork = TRUE))
}

ROOT_DIR <- get_script_dir()
RESULT_DIR <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results", "13A_canonical_256_DEP_master"
)
MASTER_FILE <- file.path(RESULT_DIR, "Stage13A_canonical_256_DEP_master.csv")
INTEGRITY_FILE <- file.path(RESULT_DIR, "Stage13A_integrity_assertions.csv")

dir.create(RESULT_DIR, recursive = TRUE, showWarnings = FALSE)
if (!dir.exists(RESULT_DIR)) stop("Could not create Stage 13A result directory: ", RESULT_DIR)

assertions <- data.frame(
    assertion_id = character(),
    assertion = character(),
    expected = character(),
    observed = character(),
    status = character(),
    details = character(),
    stringsAsFactors = FALSE
)

record_assertion <- function(assertion_id, assertion, expected, observed,
                             passed, details = "") {
    assertions <<- rbind(
        assertions,
        data.frame(
            assertion_id = as.character(assertion_id),
            assertion = as.character(assertion),
            expected = as.character(expected),
            observed = as.character(observed),
            status = if (isTRUE(passed)) "PASS" else "FAIL",
            details = as.character(details),
            stringsAsFactors = FALSE
        )
    )
    invisible(isTRUE(passed))
}

write_integrity <- function() {
    tryCatch(
        write.csv(assertions, INTEGRITY_FILE, row.names = FALSE, na = ""),
        error = function(e) warning("Could not write integrity report: ", conditionMessage(e))
    )
}

fail_stage <- function(message) {
    write_integrity()
    stop(message, call. = FALSE)
}

read_input <- function(path, label, assertion_id) {
    exists <- file.exists(path)
    record_assertion(
        assertion_id, paste0(label, " input exists"), "file exists",
        if (exists) "file exists" else "file missing", exists,
        normalizePath(path, winslash = "/", mustWork = FALSE)
    )
    if (!exists) fail_stage(label, " input is missing: ", path)
    tryCatch(
        read.csv(path, check.names = FALSE, stringsAsFactors = FALSE),
        error = function(e) {
            record_assertion(
                paste0(assertion_id, "_READ"), paste0(label, " input is readable"),
                "read succeeds", "read failed", FALSE, conditionMessage(e)
            )
            fail_stage("Could not read ", label, ": ", conditionMessage(e))
        }
    )
}

require_columns <- function(x, required, label, assertion_id) {
    missing <- setdiff(required, names(x))
    record_assertion(
        assertion_id, paste0(label, " required columns"),
        paste(required, collapse = ", "),
        if (length(missing)) paste0("missing: ", paste(missing, collapse = ", ")) else "all present",
        length(missing) == 0L,
        if (length(missing)) paste(missing, collapse = ", ") else ""
    )
    if (length(missing)) fail_stage(label, " missing columns: ", paste(missing, collapse = ", "))
}

check_unique_keys <- function(x, label, assertion_id, expected_n = 256L) {
    keys <- x$PG.ProteinGroups
    invalid <- is.na(keys) | !nzchar(trimws(keys))
    unique_n <- length(unique(keys[!invalid]))
    duplicate_n <- sum(duplicated(keys[!invalid]))
    passed <- nrow(x) == expected_n && !any(invalid) && unique_n == expected_n && duplicate_n == 0L
    record_assertion(
        assertion_id, paste0(label, ": exactly 256 unique canonical keys"),
        "256 rows; 256 unique nonmissing PG.ProteinGroups keys; no duplicates",
        paste0(nrow(x), " rows; ", unique_n, " unique keys; ",
               sum(invalid), " invalid keys; ", duplicate_n, " duplicate rows"),
        passed
    )
    if (!passed) fail_stage(label, " does not contain exactly 256 unique valid keys.")
}

check_key_set <- function(canonical_keys, source_keys, label, assertion_id) {
    missing <- setdiff(canonical_keys, source_keys)
    extra <- setdiff(source_keys, canonical_keys)
    passed <- length(missing) == 0L && length(extra) == 0L
    details <- paste0(
        "missing canonical keys: ", if (length(missing)) paste(missing, collapse = "; ") else "none",
        " | extra keys: ", if (length(extra)) paste(extra, collapse = "; ") else "none"
    )
    record_assertion(
        assertion_id, paste0(label, ": exact canonical key-set equality"),
        "identical set of 256 Stage 10a PG.ProteinGroups keys",
        paste0(length(intersect(canonical_keys, source_keys)), " shared; ",
               length(missing), " missing; ", length(extra), " extra"),
        passed, details
    )
    if (!passed) fail_stage(label, " key set differs from the Stage 10a canonical universe.")
}

check_one_to_one <- function(x, label, assertion_id) {
    keys <- x$PG.ProteinGroups
    invalid <- is.na(keys) | !nzchar(trimws(keys))
    duplicate_keys <- unique(keys[!invalid & duplicated(keys)])
    passed <- !any(invalid) && length(duplicate_keys) == 0L
    record_assertion(
        assertion_id, paste0(label, ": one-to-one join key"),
        "one row per valid PG.ProteinGroups key",
        paste0(nrow(x), " rows; ", sum(invalid), " invalid keys; ",
               length(duplicate_keys), " duplicated keys"),
        passed,
        if (length(duplicate_keys)) paste(duplicate_keys, collapse = "; ") else ""
    )
    if (!passed) fail_stage(label, " cannot participate in a one-to-one join.")
}

stage10a_file <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results", "09_DEP_characterization",
    "High_vs_Low_DEP_all.csv"
)
stage10b_file <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results", "09_DEP_threshold_summary",
    "High_vs_Low_all_classified.csv"
)
stage11a_file <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results", "10_dose_pattern_classification_v2",
    "DEP_three_group_pattern.csv"
)
stage11b_file <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results", "10_protein_clustering",
    "DEP_cluster_membership_hclust.csv"
)
robustness_file <- file.path(
    ROOT_DIR, "missingness_robustness", "results",
    "canonical_256_sensitivity_flags.csv"
)

tryCatch({
    stage10a <- read_input(stage10a_file, "Stage 10a", "STRUCT_INPUT_10A")
    require_columns(
        stage10a,
        c("PG.ProteinGroups", "Gene_symbol", "Display_label", "Contrast", "logFC",
          "AveExpr", "t", "P.Value", "adj.P.Val", "B", "Significant_FDR_0.05", "Direction"),
        "Stage 10a", "STRUCT_COLUMNS_10A"
    )
    check_unique_keys(stage10a, "Stage 10a canonical universe", "STRUCT_CANONICAL_256")
    canonical_keys <- stage10a$PG.ProteinGroups

    stage10b_all <- read_input(stage10b_file, "Stage 10b", "STRUCT_INPUT_10B")
    require_columns(
        stage10b_all,
        c("PG.ProteinGroups", "FDR05", "FC05", "FC10", "DEP_FDR",
          "DEP_FDR_FC05", "DEP_FDR_FC10"),
        "Stage 10b", "STRUCT_COLUMNS_10B"
    )
    check_one_to_one(stage10b_all, "Stage 10b", "STRUCT_ONE_TO_ONE_10B")

    # Stage 10a keys select the Stage 10b rows. DEP_FDR never defines membership.
    stage10b <- stage10b_all[match(canonical_keys, stage10b_all$PG.ProteinGroups), , drop = FALSE]
    matched_n <- sum(!is.na(match(canonical_keys, stage10b_all$PG.ProteinGroups)))
    coverage_pass <- nrow(stage10b) == 256L && matched_n == 256L &&
        !anyNA(stage10b$PG.ProteinGroups) && identical(stage10b$PG.ProteinGroups, canonical_keys)
    record_assertion(
        "STRUCT_10B_CANONICAL_COVERAGE",
        "Stage 10b rows selected by Stage 10a keys have exact 256-key coverage",
        "256 Stage 10a keys matched exactly once and retained in Stage 10a order",
        paste0(matched_n, " of 256 keys matched; ", nrow(stage10b), " selected rows"),
        coverage_pass
    )
    if (!coverage_pass) fail_stage("Stage 10b does not cover all Stage 10a canonical keys.")
    check_key_set(canonical_keys, stage10b$PG.ProteinGroups, "Selected Stage 10b", "STRUCT_KEYSET_10B")

    dep_fdr_valid <- is.logical(stage10b$DEP_FDR) && !anyNA(stage10b$DEP_FDR) && all(stage10b$DEP_FDR)
    record_assertion(
        "STRUCT_10B_DEP_FDR_TRUE",
        "All Stage 10b rows selected by Stage 10a keys have DEP_FDR == TRUE",
        "256 TRUE; 0 FALSE; 0 missing",
        paste0(sum(stage10b$DEP_FDR %in% TRUE, na.rm = TRUE), " TRUE; ",
               sum(stage10b$DEP_FDR %in% FALSE, na.rm = TRUE), " FALSE; ",
               sum(is.na(stage10b$DEP_FDR)), " missing; storage mode ", typeof(stage10b$DEP_FDR)),
        dep_fdr_valid
    )
    if (!dep_fdr_valid) fail_stage("Selected Stage 10b rows are not uniformly DEP_FDR == TRUE.")

    stage11a <- read_input(stage11a_file, "Stage 11a", "STRUCT_INPUT_11A")
    require_columns(
        stage11a,
        c("PG.ProteinGroups", "Control", "N_observed_Control", "N_total_Control",
          "Short", "N_observed_Short", "N_total_Short", "Long", "N_observed_Long",
          "N_total_Long", "Short_minus_Control", "Long_minus_Short",
          "Long_minus_Control", "Pattern", "Pattern_version", "Tolerance_log2"),
        "Stage 11a", "STRUCT_COLUMNS_11A"
    )
    check_one_to_one(stage11a, "Stage 11a", "STRUCT_ONE_TO_ONE_11A")
    check_key_set(canonical_keys, stage11a$PG.ProteinGroups, "Stage 11a", "STRUCT_KEYSET_11A")
    valid_patterns <- c("Short_peak", "Long_suppression")
    invalid_patterns <- is.na(stage11a$Pattern) | !stage11a$Pattern %in% valid_patterns
    record_assertion(
        "STRUCT_PATTERN_VALUES",
        "Stage 11a pattern values are valid and nonmissing",
        paste(valid_patterns, collapse = ", "),
        paste(names(table(stage11a$Pattern, useNA = "ifany")),
              as.integer(table(stage11a$Pattern, useNA = "ifany")), sep = "=", collapse = "; "),
        !any(invalid_patterns),
        if (any(invalid_patterns)) paste(unique(stage11a$Pattern[invalid_patterns]), collapse = "; ") else ""
    )
    if (any(invalid_patterns)) fail_stage("Stage 11a contains invalid or missing pattern values.")

    stage11b <- read_input(stage11b_file, "Stage 11b", "STRUCT_INPUT_11B")
    require_columns(stage11b, c("PG.ProteinGroups", "Cluster"), "Stage 11b", "STRUCT_COLUMNS_11B")
    check_one_to_one(stage11b, "Stage 11b", "STRUCT_ONE_TO_ONE_11B")
    check_key_set(canonical_keys, stage11b$PG.ProteinGroups, "Stage 11b", "STRUCT_KEYSET_11B")
    cluster_numeric <- suppressWarnings(as.integer(as.character(stage11b$Cluster)))
    valid_clusters <- !anyNA(cluster_numeric) && all(cluster_numeric %in% 1:4)
    record_assertion(
        "STRUCT_CLUSTER_VALUES",
        "Stage 11b hierarchical cluster values are valid and nonmissing",
        "integer cluster values C1-C4 (stored as 1-4)",
        paste(names(table(stage11b$Cluster, useNA = "ifany")),
              as.integer(table(stage11b$Cluster, useNA = "ifany")), sep = "=", collapse = "; "),
        valid_clusters
    )
    if (!valid_clusters) fail_stage("Stage 11b contains invalid or missing cluster values.")

    robustness <- read_input(robustness_file, "Missingness robustness", "STRUCT_INPUT_ROBUSTNESS")
    robustness_columns <- c(
        "PG.ProteinGroups", "D0_logFC", "D0_FDR",
        "D1_direction_changed", "D1_abs_delta_logFC_ge_0.5", "D1_lost_FDR", "D1_Any_sensitivity_flag",
        "D2_direction_changed", "D2_abs_delta_logFC_ge_0.5", "D2_lost_FDR", "D2_Any_sensitivity_flag",
        "D3_direction_changed", "D3_abs_delta_logFC_ge_0.5", "D3_lost_FDR", "D3_Any_sensitivity_flag",
        "Any_sensitivity_flag"
    )
    require_columns(robustness, robustness_columns, "Missingness robustness", "STRUCT_COLUMNS_ROBUSTNESS")
    check_one_to_one(robustness, "Missingness robustness", "STRUCT_ONE_TO_ONE_ROBUSTNESS")
    check_key_set(canonical_keys, robustness$PG.ProteinGroups, "Missingness robustness", "STRUCT_KEYSET_ROBUSTNESS")

    # Frozen-result regression checks validate the known frozen outputs. They
    # are not definitions of pattern membership or cluster membership.
    pattern_expected <- c(Short_peak = 249L, Long_suppression = 7L)
    pattern_observed <- table(factor(stage11a$Pattern, levels = names(pattern_expected)))
    for (pattern_name in names(pattern_expected)) {
        observed <- unname(pattern_observed[pattern_name])
        passed <- identical(as.integer(observed), as.integer(pattern_expected[pattern_name]))
        record_assertion(
            paste0("REGRESSION_PATTERN_", toupper(pattern_name)),
            paste0("Frozen-result regression: Stage 11a ", pattern_name, " count"),
            pattern_expected[pattern_name], observed, passed,
            "Frozen-result regression check; not an analytical definition."
        )
        if (!passed) fail_stage("Frozen Stage 11a pattern count changed for ", pattern_name, ".")
    }

    cluster_expected <- c(`1` = 130L, `2` = 96L, `3` = 7L, `4` = 23L)
    cluster_observed <- table(factor(cluster_numeric, levels = 1:4))
    for (cluster_id in names(cluster_expected)) {
        observed <- unname(cluster_observed[cluster_id])
        passed <- identical(as.integer(observed), as.integer(cluster_expected[cluster_id]))
        record_assertion(
            paste0("REGRESSION_CLUSTER_C", cluster_id),
            paste0("Frozen-result regression: Stage 11b C", cluster_id, " count"),
            cluster_expected[cluster_id], observed, passed,
            "Frozen-result regression check; not an analytical definition."
        )
        if (!passed) fail_stage("Frozen Stage 11b cluster count changed for C", cluster_id, ".")
    }

    # Align every provider to canonical Stage 10a order after all one-to-one
    # and exact-set assertions pass.
    stage11a <- stage11a[match(canonical_keys, stage11a$PG.ProteinGroups), , drop = FALSE]
    stage11b <- stage11b[match(canonical_keys, stage11b$PG.ProteinGroups), , drop = FALSE]
    robustness <- robustness[match(canonical_keys, robustness$PG.ProteinGroups), , drop = FALSE]

    master <- stage10a[, c(
        "PG.ProteinGroups", "Gene_symbol", "Display_label", "Contrast", "logFC",
        "AveExpr", "t", "P.Value", "adj.P.Val", "B", "Significant_FDR_0.05", "Direction"
    ), drop = FALSE]
    effect_columns <- c("FDR05", "FC05", "FC10", "DEP_FDR", "DEP_FDR_FC05", "DEP_FDR_FC10")
    profile_columns <- c(
        "Control", "N_observed_Control", "N_total_Control",
        "Short", "N_observed_Short", "N_total_Short",
        "Long", "N_observed_Long", "N_total_Long",
        "Short_minus_Control", "Long_minus_Short", "Long_minus_Control",
        "Pattern", "Pattern_version", "Tolerance_log2"
    )
    master <- cbind(
        master,
        stage10b[, effect_columns, drop = FALSE],
        stage11a[, profile_columns, drop = FALSE],
        Stage11b_cluster = paste0("C", cluster_numeric[match(canonical_keys, stage11b$PG.ProteinGroups)]),
        robustness[, setdiff(robustness_columns, "PG.ProteinGroups"), drop = FALSE]
    )

    final_pass <- nrow(master) == 256L && identical(master$PG.ProteinGroups, canonical_keys) &&
        !anyDuplicated(master$PG.ProteinGroups)
    record_assertion(
        "STRUCT_FINAL_MASTER",
        "Final master preserves canonical Stage 10a membership and order",
        "256 rows; exact ordered Stage 10a keys; no duplicate keys",
        paste0(nrow(master), " rows; ordered keys identical=", identical(master$PG.ProteinGroups, canonical_keys),
               "; duplicated keys=", sum(duplicated(master$PG.ProteinGroups))),
        final_pass
    )
    if (!final_pass) fail_stage("Final Stage 13A master integrity check failed.")

    # The master is written only after every structural and frozen-result
    # regression assertion has passed. The integrity report is always written.
    write.csv(master, MASTER_FILE, row.names = FALSE, na = "")
    write_integrity()
    cat("Stage 13A completed.\n")
    cat("Master: ", MASTER_FILE, "\n", sep = "")
    cat("Integrity report: ", INTEGRITY_FILE, "\n", sep = "")
}, error = function(e) {
    if (!nrow(assertions) || tail(assertions$status, 1L) != "FAIL") {
        record_assertion(
            "STRUCT_UNHANDLED_ERROR", "Stage 13A completed without an unhandled error",
            "no unhandled error", "unhandled error", FALSE, conditionMessage(e)
        )
    }
    write_integrity()
    stop(conditionMessage(e), call. = FALSE)
})
