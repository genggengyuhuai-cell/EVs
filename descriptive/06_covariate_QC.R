# v2.1 descriptive covariate / preanalytical QC. Does not select limma covariates.
# Figure contract: quantitative grids; raw samples + median/IQR, no significance tests.
arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(arg) != 1L) stop("Run this stage with Rscript so --file= is available.")
ROOT_DIR <- dirname(normalizePath(sub("^--file=", "", arg), winslash = "/", mustWork = TRUE))
source(file.path(ROOT_DIR, "v21_common.R"))
v21_packages(c("ggplot2", "dplyr", "tidyr", "patchwork", "ragg", "svglite"))
suppressPackageStartupMessages({library(ggplot2); library(dplyr); library(tidyr); library(patchwork)})
inputs <- file.path(ROOT_DIR, c("sample_statistics.csv", "dose_defined_metadata.csv"))
all_meta <- v21_read(inputs[1], c("UniqueSampleID", "TREAT1_clean"), "UniqueSampleID", TRUE)
defined <- v21_read(inputs[2], c("UniqueSampleID", "TREAT1_clean"), "UniqueSampleID", TRUE)
meta <- all_meta[all_meta$TREAT1_clean %in% EXPOSURE_LEVELS, , drop = FALSE]
defined <- v21_match(meta$UniqueSampleID, defined, "Exposure-defined metadata")
if (!identical(meta$TREAT1_clean, defined$TREAT1_clean)) stop("Conflicting exposure labels.")
if (!all(EXPOSURE_LEVELS %in% meta$TREAT1_clean)) stop("An exposure group has no samples.")
for (name in intersect(c("condition", "进样时间", "Tube_Mixing", "WoleBlood_oldTime", "Plasma_HoldTime_h"),
                       intersect(names(meta), names(defined)))) {
    if (!identical(meta[[name]], defined[[name]])) stop("Conflicting metadata values: ", name)
}
for (name in setdiff(names(defined), names(meta))) meta[[name]] <- defined[[name]]
meta$Exposure <- factor(meta$TREAT1_clean, levels = EXPOSURE_LEVELS, labels = unname(EXPOSURE_LABELS))
# Named aliases are explicit; region is NOT inferred from cohort/site group codes.
aliases <- list(Age = c("Age", "age", "年龄"), Sex = c("Sex", "sex", "Gender", "gender", "性别"),
                Collection_time = c("collection_time", "sampling_time", "Collection_Time", "采样时间"),
                Acquisition_date = c("进样时间", "MS_batch_proxy", "acquisition_date", "run_date"),
                Environment = c("condition", "environment"), Region = c("region", "Region", "地区"),
                Cohort_group = "group", Tube_Mixing = "Tube_Mixing",
                WoleBlood_oldTime = "WoleBlood_oldTime", Plasma_HoldTime_h = "Plasma_HoldTime_h")
fields <- vapply(names(aliases), function(name) v21_alias(meta, aliases[[name]], name), character(1))
numeric_covariates <- c("Age", "WoleBlood_oldTime", "Plasma_HoldTime_h")
absent <- function(x) is.na(x) | trimws(x) == ""
display_token <- function(x) { x <- as.character(x); x[absent(x)] <- "[Blank/absent]"; x }
finite_numeric <- function(x) { x <- suppressWarnings(as.numeric(x)); x[!is.finite(x)] <- NA_real_; x }
quant <- function(x, p) if (any(is.finite(x))) unname(quantile(x[is.finite(x)], p)) else NA_real_
completeness <- bind_rows(lapply(names(all_meta), function(name) {
    x <- all_meta[[name]]; available <- !absent(x); levels <- unique(x[available])
    num <- finite_numeric(levels)
    description <- if (length(levels) && all(is.finite(num))) paste(range(num), collapse = " to ") else
        paste(sort(levels), collapse = " | ")
    data.frame(Variable = name, N_total = length(x), N_available = sum(available),
               N_missing = sum(!available), Missing_pct = mean(!available) * 100,
               N_unique = length(levels), Levels_or_range = description)
}))
# Literal tokens are not silently folded into N_missing; expose them in their own table.
token_counts <- bind_rows(lapply(names(all_meta), function(name) {
    x <- display_token(all_meta[[name]])
    as.data.frame(table(Variable = rep(name, length(x)), Raw_token = x), stringsAsFactors = FALSE)
}))
metrics <- character()
for (name in intersect(c("detected_protein_groups", "missing_pct"), names(meta))) {
    meta[[name]] <- finite_numeric(meta[[name]])
    metrics <- c(metrics, name)
}
optional_inputs <- list(
    normalization = list(path = file.path(ROOT_DIR, "normalization_sample_diagnostics.csv"),
                         columns = c("log2_median")),
    PCA = list(path = file.path(ROOT_DIR, "complete_case_PCA_scores.csv"), columns = c("PC1", "PC2")),
    UMAP = list(path = file.path(ROOT_DIR, "limma_dose_analysis", "figures_final", "06a_core_v2.2",
                                 "Figure_A2b_UMAP_source_data.csv"), columns = c("UMAP1", "UMAP2")))
availability <- data.frame(Item = names(fields), Source_field = unname(fields),
                           Status = ifelse(is.na(fields), "absent_skipped", "available"))
for (label in names(optional_inputs)) {
    spec <- optional_inputs[[label]]
    if (!file.exists(spec$path)) {
        availability <- bind_rows(availability, data.frame(Item = label, Source_field = basename(spec$path), Status = "absent_skipped"))
        next
    }
    tab <- v21_read(spec$path, c("UniqueSampleID", spec$columns), "UniqueSampleID")
    tab <- v21_match(meta$UniqueSampleID, tab, label)
    for (name in spec$columns) { meta[[name]] <- finite_numeric(tab[[name]]); metrics <- c(metrics, name) }
    inputs <- c(inputs, spec$path)
    availability <- bind_rows(availability, data.frame(Item = label, Source_field = basename(spec$path), Status = "available"))
}
out <- v21_output(file.path(ROOT_DIR, "covariate_QC"))
FIG_DIR <- file.path(out, "figures_nature_v2.2")
v21_write(completeness, file.path(out, "metadata_completeness.csv"))
v21_write(token_counts, file.path(out, "metadata_raw_token_counts.csv"))
v21_write(availability, file.path(out, "input_availability.csv"))
v21_write(all_meta[!all_meta$TREAT1_clean %in% EXPOSURE_LEVELS, c("UniqueSampleID", "TREAT1_clean"), drop = FALSE],
          file.path(out, "excluded_exposure_samples.csv"))
v21_write(meta, file.path(out, "QC_sample_source_data.csv"))
balance <- list(); qc_summary <- list(); plot_log <- list()
for (label in names(fields)[!is.na(fields)]) {
    field <- fields[[label]]
    figure_stem <- paste0("Figure_04_covariate_QC_", v22_slug(label))
    raw <- meta[[field]]
    num <- if (label %in% numeric_covariates) finite_numeric(raw) else rep(NA_real_, length(raw))
    numeric <- label %in% numeric_covariates && any(is.finite(num))
    data <- data.frame(UniqueSampleID = meta$UniqueSampleID, Exposure = meta$Exposure,
                       Raw_value = display_token(raw), Value = num, Missing = absent(raw))
    if (numeric) {
        summary <- data %>% group_by(Exposure) %>% summarise(
            N_total = n(), N_available = sum(!Missing), N_missing = sum(Missing),
            N_numeric = sum(is.finite(Value)), N_nonnumeric_present = sum(!Missing & !is.finite(Value)),
            Median = quant(Value, 0.5), Q25 = quant(Value, 0.25), Q75 = quant(Value, 0.75), .groups = "drop")
        summary$Variable <- label; summary$Level <- "[Numeric values]"
        balance[[paste0(label, "_numeric")]] <- summary
        p <- ggplot(data[is.finite(data$Value), ], aes(Exposure, Value, colour = Exposure)) +
            geom_boxplot(width = 0.45, outlier.shape = NA, linewidth = 0.35) +
            geom_point(position = position_jitter(width = 0.12, seed = 20260922), size = 0.6, alpha = 0.45) +
            scale_colour_manual(values = setNames(EXPOSURE_COLORS, unname(EXPOSURE_LABELS))) +
            v21_theme() + theme(legend.position = "none") +
            labs(x = NULL, y = field, title = paste(label, "by exposure"),
                 subtitle = "Observed numeric samples; box = median/IQR; whiskers = 1.5 IQR")
        v21_save(p, FIG_DIR, paste0(figure_stem, "_numeric_distribution"), data, height_mm = 115)
    }
    # Raw categorical counts include zero, literal Unknown/NA/missing and blank separately.
    counts <- data %>% count(Exposure, Raw_value, name = "N") %>%
        complete(Exposure, Raw_value, fill = list(N = 0L)) %>% group_by(Exposure) %>%
        mutate(Proportion = N / sum(N)) %>% ungroup()
    counts$Variable <- label
    balance[[paste0(label, "_raw")]] <- rename(counts, Level = Raw_value)
    categories <- sort(unique(data$Raw_value))
    pages <- split(categories, ceiling(seq_along(categories) / 12L))
    for (page in seq_along(pages)) {
        count_page <- counts[counts$Raw_value %in% pages[[page]], , drop = FALSE]
        if (label == "Sex" && length(pages) == 1L) {
            p <- ggplot(count_page, aes(Exposure, Proportion, fill = Raw_value)) + geom_col(width = 0.7) +
                scale_fill_manual(values = setNames(grDevices::hcl.colors(length(categories), "Dark 3"), categories)) +
                labs(x = NULL, y = "Proportion", fill = field)
        } else {
            p <- ggplot(count_page, aes(Exposure, Raw_value, fill = N)) + geom_tile(colour = "white", linewidth = 0.25) +
                geom_text(aes(label = N), size = 2.1) + scale_fill_gradient(low = "#EEF4F7", high = "#3178A5") +
                labs(x = NULL, y = field, fill = "Samples")
        }
        p <- p + v21_theme() + labs(title = paste(label, "balance"), subtitle = "Raw tokens retained; no missing-code recoding")
        v21_save(p, FIG_DIR, paste0(figure_stem, "_raw_token_balance_", sprintf("%02d", page)), count_page, height_mm = 125)
    }
    missing_summary <- data %>% group_by(Exposure) %>% summarise(
        Missing_pct = mean(Missing) * 100, N_missing = sum(Missing), N_total = n(), .groups = "drop")
    p_missing <- ggplot(missing_summary, aes(Exposure, Missing_pct)) + geom_col(fill = "#595959", width = 0.6) +
        v21_theme() + labs(x = NULL, y = "Blank / absent (%)", title = paste(label, "missingness"),
                           subtitle = "Literal Unknown, NA, missing and 0 are counted separately in raw-token tables")
    v21_save(p_missing, FIG_DIR, paste0(figure_stem, "_blank_missingness"), missing_summary, height_mm = 110)
    if (!length(metrics)) next
    metric_data <- cbind(data, meta[metrics]) %>% pivot_longer(all_of(metrics), names_to = "Metric", values_to = "QC_value")
    if (numeric) {
        qc_summary[[label]] <- metric_data %>% group_by(Metric) %>% summarise(
            N_pairs = sum(is.finite(Value) & is.finite(QC_value)),
            Spearman_rho = {
                good <- is.finite(Value) & is.finite(QC_value)
                if (sum(good) >= 3 && length(unique(Value[good])) > 1 && length(unique(QC_value[good])) > 1)
                    cor(Value[good], QC_value[good], method = "spearman") else NA_real_
            }, .groups = "drop") %>% mutate(Variable = label, Level = "[Numeric values]")
        shown <- metric_data[is.finite(metric_data$Value) & is.finite(metric_data$QC_value), ]
        for (metric in unique(shown$Metric)) {
            one_metric <- shown[shown$Metric == metric, , drop = FALSE]
            p <- ggplot(one_metric, aes(Value, QC_value, colour = Exposure)) + geom_point(size = 1, alpha = 0.5) +
                scale_colour_manual(values = setNames(EXPOSURE_COLORS, unname(EXPOSURE_LABELS))) + v21_theme() +
                labs(x = field, y = metric, title = paste(label, "and", metric), colour = "Exposure")
            v21_save(p, FIG_DIR, paste0(figure_stem, "_QC_association_", v22_slug(metric)), one_metric, height_mm = 125)
        }
    } else {
        qc_summary[[label]] <- metric_data %>% group_by(Metric, Raw_value) %>% summarise(
            N_pairs = sum(is.finite(QC_value)), Median = quant(QC_value, 0.5),
            Q25 = quant(QC_value, 0.25), Q75 = quant(QC_value, 0.75), .groups = "drop") %>%
            mutate(Variable = label) %>% rename(Level = Raw_value)
        for (metric in metrics) for (page in seq_along(pages)) {
            shown <- metric_data[metric_data$Metric == metric & metric_data$Raw_value %in% pages[[page]] & is.finite(metric_data$QC_value), ]
            if (!nrow(shown)) next
            p <- ggplot(shown, aes(QC_value, Raw_value)) +
                geom_boxplot(outlier.shape = NA, linewidth = 0.3, orientation = "y") +
                geom_point(aes(colour = Exposure), size = 0.5, alpha = 0.4,
                           position = position_jitter(height = 0.12, width = 0, seed = 20260922)) +
                scale_colour_manual(values = setNames(EXPOSURE_COLORS, unname(EXPOSURE_LABELS))) + v21_theme() +
                labs(x = metric, y = field, title = paste(label, "and", metric),
                     subtitle = "Observed samples; median/IQR boxes; no significance tests", colour = "Exposure")
            v21_save(p, FIG_DIR, paste0(figure_stem, "_QC_distribution_", v22_slug(metric), "_", sprintf("%02d", page)), shown,
                      height_mm = max(110, 45 + 7 * length(unique(shown$Raw_value))))
        }
    }
    plot_log[[label]] <- data.frame(Variable = label, N_samples = nrow(data),
                                    N_blank = sum(data$Missing), N_numeric = sum(is.finite(data$Value)),
                                    Display = if (numeric) "numeric plus raw-token counts" else "categorical; paginated, no categories dropped")
}
v21_write(bind_rows(balance), file.path(out, "exposure_covariate_balance.csv"))
v21_write(bind_rows(qc_summary), file.path(out, "QC_metric_covariate_summary.csv"))
v21_write(bind_rows(plot_log), file.path(out, "figure_inclusion_audit.csv"))
p_complete <- ggplot(completeness, aes(Missing_pct, reorder(Variable, Missing_pct))) +
    geom_col(fill = "#3178A5", width = 0.7) +
    labs(x = "Blank / absent (%)", y = NULL, title = "Metadata completeness") + v21_theme()
v21_save(p_complete, FIG_DIR, "Figure_04_covariate_QC_metadata_completeness", completeness,
          height_mm = max(120, 35 + 6 * nrow(completeness)))
v21_provenance(out, c(inputs, file.path(ROOT_DIR, "06_covariate_QC.R")),
               c(seed = 20260922, completeness_cohort = "all audited samples", balance_cohort = "exposure-defined only",
                 missing_definition = "blank/absent only; literal tokens kept", tests = "none",
                 summary = "median/IQR; Spearman descriptive only", plotting_backend = "R; Nature figure contract"),
               c("ggplot2", "ragg", "patchwork"))
writeLines(c("# Covariate QC v2.1", "Descriptive only; no automatic primary-model adjustment.",
             "All-sample completeness; exposure-defined balance and QC associations. No new hypothesis tests.",
             "N_missing means blank/absent only. Unknown, NA, missing and zero remain separate raw tokens.",
             "Numeric plots exclude nonnumeric tokens, with counts exported; zero remains numeric.",
             "WoleBlood_oldTime units are not inferred. Cohort group is not relabelled as region.",
             "Missing optional fields/coordinates are recorded in input_availability.csv and skipped.",
             "UMAP coordinates are exploratory. Correlation is not evidence of confounding or causation.",
             "PDF/PNG and source data share names; inspect final-size figures after an authorized run."),
           file.path(out, "README_METHODS.md"))
