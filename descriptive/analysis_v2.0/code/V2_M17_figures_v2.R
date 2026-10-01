#!/usr/bin/env Rscript
# V2 M17 — Nature-style manuscript figures 1–6.
# Rendering only: consumes finalized result tables and never refits a model.

suppressPackageStartupMessages({
  library(ggplot2); library(patchwork); library(dplyr); library(tidyr)
  library(ggrepel); library(scales)
})

root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
source(file.path(root, "descriptive", "figure_display_labels.R"), local = TRUE)
v2 <- file.path(root, "descriptive", "analysis_v2.0")
fig_dir <- file.path(v2, "figures_final_v2")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
read_result <- function(...) read.csv(file.path(v2, ...), check.names = FALSE)

m05 <- read_result("M05_overall_exposure", "M05_overall_exposure_AE_results.csv")
m06_means <- read_result("M06_ordered_omnibus_architecture", "M06_adjusted_means_architecture_table.csv")
m06_arch <- read_result("M06_ordered_omnibus_architecture", "M06_architecture_class_summary.csv")
m07_lc <- read_result("M07_pairwise_contrasts", "M07_Low_vs_Control.csv")
m07_hc <- read_result("M07_pairwise_contrasts", "M07_High_vs_Control.csv")
m07_hl <- read_result("M07_pairwise_contrasts", "M07_High_vs_Low.csv")
m08 <- read_result("M08_detection", "Firth_primary", "M08_Firth_detection_Group_LR.csv")
m09 <- read_result("M09_missingness_sensitivity", "KNN_sensitivity", "M09_KNN_E_comparison.csv")
m10 <- read_result("M10_environment_interaction", "corrected_pure_interaction", "M10_pure_interaction.csv")
m11_site <- read_result("M11_site_robustness", "M11_site_composition.csv")
names(m11_site)[1] <- "Site"
m11_loo <- read_result("M11_site_robustness", "M11_site_LOO_stability.csv")
m14 <- read_result("M14_frozen_replication", "M14_replication_hierarchy.csv")
ml85 <- read_result("ml_v2.1", "results", "integrated_table_85.csv")
ml_cv <- read_result("ml_v2.1", "results", "outer_cv_metrics.csv")
strict_cv <- read_result("ml_v2.1", "strict_nested", "strict_nested_outer_metrics.csv")
ranked <- read_result("M12_pathway_v2.1", "ranked", "M12_ranked_combined_FDR.csv")
gsea <- read_result("M12_pathway_v2.1", "ranked_gsea", "M12_cameraPR_fgsea_concordance.csv")
ora <- read_result("M12_pathway_v2.1", "ora", "M12_ORA_combined_FDR.csv")
path_member <- read_result("M12_pathway_v2.1", "integration", "M12_ML_candidate_pathway_membership.csv")

pal <- c(Control = "#A6A6A6", Low = "#4A85B3", High = "#FF6347",
         Humid_hot = "#B266C4", High_altitude = "#4BBEB6",
         positive = "#FF6347", negative = "#4A85B3", neutral = "#A6A6A6",
         dark = "#2F3337", light = "#D8DDE2", accent = "#FFB84D")

theme_m17 <- function(base_size = 7.2) {
  theme_classic(base_size = base_size, base_family = "Arial") +
    theme(axis.line = element_line(linewidth = 0.35, colour = pal[["dark"]]),
          axis.ticks = element_line(linewidth = 0.35, colour = pal[["dark"]]),
          axis.text = element_text(colour = pal[["dark"]], size = base_size - 0.4),
          axis.title = element_text(colour = pal[["dark"]], size = base_size),
          legend.title = element_text(size = base_size - 0.2, face = "bold"),
          legend.text = element_text(size = base_size - 0.5),
          strip.background = element_blank(),
          strip.text = element_text(size = base_size, face = "bold", colour = pal[["dark"]]),
          plot.title = element_text(size = base_size + 0.5, face = "bold", hjust = 0),
          plot.subtitle = element_text(size = base_size - 0.2, colour = "#555555"),
          panel.grid.major.y = element_line(linewidth = 0.22, colour = "#ECECEC"),
          panel.grid.major.x = element_blank(), panel.grid.minor = element_blank(),
          plot.tag = element_text(size = base_size + 1.8, face = "bold"),
          plot.tag.position = c(0, 1), plot.margin = margin(5, 6, 5, 6))
}
theme_set(theme_m17())

write_source <- function(x, stem) write.csv(x, file.path(fig_dir, paste0(stem, "_source_data.csv")), row.names = FALSE, na = "")
save_figure <- function(plot, stem, width_mm = 183, height_mm = 130) {
  w <- width_mm / 25.4; h <- height_mm / 25.4
  svglite::svglite(file.path(fig_dir, paste0(stem, ".svg")), width = w, height = h, bg = "white")
  print(plot); dev.off()
  grDevices::cairo_pdf(file.path(fig_dir, paste0(stem, ".pdf")), width = w, height = h, family = "Arial", bg = "white")
  print(plot); dev.off()
  ragg::agg_png(file.path(fig_dir, paste0(stem, "_preview.png")), width = width_mm, height = height_mm,
                units = "mm", res = 300, background = "white")
  print(plot); dev.off()
}
short_label <- function(x, width = 38) vapply(x, function(z) paste(strwrap(z, width = width), collapse = "\n"), character(1))
safe_log10 <- function(x) -log10(pmax(x, .Machine$double.xmin))

# Figure 1 — Cohort, workflow and proteome landscape.
flow <- tibble::tribble(
  ~x, ~y, ~label, ~kind,
  1, 3, "Raw cohort\nn = 519", "cohort", 2, 3, "Exposure-defined\nn = 515", "cohort",
  3, 3.45, "Discovery\nn = 386", "discovery", 3, 2.55, "Reused hold-out\nn = 129", "holdout",
  4.25, 3.45, "Discovery screen\n1,445 proteins", "discovery", 5.45, 3.45, "Locked family\n85 proteins", "locked",
  6.65, 3.45, "Replication / ML\npredefined analyses", "analysis")
arrows <- tibble::tribble(~x, ~y, ~xend, ~yend,
  1.35, 3, 1.65, 3, 2.35, 3, 2.65, 3.38, 2.35, 3, 2.65, 2.62,
  3.35, 3.45, 3.85, 3.45, 4.65, 3.45, 5.05, 3.45, 5.85, 3.45, 6.25, 3.45,
  3.35, 2.55, 6.25, 2.78)
p1a <- ggplot(flow, aes(x, y)) +
  geom_segment(data = arrows, aes(x = x, y = y, xend = xend, yend = yend), inherit.aes = FALSE,
               linewidth = 0.5, colour = pal[["dark"]], arrow = arrow(length = unit(1.4, "mm"), type = "closed")) +
  geom_label(aes(label = label, fill = kind), size = 2.35, linewidth = 0.25, label.padding = unit(1.5, "mm")) +
  scale_fill_manual(values = c(cohort = "#EEF2F5", discovery = "#DCE8F3", holdout = "#F5E5E8",
                               locked = "#F3E7CB", analysis = "#E6ECE8")) +
  annotate("text", x = 4.75, y = 2.18, label = "Hold-out outcomes did not define the 85-protein family",
           size = 2.25, colour = "#555555") +
  coord_cartesian(xlim = c(0.55, 7.1), ylim = c(2.02, 3.9), clip = "off") +
  theme_void(base_family = "Arial", base_size = 7) + theme(legend.position = "none")
group_df <- data.frame(Group = factor(c("Control", "Low", "High"), levels = c("Control", "Low", "High")),
                       n = c(153, 186, 176), panel = "Group")
p1b <- ggplot(group_df, aes(Group, n, fill = Group)) + geom_col(width = 0.68) +
  geom_text(aes(label = n), vjust = -0.4, size = 2.5) + scale_fill_manual(values = pal[c("Control", "Low", "High")]) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.13))) + labs(x = NULL, y = "Participants", title = "Group composition") +
  theme(legend.position = "none")
site_df <- m11_site %>% pivot_longer(c(Control, Low, High), names_to = "Group", values_to = "n") %>%
  mutate(Group = factor(Group, levels = c("Control", "Low", "High")), panel = "Site")
p1c <- ggplot(site_df, aes(reorder(Site, n, FUN = sum), n, fill = Group)) + geom_col(width = 0.75) + coord_flip() +
  scale_fill_manual(values = pal[c("Control", "Low", "High")]) + labs(x = NULL, y = "Participants", title = "Site nesting", fill = "Group") +
  theme(legend.position = "top", legend.direction = "horizontal")
universe_df <- data.frame(Gate = factor(c("Raw protein groups", "Detection universe", "Quantitative universe", "Discovery eligible", "Locked candidates"),
  levels = rev(c("Raw protein groups", "Detection universe", "Quantitative universe", "Discovery eligible", "Locked candidates"))),
  n = c(3817, 3054, 1430, 1445, 85), panel = "Protein universe")
p1d <- ggplot(universe_df, aes(Gate, n)) + geom_col(fill = pal[["neutral"]], width = 0.7) + coord_flip() +
  geom_text(data = subset(universe_df, n >= 500), aes(label = comma(n)), hjust = 1.08, size = 2.35, colour = "white") +
  geom_text(data = subset(universe_df, n < 500), aes(label = comma(n)), hjust = -0.25, size = 2.35, colour = pal[["dark"]]) +
  scale_y_continuous(labels = comma, expand = expansion(mult = c(0, 0.08))) +
  labs(x = NULL, y = "Proteins", title = "Protein-universe gates")
fig1 <- (p1a / (p1b | p1c | p1d)) + plot_layout(heights = c(0.75, 1.25)) + plot_annotation(tag_levels = "a")
save_figure(fig1, "Fig1_cohort_design", height_mm = 128)
write_source(bind_rows(flow %>% mutate(panel = "a_flow"), group_df %>% rename(category = Group) %>% mutate(panel = "b_group"),
                       site_df %>% rename(category = Site) %>% mutate(panel = "c_site"),
                       universe_df %>% rename(category = Gate) %>% mutate(panel = "d_universe")), "Fig1_cohort_design")

# Figure 2 — Proteome-wide exposure associations.
m05_plot <- m05 %>% left_join(m06_means %>% select(PG.ProteinGroups, starts_with("adjusted_mean_")), by = "PG.ProteinGroups") %>%
  mutate(mean_abundance = rowMeans(across(starts_with("adjusted_mean_")), na.rm = TRUE), direction_plot = ifelse(log2FC_E >= 0, "Higher", "Lower"))
p2a <- ggplot(m05_plot, aes(mean_abundance, log2FC_E, colour = direction_plot)) + geom_hline(yintercept = 0, linewidth = 0.35, colour = "#777777") +
  geom_point(size = 0.8, alpha = 0.55) + scale_colour_manual(values = c(Higher = pal[["positive"]], Lower = pal[["negative"]])) +
  labs(x = "Adjusted mean abundance (log2)", y = "Overall exposure effect (log2 FC)", title = "Overall exposure association",
       subtitle = "0/1,430 at BH-FDR < 0.05", colour = "Direction") + theme(legend.position = "top")
pairwise <- bind_rows(m07_lc %>% mutate(Contrast = "Low - Control"), m07_hc %>% mutate(Contrast = "High - Control"),
                      m07_hl %>% mutate(Contrast = "High - Low")) %>%
  mutate(Contrast = factor(Contrast, levels = c("Low - Control", "High - Control", "High - Low")), sig = BH_FDR < 0.05)
p2b <- ggplot(pairwise, aes(effect, after_stat(density), fill = Contrast, colour = Contrast)) + geom_density(alpha = 0.16, linewidth = 0.7) +
  geom_vline(xintercept = 0, linewidth = 0.35, linetype = 2) +
  scale_fill_manual(values = c("Low - Control" = pal[["Low"]], "High - Control" = pal[["High"]], "High - Low" = pal[["accent"]])) +
  scale_colour_manual(values = c("Low - Control" = pal[["Low"]], "High - Control" = pal[["High"]], "High - Low" = pal[["accent"]])) +
  labs(x = "Pairwise effect (log2 FC)", y = "Density", title = "Pairwise effect distributions",
       subtitle = "FDR-supported: 13, 0 and 257 proteins", fill = NULL, colour = NULL) + theme(legend.position = "top")
det_plot <- m08 %>% filter(Model_status == "OK") %>% mutate(max_rate_difference = pmax(rate_C, rate_L, rate_H) - pmin(rate_C, rate_L, rate_H),
                                                              sig = BH_FDR_A_Det_Firth < 0.05)
p2c <- ggplot(det_plot, aes(max_rate_difference, safe_log10(BH_FDR_A_Det_Firth), colour = sig)) +
  geom_hline(yintercept = -log10(0.05), linewidth = 0.35, linetype = 2, colour = "#777777") + geom_point(size = 0.75, alpha = 0.55) +
  scale_colour_manual(values = c(`FALSE` = pal[["neutral"]], `TRUE` = pal[["accent"]])) +
  labs(x = "Maximum detection-rate difference", y = "-log10(BH-FDR)", title = "Firth detection test",
       subtitle = "2/3,054 proteins at BH-FDR < 0.05", colour = "FDR < 0.05") + theme(legend.position = "top")
arch_plot <- m06_arch %>% arrange(n) %>% mutate(architecture_class = factor(architecture_class, levels = architecture_class))
p2d <- ggplot(arch_plot, aes(architecture_class, n)) + geom_col(fill = pal[["neutral"]], width = 0.72) + coord_flip() +
  geom_text(aes(label = n), hjust = -0.12, size = 2.25) + scale_y_continuous(expand = expansion(mult = c(0, 0.13))) +
  labs(x = NULL, y = "Proteins", title = "Descriptive exposure architecture", subtitle = "Classification is descriptive, not a selection rule")
fig2 <- ((p2a | p2b) / (p2c | p2d)) + plot_annotation(tag_levels = "a")
save_figure(fig2, "Fig2_proteome_associations", height_mm = 145)
write_source(bind_rows(
  m05_plot %>% transmute(panel = "a_overall", PG.ProteinGroups, Display_label, x = mean_abundance, estimate = log2FC_E, ci_low = CI_low, ci_high = CI_high, p_value = P_raw, fdr = BH_FDR_AE, n = N_total),
  pairwise %>% transmute(panel = paste0("b_", as.character(Contrast)), PG.ProteinGroups, Display_label, estimate = effect, ci_low = CI_low, ci_high = CI_high, p_value = P_raw, fdr = BH_FDR),
  det_plot %>% transmute(panel = "c_detection", PG.ProteinGroups, Display_label, x = max_rate_difference, p_value = Firth_Group_LR_P, fdr = BH_FDR_A_Det_Firth, rate_C, rate_L, rate_H),
  arch_plot %>% transmute(panel = "d_architecture", category = architecture_class, n, pct)), "Fig2_proteome_associations")

# Figure 3 — Discovery High-vs-Low candidate biology.
cand_ids <- ml85$PG.ProteinGroups
cand <- ml85 %>% transmute(PG.ProteinGroups, Gene = Display_label, Discovery_effect = Discovery_log2FC.x,
  Holdout_effect = log2FC, Holdout_low = CI_low, Holdout_high = CI_high,
  Replication = case_when(FDR_supported_replication ~ "FDR-supported", Nominal_replication ~ "Nominal",
                          Direction_concordant ~ "Same direction", TRUE ~ "Discordant")) %>%
  left_join(m06_means %>% select(PG.ProteinGroups, adjusted_mean_Control, adjusted_mean_Low, adjusted_mean_High, descriptive_architecture_class), by = "PG.ProteinGroups") %>%
  left_join(m09, by = "PG.ProteinGroups") %>% arrange(Gene) %>% mutate(candidate_index = row_number())
p3a <- ggplot(cand, aes(Discovery_effect, candidate_index, colour = Discovery_effect >= 0)) + geom_vline(xintercept = 0, linewidth = 0.35, linetype = 2) +
  geom_segment(aes(x = 0, xend = Discovery_effect, yend = candidate_index), linewidth = 0.35, alpha = 0.75) + geom_point(size = 1.2) +
  scale_colour_manual(values = c(`FALSE` = pal[["negative"]], `TRUE` = pal[["positive"]]), guide = "none") +
  scale_y_continuous(breaks = c(1, 22, 43, 64, 85)) + labs(x = "Discovery High - Low effect (log2 FC)", y = "Candidate index (alphabetical)", title = "Locked 85-protein effect landscape")
profiles <- cand %>% select(PG.ProteinGroups, Gene, candidate_index, adjusted_mean_Control, adjusted_mean_Low, adjusted_mean_High) %>%
  pivot_longer(starts_with("adjusted_mean_"), names_to = "Group", values_to = "adjusted_mean") %>%
  mutate(Group = factor(sub("adjusted_mean_", "", Group), levels = c("Control", "Low", "High")), row_z = ave(adjusted_mean, PG.ProteinGroups, FUN = function(z) as.numeric(scale(z))))
p3b <- ggplot(profiles, aes(Group, candidate_index, fill = row_z)) + geom_tile() +
  scale_fill_gradient2(low = pal[["negative"]], mid = "white", high = pal[["positive"]], midpoint = 0, limits = c(-1.2, 1.2), oob = squish) +
  scale_y_continuous(breaks = c(1, 22, 43, 64, 85)) + labs(x = NULL, y = "Candidate index (alphabetical)", fill = "Row z-score", title = "Adjusted Control / Low / High profiles") +
  theme(legend.position = "top")
p3c <- ggplot(cand, aes(E_primary, E_knn, colour = Replication)) + geom_abline(slope = 1, intercept = 0, linewidth = 0.35, linetype = 2, colour = "#777777") +
  geom_point(size = 1.15, alpha = 0.8) + scale_colour_manual(values = c("Discordant" = pal[["neutral"]], "Same direction" = "#9CB7C3", "Nominal" = pal[["accent"]], "FDR-supported" = pal[["positive"]])) +
  coord_equal() + labs(x = "Primary overall exposure effect", y = "KNN-sensitivity effect", title = "Overall-exposure sensitivity", colour = NULL) +
  guides(colour = guide_legend(nrow = 2, byrow = TRUE, override.aes = list(size = 2))) +
  theme(legend.position = "top", legend.text = element_text(size = 5.6), legend.key.width = unit(2.5, "mm"))
cand_arch <- cand %>% count(descriptive_architecture_class, name = "n") %>% arrange(n) %>% mutate(descriptive_architecture_class = factor(descriptive_architecture_class, levels = descriptive_architecture_class))
p3d <- ggplot(cand_arch, aes(descriptive_architecture_class, n)) + geom_col(fill = pal[["neutral"]], width = 0.72) + coord_flip() +
  geom_text(aes(label = n), hjust = -0.12, size = 2.2) + scale_y_continuous(expand = expansion(mult = c(0, 0.18))) + labs(x = NULL, y = "Candidates", title = "Candidate architecture")
fig3 <- ((p3a | p3b) / (p3c + p3d + plot_layout(widths = c(0.8, 1.7)))) + plot_annotation(tag_levels = "a")
save_figure(fig3, "Fig3_candidate_biology", height_mm = 150)
write_source(bind_rows(
  cand %>% transmute(panel = "a_effect_landscape", PG.ProteinGroups, Gene, candidate_index, estimate = Discovery_effect, holdout_estimate = Holdout_effect, ci_low = Holdout_low, ci_high = Holdout_high, replication = Replication),
  profiles %>% transmute(panel = "b_profiles", PG.ProteinGroups, Gene, candidate_index, category = Group, value = adjusted_mean, scaled_value = row_z),
  cand %>% transmute(panel = "c_missingness", PG.ProteinGroups, Gene, primary_effect = E_primary, knn_effect = E_knn, difference = diff, replication = Replication),
  cand_arch %>% transmute(panel = "d_architecture", category = descriptive_architecture_class, n)), "Fig3_candidate_biology")

# Figure 4 — Environment, site and leave-one-site-out robustness.
m10p <- m10 %>% mutate(candidate = PG.ProteinGroups %in% cand_ids, direction = ifelse(dir_concordant, "Concordant", "Discordant"))
p4a <- ggplot(m10p, aes(E_Humid, E_HighAlt)) + geom_hline(yintercept = 0, linewidth = 0.3, colour = "#BBBBBB") + geom_vline(xintercept = 0, linewidth = 0.3, colour = "#BBBBBB") +
  geom_abline(slope = 1, intercept = 0, linewidth = 0.35, linetype = 2, colour = "#777777") + geom_point(aes(colour = candidate), size = 0.8, alpha = 0.55) +
  scale_colour_manual(values = c(`FALSE` = pal[["neutral"]], `TRUE` = pal[["accent"]])) + coord_equal() +
  labs(x = paste("Overall exposure effect:", display_environment("Humid-hot")),
       y = paste("Overall exposure effect:", display_environment("High-pressure/high-altitude")),
       title = "Environment-stratified estimates", colour = "Locked 85") + theme(legend.position = "top")
interaction_df <- m10p %>% mutate(fdr_bin = cut(interaction_BH, breaks = c(0, .05, .25, .5, .75, 1), include.lowest = TRUE)) %>% count(fdr_bin, name = "n")
p4b <- ggplot(interaction_df, aes(fdr_bin, n)) + geom_col(fill = pal[["neutral"]], width = 0.72) + geom_text(aes(label = n), vjust = -0.35, size = 2.3) +
  scale_y_continuous(expand = expansion(mult = c(0, 0.13))) + labs(x = "Pure 2-df interaction BH-FDR", y = "Proteins", title = "Formal interaction evidence", subtitle = "0/1,430 at BH-FDR < 0.05")
p4c <- ggplot(site_df, aes(reorder(Site, n, FUN = sum), n, fill = Group)) + geom_col(width = 0.75) + coord_flip() + scale_fill_manual(values = pal[c("Control", "Low", "High")]) +
  labs(x = NULL, y = "Participants", title = "Site x Group composition", fill = "Group") + theme(legend.position = "top")
loo_plot <- m11_loo %>% mutate(candidate = PG.ProteinGroups %in% cand_ids, consistency = ifelse(loo_dir_consistent, "Direction consistent", "Direction changed"))
p4d <- ggplot(loo_plot, aes(E_loo_max_shift, fill = consistency)) + geom_histogram(bins = 35, position = "identity", alpha = 0.72, colour = "white", linewidth = 0.15) +
  scale_fill_manual(values = c("Direction consistent" = pal[["negative"]], "Direction changed" = pal[["light"]])) +
  labs(x = "Maximum absolute LOO shift (log2 FC)", y = "Proteins", title = "Leave-one-site-out influence", subtitle = "Robustness evidence; not proof of no site heterogeneity", fill = NULL) + theme(legend.position = "top")
fig4 <- ((p4a + p4b + plot_layout(widths = c(0.8, 1.7))) /
         (p4c + p4d + plot_layout(widths = c(1, 1.15)))) + plot_annotation(tag_levels = "a")
save_figure(fig4, "Fig4_environment_site", height_mm = 145)
write_source(bind_rows(
  m10p %>% transmute(panel = "a_environment", PG.ProteinGroups, Display_label, humid_effect = E_Humid, high_altitude_effect = E_HighAlt, interaction_p = interaction_P, interaction_fdr = interaction_BH, direction_concordant = dir_concordant, candidate),
  interaction_df %>% transmute(panel = "b_interaction", category = fdr_bin, n), site_df %>% transmute(panel = "c_site", category = Site, group = Group, n),
  loo_plot %>% transmute(panel = "d_loo", PG.ProteinGroups, full_effect = E_full, max_shift = E_loo_max_shift, effect_range = E_loo_range, direction_consistent = loo_dir_consistent, candidate)), "Fig4_environment_site")

# Figure 5 — Replication and conditional / strict-nested ML evidence.
m14p <- m14 %>% mutate(stage = factor(stage, levels = rev(stage)))
p5a <- ggplot(m14p, aes(stage, n)) + geom_col(fill = pal[["neutral"]], width = 0.7) + coord_flip() + geom_text(aes(label = n), hjust = -0.15, size = 2.35) +
  scale_y_continuous(limits = c(0, 96), expand = c(0, 0)) + labs(x = NULL, y = "Proteins (denominator = 85)", title = "Reused hold-out replication hierarchy")
cv_plot <- bind_rows(ml_cv %>% transmute(strategy = "Fixed-85 conditional ML", method = "LASSO", AUROC = lasso_auroc),
  ml_cv %>% transmute(strategy = "Fixed-85 conditional ML", method = "XGBoost", AUROC = xgb_auroc),
  strict_cv %>% transmute(strategy = "Strict nested ML", method = "LASSO", AUROC = lasso_auroc),
  strict_cv %>% transmute(strategy = "Strict nested ML", method = "Elastic Net", AUROC = en_auroc))
p5b <- ggplot(cv_plot, aes(method, AUROC, fill = method)) + geom_hline(yintercept = 0.5, linewidth = 0.35, linetype = 2, colour = "#777777") +
  geom_boxplot(width = 0.62, outlier.shape = NA, linewidth = 0.4) + geom_jitter(width = 0.09, size = 0.7, alpha = 0.55) + facet_wrap(~strategy, scales = "free_x") +
  scale_fill_manual(values = c("LASSO" = "#4A85B3", "Elastic Net" = "#4BBEB6", "XGBoost" = "#FFB84D")) + coord_cartesian(ylim = c(0.35, 0.82)) +
  labs(x = NULL, y = "Outer-fold AUROC", title = "Predictive performance by prespecified branch") + theme(legend.position = "none", axis.text.x = element_text(angle = 25, hjust = 1))
ml_long <- ml85 %>% arrange(Display_label) %>% mutate(candidate_index = row_number()) %>%
  transmute(PG.ProteinGroups, Gene = Display_label, candidate_index,
    Replication = case_when(FDR_supported_replication ~ "FDR", Nominal_replication ~ "Nominal", Direction_concordant ~ "Direction", TRUE ~ "No support"),
    LASSO = LASSO_selection_freq, `Elastic Net` = EN_selection_freq, Boruta = Boruta_confirmed_freq,
    XGBoost = 1 - (XGBoost_mean_rank - 1) / max(XGBoost_mean_rank - 1, na.rm = TRUE)) %>%
  pivot_longer(c(LASSO, `Elastic Net`, Boruta, XGBoost), names_to = "Method", values_to = "Stability")
p5c <- ggplot(ml_long, aes(Method, candidate_index, size = Stability, colour = Replication)) + geom_point(alpha = 0.82) +
  scale_size(range = c(0.15, 2.3), limits = c(0, 1)) + scale_colour_manual(values = c("No support" = pal[["light"]], Direction = "#9CB7C3", Nominal = pal[["accent"]], FDR = pal[["positive"]])) +
  scale_y_continuous(breaks = c(1, 22, 43, 64, 85)) + labs(x = NULL, y = "Candidate index (alphabetical)", title = "Candidate-level evidence convergence",
       subtitle = "Point size is within-method stability/importance; no composite rank", size = "Scaled evidence", colour = "Replication") + theme(legend.position = "top")
summary_ml <- ml85 %>% summarise(`LASSO selected >=50%` = sum(LASSO_selection_freq >= 0.5, na.rm = TRUE),
  `Elastic Net selected >=50%` = sum(EN_selection_freq >= 0.5, na.rm = TRUE), `Boruta confirmed` = sum(Boruta_full_status == "Confirmed", na.rm = TRUE),
  `XGBoost top-20 mean rank` = sum(XGBoost_mean_rank <= 20, na.rm = TRUE)) %>% pivot_longer(everything(), names_to = "criterion", values_to = "n") %>%
  mutate(criterion = factor(criterion, levels = rev(criterion)))
p5d <- ggplot(summary_ml, aes(criterion, n)) + geom_col(fill = pal[["neutral"]], width = 0.7) + coord_flip() + geom_text(aes(label = n), hjust = -0.15, size = 2.3) +
  scale_y_continuous(limits = c(0, 92), expand = c(0, 0)) + labs(x = NULL, y = "Candidates", title = "Method-specific support counts", subtitle = "Criteria shown separately; no winner implied")
fig5 <- ((p5a | p5b) / (p5c | p5d)) + plot_annotation(tag_levels = "a")
save_figure(fig5, "Fig5_replication_ml", height_mm = 150)
write_source(bind_rows(m14p %>% transmute(panel = "a_replication", category = stage, n, status, note = terminology_note),
  cv_plot %>% transmute(panel = "b_cv", strategy, method, value = AUROC),
  ml_long %>% transmute(panel = "c_convergence", PG.ProteinGroups, Gene, candidate_index, method = Method, value = Stability, replication = Replication),
  summary_ml %>% transmute(panel = "d_support_counts", category = criterion, n)), "Fig5_replication_ml")

# Figure 6 — Pathway and integrated biological interpretation.
rank_top <- ranked %>% filter(database == "GO_BP", FDR_pooled < 0.05) %>% arrange(FDR_pooled) %>% slice_head(n = 8) %>%
  mutate(label = factor(short_label(pathway_name, 30), levels = rev(short_label(pathway_name, 30))), signed_score = ifelse(direction == "Up", 1, -1) * safe_log10(FDR_pooled))
p6a <- ggplot(rank_top, aes(signed_score, label, colour = direction, size = pathway_size)) + geom_vline(xintercept = 0, linewidth = 0.35, colour = "#777777") + geom_point(alpha = 0.9) +
  scale_colour_manual(values = c(Up = pal[["positive"]], Down = pal[["negative"]])) + labs(x = "Signed -log10(pooled FDR)", y = NULL, title = "Ranked cameraPR pathways", colour = "Direction", size = "Genes") +
  theme(legend.position = "top", axis.text.y = element_text(size = 5.9, lineheight = 0.9))
gsea_plot <- gsea %>% filter(is.finite(FDR), is.finite(padj)) %>% mutate(camera_score = safe_log10(FDR), fgsea_score = safe_log10(padj),
  concordance = case_when(significant_both & same_direction ~ "Both, same direction", significant_cameraPR ~ "cameraPR only", significant_fgsea ~ "fgsea only", TRUE ~ "Neither"))
p6b <- ggplot(gsea_plot, aes(camera_score, fgsea_score, colour = concordance)) + geom_vline(xintercept = -log10(0.05), linewidth = 0.3, linetype = 2, colour = "#999999") +
  geom_hline(yintercept = -log10(0.05), linewidth = 0.3, linetype = 2, colour = "#999999") + geom_point(size = 0.7, alpha = 0.55) +
  scale_colour_manual(values = c("Neither" = pal[["light"]], "cameraPR only" = pal[["negative"]], "fgsea only" = pal[["accent"]], "Both, same direction" = pal[["positive"]])) +
  labs(x = "cameraPR -log10(FDR)", y = "fgsea -log10(FDR)", title = "Ranked-method sensitivity", colour = NULL) +
  guides(colour = guide_legend(nrow = 2, byrow = TRUE)) + theme(legend.position = "bottom", legend.key.width = unit(3, "mm"))
go_names <- ranked %>% filter(database == "GO_BP") %>% distinct(pathway_id, pathway_label = pathway_name)
ora_top <- ora %>% filter(database == "GO_BP", FDR_pooled < 0.05) %>% left_join(go_names, by = "pathway_id") %>%
  mutate(pathway_name = ifelse(is.na(pathway_label), pathway_name, pathway_label)) %>% arrange(FDR_pooled) %>% slice_head(n = 10) %>%
  mutate(label = factor(short_label(pathway_name, 34), levels = rev(short_label(pathway_name, 34))))
p6c <- ggplot(ora_top, aes(enrichment_ratio, label, size = foreground_mapped, colour = safe_log10(FDR_pooled))) + geom_point(alpha = 0.9) +
  scale_colour_gradient(low = "#A9C3CC", high = pal[["negative"]]) + labs(x = "Enrichment ratio", y = NULL, title = "Candidate-family ORA", size = "Candidates", colour = "-log10(FDR)") + theme(legend.position = "top")
network_source <- path_member %>% filter(pathway_database == "GO_BP", !is.na(ranked_pathway_FDR)) %>% group_by(pathway_id, pathway_name) %>%
  mutate(pathway_fdr = min(ranked_pathway_FDR, na.rm = TRUE)) %>% ungroup()
top_path_ids <- network_source %>% distinct(pathway_id, pathway_name, pathway_fdr) %>% arrange(pathway_fdr) %>% slice_head(n = 4) %>% pull(pathway_id)
net <- network_source %>% filter(pathway_id %in% top_path_ids) %>% mutate(pathway_short = short_label(pathway_name, 24), candidate = Gene_symbol)
path_levels <- unique(net$pathway_short[order(net$pathway_fdr)]); gene_levels <- sort(unique(net$candidate))
net <- net %>% mutate(x = match(pathway_short, path_levels), y = match(candidate, gene_levels))
net_nodes_path <- net %>% distinct(pathway_short, x, pathway_fdr) %>% mutate(y = length(gene_levels) + 2)
net_nodes_gene <- net %>% distinct(candidate, y) %>% mutate(x = seq(1, length(path_levels), length.out = n()))
net_edges <- net %>% left_join(net_nodes_gene %>% select(candidate, gene_x = x, gene_y = y), by = "candidate") %>% mutate(path_y = length(gene_levels) + 2)
p6d <- ggplot() + geom_segment(data = net_edges, aes(x = x, y = path_y - 0.35, xend = gene_x, yend = gene_y + 0.35), linewidth = 0.28, colour = "#BCC2C7", alpha = 0.65) +
  geom_point(data = net_nodes_path, aes(x, y, size = safe_log10(pathway_fdr)), shape = 22, fill = pal[["negative"]], colour = "white") +
  geom_text(data = net_nodes_path, aes(x, y + 0.7, label = pathway_short), size = 1.85, lineheight = 0.85) +
  geom_point(data = net_nodes_gene, aes(x, y), size = 1.8, colour = pal[["accent"]]) + geom_text(data = net_nodes_gene, aes(x, y - 0.55, label = candidate), size = 1.75, angle = 45, hjust = 1) +
  scale_size(range = c(2.2, 4.2), guide = "none") + coord_cartesian(clip = "off") + labs(title = "Compact pathway-candidate map") +
  theme_void(base_family = "Arial", base_size = 7) + theme(plot.title = element_text(size = 7.7, face = "bold"), plot.margin = margin(8, 10, 14, 10))
fig6 <- ((p6a | p6b) / (p6c | p6d)) + plot_annotation(tag_levels = "a")
save_figure(fig6, "Fig6_pathway_integration", height_mm = 158)
write_source(bind_rows(rank_top %>% transmute(panel = "a_ranked", database, pathway_id, pathway_name, pathway_size, direction, p_value = PValue, fdr = FDR_pooled, signed_score),
  gsea_plot %>% transmute(panel = "b_sensitivity", database, pathway_id, pathway_name, camera_fdr = FDR, fgsea_fdr = padj, NES, same_direction, concordance),
  ora_top %>% transmute(panel = "c_ora", database, pathway_id, pathway_name, foreground_mapped, background_pathway, foreground_total, background_total, enrichment_ratio, odds_ratio, p_value = PValue, fdr = FDR_pooled),
  net %>% transmute(panel = "d_network", pathway_id, pathway_name, pathway_fdr, PG.ProteinGroups, Gene_symbol, ML_branch, ML_stability, D08_replication)), "Fig6_pathway_integration")

cat("M17 figures 1–6 written to:", fig_dir, "\n")
