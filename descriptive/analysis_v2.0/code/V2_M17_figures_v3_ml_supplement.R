#!/usr/bin/env Rscript
# V3 M17 — Supplementary figure: ML-based prioritization of the 85 frozen discovery proteins.
# Rendering only. Reads frozen integrated_table_85.csv and strict_nested_feature_stability.csv.
# Does NOT refit models, re-rank candidates, or alter any frozen result.
#
# Interpretation guardrails (enforced in caption/manuscript, not by the plot):
#   - Conditional on the locked 85-protein Discovery panel.
#   - NOT unbiased generalization; NOT a validated biomarker panel.
#   - Boruta-style procedure confirms all 85 (by construction on a pre-selected set);
#     XGBoost gain is the discriminating axis here.
#   - Strict-nested fold-local DEP range 8-618 reflects feature-selection instability
#     under resampling, not biological heterogeneity.

suppressPackageStartupMessages({
  library(ggplot2); library(patchwork); library(dplyr)
  library(scales)
})

root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
v2 <- file.path(root, "descriptive", "analysis_v2.0")
fig_dir <- file.path(v2, "figures_final_v2")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
read_result <- function(...) read.csv(file.path(v2, ...), check.names = FALSE)

ml85 <- read_result("ml_v2.1", "results", "integrated_table_85.csv")
names(ml85)[names(ml85) == "Discovery_log2FC.x"] <- "Discovery_log2FC"
stab <- read_result("ml_v2.1", "strict_nested", "strict_nested_feature_stability.csv")

# Coerce numeric
num_cols <- c("Discovery_log2FC","Discovery_BH_FDR",
              "LASSO_selection_freq","EN_selection_freq",
              "Boruta_confirmed_freq","Boruta_mean_frac_beat",
              "XGBoost_mean_rank","XGBoost_mean_gain")
for (cc in num_cols) ml85[[cc]] <- suppressWarnings(as.numeric(ml85[[cc]]))
ml85$Direction_concordant <- as.logical(ml85$Direction_concordant)
ml85$Nominal_replication  <- as.logical(ml85$Nominal_replication)
ml85$FDR_supported_replication <- as.logical(ml85$FDR_supported_replication)

# Join strict-nested stability on PG
stab$PG.ProteinGroups <- stab[["PG.ProteinGroups"]]
ml <- ml85 %>% left_join(stab, by = "PG.ProteinGroups")

# Replication tier (ordered)
ml$rep_tier <- factor(
  ifelse(ml$FDR_supported_replication, "FDR-supported (1/85)",
         ifelse(ml$Nominal_replication, "Nominal (29/85)",
                ifelse(ml$Direction_concordant, "Direction concordant (83/85)",
                       "Direction discordant"))),
  levels = c("Direction discordant",
             "Direction concordant (83/85)",
             "Nominal (29/85)",
             "FDR-supported (1/85)"))

pal_tier <- c("Direction discordant"          = "#A6A6A6",
              "Direction concordant (83/85)"  = "#4BBEB6",
              "Nominal (29/85)"               = "#FFB84D",
              "FDR-supported (1/85)"          = "#FF6347")

# ---------- Panel A: top 15 by XGBoost mean gain ----------
top_xgb <- ml %>% arrange(desc(XGBoost_mean_gain)) %>% head(15) %>%
  mutate(Display_label = factor(Display_label, levels = rev(Display_label)))
pA <- ggplot(top_xgb, aes(x = XGBoost_mean_gain, y = Display_label, fill = rep_tier)) +
  geom_col(width = 0.72) +
  scale_fill_manual(values = pal_tier, drop = FALSE) +
  labs(x = "XGBoost mean gain (outer folds)", y = NULL,
       title = "A  Top XGBoost gain among the 85 locked Discovery proteins",
       fill = "Replication tier") +
  theme_classic(base_size = 7.2) +
  theme(plot.title = element_text(size = 7.8, face = "bold"),
        legend.position = c(0.98, 0.02), legend.justification = c(1, 0),
        legend.background = element_rect(fill = "white", colour = NA),
        panel.grid.major.x = element_line(linewidth = 0.22, colour = "#ECECEC"))

# ---------- Panel B: LASSO + EN selection frequency (top 15 by EN) ----------
top_en <- ml %>% arrange(desc(EN_selection_freq)) %>% head(15) %>%
  select(Display_label, EN_selection_freq, LASSO_selection_freq) %>%
  tidyr::pivot_longer(-Display_label,
                      names_to = "model", values_to = "freq") %>%
  mutate(model = recode(model,
                         EN_selection_freq = "Elastic Net",
                         LASSO_selection_freq = "LASSO"),
         Display_label = factor(Display_label,
                                levels = rev(unique(Display_label))))
pB <- ggplot(top_en, aes(x = freq, y = Display_label, fill = model)) +
  geom_col(width = 0.72, position = position_dodge(width = 0.8)) +
  scale_fill_manual(values = c("Elastic Net" = "#4A85B3",
                               "LASSO"         = "#4BBEB6")) +
  scale_x_continuous(labels = percent_format(scale = 100), limits = c(0, 1)) +
  labs(x = "Outer-fold selection frequency", y = NULL,
       title = "B  Penalised selection frequency (top 15 by Elastic Net)",
       fill = "Model") +
  theme_classic(base_size = 7.2) +
  theme(plot.title = element_text(size = 7.8, face = "bold"),
        legend.position = c(0.98, 0.02), legend.justification = c(1, 0),
        panel.grid.major.x = element_line(linewidth = 0.22, colour = "#ECECEC"))

# ---------- Panel C: strict-nested selection frequency for the 85 ----------
# overall_en_freq = fraction of 15 outer folds in which the protein was
# re-discovered AND selected by Elastic Net in that fold.
pC <- ggplot(ml, aes(x = overall_en_freq)) +
  geom_histogram(binwidth = 1/15, fill = "#4A85B3", colour = "white",
                 linewidth = 0.2) +
  scale_x_continuous(labels = percent_format(scale = 100),
                     breaks = seq(0, 1, by = 1/3),
                     limits = c(0, 1)) +
  labs(x = "Strict-nested selection frequency (15 outer folds, Elastic Net)",
       y = "Number of 85 locked proteins",
       title = "C  Strict-nested feature stability") +
  annotate("text", x = 0.98, y = Inf, hjust = 1, vjust = 1.1, size = 2.2,
           label = paste0("Fold-local DEP range: 8-618\n(n = 85 locked proteins)"),
           colour = "#555555") +
  theme_classic(base_size = 7.2) +
  theme(plot.title = element_text(size = 7.8, face = "bold"),
        panel.grid.major.y = element_line(linewidth = 0.22, colour = "#ECECEC"))

# ---------- Panel D: Discovery log2FC vs XGBoost gain, colored by tier ----------
pD <- ggplot(ml, aes(x = Discovery_log2FC, y = XGBoost_mean_gain,
                     colour = rep_tier)) +
  geom_point(size = 1.4, alpha = 0.85) +
  geom_vline(xintercept = 0, linewidth = 0.3, linetype = "dashed",
             colour = "#555555") +
  scale_colour_manual(values = pal_tier, drop = FALSE) +
  labs(x = "Discovery High-vs-Low log2 fold change",
       y = "XGBoost mean gain",
       title = "D  Discovery effect vs ML gain (all 85 locked proteins)",
       colour = "Replication tier") +
  theme_classic(base_size = 7.2) +
  theme(plot.title = element_text(size = 7.8, face = "bold"),
        legend.position = c(0.98, 0.02), legend.justification = c(1, 0),
        legend.background = element_rect(fill = "white", colour = NA),
        panel.grid.major = element_line(linewidth = 0.22, colour = "#ECECEC"))

# ---------- Compose ----------
fig <- (pA | pB) / (pC | pD) +
  plot_annotation(
    title = "Supplementary Figure — ML-based prioritisation of the 85 frozen Discovery proteins",
    subtitle = "Conditional on the locked 85-protein High-vs-Low Discovery panel. Not an unbiased generalisation estimate; not a validated biomarker panel.",
    theme = theme(plot.title = element_text(size = 9.5, face = "bold"),
                  plot.subtitle = element_text(size = 7.2, colour = "#555555")))

out_pdf <- file.path(fig_dir, "SuppFig_ML_prioritization.pdf")
out_svg <- file.path(fig_dir, "SuppFig_ML_prioritization.svg")
out_png <- file.path(fig_dir, "SuppFig_ML_prioritization_preview.png")
out_csv <- file.path(fig_dir, "SuppFig_ML_prioritization_source_data.csv")

ggsave(out_pdf, fig, width = 183/25.4, height = 130/25.4, device = cairo_pdf)
ggsave(out_svg, fig, width = 183/25.4, height = 130/25.4, device = svglite::svglite)
ggsave(out_png, fig, width = 183/25.4, height = 130/25.4, dpi = 300)

# Source data: one row per protein per panel used
src <- ml %>% transmute(
  PG.ProteinGroups, Display_label,
  Discovery_log2FC, Discovery_BH_FDR,
  Direction_concordant, Nominal_replication, FDR_supported_replication,
  LASSO_selection_freq, EN_selection_freq,
  XGBoost_mean_gain,
  strict_nested_lasso_freq   = overall_lasso_freq,
  strict_nested_en_freq      = overall_en_freq,
  panel = "all_85")
write.csv(src, out_csv, row.names = FALSE, quote = TRUE)

message("Wrote: ", out_pdf)
message("Wrote: ", out_svg)
message("Wrote: ", out_png)
message("Wrote: ", out_csv)
