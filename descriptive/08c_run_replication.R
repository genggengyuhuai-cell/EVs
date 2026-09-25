# Legacy filename, result keys and output paths are retained for compatibility.
# low = Short exposure; high = Long exposure. No independent replication claim.
# ============================================================
# 06c ACQUISITION-DATE-STRATIFIED EXPOSURE ROBUSTNESS
#
# Purpose:
#   Assess concordance of primary exposure-effect directions
#   within the two largest MS run-date strata that each contain
#   control / low / high samples.
#
# Runs:
#   20260527
#   20260717
#
# IMPORTANT:
#   - This is acquisition-date-stratified sensitivity / robustness, not independent biological replication.
#   - It does NOT replace the locked primary model.
#   - The primary model remains dose + environment.
#   - Within each selected run, environment is fixed by cohort
#     structure, so the within-run model is dose only.
#   - Missing values remain NA.
#   - No imputation.
#   - No additional normalization.
#
# Main outputs:
#   run-specific limma tables
#   within-stratum concordance metrics
#   Figure_C1_run_replication
#   Figure_C2_top_primary_effect_forest
# ============================================================


rm(list = ls())
gc()


# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
    "limma",
    "statmod",
    "ggplot2",
    "dplyr",
    "tidyr",
    "readr",
    "patchwork",
    "ggrepel"
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
            "\nInstall missing CRAN packages with install.packages(). ",
            "Install limma with BiocManager::install('limma')."
        )
    )
}

suppressPackageStartupMessages({
    library(limma)
    library(ggplot2)
    library(dplyr)
    library(tidyr)
    library(readr)
    library(patchwork)
    library(ggrepel)
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
PROTEIN_ANNOTATION <- v21_annotation(ROOT_DIR)
v21_packages(c("ragg", "svglite"))

LIMMA_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis"
)

RESULT_DIR <- file.path(
    LIMMA_DIR,
    "results"
)

RUN_DIR <- file.path(
    LIMMA_DIR,
    "run_replication"
)

RUN_RESULT_DIR <- file.path(
    RUN_DIR,
    "results"
)

FIG_DIR <- file.path(
    LIMMA_DIR,
    "figures_final",
    "06c_run_replication/figures_nature_v2.2"
)

RUN_DIR <- v21_output(
    RUN_DIR
)

RUN_RESULT_DIR <- v21_output(
    RUN_RESULT_DIR
)

FIG_DIR <- v21_output(
    FIG_DIR
)


EXPR_FILE <- file.path(
    ROOT_DIR,
    "PRIMARY_dose_log2_expression.csv.gz"
)

META_FILE <- file.path(
    ROOT_DIR,
    "dose_defined_metadata.csv"
)

PRIMARY_HIGH_LOW_FILE <- file.path(
    RESULT_DIR,
    "01_PRIMARY",
    "PRIMARY_log2_dose_environment__High_vs_Low.csv"
)

PRIMARY_LOW_CONTROL_FILE <- file.path(
    RESULT_DIR,
    "01_PRIMARY",
    "PRIMARY_log2_dose_environment__Low_vs_Control.csv"
)

PRIMARY_HIGH_CONTROL_FILE <- file.path(
    RESULT_DIR,
    "01_PRIMARY",
    "PRIMARY_log2_dose_environment__High_vs_Control.csv"
)

required_files <- c(
    EXPR_FILE,
    META_FILE,
    PRIMARY_HIGH_LOW_FILE,
    PRIMARY_LOW_CONTROL_FILE,
    PRIMARY_HIGH_CONTROL_FILE
)

missing_files <- required_files[
    !file.exists(
        required_files
    )
]

if (length(missing_files) > 0) {
    stop(
        paste0(
            "Missing required file(s):\n",
            paste(missing_files, collapse = "\n")
        )
    )
}


# ============================================================
# 3. Locked settings
# ============================================================

TARGET_RUNS <- c(
    "20260527",
    "20260717"
)

DOSE_LEVELS <- c(
    "control",
    "low",
    "high"
)

CONTRASTS <- c(
    "Low_vs_Control",
    "High_vs_Control",
    "High_vs_Low"
)

CONTRAST_LABELS <- c(
    Low_vs_Control = "Short exposure vs Control",
    High_vs_Control = "Long exposure vs Control",
    High_vs_Low = "Long vs Short exposure"
)

RUN_COLORS <- c(
    "20260527" = "#7C3AED",
    "20260717" = "#0F9D8A"
)

DOSE_COLORS <- c(
    control = "#4D4D4D",
    low = "#3B82F6",
    high = "#D97706"
)

EBAYES_TREND <- TRUE
EBAYES_ROBUST <- TRUE


theme_publication <- function(base_size = 8) v21_theme(base_size)


save_plot <- function(plot_object, filename, width = 7.2, height = 4.8) {
    v21_save(plot_object, FIG_DIR, filename,
             if (is.data.frame(plot_object$data)) plot_object$data else NULL,
             width_mm = 183, height_mm = 125)
}


# ============================================================
# 4. Read expression and metadata
# ============================================================

expr_df <- read.csv(
    EXPR_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)

meta <- read.csv(
    META_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = character(0)
)

if (!"PG.ProteinGroups" %in% colnames(
    expr_df
)) {
    stop(
        "Expression file lacks PG.ProteinGroups."
    )
}

if (!identical(
    colnames(expr_df)[-1],
    meta$UniqueSampleID
)) {
    stop(
        "Expression columns and metadata are not aligned."
    )
}

expr <- as.matrix(
    expr_df[
        ,
        -1,
        drop = FALSE
    ]
)

storage.mode(
    expr
) <- "double"

rownames(
    expr
) <- expr_df$PG.ProteinGroups

meta$run_date <- as.character(
    meta[["进样时间"]]
)

meta$dose <- factor(
    meta$TREAT1_clean,
    levels = DOSE_LEVELS
)


# ============================================================
# 5. Validate target-run structure
# ============================================================

run_meta <- meta[
    meta$run_date %in% TARGET_RUNS,
    ,
    drop = FALSE
]

run_counts <- as.data.frame(
    table(
        Run = run_meta$run_date,
        Dose = run_meta$dose
    ),
    stringsAsFactors = FALSE
)

write.csv(
    run_counts,
    file.path(
        RUN_DIR,
        "run_dose_sample_counts.csv"
    ),
    row.names = FALSE
)


for (target_run in TARGET_RUNS) {

    sub_meta <- meta[
        meta$run_date == target_run,
        ,
        drop = FALSE
    ]

    observed_doses <- unique(
        as.character(
            sub_meta$dose
        )
    )

    missing_doses <- setdiff(
        DOSE_LEVELS,
        observed_doses
    )

    if (length(missing_doses) > 0) {
        stop(
            paste0(
                "Run ",
                target_run,
                " is missing dose group(s): ",
                paste(
                    missing_doses,
                    collapse = ", "
                )
            )
        )
    }
}


# ============================================================
# 6. Primary reference results
# ============================================================

read_primary <- function(
    file,
    contrast_name
) {

    dat <- read.csv(
        file,
        check.names = FALSE,
        stringsAsFactors = FALSE
    )

    dat$Contrast <- contrast_name

    dat
}


primary_results <- list(
    Low_vs_Control = read_primary(
        PRIMARY_LOW_CONTROL_FILE,
        "Low_vs_Control"
    ),
    High_vs_Control = read_primary(
        PRIMARY_HIGH_CONTROL_FILE,
        "High_vs_Control"
    ),
    High_vs_Low = read_primary(
        PRIMARY_HIGH_LOW_FILE,
        "High_vs_Low"
    )
)


# ============================================================
# 7. Run-specific limma helper
# ============================================================

fit_one_run <- function(
    target_run
) {

    sub_meta <- meta[
        meta$run_date == target_run,
        ,
        drop = FALSE
    ]

    sample_ids <- sub_meta$UniqueSampleID

    sub_expr <- expr[
        ,
        sample_ids,
        drop = FALSE
    ]

    sub_meta$dose <- factor(
        sub_meta$dose,
        levels = DOSE_LEVELS
    )

    design <- model.matrix(
        ~ 0 + dose,
        data = sub_meta
    )

    colnames(design) <- c(
        "dosecontrol",
        "doselow",
        "dosehigh"
    )

    if (qr(design)$rank != ncol(design)) {
        stop(
            paste0(
                "Run ",
                target_run,
                " dose design is not full rank."
            )
        )
    }

    contrast_matrix <- makeContrasts(
        Low_vs_Control =
            doselow - dosecontrol,
        High_vs_Control =
            dosehigh - dosecontrol,
        High_vs_Low =
            dosehigh - doselow,
        levels = design
    )

    fit <- lmFit(
        sub_expr,
        design
    )

    fit <- contrasts.fit(
        fit,
        contrast_matrix
    )

    fit <- eBayes(
        fit,
        trend = EBAYES_TREND,
        robust = EBAYES_ROBUST
    )

    result_list <- list()

    for (contrast_name in CONTRASTS) {

        coef_index <- match(
            contrast_name,
            colnames(
                contrast_matrix
            )
        )

        tab <- topTable(
            fit,
            coef = contrast_name,
            number = Inf,
            adjust.method = "BH",
            sort.by = "P"
        )

        tab$PG.ProteinGroups <- rownames(
            tab
        )

        row_index <- match(
            tab$PG.ProteinGroups,
            rownames(
                fit$coefficients
            )
        )

        coef_values <- fit$coefficients[
            row_index,
            coef_index
        ]

        t_values <- fit$t[
            row_index,
            coef_index
        ]

        df_values <- fit$df.total[
            row_index
        ]

        se_values <- rep(
            NA_real_,
            length(
                coef_values
            )
        )

        valid_se <- is.finite(
            coef_values
        ) &
            is.finite(
                t_values
            ) &
            t_values != 0

        se_values[
            valid_se
        ] <- abs(
            coef_values[
                valid_se
            ] /
                t_values[
                    valid_se
                ]
        )

        critical_values <- qt(
            0.975,
            df = df_values
        )

        tab$SE_moderated <- se_values

        tab$CI_low <- tab$logFC -
            critical_values * se_values

        tab$CI_high <- tab$logFC +
            critical_values * se_values

        tab$Run <- target_run

        tab$Contrast <- contrast_name

        # Number observed in each dose group for this protein
        protein_index <- match(
            tab$PG.ProteinGroups,
            rownames(
                sub_expr
            )
        )

        control_samples <- sub_meta$UniqueSampleID[
            sub_meta$dose == "control"
        ]

        low_samples <- sub_meta$UniqueSampleID[
            sub_meta$dose == "low"
        ]

        high_samples <- sub_meta$UniqueSampleID[
            sub_meta$dose == "high"
        ]

        tab$N_observed_control <- rowSums(
            is.finite(
                sub_expr[
                    protein_index,
                    control_samples,
                    drop = FALSE
                ]
            )
        )

        tab$N_observed_low <- rowSums(
            is.finite(
                sub_expr[
                    protein_index,
                    low_samples,
                    drop = FALSE
                ]
            )
        )

        tab$N_observed_high <- rowSums(
            is.finite(
                sub_expr[
                    protein_index,
                    high_samples,
                    drop = FALSE
                ]
            )
        )

        tab <- tab[
            ,
            c(
                "PG.ProteinGroups",
                "Run",
                "Contrast",
                "logFC",
                "SE_moderated",
                "CI_low",
                "CI_high",
                "AveExpr",
                "t",
                "P.Value",
                "adj.P.Val",
                "B",
                "N_observed_control",
                "N_observed_low",
                "N_observed_high"
            ),
            drop = FALSE
        ]

        rownames(
            tab
        ) <- NULL

        result_list[[contrast_name]] <- tab

        write.csv(
            tab,
            file.path(
                RUN_RESULT_DIR,
                paste0(
                    "Run_",
                    target_run,
                    "__",
                    contrast_name,
                    ".csv"
                )
            ),
            row.names = FALSE,
            na = ""
        )
    }

    saveRDS(
        fit,
        file.path(
            RUN_RESULT_DIR,
            paste0(
                "Run_",
                target_run,
                "__fit.rds"
            )
        )
    )

    list(
        metadata = sub_meta,
        expression = sub_expr,
        design = design,
        fit = fit,
        results = result_list
    )
}


# ============================================================
# 8. Fit both runs
# ============================================================

run_fits <- lapply(
    TARGET_RUNS,
    fit_one_run
)

names(run_fits) <- TARGET_RUNS


# ============================================================
# 9. Within-stratum concordance metrics
# ============================================================

metric_rows <- list()
counter <- 1

for (contrast_name in CONTRASTS) {

    run1 <- run_fits[["20260527"]]$results[[contrast_name]]

    run2 <- run_fits[["20260717"]]$results[[contrast_name]]

    merged <- merge(
        run1[
            ,
            c(
                "PG.ProteinGroups",
                "logFC"
            )
        ],
        run2[
            ,
            c(
                "PG.ProteinGroups",
                "logFC"
            )
        ],
        by = "PG.ProteinGroups",
        suffixes = c(
            "_20260527",
            "_20260717"
        ),
        all = FALSE
    )

    valid <- is.finite(
        merged$logFC_20260527
    ) &
        is.finite(
            merged$logFC_20260717
        )

    merged_valid <- merged[
        valid,
        ,
        drop = FALSE
    ]

    primary <- primary_results[[contrast_name]]

    primary_sig <- primary %>%
        filter(
            !is.na(
                adj.P.Val
            ),
            adj.P.Val < 0.05
        ) %>%
        select(
            PG.ProteinGroups
        )

    primary_sig_merged <- merged_valid %>%
        inner_join(
            primary_sig,
            by = "PG.ProteinGroups"
        )

    all_pearson <- if (
        nrow(
            merged_valid
        ) >= 3
    ) {
        cor(
            merged_valid$logFC_20260527,
            merged_valid$logFC_20260717,
            method = "pearson"
        )
    } else {
        NA_real_
    }

    all_spearman <- if (
        nrow(
            merged_valid
        ) >= 3
    ) {
        cor(
            merged_valid$logFC_20260527,
            merged_valid$logFC_20260717,
            method = "spearman"
        )
    } else {
        NA_real_
    }

    all_direction <- if (
        nrow(
            merged_valid
        ) > 0
    ) {
        mean(
            sign(
                merged_valid$logFC_20260527
            )
            ==
            sign(
                merged_valid$logFC_20260717
            )
        )
    } else {
        NA_real_
    }

    primary_sig_direction <- if (
        nrow(
            primary_sig_merged
        ) > 0
    ) {
        mean(
            sign(
                primary_sig_merged$logFC_20260527
            )
            ==
            sign(
                primary_sig_merged$logFC_20260717
            )
        )
    } else {
        NA_real_
    }

    metric_rows[[counter]] <- data.frame(
        Contrast = contrast_name,
        Proteins_estimable_both_runs = nrow(
            merged_valid
        ),
        Pearson_all = all_pearson,
        Spearman_all = all_spearman,
        Direction_all = all_direction,
        Primary_FDR_significant_estimable_both_runs = nrow(
            primary_sig_merged
        ),
        Direction_primary_FDR_significant = primary_sig_direction,
        stringsAsFactors = FALSE
    )

    counter <- counter + 1
}


concordance_metrics <- bind_rows(
    metric_rows
)

write.csv(
    concordance_metrics,
    file.path(
        RUN_DIR,
        "run_replication_metrics.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 10. Figure C1 panel A: run x dose sample counts
# ============================================================

run_counts$Run <- factor(
    run_counts$Run,
    levels = TARGET_RUNS
)

run_counts$Dose <- factor(
    run_counts$Dose,
    levels = DOSE_LEVELS
)

p_a <- ggplot(
    run_counts,
    aes(
        x = Run,
        y = Freq,
        fill = Dose
    )
) +
    geom_col(
        position = position_dodge(
            width = 0.75
        ),
        width = 0.68
    ) +
    geom_text(
        aes(
            label = Freq
        ),
        position = position_dodge(
            width = 0.75
        ),
        vjust = -0.30,
        size = 2.8
    ) +
    scale_fill_manual(
        values = DOSE_COLORS,
        labels = c(
            control = "Control",
            low = "Short exposure",
            high = "Long exposure"
        )
    ) +
    labs(
        title = "Samples within each acquisition-date stratum",
        x = "Acquisition date",
        y = "Samples",
        fill = "Exposure duration"
    ) +
    theme_publication() +
    theme(
        legend.position = "bottom"
    )


# ============================================================
# 11. Figure C1 panels B-D: run-vs-run logFC
# ============================================================

make_run_scatter <- function(
    contrast_name
) {

    run1 <- run_fits[["20260527"]]$results[[contrast_name]]

    run2 <- run_fits[["20260717"]]$results[[contrast_name]]

    merged <- merge(
        run1[
            ,
            c(
                "PG.ProteinGroups",
                "logFC"
            )
        ],
        run2[
            ,
            c(
                "PG.ProteinGroups",
                "logFC"
            )
        ],
        by = "PG.ProteinGroups",
        suffixes = c(
            "_20260527",
            "_20260717"
        ),
        all = FALSE
    )

    valid <- is.finite(
        merged$logFC_20260527
    ) &
        is.finite(
            merged$logFC_20260717
        )

    merged <- merged[
        valid,
        ,
        drop = FALSE
    ]

    primary <- primary_results[[contrast_name]]

    primary_sig_ids <- primary$PG.ProteinGroups[
        !is.na(
            primary$adj.P.Val
        )
        &
        primary$adj.P.Val < 0.05
    ]

    merged$Primary_significant <- (
        merged$PG.ProteinGroups %in%
            primary_sig_ids
    )

    r_all <- cor(
        merged$logFC_20260527,
        merged$logFC_20260717,
        method = "pearson"
    )

    direction_all <- mean(
        sign(
            merged$logFC_20260527
        )
        ==
        sign(
            merged$logFC_20260717
        )
    )

    lim_value <- max(
        abs(
            c(
                merged$logFC_20260527,
                merged$logFC_20260717
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
            x = logFC_20260527,
            y = logFC_20260717
        )
    ) +
        geom_point(
            aes(
                colour = Primary_significant
            ),
            size = 0.95,
            alpha = 0.45
        ) +
        geom_abline(
            slope = 1,
            intercept = 0,
            linetype = "dashed",
            linewidth = 0.45,
            colour = "#555555"
        ) +
        geom_hline(
            yintercept = 0,
            linewidth = 0.30,
            colour = "#B0B0B0"
        ) +
        geom_vline(
            xintercept = 0,
            linewidth = 0.30,
            colour = "#B0B0B0"
        ) +
        scale_colour_manual(
            values = c(
                `FALSE` = "#B8B8B8",
                `TRUE` = "#C0392B"
            ),
            labels = c(
                `FALSE` = "Other protein",
                `TRUE` = "Primary FDR < 0.05"
            )
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
                    "%.2f",
                    r_all
                ),
                "\nSame direction = ",
                round(
                    direction_all * 100
                ),
                "%"
            ),
            hjust = -0.03,
            vjust = 1.08,
            size = 2.6,
            fill = alpha(
                "white",
                0.90
            )
        ) +
        labs(
            title = CONTRAST_LABELS[
                contrast_name
            ],
            x = "20260527 logFC",
            y = "20260717 logFC",
            colour = NULL
        ) +
        theme_publication(
            base_size = 8
        ) +
        theme(
            legend.position = "bottom"
        )
}


p_b <- make_run_scatter("Low_vs_Control")

p_c <- make_run_scatter("High_vs_Control")

p_d <- make_run_scatter("High_vs_Low")


save_plot(p_a, "Figure_06c_acquisition_date_sample_counts")
save_plot(p_b, "Figure_06c_short_vs_control_concordance")
save_plot(p_c, "Figure_06c_long_vs_control_concordance")
save_plot(p_d, "Figure_06c_long_vs_short_concordance")

# 12. Figure C2: forest plot of top primary High-vs-Low hits
# ============================================================

primary_high_low <- primary_results$High_vs_Low %>%
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
    18,
    nrow(
        primary_high_low
    )
)

top_ids <- primary_high_low$PG.ProteinGroups[
    seq_len(
        top_n
    )
]

# Primary analysis does not have CI columns in the CSV.
# For C2, the primary effect is shown as a point only.
primary_forest <- primary_high_low %>%
    filter(
        PG.ProteinGroups %in% top_ids
    ) %>%
    transmute(
        PG.ProteinGroups,
        Dataset = "Primary",
        logFC = logFC,
        CI_low = NA_real_,
        CI_high = NA_real_
    )


run1_forest <- run_fits[["20260527"]]$results$High_vs_Low %>%
    filter(
        PG.ProteinGroups %in% top_ids
    ) %>%
    transmute(
        PG.ProteinGroups,
        Dataset = "20260527",
        logFC = logFC,
        CI_low = CI_low,
        CI_high = CI_high
    )


run2_forest <- run_fits[["20260717"]]$results$High_vs_Low %>%
    filter(
        PG.ProteinGroups %in% top_ids
    ) %>%
    transmute(
        PG.ProteinGroups,
        Dataset = "20260717",
        logFC = logFC,
        CI_low = CI_low,
        CI_high = CI_high
    )


forest_df <- bind_rows(
    primary_forest,
    run1_forest,
    run2_forest
)

forest_df <- v21_annotate(forest_df, PROTEIN_ANNOTATION)
forest_df$Display_label <- factor(
    forest_df$Display_label,
    levels = rev(PROTEIN_ANNOTATION$Display_label[match(top_ids, PROTEIN_ANNOTATION$PG.ProteinGroups)])
)

forest_df$PG.ProteinGroups <- factor(
    forest_df$PG.ProteinGroups,
    levels = rev(
        top_ids
    )
)

forest_df$Dataset <- factor(
    forest_df$Dataset,
    levels = c(
        "Primary",
        "20260527",
        "20260717"
    )
)


p_c2 <- ggplot(
    forest_df,
    aes(
        x = logFC,
        y = Display_label,
        colour = Dataset
    )
) +
    geom_vline(
        xintercept = 0,
        linetype = "dashed",
        linewidth = 0.45,
        colour = "#7A7A7A"
    ) +
    geom_errorbar(
        aes(
            xmin = CI_low,
            xmax = CI_high
        ),
        orientation = "y",
        position = position_dodge(
            width = 0.55
        ),
        width = 0,
        linewidth = 0.55,
        na.rm = TRUE
    ) +
    geom_point(
        position = position_dodge(
            width = 0.55
        ),
        size = 2.0
    ) +
    scale_colour_manual(
        values = c(
            Primary = "#222222",
            `20260527` = RUN_COLORS[
                "20260527"
            ],
            `20260717` = RUN_COLORS[
                "20260717"
            ]
        )
    ) +
    labs(
        title = "Top primary Long-vs-Short effects across acquisition-date strata",
        subtitle = "Within-date estimates include moderated 95% CIs; primary effect is a reference, not independent replication",
        x = "Long vs Short exposure log2 fold change",
        y = NULL,
        colour = NULL
    ) +
    theme_publication() +
    theme(
        legend.position = "top"
    )

save_plot(
    p_c2,
    "Figure_06c_top_primary_long_vs_short_forest",
    width = 7.8,
    height = 6.2
)


# ============================================================
# 13. Export forest data
# ============================================================

write.csv(
    forest_df,
    file.path(
        RUN_DIR,
        "Figure_06c_top_primary_long_vs_short_forest_source_data.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 14. Console
# ============================================================

cat(
    "\n============================================================\n"
)

cat(
    "06c ACQUISITION-DATE-STRATIFIED ROBUSTNESS COMPLETED\n"
)

cat(
    "============================================================\n"
)

cat(
    "\nAcquisition date x exposure group sample counts:\n"
)

print(
    run_counts,
    row.names = FALSE
)

cat(
    "\nWithin-date concordance metrics:\n"
)

print(
    concordance_metrics,
    row.names = FALSE
)

cat(
    "\nOutputs:\n",
    RUN_DIR,
    "\n",
    sep = ""
)

cat(
    "\nFigures:\n",
    FIG_DIR,
    "\n",
    sep = ""
)

cat(
    "\nPASS\n"
)


