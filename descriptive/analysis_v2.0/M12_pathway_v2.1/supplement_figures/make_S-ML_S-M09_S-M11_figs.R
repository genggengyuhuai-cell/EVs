# =============================================================================
# Phase 6 Supplement Figures: S-ML1, S-ML2, S-ML3, S-M09, S-M11
# All data read from repaired canonical outputs — no manual input
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
  library(patchwork)
})

root <- "F:/env"
v2 <- file.path(root, "descriptive/analysis_v2.0")
out_dir <- file.path(v2, "supplement_figures")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# =============================================================================
# S-ML1: Fixed-85 ML performance (conditional on locked 85)
# =============================================================================
cat("=== S-ML1: Fixed-85 ML performance ===\n")
ocm <- read.csv(file.path(v2, "ml_v2.1/results/outer_cv_metrics.csv"), stringsAsFactors=FALSE)

# Reshape for plotting
ml1_df <- data.frame(
  fold = rep(1:nrow(ocm), 3),
  Model = rep(c("LASSO", "Elastic Net", "XGBoost"), each = nrow(ocm)),
  AUROC = c(ocm$lasso_auroc, ocm$en_auroc, ocm$xgb_auroc)
)

p_ml1 <- ggplot(ml1_df, aes(x = Model, y = AUROC, fill = Model)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.15, size = 1.5, alpha = 0.8) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "grey50") +
  scale_fill_brewer(palette = "Set2", guide = "none") +
  labs(
    title = "S-ML1: Fixed-85 ML outer-fold performance",
    subtitle = "Conditional on the locked 85-protein Discovery panel. Not an unbiased generalization estimate.",
    x = "", y = "Outer-fold AUROC (15 folds)",
    caption = "Source: ml_v2.1/results/outer_cv_metrics.csv (repaired P0-1/P0-2)"
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    plot.caption = element_text(size = 7, color = "grey50", hjust = 0)
  )

ggsave(file.path(out_dir, "SuppFig_S-ML1_fixed85_performance.pdf"), p_ml1, width = 7, height = 5)
ggsave(file.path(out_dir, "SuppFig_S-ML1_fixed85_performance.svg"), p_ml1, width = 7, height = 5)
ggsave(file.path(out_dir, "SuppFig_S-ML1_fixed85_performance.png"), p_ml1, width = 7, height = 5, dpi = 300, bg = "white")
cat("  Saved S-ML1\n")

# =============================================================================
# S-ML2: Strict nested CV metrics (8 fit folds out of 15)
# =============================================================================
cat("=== S-ML2: Strict nested CV metrics ===\n")
sn_om <- read.csv(file.path(v2, "ml_v2.1/strict_nested/strict_nested_outer_metrics.csv"), stringsAsFactors=FALSE)

# Only folds where model was actually fit
sn_fit <- sn_om[!is.na(sn_om$lasso_auroc), ]
n_zero <- sum(is.na(sn_om$lasso_auroc))
n_fit <- nrow(sn_fit)

ml2_df <- data.frame(
  fold = rep(1:n_fit, 2),
  Model = rep(c("LASSO", "Elastic Net"), each = n_fit),
  AUROC = c(sn_fit$lasso_auroc, sn_fit$en_auroc)
)

p_ml2 <- ggplot(ml2_df, aes(x = Model, y = AUROC, fill = Model)) +
  geom_boxplot(alpha = 0.7, outlier.shape = NA) +
  geom_jitter(width = 0.15, size = 1.5, alpha = 0.8) +
  geom_hline(yintercept = 0.5, linetype = "dashed", color = "grey50") +
  scale_fill_brewer(palette = "Set1", guide = "none") +
  labs(
    title = "S-ML2: Strict-nested outer-fold AUROC",
    subtitle = paste0("Only ", n_fit, "/15 outer folds had ≥1 DEP (model fit). ", n_zero, "/15 folds had zero features (no model fit)."),
    x = "", y = "Outer-fold AUROC",
    caption = "Source: ml_v2.1/strict_nested/strict_nested_outer_metrics.csv\nConditional on folds with ≥1 BH-significant DEP. Not a generalizable performance estimate."
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    plot.caption = element_text(size = 7, color = "grey50", hjust = 0)
  )

ggsave(file.path(out_dir, "SuppFig_S-ML2_strict_nested_metrics.pdf"), p_ml2, width = 7, height = 5)
ggsave(file.path(out_dir, "SuppFig_S-ML2_strict_nested_metrics.svg"), p_ml2, width = 7, height = 5)
ggsave(file.path(out_dir, "SuppFig_S-ML2_strict_nested_metrics.png"), p_ml2, width = 7, height = 5, dpi = 300, bg = "white")
cat("  Saved S-ML2\n")

# =============================================================================
# S-ML3: Feature stability / zero-feature folds
# =============================================================================
cat("=== S-ML3: Feature stability ===\n")
sn_fs <- read.csv(file.path(v2, "ml_v2.1/strict_nested/strict_nested_feature_stability.csv"), stringsAsFactors=FALSE)
sn_ffc <- read.csv(file.path(v2, "ml_v2.1/strict_nested/strict_nested_fold_feature_counts.csv"), stringsAsFactors=FALSE)

# Panel A: appearance frequency histogram
p_ml3a <- ggplot(sn_fs, aes(x = appearance_frequency)) +
  geom_histogram(binwidth = 1/15, fill = "#4A85B3", color = "white", linewidth = 0.2) +
  scale_x_continuous(labels = scales::percent, breaks = seq(0, 1, by = 0.2)) +
  labs(
    title = "A  Feature appearance frequency across 15 outer folds",
    subtitle = paste0(nrow(sn_fs), " proteins appeared in ≥1 fold. No protein appears in ≥70% of folds."),
    x = "Appearance frequency (folds with ≥1 DEP / 15 total)",
    y = "Number of proteins"
  ) +
  theme_bw(base_size = 9) +
  theme(plot.title = element_text(size = 10, face = "bold"),
        plot.subtitle = element_text(size = 8, color = "grey40"))

# Panel B: fold feature counts
p_ml3b <- ggplot(sn_ffc, aes(x = factor(Outer_fold), y = N_BH_significant)) +
  geom_col(fill = "#4BBEB6", alpha = 0.8) +
  labs(
    title = "B  DEP count per outer fold (strict nested)",
    subtitle = "7/15 folds had 0 DEPs (no model fit). Feature count range: 0–536.",
    x = "Outer fold", y = "Number of BH-significant DEPs"
  ) +
  theme_bw(base_size = 9) +
  theme(plot.title = element_text(size = 10, face = "bold"),
        plot.subtitle = element_text(size = 8, color = "grey40"),
        axis.text.x = element_text(size = 7))

# Combine
p_ml3 <- (p_ml3a / p_ml3b) + patchwork::plot_annotation(
  title = "S-ML3: Strict-nested feature stability and zero-feature folds",
  theme = theme(plot.title = element_text(size = 11, face = "bold"))
)

ggsave(file.path(out_dir, "SuppFig_S-ML3_feature_stability.pdf"), p_ml3, width = 9, height = 7)
ggsave(file.path(out_dir, "SuppFig_S-ML3_feature_stability.svg"), p_ml3, width = 9, height = 7)
ggsave(file.path(out_dir, "SuppFig_S-ML3_feature_stability.png"), p_ml3, width = 9, height = 7, dpi = 300, bg = "white")
cat("  Saved S-ML3\n")

# =============================================================================
# S-M09: KNN imputation sensitivity
# =============================================================================
cat("=== S-M09: KNN sensitivity ===\n")
m09 <- read.csv(file.path(v2, "M09_missingness_sensitivity/KNN_sensitivity/M09_KNN_E_comparison.csv"), stringsAsFactors=FALSE)

# Compute stats
pearson_cor <- cor(m09$E_primary, m09$E_knn, method = "pearson", use = "complete.obs")
spearman_cor <- cor(m09$E_primary, m09$E_knn, method = "spearman", use = "complete.obs")
dir_conc <- sum(m09$Direction_concordant, na.rm = TRUE)
n_total <- nrow(m09)
primary_sig <- sum(m09$Primary_FDR < 0.05, na.rm = TRUE)
knn_sig <- sum(m09$KNN_FDR < 0.05, na.rm = TRUE)

p_m09 <- ggplot(m09, aes(x = E_primary, y = E_knn, color = Direction_concordant)) +
  geom_point(alpha = 0.6, size = 0.8) +
  geom_abline(slope = 1, intercept = 0, linetype = "dashed", color = "grey50") +
  scale_color_manual(values = c("TRUE" = "#4BBEB6", "FALSE" = "#FF6347"),
                    labels = c("Direction concordant", "Direction discordant")) +
  labs(
    title = "S-M09: KNN imputation sensitivity — overall exposure effect (E)",
    subtitle = paste0("Full 515-cohort, Q515 universe (n=", n_total, " proteins).\n",
                      "Pearson r = ", round(pearson_cor, 4),
                      "; Spearman r = ", round(spearman_cor, 4),
                      "; direction concordance = ", dir_conc, "/", n_total),
    x = "Primary E (no imputation)",
    y = "KNN-imputed E",
    color = "Direction",
    caption = "Sensitivity analysis only — not validation. Source: M09_KNN_E_comparison.csv (repaired Phase 3).\nPrimary FDR<0.05: 0; KNN FDR<0.05: 0. Overall exposure family is null in both."
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    plot.caption = element_text(size = 7, color = "grey50", hjust = 0)
  )

ggsave(file.path(out_dir, "SuppFig_S-M09_KNN_sensitivity.pdf"), p_m09, width = 7, height = 6)
ggsave(file.path(out_dir, "SuppFig_S-M09_KNN_sensitivity.svg"), p_m09, width = 7, height = 6)
ggsave(file.path(out_dir, "SuppFig_S-M09_KNN_sensitivity.png"), p_m09, width = 7, height = 6, dpi = 300, bg = "white")
cat("  Saved S-M09\n")

# =============================================================================
# S-M11: Site LOO robustness
# =============================================================================
cat("=== S-M11: Site LOO robustness ===\n")
m11 <- read.csv(file.path(v2, "M11_site_robustness/M11_site_LOO_stability.csv"), stringsAsFactors=FALSE)

# Reshape: compute per-site median absolute shift from E_full
loo_cols <- grep("^E_loo_drop_", names(m11), value = TRUE)
sites <- gsub("E_loo_drop_", "", loo_cols)

site_summary <- data.frame()
for (i in seq_along(loo_cols)) {
  col <- loo_cols[i]
  site <- sites[i]
  shift <- m11[[col]] - m11$E_full
  abs_shift <- abs(shift)
  dir_change <- sign(shift) != sign(m11$E_full) & m11$E_full != 0
  site_summary <- rbind(site_summary, data.frame(
    site = site,
    median_abs_shift = median(abs_shift, na.rm = TRUE),
    mean_abs_shift = mean(abs_shift, na.rm = TRUE),
    max_abs_shift = max(abs_shift, na.rm = TRUE),
    dir_change_pct = mean(dir_change, na.rm = TRUE) * 100
  ))
}

# Add environment
site_env <- read.csv(file.path(v2, "M11_site_robustness/M11_site_composition.csv"), stringsAsFactors=FALSE)
site_summary$environment <- site_env$Environment[match(site_summary$site, site_env$Site)]

p_m11 <- ggplot(site_summary, aes(x = reorder(site, median_abs_shift), y = median_abs_shift, fill = environment)) +
  geom_col(alpha = 0.8) +
  coord_flip() +
  scale_fill_brewer(palette = "Set1") +
  labs(
    title = "S-M11: Leave-one-site-out sensitivity — median absolute effect shift",
    subtitle = "Per-protein overall exposure (E) effect: median absolute change when each site is excluded.",
    x = "Site left out", y = "Median |ΔE| across 1430 proteins",
    fill = "Environment",
    caption = "Source: M11_site_LOO_stability.csv (repaired Phase 4).\nLeave-one-site-out sensitivity — not site-independent validation. 9 sites, 1430 proteins."
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    plot.caption = element_text(size = 7, color = "grey50", hjust = 0)
  )

ggsave(file.path(out_dir, "SuppFig_S-M11_site_LOO.pdf"), p_m11, width = 8, height = 6)
ggsave(file.path(out_dir, "SuppFig_S-M11_site_LOO.svg"), p_m11, width = 8, height = 6)
ggsave(file.path(out_dir, "SuppFig_S-M11_site_LOO.png"), p_m11, width = 8, height = 6, dpi = 300, bg = "white")
cat("  Saved S-M11\n")

cat("\n=== All supplement figures generated ===\n")
