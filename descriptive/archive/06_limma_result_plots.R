# ============================================================
# 06 LIMMA RESULT PLOTS
#
# Purpose:
#   Visualize the completed plasma-proteomics limma analysis.
#
# Reads:
#   limma_dose_analysis/
#   normalization_sample_diagnostics.csv
#   complete_case_PCA_scores.csv
#
# Outputs:
#   limma_dose_analysis/figures/
#
# IMPORTANT:
#   This script performs plotting only.
#   It does NOT refit limma models.
#   It does NOT alter the locked primary analysis.
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
    "scales",
    "pheatmap"
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
            "Missing required package(s): ",
            paste(missing_packages, collapse = ", "),
            "\nInstall with:\n",
            "install.packages(c(",
            paste(
                paste0(
                    "'",
                    missing_packages,
                    "'"
                ),
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
    library(pheatmap)
})


# ============================================================
# 2. Locate script directory
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

        script_path <- sub(
            "^--file=",
            "",
            file_arg
        )

        return(
            dirname(
                normalizePath(
                    script_path,
                    winslash = "/",
                    mustWork = TRUE
                )
            )
        )
    }

    normalizePath(
        getwd(),
        winslash = "/",
        mustWork = TRUE
    )
}


ROOT_DIR <- get_script_dir()

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
    "figures"
)

dir.create(
    FIG_DIR,
    recursive = TRUE,
    showWarnings = FALSE
)


# ============================================================
# 3. Input files
# ============================================================

SAMPLE_DIAG_FILE <- file.path(
    ROOT_DIR,
    "normalization_sample_diagnostics.csv"
)

PCA_FILE <- file.path(
    ROOT_DIR,
    "complete_case_PCA_scores.csv"
)

ROBUSTNESS_FILE <- file.path(
    ROBUSTNESS_DIR,
    "robustness_summary.csv"
)

PRIMARY_SUMMARY_FILE <- file.path(
    LIMMA_DIR,
    "PRIMARY_summary.csv"
)

PRIMARY_EXPR_FILE <- file.path(
    ROOT_DIR,
    "PRIMARY_dose_log2_expression.csv.gz"
)

META_FILE <- file.path(
    ROOT_DIR,
    "dose_defined_metadata.csv"
)


# ============================================================
# 4. Result file map
# ============================================================

contrast_names <- c(
    "Low_vs_Control",
    "High_vs_Control",
    "High_vs_Low"
)

primary_files <- c(
    Low_vs_Control = file.path(
        RESULT_DIR,
        "01_PRIMARY",
        "PRIMARY_log2_dose_environment__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        RESULT_DIR,
        "01_PRIMARY",
        "PRIMARY_log2_dose_environment__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        RESULT_DIR,
        "01_PRIMARY",
        "PRIMARY_log2_dose_environment__High_vs_Low.csv"
    )
)

median_files <- c(
    Low_vs_Control = file.path(
        RESULT_DIR,
        "02_SENS_median_normalization",
        "SENS_normalization_median__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        RESULT_DIR,
        "02_SENS_median_normalization",
        "SENS_normalization_median__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        RESULT_DIR,
        "02_SENS_median_normalization",
        "SENS_normalization_median__High_vs_Low.csv"
    )
)

batch_files <- c(
    Low_vs_Control = file.path(
        RESULT_DIR,
        "03_SENS_MS_batch_proxy",
        "SENS_add_MS_batch_proxy__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        RESULT_DIR,
        "03_SENS_MS_batch_proxy",
        "SENS_add_MS_batch_proxy__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        RESULT_DIR,
        "03_SENS_MS_batch_proxy",
        "SENS_add_MS_batch_proxy__High_vs_Low.csv"
    )
)

threshold50_files <- c(
    Low_vs_Control = file.path(
        RESULT_DIR,
        "04_SENS_threshold_50pct",
        "SENS_detection_threshold_50pct__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        RESULT_DIR,
        "04_SENS_threshold_50pct",
        "SENS_detection_threshold_50pct__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        RESULT_DIR,
        "04_SENS_threshold_50pct",
        "SENS_detection_threshold_50pct__High_vs_Low.csv"
    )
)

threshold80_files <- c(
    Low_vs_Control = file.path(
        RESULT_DIR,
        "05_SENS_threshold_80pct",
        "SENS_detection_threshold_80pct__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        RESULT_DIR,
        "05_SENS_threshold_80pct",
        "SENS_detection_threshold_80pct__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        RESULT_DIR,
        "05_SENS_threshold_80pct",
        "SENS_detection_threshold_80pct__High_vs_Low.csv"
    )
)

complete_case_files <- c(
    Low_vs_Control = file.path(
        RESULT_DIR,
        "06_SENS_complete_case",
        "SENS_complete_case__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        RESULT_DIR,
        "06_SENS_complete_case",
        "SENS_complete_case__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        RESULT_DIR,
        "06_SENS_complete_case",
        "SENS_complete_case__High_vs_Low.csv"
    )
)


# ============================================================
# 5. Validate files
# ============================================================

all_required_files <- c(
    SAMPLE_DIAG_FILE,
    PCA_FILE,
    ROBUSTNESS_FILE,
    PRIMARY_SUMMARY_FILE,
    PRIMARY_EXPR_FILE,
    META_FILE,
    unname(primary_files),
    unname(median_files),
    unname(batch_files),
    unname(threshold50_files),
    unname(threshold80_files),
    unname(complete_case_files)
)

missing_files <- all_required_files[
    !file.exists(
        all_required_files
    )
]

if (length(missing_files) > 0) {
    stop(
        paste0(
            "Missing required file(s):\n",
            paste(
                missing_files,
                collapse = "\n"
            )
        )
    )
}


# ============================================================
# 6. Plot style
# ============================================================

theme_set(
    theme_classic(
        base_size = 9,
        base_family = "Arial"
    )
)

theme_common <- theme(
    plot.title = element_text(
        face = "bold",
        size = 10,
        hjust = 0
    ),
    plot.subtitle = element_text(
        size = 8
    ),
    axis.title = element_text(
        size = 9
    ),
    axis.text = element_text(
        size = 8
    ),
    legend.title = element_text(
        size = 8
    ),
    legend.text = element_text(
        size = 7
    )
)


save_plot <- function(
    plot,
    filename,
    width,
    height
) {

    ggsave(
        filename = file.path(
            FIG_DIR,
            paste0(
                filename,
                ".pdf"
            )
        ),
        plot = plot,
        width = width,
        height = height,
        units = "in",
        device = cairo_pdf
    )

    ggsave(
        filename = file.path(
            FIG_DIR,
            paste0(
                filename,
                ".png"
            )
        ),
        plot = plot,
        width = width,
        height = height,
        units = "in",
        dpi = 300
    )
}


# ============================================================
# 7. Read normalization diagnostics
# ============================================================

sample_diag <- read.csv(
    SAMPLE_DIAG_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)

sample_diag$TREAT1_clean <- factor(
    sample_diag$TREAT1_clean,
    levels = c(
        "control",
        "low",
        "high"
    )
)

sample_diag$condition <- factor(
    sample_diag$condition,
    levels = c(
        "high_stress",
        "high_temperature"
    )
)

sample_diag$MS_batch_proxy <- factor(
    sample_diag$MS_batch_proxy,
    levels = sort(
        unique(
            sample_diag$MS_batch_proxy
        )
    )
)


# ============================================================
# 8. Figure 1: sample median diagnostics
# ============================================================

p1a <- ggplot(
    sample_diag,
    aes(
        x = TREAT1_clean,
        y = log2_median
    )
) +
    geom_boxplot(
        outlier.shape = NA,
        width = 0.60
    ) +
    geom_jitter(
        width = 0.15,
        alpha = 0.35,
        size = 0.9
    ) +
    labs(
        title = "A  Sample median by dose",
        x = NULL,
        y = "Sample median log2 abundance"
    ) +
    theme_common

p1b <- ggplot(
    sample_diag,
    aes(
        x = condition,
        y = log2_median
    )
) +
    geom_boxplot(
        outlier.shape = NA,
        width = 0.60
    ) +
    geom_jitter(
        width = 0.15,
        alpha = 0.35,
        size = 0.9
    ) +
    labs(
        title = "B  Sample median by environment",
        x = NULL,
        y = "Sample median log2 abundance"
    ) +
    theme_common +
    theme(
        axis.text.x = element_text(
            angle = 20,
            hjust = 1
        )
    )

p1c <- ggplot(
    sample_diag,
    aes(
        x = MS_batch_proxy,
        y = log2_median
    )
) +
    geom_boxplot(
        outlier.shape = NA,
        width = 0.65
    ) +
    geom_jitter(
        width = 0.15,
        alpha = 0.30,
        size = 0.8
    ) +
    labs(
        title = "C  Sample median by MS run-date proxy",
        x = "MS run-date proxy",
        y = "Sample median log2 abundance"
    ) +
    theme_common +
    theme(
        axis.text.x = element_text(
            angle = 45,
            hjust = 1
        )
    )

p1d <- ggplot(
    sample_diag,
    aes(
        x = observed_proteins,
        y = log2_median,
        shape = TREAT1_clean
    )
) +
    geom_point(
        alpha = 0.55,
        size = 1.6
    ) +
    geom_smooth(
        method = "lm",
        se = FALSE,
        linewidth = 0.6,
        inherit.aes = TRUE
    ) +
    labs(
        title = "D  Detection depth vs sample median",
        x = "Observed proteins in primary set",
        y = "Sample median log2 abundance",
        shape = "Dose"
    ) +
    theme_common

fig1 <- (
    p1a |
    p1b
) /
(
    p1c |
    p1d
)

save_plot(
    fig1,
    "Figure01_sample_level_normalization_diagnostics",
    width = 8.2,
    height = 6.6
)


# ============================================================
# 9. Figure 2: complete-case PCA
# ============================================================

pca <- read.csv(
    PCA_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)

required_pca_columns <- c(
    "UniqueSampleID",
    "PC1",
    "PC2",
    "PC1_variance_pct",
    "PC2_variance_pct",
    "TREAT1_clean",
    "condition",
    "MS_batch_proxy"
)

missing_pca_columns <- setdiff(
    required_pca_columns,
    colnames(pca)
)

if (length(missing_pca_columns) > 0) {
    stop(
        paste0(
            "PCA file missing column(s): ",
            paste(
                missing_pca_columns,
                collapse = ", "
            )
        )
    )
}

pca$TREAT1_clean <- factor(
    pca$TREAT1_clean,
    levels = c(
        "control",
        "low",
        "high"
    )
)

pca$condition <- factor(
    pca$condition,
    levels = c(
        "high_stress",
        "high_temperature"
    )
)

# MS_batch_proxy may be read as numeric from CSV.
# Convert it explicitly to a categorical factor before mapping to shape.
pca$MS_batch_proxy <- factor(
    as.character(
        pca$MS_batch_proxy
    ),
    levels = sort(
        unique(
            as.character(
                pca$MS_batch_proxy
            )
        )
    )
)

pc1_pct <- unique(
    pca$PC1_variance_pct
)

pc2_pct <- unique(
    pca$PC2_variance_pct
)

pc1_label <- paste0(
    "PC1 (",
    sprintf(
        "%.2f",
        pc1_pct[1]
    ),
    "%)"
)

pc2_label <- paste0(
    "PC2 (",
    sprintf(
        "%.2f",
        pc2_pct[1]
    ),
    "%)"
)

p2a <- ggplot(
    pca,
    aes(
        x = PC1,
        y = PC2,
        shape = TREAT1_clean
    )
) +
    geom_point(
        size = 1.7,
        alpha = 0.65
    ) +
    labs(
        title = "A  Complete-case PCA by dose",
        x = pc1_label,
        y = pc2_label,
        shape = "Dose"
    ) +
    theme_common

p2b <- ggplot(
    pca,
    aes(
        x = PC1,
        y = PC2,
        shape = condition
    )
) +
    geom_point(
        size = 1.7,
        alpha = 0.65
    ) +
    labs(
        title = "B  Complete-case PCA by environment",
        x = pc1_label,
        y = pc2_label,
        shape = "Environment"
    ) +
    theme_common

p2c <- ggplot(
    pca,
    aes(
        x = PC1,
        y = PC2,
        shape = MS_batch_proxy
    )
) +
    geom_point(
        size = 1.6,
        alpha = 0.60
    ) +
    labs(
        title = "C  Complete-case PCA by MS run-date proxy",
        x = pc1_label,
        y = pc2_label,
        shape = "MS run date"
    ) +
    theme_common

fig2 <- (
    p2a |
    p2b
) /
p2c

save_plot(
    fig2,
    "Figure02_complete_case_PCA",
    width = 8.2,
    height = 6.5
)


# ============================================================
# 10. Helpers to read result files
# ============================================================

read_result <- function(
    file,
    analysis_name
) {

    dat <- read.csv(
        file,
        check.names = FALSE,
        stringsAsFactors = FALSE
    )

    required_columns <- c(
        "PG.ProteinGroups",
        "Contrast",
        "logFC",
        "P.Value",
        "adj.P.Val"
    )

    missing_columns <- setdiff(
        required_columns,
        colnames(dat)
    )

    if (length(missing_columns) > 0) {
        stop(
            paste0(
                "Missing columns in ",
                basename(file),
                ": ",
                paste(
                    missing_columns,
                    collapse = ", "
                )
            )
        )
    }

    dat$Analysis <- analysis_name

    dat
}


# ============================================================
# 11. Primary result list
# ============================================================

primary_results <- lapply(
    contrast_names,
    function(
        contrast_name
    ) {
        read_result(
            primary_files[contrast_name],
            "Primary"
        )
    }
)

names(primary_results) <- contrast_names


median_results <- lapply(
    contrast_names,
    function(
        contrast_name
    ) {
        read_result(
            median_files[contrast_name],
            "Median normalization"
        )
    }
)

names(median_results) <- contrast_names


batch_results <- lapply(
    contrast_names,
    function(
        contrast_name
    ) {
        read_result(
            batch_files[contrast_name],
            "MS batch proxy"
        )
    }
)

names(batch_results) <- contrast_names


threshold50_results <- lapply(
    contrast_names,
    function(
        contrast_name
    ) {
        read_result(
            threshold50_files[contrast_name],
            "Threshold 50%"
        )
    }
)

names(threshold50_results) <- contrast_names


threshold80_results <- lapply(
    contrast_names,
    function(
        contrast_name
    ) {
        read_result(
            threshold80_files[contrast_name],
            "Threshold 80%"
        )
    }
)

names(threshold80_results) <- contrast_names


complete_case_results <- lapply(
    contrast_names,
    function(
        contrast_name
    ) {
        read_result(
            complete_case_files[contrast_name],
            "Complete case"
        )
    }
)

names(complete_case_results) <- contrast_names


# ============================================================
# 12. Figure 3: Primary volcano plots
# ============================================================

make_volcano <- function(
    dat,
    title
) {

    dat <- dat %>%
        mutate(
            minus_log10_fdr = -log10(
                pmax(
                    adj.P.Val,
                    .Machine$double.xmin
                )
            ),
            Status = case_when(
                !is.na(adj.P.Val) &
                    adj.P.Val < 0.05 &
                    logFC > 0 ~ "Higher",
                !is.na(adj.P.Val) &
                    adj.P.Val < 0.05 &
                    logFC < 0 ~ "Lower",
                TRUE ~ "Not significant"
            )
        )

    top_labels <- dat %>%
        filter(
            !is.na(adj.P.Val)
        ) %>%
        arrange(
            adj.P.Val,
            desc(
                abs(
                    logFC
                )
            )
        ) %>%
        slice_head(
            n = 10
        )

    ggplot(
        dat,
        aes(
            x = logFC,
            y = minus_log10_fdr
        )
    ) +
        geom_point(
            aes(
                shape = Status
            ),
            alpha = 0.55,
            size = 1.25
        ) +
        geom_hline(
            yintercept = -log10(
                0.05
            ),
            linetype = "dashed",
            linewidth = 0.45
        ) +
        geom_vline(
            xintercept = 0,
            linewidth = 0.35
        ) +
        geom_text(
            data = top_labels,
            aes(
                label = PG.ProteinGroups
            ),
            size = 2.4,
            check_overlap = TRUE,
            vjust = -0.45
        ) +
        labs(
            title = title,
            x = "log2 fold change",
            y = "-log10(BH FDR)",
            shape = NULL
        ) +
        theme_common +
        theme(
            legend.position = "bottom"
        )
}


v1 <- make_volcano(
    primary_results$Low_vs_Control,
    "A  Low vs Control"
)

v2 <- make_volcano(
    primary_results$High_vs_Control,
    "B  High vs Control"
)

v3 <- make_volcano(
    primary_results$High_vs_Low,
    "C  High vs Low"
)

fig3 <- v1 | v2 | v3

save_plot(
    fig3,
    "Figure03_PRIMARY_volcano",
    width = 11.0,
    height = 3.8
)


# ============================================================
# 13. Figure 4: Primary vs median-normalization logFC
# ============================================================

make_logfc_comparison <- function(
    primary_dat,
    comparison_dat,
    title,
    comparison_label
) {

    merged <- merge(
        primary_dat[
            ,
            c(
                "PG.ProteinGroups",
                "logFC",
                "adj.P.Val"
            )
        ],
        comparison_dat[
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
        )
    )

    r_value <- cor(
        merged$logFC_primary,
        merged$logFC_comparison,
        use = "complete.obs",
        method = "pearson"
    )

    limit_value <- max(
        abs(
            c(
                merged$logFC_primary,
                merged$logFC_comparison
            )
        ),
        na.rm = TRUE
    )

    ggplot(
        merged,
        aes(
            x = logFC_primary,
            y = logFC_comparison
        )
    ) +
        geom_point(
            alpha = 0.45,
            size = 1.1
        ) +
        geom_abline(
            slope = 1,
            intercept = 0,
            linetype = "dashed",
            linewidth = 0.45
        ) +
        coord_equal(
            xlim = c(
                -limit_value,
                limit_value
            ),
            ylim = c(
                -limit_value,
                limit_value
            )
        ) +
        annotate(
            "text",
            x = -Inf,
            y = Inf,
            label = paste0(
                "Pearson r = ",
                sprintf(
                    "%.3f",
                    r_value
                )
            ),
            hjust = -0.05,
            vjust = 1.4,
            size = 3
        ) +
        labs(
            title = title,
            x = "Primary logFC",
            y = paste0(
                comparison_label,
                " logFC"
            )
        ) +
        theme_common
}


m1 <- make_logfc_comparison(
    primary_results$Low_vs_Control,
    median_results$Low_vs_Control,
    "A  Low vs Control",
    "Median-normalized"
)

m2 <- make_logfc_comparison(
    primary_results$High_vs_Control,
    median_results$High_vs_Control,
    "B  High vs Control",
    "Median-normalized"
)

m3 <- make_logfc_comparison(
    primary_results$High_vs_Low,
    median_results$High_vs_Low,
    "C  High vs Low",
    "Median-normalized"
)

fig4 <- m1 | m2 | m3

save_plot(
    fig4,
    "Figure04_PRIMARY_vs_median_normalization_logFC",
    width = 10.8,
    height = 3.6
)


# ============================================================
# 14. Figure 5: Primary vs MS-batch-proxy model
# ============================================================

b1 <- make_logfc_comparison(
    primary_results$Low_vs_Control,
    batch_results$Low_vs_Control,
    "A  Low vs Control",
    "+ MS batch proxy"
)

b2 <- make_logfc_comparison(
    primary_results$High_vs_Control,
    batch_results$High_vs_Control,
    "B  High vs Control",
    "+ MS batch proxy"
)

b3 <- make_logfc_comparison(
    primary_results$High_vs_Low,
    batch_results$High_vs_Low,
    "C  High vs Low",
    "+ MS batch proxy"
)

fig5 <- b1 | b2 | b3

save_plot(
    fig5,
    "Figure05_PRIMARY_vs_MS_batch_proxy_logFC",
    width = 10.8,
    height = 3.6
)


# ============================================================
# 15. Figure 6: significant-protein counts across analyses
# ============================================================

count_significant <- function(
    result_list,
    analysis_name
) {

    do.call(
        rbind,
        lapply(
            contrast_names,
            function(
                contrast_name
            ) {

                dat <- result_list[[contrast_name]]

                data.frame(
                    Analysis = analysis_name,
                    Contrast = contrast_name,
                    FDR_lt_0.05 = sum(
                        !is.na(
                            dat$adj.P.Val
                        )
                        &
                        dat$adj.P.Val < 0.05
                    ),
                    stringsAsFactors = FALSE
                )
            }
        )
    )
}


sig_counts <- bind_rows(
    count_significant(
        primary_results,
        "Primary"
    ),
    count_significant(
        median_results,
        "Median normalization"
    ),
    count_significant(
        batch_results,
        "MS batch proxy"
    ),
    count_significant(
        threshold50_results,
        "Threshold 50%"
    ),
    count_significant(
        threshold80_results,
        "Threshold 80%"
    ),
    count_significant(
        complete_case_results,
        "Complete case"
    )
)

sig_counts$Contrast <- factor(
    sig_counts$Contrast,
    levels = contrast_names
)

sig_counts$Analysis <- factor(
    sig_counts$Analysis,
    levels = c(
        "Primary",
        "Median normalization",
        "MS batch proxy",
        "Threshold 50%",
        "Threshold 80%",
        "Complete case"
    )
)

p6 <- ggplot(
    sig_counts,
    aes(
        x = Analysis,
        y = FDR_lt_0.05,
        fill = Contrast
    )
) +
    geom_col(
        position = position_dodge(
            width = 0.78
        ),
        width = 0.72
    ) +
    geom_text(
        aes(
            label = FDR_lt_0.05
        ),
        position = position_dodge(
            width = 0.78
        ),
        vjust = -0.25,
        size = 2.5
    ) +
    labs(
        title = "Significant proteins across pre-specified analyses",
        x = NULL,
        y = "Proteins with BH FDR < 0.05",
        fill = "Contrast"
    ) +
    theme_common +
    theme(
        axis.text.x = element_text(
            angle = 25,
            hjust = 1
        )
    )

save_plot(
    p6,
    "Figure06_significant_protein_counts",
    width = 8.6,
    height = 4.6
)


# ============================================================
# 16. Figure 7: robustness metrics
# ============================================================

robustness <- read.csv(
    ROBUSTNESS_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)

robustness$Contrast <- factor(
    robustness$Contrast,
    levels = contrast_names
)

robustness$Comparison <- factor(
    robustness$Comparison,
    levels = c(
        "Median_normalization",
        "MS_batch_proxy",
        "Threshold_50pct",
        "Threshold_80pct",
        "Complete_case"
    )
)

robust_long <- robustness %>%
    select(
        Contrast,
        Comparison,
        Pearson_logFC,
        Spearman_logFC,
        Direction_concordance,
        Jaccard_FDR_0.05
    ) %>%
    pivot_longer(
        cols = c(
            Pearson_logFC,
            Spearman_logFC,
            Direction_concordance,
            Jaccard_FDR_0.05
        ),
        names_to = "Metric",
        values_to = "Value"
    )

p7 <- ggplot(
    robust_long,
    aes(
        x = Comparison,
        y = Value,
        fill = Contrast
    )
) +
    geom_col(
        position = position_dodge(
            width = 0.78
        ),
        width = 0.72
    ) +
    facet_wrap(
        ~ Metric,
        scales = "free_y",
        ncol = 2
    ) +
    labs(
        title = "Robustness of primary dose effects",
        x = NULL,
        y = NULL,
        fill = "Contrast"
    ) +
    theme_common +
    theme(
        axis.text.x = element_text(
            angle = 30,
            hjust = 1
        )
    )

save_plot(
    p7,
    "Figure07_robustness_metrics",
    width = 9.0,
    height = 6.2
)


# ============================================================
# 17. Figure 8: threshold and complete-case logFC comparisons
# ============================================================

make_three_way_panel <- function(
    comparison_results,
    comparison_label,
    filename
) {

    q1 <- make_logfc_comparison(
        primary_results$Low_vs_Control,
        comparison_results$Low_vs_Control,
        "A  Low vs Control",
        comparison_label
    )

    q2 <- make_logfc_comparison(
        primary_results$High_vs_Control,
        comparison_results$High_vs_Control,
        "B  High vs Control",
        comparison_label
    )

    q3 <- make_logfc_comparison(
        primary_results$High_vs_Low,
        comparison_results$High_vs_Low,
        "C  High vs Low",
        comparison_label
    )

    fig <- q1 | q2 | q3

    save_plot(
        fig,
        filename,
        width = 10.8,
        height = 3.6
    )
}


make_three_way_panel(
    threshold50_results,
    "Threshold 50%",
    "Figure08A_PRIMARY_vs_threshold50_logFC"
)

make_three_way_panel(
    threshold80_results,
    "Threshold 80%",
    "Figure08B_PRIMARY_vs_threshold80_logFC"
)

make_three_way_panel(
    complete_case_results,
    "Complete case",
    "Figure08C_PRIMARY_vs_complete_case_logFC"
)


# ============================================================
# 18. Figure 9: top stable proteins heatmap
#
# Select proteins from High_vs_Low primary results:
#   FDR < 0.05
# Then rank by:
#   smallest FDR, then largest |logFC|
# Plot top 30 proteins using primary log2 matrix.
#
# No imputation is performed.
# Missing cells remain NA in the heatmap.
# ============================================================

expr_df <- read.csv(
    PRIMARY_EXPR_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)

meta <- read.csv(
    META_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = character(0)
)

if (!identical(
    colnames(expr_df)[-1],
    meta$UniqueSampleID
)) {
    stop(
        "Expression and metadata are not aligned for heatmap."
    )
}

high_low <- primary_results$High_vs_Low %>%
    filter(
        !is.na(
            adj.P.Val
        ),
        adj.P.Val < 0.05
    ) %>%
    arrange(
        adj.P.Val,
        desc(
            abs(
                logFC
            )
        )
    )

top_n <- min(
    30,
    nrow(
        high_low
    )
)

if (top_n >= 2) {

    top_proteins <- high_low$PG.ProteinGroups[
        seq_len(
            top_n
        )
    ]

    heat_idx <- match(
        top_proteins,
        expr_df$PG.ProteinGroups
    )

    heat_mat <- as.matrix(
        expr_df[
            heat_idx,
            -1,
            drop = FALSE
        ]
    )

    storage.mode(
        heat_mat
    ) <- "double"

    rownames(
        heat_mat
    ) <- top_proteins

    row_mean <- rowMeans(
        heat_mat,
        na.rm = TRUE
    )

    row_sd <- apply(
        heat_mat,
        1,
        sd,
        na.rm = TRUE
    )

    row_sd[
        !is.finite(
            row_sd
        )
        |
        row_sd == 0
    ] <- 1

    heat_z <- sweep(
        heat_mat,
        1,
        row_mean,
        "-"
    )

    heat_z <- sweep(
        heat_z,
        1,
        row_sd,
        "/"
    )

    annotation_col <- data.frame(
        Dose = factor(
            meta$TREAT1_clean,
            levels = c(
                "control",
                "low",
                "high"
            )
        ),
        Environment = factor(
            meta$condition,
            levels = c(
                "high_stress",
                "high_temperature"
            )
        ),
        MS_run_date = factor(
            as.character(
                meta$进样时间
            )
        ),
        row.names = meta$UniqueSampleID,
        check.names = FALSE
    )

    pdf(
        file.path(
            FIG_DIR,
            "Figure09_top30_High_vs_Low_heatmap.pdf"
        ),
        width = 11,
        height = 7
    )

    pheatmap(
        heat_z,
        cluster_rows = TRUE,
        cluster_cols = TRUE,
        show_colnames = FALSE,
        annotation_col = annotation_col,
        border_color = NA,
        main = paste0(
            "Top ",
            top_n,
            " primary High vs Low proteins"
        ),
        na_col = "grey90",
        fontsize_row = 7
    )

    dev.off()

    png(
        file.path(
            FIG_DIR,
            "Figure09_top30_High_vs_Low_heatmap.png"
        ),
        width = 3300,
        height = 2100,
        res = 300
    )

    pheatmap(
        heat_z,
        cluster_rows = TRUE,
        cluster_cols = TRUE,
        show_colnames = FALSE,
        annotation_col = annotation_col,
        border_color = NA,
        main = paste0(
            "Top ",
            top_n,
            " primary High vs Low proteins"
        ),
        na_col = "grey90",
        fontsize_row = 7
    )

    dev.off()
}


# ============================================================
# 19. Figure 10: top primary proteins across dose groups
#
# Take top 12 proteins from High_vs_Low primary result.
# Plot sample-level log2 abundance by dose.
# NA values are not imputed.
# ============================================================

top_box_n <- min(
    12,
    nrow(
        high_low
    )
)

if (top_box_n >= 1) {

    top_box_proteins <- high_low$PG.ProteinGroups[
        seq_len(
            top_box_n
        )
    ]

    box_idx <- match(
        top_box_proteins,
        expr_df$PG.ProteinGroups
    )

    box_df <- expr_df[
        box_idx,
        ,
        drop = FALSE
    ]

    box_long <- box_df %>%
        pivot_longer(
            cols = -PG.ProteinGroups,
            names_to = "UniqueSampleID",
            values_to = "Abundance"
        ) %>%
        left_join(
            meta[
                ,
                c(
                    "UniqueSampleID",
                    "TREAT1_clean",
                    "condition"
                )
            ],
            by = "UniqueSampleID"
        )

    box_long$TREAT1_clean <- factor(
        box_long$TREAT1_clean,
        levels = c(
            "control",
            "low",
            "high"
        )
    )

    p10 <- ggplot(
        box_long,
        aes(
            x = TREAT1_clean,
            y = Abundance
        )
    ) +
        geom_boxplot(
            outlier.shape = NA,
            width = 0.62
        ) +
        geom_jitter(
            width = 0.16,
            alpha = 0.18,
            size = 0.55
        ) +
        facet_wrap(
            ~ PG.ProteinGroups,
            scales = "free_y",
            ncol = 4
        ) +
        labs(
            title = "Top primary High vs Low proteins across dose groups",
            x = NULL,
            y = "log2(PG.Quantity)"
        ) +
        theme_common +
        theme(
            strip.text = element_text(
                face = "bold",
                size = 7
            )
        )

    save_plot(
        p10,
        "Figure10_top12_protein_boxplots",
        width = 10.0,
        height = 7.0
    )
}


# ============================================================
# 20. Export figure data tables
# ============================================================

write.csv(
    sig_counts,
    file.path(
        FIG_DIR,
        "Figure06_significant_counts_data.csv"
    ),
    row.names = FALSE
)

write.csv(
    robust_long,
    file.path(
        FIG_DIR,
        "Figure07_robustness_metrics_data.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 21. Console summary
# ============================================================

cat(
    "\n============================================================\n"
)

cat(
    "LIMMA RESULT PLOTTING COMPLETED\n"
)

cat(
    "============================================================\n"
)

cat(
    "Figures written to:\n"
)

cat(
    FIG_DIR,
    "\n"
)

cat(
    "\nGenerated:\n"
)

cat(
    "Figure01_sample_level_normalization_diagnostics\n"
)

cat(
    "Figure02_complete_case_PCA\n"
)

cat(
    "Figure03_PRIMARY_volcano\n"
)

cat(
    "Figure04_PRIMARY_vs_median_normalization_logFC\n"
)

cat(
    "Figure05_PRIMARY_vs_MS_batch_proxy_logFC\n"
)

cat(
    "Figure06_significant_protein_counts\n"
)

cat(
    "Figure07_robustness_metrics\n"
)

cat(
    "Figure08A/B/C threshold and complete-case comparisons\n"
)

cat(
    "Figure09_top30_High_vs_Low_heatmap\n"
)

cat(
    "Figure10_top12_protein_boxplots\n"
)

cat(
    "\nPASS: plotting completed.\n"
)
