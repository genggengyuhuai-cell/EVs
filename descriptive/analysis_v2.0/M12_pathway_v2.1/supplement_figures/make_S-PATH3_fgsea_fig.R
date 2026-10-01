# =============================================================================
# S-PATH3: fgsea 四族补充图（GO-BP / GO-MF / GO-CC / Reactome）
# 从 repaired M12_fgsea_combined.csv 读取，不手工输入数值
# 双列标注：padj_family（家族内 BH）与 padj_pooled（跨族合并 BH）
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(ggrepel)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
OUT_DIR <- file.path(M12, "supplement_figures")

fg <- read.csv(file.path(M12, "ranked_gsea/M12_fgsea_combined.csv"),
               stringsAsFactors=FALSE, check.names=FALSE)

# Filter: keep pathways with at least one FDR < 0.05, or top N by pval
fg_sig <- fg[fg$padj < 0.05 | fg$padj_pooled < 0.05, ]
cat("Significant pathways (either FDR):", nrow(fg_sig), "\n")

# For each family, take top 15 by padj_pooled
families <- c("GO_BP", "GO_MF", "GO_CC", "Reactome")
family_labels <- c("GO Biological Process", "GO Molecular Function",
                   "GO Cellular Component", "Reactome")

plot_df <- data.frame()
for (i in seq_along(families)) {
  fam <- families[i]
  sub <- fg_sig[fg_sig$database == fam, ]
  sub <- sub[order(sub$padj_pooled), ]
  sub <- head(sub, 15)
  if (nrow(sub) > 0) {
    sub$family_label <- family_labels[i]
    sub$family_order <- i
    plot_df <- rbind(plot_df, sub)
  }
}

cat("Plotting pathways:", nrow(plot_df), "\n")

# Shorten pathway names for readability
plot_df$pathway_short <- ifelse(nchar(plot_df$pathway) > 45,
                                paste0(substr(plot_df$pathway, 1, 42), "..."),
                                plot_df$pathway)

# Order by family then padj_pooled
plot_df$pathway_short <- factor(plot_df$pathway_short,
                                levels = rev(unique(plot_df$pathway_short[order(plot_df$family_order, plot_df$padj_pooled)])))

# Create dotplot: NES on x, pathway on y, color by family, size by -log10(padj_pooled)
# Two columns annotation: shape = padj_family sig, color = padj_pooled sig
plot_df$sig_family <- ifelse(plot_df$padj < 0.05, "padj_family < 0.05", "n.s.")
plot_df$sig_pooled <- ifelse(plot_df$padj_pooled < 0.05, "padj_pooled < 0.05", "n.s.")

p <- ggplot(plot_df, aes(x = NES, y = pathway_short, color = family_label)) +
  geom_point(aes(size = -log10(padj_pooled), shape = sig_family)) +
  geom_vline(xintercept = 0, linetype = "dashed", color = "grey50") +
  facet_wrap(~ family_label, scales = "free_y", ncol = 2) +
  scale_color_brewer(palette = "Set1", guide = "none") +
  scale_shape_manual(values = c("padj_family < 0.05" = 16, "n.s." = 1)) +
  labs(
    title = "fgsea Multilevel — Significant Pathways by Family",
    subtitle = "Dot size = -log10(padj_pooled); Shape: filled = padj_family<0.05, open = n.s. (family-wise)",
    x = "Normalized Enrichment Score (NES)",
    y = "",
    shape = "Family-wise FDR"
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    strip.background = element_rect(fill = "grey90"),
    strip.text = element_text(size = 9, face = "bold"),
    axis.text.y = element_text(size = 7),
    legend.position = "bottom"
  )

# Save PDF, SVG, PNG
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH3_fgsea_4families.pdf"), p,
       width = 12, height = 10, units = "in")
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH3_fgsea_4families.svg"), p,
       width = 12, height = 10, units = "in")
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH3_fgsea_4families.png"), p,
       width = 12, height = 10, units = "in", dpi = 300, bg = "white")

cat("Saved fgsea 4-family supplement figure.\n")

# Also create a summary barplot: counts per family, two FDR types
count_df <- data.frame(
  Family = rep(family_labels, 2),
  FDR_type = rep(c("padj_family (within-family BH)", "padj_pooled (cross-family BH)"), each = 4),
  Significant = c(
    sum(fg$padj < 0.05 & fg$database == "GO_BP", na.rm = TRUE),
    sum(fg$padj < 0.05 & fg$database == "GO_MF", na.rm = TRUE),
    sum(fg$padj < 0.05 & fg$database == "GO_CC", na.rm = TRUE),
    sum(fg$padj < 0.05 & fg$database == "Reactome", na.rm = TRUE),
    sum(fg$padj_pooled < 0.05 & fg$database == "GO_BP", na.rm = TRUE),
    sum(fg$padj_pooled < 0.05 & fg$database == "GO_MF", na.rm = TRUE),
    sum(fg$padj_pooled < 0.05 & fg$database == "GO_CC", na.rm = TRUE),
    sum(fg$padj_pooled < 0.05 & fg$database == "Reactome", na.rm = TRUE)
  )
)

p2 <- ggplot(count_df, aes(x = Family, y = Significant, fill = FDR_type)) +
  geom_bar(stat = "identity", position = "dodge") +
  geom_text(aes(label = Significant), position = position_dodge(width = 0.9), vjust = -0.5, size = 3) +
  labs(
    title = "fgsea Significant Pathway Counts — Two FDR Columns",
    subtitle = "Canonical_FDR = UNRESOLVED (both columns shown per contract §12)",
    x = "", y = "Number of significant pathways (FDR < 0.05)",
    fill = "FDR column"
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    axis.text.x = element_text(size = 8, angle = 15, hjust = 1),
    legend.position = "bottom"
  )

ggsave(file.path(OUT_DIR, "SuppFig_S-PATH3_fgsea_FDR_summary.pdf"), p2,
       width = 8, height = 5, units = "in")
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH3_fgsea_FDR_summary.svg"), p2,
       width = 8, height = 5, units = "in")
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH3_fgsea_FDR_summary.png"), p2,
       width = 8, height = 5, units = "in", dpi = 300, bg = "white")

cat("Saved fgsea FDR summary barplot.\n")
cat("\nDone S-PATH3.\n")
