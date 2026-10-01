#!/usr/bin/env Rscript
# V2 M11 — primary-contract site leave-one-out robustness for M05 E.
# Authority: ANALYSIS_PLAN_v2.0, Module 11.

suppressPackageStartupMessages({
  library(limma)
})

root <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
v2 <- file.path(root, "descriptive", "analysis_v2.0")
out_dir <- file.path(v2, "M11_site_robustness")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

log2_path <- file.path(root, "descriptive", "PRIMARY_dose_log2_expression.csv.gz")
meta_path <- file.path(root, "descriptive", "dose_defined_metadata.csv")
universe_path <- file.path(v2, "universes", "Q515.csv")
m05_path <- file.path(v2, "M05_overall_exposure", "M05_overall_exposure_AE_results.csv")
annotation_path <- file.path(root, "descriptive", "canonical_protein_annotation.csv")
old_loo_path <- file.path(v2, "M11_pre_repair_snapshot", "M11_site_LOO_stability.csv")

for (p in c(log2_path, meta_path, universe_path, m05_path, annotation_path, old_loo_path)) {
  if (!file.exists(p)) stop("M11 missing required input: ", p)
}

log2mat <- read.csv(gzfile(log2_path), check.names = FALSE, row.names = 1)
meta <- read.csv(meta_path, check.names = FALSE, stringsAsFactors = FALSE)
univ <- read.csv(universe_path, check.names = FALSE, stringsAsFactors = FALSE)
m05 <- read.csv(m05_path, check.names = FALSE, stringsAsFactors = FALSE)
annotation <- read.csv(annotation_path, check.names = FALSE, stringsAsFactors = FALSE)
old_loo <- read.csv(old_loo_path, check.names = FALSE, stringsAsFactors = FALSE)

q515_ids <- univ$PG.ProteinGroups[univ$Q515 %in% TRUE]
if (length(q515_ids) != 1430L || anyDuplicated(q515_ids)) {
  stop("M11 Q515 contract failed: expected 1,430 unique protein groups")
}
if (!all(q515_ids %in% rownames(log2mat))) stop("M11 Q515 proteins missing from matrix")

sample_ids <- colnames(log2mat)
if (length(sample_ids) != 515L || anyDuplicated(sample_ids)) {
  stop("M11 sample contract failed: expected 515 unique matrix columns")
}
rownames(meta) <- meta$UniqueSampleID
if (!all(sample_ids %in% rownames(meta))) stop("M11 metadata missing matrix samples")
m <- meta[sample_ids, , drop = FALSE]
if (!identical(rownames(m), sample_ids)) stop("M11 metadata/sample order mismatch")

m$Group <- factor(m$TREAT1_clean, c("control", "low", "high"),
                  c("Control", "Low", "High"))
site_to_env <- function(site) {
  ifelse(grepl("^XZ_", site), "High_altitude",
         ifelse(grepl("^(FJ_|GZ_)", site), "Humid_hot", NA_character_))
}
m$Environment <- factor(site_to_env(m$group), c("Humid_hot", "High_altitude"))
if (anyNA(m$Group) || anyNA(m$Environment) || anyNA(m$group)) {
  stop("M11 Group/Environment/Site mapping failed")
}

nC_full <- sum(m$Group == "Control")
nL_full <- sum(m$Group == "Low")
nH_full <- sum(m$Group == "High")
if (!identical(c(nC_full, nL_full, nH_full), c(153L, 186L, 176L))) {
  stop("M11 full-cohort Group counts do not match frozen M05")
}
wL_fixed <- nL_full / (nL_full + nH_full)
wH_fixed <- nH_full / (nL_full + nH_full)

y <- as.matrix(log2mat[q515_ids, sample_ids, drop = FALSE])
storage.mode(y) <- "numeric"
if (!identical(rownames(y), q515_ids) || !identical(colnames(y), sample_ids)) {
  stop("M11 input order changed during Q515 subsetting")
}
if (any(is.infinite(y))) stop("M11 input contains infinite abundance values")

if (nrow(m05) != length(q515_ids) || anyDuplicated(m05$PG.ProteinGroups)) {
  stop("M11 frozen M05 output must contain 1,430 unique proteins")
}
m05 <- m05[match(q515_ids, m05$PG.ProteinGroups), , drop = FALSE]
if (!identical(m05$PG.ProteinGroups, q515_ids)) stop("M11 could not align M05 output")
if (!all(m05$Estimable %in% TRUE)) stop("M11 expected all frozen M05 Q515 effects to be estimable")

gene_map <- setNames(annotation$Gene_symbol, annotation$PG.ProteinGroups)
sites <- sort(unique(m$group))
if (length(sites) != 9L) stop("M11 expected nine Sites")

direction_label <- function(x) {
  ifelse(!is.finite(x), NA_character_,
         ifelse(x > 0, "Positive", ifelse(x < 0, "Negative", "Zero")))
}

make_nonestimable <- function(site, reason, ms, n_removed, env_levels, group_levels,
                              other_sites, design_rank = NA_integer_, design_columns = NA_integer_) {
  effect <- data.frame(
    Protein_ID = q515_ids,
    Gene_symbol = unname(gene_map[q515_ids]),
    Site_removed = site,
    Primary_effect = m05$log2FC_E,
    LOO_effect = NA_real_,
    Delta_effect = NA_real_,
    Absolute_delta = NA_real_,
    Primary_direction = direction_label(m05$log2FC_E),
    LOO_direction = NA_character_,
    Direction_concordant = NA,
    Primary_P = m05$P_raw,
    LOO_P = NA_real_,
    Primary_FDR = m05$BH_FDR_AE,
    LOO_FDR = 1,
    Estimable = FALSE,
    Status = "NONESTIMABLE_UNDER_PRIMARY_CONTRACT",
    Failure_reason = reason,
    N_observed = rowSums(!is.na(y[, rownames(ms), drop = FALSE])),
    N_Control_observed = NA_integer_,
    N_Low_observed = NA_integer_,
    N_High_observed = NA_integer_,
    stringsAsFactors = FALSE
  )
  summary <- data.frame(
    Site_removed = site, N_removed = n_removed, N_remaining = nrow(ms),
    N_Control = sum(ms$Group == "Control"), N_Low = sum(ms$Group == "Low"),
    N_High = sum(ms$Group == "High"),
    Environment_levels_remaining = paste(env_levels, collapse = ";"),
    Group_levels_remaining = paste(group_levels, collapse = ";"),
    Other_sites_remaining = other_sites, Design_rank = design_rank,
    Design_columns = design_columns, N_proteins_compared = 0L,
    N_nonestimable_proteins = length(q515_ids), Pearson_effect_correlation = NA_real_,
    Spearman_effect_correlation = NA_real_, Direction_concordance_n = NA_integer_,
    Direction_concordance_pct = NA_real_, Median_absolute_effect_change = NA_real_,
    Max_absolute_effect_change = NA_real_, Sign_flip_n = NA_integer_,
    Primary_FDR_sig_n = sum(m05$BH_FDR_AE < 0.05), LOO_FDR_sig_n = NA_integer_,
    Both_FDR_sig_n = NA_integer_, Any_FDR_status_change = NA,
    Design_estimable = FALSE, Failure_reason = reason, stringsAsFactors = FALSE
  )
  list(effect = effect, summary = summary)
}

fit_one_site <- function(site) {
  keep <- m$group != site
  ms <- droplevels(m[keep, , drop = FALSE])
  ys <- y[, keep, drop = FALSE]
  removed_ids <- sample_ids[!keep]
  if (length(removed_ids) != sum(!keep) || any(removed_ids %in% colnames(ys))) {
    stop("M11 deletion tracking failure for Site ", site)
  }
  if (!identical(colnames(ys), sample_ids[keep])) stop("M11 retained sample order changed")

  env_levels <- levels(ms$Environment)
  group_levels <- levels(ms$Group)
  n_removed <- sum(!keep)
  other_sites <- length(unique(ms$group))

  if (length(env_levels) != 2L) {
    return(make_nonestimable(site, "Environment has fewer than two remaining levels",
                             ms, n_removed, env_levels, group_levels, other_sites))
  }
  if (length(group_levels) != 3L) {
    return(make_nonestimable(site, "Exposure Group has fewer than three remaining levels",
                             ms, n_removed, env_levels, group_levels, other_sites))
  }

  design <- model.matrix(~0 + Group + Environment, data = ms)
  design_rank <- qr(design)$rank
  design_columns <- ncol(design)
  if (design_rank != design_columns) {
    return(make_nonestimable(site, "Primary design is rank deficient after Site deletion",
                             ms, n_removed, env_levels, group_levels, other_sites,
                             design_rank, design_columns))
  }

  required_coef <- c("GroupControl", "GroupLow", "GroupHigh")
  if (!all(required_coef %in% colnames(design))) {
    return(make_nonestimable(site, "Primary E contrast coefficients are unavailable",
                             ms, n_removed, env_levels, group_levels, other_sites,
                             design_rank, design_columns))
  }

  e_vec <- setNames(rep(0, ncol(design)), colnames(design))
  e_vec["GroupLow"] <- wL_fixed
  e_vec["GroupHigh"] <- wH_fixed
  e_vec["GroupControl"] <- -1
  contrast <- matrix(e_vec, ncol = 1, dimnames = list(names(e_vec), "E"))
  design2 <- tryCatch(limma::contrastAsCoef(design, contrast)[["design"]],
                      error = function(e) e)
  if (inherits(design2, "error")) {
    return(make_nonestimable(site, paste("E contrast non-estimable:", conditionMessage(design2)),
                             ms, n_removed, env_levels, group_levels, other_sites,
                             design_rank, design_columns))
  }

  fit <- tryCatch({
    z <- limma::lmFit(ys, design2)
    limma::eBayes(z, trend = TRUE, robust = TRUE)
  }, error = function(e) e)
  if (inherits(fit, "error")) {
    return(make_nonestimable(site, paste("Primary-contract limma fit failed:", conditionMessage(fit)),
                             ms, n_removed, env_levels, group_levels, other_sites,
                             design_rank, design_columns))
  }

  b <- fit$coefficients[, "E"]
  se <- fit$stdev.unscaled[, "E"] * sqrt(fit$s2.post)
  df_total <- fit$df.total
  p_raw_fit <- 2 * pt(-abs(b / se), df = df_total)
  n_control <- rowSums(!is.na(ys[, ms$Group == "Control", drop = FALSE]))
  n_low <- rowSums(!is.na(ys[, ms$Group == "Low", drop = FALSE]))
  n_high <- rowSums(!is.na(ys[, ms$Group == "High", drop = FALSE]))
  support_ok <- n_control >= 10L & n_low >= 10L & n_high >= 10L
  finite_ok <- is.finite(b) & is.finite(se) & se > 0 & is.finite(p_raw_fit) & df_total >= 5
  estimable <- support_ok & finite_ok
  p_report <- ifelse(estimable, p_raw_fit, NA_real_)
  fdr <- p.adjust(ifelse(estimable, p_raw_fit, 1), method = "BH")
  loo_effect <- ifelse(estimable, b, NA_real_)
  primary_effect <- m05$log2FC_E
  primary_direction <- direction_label(primary_effect)
  loo_direction <- direction_label(loo_effect)
  delta <- loo_effect - primary_effect
  failure_reason <- ifelse(
    estimable, NA_character_,
    ifelse(!support_ok, "Fewer than 10 observed values in at least one Group",
           "Non-finite coefficient, uncertainty, P value, or residual df <5")
  )

  effect <- data.frame(
    Protein_ID = q515_ids,
    Gene_symbol = unname(gene_map[q515_ids]),
    Site_removed = site,
    Primary_effect = primary_effect,
    LOO_effect = loo_effect,
    Delta_effect = delta,
    Absolute_delta = abs(delta),
    Primary_direction = primary_direction,
    LOO_direction = loo_direction,
    Direction_concordant = ifelse(estimable, primary_direction == loo_direction, NA),
    Primary_P = m05$P_raw,
    LOO_P = p_report,
    Primary_FDR = m05$BH_FDR_AE,
    LOO_FDR = fdr,
    Estimable = estimable,
    Status = ifelse(estimable, "OK", "NONESTIMABLE_UNDER_PRIMARY_CONTRACT"),
    Failure_reason = failure_reason,
    N_observed = rowSums(!is.na(ys)),
    N_Control_observed = n_control,
    N_Low_observed = n_low,
    N_High_observed = n_high,
    stringsAsFactors = FALSE
  )

  z <- effect[effect$Estimable, , drop = FALSE]
  primary_sig <- z$Primary_FDR < 0.05
  loo_sig <- z$LOO_FDR < 0.05
  summary <- data.frame(
    Site_removed = site,
    N_removed = n_removed,
    N_remaining = nrow(ms),
    N_Control = sum(ms$Group == "Control"),
    N_Low = sum(ms$Group == "Low"),
    N_High = sum(ms$Group == "High"),
    Environment_levels_remaining = paste(env_levels, collapse = ";"),
    Group_levels_remaining = paste(group_levels, collapse = ";"),
    Other_sites_remaining = other_sites,
    Design_rank = design_rank,
    Design_columns = design_columns,
    N_proteins_compared = nrow(z),
    N_nonestimable_proteins = sum(!effect$Estimable),
    Pearson_effect_correlation = if (nrow(z) >= 3L) cor(z$Primary_effect, z$LOO_effect) else NA_real_,
    Spearman_effect_correlation = if (nrow(z) >= 3L) cor(z$Primary_effect, z$LOO_effect, method = "spearman") else NA_real_,
    Direction_concordance_n = sum(z$Direction_concordant),
    Direction_concordance_pct = 100 * mean(z$Direction_concordant),
    Median_absolute_effect_change = median(z$Absolute_delta),
    Max_absolute_effect_change = max(z$Absolute_delta),
    Sign_flip_n = sum(!z$Direction_concordant),
    Primary_FDR_sig_n = sum(primary_sig),
    LOO_FDR_sig_n = sum(loo_sig),
    Both_FDR_sig_n = sum(primary_sig & loo_sig),
    Any_FDR_status_change = any(primary_sig != loo_sig),
    Design_estimable = TRUE,
    Failure_reason = NA_character_,
    stringsAsFactors = FALSE
  )
  list(effect = effect, summary = summary)
}

fits <- lapply(sites, fit_one_site)
names(fits) <- sites
effect_long <- do.call(rbind, lapply(fits, `[[`, "effect"))
site_summary <- do.call(rbind, lapply(fits, `[[`, "summary"))
rownames(effect_long) <- NULL
rownames(site_summary) <- NULL

if (nrow(effect_long) != length(q515_ids) * length(sites)) stop("M11 long output row count failed")
if (anyDuplicated(effect_long[, c("Protein_ID", "Site_removed")])) stop("M11 duplicate protein-Site rows")

effect_matrix <- sapply(sites, function(site) {
  z <- effect_long[effect_long$Site_removed == site, , drop = FALSE]
  z$LOO_effect[match(q515_ids, z$Protein_ID)]
})
colnames(effect_matrix) <- paste0("E_loo_drop_", sites)
rownames(effect_matrix) <- q515_ids
estimable_matrix <- sapply(sites, function(site) {
  z <- effect_long[effect_long$Site_removed == site, , drop = FALSE]
  z$Estimable[match(q515_ids, z$Protein_ID)]
})
rownames(estimable_matrix) <- q515_ids

max_shift <- vapply(seq_along(q515_ids), function(i) {
  x <- effect_matrix[i, ]
  if (!any(is.finite(x))) return(NA_real_)
  max(abs(x - m05$log2FC_E[i]), na.rm = TRUE)
}, numeric(1))
loo_range <- apply(effect_matrix, 1, function(x) {
  if (sum(is.finite(x)) < 2L) return(NA_real_)
  diff(range(x, na.rm = TRUE))
})
direction_consistent <- vapply(seq_along(q515_ids), function(i) {
  x <- effect_matrix[i, ]
  if (!all(is.finite(x))) return(NA)
  all(sign(x) == sign(m05$log2FC_E[i]))
}, logical(1))

canonical <- data.frame(
  PG.ProteinGroups = q515_ids,
  Gene_symbol = unname(gene_map[q515_ids]),
  E_full = m05$log2FC_E,
  effect_matrix,
  E_loo_max_shift = max_shift,
  E_loo_range = loo_range,
  N_LOO_estimable = rowSums(estimable_matrix),
  loo_dir_consistent = direction_consistent,
  stringsAsFactors = FALSE,
  check.names = FALSE
)

site_composition <- do.call(rbind, lapply(sites, function(site) {
  z <- m[m$group == site, , drop = FALSE]
  data.frame(
    Site = site,
    Environment = as.character(unique(z$Environment)),
    Control = sum(z$Group == "Control"),
    Low = sum(z$Group == "Low"),
    High = sum(z$Group == "High"),
    Total = nrow(z),
    stringsAsFactors = FALSE
  )
}))

# Old-output comparison using the frozen pre-repair snapshot.
old_loo <- old_loo[match(q515_ids, old_loo$PG.ProteinGroups), , drop = FALSE]
if (!identical(old_loo$PG.ProteinGroups, q515_ids)) stop("M11 old snapshot alignment failed")
old_site_metrics <- do.call(rbind, lapply(sites, function(site) {
  col <- paste0("E_loo_drop_", site)
  x <- old_loo[[col]]
  delta <- x - m05$log2FC_E
  data.frame(
    Site_removed = site,
    Pearson = cor(m05$log2FC_E, x, use = "complete.obs"),
    Spearman = cor(m05$log2FC_E, x, method = "spearman", use = "complete.obs"),
    Direction_concordance_pct = 100 * mean(sign(m05$log2FC_E) == sign(x), na.rm = TRUE),
    Sign_flip_n = sum(sign(m05$log2FC_E) != sign(x), na.rm = TRUE),
    Median_absolute_effect_change = median(abs(delta), na.rm = TRUE),
    Max_absolute_effect_change = max(abs(delta), na.rm = TRUE),
    stringsAsFactors = FALSE
  )
}))

new_estimable_sites <- sum(site_summary$Design_estimable)
new_nonestimable_sites <- sum(!site_summary$Design_estimable)
fig4d_changed <- !isTRUE(all.equal(
  as.matrix(old_loo[, paste0("E_loo_drop_", sites), drop = FALSE]),
  effect_matrix, tolerance = 0, check.attributes = FALSE
))

fmt_range <- function(x, digits = 6) {
  sprintf(paste0("%.", digits, "f-%.", digits, "f"), min(x, na.rm = TRUE), max(x, na.rm = TRUE))
}

repair_comparison <- data.frame(
  Metric = c(
    "Status", "Reference_estimand", "Formula", "Environment_adjustment",
    "Weighting_rule", "Protein_universe", "Eligibility_rule", "N_LOO_fits",
    "N_nonestimable_design_fits", "Effect_correlation_range_Pearson",
    "Effect_correlation_range_Spearman", "Direction_concordance_range_pct",
    "Sign_flips_total", "FDR_support", "Fig4_source_data_impact"
  ),
  Old = c(
    "PRE_REPAIR_NOT_INTERPRETABLE_AS_PURE_SITE_LOO_ROBUSTNESS",
    "Deletion-specific reweighted exposed-mixture effect", "~0+Group", "No",
    "Recomputed Low/High weights after each deletion", "Fixed Q515 (1430)",
    "Not recomputed", length(sites), "0 recorded",
    fmt_range(old_site_metrics$Pearson), fmt_range(old_site_metrics$Spearman),
    fmt_range(old_site_metrics$Direction_concordance_pct, 2),
    sum(old_site_metrics$Sign_flip_n), "Not exported", "Old M11_site_LOO_stability.csv"
  ),
  Repaired = c(
    "POST_PHASE4_REPAIR_CURRENT", "Fixed frozen M05 overall-exposure E",
    "~0+Group+Environment", "Yes", "Fixed full-cohort weights 186/362 and 176/362",
    "Fixed Q515 (1430)", "Not recomputed", length(sites), new_nonestimable_sites,
    fmt_range(site_summary$Pearson_effect_correlation[site_summary$Design_estimable]),
    fmt_range(site_summary$Spearman_effect_correlation[site_summary$Design_estimable]),
    fmt_range(site_summary$Direction_concordance_pct[site_summary$Design_estimable], 2),
    sum(site_summary$Sign_flip_n, na.rm = TRUE),
    sprintf("Primary=%d; LOO range=%d-%d; descriptive only",
            unique(site_summary$Primary_FDR_sig_n), min(site_summary$LOO_FDR_sig_n, na.rm = TRUE),
            max(site_summary$LOO_FDR_sig_n, na.rm = TRUE)),
    if (fig4d_changed) "Fig4d numerical source changed" else "No numerical change"
  ),
  Changed = c(
    "YES", "YES", "YES", "YES", "YES", "NO", "NO", "NO",
    ifelse(new_nonestimable_sites != 0L, "YES", "NO"), "YES", "YES", "YES", "YES",
    "YES", ifelse(fig4d_changed, "YES", "NO")
  ),
  Interpretation = c(
    "Old result invalidated by estimand mismatch", "LOO now targets one fixed estimand",
    "Primary design structure restored", "No silent unadjusted fallback",
    "Site deletion no longer changes mathematical contrast coefficients",
    "Universe remains isolated from deletion", "No hidden reselection",
    "All nine prespecified Sites retained", "Explicit design audit added",
    "Old/new values are not method-equivalent", "Rank concordance now reported",
    "Compared directly with frozen M05 direction", "Across protein-Site comparisons",
    "LOO FDR is descriptive sensitivity output, not a new discovery family",
    "Fig4d reads the repaired canonical LOO table"
  ),
  stringsAsFactors = FALSE
)

write.csv(effect_long, file.path(v2, "M11_EFFECT_COMPARISON.csv"), row.names = FALSE, na = "")
write.csv(site_summary, file.path(v2, "M11_SITE_SUMMARY.csv"), row.names = FALSE, na = "")
write.csv(repair_comparison, file.path(v2, "M11_REPAIR_COMPARISON.csv"), row.names = FALSE, na = "")
write.csv(canonical, file.path(out_dir, "M11_site_LOO_stability.csv"), row.names = FALSE, na = "")
write.csv(site_composition, file.path(out_dir, "M11_site_composition.csv"), row.names = FALSE)

manifest <- data.frame(
  item = c(
    "status", "authority", "reference", "role", "population", "n_samples_full",
    "protein_universe", "n_proteins", "n_sites", "formula", "environment",
    "contrast", "weights", "missingness", "eligibility", "ebayes", "family",
    "n_estimable_design_fits", "n_nonestimable_design_fits",
    "pearson_range", "spearman_range", "direction_concordance_pct_range",
    "fig4d_rebuild_required"
  ),
  value = c(
    "POST_PHASE4_REPAIR_CURRENT", "ANALYSIS_PLAN_v2.0 Module 11", "frozen M05 A-E",
    "descriptive Site leave-one-out influence; not validation", "full analytical cohort",
    length(sample_ids), "fixed Q515", length(q515_ids), length(sites),
    "~0+Group+Environment", "retained; no unadjusted fallback",
    "fixed cohort-weighted overall-exposure E via contrastAsCoef",
    sprintf("Low=%0.15f; High=%0.15f", wL_fixed, wH_fixed),
    "observed log2 abundance; no imputation", "fixed parent; not recomputed",
    "trend=TRUE; robust=TRUE", "A-E BH across fixed Q515; LOO FDR descriptive only",
    new_estimable_sites, new_nonestimable_sites,
    fmt_range(site_summary$Pearson_effect_correlation[site_summary$Design_estimable]),
    fmt_range(site_summary$Spearman_effect_correlation[site_summary$Design_estimable]),
    fmt_range(site_summary$Direction_concordance_pct[site_summary$Design_estimable], 2),
    fig4d_changed
  ),
  stringsAsFactors = FALSE
)
write.csv(manifest, file.path(out_dir, "M11_manifest.csv"), row.names = FALSE)

most_influential_site <- site_summary$Site_removed[which.max(site_summary$Median_absolute_effect_change)]
report <- c(
  "# M11 Site Leave-one-out Repair Report", "",
  "Status: `PHASE4_M11_REPAIR_PASS` / `POST_PHASE4_REPAIR_CURRENT`.", "",
  "## Contract", "",
  "M11 is a full-515, fixed-Q515 sensitivity analysis referenced to the frozen M05 overall-exposure effect E. Each fit removes one Site while retaining `~0+Group+Environment`, the full-cohort E weights, observed-value limma, `contrastAsCoef`, `eBayes(trend=TRUE, robust=TRUE)`, and the fixed Q515 family. No fallback model or eligibility reselection is used.", "",
  "## Estimability", "",
  sprintf("- Prespecified Site deletions: %d; participant-level design-estimable: %d; non-estimable: %d.", length(sites), new_estimable_sites, new_nonestimable_sites),
  sprintf("- Protein-Site comparisons: %d; estimable: %d; non-estimable: %d.", nrow(effect_long), sum(effect_long$Estimable), sum(!effect_long$Estimable)),
  "- Every deletion records remaining Group/Environment levels, sample counts, design rank, and failure reason.", "",
  "## Effect sensitivity", "",
  sprintf("- Pearson correlation range: %s.", fmt_range(site_summary$Pearson_effect_correlation[site_summary$Design_estimable])),
  sprintf("- Spearman correlation range: %s.", fmt_range(site_summary$Spearman_effect_correlation[site_summary$Design_estimable])),
  sprintf("- Direction concordance range: %s%%.", fmt_range(site_summary$Direction_concordance_pct[site_summary$Design_estimable], 2)),
  sprintf("- Total sign flips across estimable protein-Site comparisons: %d.", sum(site_summary$Sign_flip_n, na.rm = TRUE)),
  sprintf("- Most influential deletion by median absolute effect change: %s.", most_influential_site),
  sprintf("- Lowest overall concordance: %s (Pearson %.6f; Spearman %.6f; direction %.2f%%; %d sign flips).",
          site_summary$Site_removed[which.min(site_summary$Pearson_effect_correlation)],
          min(site_summary$Pearson_effect_correlation),
          site_summary$Spearman_effect_correlation[which.min(site_summary$Pearson_effect_correlation)],
          site_summary$Direction_concordance_pct[which.min(site_summary$Pearson_effect_correlation)],
          site_summary$Sign_flip_n[which.min(site_summary$Pearson_effect_correlation)]),
  sprintf("- Largest single-protein absolute change: %s (%.6f).",
          site_summary$Site_removed[which.max(site_summary$Max_absolute_effect_change)],
          max(site_summary$Max_absolute_effect_change)),
  sprintf("- Primary FDR-supported proteins: %d; LOO FDR-supported range: %d-%d.", unique(site_summary$Primary_FDR_sig_n), min(site_summary$LOO_FDR_sig_n), max(site_summary$LOO_FDR_sig_n)), "",
  "No binary stability threshold was prespecified. Effect estimates were sensitive to exclusion of specific Sites under the primary model contract; the influential Site depends on whether influence is summarized by median shift, global concordance, or the largest single-protein shift. LOO FDR changes are descriptive sensitivity diagnostics, not new discoveries.", "",
  "## Interpretation boundary", "",
  "LOO answers: how sensitive are estimated effects to exclusion of one Site under the primary analysis model contract? It does not show that a Site effect was removed, that batch confounding was eliminated, that effects transport across Sites, or that findings were replicated across Sites. Site, Environment, and acquisition era remain coupled in the observed design.", "",
  "## Scope", "",
  "Only M11 was rerun. D01-D03, D08, fixed-85 ML, strict nested ML, repaired M09, M12/M12B, and the M17 figure pipeline were not run or modified. Fig. 4 was not redrawn."
)
writeLines(report, file.path(v2, "M11_REPAIR_REPORT.md"), useBytes = TRUE)

fig4_note <- c(
  "# M11 Fig. 4 Rebuild Requirement", "",
  if (fig4d_changed) "Status: `FIG4D_REBUILD_REQUIRED`." else "Status: `FIG4D_METHOD_RELABEL_REQUIRED`.", "",
  "| Panel | Old source | Repaired source | Old metric | New metric | Needs rebuild? | Caption change? | Reason |",
  "|---|---|---|---|---|---|---|---|",
  "| Fig. 4c Site composition | `M11_pre_repair_snapshot/M11_site_composition.csv` | `M11_site_robustness/M11_site_composition.csv` | Site × Group counts | Same counts with explicit Site/Environment/Total fields | NO | NO | Composition is descriptive and numerically unchanged |",
  sprintf("| Fig. 4d LOO influence | `M11_pre_repair_snapshot/M11_site_LOO_stability.csv` | `M11_site_robustness/M11_site_LOO_stability.csv` and `M11_EFFECT_COMPARISON.csv` | Unadjusted, deletion-reweighted LOO maximum shift and direction summary | Primary-contract adjusted LOO maximum shift and direction versus frozen M05 | %s | YES | Formula and weights were repaired; numerical source changed=%s |", ifelse(fig4d_changed, "YES", "NO"), ifelse(fig4d_changed, "YES", "NO")), "",
  "The Fig. 4 producer reads M11 Site composition for panel c and the canonical LOO stability table for panel d. The M17 figure pipeline was not executed in Phase 4."
)
writeLines(fig4_note, file.path(v2, "M11_FIG4_REBUILD_REQUIREMENT.md"), useBytes = TRUE)

cat(sprintf("M11 repaired: sites=%d estimable_designs=%d nonestimable_designs=%d\n",
            length(sites), new_estimable_sites, new_nonestimable_sites))
cat("M11_PHASE4_REPAIR_DONE\n")
