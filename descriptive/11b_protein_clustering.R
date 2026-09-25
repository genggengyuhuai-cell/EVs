# STAGE 11b: exploratory unsupervised DEP response-profile clustering.
# Stage 11a remains the canonical rule-based dose-pattern characterization.
# Input is observed Control/Short/Long means (no sample-level imputation),
# protein-wise z-scored. Primary method remains Pearson distance, complete
# linkage and the existing K=4 display cut. K-means K=2:6 is sensitivity only.

rm(list = ls())
gc()
suppressPackageStartupMessages({
    library(dplyr)
    library(pheatmap)
    library(ggplot2)
    library(readr)
})

get_script_dir <- function() {
    arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
    if (length(arg) != 1L) stop("Run this stage with Rscript so --file= is available.")
    dirname(normalizePath(sub("^--file=", "", arg), winslash = "/", mustWork = TRUE))
}
require_columns <- function(x, required, label) {
    missing <- setdiff(required, names(x))
    if (length(missing)) stop(label, " missing columns: ", paste(missing, collapse = ", "))
}
validate_ids <- function(x, label) {
    if (anyNA(x) || any(!nzchar(trimws(x))) || anyDuplicated(x))
        stop(label, " must be unique, non-empty and non-missing.")
}

ROOT_DIR <- get_script_dir()
source(file.path(ROOT_DIR, "v21_common.R"))
# Read the existing UTF-8-BOM annotation robustly without modifying its source.
PROTEIN_ANNOTATION <- read.csv(
    file.path(ROOT_DIR, "canonical_protein_annotation.csv"),
    check.names = FALSE, stringsAsFactors = FALSE, fileEncoding = "UTF-8-BOM"
)
names(PROTEIN_ANNOTATION)[1] <- sub("^\\ufeff", "", names(PROTEIN_ANNOTATION)[1])
require_columns(PROTEIN_ANNOTATION,
                c("PG.ProteinGroups", "Gene_symbol", "Display_label"),
                "Canonical protein annotation")
validate_ids(PROTEIN_ANNOTATION$PG.ProteinGroups, "Canonical annotation protein IDs")
v21_packages(c("svglite", "ragg"))
DEP_FILE <- file.path(ROOT_DIR, "limma_dose_analysis", "results", "09_DEP_characterization", "High_vs_Low_DEP_all.csv")
EXPR_FILE <- file.path(ROOT_DIR, "PRIMARY_dose_log2_expression.csv.gz")
META_FILE <- file.path(ROOT_DIR, "dose_defined_metadata.csv")
STAGE11A_FILE <- file.path(ROOT_DIR, "limma_dose_analysis", "results", "10_dose_pattern_classification_v2", "DEP_three_group_pattern.csv")
RESULT_DIR <- v21_output(file.path(ROOT_DIR, "limma_dose_analysis", "results", "10_protein_clustering"))
FIG_DIR <- v21_output(file.path(ROOT_DIR, "limma_dose_analysis", "figures_final", "10_protein_clustering", "figures_nature_v2.2"))

# Canonical inputs.
dep <- read.csv(DEP_FILE, check.names = FALSE, stringsAsFactors = FALSE)
expr_df <- read.csv(gzfile(EXPR_FILE), check.names = FALSE, stringsAsFactors = FALSE)
meta <- read.csv(META_FILE, check.names = FALSE, stringsAsFactors = FALSE)
stage11a <- read.csv(STAGE11A_FILE, check.names = FALSE, stringsAsFactors = FALSE)
require_columns(dep, c("PG.ProteinGroups", "logFC", "adj.P.Val"), "DEP table")
require_columns(expr_df, "PG.ProteinGroups", "Expression table")
require_columns(meta, c("UniqueSampleID", "TREAT1_clean"), "Metadata")
require_columns(stage11a, c("PG.ProteinGroups", "Pattern"), "Stage 11a table")
validate_ids(dep$PG.ProteinGroups, "DEP protein IDs")
validate_ids(expr_df$PG.ProteinGroups, "Expression protein IDs")
validate_ids(names(expr_df)[-1], "Expression sample IDs")
validate_ids(meta$UniqueSampleID, "Metadata sample IDs")
validate_ids(stage11a$PG.ProteinGroups, "Stage 11a protein IDs")

dep_ids <- dep$PG.ProteinGroups
if (length(dep_ids) != 256L) stop("Expected 256 canonical DEP proteins; found ", length(dep_ids), ".")
if (!all(dep_ids %in% expr_df$PG.ProteinGroups)) stop("Expression matrix is missing DEP proteins.")
if (!setequal(names(expr_df)[-1], meta$UniqueSampleID)) stop("Expression/metadata sample sets differ.")
if (!setequal(dep_ids, stage11a$PG.ProteinGroups)) stop("Stage 11a and Stage 11b DEP sets differ.")
if (!all(vapply(expr_df[-1], is.numeric, logical(1)))) stop("Expression values must be numeric.")
expr <- as.matrix(expr_df[-1])
rownames(expr) <- expr_df$PG.ProteinGroups
if (any(is.infinite(expr))) stop("Infinite sample-level expression values are not supported.")
dep_expr <- expr[dep_ids, , drop = FALSE]
meta <- meta[match(colnames(dep_expr), meta$UniqueSampleID), , drop = FALSE]
if (!identical(meta$UniqueSampleID, colnames(dep_expr))) stop("Metadata alignment failed.")
group_keys <- c("control", "low", "high")
group_labels <- c("Control", "Short", "Long")
if (anyNA(meta$TREAT1_clean) || !all(meta$TREAT1_clean %in% group_keys) || !all(group_keys %in% meta$TREAT1_clean))
    stop("Expected canonical control, low and high dose metadata groups.")
cat("DEP input count:", length(dep_ids), "\n")
cat("Sample-level missing values retained (no imputation):", sum(is.na(dep_expr)), "\n")

# Observed group means and availability; individual missing values remain NA.
profile <- data.frame(PG.ProteinGroups = dep_ids, stringsAsFactors = FALSE)
profile$Gene_symbol <- PROTEIN_ANNOTATION$Gene_symbol[match(dep_ids, PROTEIN_ANNOTATION$PG.ProteinGroups)]
profile$Display_label <- PROTEIN_ANNOTATION$Display_label[match(dep_ids, PROTEIN_ANNOTATION$PG.ProteinGroups)]
if (anyNA(profile$Display_label) || any(!nzchar(trimws(profile$Display_label))))
    stop("Canonical Display_label is missing for one or more DEP proteins.")
for (i in seq_along(group_keys)) {
    label <- group_labels[i]
    block <- dep_expr[, meta$TREAT1_clean == group_keys[i], drop = FALSE]
    observed <- rowSums(!is.na(block))
    means <- rowMeans(block, na.rm = TRUE)
    means[observed == 0L] <- NA_real_
    profile[[paste0(label, "_mean")]] <- means
    profile[[paste0(label, "_n_observed")]] <- observed
    profile[[paste0(label, "_missing_n")]] <- rowSums(is.na(block))
    profile[[paste0(label, "_availability_proportion")]] <- observed / ncol(block)
}
group_mean_matrix <- as.matrix(profile[, paste0(group_labels, "_mean"), drop = FALSE])
colnames(group_mean_matrix) <- group_labels
rownames(group_mean_matrix) <- dep_ids
missing_group_means <- sum(!is.finite(group_mean_matrix))
cat("Group-mean matrix dimensions:", paste(dim(group_mean_matrix), collapse = " x "), "\n")
cat("Missing/non-finite group means:", missing_group_means, "\n")
if (missing_group_means) {
    bad <- which(!is.finite(group_mean_matrix), arr.ind = TRUE)
    stop("Non-finite observed group mean(s): ", paste(rownames(group_mean_matrix)[bad[, 1]], colnames(group_mean_matrix)[bad[, 2]], sep = "/", collapse = ", "))
}

# Shape standardization; fail rather than alter undefined profiles.
profile_sd <- apply(group_mean_matrix, 1L, sd)
zero_variance <- sum(!is.finite(profile_sd) | profile_sd == 0)
cat("Zero-variance profiles:", zero_variance, "\n")
if (zero_variance) stop("Zero-variance group-mean profile(s): ", paste(names(profile_sd)[!is.finite(profile_sd) | profile_sd == 0], collapse = ", "))
z_expr <- t(scale(t(group_mean_matrix)))
colnames(z_expr) <- group_labels
if (anyNA(z_expr) || any(is.infinite(z_expr))) stop("Standardized clustering matrix contains NA/Inf.")
if (nrow(z_expr) != 256L) stop("Expected 256 proteins entering clustering; found ", nrow(z_expr), ".")
cat("Proteins entering clustering:", nrow(z_expr), "\n")

# Existing primary hierarchical method retained.
row_dist <- as.dist(1 - cor(t(z_expr), method = "pearson"))
if (anyNA(row_dist) || any(is.infinite(row_dist))) stop("Pearson distance contains NA/Inf.")
row_hc <- hclust(row_dist, method = "complete")
k <- 4L
cluster_hc <- cutree(row_hc, k = k)
stage11a_pattern <- stage11a$Pattern[match(dep_ids, stage11a$PG.ProteinGroups)]
if (anyNA(stage11a_pattern)) stop("Stage 11a pattern alignment failed.")
profile$Control_z <- z_expr[, "Control"]
profile$Short_z <- z_expr[, "Short"]
profile$Long_z <- z_expr[, "Long"]
profile$hierarchical_cluster <- unname(cluster_hc[dep_ids])
profile$Stage11a_pattern <- stage11a_pattern
profile$logFC <- dep$logFC
profile$adj.P.Val <- dep$adj.P.Val
cluster_table <- profile %>% transmute(Protein = PG.ProteinGroups, PG.ProteinGroups, Gene_symbol, Display_label, Cluster = hierarchical_cluster, logFC, adj.P.Val, Stage11a_pattern)
cluster_summary <- cluster_table %>% group_by(Cluster) %>% summarise(N = n(), Mean_logFC = mean(logFC, na.rm = TRUE), Median_FDR = median(adj.P.Val, na.rm = TRUE), .groups = "drop")
concordance <- as.data.frame.matrix(table(Stage11a_pattern = profile$Stage11a_pattern, hierarchical_cluster = profile$hierarchical_cluster))
concordance <- data.frame(Stage11a_pattern = rownames(concordance), concordance, row.names = NULL, check.names = FALSE)
write.csv(profile, file.path(RESULT_DIR, "DEP_response_profile_clustering_source.csv"), row.names = FALSE)
write.csv(cluster_table, file.path(RESULT_DIR, "DEP_cluster_membership_hclust.csv"), row.names = FALSE)
write.csv(cluster_summary, file.path(RESULT_DIR, "DEP_cluster_summary.csv"), row.names = FALSE)
write.csv(concordance, file.path(RESULT_DIR, "Stage11a_by_Stage11b_hierarchical_cluster.csv"), row.names = FALSE)
writeLines(c(
    "Stage 11b is a supplementary exploratory unsupervised analysis of the 256 primary Long-vs-Short DEPs.",
    "Stage 11a remains the canonical rule-based dose-pattern classification.",
    "Input profiles are observed Control, Short and Long means calculated from available values only; no sample-level imputation is used.",
    "Profiles are protein-wise z-scored across the three observed group means.",
    "Primary clustering uses Pearson correlation distance and complete-linkage hierarchical clustering; the existing K=4 cut is retained for display and concordance.",
    "K-means K=2:6 is retained only as an exploratory sensitivity analysis; no optimal biological K is selected."
), file.path(RESULT_DIR, "STAGE11b_METHODS.txt"))
cat("Hierarchical cluster sizes:\n"); print(table(profile$hierarchical_cluster))
cat("Stage 11a x Stage 11b concordance:\n"); print(table(profile$Stage11a_pattern, profile$hierarchical_cluster))

# Primary 256 x 3 response-profile heatmap and labeled top-50 view.
v22_heatmap(z_expr, FIG_DIR, "Figure_10_protein_clustering_all_DEP_heatmap", scale = "none", clustering_distance_rows = row_dist, clustering_method = "complete", show_rownames = FALSE, show_colnames = TRUE, main = "Exploratory DEP response-profile clustering\nObserved group means; protein-wise z-score", height_mm = 180)
top50 <- dep %>% arrange(adj.P.Val) %>% slice_head(n = 50) %>% pull(PG.ProteinGroups)
top50 <- top50[top50 %in% rownames(z_expr)]
v22_heatmap(z_expr[top50, , drop = FALSE], FIG_DIR, "Figure_10_protein_clustering_top50_DEP_heatmap", scale = "none", display_labels = profile$Display_label[match(top50, profile$PG.ProteinGroups)], clustering_method = "complete", show_rownames = TRUE, show_colnames = TRUE, main = "Exploratory top-50 DEP response profiles\nObserved group means; protein-wise z-score", height_mm = 220)

# K-means is exploratory sensitivity analysis only; no K is selected.
set.seed(123)
km_result <- data.frame()
for (kk in 2:6) {
    km <- kmeans(z_expr, centers = kk, nstart = 100)
    km_result <- rbind(km_result, data.frame(Protein = rownames(z_expr), K = kk, Cluster = km$cluster, Analysis_role = "exploratory sensitivity analysis"))
}
write.csv(km_result, file.path(RESULT_DIR, "DEP_cluster_membership_kmeans.csv"), row.names = FALSE)
cat("K-means retained: yes, exploratory sensitivity analysis only (K=2:6).\n")

p <- ggplot(cluster_summary, aes(factor(Cluster), N)) + geom_col(fill = "#3178A5", width = 0.65) + labs(x = "Hierarchical cluster", y = "Protein groups", title = "Exploratory hierarchical cluster sizes (K = 4)")
v21_save(p, FIG_DIR, "Figure_10_protein_clustering_hierarchical_cluster_sizes", cluster_summary)
p <- ggplot(cluster_table, aes(factor(Cluster), logFC)) + geom_hline(yintercept = 0, linetype = 2, linewidth = 0.35) + geom_boxplot(fill = "#DCE8EF", outlier.size = 0.6, linewidth = 0.35) + labs(x = "Hierarchical cluster", y = "log2 fold change (Long - Short exposure)", title = "Long vs Short exposure effects by exploratory cluster")
v21_save(p, FIG_DIR, "Figure_10_protein_clustering_cluster_effect_distributions", cluster_table)
for (kk in sort(unique(km_result$K))) {
    shown <- count(km_result[km_result$K == kk, , drop = FALSE], Cluster, name = "N")
    p <- ggplot(shown, aes(factor(Cluster), N)) + geom_col(fill = "#3178A5", width = 0.65) + labs(x = "K-means cluster", y = "Protein groups", title = paste("Exploratory K-means sensitivity: K =", kk))
    v21_save(p, FIG_DIR, paste0("Figure_10_protein_clustering_kmeans_cluster_sizes_K", kk), shown)
}
cat("\nStage 11b exploratory DEP response-profile clustering completed.\n")
