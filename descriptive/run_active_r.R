# Future active-R entry point. This file is an explicit whitelist only.
# It does not discover scripts dynamically and does not clean output folders.

get_script_dir <- function() {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) == 1L) {
        return(dirname(normalizePath(sub("^--file=", "", file_arg),
                                     winslash = "/", mustWork = TRUE)))
    }
    normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

SCRIPT_DIR <- get_script_dir()
setwd(SCRIPT_DIR)

ACTIVE_R_SCRIPTS <- c(
    "05_limma_dose_analysis.R",
    "06a_limma_core_figures.R",
    "06b_limma_robustness.R",
    "06c_run_replication.R",
    "04_covariate_QC.R",
    "08_detection_pattern_analysis.R",
    "06d_integrated_results.R",
    "09_DEP_characterization.R",
    "DEP_effect_size_summary.R",
    "10_protein_clustering.R",
    "10_dose_pattern_classification.R"
)

rscript <- file.path(R.home("bin"), "Rscript")
if (.Platform$OS.type == "windows") {
    rscript <- paste0(rscript, ".exe")
}

for (script_name in ACTIVE_R_SCRIPTS) {
    script_path <- file.path(SCRIPT_DIR, script_name)
    if (!file.exists(script_path)) {
        stop("Whitelisted R script is missing: ", script_path)
    }
    message("Running ", script_name)
    status <- system2(rscript, c("--vanilla", shQuote(script_path)))
    if (!identical(status, 0L)) {
        stop("R pipeline stopped after failure in ", script_name,
             " (exit status ", status, ").")
    }
}
