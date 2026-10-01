# =============================================================================
# S-PATH4: Pathway Method Overlap 图
# 从 repaired PATHWAY_METHOD_OVERLAP.csv 读取
# =============================================================================

suppressPackageStartupMessages({
  library(ggplot2)
  library(dplyr)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
OUT_DIR <- file.path(M12, "supplement_figures")

ov <- read.csv(file.path(M12, "PATHWAY_METHOD_OVERLAP.csv"), stringsAsFactors=FALSE)

# Summary: how many pathways are sig in each combination
ov_summary <- ov %>%
  mutate(
    combo = case_when(
      cameraPR_sig & ORA_sig & fgsea_sig ~ "All 3 methods",
      cameraPR_sig & ORA_sig & !fgsea_sig ~ "cameraPR + ORA",
      cameraPR_sig & !ORA_sig & fgsea_sig ~ "cameraPR + fgsea",
      !cameraPR_sig & ORA_sig & fgsea_sig ~ "ORA + fgsea",
      cameraPR_sig & !ORA_sig & !fgsea_sig ~ "cameraPR only",
      !cameraPR_sig & ORA_sig & !fgsea_sig ~ "ORA only",
      !cameraPR_sig & !ORA_sig & fgsea_sig ~ "fgsea only",
      TRUE ~ "None"
    )
  )

combo_counts <- as.data.frame(table(ov_summary$combo))
names(combo_counts) <- c("Combination", "Count")

# Order by count descending
combo_counts$Combination <- factor(combo_counts$Combination,
                                  levels = combo_counts$Combination[order(-combo_counts$Count)])

p <- ggplot(combo_counts, aes(x = reorder(Combination, Count), y = Count, fill = Combination)) +
  geom_bar(stat = "identity") +
  geom_text(aes(label = Count), hjust = -0.2, size = 3.5) +
  coord_flip() +
  labs(
    title = "Pathway Method Overlap — Significant Pathways by Method Combination",
    subtitle = "363 pathways significant in >= 1 method (cameraPR pooled / ORA pooled / fgsea pooled FDR < 0.05)",
    x = "", y = "Number of pathways",
    caption = "Descriptive overlap only — no new significance rule (per contract §14)"
  ) +
  theme_bw(base_size = 9) +
  theme(
    plot.title = element_text(size = 11, face = "bold"),
    plot.subtitle = element_text(size = 8, color = "grey40"),
    legend.position = "none",
    plot.caption = element_text(size = 7, color = "grey50", hjust = 0)
  )

ggsave(file.path(OUT_DIR, "SuppFig_S-PATH4_method_overlap.pdf"), p,
       width = 9, height = 5, units = "in")
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH4_method_overlap.svg"), p,
       width = 9, height = 5, units = "in")
ggsave(file.path(OUT_DIR, "SuppFig_S-PATH4_method_overlap.png"), p,
       width = 9, height = 5, units = "in", dpi = 300, bg = "white")

cat("Saved S-PATH4 method overlap figure.\n")
cat("Total pathways in overlap table:", nrow(ov), "\n")
