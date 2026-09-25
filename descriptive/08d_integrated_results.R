# v2.1: read-only abundance extensions and abundance x detection integration.
# Nature-style quantitative panels; primary limma is never refitted.
arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(arg) != 1L) stop("Run this stage with Rscript so --file= is available.")
ROOT_DIR <- dirname(normalizePath(sub("^--file=", "", arg), winslash = "/", mustWork = TRUE))
source(file.path(ROOT_DIR, "v21_common.R"))
PROTEIN_ANNOTATION <- v21_annotation(ROOT_DIR)
v21_packages(c("ggplot2", "dplyr", "tidyr", "patchwork", "ggrepel", "ragg", "svglite", "limma"))
suppressPackageStartupMessages({library(ggplot2); library(dplyr); library(tidyr); library(patchwork)})
primary_dir <- file.path(ROOT_DIR, "limma_dose_analysis", "results", "01_PRIMARY")
detection_dir <- file.path(ROOT_DIR, "limma_dose_analysis", "results", "10_detection_pattern_analysis")
rate_file <- file.path(ROOT_DIR, "detection_pattern", "protein_detection_rates_by_exposure.csv")
detect_file <- file.path(detection_dir, "detection_primary_results.csv")
fit_file <- file.path(primary_dir, "PRIMARY_log2_dose_environment__fit.rds")
expr_file <- file.path(ROOT_DIR, "PRIMARY_dose_log2_expression.csv.gz")
meta_file <- file.path(ROOT_DIR, "dose_defined_metadata.csv")

rate_columns <- paste0(c("Control", "Short", "Long"), "_detection_rate")

rates <- v21_read(
    rate_file,
    c(
        "PG.ProteinGroups",
        rate_columns,
        "In_detection_analysis_universe"
    ),
    "PG.ProteinGroups"
)

# Strictly parse the Python-exported detection-universe flag.
# Upstream Python writes "True"/"False"; v21_read() imports
# this column as character in the current runtime.
# This is representation-only compatibility handling and
# does not redefine the detection-analysis universe.
universe_flag_raw <- trimws(
    as.character(rates$In_detection_analysis_universe)
)

if (
    anyNA(universe_flag_raw) ||
    !all(universe_flag_raw %in% c("True", "False"))
) {
    bad_values <- unique(
        universe_flag_raw[
            is.na(universe_flag_raw) |
                !universe_flag_raw %in% c("True", "False")
        ]
    )

    stop(
        paste0(
            "In_detection_analysis_universe must contain only ",
            "Python-exported True/False values. Invalid value(s): ",
            paste(bad_values, collapse = ", ")
        )
    )
}

rates$In_detection_analysis_universe <-
    universe_flag_raw == "True"

# Independently reconstruct the frozen scientific universe.
expected_universe <- apply(
    rates[, rate_columns, drop = FALSE],
    1,
    max
) >= 0.60

if (
    !is.logical(rates$In_detection_analysis_universe) ||
    anyNA(rates$In_detection_analysis_universe) ||
    length(rates$In_detection_analysis_universe) !=
        length(expected_universe) ||
    any(
        rates$In_detection_analysis_universe !=
            expected_universe
    )
) {
    stop(
        paste0(
            "Detection-analysis universe must equal ",
            "max(Control, Short, Long detection rate) >= 0.60."
        )
    )
}
detect <- v21_read(detect_file, c("PG.ProteinGroups", "Contrast", "FDR", "P", "logOR", "Model_status"))
v21_ids(paste(detect$PG.ProteinGroups, detect$Contrast, sep = "\r"), "Detection protein-contrast keys")
expr_df <- v21_read(expr_file, "PG.ProteinGroups", "PG.ProteinGroups")
metadata <- v21_read(meta_file, c("UniqueSampleID", "TREAT1_clean"), "UniqueSampleID", TRUE)
metadata <- v21_match(names(expr_df)[-1], metadata, "Abundance metadata")
if (anyNA(metadata$TREAT1_clean) || !all(metadata$TREAT1_clean %in% EXPOSURE_LEVELS) ||
    !all(EXPOSURE_LEVELS %in% metadata$TREAT1_clean)) stop("Invalid abundance exposure groups.")
# Check sample identity across both branches; never integrate unrelated cohorts.
detection_meta_file <- file.path(ROOT_DIR, "detection_pattern", "detection_metadata.csv")
detection_meta <- v21_read(detection_meta_file, c("UniqueSampleID", "TREAT1_clean", "condition"), "UniqueSampleID", TRUE)
detection_meta <- v21_match(metadata$UniqueSampleID, detection_meta, "Detection/abundance cohorts")
for (name in intersect(c("TREAT1_clean", "condition"), names(metadata))) {
    if (!identical(metadata[[name]], detection_meta[[name]])) stop("Cross-branch metadata conflict: ", name)
}
if (!file.exists(fit_file)) stop("Saved primary limma fit is required for moderated CIs; no P-value reconstruction.")
fit <- readRDS(fit_file)
needed <- c("coefficients", "stdev.unscaled", "s2.post", "df.total")
if (!all(needed %in% names(fit))) stop("Saved fit lacks moderated uncertainty components.")
v21_ids(rownames(fit$coefficients), "Saved fit protein IDs")
if (!all(names(CONTRAST_LABELS) %in% colnames(fit$coefficients))) stop("Saved fit contrast mismatch.")
if (
    !identical(dim(fit$coefficients), dim(fit$stdev.unscaled)) ||
    !identical(rownames(fit$coefficients), rownames(fit$stdev.unscaled)) ||
    !identical(colnames(fit$coefficients), colnames(fit$stdev.unscaled))
) {
    stop("Saved fit SE alignment mismatch.")
}
n_fit <- nrow(fit$coefficients)
if (!length(fit$s2.post) %in% c(1L, n_fit) || !length(fit$df.total) %in% c(1L, n_fit))
    stop("Unexpected moderated variance/df lengths.")
s2 <- rep(fit$s2.post, length.out = n_fit)
df_total <- rep(fit$df.total, length.out = n_fit)
expression <- as.matrix(expr_df[-1])
if (!is.numeric(expression)) stop("Abundance expression must be numeric.")
rownames(expression) <- expr_df$PG.ProteinGroups
out <- v21_output(file.path(ROOT_DIR, "limma_dose_analysis", "figures_final", "06d_integrated_v2.2"))
inputs <- c(rate_file, detect_file, fit_file, expr_file, meta_file, detection_meta_file)
audit <- list(); evidence_counts <- list()
signal_colors <- c("FDR < 0.05" = "#3178A5", "Not significant" = "#B8B8B8", "Not estimable" = "#595959")
evidence_colors <- c("Abundance-only" = "#3178A5", "Detection-only" = "#C78132", "Both" = "#7A5195",
                     "Neither" = "#B8B8B8", "Not jointly evaluable" = "#595959")
fdr_evidence <- function(x) ifelse(is.finite(x), x < 0.05, NA)
TOP_FOREST <- 12L; TOP_PROFILE <- 6L; LABEL_N <- 6L
pair_groups <- list(Low_vs_Control = c("Short", "Control"),
                    High_vs_Control = c("Long", "Control"), High_vs_Low = c("Long", "Short"))
for (contrast in names(CONTRAST_LABELS)) {
    path <- file.path(primary_dir, paste0("PRIMARY_log2_dose_environment__", contrast, ".csv"))
    abundance <- v21_read(path, c("PG.ProteinGroups", "Contrast", "logFC", "AveExpr", "adj.P.Val"), "PG.ProteinGroups")
    abundance <- v21_annotate(abundance, PROTEIN_ANNOTATION)
    if (!all(abundance$Contrast == contrast)) stop("Contrast key conflict in primary table.")
    if (!setequal(abundance$PG.ProteinGroups, rownames(fit$coefficients)) ||
        !setequal(abundance$PG.ProteinGroups, rownames(expression))) stop("Primary table/fit/expression protein-set mismatch.")
    fit_index <- match(abundance$PG.ProteinGroups, rownames(fit$coefficients))
    saved_effect <- fit$coefficients[fit_index, contrast]
    compatible <- (is.na(abundance$logFC) & is.na(saved_effect)) |
        (is.finite(abundance$logFC) & is.finite(saved_effect) & abs(abundance$logFC - saved_effect) < 1e-8)
    if (anyNA(compatible) || !all(compatible)) stop("Primary CSV differs from saved fit coefficients.")
    abundance$SE_moderated <- fit$stdev.unscaled[fit_index, contrast] * sqrt(s2[fit_index])
    abundance$DF_total <- df_total[fit_index]
    valid_ci <- is.finite(abundance$logFC) & is.finite(abundance$SE_moderated) & abundance$SE_moderated >= 0 &
        !is.na(abundance$DF_total) & abundance$DF_total > 0
    abundance$CI_low <- abundance$CI_high <- NA_real_
    margin <- qt(0.975, df = abundance$DF_total[valid_ci]) * abundance$SE_moderated[valid_ci]
    abundance$CI_low[valid_ci] <- abundance$logFC[valid_ci] - margin
    abundance$CI_high[valid_ci] <- abundance$logFC[valid_ci] + margin
    abundance$CI_status <- ifelse(valid_ci, "moderated_fit_95pct_CI", "not_estimable")
    evidence <- fdr_evidence(abundance$adj.P.Val)
    abundance$Significance <- ifelse(is.na(evidence), "Not estimable", ifelse(evidence, "FDR < 0.05", "Not significant"))
    abundance <- abundance[order(abundance$logFC, abundance$PG.ProteinGroups, na.last = TRUE), ]
    abundance$Effect_rank <- NA_integer_
    abundance$Effect_rank[is.finite(abundance$logFC)] <- seq_len(sum(is.finite(abundance$logFC)))
    title <- unname(CONTRAST_LABELS[contrast])
    figure_stem <- paste0("Figure_06d_", v22_slug(title))
    ma_data <- abundance[is.finite(abundance$AveExpr) & is.finite(abundance$logFC), ]
    p_ma <- ggplot(ma_data, aes(AveExpr, logFC, colour = Significance)) +
        geom_hline(yintercept = 0, linewidth = 0.3, colour = "#777777") + geom_point(size = 0.6, alpha = 0.65) +
        scale_colour_manual(values = signal_colors, drop = FALSE) + v21_theme() +
        labs(x = "Average log2 abundance (AveExpr)", y = "Adjusted log2 fold change", colour = NULL, title = title)
    v21_save(p_ma, out, paste0(figure_stem, "_MA_plot"), abundance, height_mm = 100)
    rank_data <- abundance[is.finite(abundance$logFC), ]
    labels <- rank_data[is.finite(rank_data$adj.P.Val) & rank_data$adj.P.Val < 0.05, ]
    labels <- head(labels[order(-abs(labels$logFC), labels$PG.ProteinGroups), ], LABEL_N)
    p_rank <- ggplot(rank_data, aes(Effect_rank, logFC, colour = Significance)) +
        geom_hline(yintercept = 0, linewidth = 0.3, colour = "#777777") + geom_point(size = 0.7, alpha = 0.7) +
        ggrepel::geom_text_repel(data = labels, aes(label = Display_label), size = 2.2,
                                 seed = 20260922, max.overlaps = Inf, show.legend = FALSE) +
        scale_colour_manual(values = signal_colors, drop = FALSE) + v21_theme() +
        labs(x = "Protein rank by adjusted log2FC", y = "Adjusted log2 fold change", colour = NULL, title = title)
    v21_save(p_rank, out, paste0(figure_stem, "_effect_rank_plot"), abundance, height_mm = 110)
    ordered <- abundance[order(abundance$adj.P.Val, abundance$PG.ProteinGroups, na.last = TRUE), ]
    selected <- head(ordered[is.finite(ordered$adj.P.Val) & ordered$CI_status != "not_estimable", ], TOP_FOREST)
    if (nrow(selected)) {
        selected$Protein_label <- factor(selected$Display_label, levels = rev(selected$Display_label))
        p_forest <- ggplot(selected, aes(logFC, Protein_label, colour = Significance)) +
            geom_vline(xintercept = 0, linewidth = 0.3, linetype = "dashed") +
            geom_segment(aes(x = CI_low, xend = CI_high, yend = Protein_label), linewidth = 0.5) + geom_point(size = 1.5) +
            scale_colour_manual(values = signal_colors, drop = FALSE) + v21_theme() +
            labs(x = "Adjusted log2FC (moderated 95% CI)", y = NULL, colour = NULL, title = title,
                 subtitle = "Top proteins ranked by primary FDR; intervals from the saved limma fit")
        v21_save(p_forest, out, paste0(figure_stem, "_forest_plot"), selected, height_mm = 125)
    }
    profile_ids <- head(ordered$PG.ProteinGroups[is.finite(ordered$adj.P.Val)], TOP_PROFILE)
    profile <- bind_rows(lapply(profile_ids, function(id) data.frame(
        Protein = id, UniqueSampleID = metadata$UniqueSampleID,
        Exposure = factor(metadata$TREAT1_clean, levels = EXPOSURE_LEVELS, labels = unname(EXPOSURE_LABELS)),
        Log2_abundance = as.numeric(expression[id, ]))))
    if (nrow(profile)) {
        means <- profile %>% group_by(Protein, Exposure) %>% summarise(
            N_total = n(), N_observed = sum(is.finite(Log2_abundance)),
            Mean = if (any(is.finite(Log2_abundance))) mean(Log2_abundance[is.finite(Log2_abundance)]) else NA_real_,
            SE = if (sum(is.finite(Log2_abundance)) > 1L)
                sd(Log2_abundance[is.finite(Log2_abundance)]) / sqrt(sum(is.finite(Log2_abundance))) else NA_real_, .groups = "drop")
        for (i in seq_along(profile_ids)) {
        id <- profile_ids[i]
        one_protein <- means[means$Protein == id, , drop = FALSE]
        p_profile <- ggplot(one_protein, aes(Exposure, Mean, group = Protein)) +
            geom_line(linewidth = 0.4, colour = "#595959", na.rm = TRUE) +
            geom_errorbar(aes(ymin = Mean - SE, ymax = Mean + SE), width = 0.12, linewidth = 0.35, na.rm = TRUE) +
            geom_point(aes(colour = Exposure), size = 2, na.rm = TRUE) +
            scale_colour_manual(values = setNames(EXPOSURE_COLORS, unname(EXPOSURE_LABELS))) + v21_theme() +
            theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "none") +
            labs(x = NULL, y = "Observed mean log2 abundance +/- SE", title = paste(title, id, sep = ": "),
                 subtitle = "Descriptive unadjusted profiles; categorical connections, not longitudinal trajectories")
        v21_save(p_profile, out, paste0(figure_stem, "_single_protein_profile_", sprintf("%02d", i), "_", v22_slug(id)),
                  one_protein, height_mm = 125)
        }
        v21_write(profile, file.path(out, paste0(figure_stem, "_single_protein_profiles_samples.csv")))
    }
    det <- detect[detect$Contrast == contrast, , drop = FALSE]
    universe_ids <- rates$PG.ProteinGroups[rates$In_detection_analysis_universe]
    if (!setequal(det$PG.ProteinGroups, universe_ids)) stop("Detection model/universe protein mismatch.")
    if (!all(abundance$PG.ProteinGroups %in% rates$PG.ProteinGroups)) stop("Abundance proteins absent from detection mother table.")
    integrated <- rates
    ai <- match(integrated$PG.ProteinGroups, abundance$PG.ProteinGroups)
    di <- match(integrated$PG.ProteinGroups, det$PG.ProteinGroups)
    integrated$Contrast <- contrast
    integrated$Abundance_log2FC <- abundance$logFC[ai]
    integrated$Abundance_FDR <- abundance$adj.P.Val[ai]
    integrated$Detection_logOR <- det$logOR[di]
    integrated$Detection_FDR <- det$FDR[di]
    integrated$Detection_model_status <- det$Model_status[di]
    integrated$Detection_analysis_status <- ifelse(
        integrated$In_detection_analysis_universe,
        integrated$Detection_model_status,
        "outside_detection_analysis_universe"
    )
    if (any(integrated$In_detection_analysis_universe & is.na(di))) {
        stop("Detection-analysis universe contains a protein without a model result.")
    }
    groups <- pair_groups[[contrast]]
    integrated$Detection_rate_difference <- integrated[[paste0(groups[1], "_detection_rate")]] -
        integrated[[paste0(groups[2], "_detection_rate")]]
    integrated$Abundance_evidence <- fdr_evidence(integrated$Abundance_FDR)
    integrated$Detection_evidence <- fdr_evidence(integrated$Detection_FDR)
    a <- integrated$Abundance_evidence; d <- integrated$Detection_evidence
    integrated$Evidence <- "Not jointly evaluable"
    evaluable <- !is.na(a) & !is.na(d)
    integrated$Evidence[evaluable] <- ifelse(a[evaluable] & d[evaluable], "Both",
        ifelse(a[evaluable], "Abundance-only", ifelse(d[evaluable], "Detection-only", "Neither")))
    integrated$Plotted_jointly <- integrated$In_detection_analysis_universe &
        is.finite(integrated$Abundance_log2FC) & is.finite(integrated$Detection_rate_difference)
    integrated$Abundance_status <- ifelse(is.na(ai), "outside_core_quantitative_set",
                                          ifelse(is.finite(integrated$Abundance_FDR), "tested", "not_estimable"))
    # All proteins remain in source. Outside-core proteins have no artificial x=0.
    shown <- integrated[integrated$Plotted_jointly, ]
    p_joint <- ggplot(shown, aes(Abundance_log2FC, Detection_rate_difference, colour = Evidence)) +
        geom_hline(yintercept = 0, linewidth = 0.3, colour = "#777777") +
        geom_vline(xintercept = 0, linewidth = 0.3, colour = "#777777") + geom_point(size = 0.8, alpha = 0.7) +
        scale_colour_manual(values = evidence_colors, drop = FALSE) + v21_theme() +
        labs(x = "Abundance: adjusted limma log2FC", y = "Detection-rate difference (unadjusted)",
             colour = "Evidence", title = title,
             subtitle = "Evidence: separate BH FDR < 0.05 in each branch; no fold-change cutoff")
    v21_save(p_joint, out, paste0(figure_stem, "_abundance_detection_evidence"), integrated, height_mm = 125)
    outside <- integrated[integrated$Abundance_status == "outside_core_quantitative_set" &
                          integrated$In_detection_analysis_universe, ]
    if (nrow(outside)) {
        outside <- outside[order(outside$Detection_rate_difference, outside$PG.ProteinGroups), ]
        outside$Rank <- seq_len(nrow(outside))
        outside$Detection_status <- ifelse(is.na(outside$Detection_evidence), "Not estimable",
                                           ifelse(outside$Detection_evidence, "FDR < 0.05", "Not significant"))
        p_outside <- ggplot(outside, aes(Rank, Detection_rate_difference, colour = Detection_status)) +
            geom_hline(yintercept = 0, linewidth = 0.3) + geom_point(size = 0.6, alpha = 0.7) +
            scale_colour_manual(values = signal_colors, drop = FALSE) + v21_theme() +
            labs(x = "Rank outside the core quantitative set", y = "Detection-rate difference", colour = NULL,
                 title = paste(title, "(outside core)"), subtitle = "Abundance evidence unavailable; these proteins are not classified as Neither")
        v21_save(p_outside, out, paste0(figure_stem, "_outside_core_detection_summary"), outside, height_mm = 105)
    }
    evidence_counts[[contrast]] <- count(integrated, Contrast, Evidence, Abundance_status,
                                         Detection_analysis_status, name = "N_proteins")
    evidence_plot_data <- count(integrated, Evidence, name = "N_proteins")
    p_counts <- ggplot(evidence_plot_data, aes(N_proteins, reorder(Evidence, N_proteins), fill = Evidence)) +
        geom_col(width = 0.65) + geom_text(aes(label = N_proteins), hjust = -0.15, size = 2.6) +
        scale_fill_manual(values = evidence_colors, guide = "none") +
        scale_x_continuous(expand = expansion(mult = c(0, 0.16))) + v21_theme() +
        labs(x = "Protein groups", y = NULL, title = paste(title, "evidence types"))
    v21_save(p_counts, out, paste0(figure_stem, "_evidence_count_summary"), evidence_plot_data, height_mm = 120)
    audit[[contrast]] <- data.frame(Contrast = contrast, N_abundance = nrow(abundance), N_MA = nrow(ma_data),
                                    N_rank = nrow(rank_data), N_forest = nrow(selected), N_profiles = length(profile_ids),
                                    N_detection_mother_table = nrow(integrated),
                                    N_detection_universe = sum(integrated$In_detection_analysis_universe),
                                    N_joint = nrow(shown), N_outside_core = nrow(outside))
    inputs <- c(inputs, path)
}
v21_write(bind_rows(audit), file.path(out, "figure_inclusion_audit.csv"))
v21_write(bind_rows(evidence_counts), file.path(out, "evidence_type_counts.csv"))
v21_provenance(out, c(inputs, file.path(ROOT_DIR, "08d_integrated_results.R")),
               c(FDR = "<0.05 separately within each branch/contrast", confidence_level = 0.95,
                 CI = "saved stdev.unscaled * sqrt(s2.post), qt(df.total); no refit",
                 profile_summary = "observed mean +/- SE; NA retained", forest_top_n = TOP_FOREST,
                 profile_top_n = TOP_PROFILE, rank_label_n = LABEL_N, seed = 20260922),
               c("ggplot2", "ggrepel", "limma", "ragg"))
writeLines(c("# Integrated results v2.1", "Existing primary contrasts and volcano plots remain unchanged.",
             "MA/rank use all finite primary estimates. Only labels and forest/profile representatives are limited.",
             "Forest: top 12 by FDR with valid moderated 95% CI; CI uses saved fit, never P values alone.",
             "Profiles: top 6 by FDR, observed sample mean +/- SE, unadjusted and descriptive; sample n exported.",
             "Joint plot x=adjusted abundance log2FC; y=unadjusted detection-rate difference.",
             "Evidence classes require BOTH models to be evaluable: branch-specific BH FDR <0.05.",
              "Detection models and BH families use the fixed universe: any exposure-group detection rate >=60%.",
              "Proteins outside that universe remain in the mother-table source and are explicitly marked as not modelled.",
             "An unavailable/non-estimable branch is Not jointly evaluable, not evidence of a null effect.",
             "Outside-core proteins remain in all-protein source and separate detection panel; never assigned x=0.",
             "Separate FDR families are not a formal joint omnibus test. No causal or biological-absence claim.",
             "Final-size PDF/PNG visual inspection remains required after an authorized run."), file.path(out, "README_METHODS.md"))
