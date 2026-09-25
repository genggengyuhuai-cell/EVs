# ============================================================
# 05 LIMMA DOSE ANALYSIS
#
# Plasma proteomics / Spectronaut PG.Quantity
#
# PRIMARY ANALYSIS
#   Protein set:
#     control / low / high EACH >= 70% detection
#     1434 proteins, 515 dose-defined samples
#
#   Input:
#     PRIMARY_dose_log2_expression.csv.gz
#
#   Missing values:
#     retained as NA; NO imputation; NO NA -> 0
#
#   Additional normalization:
#     NONE for the primary analysis
#
#   Model:
#     abundance ~ dose + environment
#
#   Main contrasts:
#     Low_vs_Control
#     High_vs_Control
#     High_vs_Low
#
# PRE-SPECIFIED SENSITIVITY / SECONDARY ANALYSES
#   1) Median-normalized sensitivity:
#        same protein set, same model
#   2) MS run-date proxy sensitivity:
#        abundance ~ dose + environment + MS_batch_proxy
#   3) Detection-threshold sensitivity:
#        50% and 80% dose-wise protein sets
#   4) Complete-case sensitivity:
#        proteins with no NA across all 515 samples
#   5) Dose x environment interaction:
#        six group means + difference-in-differences contrasts
#
# The deprecated control=0, low=1, high=2 continuous exposure trend is not
# part of this script. Exposure groups are categorical duration groups.
#
# IMPORTANT
#   - No ComBat.
#   - No removeBatchEffect() before differential analysis.
#   - No KNN / MinProb / QRILC for differential abundance.
#   - MS_batch_proxy is run date, not a confirmed technical batch ID.
#
# Statistical inference:
#   limma::lmFit()
#   limma::eBayes(trend = TRUE, robust = TRUE)
#   BH-adjusted P values are reported.
#
# Reporting cutoff used ONLY for summary counts:
#   FDR < 0.05
#   No hard |log2FC| cutoff is imposed in this script.
# ============================================================


rm(list = ls())
gc()


# ============================================================
# 1. Packages
# ============================================================

required_packages <- c(
    "limma",
    "statmod"
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
            "if (!requireNamespace('BiocManager', quietly=TRUE)) ",
            "install.packages('BiocManager')\n",
            "BiocManager::install('limma')\n",
            "install.packages('statmod')"
        )
    )
}

suppressPackageStartupMessages({
    library(limma)
})


# ============================================================
# 2. Script directory and paths
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


ANALYSIS_DIR <- get_script_dir()
source(file.path(ANALYSIS_DIR, "v21_common.R"))
v21_packages(c("svglite", "ragg"))

PRIMARY_EXPR_FILE <- file.path(
    ANALYSIS_DIR,
    "PRIMARY_dose_log2_expression.csv.gz"
)

MEDIAN_NORM_EXPR_FILE <- file.path(
    ANALYSIS_DIR,
    "SENSITIVITY_dose_log2_median_normalized_expression.csv.gz"
)

META_FILE <- file.path(
    ANALYSIS_DIR,
    "dose_defined_metadata.csv"
)

THRESHOLD_50_FILE <- file.path(
    ANALYSIS_DIR,
    "dose_expression_all_doses_ge50pct.csv.gz"
)

THRESHOLD_80_FILE <- file.path(
    ANALYSIS_DIR,
    "dose_expression_all_doses_ge80pct.csv.gz"
)

OUTPUT_DIR <- file.path(
    ANALYSIS_DIR,
    "limma_dose_analysis"
)

RESULT_DIR <- file.path(
    OUTPUT_DIR,
    "results"
)

ROBUSTNESS_DIR <- file.path(
    OUTPUT_DIR,
    "robustness"
)

DIAGNOSTIC_DIR <- file.path(
    OUTPUT_DIR,
    "diagnostics"
)

for (directory in c(
    OUTPUT_DIR,
    RESULT_DIR,
    ROBUSTNESS_DIR,
    DIAGNOSTIC_DIR
)) {
    dir.create(
        directory,
        recursive = TRUE,
        showWarnings = FALSE
    )
}


# ============================================================
# 3. Locked analysis settings
# ============================================================

DOSE_LEVELS <- c(
    "control",
    "low",
    "high"
)

ENVIRONMENT_LEVELS <- c(
    "high_stress",
    "high_temperature"
)

REPORT_FDR_CUTOFF <- 0.05

EBAYES_TREND <- TRUE
EBAYES_ROBUST <- TRUE


# ============================================================
# 4. Input checks
# ============================================================

required_files <- c(
    PRIMARY_EXPR_FILE,
    MEDIAN_NORM_EXPR_FILE,
    META_FILE,
    THRESHOLD_50_FILE,
    THRESHOLD_80_FILE
)

missing_files <- required_files[
    !file.exists(required_files)
]

if (length(missing_files) > 0) {
    stop(
        paste0(
            "Missing required input file(s):\n",
            paste(
                missing_files,
                collapse = "\n"
            )
        )
    )
}


# ============================================================
# 5. Read metadata
# ============================================================

meta <- read.csv(
    META_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE,
    na.strings = character(0)
)

required_meta_columns <- c(
    "UniqueSampleID",
    "TREAT1_clean",
    "condition",
    "group",
    "进样时间"
)

missing_meta_columns <- setdiff(
    required_meta_columns,
    colnames(meta)
)

if (length(missing_meta_columns) > 0) {
    stop(
        paste0(
            "Metadata missing column(s): ",
            paste(
                missing_meta_columns,
                collapse = ", "
            )
        )
    )
}

if (anyDuplicated(meta$UniqueSampleID) > 0) {
    stop(
        "UniqueSampleID is not unique in dose_defined_metadata.csv."
    )
}

if (!setequal(
    unique(meta$TREAT1_clean),
    DOSE_LEVELS
)) {
    stop(
        paste0(
            "TREAT1_clean must contain exactly: ",
            paste(
                DOSE_LEVELS,
                collapse = ", "
            )
        )
    )
}

environment_aliases <- c(
    "高海拔" = "high_stress",
    "湿热" = "high_temperature"
)

environment_labels <- as.character(meta$condition)
known_aliases <- environment_labels %in% names(environment_aliases)
environment_labels[known_aliases] <- unname(
    environment_aliases[environment_labels[known_aliases]]
)

if (!all(
    unique(environment_labels) %in% ENVIRONMENT_LEVELS
)) {
    stop(
        paste0(
            "Unexpected environment labels: ",
            paste(
                setdiff(
                    unique(environment_labels),
                    ENVIRONMENT_LEVELS
                ),
                collapse = ", "
            )
        )
    )
}

meta$dose <- factor(
    meta$TREAT1_clean,
    levels = DOSE_LEVELS
)

meta$environment <- factor(
    environment_labels,
    levels = ENVIRONMENT_LEVELS
)

meta$MS_batch_proxy <- factor(
    as.character(
        meta[["进样时间"]]
    )
)


# ============================================================
# 6. Expression reader
# ============================================================

read_expression_matrix <- function(
    file,
    expect_log2
) {

    dat <- read.csv(
        file,
        check.names = FALSE,
        stringsAsFactors = FALSE
    )

    if (!"PG.ProteinGroups" %in% colnames(dat)) {
        stop(
            paste0(
                "Missing PG.ProteinGroups in ",
                basename(file)
            )
        )
    }

    if (anyDuplicated(dat$PG.ProteinGroups) > 0) {
        stop(
            paste0(
                "Duplicated PG.ProteinGroups in ",
                basename(file)
            )
        )
    }

    sample_columns <- setdiff(
        colnames(dat),
        "PG.ProteinGroups"
    )

    if (!identical(
        sample_columns,
        meta$UniqueSampleID
    )) {
        stop(
            paste0(
                "Expression columns are not aligned with metadata in ",
                basename(file)
            )
        )
    }

    x <- as.matrix(
        dat[
            ,
            sample_columns,
            drop = FALSE
        ]
    )

    storage.mode(x) <- "double"

    rownames(x) <- dat$PG.ProteinGroups

    if (any(
        is.infinite(x),
        na.rm = TRUE
    )) {
        stop(
            paste0(
                "Infinite values found in ",
                basename(file)
            )
        )
    }

    if (!expect_log2) {

        bad <- is.finite(x) & x <= 0

        if (any(bad)) {
            stop(
                paste0(
                    "Non-positive finite value(s) found in ",
                    basename(file)
                )
            )
        }

        observed <- is.finite(x)

        x_log2 <- matrix(
            NA_real_,
            nrow = nrow(x),
            ncol = ncol(x),
            dimnames = dimnames(x)
        )

        x_log2[observed] <- log2(
            x[observed]
        )

        x <- x_log2
    }

    list(
        expression = x,
        proteins = rownames(x)
    )
}


# ============================================================
# 7. Read analysis matrices
# ============================================================

primary_obj <- read_expression_matrix(
    PRIMARY_EXPR_FILE,
    expect_log2 = TRUE
)

primary_expr <- primary_obj$expression

median_norm_obj <- read_expression_matrix(
    MEDIAN_NORM_EXPR_FILE,
    expect_log2 = TRUE
)

median_norm_expr <- median_norm_obj$expression

threshold50_obj <- read_expression_matrix(
    THRESHOLD_50_FILE,
    expect_log2 = FALSE
)

threshold50_expr <- threshold50_obj$expression

threshold80_obj <- read_expression_matrix(
    THRESHOLD_80_FILE,
    expect_log2 = FALSE
)

threshold80_expr <- threshold80_obj$expression


# ============================================================
# 8. Hard validation of primary set
# ============================================================

if (nrow(primary_expr) != 1434) {
    stop(
        paste0(
            "Primary matrix contains ",
            nrow(primary_expr),
            " proteins; expected 1434."
        )
    )
}

if (ncol(primary_expr) != 515) {
    stop(
        paste0(
            "Primary matrix contains ",
            ncol(primary_expr),
            " samples; expected 515."
        )
    )
}

if (!identical(
    dim(primary_expr),
    dim(median_norm_expr)
)) {
    stop(
        "Primary and median-normalized matrices have different dimensions."
    )
}

if (!identical(
    rownames(primary_expr),
    rownames(median_norm_expr)
)) {
    stop(
        "Primary and median-normalized matrices have different proteins/order."
    )
}

if (!identical(
    is.na(primary_expr),
    is.na(median_norm_expr)
)) {
    stop(
        "Primary and median-normalized matrices have different NA patterns."
    )
}

primary_missing_pct <- mean(
    is.na(primary_expr)
) * 100

if (abs(
    primary_missing_pct - 6.288744
) > 0.02) {
    warning(
        paste0(
            "Primary missingness is ",
            round(
                primary_missing_pct,
                4
            ),
            "%; previous diagnostic was approximately 6.29%."
        )
    )
}


# ============================================================
# 9. Design helpers
# ============================================================

assert_full_rank <- function(
    design,
    name
) {

    rank_value <- qr(
        design
    )$rank

    if (rank_value != ncol(design)) {
        stop(
            paste0(
                "Design matrix is not full rank: ",
                name,
                " (rank ",
                rank_value,
                " / ",
                ncol(design),
                ")."
            )
        )
    }

    invisible(
        TRUE
    )
}


make_primary_design <- function() {

    design <- model.matrix(
        ~ 0 + dose + environment,
        data = meta
    )

    colnames(design) <- make.names(
        colnames(design)
    )

    assert_full_rank(
        design,
        "primary: dose + environment"
    )

    design
}


make_batch_design <- function() {

    design <- model.matrix(
        ~ 0 + dose + environment + MS_batch_proxy,
        data = meta
    )

    colnames(design) <- make.names(
        colnames(design)
    )

    assert_full_rank(
        design,
        "batch sensitivity: dose + environment + MS_batch_proxy"
    )

    design
}


make_interaction_design <- function() {

    meta$group6 <- factor(
        paste(
            meta$dose,
            meta$environment,
            sep = "__"
        )
    )

    design <- model.matrix(
        ~ 0 + group6,
        data = meta
    )

    colnames(design) <- sub(
        "^group6",
        "",
        colnames(design)
    )

    colnames(design) <- make.names(
        colnames(design)
    )

    assert_full_rank(
        design,
        "dose x environment six-group model"
    )

    design
}


primary_design <- make_primary_design()
batch_design <- make_batch_design()
interaction_design <- make_interaction_design()


# ============================================================
# 10. Primary contrast matrix
# ============================================================

required_primary_columns <- c(
    "dosecontrol",
    "doselow",
    "dosehigh"
)

missing_primary_columns <- setdiff(
    required_primary_columns,
    colnames(primary_design)
)

if (length(missing_primary_columns) > 0) {
    stop(
        paste0(
            "Primary design missing dose column(s): ",
            paste(
                missing_primary_columns,
                collapse = ", "
            )
        )
    )
}

primary_contrasts <- makeContrasts(
    Low_vs_Control =
        doselow - dosecontrol,
    High_vs_Control =
        dosehigh - dosecontrol,
    High_vs_Low =
        dosehigh - doselow,
    levels = primary_design
)


# ============================================================
# 11. Core limma runner
# ============================================================

run_limma_contrasts <- function(
    expression_matrix,
    design,
    contrast_matrix,
    analysis_name,
    output_subdir
) {

    output_path <- file.path(
        RESULT_DIR,
        output_subdir
    )

    dir.create(
        output_path,
        recursive = TRUE,
        showWarnings = FALSE
    )

    fit <- lmFit(
        expression_matrix,
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

    results <- list()

    for (contrast_name in colnames(
        contrast_matrix
    )) {

        tab <- topTable(
            fit,
            coef = contrast_name,
            number = Inf,
            adjust.method = "BH",
            sort.by = "P"
        )

        tab$PG.ProteinGroups <- rownames(tab)

        tab$Contrast <- contrast_name

        tab$Significant_FDR_0.05 <- (
            !is.na(tab$adj.P.Val)
            &
            tab$adj.P.Val < REPORT_FDR_CUTOFF
        )

        tab <- tab[
            ,
            c(
                "PG.ProteinGroups",
                "Contrast",
                "logFC",
                "AveExpr",
                "t",
                "P.Value",
                "adj.P.Val",
                "B",
                "Significant_FDR_0.05"
            ),
            drop = FALSE
        ]

        rownames(tab) <- NULL

        results[[contrast_name]] <- tab

        write.csv(
            tab,
            file.path(
                output_path,
                paste0(
                    analysis_name,
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
            output_path,
            paste0(
                analysis_name,
                "__fit.rds"
            )
        )
    )

    v22_draw(function() {
        par(family = "sans", ps = 9, cex.axis = 0.85, cex.lab = 0.9,
            cex.main = 1, mar = c(4, 4, 4, 1))
        plotSA(fit, main = paste(strwrap(paste0(analysis_name, ": residual SD trend"), 55), collapse = "\n"))
    }, file.path(DIAGNOSTIC_DIR, "figures_nature_v2.2"), paste0(analysis_name, "__plotSA"))

    list(
        fit = fit,
        results = results
    )
}


# ============================================================
# 12. PRIMARY ANALYSIS
#
# log2(PG.Quantity)
# no additional normalization
# model: dose + environment
# ============================================================

primary_fit <- run_limma_contrasts(
    expression_matrix = primary_expr,
    design = primary_design,
    contrast_matrix = primary_contrasts,
    analysis_name = "PRIMARY_log2_dose_environment",
    output_subdir = "01_PRIMARY"
)


# ============================================================
# 13. SENSITIVITY 1
#
# sample-wise median normalized log2 matrix
# same model and contrasts
# ============================================================

median_norm_fit <- run_limma_contrasts(
    expression_matrix = median_norm_expr,
    design = primary_design,
    contrast_matrix = primary_contrasts,
    analysis_name = "SENS_normalization_median",
    output_subdir = "02_SENS_median_normalization"
)


# ============================================================
# 14. SENSITIVITY 2
#
# log2 primary matrix
# model includes MS run-date proxy
# ============================================================

batch_contrasts <- makeContrasts(
    Low_vs_Control =
        doselow - dosecontrol,
    High_vs_Control =
        dosehigh - dosecontrol,
    High_vs_Low =
        dosehigh - doselow,
    levels = batch_design
)

batch_fit <- run_limma_contrasts(
    expression_matrix = primary_expr,
    design = batch_design,
    contrast_matrix = batch_contrasts,
    analysis_name = "SENS_add_MS_batch_proxy",
    output_subdir = "03_SENS_MS_batch_proxy"
)


# ============================================================
# 15. SENSITIVITY 3
#
# detection threshold >=50%
# log2 only
# same primary model
# ============================================================

threshold50_fit <- run_limma_contrasts(
    expression_matrix = threshold50_expr,
    design = primary_design,
    contrast_matrix = primary_contrasts,
    analysis_name = "SENS_detection_threshold_50pct",
    output_subdir = "04_SENS_threshold_50pct"
)


# ============================================================
# 16. SENSITIVITY 4
#
# detection threshold >=80%
# log2 only
# same primary model
# ============================================================

threshold80_fit <- run_limma_contrasts(
    expression_matrix = threshold80_expr,
    design = primary_design,
    contrast_matrix = primary_contrasts,
    analysis_name = "SENS_detection_threshold_80pct",
    output_subdir = "05_SENS_threshold_80pct"
)


# ============================================================
# 17. SENSITIVITY 5
#
# complete-case proteins within primary 70% set
# no missing values across all 515 samples
# ============================================================

complete_case_mask <- rowSums(
    is.na(primary_expr)
) == 0

complete_case_expr <- primary_expr[
    complete_case_mask,
    ,
    drop = FALSE
]

write.csv(
    data.frame(
        PG.ProteinGroups = rownames(
            complete_case_expr
        ),
        stringsAsFactors = FALSE
    ),
    file.path(
        ROBUSTNESS_DIR,
        "complete_case_proteins.csv"
    ),
    row.names = FALSE
)

complete_case_fit <- run_limma_contrasts(
    expression_matrix = complete_case_expr,
    design = primary_design,
    contrast_matrix = primary_contrasts,
    analysis_name = "SENS_complete_case",
    output_subdir = "06_SENS_complete_case"
)


# ============================================================
# 18. SECONDARY: dose x environment interaction
#
# Six group means:
#   control__high_stress
#   low__high_stress
#   high__high_stress
#   control__high_temperature
#   low__high_temperature
#   high__high_temperature
#
# Interaction contrasts are difference-in-differences.
# ============================================================

interaction_required <- make.names(
    c(
        "control__high_stress",
        "low__high_stress",
        "high__high_stress",
        "control__high_temperature",
        "low__high_temperature",
        "high__high_temperature"
    )
)

missing_interaction_columns <- setdiff(
    interaction_required,
    colnames(interaction_design)
)

if (length(missing_interaction_columns) > 0) {
    stop(
        paste0(
            "Interaction design missing group(s): ",
            paste(
                missing_interaction_columns,
                collapse = ", "
            )
        )
    )
}

interaction_contrasts <- makeContrasts(
    Low_vs_Control_in_HighStress =
        low__high_stress -
        control__high_stress,

    High_vs_Control_in_HighStress =
        high__high_stress -
        control__high_stress,

    Low_vs_Control_in_HighTemperature =
        low__high_temperature -
        control__high_temperature,

    High_vs_Control_in_HighTemperature =
        high__high_temperature -
        control__high_temperature,

    Interaction_Low =
        (
            low__high_temperature -
            control__high_temperature
        )
        -
        (
            low__high_stress -
            control__high_stress
        ),

    Interaction_High =
        (
            high__high_temperature -
            control__high_temperature
        )
        -
        (
            high__high_stress -
            control__high_stress
        ),

    levels = interaction_design
)

interaction_fit <- run_limma_contrasts(
    expression_matrix = primary_expr,
    design = interaction_design,
    contrast_matrix = interaction_contrasts,
    analysis_name = "SECONDARY_dose_environment_interaction",
    output_subdir = "08_SECONDARY_interaction"
)


# ============================================================
# 20. Robustness comparison helpers
# ============================================================

compare_result_tables <- function(
    reference_table,
    comparison_table,
    reference_name,
    comparison_name,
    contrast_name
) {

    ref <- reference_table[
        ,
        c(
            "PG.ProteinGroups",
            "logFC",
            "adj.P.Val"
        ),
        drop = FALSE
    ]

    cmp <- comparison_table[
        ,
        c(
            "PG.ProteinGroups",
            "logFC",
            "adj.P.Val"
        ),
        drop = FALSE
    ]

    colnames(ref) <- c(
        "PG.ProteinGroups",
        "logFC_ref",
        "FDR_ref"
    )

    colnames(cmp) <- c(
        "PG.ProteinGroups",
        "logFC_cmp",
        "FDR_cmp"
    )

    merged <- merge(
        ref,
        cmp,
        by = "PG.ProteinGroups",
        all = FALSE,
        sort = FALSE
    )

    complete_logfc <- is.finite(
        merged$logFC_ref
    ) & is.finite(
        merged$logFC_cmp
    )

    if (sum(complete_logfc) >= 3) {

        pearson <- cor(
            merged$logFC_ref[
                complete_logfc
            ],
            merged$logFC_cmp[
                complete_logfc
            ],
            method = "pearson"
        )

        spearman <- cor(
            merged$logFC_ref[
                complete_logfc
            ],
            merged$logFC_cmp[
                complete_logfc
            ],
            method = "spearman"
        )

        direction_concordance <- mean(
            sign(
                merged$logFC_ref[
                    complete_logfc
                ]
            )
            ==
            sign(
                merged$logFC_cmp[
                    complete_logfc
                ]
            )
        )

    } else {

        pearson <- NA_real_
        spearman <- NA_real_
        direction_concordance <- NA_real_
    }

    sig_ref <- (
        !is.na(
            merged$FDR_ref
        )
        &
        merged$FDR_ref < REPORT_FDR_CUTOFF
    )

    sig_cmp <- (
        !is.na(
            merged$FDR_cmp
        )
        &
        merged$FDR_cmp < REPORT_FDR_CUTOFF
    )

    overlap <- sum(
        sig_ref & sig_cmp
    )

    union_count <- sum(
        sig_ref | sig_cmp
    )

    jaccard <- if (
        union_count > 0
    ) {
        overlap / union_count
    } else {
        NA_real_
    }

    data.frame(
        Contrast = contrast_name,
        Reference = reference_name,
        Comparison = comparison_name,
        Shared_proteins = nrow(
            merged
        ),
        Pearson_logFC = pearson,
        Spearman_logFC = spearman,
        Direction_concordance = direction_concordance,
        Significant_ref_FDR_0.05 = sum(
            sig_ref
        ),
        Significant_cmp_FDR_0.05 = sum(
            sig_cmp
        ),
        Significant_overlap = overlap,
        Jaccard_FDR_0.05 = jaccard,
        stringsAsFactors = FALSE
    )
}


# ============================================================
# 21. Robustness comparisons against PRIMARY
# ============================================================

robustness_rows <- list()

comparison_analyses <- list(
    Median_normalization =
        median_norm_fit$results,
    MS_batch_proxy =
        batch_fit$results,
    Threshold_50pct =
        threshold50_fit$results,
    Threshold_80pct =
        threshold80_fit$results,
    Complete_case =
        complete_case_fit$results
)

counter <- 1

for (analysis_name in names(
    comparison_analyses
)) {

    comparison_results <- comparison_analyses[[analysis_name]]

    for (contrast_name in colnames(
        primary_contrasts
    )) {

        robustness_rows[[counter]] <- compare_result_tables(
            reference_table =
                primary_fit$results[[contrast_name]],
            comparison_table =
                comparison_results[[contrast_name]],
            reference_name =
                "PRIMARY_log2_dose_environment",
            comparison_name =
                analysis_name,
            contrast_name =
                contrast_name
        )

        counter <- counter + 1
    }
}

robustness_summary <- do.call(
    rbind,
    robustness_rows
)

write.csv(
    robustness_summary,
    file.path(
        ROBUSTNESS_DIR,
        "robustness_summary.csv"
    ),
    row.names = FALSE,
    na = ""
)


# ============================================================
# 22. Primary result summary
# ============================================================

primary_summary_rows <- lapply(
    colnames(
        primary_contrasts
    ),
    function(
        contrast_name
    ) {

        tab <- primary_fit$results[[contrast_name]]

        data.frame(
            Contrast = contrast_name,
            Proteins_tested = nrow(
                tab
            ),
            FDR_lt_0.05 = sum(
                tab$Significant_FDR_0.05,
                na.rm = TRUE
            ),
            Positive_logFC_FDR_lt_0.05 = sum(
                tab$Significant_FDR_0.05
                &
                tab$logFC > 0,
                na.rm = TRUE
            ),
            Negative_logFC_FDR_lt_0.05 = sum(
                tab$Significant_FDR_0.05
                &
                tab$logFC < 0,
                na.rm = TRUE
            ),
            stringsAsFactors = FALSE
        )
    }
)

primary_summary <- do.call(
    rbind,
    primary_summary_rows
)

write.csv(
    primary_summary,
    file.path(
        OUTPUT_DIR,
        "PRIMARY_summary.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 23. Save design matrices and metadata snapshot
# ============================================================

write.csv(
    data.frame(
        UniqueSampleID =
            meta$UniqueSampleID,
        primary_design,
        check.names = FALSE
    ),
    file.path(
        OUTPUT_DIR,
        "PRIMARY_design_matrix.csv"
    ),
    row.names = FALSE
)

write.csv(
    data.frame(
        UniqueSampleID =
            meta$UniqueSampleID,
        batch_design,
        check.names = FALSE
    ),
    file.path(
        OUTPUT_DIR,
        "SENS_batch_design_matrix.csv"
    ),
    row.names = FALSE
)

write.csv(
    meta,
    file.path(
        OUTPUT_DIR,
        "analysis_metadata_snapshot.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 24. Analysis manifest
# ============================================================

manifest <- data.frame(
    Item = c(
        "Primary proteins",
        "Primary samples",
        "Primary residual missingness (%)",
        "Primary input scale",
        "Primary additional normalization",
        "Primary missing-value imputation",
        "Primary model",
        "Primary eBayes trend",
        "Primary eBayes robust",
        "Summary FDR cutoff",
        "Complete-case proteins",
        "Threshold 50% proteins",
        "Threshold 80% proteins"
    ),
    Value = c(
        nrow(
            primary_expr
        ),
        ncol(
            primary_expr
        ),
        sprintf(
            "%.4f",
            primary_missing_pct
        ),
        "log2(PG.Quantity)",
        "None",
        "None",
        "dose + environment",
        EBAYES_TREND,
        EBAYES_ROBUST,
        REPORT_FDR_CUTOFF,
        nrow(
            complete_case_expr
        ),
        nrow(
            threshold50_expr
        ),
        nrow(
            threshold80_expr
        )
    ),
    stringsAsFactors = FALSE
)

write.csv(
    manifest,
    file.path(
        OUTPUT_DIR,
        "analysis_manifest.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 25. Console output
# ============================================================

cat(
    "\n============================================================\n"
)

cat(
    "LIMMA DOSE ANALYSIS COMPLETED\n"
)

cat(
    "============================================================\n"
)

cat(
    "Primary proteins        : ",
    nrow(
        primary_expr
    ),
    "\n",
    sep = ""
)

cat(
    "Primary samples         : ",
    ncol(
        primary_expr
    ),
    "\n",
    sep = ""
)

cat(
    "Primary missingness (%) : ",
    sprintf(
        "%.2f",
        primary_missing_pct
    ),
    "\n",
    sep = ""
)

cat(
    "Primary input           : log2(PG.Quantity)\n"
)

cat(
    "Extra normalization     : NONE\n"
)

cat(
    "Imputation              : NONE\n"
)

cat(
    "Primary model           : dose + environment\n"
)

cat(
    "eBayes                  : trend=TRUE, robust=TRUE\n"
)

cat(
    "\nPrimary contrasts:\n"
)

print(
    primary_summary,
    row.names = FALSE
)

cat(
    "\nComplete-case proteins  : ",
    nrow(
        complete_case_expr
    ),
    "\n",
    sep = ""
)

cat(
    "\nRobustness summary:\n"
)

print(
    robustness_summary,
    row.names = FALSE
)

cat(
    "\nOutput directory:\n"
)

cat(
    OUTPUT_DIR,
    "\n"
)

cat(
    "\nPASS: all pre-specified primary, sensitivity, and secondary analyses completed.\n"
)
