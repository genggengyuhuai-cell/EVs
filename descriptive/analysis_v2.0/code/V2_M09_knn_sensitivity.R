#!/usr/bin/env Rscript
# V2 M09 — frozen-protocol KNN missingness sensitivity for the M05 E estimand.
# Authority: ANALYSIS_PLAN_v2.0, Module 09.

suppressPackageStartupMessages({
  library(limma)
  library(impute)
})

root <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
v2 <- file.path(root, "descriptive", "analysis_v2.0")
out_dir <- file.path(v2, "M09_missingness_sensitivity", "KNN_sensitivity")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

log2_path <- file.path(root, "descriptive", "PRIMARY_dose_log2_expression.csv.gz")
meta_path <- file.path(root, "descriptive", "dose_defined_metadata.csv")
universe_path <- file.path(v2, "universes", "Q515.csv")
m05_path <- file.path(v2, "M05_overall_exposure", "M05_overall_exposure_AE_results.csv")
annotation_path <- file.path(root, "descriptive", "canonical_protein_annotation.csv")
snapshot_path <- file.path(v2, "M09_pre_repair_snapshot", "M09_KNN_E_comparison.csv")

for (p in c(log2_path, meta_path, universe_path, m05_path, annotation_path, snapshot_path)) {
  if (!file.exists(p)) stop("M09 missing required input: ", p)
}

K <- 10L
ROWMAX <- 0.5
COLMAX <- 0.8
MAXP <- 1500L
RNG_SEED <- 20260925L

log2mat <- read.csv(gzfile(log2_path), check.names = FALSE, row.names = 1)
meta <- read.csv(meta_path, check.names = FALSE, stringsAsFactors = FALSE)
univ <- read.csv(universe_path, check.names = FALSE, stringsAsFactors = FALSE)
m05 <- read.csv(m05_path, check.names = FALSE, stringsAsFactors = FALSE)
annotation <- read.csv(annotation_path, check.names = FALSE, stringsAsFactors = FALSE)
old_cmp <- read.csv(snapshot_path, check.names = FALSE, stringsAsFactors = FALSE)

q515_ids <- univ$PG.ProteinGroups[univ$Q515 %in% TRUE]
if (length(q515_ids) != 1430L || anyDuplicated(q515_ids)) {
  stop("M09 Q515 contract failed: expected 1,430 unique protein groups")
}
if (!all(q515_ids %in% rownames(log2mat))) stop("M09 Q515 proteins missing from input matrix")

sample_ids <- colnames(log2mat)
if (length(sample_ids) != 515L || anyDuplicated(sample_ids)) {
  stop("M09 sample contract failed: expected 515 unique matrix columns")
}
rownames(meta) <- meta$UniqueSampleID
if (!all(sample_ids %in% rownames(meta))) stop("M09 metadata missing matrix samples")
m <- meta[sample_ids, , drop = FALSE]
if (!identical(rownames(m), sample_ids)) stop("M09 metadata/sample order mismatch")

m$Group <- factor(m$TREAT1_clean, c("control", "low", "high"),
                  c("Control", "Low", "High"))
site_to_env <- function(site) {
  ifelse(grepl("^XZ_", site), "High_altitude",
         ifelse(grepl("^(FJ_|GZ_)", site), "Humid_hot", NA_character_))
}
m$Environment <- factor(site_to_env(m$group), c("Humid_hot", "High_altitude"))
if (anyNA(m$Group) || anyNA(m$Environment)) stop("M09 Group/Environment mapping failed")

nC <- sum(m$Group == "Control")
nL <- sum(m$Group == "Low")
nH <- sum(m$Group == "High")
if (!identical(c(nC, nL, nH), c(153L, 186L, 176L))) {
  stop("M09 group counts do not match frozen M05")
}
wL <- nL / (nL + nH)
wH <- nH / (nL + nH)

y <- as.matrix(log2mat[q515_ids, sample_ids, drop = FALSE])
storage.mode(y) <- "numeric"
if (!identical(rownames(y), q515_ids) || !identical(colnames(y), sample_ids)) {
  stop("M09 input order changed during Q515 subsetting")
}
if (any(is.infinite(y))) stop("M09 input contains infinite abundance values")

missing_before <- sum(is.na(y))
row_missing_fraction <- rowMeans(is.na(y))
col_missing_fraction <- colMeans(is.na(y))
rowmax_rows <- which(row_missing_fraction > ROWMAX)
colmax_columns <- which(col_missing_fraction > COLMAX)
if (length(colmax_columns)) {
  stop("M09 colmax contract failed: at least one sample exceeds 80% missingness")
}

# Diagnostic exposure to impute's documented column-mean fallback. This does
# not supply the analytical result; the public impute.knn call below does.
# With Q515 (1,430 rows) <= maxp (1,500), no recursive block split is used.
diagnose_knn_fallback <- function(x, k, rowmax, maxp) {
  imiss_all <- is.na(x)
  row_nmiss <- rowSums(imiss_all)
  row_excluded <- row_nmiss > trunc(rowmax * ncol(x))
  x0 <- x
  x0[imiss_all] <- 0
  keep <- !row_excluded
  x_keep <- x0[keep, , drop = FALSE]
  imiss_keep <- imiss_all[keep, , drop = FALSE]
  storage.mode(x_keep) <- "double"
  storage.mode(imiss_keep) <- "integer"
  irmiss <- as.integer(rowSums(imiss_keep))
  if (nrow(x_keep) > maxp) {
    return(list(observable = FALSE, neighbor_fallback_cells = NA_integer_,
                neighbor_fallback_rows = NA_integer_, neighbor_fallback_columns = NA_integer_,
                neighbor_fallback_row_indices = integer(),
                neighbor_fallback_column_indices = integer()))
  }
  pre_fallback <- impute:::knnimp.internal(
    x_keep, as.integer(k), imiss_keep, irmiss,
    as.integer(nrow(x_keep)), as.integer(ncol(x_keep)), maxp = as.integer(maxp)
  )
  unresolved <- is.na(pre_fallback)
  list(
    observable = TRUE,
    neighbor_fallback_cells = sum(unresolved),
    neighbor_fallback_rows = sum(rowSums(unresolved) > 0),
    neighbor_fallback_columns = sum(colSums(unresolved) > 0),
    neighbor_fallback_row_indices = which(keep)[rowSums(unresolved) > 0],
    neighbor_fallback_column_indices = which(colSums(unresolved) > 0)
  )
}

fallback_diag <- diagnose_knn_fallback(y, K, ROWMAX, MAXP)
rowmax_fallback_cells <- sum(is.na(y[rowmax_rows, , drop = FALSE]))
rowmax_fallback_columns <- if (length(rowmax_rows)) {
  which(colSums(is.na(y[rowmax_rows, , drop = FALSE])) > 0)
} else integer()
total_fallback_rows <- if (fallback_diag$observable) {
  length(unique(c(rowmax_rows, fallback_diag$neighbor_fallback_row_indices)))
} else NA_integer_
total_fallback_columns <- if (fallback_diag$observable) {
  length(unique(c(rowmax_fallback_columns, fallback_diag$neighbor_fallback_column_indices)))
} else NA_integer_

knn <- impute::impute.knn(
  y, k = K, rowmax = ROWMAX, colmax = COLMAX,
  maxp = MAXP, rng.seed = RNG_SEED
)
y_imp <- knn$data

if (!identical(dim(y_imp), dim(y))) stop("M09 imputation changed matrix dimensions")
if (!identical(rownames(y_imp), rownames(y)) || !identical(colnames(y_imp), colnames(y))) {
  stop("M09 imputation changed protein or sample order")
}
if (!isTRUE(all.equal(y_imp[!is.na(y)], y[!is.na(y)], tolerance = 0))) {
  stop("M09 imputation altered observed abundance values")
}
if (anyNA(y_imp)) stop("M09 imputation left unresolved NA values")
if (any(!is.finite(y_imp))) stop("M09 imputation produced non-finite abundance values")

design <- model.matrix(~0 + Group + Environment, data = m)
if (qr(design)$rank != ncol(design)) stop("M09 M05-compatible design is not full rank")
e_vec <- setNames(rep(0, ncol(design)), colnames(design))
e_vec["GroupLow"] <- wL
e_vec["GroupHigh"] <- wH
e_vec["GroupControl"] <- -1
contrast <- matrix(e_vec, ncol = 1, dimnames = list(names(e_vec), "E"))
design2 <- limma::contrastAsCoef(design, contrast)[["design"]]

fit <- limma::lmFit(y_imp, design2)
fit <- limma::eBayes(fit, trend = TRUE, robust = TRUE)
b <- fit$coefficients[, "E"]
se <- fit$stdev.unscaled[, "E"] * sqrt(fit$s2.post)
df_total <- fit$df.total
p_raw <- 2 * pt(-abs(b / se), df = df_total)
fdr <- p.adjust(p_raw, method = "BH")

if (nrow(m05) != length(q515_ids) || anyDuplicated(m05$PG.ProteinGroups)) {
  stop("M09 frozen M05 output does not contain 1,430 unique proteins")
}
m05 <- m05[match(q515_ids, m05$PG.ProteinGroups), , drop = FALSE]
if (!identical(m05$PG.ProteinGroups, q515_ids)) stop("M09 could not align frozen M05 output")
if (!all(m05$Estimable %in% TRUE)) stop("M09 expected all Q515 M05 effects to be estimable")

gene_map <- setNames(annotation$Gene_symbol, annotation$PG.ProteinGroups)
direction <- function(z) ifelse(z > 0, "Positive", ifelse(z < 0, "Negative", "Zero"))

effect <- data.frame(
  Protein_ID = q515_ids,
  Gene_symbol = unname(gene_map[q515_ids]),
  E_primary = m05$log2FC_E,
  E_knn = unname(b[q515_ids]),
  stringsAsFactors = FALSE
)
effect$Delta_E <- effect$E_knn - effect$E_primary
effect$Absolute_Delta_E <- abs(effect$Delta_E)
effect$Direction_primary <- direction(effect$E_primary)
effect$Direction_knn <- direction(effect$E_knn)
effect$Direction_concordant <- effect$Direction_primary == effect$Direction_knn
effect$Primary_P <- m05$P_raw
effect$Primary_FDR <- m05$BH_FDR_AE
effect$KNN_P <- unname(p_raw[q515_ids])
effect$KNN_FDR <- unname(fdr[q515_ids])
effect$M09_estimable <- is.finite(effect$E_knn) & is.finite(effect$KNN_P)

if (anyDuplicated(effect$Protein_ID) || nrow(effect) != 1430L) stop("M09 effect output ID failure")
if (!all(effect$M09_estimable)) stop("M09 produced non-estimable KNN effects")

pearson <- cor(effect$E_primary, effect$E_knn, method = "pearson")
spearman <- cor(effect$E_primary, effect$E_knn, method = "spearman")
direction_n <- sum(effect$Direction_concordant)
sign_flips <- sum(!effect$Direction_concordant)
primary_sig <- effect$Primary_FDR < 0.05
knn_sig <- effect$KNN_FDR < 0.05

diagnostics <- data.frame(
  Metric = c(
    "input_rows", "input_columns", "missing_values_before", "missing_fraction_before",
    "missing_values_after", "rows_exceeding_rowmax", "columns_exceeding_colmax",
    "rowmax_fallback_rows", "rowmax_fallback_cells",
    "neighbor_column_mean_fallback_observable", "neighbor_column_mean_fallback_cells",
    "neighbor_column_mean_fallback_rows", "neighbor_column_mean_fallback_columns",
    "total_fallback_rows", "total_fallback_columns", "unresolved_NA_after",
    "maxp_block_split_used", "sample_order_unchanged", "protein_order_unchanged",
    "observed_values_unchanged", "group_counts", "environment_missing", "impute_version"
  ),
  Value = c(
    nrow(y), ncol(y), missing_before, sprintf("%.12f", missing_before / length(y)),
    sum(is.na(y_imp)), length(rowmax_rows), length(colmax_columns),
    length(rowmax_rows), rowmax_fallback_cells,
    fallback_diag$observable, fallback_diag$neighbor_fallback_cells,
    fallback_diag$neighbor_fallback_rows, fallback_diag$neighbor_fallback_columns,
    total_fallback_rows, total_fallback_columns,
    sum(is.na(y_imp)), nrow(y) > MAXP,
    identical(colnames(y_imp), sample_ids), identical(rownames(y_imp), q515_ids),
    isTRUE(all.equal(y_imp[!is.na(y)], y[!is.na(y)], tolerance = 0)),
    sprintf("Control=%d; Low=%d; High=%d", nC, nL, nH), sum(is.na(m$Environment)),
    as.character(utils::packageVersion("impute"))
  ),
  stringsAsFactors = FALSE
)

old_e <- old_cmp$E_knn[match(effect$Protein_ID, old_cmp$PG.ProteinGroups)]
old_primary <- old_cmp$E_primary[match(effect$Protein_ID, old_cmp$PG.ProteinGroups)]
if (anyNA(old_e) || anyNA(old_primary)) stop("M09 old snapshot comparison alignment failed")
old_pearson <- cor(old_primary, old_e)
old_spearman <- cor(old_primary, old_e, method = "spearman")
old_direction_n <- sum(sign(old_primary) == sign(old_e))
fig3_changed <- !isTRUE(all.equal(old_e, effect$E_knn, tolerance = 0))

repair_comparison <- data.frame(
  Metric = c(
    "Status", "Method", "Neighbor_or_distance", "Aggregation", "k", "Fallback",
    "Input_scale", "Sample_universe", "Protein_universe", "Estimator",
    "Pearson_E_correlation", "Spearman_E_correlation", "Direction_concordance",
    "Primary_significant_count", "Sensitivity_significant_count", "Fig3c_source_data"
  ),
  Old = c(
    "PRE_REPAIR_INVALIDATED", "Custom correlation-neighbor procedure",
    "Descending raw protein-protein correlation; <5-overlap candidates kept at zero; computed NA not explicitly handled",
    "Sample-wise unweighted neighbor median", "10",
    "Silent target-row median for remaining NA", "Q515 log2 abundance", "515",
    "Q515 (1430)", "M05-like E model", sprintf("%.12f", old_pearson),
    sprintf("%.12f", old_spearman), sprintf("%d/%d (%.6f%%)", old_direction_n, nrow(effect), 100 * old_direction_n / nrow(effect)),
    "NOT_AVAILABLE", "NOT_AVAILABLE", "Old M09_KNN_E_comparison.csv"
  ),
  New = c(
    "POST_PHASE3_REPAIR_CURRENT", "impute::impute.knn",
    "Euclidean distance in protein space on available target coordinates",
    "Arithmetic mean of available neighbor values", as.character(K),
    "Package rowmax and column-mean fallback rules", "Q515 log2 abundance", "515",
    "Q515 (1430)", "Exact frozen M05 E estimator", sprintf("%.12f", pearson),
    sprintf("%.12f", spearman), sprintf("%d/%d (%.6f%%)", direction_n, nrow(effect), 100 * direction_n / nrow(effect)),
    as.character(sum(primary_sig)), as.character(sum(knn_sig)), "Repaired M09_EFFECT_COMPARISON.csv"
  ),
  Changed = c(
    "YES", "YES", "YES", "YES", "NO", "YES", "NO", "NO", "NO", "NO",
    as.character(abs(old_pearson - pearson) > .Machine$double.eps),
    as.character(abs(old_spearman - spearman) > .Machine$double.eps),
    as.character(old_direction_n != direction_n), "NA", "NA", as.character(fig3_changed)
  ),
  Reason = c(
    "Old implementation did not match the frozen protocol",
    "Restore ANALYSIS_PLAN_v2.0 Module 09",
    "Remove noncanonical correlation selection",
    "Remove noncanonical median aggregation",
    "Frozen parameter retained",
    "Use package-defined behavior without custom rescue",
    "Frozen M05-compatible input retained",
    "Frozen full analytical cohort retained",
    "Frozen Q515 retained",
    "Existing M05-compatible effect estimator retained; exact test and BH fields are now exported",
    "Recomputed from repaired effects", "Added descriptive rank correlation",
    "Recomputed from repaired effects", "Frozen M05 reference", "Repaired KNN result",
    "Panel c reads M09 E comparison"
  ),
  stringsAsFactors = FALSE
)

canonical <- data.frame(
  PG.ProteinGroups = effect$Protein_ID,
  Gene_symbol = effect$Gene_symbol,
  E_primary = effect$E_primary,
  E_knn = effect$E_knn,
  diff = effect$Delta_E,
  Primary_P = effect$Primary_P,
  Primary_FDR = effect$Primary_FDR,
  KNN_P = effect$KNN_P,
  KNN_FDR = effect$KNN_FDR,
  Direction_concordant = effect$Direction_concordant,
  stringsAsFactors = FALSE
)

write.csv(canonical, file.path(out_dir, "M09_KNN_E_comparison.csv"), row.names = FALSE, na = "")
write.csv(effect, file.path(v2, "M09_EFFECT_COMPARISON.csv"), row.names = FALSE, na = "")
write.csv(diagnostics, file.path(v2, "M09_IMPUTATION_DIAGNOSTICS.csv"), row.names = FALSE, na = "")
write.csv(repair_comparison, file.path(v2, "M09_REPAIR_COMPARISON.csv"), row.names = FALSE, na = "")

manifest <- data.frame(
  item = c(
    "status", "authority", "role", "reference", "input", "input_scale",
    "n_proteins", "n_samples", "k", "rowmax", "colmax", "maxp", "rng_seed",
    "impute_version", "distance", "aggregation", "fallback", "model", "contrast",
    "weights", "ebayes", "family", "pearson", "spearman", "direction_concordance",
    "primary_FDR_lt_0.05", "knn_FDR_lt_0.05", "unresolved_NA"
  ),
  value = c(
    "POST_PHASE3_REPAIR_CURRENT", "ANALYSIS_PLAN_v2.0 Module 09",
    "missingness/imputation sensitivity; not validation", "frozen M05 A-E output",
    "Q515 x full analytical cohort", "log2 abundance", nrow(y), ncol(y), K,
    ROWMAX, COLMAX, MAXP, RNG_SEED, as.character(utils::packageVersion("impute")),
    "Euclidean in protein space on available target coordinates",
    "arithmetic mean of available neighbor values",
    "package rowmax and column-mean fallback rules",
    "limma ~0+Group+Environment via contrastAsCoef", "cohort-weighted overall exposure E",
    sprintf("Low=%0.15f; High=%0.15f", wL, wH), "trend=TRUE; robust=TRUE",
    "A-E BH across Q515", sprintf("%.12f", pearson), sprintf("%.12f", spearman),
    sprintf("%d/%d", direction_n, nrow(effect)), sum(primary_sig), sum(knn_sig), sum(is.na(y_imp))
  ),
  stringsAsFactors = FALSE
)
write.csv(manifest, file.path(out_dir, "M09_KNN_manifest.csv"), row.names = FALSE)
write.csv(manifest, file.path(v2, "M09_missingness_sensitivity", "M09_manifest.csv"), row.names = FALSE)

report <- c(
  "# M09 Repair Report", "",
  "Status: `PHASE3_M09_REPAIR_PASS` / `POST_PHASE3_REPAIR_CURRENT`.", "",
  "## Contract", "",
  "Frozen `ANALYSIS_PLAN_v2.0` Module 09 is authoritative. The pre-repair custom correlation-neighbor, unweighted-median procedure was removed. The repaired run uses `impute::impute.knn` on the 1,430 × 515 Q515 log2 matrix with `k=10`, `rowmax=0.5`, `colmax=0.8`, `maxp=1500`, and `rng.seed=20260925`.", "",
  "The downstream model preserves the frozen M05 population, sample order, Group and Environment coding, design, cohort-weighted overall-exposure E contrast, `contrastAsCoef` implementation, `eBayes(trend=TRUE, robust=TRUE)`, and A-E BH family. M05 itself was not rerun or modified.", "",
  "## Imputation diagnostics", "",
  sprintf("- Input dimensions: %d proteins × %d samples.", nrow(y), ncol(y)),
  sprintf("- Missing values: %d before; %d after.", missing_before, sum(is.na(y_imp))),
  sprintf("- Rows exceeding rowmax: %d; columns exceeding colmax: %d.", length(rowmax_rows), length(colmax_columns)),
  sprintf("- Rowmax fallback rows/cells: %d/%d.", length(rowmax_rows), rowmax_fallback_cells),
  sprintf("- Neighbor-column-mean fallback cells/rows/columns: %s/%s/%s.", fallback_diag$neighbor_fallback_cells, fallback_diag$neighbor_fallback_rows, fallback_diag$neighbor_fallback_columns),
  sprintf("- Recursive maxp block split used: %s.", ifelse(nrow(y) > MAXP, "YES", "NO")),
  "- Sample order, protein order, and all observed values were unchanged.", "",
  "## Effect comparison", "",
  sprintf("- Proteins compared: %d.", nrow(effect)),
  sprintf("- Pearson correlation: %.6f.", pearson),
  sprintf("- Spearman correlation: %.6f.", spearman),
  sprintf("- Direction concordance: %d/%d (%.2f%%); sign flips: %d.", direction_n, nrow(effect), 100 * direction_n / nrow(effect), sign_flips),
  sprintf("- Median absolute effect change: %.6f; maximum: %.6f.", median(effect$Absolute_Delta_E), max(effect$Absolute_Delta_E)),
  sprintf("- FDR<0.05: primary only %d; KNN only %d; both %d; primary total %d; KNN total %d.", sum(primary_sig & !knn_sig), sum(!primary_sig & knn_sig), sum(primary_sig & knn_sig), sum(primary_sig), sum(knn_sig)), "",
  "## Old versus repaired M09", "",
  sprintf("- Pearson correlation changed from %.6f to %.6f.", old_pearson, pearson),
  sprintf("- Spearman correlation changed from %.6f to %.6f.", old_spearman, spearman),
  sprintf("- Direction concordance changed from %d/%d to %d/%d.", old_direction_n, nrow(effect), direction_n, nrow(effect)),
  sprintf("- Repaired E_knn differs from the old invalidated value for %d/%d proteins.", sum(abs(old_e - effect$E_knn) > 0), nrow(effect)),
  "- The old output did not contain P/FDR fields, so old significant counts are not available.", "",
  "## Interpretation", "",
  "The primary overall-exposure effect estimates were compared with estimates obtained after the prespecified KNN-imputation sensitivity analysis. Agreement is evidence only about robustness to this specific missing-value treatment; M09 is not validation and does not establish that missingness has no effect.", "",
  "## Scope", "",
  "Only M09 was rerun. D03, D08, fixed-85 ML, strict nested ML, SVM-RFE, M11, M12/M12B, and the M17 figure pipeline were not run or modified. Fig. 3c was not redrawn."
)
writeLines(report, file.path(v2, "M09_REPAIR_REPORT.md"), useBytes = TRUE)

fig3_note <- c(
  "# M09 Fig. 3 Rebuild Requirement", "",
  if (fig3_changed) "Status: `FIG3_REBUILD_REQUIRED`." else "Status: `FIG3_METHOD_RELABEL_REQUIRED`.", "",
  "- Affected panel: Fig. 3c, `Overall-exposure sensitivity`.",
  "- Producer: `code/V2_M17_figures_v2.R`.",
  "- Old M09 source: `M09_pre_repair_snapshot/M09_KNN_E_comparison.csv`.",
  "- Repaired M09 source: `M09_missingness_sensitivity/KNN_sensitivity/M09_KNN_E_comparison.csv` and `M09_EFFECT_COMPARISON.csv`.",
  sprintf("- Old Pearson E correlation: %.6f.", old_pearson),
  sprintf("- Repaired Pearson E correlation: %.6f.", pearson),
  sprintf("- Old/repaired Spearman E correlation: %.6f / %.6f.", old_spearman, spearman),
  sprintf("- Old/repaired direction concordance: %d/%d / %d/%d.", old_direction_n, nrow(effect), direction_n, nrow(effect)),
  sprintf("- Repaired E values differ from old invalidated values for %d/%d proteins.", sum(abs(old_e - effect$E_knn) > 0), nrow(effect)),
  sprintf("- Numerical E_knn content changed: %s.", ifelse(fig3_changed, "YES", "NO")),
  sprintf("- Panel rebuild required: %s.", ifelse(fig3_changed, "YES", "NO; method/caption relabel still required")),
  "- Caption/Methods must replace the invalid correlation-weighted/custom description with the full `impute::impute.knn(k=10, rowmax=0.5, colmax=0.8, maxp=1500, rng.seed=20260925)` contract.",
  "- The M17 figure pipeline was not executed in Phase 3."
)
writeLines(fig3_note, file.path(v2, "M09_FIG3_REBUILD_REQUIREMENT.md"), useBytes = TRUE)

cat(sprintf("M09 repaired: Pearson=%.6f Spearman=%.6f direction=%d/%d\n",
            pearson, spearman, direction_n, nrow(effect)))
cat("M09_PHASE3_REPAIR_DONE\n")
