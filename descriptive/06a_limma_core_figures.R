# ============================================================
# 06a CORE PUBLICATION FIGURES
#
# Plasma proteomics exposure-duration group comparisons
#
# Purpose:
#   Produce polished core figures from the LOCKED primary analysis.
#
# Reads existing outputs only.
# Does NOT refit limma or alter the primary analysis.
#
# Main outputs:
#   Figure_A1_sample_structure
#   Figure_A2_PCA
#   Figure_A2b_complete_case_UMAP + Figure_A2c_PCA_UMAP_overview
#   Figure_A3_primary_volcano
#   Figure_A4_top12_proteins
#   Figure_A5_top30_heatmap
#
# Primary analysis:
#   1434 proteins x 515 samples
#   log2(PG.Quantity)
#   no additional normalization
#   NA retained
#   limma: dose + environment
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
    "ggrepel",
    "pheatmap",
    "uwot",
    "ragg",
    "svglite"
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
    library(ggrepel)
    library(pheatmap)
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

    normalizePath(
        getwd(),
        winslash = "/",
        mustWork = TRUE
    )
}


ROOT_DIR <- get_script_dir()
source(file.path(ROOT_DIR, "v21_common.R"))

LIMMA_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis"
)

RESULT_DIR <- file.path(
    LIMMA_DIR,
    "results"
)

FIG_DIR <- file.path(
    LIMMA_DIR,
    "figures_final",
    "06a_core_v2.2"
)

# New versioned destination; refuse to overwrite any historical or partial run.
FIG_DIR <- v21_output(FIG_DIR)


SAMPLE_DIAG_FILE <- file.path(
    ROOT_DIR,
    "normalization_sample_diagnostics.csv"
)

PCA_FILE <- file.path(
    ROOT_DIR,
    "complete_case_PCA_scores.csv"
)

PRIMARY_EXPR_FILE <- file.path(
    ROOT_DIR,
    "PRIMARY_dose_log2_expression.csv.gz"
)

META_FILE <- file.path(
    ROOT_DIR,
    "dose_defined_metadata.csv"
)

PRIMARY_RESULT_DIR <- file.path(
    RESULT_DIR,
    "01_PRIMARY"
)


primary_files <- c(
    Low_vs_Control = file.path(
        PRIMARY_RESULT_DIR,
        "PRIMARY_log2_dose_environment__Low_vs_Control.csv"
    ),
    High_vs_Control = file.path(
        PRIMARY_RESULT_DIR,
        "PRIMARY_log2_dose_environment__High_vs_Control.csv"
    ),
    High_vs_Low = file.path(
        PRIMARY_RESULT_DIR,
        "PRIMARY_log2_dose_environment__High_vs_Low.csv"
    )
)


required_files <- c(
    SAMPLE_DIAG_FILE,
    PCA_FILE,
    PRIMARY_EXPR_FILE,
    META_FILE,
    unname(primary_files)
)

missing_files <- required_files[
    !file.exists(required_files)
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
# 3. Locked display settings
# ============================================================

DOSE_LEVELS <- c(
    "control",
    "low",
    "high"
)

ENV_LEVELS <- c(
    "high_stress",
    "high_temperature"
)

DOSE_LABELS <- c(
    control = "Control",
    low = "Short exposure",
    high = "Long exposure"
)

ENV_LABELS <- c(
    high_stress = "High stress",
    high_temperature = "High temperature"
)

DOSE_COLORS <- c(
    control = "#4D4D4D",
    low = "#3B82F6",
    high = "#D97706"
)

ENV_COLORS <- c(
    high_stress = "#7C3AED",
    high_temperature = "#0F9D8A"
)

STATUS_COLORS <- c(
    Higher = "#C0392B",
    Lower = "#2C6E9B",
    `Not significant` = "#B8B8B8"
)

RUN_PALETTE <- c(
    "20250913" = "#4E79A7",
    "20250914" = "#F28E2B",
    "20251001" = "#E15759",
    "20251026" = "#76B7B2",
    "20251104" = "#59A14F",
    "20251107" = "#EDC948",
    "20260527" = "#B07AA1",
    "20260717" = "#9C755F"
)


# Nature figure contract: R backend, white quantitative panels, >=6 pt text.
# Existing panel logic is retained; display settings come from the shared contract.
theme_publication <- function(base_size = 7) v21_theme(base_size)


save_plot <- function(plot_object, filename, width = 7.2, height = 4.8) {
    v21_save(plot_object, FIG_DIR, filename,
             if (is.data.frame(plot_object$data)) plot_object$data else NULL,
             width_mm = 183, height_mm = 125)
}


# ============================================================
# 4. Sample-structure data
# ============================================================

sample_diag <- read.csv(
    SAMPLE_DIAG_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)

sample_diag$TREAT1_clean <- factor(
    sample_diag$TREAT1_clean,
    levels = DOSE_LEVELS
)

sample_diag$condition <- factor(
    sample_diag$condition,
    levels = ENV_LEVELS
)

sample_diag$MS_batch_proxy <- factor(
    as.character(
        sample_diag$MS_batch_proxy
    ),
    levels = sort(
        unique(
            as.character(
                sample_diag$MS_batch_proxy
            )
        )
    )
)


# ============================================================
# 5. Figure A1: sample structure
# ============================================================

p_a1 <- ggplot(
    sample_diag,
    aes(
        x = TREAT1_clean,
        y = log2_median,
        fill = TREAT1_clean
    )
) +
    geom_violin(
        width = 0.90,
        trim = TRUE,
        alpha = 0.18,
        colour = NA
    ) +
    geom_boxplot(
        width = 0.34,
        outlier.shape = NA,
        linewidth = 0.45,
        colour = "black",
        alpha = 0.80
    ) +
    geom_jitter(
        na.rm = TRUE,
        aes(
            colour = TREAT1_clean
        ),
        width = 0.11,
        size = 0.75,
        alpha = 0.30,
        show.legend = FALSE
    ) +
    scale_fill_manual(
        values = DOSE_COLORS,
        guide = "none"
    ) +
    scale_colour_manual(
        values = DOSE_COLORS,
        guide = "none"
    ) +
    scale_x_discrete(
        labels = DOSE_LABELS
    ) +
    labs(
        title = "a  Sample median by exposure group",
        x = NULL,
        y = "Median log2 abundance"
    ) +
    theme_publication()


p_b1 <- ggplot(
    sample_diag,
    aes(
        x = condition,
        y = log2_median,
        fill = condition
    )
) +
    geom_violin(
        width = 0.90,
        trim = TRUE,
        alpha = 0.18,
        colour = NA
    ) +
    geom_boxplot(
        width = 0.34,
        outlier.shape = NA,
        linewidth = 0.45,
        colour = "black",
        alpha = 0.80
    ) +
    geom_jitter(
        na.rm = TRUE,
        aes(
            colour = condition
        ),
        width = 0.11,
        size = 0.75,
        alpha = 0.28,
        show.legend = FALSE
    ) +
    scale_fill_manual(
        values = ENV_COLORS,
        guide = "none"
    ) +
    scale_colour_manual(
        values = ENV_COLORS,
        guide = "none"
    ) +
    scale_x_discrete(
        labels = ENV_LABELS
    ) +
    labs(
        title = "b  Sample median by environment",
        x = NULL,
        y = "Median log2 abundance"
    ) +
    theme_publication()


p_c1 <- ggplot(
    sample_diag,
    aes(
        x = MS_batch_proxy,
        y = log2_median
    )
) +
    geom_boxplot(
        aes(
            fill = MS_batch_proxy
        ),
        width = 0.58,
        outlier.shape = NA,
        linewidth = 0.42,
        colour = "black",
        alpha = 0.70
    ) +
    geom_jitter(
        na.rm = TRUE,
        aes(
            colour = MS_batch_proxy
        ),
        width = 0.10,
        size = 0.65,
        alpha = 0.28,
        show.legend = FALSE
    ) +
    scale_fill_manual(
        values = RUN_PALETTE,
        guide = "none"
    ) +
    scale_colour_manual(
        values = RUN_PALETTE,
        guide = "none"
    ) +
    labs(
        title = "c  Sample median by MS run-date proxy",
        x = "MS run-date proxy",
        y = "Median log2 abundance"
    ) +
    theme_publication() +
    theme(
        axis.text.x = element_text(
            angle = 38,
            hjust = 1,
            vjust = 1
        )
    )


p_d1 <- ggplot(
    sample_diag,
    aes(
        x = observed_proteins,
        y = log2_median,
        colour = condition,
        shape = TREAT1_clean
    )
) +
    geom_point(
        size = 1.5,
        alpha = 0.52
    ) +
    geom_smooth(
        aes(
            group = condition,
            colour = condition
        ),
        method = "lm",
        formula = y ~ x,
        se = FALSE,
        linewidth = 0.75,
        show.legend = FALSE
    ) +
    scale_colour_manual(
        values = ENV_COLORS,
        labels = ENV_LABELS
    ) +
    scale_shape_manual(
        values = c(
            control = 16,
            low = 17,
            high = 15
        ),
        labels = DOSE_LABELS
    ) +
    labs(
        title = "D  Detection depth and sample median",
        x = "Observed proteins in primary set",
        y = "Median log2 abundance",
        colour = "Environment",
        shape = "Exposure duration"
    ) +
    theme_publication()


# Each scientific question has its own canvas and file.
for (name in c("sample_median_exposure", "sample_median_environment", "sample_median_date", "sample_structure")) {
    plots <- list(sample_median_exposure = p_a1, sample_median_environment = p_b1,
                  sample_median_date = p_c1, sample_structure = p_d1)
    save_plot(plots[[name]], paste0("Figure_A1_", name))
}

# 6. Figure A2: PCA
# ============================================================

# Read current matrix to establish actual complete-case feature provenance.
embedding_input <- v21_read(PRIMARY_EXPR_FILE, "PG.ProteinGroups", "PG.ProteinGroups")
v21_ids(names(embedding_input)[-1], "Embedding sample IDs")
embedding_all <- as.matrix(embedding_input[-1])
if (!is.numeric(embedding_all)) stop("Embedding matrix must be numeric.")
embedding_complete <- rowSums(!is.finite(embedding_all)) == 0L
embedding_n <- sum(embedding_complete)
if (embedding_n < 2L) stop("Insufficient complete-case proteins for PCA/UMAP.")
pca_subtitle <- paste("Complete-case PCA;", embedding_n, "proteins; no imputation")

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

numeric_pca_columns <- c(
    "PC1",
    "PC2",
    "PC1_variance_pct",
    "PC2_variance_pct"
)

if (!all(vapply(pca[numeric_pca_columns], is.numeric, logical(1)))) {
    stop("PCA score and variance columns must be numeric.")
}

v21_ids(pca$UniqueSampleID, "PCA sample IDs")
if (!setequal(pca$UniqueSampleID, names(embedding_input)[-1])) stop("PCA/expression sample-ID mismatch.")
# Verify cached scores against the same centered, unscaled feature set. This is
# QC-only PCA verification, not an abundance model fit. No cached file is changed.
pca_check <- prcomp(t(embedding_all[embedding_complete, , drop = FALSE]), center = TRUE, scale. = FALSE)
if (!identical(rownames(pca_check$x), names(embedding_input)[-1])) {
    stop("PCA score row names do not match the primary expression sample order.")
}
pca_order <- match(names(embedding_input)[-1], pca$UniqueSampleID)
for (pc in c("PC1", "PC2")) {
    old <- pca[[pc]][pca_order]
    current <- pca_check$x[, pc]
    tolerance <- 1e-6 * max(1, abs(current))
    same_axis <- all(is.finite(old)) &&
        (max(abs(old - current)) <= tolerance || max(abs(old + current)) <= tolerance)
    if (!same_axis) stop("Cached PCA differs from current complete-case feature set; review diagnostics.")
}
pca_variance_current <- pca_check$sdev^2 / sum(pca_check$sdev^2) * 100
for (i in 1:2) {
    saved_pct <- pca[[paste0("PC", i, "_variance_pct")]]
    if (any(!is.finite(saved_pct)) || any(abs(saved_pct - pca_variance_current[i]) > 1e-6))
        stop("Cached PCA variance labels differ from current input.")
}
write.csv(data.frame(Protein = embedding_input$PG.ProteinGroups[embedding_complete]),
          file.path(FIG_DIR, "Figure_A2_PCA_proteins.csv"), row.names = FALSE)
write.csv(pca, file.path(FIG_DIR, "Figure_A2_PCA_source_data.csv"), row.names = FALSE)

pca$TREAT1_clean <- factor(
    pca$TREAT1_clean,
    levels = DOSE_LEVELS
)

pca$condition <- factor(
    pca$condition,
    levels = ENV_LEVELS
)

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


p_a2 <- ggplot(
    pca,
    aes(
        x = PC1,
        y = PC2,
        colour = TREAT1_clean,
        shape = TREAT1_clean
    )
) +
    geom_point(
        size = 1.7,
        alpha = 0.62
    ) +
    stat_ellipse(
        aes(
            group = TREAT1_clean,
            colour = TREAT1_clean
        ),
        type = "norm",
        level = 0.80,
        linewidth = 0.55,
        alpha = 0.8,
        show.legend = FALSE
    ) +
    scale_colour_manual(
        values = DOSE_COLORS,
        labels = DOSE_LABELS
    ) +
    scale_shape_manual(
        values = c(
            control = 16,
            low = 17,
            high = 15
        ),
        labels = DOSE_LABELS
    ) +
    labs(
        title = "a  Exposure duration",
        subtitle = pca_subtitle,
        x = pc1_label,
        y = pc2_label,
        colour = "Exposure duration",
        shape = "Exposure duration"
    ) +
    theme_publication()


p_b2 <- ggplot(
    pca,
    aes(
        x = PC1,
        y = PC2,
        colour = condition,
        shape = condition
    )
) +
    geom_point(
        size = 1.7,
        alpha = 0.62
    ) +
    stat_ellipse(
        aes(
            group = condition,
            colour = condition
        ),
        type = "norm",
        level = 0.80,
        linewidth = 0.60,
        alpha = 0.8,
        show.legend = FALSE
    ) +
    scale_colour_manual(
        values = ENV_COLORS,
        labels = ENV_LABELS
    ) +
    scale_shape_manual(
        values = c(
            high_stress = 16,
            high_temperature = 17
        ),
        labels = ENV_LABELS
    ) +
    labs(
        title = "b  Environment",
        subtitle = pca_subtitle,
        x = pc1_label,
        y = pc2_label,
        colour = "Environment",
        shape = "Environment"
    ) +
    theme_publication()


p_c2 <- ggplot(
    pca,
    aes(
        x = PC1,
        y = PC2,
        colour = MS_batch_proxy
    )
) +
    geom_point(
        size = 1.55,
        alpha = 0.65
    ) +
    scale_colour_manual(
        values = RUN_PALETTE,
        drop = FALSE
    ) +
    labs(
        title = "c  MS run-date proxy",
        subtitle = pca_subtitle,
        x = pc1_label,
        y = pc2_label,
        colour = "Run date"
    ) +
    theme_publication()


for (name in c("exposure", "environment", "acquisition_date")) {
    plots <- list(exposure = p_a2, environment = p_b2, acquisition_date = p_c2)
    save_plot(plots[[name]], paste0("Figure_A2_PCA_", name))
}

# 7. Read primary results
# ============================================================

read_primary_result <- function(
    contrast_name
) {

    file <- primary_files[
        contrast_name
    ]

    dat <- read.csv(
        file,
        check.names = FALSE,
        stringsAsFactors = FALSE
    )

    dat$Contrast <- contrast_name

    dat
}


primary_results <- lapply(
    names(primary_files),
    read_primary_result
)

names(primary_results) <- names(
    primary_files
)


# ============================================================
# 8. Figure A3: polished volcano plots
# ============================================================

make_volcano <- function(
    dat,
    panel_title
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

    significant_n <- sum(
        !is.na(
            dat$adj.P.Val
        )
        &
        dat$adj.P.Val < 0.05
    )

    label_data <- dat %>%
        filter(
            !is.na(
                adj.P.Val
            )
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
            n = 8
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
                colour = Status
            ),
            size = 1.25,
            alpha = 0.72
        ) +
        geom_hline(
            yintercept = -log10(
                0.05
            ),
            linetype = "dashed",
            linewidth = 0.45,
            colour = "#555555"
        ) +
        geom_vline(
            xintercept = 0,
            linewidth = 0.35,
            colour = "#555555"
        ) +
        geom_label_repel(
            data = label_data,
            aes(
                label = PG.ProteinGroups
            ),
            size = 2.55,
            box.padding = 0.32,
            point.padding = 0.18,
            min.segment.length = 0,
            segment.size = 0.3,
            label.size = 0.18,
            fill = alpha(
                "white",
                0.90
            ),
            max.overlaps = Inf,
            show.legend = FALSE
        ) +
        annotate(
            "text",
            x = Inf,
            y = Inf,
            label = paste0(
                "FDR < 0.05: ",
                significant_n
            ),
            hjust = 1.05,
            vjust = 1.25,
            size = 3,
            fontface = "bold"
        ) +
        scale_colour_manual(
            values = STATUS_COLORS,
            breaks = c(
                "Higher",
                "Lower",
                "Not significant"
            )
        ) +
        labs(
            title = panel_title,
            x = "log2 fold change",
            y = "-log10(BH FDR)",
            colour = NULL
        ) +
        theme_publication() +
        theme(
            legend.position = "bottom"
        )
}


for (name in names(primary_results)) {
    p <- make_volcano(primary_results[[name]], CONTRAST_LABELS[[name]])
    save_plot(p, paste0("Figure_A3_volcano_", name))
}

# 9. Expression + metadata
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
        "Primary expression columns and metadata are not aligned."
    )
}

meta$TREAT1_clean <- factor(
    meta$TREAT1_clean,
    levels = DOSE_LEVELS
)

meta$condition <- factor(
    meta$condition,
    levels = ENV_LEVELS
)


# ============================================================
# 9b. Exploratory UMAP from complete-case primary log2 abundance
# No imputation, outcome selection or limma refitting. Same complete-case
# protein rule as the upstream PCA; center only, without variance scaling.
# ============================================================

embedding_expr <- as.matrix(expr_df[, -1, drop = FALSE])
storage.mode(embedding_expr) <- "numeric"
if (anyDuplicated(meta$UniqueSampleID) || anyNA(meta$UniqueSampleID) ||
    anyDuplicated(expr_df[[1]]) || anyNA(expr_df[[1]]) ||
    anyNA(meta$TREAT1_clean) || anyNA(meta$condition)) {
    stop("Embedding inputs contain duplicate/missing IDs or unknown group labels.")
}
complete_rows <- rowSums(!is.finite(embedding_expr)) == 0L
embedding_matrix <- t(embedding_expr[complete_rows, , drop = FALSE])
if (nrow(embedding_matrix) != nrow(meta) ||
    !setequal(rownames(embedding_matrix), meta$UniqueSampleID)) {
    stop("UMAP expression samples and metadata sample IDs are not identical.")
}
if (ncol(embedding_matrix) < 2L || nrow(embedding_matrix) < 4L) {
    stop("UMAP needs at least two complete-case proteins and four samples.")
}
if (anyDuplicated(pca$UniqueSampleID) ||
    !setequal(pca$UniqueSampleID, meta$UniqueSampleID)) {
    stop("Existing PCA and current expression sample IDs differ; review upstream diagnostics.")
}
aligned_pca <- pca[match(meta$UniqueSampleID, pca$UniqueSampleID), , drop = FALSE]
for (name in c("TREAT1_clean", "condition")) {
    if (!identical(as.character(aligned_pca[[name]]), as.character(meta[[name]])))
        stop("PCA/current metadata label conflict: ", name)
}
if (!identical(as.character(aligned_pca$MS_batch_proxy), as.character(meta[["进样时间"]])))
    stop("PCA/current acquisition-date labels differ.")
embedding_matrix <- scale(embedding_matrix, center = TRUE, scale = FALSE)
umap_feature_variance <- apply(embedding_matrix, 2, var)
umap_keep_features <- is.finite(umap_feature_variance) & umap_feature_variance > 0
if (sum(umap_keep_features) < 2L) {
    stop("UMAP needs at least two non-zero-variance complete-case proteins.")
}
embedding_matrix <- embedding_matrix[, umap_keep_features, drop = FALSE]
if (any(!is.finite(embedding_matrix))) {
    stop("UMAP input contains non-finite values after complete-case filtering and centering.")
}
umap_seed <- 20260922L
umap_neighbors <- min(15L, nrow(embedding_matrix) - 1L)
set.seed(umap_seed)
umap_coordinates <- uwot::umap(
    embedding_matrix, n_neighbors = umap_neighbors, min_dist = 0.1,
    metric = "euclidean", n_components = 2L, init = "random",
    n_threads = 1L, n_sgd_threads = 1L, verbose = FALSE
)
umap_coordinates_data <- data.frame(
    UniqueSampleID = rownames(embedding_matrix),
    UMAP1 = umap_coordinates[, 1], UMAP2 = umap_coordinates[, 2],
    stringsAsFactors = FALSE
)
umap_data <- umap_coordinates_data %>%
    left_join(
        meta[, c("UniqueSampleID", "TREAT1_clean", "condition", "进样时间")],
        by = "UniqueSampleID"
    ) %>%
    rename(MS_batch_proxy = `进样时间`)
if (nrow(umap_data) != nrow(embedding_matrix) ||
    anyNA(umap_data$TREAT1_clean) || anyNA(umap_data$condition) ||
    anyNA(umap_data$MS_batch_proxy)) {
    stop("UMAP coordinates could not be joined unambiguously to current metadata.")
}
umap_subtitle <- paste(ncol(embedding_matrix), "complete-case, non-zero-variance proteins; exploratory")
umap_base <- ggplot(umap_data, aes(UMAP1, UMAP2)) +
    labs(x = "UMAP 1", y = "UMAP 2", subtitle = umap_subtitle) + theme_publication()
umap_exposure <- umap_base +
    geom_point(aes(colour = TREAT1_clean, shape = TREAT1_clean), size = 1.6, alpha = 0.65) +
    scale_colour_manual(values = DOSE_COLORS, labels = DOSE_LABELS) +
    scale_shape_manual(values = c(control = 16, low = 17, high = 15), labels = DOSE_LABELS) +
    labs(title = "a  Exposure duration", colour = "Exposure duration", shape = "Exposure duration")
umap_environment <- umap_base +
    geom_point(aes(colour = condition, shape = condition), size = 1.6, alpha = 0.65) +
    scale_colour_manual(values = ENV_COLORS, labels = ENV_LABELS) +
    scale_shape_manual(values = c(high_stress = 16, high_temperature = 17), labels = ENV_LABELS) +
    labs(title = "b  Environment", colour = "Environment", shape = "Environment")
umap_date <- umap_base +
    geom_point(aes(colour = MS_batch_proxy), size = 1.6, alpha = 0.65) +
    scale_colour_manual(values = RUN_PALETTE, drop = FALSE) +
    labs(title = "c  Acquisition date", colour = "Acquisition date")
for (name in c("exposure", "environment", "acquisition_date")) {
    plots <- list(exposure = umap_exposure, environment = umap_environment, acquisition_date = umap_date)
    save_plot(plots[[name]], paste0("Figure_A2b_UMAP_", name))
}
# No PCA/UMAP assembly: each coordinate view is exported independently.

write.csv(umap_data, file.path(FIG_DIR, "Figure_A2b_UMAP_source_data.csv"), row.names = FALSE)
write.csv(data.frame(
    seed = umap_seed, n_neighbors = umap_neighbors, min_dist = 0.1,
    metric = "euclidean", init = "random", n_threads = 1L, n_sgd_threads = 1L,
    n_samples = nrow(embedding_matrix), n_proteins = ncol(embedding_matrix),
    preprocessing = "complete-case log2; centered; zero-variance features removed; no scaling or imputation",
    uwot_version = as.character(utils::packageVersion("uwot")),
    input_file = PRIMARY_EXPR_FILE,
    input_MD5 = unname(tools::md5sum(PRIMARY_EXPR_FILE)),
    expression_md5 = unname(tools::md5sum(PRIMARY_EXPR_FILE)),
    metadata_md5 = unname(tools::md5sum(META_FILE)),
    pca_md5 = unname(tools::md5sum(PCA_FILE))
), file.path(FIG_DIR, "Figure_A2b_UMAP_parameters.csv"), row.names = FALSE)
write.csv(data.frame(Protein = expr_df[[1]][complete_rows][umap_keep_features]),
          file.path(FIG_DIR, "Figure_A2b_UMAP_proteins.csv"), row.names = FALSE)

# ============================================================
# 10. Select top Long-vs-Short exposure proteins
# ============================================================

high_low_sig <- primary_results$High_vs_Low %>%
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

if (nrow(high_low_sig) == 0) {
    stop(
        "No primary Long-vs-Short exposure proteins at FDR < 0.05."
    )
}


# ============================================================
# 11. Figure A4: top 12 protein distributions
# ============================================================

top12_n <- min(
    12,
    nrow(
        high_low_sig
    )
)

top12 <- high_low_sig$PG.ProteinGroups[
    seq_len(
        top12_n
    )
]

top12_index <- match(
    top12,
    expr_df$PG.ProteinGroups
)

top12_df <- expr_df[
    top12_index,
    ,
    drop = FALSE
]

top12_long <- top12_df %>%
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

top12_long$PG.ProteinGroups <- factor(
    top12_long$PG.ProteinGroups,
    levels = top12
)

p_a4 <- ggplot(
    top12_long,
    aes(
        x = TREAT1_clean,
        y = Abundance,
        fill = TREAT1_clean
    )
) +
    geom_violin(
        na.rm = TRUE,
        trim = TRUE,
        alpha = 0.16,
        colour = NA,
        width = 0.92
    ) +
    geom_boxplot(
        na.rm = TRUE,
        width = 0.32,
        outlier.shape = NA,
        linewidth = 0.38,
        colour = "black",
        alpha = 0.75
    ) +
    geom_jitter(
        na.rm = TRUE,
        aes(
            colour = TREAT1_clean
        ),
        width = 0.11,
        size = 0.42,
        alpha = 0.20,
        show.legend = FALSE
    ) +
    scale_fill_manual(
        values = DOSE_COLORS,
        guide = "none"
    ) +
    scale_colour_manual(
        values = DOSE_COLORS,
        guide = "none"
    ) +
    scale_x_discrete(
        labels = DOSE_LABELS
    ) +
    labs(
        title = "Top primary Long-vs-Short exposure proteins",
        subtitle = "Sample-level distributions; no imputation",
        x = NULL,
        y = "log2(PG.Quantity)"
    ) +
    theme_publication(
        base_size = 8
    ) +
    theme(
        axis.text.x = element_text(
            angle = 0,
            size = 7
        ),
        strip.text = element_text(
            size = 7.5,
            face = "bold"
        )
    )

set.seed(20260922)
for (i in seq_along(top12)) {
    id <- top12[i]
    shown <- top12_long[as.character(top12_long$PG.ProteinGroups) == id, , drop = FALSE]
    p <- (p_a4 %+% shown) + labs(title = paste("Observed abundance:", id))
    save_plot(p, paste0("Figure_A4_", sprintf("%02d", i), "_", v22_slug(id)))
}

# 12. Figure A5: top 30 heatmap
# ============================================================

top30_n <- min(
    30,
    nrow(
        high_low_sig
    )
)

top30 <- high_low_sig$PG.ProteinGroups[
    seq_len(
        top30_n
    )
]

top30_index <- match(
    top30,
    expr_df$PG.ProteinGroups
)

heat_mat <- as.matrix(
    expr_df[
        top30_index,
        -1,
        drop = FALSE
    ]
)

storage.mode(
    heat_mat
) <- "double"

rownames(
    heat_mat
) <- top30

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
    Exposure_duration = factor(
        meta$TREAT1_clean,
        levels = DOSE_LEVELS,
        labels = unname(DOSE_LABELS[DOSE_LEVELS])
    ),
    Environment = factor(
        meta$condition,
        levels = ENV_LEVELS
    ),
    MS_run_date = factor(
        as.character(
            meta[["进样时间"]]
        )
    ),
    row.names = meta$UniqueSampleID,
    check.names = FALSE
)

annotation_colors <- list(
    Exposure_duration = setNames(DOSE_COLORS, unname(DOSE_LABELS[names(DOSE_COLORS)])),
    Environment = ENV_COLORS,
    MS_run_date = RUN_PALETTE
)

heat_colors <- colorRampPalette(
    c(
        "#2C6E9B",
        "#F7F7F7",
        "#C0392B"
    )
)(
    101
)


v22_heatmap(heat_z, FIG_DIR, "Figure_A5_top30_heatmap",
             color = heat_colors, breaks = seq(-3, 3, length.out = 102),
             cluster_rows = TRUE, cluster_cols = TRUE, show_colnames = FALSE,
             annotation_col = annotation_col, annotation_colors = annotation_colors,
             na_col = "#D9D9D9", main = "Top primary Long-vs-Short exposure proteins",
             height_mm = 170)

# 13. Export source data for figures
# ============================================================

write.csv(
    sample_diag,
    file.path(
        FIG_DIR,
        "Figure_A1_source_data.csv"
    ),
    row.names = FALSE
)

write.csv(
    pca,
    file.path(
        FIG_DIR,
        "Figure_A2_source_data.csv"
    ),
    row.names = FALSE
)

write.csv(
    bind_rows(
        primary_results
    ),
    file.path(
        FIG_DIR,
        "Figure_A3_source_data.csv"
    ),
    row.names = FALSE
)

write.csv(
    top12_long,
    file.path(
        FIG_DIR,
        "Figure_A4_source_data.csv"
    ),
    row.names = FALSE
)


# ============================================================
# 14. Console
# ============================================================

write.csv(data.frame(Protein = rownames(heat_z), heat_z, check.names = FALSE),
          file.path(FIG_DIR, "Figure_A5_heatmap_source_data.csv"), row.names = FALSE)
v21_provenance(FIG_DIR, c(required_files, file.path(ROOT_DIR, "06a_limma_core_figures.R")),
               c(UMAP_seed = umap_seed, UMAP_features = "complete-case, non-zero-variance; no DEP selection",
                 PCA = "cached scores verified against centered unscaled primary matrix",
                 interpretation = "exploratory QC, not evidence of significant group separation"),
               c("ggplot2", "uwot", "ragg"))

cat(
    "\n============================================================\n"
)

cat(
    "06a CORE PUBLICATION FIGURES COMPLETED\n"
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
    "Figure_A1_sample_structure\n"
)

cat(
    "Figure_A2_PCA: separate exposure, environment and acquisition-date figures\n"
)

cat("Figure_A2b_UMAP: separate exposure, environment and acquisition-date figures\n")

cat(
    "Figure_A3_volcano: one figure per contrast\n"
)

cat(
    "Figure_A4: one distribution figure per selected protein\n"
)

cat(
    "Figure_A5_top30_heatmap\n"
)

cat(
    "\nPASS\n"
)




