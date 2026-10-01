# Post-freeze missingness robustness analysis. Writes only below this module.
rm(list = ls())
gc()

required <- c("limma", "statmod", "impute", "ggplot2")
missing_packages <- required[!vapply(required, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
if (length(missing_packages)) stop("Missing required package(s): ", paste(missing_packages, collapse = ", "))
suppressPackageStartupMessages({ library(limma); library(ggplot2) })

script_arg <- grep("^--file=", commandArgs(FALSE), value = TRUE)
if (length(script_arg) != 1L) stop("Run with Rscript so --file= is available.")
CODE_DIR <- dirname(normalizePath(sub("^--file=", "", script_arg), winslash = "/", mustWork = TRUE))
MODULE_DIR <- dirname(CODE_DIR)
DESC_DIR <- dirname(MODULE_DIR)
RESULT_DIR <- file.path(MODULE_DIR, "results")
FIGURE_DIR <- file.path(MODULE_DIR, "figures")
DIAGNOSTIC_DIR <- file.path(MODULE_DIR, "diagnostics")
for (d in c(RESULT_DIR, FIGURE_DIR, DIAGNOSTIC_DIR)) dir.create(d, recursive = TRUE, showWarnings = FALSE)

EXPR_FILE <- file.path(DESC_DIR, "PRIMARY_dose_log2_expression.csv.gz")
META_FILE <- file.path(DESC_DIR, "dose_defined_metadata.csv")
CANONICAL_FILE <- file.path(DESC_DIR, "limma_dose_analysis", "results", "01_PRIMARY", "PRIMARY_log2_dose_environment__High_vs_Low.csv")
DEP_FILE <- file.path(DESC_DIR, "limma_dose_analysis", "results", "09_DEP_characterization", "High_vs_Low_DEP_all.csv")
ANNOTATION_FILE <- file.path(DESC_DIR, "canonical_protein_annotation.csv")
FDR_CUTOFF <- 0.05
NUM_TOL <- 1e-10
SEED <- 20260925L

write_csv <- function(x, path) write.csv(x, path, row.names = FALSE, na = "")
assert <- function(ok, message) if (!isTRUE(ok)) stop(message, call. = FALSE)
finite_equal <- function(a, b) identical(is.na(a), is.na(b)) && all(a[is.finite(a)] == b[is.finite(a)])
save_plot <- function(p, stem, width = 7, height = 5) {
  ggsave(file.path(FIGURE_DIR, paste0(stem, ".png")), p, width = width, height = height, dpi = 300, bg = "white")
  ggsave(file.path(FIGURE_DIR, paste0(stem, ".pdf")), p, width = width, height = height, device = cairo_pdf, bg = "white")
}

inputs <- c(EXPR_FILE, META_FILE, CANONICAL_FILE, DEP_FILE, ANNOTATION_FILE)
assert(all(file.exists(inputs)), paste("Missing input(s):", paste(inputs[!file.exists(inputs)], collapse = "; ")))
expr_df <- read.csv(EXPR_FILE, check.names = FALSE, stringsAsFactors = FALSE)
meta <- read.csv(META_FILE, check.names = FALSE, stringsAsFactors = FALSE, na.strings = character(0))
canonical <- read.csv(CANONICAL_FILE, check.names = FALSE, stringsAsFactors = FALSE)
canonical_dep <- read.csv(DEP_FILE, check.names = FALSE, stringsAsFactors = FALSE)
annotation <- read.csv(ANNOTATION_FILE, check.names = FALSE, stringsAsFactors = FALSE)
assert(all(c("PG.ProteinGroups", "Gene_symbol", "Display_label") %in% names(canonical)), "Canonical Stage 07 annotation columns are absent.")
# The frozen Stage 07 table is authoritative and covers the complete 1,434-protein universe.
annotation <- canonical[, c("PG.ProteinGroups", "Gene_symbol", "Display_label")]
assert(!anyDuplicated(annotation$PG.ProteinGroups) && nrow(annotation) == 1434L, "Canonical Stage 07 annotation is incomplete or duplicated.")

required_meta <- c("UniqueSampleID", "TREAT1_clean", "condition")
assert(all(c("PG.ProteinGroups", required_meta) %in% c(names(expr_df), names(meta))), "Required input columns are absent.")
sample_ids <- setdiff(names(expr_df), "PG.ProteinGroups")
expr <- as.matrix(expr_df[, sample_ids, drop = FALSE]); storage.mode(expr) <- "double"
rownames(expr) <- expr_df$PG.ProteinGroups
assert(!any(is.infinite(expr), na.rm = TRUE), "Infinite expression values found.")

environment_aliases <- c("高海拔" = "high_stress", "湿热" = "high_temperature")
environment_labels <- as.character(meta$condition)
known <- environment_labels %in% names(environment_aliases)
environment_labels[known] <- unname(environment_aliases[environment_labels[known]])
meta$dose <- factor(meta$TREAT1_clean, levels = c("control", "low", "high"))
meta$environment <- factor(environment_labels, levels = c("high_stress", "high_temperature"))

group_n <- table(meta$dose)
missing_cells <- sum(is.na(expr))
missing_fraction <- mean(is.na(expr))
detection_by_group <- sapply(levels(meta$dose), function(g) rowMeans(is.finite(expr[, meta$dose == g, drop = FALSE])))
preflight <- data.frame(
  Check = c("matrix_rows_1434", "matrix_sample_columns_515", "metadata_rows_515", "protein_ids_unique",
            "sample_ids_unique", "matrix_ids_exactly_match_metadata", "missing_cells_46443",
            "missing_fraction_6.2887pct", "all_observed_values_finite", "canonical_rows_1434_unique",
            "canonical_dep_rows_256_unique", "canonical_dep_equals_stage07_fdr", "exposure_counts_153_186_176",
            "all_proteins_detection_ge_0.70_each_group"),
  Observed = c(nrow(expr), ncol(expr), nrow(meta), !anyDuplicated(expr_df$PG.ProteinGroups),
               !anyDuplicated(meta$UniqueSampleID), identical(sample_ids, meta$UniqueSampleID), missing_cells,
               sprintf("%.10f", missing_fraction), all(is.finite(expr[!is.na(expr)])),
               nrow(canonical) == 1434L && !anyDuplicated(canonical$PG.ProteinGroups),
               nrow(canonical_dep) == 256L && !anyDuplicated(canonical_dep$PG.ProteinGroups),
               setequal(canonical_dep$PG.ProteinGroups, canonical$PG.ProteinGroups[canonical$adj.P.Val < FDR_CUTOFF]),
               paste(unname(group_n), collapse = "/"), all(detection_by_group >= 0.70)),
  Passed = c(nrow(expr) == 1434L, ncol(expr) == 515L, nrow(meta) == 515L, !anyDuplicated(expr_df$PG.ProteinGroups),
             !anyDuplicated(meta$UniqueSampleID), identical(sample_ids, meta$UniqueSampleID), missing_cells == 46443L,
             abs(missing_fraction - 0.062887) <= 5e-7, all(is.finite(expr[!is.na(expr)])),
             nrow(canonical) == 1434L && !anyDuplicated(canonical$PG.ProteinGroups),
             nrow(canonical_dep) == 256L && !anyDuplicated(canonical_dep$PG.ProteinGroups),
             setequal(canonical_dep$PG.ProteinGroups, canonical$PG.ProteinGroups[canonical$adj.P.Val < FDR_CUTOFF]),
             identical(unname(as.integer(group_n)), c(153L, 186L, 176L)), all(detection_by_group >= 0.70)),
  stringsAsFactors = FALSE
)
write_csv(preflight, file.path(DIAGNOSTIC_DIR, "preflight_assertions.csv"))
if (!all(preflight$Passed)) stop("PREFLIGHT FAILED: ", paste(preflight$Check[!preflight$Passed], collapse = ", "))

design <- model.matrix(~ 0 + dose + environment, data = meta)
colnames(design) <- make.names(colnames(design))
assert(qr(design)$rank == ncol(design), "Primary design is not full rank.")
contrast <- makeContrasts(High_vs_Low = dosehigh - doselow, levels = design)

run_limma <- function(x, method) {
  fit <- limma::lmFit(x, design)
  fit <- limma::contrasts.fit(fit, contrast)
  fit <- limma::eBayes(fit, trend = TRUE, robust = TRUE)
  tab <- limma::topTable(fit, coef = "High_vs_Low", adjust.method = "BH", sort.by = "P", number = Inf)
  tab$PG.ProteinGroups <- rownames(tab)
  tab$Gene_symbol <- annotation$Gene_symbol[match(tab$PG.ProteinGroups, annotation$PG.ProteinGroups)]
  tab$Display_label <- annotation$Display_label[match(tab$PG.ProteinGroups, annotation$PG.ProteinGroups)]
  tab$Method <- method
  tab$Significant_FDR_0.05 <- !is.na(tab$adj.P.Val) & tab$adj.P.Val < FDR_CUTOFF
  tab <- tab[, c("PG.ProteinGroups", "Gene_symbol", "Display_label", "Method", "logFC", "AveExpr", "t", "P.Value", "adj.P.Val", "B", "Significant_FDR_0.05")]
  rownames(tab) <- NULL
  tab
}

# D0 is a strict gate.
D0 <- run_limma(expr, "PRIMARY_FROZEN_ANALYSIS")
fields <- c("logFC", "AveExpr", "t", "P.Value", "adj.P.Val", "B")
cmp <- merge(canonical[, c("PG.ProteinGroups", fields)], D0[, c("PG.ProteinGroups", fields)], by = "PG.ProteinGroups", suffixes = c("_canonical", "_D0"), sort = FALSE)
for (f in fields) cmp[[paste0("abs_diff_", f)]] <- abs(cmp[[paste0(f, "_canonical")]] - cmp[[paste0(f, "_D0")]])
cmp$Canonical_FDR_lt_0.05 <- cmp$adj.P.Val_canonical < FDR_CUTOFF
cmp$D0_FDR_lt_0.05 <- cmp$adj.P.Val_D0 < FDR_CUTOFF
write_csv(cmp, file.path(DIAGNOSTIC_DIR, "D0_canonical_comparison.csv"))
d0_summary <- data.frame(Field = fields,
                         Maximum_absolute_difference = vapply(fields, function(f) max(cmp[[paste0("abs_diff_", f)]], na.rm = TRUE), numeric(1)),
                         Proteins_outside_tolerance = vapply(fields, function(f) sum(cmp[[paste0("abs_diff_", f)]] > NUM_TOL, na.rm = TRUE), integer(1)),
                         Tolerance = NUM_TOL)
write_csv(d0_summary, file.path(DIAGNOSTIC_DIR, "D0_numerical_summary.csv"))
d0_dep <- D0$PG.ProteinGroups[D0$Significant_FDR_0.05]
d0_pass <- nrow(cmp) == 1434L && all(d0_summary$Proteins_outside_tolerance == 0L) &&
  identical(cmp$Canonical_FDR_lt_0.05, cmp$D0_FDR_lt_0.05) && length(d0_dep) == 256L && setequal(d0_dep, canonical_dep$PG.ProteinGroups)
write_csv(data.frame(D0_DEP_count = length(d0_dep), Canonical_DEP_count = nrow(canonical_dep),
                     DEP_set_identical = setequal(d0_dep, canonical_dep$PG.ProteinGroups), D0_gate_passed = d0_pass),
          file.path(DIAGNOSTIC_DIR, "D0_gate_summary.csv"))
if (!d0_pass) stop("D0 REPRODUCTION FAILED. D1-D3 were not run; inspect diagnostics.")
write_csv(D0, file.path(RESULT_DIR, "D0_PRIMARY_FROZEN_ANALYSIS.csv"))

# Descriptive missingness diagnostics, without imputation.
sample_missing <- data.frame(UniqueSampleID = sample_ids,
  exposure = c(control = "Control", low = "Short", high = "Long")[as.character(meta$dose)],
  environment = as.character(meta$environment), N_observed = colSums(is.finite(expr)),
  N_missing = colSums(is.na(expr)), missing_fraction = colMeans(is.na(expr)), stringsAsFactors = FALSE)
write_csv(sample_missing, file.path(RESULT_DIR, "sample_missingness.csv"))

protein_missing <- data.frame(PG.ProteinGroups = rownames(expr),
  Gene_symbol = annotation$Gene_symbol[match(rownames(expr), annotation$PG.ProteinGroups)],
  Display_label = annotation$Display_label[match(rownames(expr), annotation$PG.ProteinGroups)],
  overall_detection_fraction = rowMeans(is.finite(expr)),
  Control_detection_fraction = detection_by_group[, "control"], Short_detection_fraction = detection_by_group[, "low"], Long_detection_fraction = detection_by_group[, "high"])
protein_missing$overall_missing_fraction <- 1 - protein_missing$overall_detection_fraction
protein_missing$Control_missing_fraction <- 1 - protein_missing$Control_detection_fraction
protein_missing$Short_missing_fraction <- 1 - protein_missing$Short_detection_fraction
protein_missing$Long_missing_fraction <- 1 - protein_missing$Long_detection_fraction
protein_missing$Short_minus_Control_detection <- protein_missing$Short_detection_fraction - protein_missing$Control_detection_fraction
protein_missing$Long_minus_Control_detection <- protein_missing$Long_detection_fraction - protein_missing$Control_detection_fraction
protein_missing$Long_minus_Short_detection <- protein_missing$Long_detection_fraction - protein_missing$Short_detection_fraction
protein_missing$maximum_group_detection_rate_difference <- apply(protein_missing[, c("Control_detection_fraction", "Short_detection_fraction", "Long_detection_fraction")], 1, function(z) max(z) - min(z))
protein_missing$maximum_absolute_group_difference <- apply(abs(protein_missing[, c("Short_minus_Control_detection", "Long_minus_Control_detection", "Long_minus_Short_detection")]), 1, max)
write_csv(protein_missing, file.path(RESULT_DIR, "protein_missingness.csv"))

observed_mean <- rowMeans(expr, na.rm = TRUE)
observed_median <- apply(expr, 1, median, na.rm = TRUE)
abundance_overall <- data.frame(PG.ProteinGroups = rownames(expr), observed_mean = observed_mean, observed_median = observed_median, missing_fraction = rowMeans(is.na(expr)))
group_abundance <- do.call(rbind, lapply(levels(meta$dose), function(g) {
  block <- expr[, meta$dose == g, drop = FALSE]
  data.frame(PG.ProteinGroups = rownames(expr), exposure = c(control = "Control", low = "Short", high = "Long")[[g]],
             observed_mean = rowMeans(block, na.rm = TRUE), observed_median = apply(block, 1, median, na.rm = TRUE), missing_fraction = rowMeans(is.na(block)))
}))
cor_rows <- rbind(
  data.frame(Scope = "Overall", Exposure = "All", Abundance = c("Observed_mean", "Observed_median"),
             Spearman_rho = c(cor(observed_mean, abundance_overall$missing_fraction, method = "spearman"), cor(observed_median, abundance_overall$missing_fraction, method = "spearman")), N = nrow(expr)),
  do.call(rbind, lapply(split(group_abundance, group_abundance$exposure), function(z) data.frame(Scope = "Group_specific", Exposure = z$exposure[1], Abundance = c("Observed_mean", "Observed_median"),
             Spearman_rho = c(cor(z$observed_mean, z$missing_fraction, method = "spearman"), cor(z$observed_median, z$missing_fraction, method = "spearman")), N = nrow(z)))))
write_csv(abundance_overall, file.path(RESULT_DIR, "protein_abundance_missingness.csv"))
write_csv(group_abundance, file.path(RESULT_DIR, "group_abundance_missingness.csv"))
write_csv(cor_rows, file.path(RESULT_DIR, "abundance_missingness_spearman.csv"))

canonical_mask <- protein_missing$PG.ProteinGroups %in% canonical_dep$PG.ProteinGroups
imbalance_summary <- do.call(rbind, lapply(list(All_1434 = rep(TRUE, nrow(protein_missing)), Canonical_256_DEP = canonical_mask, Noncanonical_1178 = !canonical_mask), function(mask) {
  data.frame(N = sum(mask), Median_max_abs_difference = median(protein_missing$maximum_absolute_group_difference[mask]),
             P95_max_abs_difference = unname(quantile(protein_missing$maximum_absolute_group_difference[mask], .95)),
             Maximum_abs_difference = max(protein_missing$maximum_absolute_group_difference[mask]))
}))
imbalance_summary$Set <- rownames(imbalance_summary); rownames(imbalance_summary) <- NULL
imbalance_summary <- imbalance_summary[, c("Set", "N", "Median_max_abs_difference", "P95_max_abs_difference", "Maximum_abs_difference")]
write_csv(imbalance_summary, file.path(RESULT_DIR, "group_detection_imbalance_summary.csv"))
write_csv(head(protein_missing[order(-protein_missing$maximum_absolute_group_difference), ], 50), file.path(RESULT_DIR, "largest_group_detection_imbalances_top50.csv"))

# D1-D3 copies; finite observed entries must remain bit-for-bit unchanged.
D1_expr <- expr; D1_expr[is.na(D1_expr)] <- 0
assert(all(D1_expr[is.finite(expr)] == expr[is.finite(expr)]), "D1 altered observed values.")
D1 <- run_limma(D1_expr, "ZERO_REPLACEMENT_STRESS_TEST")
write_csv(D1, file.path(RESULT_DIR, "D1_ZERO_REPLACEMENT_STRESS_TEST.csv"))

set.seed(SEED)
D2_expr <- expr
d2_rows <- lapply(seq_len(ncol(expr)), function(j) {
  observed <- expr[, j][is.finite(expr[, j])]; mu <- mean(observed); sigma <- sd(observed); nimp <- sum(is.na(expr[, j]))
  assert(is.finite(mu) && is.finite(sigma) && sigma > 0, paste("Invalid D2 parameters for sample", colnames(expr)[j]))
  vals <- if (nimp) rnorm(nimp, mu - 1.8 * sigma, 0.3 * sigma) else numeric()
  D2_expr[is.na(expr[, j]), j] <<- vals
  data.frame(UniqueSampleID = colnames(expr)[j], mu = mu, sigma = sigma, N_imputed = nimp,
             Imputed_min = if(nimp) min(vals) else NA, Imputed_Q25 = if(nimp) unname(quantile(vals,.25)) else NA,
             Imputed_median = if(nimp) median(vals) else NA, Imputed_mean = if(nimp) mean(vals) else NA,
             Imputed_Q75 = if(nimp) unname(quantile(vals,.75)) else NA, Imputed_max = if(nimp) max(vals) else NA)
})
assert(all(D2_expr[is.finite(expr)] == expr[is.finite(expr)]), "D2 altered observed values.")
write_csv(do.call(rbind, d2_rows), file.path(RESULT_DIR, "D2_sample_imputation_diagnostics.csv"))
D2 <- run_limma(D2_expr, "LEFT_CENSORED_DOWNSHIFT_GAUSSIAN")
write_csv(D2, file.path(RESULT_DIR, "D2_LEFT_CENSORED_DOWNSHIFT_GAUSSIAN.csv"))

row_missing <- rowMeans(is.na(expr)); col_missing <- colMeans(is.na(expr))
d3_constraints <- data.frame(Constraint = c("maximum_row_missingness_le_0.5", "maximum_column_missingness_le_0.8"),
                             Observed_maximum = c(max(row_missing), max(col_missing)), Limit = c(0.5, 0.8),
                             Passed = c(max(row_missing) <= 0.5, max(col_missing) <= 0.8))
write_csv(d3_constraints, file.path(DIAGNOSTIC_DIR, "D3_missingness_constraints.csv"))
if (!all(d3_constraints$Passed)) stop("D3 constraints failed; parameters were not changed.")
D3_expr <- impute::impute.knn(expr, k = 10, rowmax = 0.5, colmax = 0.8, maxp = 1500, rng.seed = SEED)$data
assert(all(D3_expr[is.finite(expr)] == expr[is.finite(expr)]), "D3 altered observed values.")
D3 <- run_limma(D3_expr, "KNN_IMPUTATION")
write_csv(D3, file.path(RESULT_DIR, "D3_KNN_IMPUTATION.csv"))

tabs <- list(D0 = D0, D1 = D1, D2 = D2, D3 = D3)
aligned <- lapply(tabs, function(z) z[match(rownames(expr), z$PG.ProteinGroups), ])
comparison_metric <- function(method) {
  z <- aligned[[method]]; ref <- aligned$D0; delta <- abs(z$logFC - ref$logFC)
  sig0 <- ref$Significant_FDR_0.05; sigz <- z$Significant_FDR_0.05
  data.frame(Method = method, N_tested = nrow(z), N_FDR_lt_0.05 = sum(sigz),
    Pearson_logFC_with_D0 = cor(ref$logFC, z$logFC), Spearman_logFC_with_D0 = cor(ref$logFC, z$logFC, method = "spearman"),
    Median_absolute_delta_logFC = median(delta), P95_absolute_delta_logFC = unname(quantile(delta, .95)), Maximum_absolute_delta_logFC = max(delta),
    Rank_correlation = cor(rank(ref$P.Value), rank(z$P.Value), method = "spearman"),
    Canonical_256_retained = sum(canonical_mask & sigz), Canonical_256_lost = sum(canonical_mask & !sigz),
    Noncanonical_newly_FDR_lt_0.05 = sum(!canonical_mask & sigz), DEP_set_Jaccard = sum(sig0 & sigz) / sum(sig0 | sigz),
    Sign_concordance_logFC = mean(sign(ref$logFC) == sign(z$logFC)))
}
robustness <- do.call(rbind, lapply(c("D1", "D2", "D3"), comparison_metric))
write_csv(robustness, file.path(RESULT_DIR, "robustness_summary.csv"))

master <- protein_missing[, c("PG.ProteinGroups", "Gene_symbol", "Display_label", "Control_detection_fraction", "Short_detection_fraction", "Long_detection_fraction", "Control_missing_fraction", "Short_missing_fraction", "Long_missing_fraction")]
for (m in names(aligned)) {
  master[[paste0(m, "_logFC")]] <- aligned[[m]]$logFC
  master[[paste0(m, "_FDR")]] <- aligned[[m]]$adj.P.Val
  master[[paste0(m, "_significant")]] <- aligned[[m]]$Significant_FDR_0.05
}
write_csv(master, file.path(RESULT_DIR, "master_comparison.csv"))

canonical_stability <- do.call(rbind, lapply(c("D1", "D2", "D3"), function(m) {
  ref <- aligned$D0[canonical_mask, ]; z <- aligned[[m]][canonical_mask, ]; delta <- abs(z$logFC - ref$logFC)
  data.frame(Method = m, N = 256L, Direction_concordance = mean(sign(ref$logFC) == sign(z$logFC)),
    Pearson_logFC = cor(ref$logFC, z$logFC), Spearman_logFC = cor(ref$logFC, z$logFC, method = "spearman"),
    Median_absolute_delta_logFC = median(delta), P95_absolute_delta_logFC = unname(quantile(delta, .95)),
    FDR_retention_count = sum(z$Significant_FDR_0.05), FDR_retention_percent = 100 * mean(z$Significant_FDR_0.05),
    Rank_stability = cor(rank(ref$P.Value), rank(z$P.Value), method = "spearman"))
}))
write_csv(canonical_stability, file.path(RESULT_DIR, "canonical_256_stability_summary.csv"))

flags <- master[canonical_mask, c("PG.ProteinGroups", "Gene_symbol", "Display_label", "D0_logFC", "D0_FDR")]
for (m in c("D1", "D2", "D3")) {
  flags[[paste0(m, "_direction_changed")]] <- sign(master[[paste0(m, "_logFC")]][canonical_mask]) != sign(master$D0_logFC[canonical_mask])
  flags[[paste0(m, "_abs_delta_logFC_ge_0.5")]] <- abs(master[[paste0(m, "_logFC")]][canonical_mask] - master$D0_logFC[canonical_mask]) >= 0.5
  flags[[paste0(m, "_lost_FDR")]] <- master[[paste0(m, "_FDR")]][canonical_mask] >= FDR_CUTOFF
  flags[[paste0(m, "_Any_sensitivity_flag")]] <- flags[[paste0(m, "_direction_changed")]] | flags[[paste0(m, "_abs_delta_logFC_ge_0.5")]] | flags[[paste0(m, "_lost_FDR")]]
}
flags$Any_sensitivity_flag <- apply(flags[, grep("_Any_sensitivity_flag$", names(flags)), drop = FALSE], 1, any)
write_csv(flags, file.path(RESULT_DIR, "canonical_256_sensitivity_flags.csv"))

# Local Stage 11a rule, restricted to the frozen canonical 256.
classify_pattern <- function(control, short, long, tolerance = 0.05) {
  bin <- function(x) ifelse(x > tolerance, 1L, ifelse(x < -tolerance, -1L, 0L))
  rules <- c("1:1"="Ordered_increase", "-1:-1"="Ordered_decrease", "1:-1"="Short_peak", "-1:1"="Short_trough",
             "0:1"="Long_elevation", "0:-1"="Long_suppression", "1:0"="Short_elevation_plateau", "-1:0"="Short_suppression_plateau", "0:0"="Adjacent_changes_within_tolerance")
  unname(rules[paste(bin(short-control), bin(long-short), sep=":")])
}
pattern_table <- function(x, method) {
  ids <- canonical_dep$PG.ProteinGroups; z <- x[ids, , drop = FALSE]
  means <- sapply(levels(meta$dose), function(g) rowMeans(z[, meta$dose == g, drop = FALSE], na.rm = TRUE))
  data.frame(PG.ProteinGroups = ids, Method = method, Control = means[,"control"], Short = means[,"low"], Long = means[,"high"],
             Pattern = classify_pattern(means[,"control"], means[,"low"], means[,"high"]), stringsAsFactors = FALSE)
}
patterns <- list(D0 = pattern_table(expr, "D0"))
d0_counts <- table(patterns$D0$Pattern)
pattern_gate <- unname(d0_counts["Short_peak"]) == 249L && unname(d0_counts["Long_suppression"]) == 7L && sum(d0_counts) == 256L
write_csv(data.frame(Pattern = names(d0_counts), N = as.integer(d0_counts)), file.path(DIAGNOSTIC_DIR, "D0_stage11a_pattern_counts.csv"))
if (!pattern_gate) stop("D0 Stage 11a local reproduction failed; pattern robustness was not run.")
patterns$D1 <- pattern_table(D1_expr, "D1"); patterns$D2 <- pattern_table(D2_expr, "D2"); patterns$D3 <- pattern_table(D3_expr, "D3")
pattern_summary <- do.call(rbind, lapply(c("D1","D2","D3"), function(m) data.frame(Method=m, Retained=sum(patterns[[m]]$Pattern == patterns$D0$Pattern), Changed=sum(patterns[[m]]$Pattern != patterns$D0$Pattern))))
write_csv(pattern_summary, file.path(RESULT_DIR, "stage11a_pattern_stability_summary.csv"))
transitions <- do.call(rbind, lapply(c("D1","D2","D3"), function(m) {
  z <- as.data.frame(table(D0_Pattern=patterns$D0$Pattern, Sensitivity_Pattern=patterns[[m]]$Pattern), stringsAsFactors=FALSE); z$Method <- m; z[z$Freq > 0, c("Method","D0_Pattern","Sensitivity_Pattern","Freq")]
}))
write_csv(transitions, file.path(RESULT_DIR, "stage11a_pattern_transition_matrix.csv"))
changed <- do.call(rbind, lapply(c("D1","D2","D3"), function(m) {
  mask <- patterns[[m]]$Pattern != patterns$D0$Pattern
  data.frame(Method=rep(m, sum(mask)), PG.ProteinGroups=patterns$D0$PG.ProteinGroups[mask], D0_Pattern=patterns$D0$Pattern[mask], Sensitivity_Pattern=patterns[[m]]$Pattern[mask])
}))
write_csv(changed, file.path(RESULT_DIR, "stage11a_changed_proteins.csv"))
long_supp <- patterns$D0$Pattern == "Long_suppression"
long_supp_out <- patterns$D0[long_supp, c("PG.ProteinGroups","Control","Short","Long","Pattern")]
names(long_supp_out)[names(long_supp_out)=="Pattern"] <- "D0_Pattern"
for(m in c("D1","D2","D3")) long_supp_out[[paste0(m,"_Pattern")]] <- patterns[[m]]$Pattern[long_supp]
write_csv(long_supp_out, file.path(RESULT_DIR, "stage11a_canonical_seven_long_suppression.csv"))

# Required diagnostic figures.
theme_set(theme_classic(base_size = 10))
p1 <- ggplot(sample_missing, aes(exposure, missing_fraction, fill=exposure)) + geom_boxplot(outlier.shape=NA, width=.55) + geom_jitter(width=.15, alpha=.35, size=.8) + scale_fill_manual(values=c(Control="#A6A6A6",Short="#4A85B3",Long="#FF6347")) + guides(fill="none") + labs(x=NULL,y="Missing fraction",title="Sample missingness by exposure")
save_plot(p1, "01_sample_missing_fraction_by_exposure")
p2 <- ggplot(abundance_overall, aes(observed_mean, missing_fraction)) + geom_point(alpha=.45,size=1) + geom_smooth(method="loess",se=FALSE,color="#FF6347") + labs(x="Observed mean log2 abundance",y="Missing fraction",title="Protein missingness and observed abundance")
save_plot(p2, "02_protein_missing_fraction_vs_observed_mean")
det_long <- rbind(data.frame(Exposure="Control",Detection=protein_missing$Control_detection_fraction),data.frame(Exposure="Short",Detection=protein_missing$Short_detection_fraction),data.frame(Exposure="Long",Detection=protein_missing$Long_detection_fraction))
p3 <- ggplot(det_long,aes(Exposure,Detection,fill=Exposure))+geom_violin(trim=TRUE)+geom_boxplot(width=.15,outlier.shape=NA,fill="white")+scale_fill_manual(values=c(Control="#A6A6A6",Short="#4A85B3",Long="#FF6347"))+guides(fill="none")+labs(x=NULL,y="Detection fraction",title="Protein detection rates by exposure")
save_plot(p3,"03_group_detection_rate_comparison")
for(m in c("D1","D2","D3")){ z<-data.frame(D0=master$D0_logFC,Method=master[[paste0(m,"_logFC")]]); p<-ggplot(z,aes(D0,Method))+geom_abline(slope=1,intercept=0,color="grey60")+geom_point(alpha=.45,size=1)+coord_equal()+labs(x="D0 logFC",y=paste(m,"logFC"),title=paste("D0 versus",m,"logFC")); save_plot(p,paste0("0",as.integer(sub("D","",m))+3,"_D0_vs_",m,"_logFC")) }
delta_long <- do.call(rbind,lapply(c("D1","D2","D3"),function(m)data.frame(Method=m,Delta_logFC=master[[paste0(m,"_logFC")]][canonical_mask]-master$D0_logFC[canonical_mask])))
p7<-ggplot(delta_long,aes(Method,Delta_logFC,fill=Method))+geom_violin(trim=TRUE)+geom_boxplot(width=.14,outlier.shape=NA,fill="white")+geom_hline(yintercept=0,color="grey50")+guides(fill="none")+labs(x=NULL,y="Sensitivity minus D0 logFC",title="Canonical 256 effect-size sensitivity")
save_plot(p7,"07_canonical_256_delta_logFC")
dep_plot<-data.frame(Method=rep(robustness$Method,3),Category=rep(c("Retained canonical","Lost canonical","New noncanonical"),each=3),N=c(robustness$Canonical_256_retained,robustness$Canonical_256_lost,robustness$Noncanonical_newly_FDR_lt_0.05))
p8<-ggplot(dep_plot,aes(Method,N,fill=Category))+geom_col(position="dodge")+labs(x=NULL,y="Proteins",title="DEP retention, loss, and gain")
save_plot(p8,"08_DEP_retention_gain_loss")
p9<-ggplot(transitions,aes(D0_Pattern,Sensitivity_Pattern,size=Freq,color=Method))+geom_point(alpha=.8)+facet_wrap(~Method)+scale_size_area(max_size=10)+theme(axis.text.x=element_text(angle=45,hjust=1))+labs(x="D0 pattern",y="Sensitivity pattern",title="Stage 11a pattern transitions")
save_plot(p9,"09_stage11a_pattern_transitions",9,5)

summary_lines <- c(
  "POST-FREEZE MISSINGNESS ROBUSTNESS ANALYSIS", sprintf("Completed: %s", format(Sys.time(), tz="America/Los_Angeles")),
  "Preflight: PASS", "D0 reproduction: PASS", sprintf("D0 DEP: %d; exact canonical set: %s",length(d0_dep),setequal(d0_dep,canonical_dep$PG.ProteinGroups)),
  "D0 maximum absolute differences:", paste(d0_summary$Field,format(d0_summary$Maximum_absolute_difference,scientific=TRUE),sep=" = "),
  "Abundance-missingness Spearman correlations:", paste(cor_rows$Scope,cor_rows$Exposure,cor_rows$Abundance,sprintf("rho=%.6f",cor_rows$Spearman_rho)),
  "Robustness summary:", capture.output(print(robustness,row.names=FALSE)),
  "Canonical 256 stability:", capture.output(print(canonical_stability,row.names=FALSE)),
  "Stage 11a D0: Short_peak=249; Long_suppression=7", "Stage 11a stability:", capture.output(print(pattern_summary,row.names=FALSE)),
  "Warnings/errors: none raised to completion."
)
writeLines(summary_lines,file.path(RESULT_DIR,"execution_summary.txt"),useBytes=TRUE)
cat(paste(summary_lines,collapse="\n"),"\n")
