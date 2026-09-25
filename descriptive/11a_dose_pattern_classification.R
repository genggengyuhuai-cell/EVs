# Exposure-duration patterns v2.0; exploratory, not a linear trend test.
# Legacy low/high keys mean Short/Long exposure. Primary limma is unchanged.
suppressPackageStartupMessages({
    library(dplyr)
    library(tidyr)
    library(ggplot2)
    library(pheatmap)
})
script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
ROOT_DIR <- if (length(script_arg) == 1L) {
    dirname(normalizePath(sub("^--file=", "", script_arg), mustWork = TRUE))
} else stop("Run this stage with Rscript so --file= is available.")
BASE_DIR <- file.path(ROOT_DIR, "limma_dose_analysis")
source(file.path(ROOT_DIR, "v21_common.R"))
PROTEIN_ANNOTATION <- v21_annotation(ROOT_DIR)
v21_packages(c("svglite", "ragg"))
DEP_FILE <- file.path(BASE_DIR, "results", "09_DEP_characterization", "High_vs_Low_DEP_all.csv")
EXPR_FILE <- file.path(ROOT_DIR, "PRIMARY_dose_log2_expression.csv.gz")
META_FILE <- file.path(ROOT_DIR, "dose_defined_metadata.csv")
# Preserve legacy results; paused script 11 must not silently read a new schema.
RESULT_DIR <- file.path(BASE_DIR, "results", "10_dose_pattern_classification_v2")
FIG_DIR <- file.path(BASE_DIR, "figures_final", "10_dose_pattern_classification_v2", "figures_nature_v2.2")
tol <- 0.05  # Descriptive log2 tolerance, not a significance threshold.

# Mutually exclusive and exhaustive 3 x 3 grid of adjacent differences.
# Differences exactly +/- tolerance belong to the near-zero bin.
classify_pattern <- function(control, short, long, tolerance = 0.05) {
    stopifnot(length(control) == length(short), length(short) == length(long),
              length(tolerance) == 1L, is.finite(tolerance), tolerance >= 0)
    valid <- is.finite(control) & is.finite(short) & is.finite(long)
    result <- rep("Insufficient_data", length(control))
    bin <- function(x) ifelse(x > tolerance, 1L, ifelse(x < -tolerance, -1L, 0L))
    key <- paste(bin(short[valid] - control[valid]), bin(long[valid] - short[valid]), sep = ":")
    rules <- c(
        "1:1" = "Ordered_increase", "-1:-1" = "Ordered_decrease",
        "1:-1" = "Short_peak", "-1:1" = "Short_trough",
        "0:1" = "Long_elevation", "0:-1" = "Long_suppression",
        "1:0" = "Short_elevation_plateau", "-1:0" = "Short_suppression_plateau",
        "0:0" = "Adjacent_changes_within_tolerance"
    )
    result[valid] <- unname(rules[key])
    stopifnot(!anyNA(result))
    result
}
require_columns <- function(tab, required, label) {
    missing <- setdiff(required, names(tab))
    if (length(missing)) stop(label, " missing columns: ", paste(missing, collapse = ", "))
}
validate_ids <- function(ids, label) {
    if (anyNA(ids) || any(!nzchar(ids)) || anyDuplicated(ids))
        stop(label, " must be unique and non-empty.")
}
dep <- read.csv(DEP_FILE, check.names = FALSE, stringsAsFactors = FALSE)
expr_df <- read.csv(EXPR_FILE, check.names = FALSE, stringsAsFactors = FALSE)
meta <- read.csv(META_FILE, check.names = FALSE, stringsAsFactors = FALSE)
require_columns(dep, c("PG.ProteinGroups", "logFC", "adj.P.Val"), "DEP table")
require_columns(expr_df, "PG.ProteinGroups", "Expression table")
require_columns(meta, c("UniqueSampleID", "TREAT1_clean"), "Metadata")
validate_ids(dep$PG.ProteinGroups, "DEP protein IDs")
validate_ids(expr_df$PG.ProteinGroups, "Expression protein IDs")
validate_ids(meta$UniqueSampleID, "Metadata sample IDs")
validate_ids(names(expr_df)[-1], "Expression sample IDs")
if (!is.numeric(dep$adj.P.Val) || !is.numeric(dep$logFC)) stop("DEP statistics must be numeric.")
if (any(!is.finite(dep$adj.P.Val) | dep$adj.P.Val < 0 | dep$adj.P.Val >= 0.05))
    stop("DEP input must contain only finite primary BH FDR < 0.05 rows.")
if (!all(dep$PG.ProteinGroups %in% expr_df$PG.ProteinGroups)) stop("Missing DEP expression rows.")
if (!setequal(names(expr_df)[-1], meta$UniqueSampleID)) stop("Expression/metadata sample sets differ.")
if (!all(vapply(expr_df[-1], is.numeric, logical(1)))) stop("Expression must be numeric.")
expr <- as.matrix(expr_df[-1])
rownames(expr) <- expr_df$PG.ProteinGroups
if (any(is.infinite(expr))) stop("Infinite expression values are not supported.")
expr_dep <- expr[dep$PG.ProteinGroups, , drop = FALSE]
meta <- meta[match(colnames(expr_dep), meta$UniqueSampleID), , drop = FALSE]
groups <- c("control", "low", "high")
if (anyNA(meta$TREAT1_clean) || !all(meta$TREAT1_clean %in% groups) ||
    !all(groups %in% meta$TREAT1_clean)) stop("Expected Control, Short and Long samples.")

# Classification uses observed log2 values, never zero-filled expression.
pattern_df <- data.frame(Protein = dep$PG.ProteinGroups, stringsAsFactors = FALSE)
pattern_df$PG.ProteinGroups <- dep$PG.ProteinGroups
pattern_df$Gene_symbol <- PROTEIN_ANNOTATION$Gene_symbol[match(dep$PG.ProteinGroups, PROTEIN_ANNOTATION$PG.ProteinGroups)]
pattern_df$Display_label <- PROTEIN_ANNOTATION$Display_label[match(dep$PG.ProteinGroups, PROTEIN_ANNOTATION$PG.ProteinGroups)]
for (i in seq_along(groups)) {
    label <- c("Control", "Short", "Long")[i]
    block <- expr_dep[, meta$TREAT1_clean == groups[i], drop = FALSE]
    n_observed <- rowSums(is.finite(block))
    means <- rowMeans(block, na.rm = TRUE)
    means[n_observed == 0] <- NA_real_
    pattern_df[[label]] <- means
    pattern_df[[paste0("N_observed_", label)]] <- n_observed
    pattern_df[[paste0("N_total_", label)]] <- rep(ncol(block), nrow(pattern_df))
}
pattern_df$Short_minus_Control <- pattern_df$Short - pattern_df$Control
pattern_df$Long_minus_Short <- pattern_df$Long - pattern_df$Short
pattern_df$Long_minus_Control <- pattern_df$Long - pattern_df$Control
pattern_df$Pattern <- classify_pattern(pattern_df$Control, pattern_df$Short, pattern_df$Long, tol)
pattern_df$logFC <- dep$logFC
pattern_df$adj.P.Val <- dep$adj.P.Val
pattern_df$Pattern_version <- rep("2.0", nrow(pattern_df))
pattern_df$Tolerance_log2 <- rep(tol, nrow(pattern_df))
pattern_summary <- count(pattern_df, Pattern, name = "n")
RESULT_DIR <- v21_output(RESULT_DIR)
FIG_DIR <- v21_output(FIG_DIR)
write.csv(pattern_df, file.path(RESULT_DIR, "DEP_three_group_pattern.csv"), row.names = FALSE)
write.csv(pattern_summary, file.path(RESULT_DIR, "DEP_pattern_summary.csv"), row.names = FALSE)
writeLines(c(
    "Pattern schema: 2.0; low=Short exposure; high=Long exposure.",
    "Input: primary Long vs Short (legacy High_vs_Low), BH FDR < 0.05.",
    "Classification: observed group means; no imputation; tolerance=0.05 log2.",
    "Missing group mean => Insufficient_data. Observed/total counts are exported.",
    "Adjacent_changes_within_tolerance does not imply total range <= tolerance.",
    "Heatmap only: NA -> 0 before protein-wise z-score, matching clustering script.",
    "Patterns are descriptive unadjusted means; no linear trend or causal claim.",
    "Legacy patterns and dependent annotations are invalid for final interpretation.",
    "Script 11 remains paused; its Low_peak/Low/High schema requires migration."
), file.path(RESULT_DIR, "PATTERN_METHODS_v2.txt"))
write.csv(data.frame(Input = c(DEP_FILE, EXPR_FILE, META_FILE),
                     MD5 = unname(tools::md5sum(c(DEP_FILE, EXPR_FILE, META_FILE)))),
          file.path(RESULT_DIR, "input_provenance.csv"), row.names = FALSE)

if (nrow(pattern_df) > 0L) {
    p1 <- ggplot(pattern_summary, aes(Pattern, n)) + geom_col(fill = "#3B82F6") +
        coord_flip() + theme_classic() +
        labs(x = NULL, y = "Protein groups", title = "Exposure-duration abundance patterns")
    v21_save(p1, FIG_DIR, "Pattern_distribution", pattern_summary, height_mm = 145)
    trajectory <- pattern_df %>% filter(Pattern != "Insufficient_data") %>%
        mutate(Baseline = (Control + Short + Long) / 3) %>%
        pivot_longer(c(Control, Short, Long), names_to = "Exposure", values_to = "Abundance") %>%
        mutate(Exposure = factor(Exposure, levels = c("Control", "Short", "Long")),
               Centered_log2 = Abundance - Baseline)
    write.csv(trajectory, file.path(RESULT_DIR, "DEP_pattern_profile_source.csv"), row.names = FALSE)
    if (nrow(trajectory) > 0L) {
      for (pattern_name in unique(trajectory$Pattern)) {
        shown <- trajectory[trajectory$Pattern == pattern_name, , drop = FALSE]
        p2 <- ggplot(shown, aes(Exposure, Centered_log2, group = Protein)) +
            geom_line(alpha = 0.18, colour = "#64748B") +
            stat_summary(aes(group = 1), fun = mean, geom = "line", linewidth = 0.9,
                         colour = "#C78132") + theme_classic() +
            labs(x = "Exposure group (categorical)", y = "Centered group mean log2 abundance",
                 title = gsub("_", " ", pattern_name), subtitle = "Observed group means; orange = mean across proteins; no trend test")
        v21_save(p2, FIG_DIR, paste0("Pattern_profile_", v22_slug(pattern_name)), shown)
      }
    }
    heat_expr <- expr_dep
    heat_expr[is.na(heat_expr)] <- 0  # Heatmap copy only, BEFORE row scaling.
    heat_sd <- apply(heat_expr, 1, sd)
    keep <- is.finite(heat_sd) & heat_sd > 0
    write.csv(data.frame(Protein = rownames(heat_expr), Included_in_heatmap = keep),
              file.path(RESULT_DIR, "heatmap_inclusion.csv"), row.names = FALSE)
    if (any(keep)) {
        z <- t(scale(t(heat_expr[keep, , drop = FALSE])))
        ordering <- order(match(meta$TREAT1_clean, groups), meta$UniqueSampleID)
        z <- z[, ordering, drop = FALSE]
        annotation_row <- data.frame(Pattern = pattern_df$Pattern[keep], row.names = rownames(z))
        annotation_col <- data.frame(
            Exposure = factor(meta$TREAT1_clean[ordering], levels = groups,
                              labels = c("Control", "Short exposure", "Long exposure")),
            row.names = colnames(z))
        v22_heatmap(z, FIG_DIR, "Pattern_heatmap", annotation_row = annotation_row, annotation_col = annotation_col,
                 show_rownames = FALSE, show_colnames = FALSE,
                 cluster_rows = nrow(z) > 1L, cluster_cols = FALSE, scale = "none",
                 main = "Exposure patterns (heatmap-only NA -> 0)",
                 height_mm = 180)
    }
}
print(pattern_summary)
cat("\nExploratory exposure pattern v2 outputs: ", RESULT_DIR, "\n", sep = "")
