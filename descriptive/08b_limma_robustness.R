# ============================================================
# 06b ROBUSTNESS FIGURES
#
# Purpose:
#   Publication-quality visualization of pre-specified
#   sensitivity analyses relative to the locked primary model.
#
# Comparisons:
#   - Median normalization
#   - MS run-date proxy covariate
#   - 50% detection threshold
#   - 80% detection threshold
#   - Complete-case proteins
#
# Does NOT change or refit the primary analysis.
# ============================================================


rm(list = ls())
gc()


# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
    "ggplot2",
    "dplyr",
    "tidyr",
    "readr",
    "patchwork",
    "scales"
)

missing_packages <- required_packages[
    !vapply(
        required_packages,
        requireNamespace,
        quietly = TRUE,
        FUN.VALUE = logical(1)
    )
]

if (length(missing_packages) > 0) {
    stop(
        paste0(
            "Missing package(s): ",
            paste(missing_packages, collapse = ", "),
            "\nInstall with:\ninstall.packages(c(",
            paste(
                paste0("'", missing_packages, "'"),
                collapse = ", "
            ),
            "))"
        )
    )
}

suppressPackageStartupMessages({
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(readr)
    library(patchwork)
    library(scales)
})


# ============================================================
# 2. Paths
# ============================================================

get_script_dir <- function() {

    args <- commandArgs(
        trailingOnly = FALSE
    )

    file_arg <- grep(
        "^--file=",
        args,
        value = TRUE
    )

    if (length(file_arg) == 1) {

        return(
            dirname(
                normalizePath(
                    sub("^--file=", "", file_arg),
                    winslash = "/",
                    mustWork = TRUE
                )
            )
        )
    }

    stop("Run this stage with Rscript so --file= is available.")
}


ROOT_DIR <- get_script_dir()
source(file.path(ROOT_DIR, "v21_common.R"))
v21_packages(c("ragg", "svglite"))

LIMMA_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis"
)

RESULT_DIR <- file.path(
    LIMMA_DIR,
    "results"
)

ROBUSTNESS_DIR <- file.path(
    LIMMA_DIR,
    "robustness"
)

FIG_DIR <- file.path(
    LIMMA_DIR,
    "figures_final",
    "06b_robustness/figures_nature_v2.2"
)

FIG_DIR <- v21_output(
    FIG_DIR
)


# ============================================================
# 3. Analysis map
# ============================================================

CONTRASTS <- c(
    "Low_vs_Control",
    "High_vs_Control",
    "High_vs_Low"
)

ANALYSIS_NAMES <- c(
    "Primary",
    "Median normalization",
    "MS run-date proxy",
    "Threshold 50%",
    "Threshold 80%",
    "Complete case"
)

ANALYSIS_SHORT <- c(
    "Primary",
    "Median norm.",
    "Run-date covariate",
    "50% filter",
    "80% filter",
    "Complete case"
)

CONTRAST_LABELS <- c(
    Low_vs_Control = "Short exposure vs Control",
    High_vs_Control = "Long exposure vs Control",
    High_vs_Low = "Long vs Short exposure"
)

CONTRAST_COLORS <- c(
    Low_vs_Control = "#C0392B",
    High_vs_Control = "#2C7A3F",
    High_vs_Low = "#2C6E9B"
)


make_file_map <- function(
    directory,
    prefix
) {

    c(
        Low_vs_Control = file.path(
            directory,
            paste0(
                prefix,
                "__Low_vs_Control.csv"
            )
        ),
        High_vs_Control = file.path(
            directory,
            paste0(
                prefix,
                "__High_vs_Control.csv"
            )
        ),
        High_vs_Low = file.path(
            directory,
            paste0(
                prefix,
                "__High_vs_Low.csv"
            )
        )
    )
}


file_maps <- list(
    Primary = make_file_map(
        file.path(
            RESULT_DIR,
            "01_PRIMARY"
        ),
        "PRIMARY_log2_dose_environment"
    ),
    `Median normalization` = make_file_map(
        file.path(
            RESULT_DIR,
            "02_SENS_median_normalization"
        ),
        "SENS_normalization_median"
    ),
    `MS run-date proxy` = make_file_map(
        file.path(
            RESULT_DIR,
            "03_SENS_MS_batch_proxy"
        ),
        "SENS_add_MS_batch_proxy"
    ),
    `Threshold 50%` = make_file_map(
        file.path(
            RESULT_DIR,
            "04_SENS_threshold_50pct"
        ),
        "SENS_detection_threshold_50pct"
    ),
    `Threshold 80%` = make_file_map(
        file.path(
            RESULT_DIR,
            "05_SENS_threshold_80pct"
        ),
        "SENS_detection_threshold_80pct"
    ),
    `Complete case` = make_file_map(
        file.path(
            RESULT_DIR,
            "06_SENS_complete_case"
        ),
        "SENS_complete_case"
    )
)


all_files <- unlist(
    file_maps,
    use.names = FALSE
)

missing_files <- all_files[
    !file.exists(
        all_files
    )
]

if (length(missing_files) > 0) {
    stop(
        paste0(
            "Missing result file(s):\n",
            paste(missing_files, collapse = "\n")
        )
    )
}


# ============================================================
# 4. Theme
# ============================================================

theme_publication <- function(base_size = 8) v21_theme(base_size)


save_plot <- function(plot_object, filename, width = 7.2, height = 4.8) {
    v21_save(plot_object, FIG_DIR, filename,
             if (is.data.frame(plot_object$data)) plot_object$data else NULL,
             width_mm = 183, height_mm = 125)
}


# ============================================================
# 5. Read all result tables
# ============================================================

read_result_set <- function(
    analysis_name
) {

    fmap <- file_maps[[analysis_name]]

    out <- lapply(
        CONTRASTS,
        function(
            contrast_name
        ) {

            dat <- read.csv(
                fmap[
                    contrast_name
                ],
                check.names = FALSE,
                stringsAsFactors = FALSE
            )

            dat$Analysis <- analysis_name
            dat$Contrast <- contrast_name

            dat
        }
    )

    names(out) <- CONTRASTS

    out
}


all_results <- lapply(
    ANALYSIS_NAMES,
    read_result_set
)

names(all_results) <- ANALYSIS_NAMES


# ============================================================
# 6. Calculate robustness metrics from source tables
# ============================================================

primary_results <- all_results$Primary

compare_one <- function(
    comparison_name,
    contrast_name
) {

    ref <- primary_results[[contrast_name]]

    cmp <- all_results[[comparison_name]][[contrast_name]]

    merged <- merge(
        ref[
            ,
            c(
                "PG.ProteinGroups",
                "logFC",
                "adj.P.Val"
            )
        ],
        cmp[
            ,
            c(
                "PG.ProteinGroups",
                "logFC",
                "adj.P.Val"
            )
        ],
        by = "PG.ProteinGroups",
        suffixes = c(
            "_primary",
            "_comparison"
        ),
        all = FALSE
    )

    valid <- is.finite(
        merged$logFC_primary
    ) & is.finite(
        merged$logFC_comparison
    )

    pearson <- cor(
        merged$logFC_primary[
            valid
        ],
        merged$logFC_comparison[
            valid
        ],
        method = "pearson"
    )

    spearman <- cor(
        merged$logFC_primary[
            valid
        ],
        merged$logFC_comparison[
            valid
        ],
        method = "spearman"
    )

    direction <- mean(
        sign(
            merged$logFC_primary[
                valid
            ]
        )
        ==
        sign(
            merged$logFC_comparison[
                valid
            ]
        )
    )

    sig_primary <- (
        !is.na(
            merged$adj.P.Val_primary
        )
        &
        merged$adj.P.Val_primary < 0.05
    )

    sig_comparison <- (
        !is.na(
            merged$adj.P.Val_comparison
        )
        &
        merged$adj.P.Val_comparison < 0.05
    )

    overlap <- sum(
        sig_primary & sig_comparison
    )

    union_n <- sum(
        sig_primary | sig_comparison
    )

    jaccard <- if (
        union_n == 0
    ) {
        NA_real_
    } else {
        overlap / union_n
    }

    data.frame(
        Comparison = comparison_name,
        Contrast = contrast_name,
        Shared_proteins = nrow(
            merged
        ),
        Pearson = pearson,
        Spearman = spearman,
        Direction = direction,
        Significant_primary = sum(
            sig_primary
        ),
        Significant_comparison = sum(
            sig_comparison
        ),
        Significant_overlap = overlap,
        Jaccard = jaccard,
        stringsAsFactors = FALSE
    )
}


comparison_names <- setdiff(
    ANALYSIS_NAMES,
    "Primary"
)

metric_rows <- list()
counter <- 1

for (comparison_name in comparison_names) {

    for (contrast_name in CONTRASTS) {

        metric_rows[[counter]] <- compare_one(
            comparison_name,
            contrast_name
        )

        counter <- counter + 1
    }
}

metrics <- bind_rows(
    metric_rows
)

metrics$Comparison <- factor(
    metrics$Comparison,
    levels = comparison_names
)

metrics$Contrast <- factor(
    metrics$Contrast,
    levels = CONTRASTS
)


write.csv(
    metrics,
    file.path(
        FIG_DIR,
        "robustness_metrics_recalculated.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 7. Significant-protein counts
# ============================================================

count_rows <- list()
counter <- 1

for (analysis_name in ANALYSIS_NAMES) {

    for (contrast_name in CONTRASTS) {

        dat <- all_results[[analysis_name]][[contrast_name]]

        count_rows[[counter]] <- data.frame(
            Analysis = analysis_name,
            Contrast = contrast_name,
            Significant = sum(
                !is.na(
                    dat$adj.P.Val
                )
                &
                dat$adj.P.Val < 0.05
            ),
            stringsAsFactors = FALSE
        )

        counter <- counter + 1
    }
}

sig_counts <- bind_rows(
    count_rows
)

sig_counts$Analysis <- factor(
    sig_counts$Analysis,
    levels = ANALYSIS_NAMES,
    labels = ANALYSIS_SHORT
)

sig_counts$Contrast <- factor(
    sig_counts$Contrast,
    levels = CONTRASTS
)


# ============================================================
# 8. Figure B1: summary dashboard
# ============================================================

p_a <- ggplot(
    sig_counts,
    aes(
        x = Analysis,
        y = Significant,
        fill = Contrast
    )
) +
    geom_col(
        position = position_dodge(
            width = 0.78
        ),
        width = 0.70
    ) +
    geom_text(
        aes(
            label = Significant
        ),
        position = position_dodge(
            width = 0.78
        ),
        vjust = -0.30,
        size = 2.55
    ) +
    scale_fill_manual(
        values = CONTRAST_COLORS,
        labels = CONTRAST_LABELS
    ) +
    labs(
        title = "FDR-significant protein counts",
        x = NULL,
        y = "Proteins with BH FDR < 0.05",
        fill = "Contrast"
    ) +
    theme_publication() +
    theme(
        axis.text.x = element_text(
            angle = 28,
            hjust = 1
        ),
        legend.position = "bottom"
    )


metric_heat <- metrics %>%
    select(
        Comparison,
        Contrast,
        Pearson,
        Jaccard
    ) %>%
    pivot_longer(
        cols = c(
            Pearson,
            Jaccard
        ),
        names_to = "Metric",
        values_to = "Value"
    )

metric_heat$Metric <- factor(
    metric_heat$Metric,
    levels = c(
        "Pearson",
        "Jaccard"
    ),
    labels = c(
        "logFC Pearson r",
        "FDR-set Jaccard"
    )
)


p_b <- ggplot(
    metric_heat,
    aes(
        x = Comparison,
        y = Contrast,
        fill = Value
    )
) +
    geom_tile(
        colour = "white",
        linewidth = 0.8
    ) +
    geom_text(
        aes(
            label = ifelse(
                is.na(
                    Value
                ),
                "NA",
                sprintf(
                    "%.2f",
                    Value
                )
            )
        ),
        size = 3
    ) +
    scale_fill_gradient(
        low = "#F4F4F4",
        high = "#2C6E9B",
        limits = c(
            0,
            1
        ),
        na.value = "#ECECEC"
    ) +
    scale_y_discrete(
        labels = CONTRAST_LABELS
    ) +
    labs(
        title = "Robustness metrics",
        x = NULL,
        y = NULL,
        fill = "Value"
    ) +
    coord_fixed(
        ratio = 0.70
    ) +
    theme_minimal(
        base_size = 9,
        base_family = "sans"
    ) +
    theme(
        panel.grid = element_blank(),
        plot.title = element_text(
            face = "bold",
            size = 10,
            hjust = 0
        ),
        strip.text = element_text(
            face = "bold"
        ),
        strip.background = element_rect(
            fill = "#F3F3F3",
            colour = "#8A8A8A",
            linewidth = 0.35
        ),
        axis.text.x = element_text(
            angle = 28,
            hjust = 1,
            colour = "black"
        ),
        axis.text.y = element_text(
            colour = "black"
        )
    )


p_c <- ggplot(
    metrics,
    aes(
        x = Comparison,
        y = Direction,
        colour = Contrast,
        group = Contrast
    )
) +
    geom_hline(
        yintercept = 1,
        linetype = "dashed",
        colour = "#9A9A9A",
        linewidth = 0.4
    ) +
    geom_line(
        linewidth = 0.75
    ) +
    geom_point(
        size = 2.2
    ) +
    scale_colour_manual(
        values = CONTRAST_COLORS,
        labels = CONTRAST_LABELS
    ) +
    scale_y_continuous(
        limits = c(
            0,
            1.01
        ),
        breaks = c(
            0.7,
            0.8,
            0.9,
            1.0
        )
    ) +
    labs(
        title = "Direction concordance",
        x = NULL,
        y = "Fraction with same logFC direction",
        colour = "Contrast"
    ) +
    theme_publication() +
    theme(
        axis.text.x = element_text(
            angle = 28,
            hjust = 1
        ),
        legend.position = "bottom"
    )


p_d <- ggplot(
    metrics,
    aes(
        x = Comparison,
        y = Pearson,
        colour = Contrast,
        group = Contrast
    )
) +
    geom_hline(
        yintercept = 1,
        linetype = "dashed",
        colour = "#9A9A9A",
        linewidth = 0.4
    ) +
    geom_line(
        linewidth = 0.75
    ) +
    geom_point(
        size = 2.2
    ) +
    scale_colour_manual(
        values = CONTRAST_COLORS,
        labels = CONTRAST_LABELS
    ) +
    scale_y_continuous(
        limits = c(
            -1,
            1.005
        ),
        breaks = c(
            0.90,
            0.95,
            1.00
        )
    ) +
    labs(
        title = "Effect-size correlation",
        x = NULL,
        y = "Pearson correlation of logFC",
        colour = "Contrast"
    ) +
    theme_publication() +
    theme(
        axis.text.x = element_text(
            angle = 28,
            hjust = 1
        ),
        legend.position = "bottom"
    )


save_plot(p_a, "Figure_06b_significant_counts")
save_plot(p_c, "Figure_06b_direction_concordance")
save_plot(p_d, "Figure_06b_effect_correlation")
for (metric in unique(as.character(metric_heat$Metric))) {
    shown <- metric_heat[as.character(metric_heat$Metric) == metric, , drop = FALSE]
    p <- (p_b %+% shown) + labs(title = metric)
    if (grepl("Pearson", metric)) p <- p + scale_fill_gradient2(low = "#A65D57", mid = "white",
        high = "#3178A5", midpoint = 0, limits = c(-1, 1), na.value = "#ECECEC")
    save_plot(p, paste0("Figure_06b_", v22_slug(metric)))
}

# 9. Figure B2: effect-size comparisons
#
# Focus on the two transformations that actually alter
# effect estimates:
#   median normalization
#   run-date covariate
# ============================================================

make_scatter <- function(
    comparison_name,
    contrast_name
) {

    ref <- primary_results[[contrast_name]]

    cmp <- all_results[[comparison_name]][[contrast_name]]

    merged <- merge(
        ref[
            ,
            c(
                "PG.ProteinGroups",
                "logFC"
            )
        ],
        cmp[
            ,
            c(
                "PG.ProteinGroups",
                "logFC"
            )
        ],
        by = "PG.ProteinGroups",
        suffixes = c(
            "_primary",
            "_comparison"
        ),
        all = FALSE
    )

    valid <- is.finite(
        merged$logFC_primary
    ) & is.finite(
        merged$logFC_comparison
    )

    merged <- merged[
        valid,
        ,
        drop = FALSE
    ]

    r_value <- cor(
        merged$logFC_primary,
        merged$logFC_comparison,
        method = "pearson"
    )

    lim_value <- max(
        abs(
            c(
                merged$logFC_primary,
                merged$logFC_comparison
            )
        ),
        na.rm = TRUE
    )

    lim_value <- max(
        lim_value,
        0.1
    )

    ggplot(
        merged,
        aes(
            x = logFC_primary,
            y = logFC_comparison
        )
    ) +
        geom_point(
            size = 0.90,
            alpha = 0.38,
            colour = "#333333"
        ) +
        geom_abline(
            slope = 1,
            intercept = 0,
            linetype = "dashed",
            linewidth = 0.50,
            colour = "#C0392B"
        ) +
        coord_equal(
            xlim = c(
                -lim_value,
                lim_value
            ),
            ylim = c(
                -lim_value,
                lim_value
            )
        ) +
        annotate(
            "label",
            x = -Inf,
            y = Inf,
            label = paste0(
                "r = ",
                sprintf(
                    "%.3f",
                    r_value
                )
            ),
            hjust = -0.04,
            vjust = 1.10,
            size = 2.8,
            fill = alpha(
                "white",
                0.88
            )
        ) +
        labs(
            title = CONTRAST_LABELS[
                contrast_name
            ],
            subtitle = comparison_name,
            x = "Primary logFC",
            y = paste0(
                comparison_name,
                " logFC"
            )
        ) +
        theme_publication(
            base_size = 8
        )
}


scatter_plots <- list()
counter <- 1

for (comparison_name in c(
    "Median normalization",
    "MS run-date proxy"
)) {

    for (contrast_name in CONTRASTS) {

        scatter_plots[[counter]] <- make_scatter(
            comparison_name,
            contrast_name
        )

        counter <- counter + 1
    }
}


for (i in seq_along(scatter_plots)) {
    save_plot(scatter_plots[[i]], paste0("Figure_06b_effect_size_sensitivity_", sprintf("%02d", i)))
}

# 10. Figure B3: primary significant-set retention
# ============================================================

retention_rows <- list()
counter <- 1

for (comparison_name in comparison_names) {

    for (contrast_name in CONTRASTS) {

        row <- metrics %>%
            filter(
                Comparison == comparison_name,
                Contrast == contrast_name
            )

        if (nrow(row) != 1) {
            stop(
                "Unexpected robustness-metric row count."
            )
        }

        retention <- if (
            row$Significant_primary == 0
        ) {
            NA_real_
        } else {
            row$Significant_overlap /
                row$Significant_primary
        }

        retention_rows[[counter]] <- data.frame(
            Comparison = comparison_name,
            Contrast = contrast_name,
            Retention = retention,
            stringsAsFactors = FALSE
        )

        counter <- counter + 1
    }
}

retention_df <- bind_rows(
    retention_rows
)

retention_df$Comparison <- factor(
    retention_df$Comparison,
    levels = comparison_names
)

retention_df$Contrast <- factor(
    retention_df$Contrast,
    levels = CONTRASTS
)


p_b3 <- ggplot(
    retention_df,
    aes(
        x = Comparison,
        y = Contrast,
        fill = Retention
    )
) +
    geom_tile(
        colour = "white",
        linewidth = 0.8
    ) +
    geom_text(
        aes(
            label = ifelse(
                is.na(
                    Retention
                ),
                "NA",
                paste0(
                    round(
                        Retention * 100
                    ),
                    "%"
                )
            )
        ),
        size = 3.2,
        fontface = "bold"
    ) +
    scale_fill_gradient(
        low = "#F5F5F5",
        high = "#2C7A3F",
        limits = c(
            0,
            1
        ),
        labels = percent_format(
            accuracy = 1
        ),
        na.value = "#E6E6E6"
    ) +
    scale_y_discrete(
        labels = CONTRAST_LABELS
    ) +
    labs(
        title = "Retention of primary FDR-significant proteins",
        subtitle = "Overlap divided by the number significant in the primary analysis",
        x = NULL,
        y = NULL,
        fill = "Retention"
    ) +
    theme_minimal(
        base_size = 9,
        base_family = "sans"
    ) +
    theme(
        panel.grid = element_blank(),
        plot.title = element_text(
            face = "bold",
            size = 10,
            hjust = 0
        ),
        axis.text.x = element_text(
            angle = 25,
            hjust = 1,
            colour = "black"
        ),
        axis.text.y = element_text(
            colour = "black"
        )
    )

save_plot(
    p_b3,
    "Figure_06b_primary_significant_retention",
    width = 7.8,
    height = 3.5
)


# ============================================================
# 11. Source data
# ============================================================

write.csv(
    sig_counts,
    file.path(
        FIG_DIR,
        "Figure_06b_significant_counts.csv"
    ),
    row.names = FALSE
)

write.csv(
    retention_df,
    file.path(
        FIG_DIR,
        "Figure_06b_retention_data.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 12. Console
# ============================================================

cat(
    "\n============================================================\n"
)

cat(
    "06b ROBUSTNESS FIGURES COMPLETED\n"
)

cat(
    "============================================================\n"
)

cat(
    "Output:\n",
    FIG_DIR,
    "\n",
    sep = ""
)

cat(
    "\nGenerated:\n"
)

cat(
    "Figure_06b independent robustness figures\n"
)

cat(
    "Figure_06b_effect_size_sensitivity\n"
)

cat(
    "Figure_06b_primary_significant_retention\n"
)

cat(
    "\nPASS\n"
)

