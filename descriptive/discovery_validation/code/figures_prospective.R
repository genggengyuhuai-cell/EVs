#!/usr/bin/env Rscript
# R-only, result-table-only manuscript figures.
# No model fitting, FDR recalculation, candidate selection, threshold tuning,
# evidence scoring/ranking, or biological-data access is permitted here.

suppressPackageStartupMessages({
  library(ggplot2)
  library(patchwork)
})

args <- commandArgs(trailingOnly = TRUE)
if (length(args) != 2L) {
  stop("Usage: Rscript figures_prospective.R FIGURE_ID OUTPUT_STEM")
}

root <- normalizePath(
  file.path(
    dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))]))),
    "..", "..", ".."
  ),
  winslash = "/",
  mustWork = FALSE
)
base <- file.path(root, "descriptive", "discovery_validation")

read_result <- function(stage, file, cols) {
  p <- file.path(base, stage, file)
  if (!file.exists(p)) return(NULL)
  x <- read.csv(p, check.names = FALSE)
  names(x) <- sub("^\xef\xbb\xbf", "", names(x), useBytes = TRUE)
  missing_cols <- setdiff(cols, names(x))
  if (length(missing_cols)) {
    stop("Figure source contract missing: ", paste(missing_cols, collapse = ", "))
  }
  x
}

nonempty <- function(x, msg) {
  if (is.null(x) || !nrow(x)) {
    stop("NON_ESTIMABLE / missing finalized source: ", msg)
  }
  x
}

assert_exact_candidate_universe <- function(x, msg) {
  if (nrow(x) != 85L ||
      length(unique(x$PG.ProteinGroups)) != 85L ||
      anyNA(x$PG.ProteinGroups)) {
    stop(msg, ": expected exact 85-candidate universe")
  }
  invisible(TRUE)
}

as_flag <- function(x, name) {
  y <- if (is.logical(x)) x else ifelse(
    is.na(x),
    NA,
    toupper(trimws(as.character(x))) == "TRUE"
  )
  if (anyNA(y)) stop(name, ": missing/non-boolean flag")
  y
}

source_required <- c(
  "PG.ProteinGroups", "Gene_symbol", "Display_label", "analysis_universe",
  "analysis_branch",
  "contrast", "effect_estimate", "CI_low", "CI_high", "P_value", "BH_FDR",
  "Model_status", "display_selection_rule"
)
figure_source <- NULL

bind_rows_fill <- function(...) {
  xs <- list(...)
  cols <- unique(unlist(lapply(xs, names), use.names = FALSE))
  xs <- lapply(xs, function(x) {
    missing <- setdiff(cols, names(x))
    for (nm in missing) x[[nm]] <- NA
    x[cols]
  })
  do.call(rbind, xs)
}

add_identity <- function(x) {
  if (!"PG.ProteinGroups" %in% names(x)) x$PG.ProteinGroups <- NA_character_
  identity <- read_result(
    "D01_discovery_eligibility",
    "D01_discovery_eligible_proteins.csv",
    c("PG.ProteinGroups", "Gene_symbol", "Display_label")
  )
  identity <- identity[!duplicated(identity$PG.ProteinGroups),
                       c("PG.ProteinGroups", "Gene_symbol", "Display_label")]
  idx <- match(as.character(x$PG.ProteinGroups), identity$PG.ProteinGroups)
  if (!"Gene_symbol" %in% names(x)) x$Gene_symbol <- identity$Gene_symbol[idx]
  if (!"Display_label" %in% names(x)) x$Display_label <- identity$Display_label[idx]
  missing_label <- is.na(x$Display_label) | !nzchar(trimws(as.character(x$Display_label)))
  x$Display_label[missing_label] <- as.character(x$PG.ProteinGroups[missing_label])
  x
}

set_figure_source <- function(x) {
  x <- add_identity(x)
  if (!"display_selection_rule" %in% names(x) &&
      "selection_display_rule" %in% names(x)) {
    x$display_selection_rule <- x$selection_display_rule
  }
  missing <- setdiff(source_required, names(x))
  for (nm in missing) x[[nm]] <- NA
  first <- c("panel", source_required)
  first <- first[first %in% names(x)]
  figure_source <<- x[c(first, setdiff(names(x), first))]
  invisible(TRUE)
}

theme_set(
  theme_classic(base_size = 6.5, base_family = "Arial") +
    theme(
      axis.line = element_line(linewidth = .35),
      axis.ticks = element_line(linewidth = .35),
      legend.text = element_text(size = 5.8),
      strip.text = element_text(size = 6.2, face = "bold"),
      plot.title = element_text(size = 7, face = "bold"),
      plot.tag = element_text(size = 8, face = "bold")
    )
)

pal <- c(
  Control = "#777777",
  "Low exposure" = "#3B82A0",
  "High exposure" = "#C45A3D",
  "Humid-hot" = "#B24C63",
  "High-altitude" = "#3274A1"
)

evidence_pal <- c(
  "All tested proteins" = "#B8B8B8",
  "Discovery candidate" = "#3274A1",
  "Direction discordant" = "#B24C63",
  "Direction concordant only" = "#777777",
  "Nominal replication only" = "#3274A1",
  "FDR-supported replication" = "#2E7D65"
)

fig1 <- function() {
  assignment_path <- file.path(
    root,
    "descriptive",
    "discovery_validation_split",
    "discovery_validation_assignment.csv"
  )
  x <- nonempty(read.csv(assignment_path, check.names = FALSE), "frozen split")
  required <- c("TREAT1_clean", "Stratum", "Split")
  missing_cols <- setdiff(required, names(x))
  if (length(missing_cols)) {
    stop("FIG1 split contract missing: ", paste(missing_cols, collapse = ", "))
  }
  if (nrow(x) != 515L || sum(x$Split == "Discovery") != 386L ||
      sum(x$Split == "Validation") != 129L) {
    stop("FIG1 split audit contract changed: expected 515 = 386 + 129")
  }

  x$Dose <- factor(
    x$TREAT1_clean,
    c("control", "low", "high"),
    c("Control", "Low exposure", "High exposure")
  )
  x$Environment <- ifelse(
    grepl("^Humid-hot", x$Stratum),
    "Humid-hot",
    "High-altitude"
  )
  counts <- as.data.frame(table(x$Split, x$Environment, x$Dose))
  names(counts) <- c("Split", "Environment", "Dose", "N")

  p1 <- ggplot(counts, aes(Dose, N, fill = Split)) +
    geom_col(position = position_dodge(width = .72), width = .64) +
    geom_text(
      aes(label = N),
      position = position_dodge(width = .72),
      vjust = -.25,
      size = 2.2
    ) +
    facet_wrap(~Environment) +
    scale_fill_manual(values = c(Discovery = "#3274A1", Validation = "#C49A3D")) +
    scale_y_continuous(expand = expansion(mult = c(0, .12))) +
    labs(x = NULL, y = "Participants", fill = "Frozen split") +
    theme(axis.text.x = element_text(angle = 30, hjust = 1))

  scope <- data.frame(
    Step = factor(
      c(
        "Raw protein groups",
        "Discovery eligible",
        "Locked candidates",
        "Direction concordant",
        "Nominal replication",
        "FDR-supported replication"
      ),
      levels = rev(c(
        "Raw protein groups",
        "Discovery eligible",
        "Locked candidates",
        "Direction concordant",
        "Nominal replication",
        "FDR-supported replication"
      ))
    ),
    N = c(3817L, 1445L, 85L, 83L, 29L, 1L),
    Phase = c(rep("Discovery", 3), rep("Validation evidence", 3))
  )
  p2 <- ggplot(scope, aes(N, Step, color = Phase)) +
    geom_segment(aes(x = 0, xend = N, yend = Step), linewidth = .7) +
    geom_point(size = 2.2) +
    geom_text(aes(label = N), hjust = -.25, size = 2.3, color = "#333333") +
    scale_x_continuous(expand = expansion(mult = c(0, .12))) +
    scale_color_manual(values = c(Discovery = "#3274A1", "Validation evidence" = "#2E7D65")) +
    labs(x = "Proteins", y = NULL, color = NULL) +
    theme(legend.position = "top")

  source_counts <- counts
  source_counts$panel <- "a_cohort_counts"
  source_counts$analysis_universe <- "Frozen participant split (n=515)"
  source_counts$contrast <- "Discovery and Validation composition"
  source_counts$effect_estimate <- source_counts$N
  source_counts$Model_status <- "Not applicable: descriptive count"
  source_counts$selection_display_rule <- paste(
    "All 515 participants in the frozen split; counts shown for every",
    "Split x Environment x exposure stratum."
  )

  source_scope <- data.frame(
    panel = "b_analysis_scope",
    analysis_universe = "Prospective Discovery-Validation workflow",
    contrast = "Analysis scope",
    effect_estimate = scope$N,
    Model_status = "Finalized workflow count",
    selection_display_rule = paste(
      "All prespecified workflow counts displayed; no protein display selection."
    ),
    Step = as.character(scope$Step),
    N = scope$N,
    Phase = scope$Phase,
    stringsAsFactors = FALSE
  )
  set_figure_source(bind_rows_fill(source_counts, source_scope))

  (p1 | p2) + plot_annotation(tag_levels = "a")
}

fig2 <- function() {
  x <- nonempty(
    read_result(
      "D02_discovery_primary",
      "D02_Long_vs_Short_all_tested.csv",
      c("log2FC", "BH_FDR", "PG.ProteinGroups")
    ),
    "D02"
  )
  x$plot_FDR <- pmax(x$BH_FDR, .Machine$double.xmin)
  locked <- nonempty(
    read_result(
      "D03_candidate_lock",
      "D03_locked_candidates.csv",
      c("PG.ProteinGroups")
    ),
    "D03 locked candidate family"
  )
  assert_exact_candidate_universe(locked, "FIG2 D03")
  x$Signal <- ifelse(
    x$PG.ProteinGroups %in% locked$PG.ProteinGroups,
    "Discovery candidate",
    "All tested proteins"
  )
  x$Signal <- factor(x$Signal, c("All tested proteins", "Discovery candidate"))
  if (sum(x$Signal == "Discovery candidate") != 85L) {
    stop("FIG2 audit contract changed: expected 85 Discovery candidates")
  }

  x$panel <- "discovery_primary"
  x$analysis_universe <- "Discovery-only eligible protein universe (n=1,445)"
  x$source_contrast_key <- x$Contrast
  x$Contrast <- NULL
  x$contrast <- "High exposure vs Low exposure"
  x$effect_estimate <- x$log2FC
  x$selection_display_rule <- paste(
    "All 1,445 finalized D02 tests displayed; candidate highlighting uses only",
    "frozen D03 membership (n=85), not a plotting-time threshold."
  )
  set_figure_source(x)

  ggplot(x, aes(log2FC, -log10(plot_FDR))) +
    geom_hline(yintercept = -log10(.05), color = "#999999", linetype = 2) +
    geom_vline(xintercept = 0, color = "#999999", linetype = 2) +
    geom_point(aes(color = Signal), size = .85, alpha = .75) +
    scale_color_manual(values = evidence_pal) +
    labs(
      x = "Discovery High exposure vs Low exposure log2 fold change",
      y = "\u2212log10 BH FDR",
      color = NULL
    ) +
    theme(legend.position = "top")
}

fig3 <- function() {
  x <- nonempty(
    read_result(
      "D04_dose_trajectory",
      "D04_modeled_abundance_by_dose.csv",
      c("PG.ProteinGroups", "Dose", "Modeled_mean", "N_observed")
    ),
    "D04"
  )
  cls <- nonempty(
    read_result(
      "D04_dose_trajectory",
      "D04_trajectory_classification.csv",
      c("PG.ProteinGroups", "Trajectory")
    ),
    "D04 trajectory classification"
  )
  x <- merge(x, cls, by = "PG.ProteinGroups", all.x = TRUE, sort = FALSE)
  if (anyNA(x$Trajectory)) stop("FIG3 missing trajectory classification")
  x$Dose_code <- x$Dose
  x$Dose <- factor(
    x$Dose,
    c("control", "low", "high"),
    c("Control", "Low exposure", "High exposure")
  )
  control_mean <- x$Modeled_mean[x$Dose == "Control"]
  names(control_mean) <- x$PG.ProteinGroups[x$Dose == "Control"]
  x$Change_from_control <- x$Modeled_mean - control_mean[x$PG.ProteinGroups]
  x$Trajectory <- factor(
    x$Trajectory,
    c("Reversal_after_short_increase", "Transient_short_peak", "Delayed_decrease"),
    c("Reversal after low-exposure increase (n=75)", "Transient low-exposure peak (n=6)", "Delayed decrease (n=4)")
  )

  stats <- nonempty(
    read_result(
      "D04_dose_trajectory",
      "D04_candidate_contrasts.csv",
      c(
        "PG.ProteinGroups", "Contrast", "CI_low", "CI_high",
        "P_value", "BH_FDR", "Model_status"
      )
    ),
    "D04 candidate contrasts"
  )
  stats_key <- paste(stats$PG.ProteinGroups, stats$Contrast, sep = "|")
  x$Contrast_key <- ifelse(
    x$Dose_code == "low",
    "Short_vs_Control",
    ifelse(x$Dose_code == "high", "Long_vs_Control", NA_character_)
  )
  idx <- match(paste(x$PG.ProteinGroups, x$Contrast_key, sep = "|"), stats_key)
  x$panel <- "dose_trajectories"
  x$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  x$contrast <- ifelse(
    x$Dose_code == "control",
    "Control reference",
    ifelse(x$Dose_code == "low", "Low exposure vs Control", "High exposure vs Control")
  )
  x$effect_estimate <- x$Change_from_control
  x$CI_low <- stats$CI_low[idx]
  x$CI_high <- stats$CI_high[idx]
  x$P_value <- stats$P_value[idx]
  x$BH_FDR <- stats$BH_FDR[idx]
  x$Model_status <- ifelse(
    x$Dose_code == "control",
    "Reference level",
    stats$Model_status[idx]
  )
  x$selection_display_rule <- paste(
    "All 85 frozen D03 candidates displayed in their finalized D04 trajectory class;",
    "no protein-level display selection."
  )
  set_figure_source(x)

  ggplot(x, aes(Dose, Change_from_control, group = PG.ProteinGroups)) +
    geom_hline(yintercept = 0, color = "#C8C8C8") +
    geom_line(alpha = .24, color = "#8F8F8F", linewidth = .35) +
    stat_summary(
      aes(group = 1),
      fun = median,
      geom = "line",
      linewidth = 1,
      color = "#B24C63"
    ) +
    stat_summary(
      aes(group = 1),
      fun = median,
      geom = "point",
      size = 1.5,
      color = "#B24C63"
    ) +
    facet_wrap(~Trajectory, scales = "free_y", nrow = 1) +
    labs(
      x = NULL,
      y = "Modeled abundance change from Control (log2)"
    )
}

fig4 <- function() {
  x <- nonempty(
    read_result(
      "D05_environment_specific",
      "D05_candidate_environment_results.csv",
      c("PG.ProteinGroups", "Environment", "Contrast", "log2FC", "CI_low", "CI_high")
    ),
    "D05"
  )
  x <- x[x$Contrast == "Long_vs_Short" & is.finite(x$log2FC), ]
  if (nrow(x) != 170L) stop("FIG4 D05 expected 85 candidates x 2 environments")
  humid <- x[x$Environment == "Humid-hot", c("PG.ProteinGroups", "log2FC", "Secondary_BH_FDR")]
  high <- x[x$Environment == "High-pressure/high-altitude", c("PG.ProteinGroups", "log2FC", "Secondary_BH_FDR")]
  names(humid)[2:3] <- c("Humid_log2FC", "Humid_FDR")
  names(high)[2:3] <- c("High_log2FC", "High_FDR")
  wide <- merge(humid, high, by = "PG.ProteinGroups", sort = FALSE)
  wide$Support <- ifelse(
    wide$Humid_FDR < .05 & wide$High_FDR < .05,
    "FDR < 0.05 in both",
    ifelse(
      wide$Humid_FDR < .05,
      "Humid-hot only",
      ifelse(wide$High_FDR < .05, "High-altitude only", "Neither")
    )
  )

  p1 <- ggplot(wide, aes(High_log2FC, Humid_log2FC, color = Support)) +
    geom_hline(yintercept = 0, color = "#BBBBBB") +
    geom_vline(xintercept = 0, color = "#BBBBBB") +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    geom_point(size = 1.25, alpha = .85) +
    scale_color_manual(values = c(
      "FDR < 0.05 in both" = "#2E7D65",
      "Humid-hot only" = "#B24C63",
      "High-altitude only" = "#3274A1",
      "Neither" = "#A6A6A6"
    )) +
    coord_equal() +
    labs(
      x = "High-altitude log2 fold change",
      y = "Humid-hot log2 fold change",
      color = NULL
    ) +
    guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
    theme(legend.position = "bottom")

  inter <- nonempty(
    read_result(
      "D06_environment_interaction",
      "D06_candidate_interaction_results.csv",
      c("Contrast", "log2FC", "Secondary_BH_FDR")
    ),
    "D06"
  )
  inter <- inter[inter$Contrast == "Interaction_Long_vs_Short", ]
  if (nrow(inter) != 85L || sum(inter$Secondary_BH_FDR < .05) != 0L) {
    stop("FIG4 D06 audit contract changed")
  }
  inter$plot_FDR <- pmax(inter$Secondary_BH_FDR, .Machine$double.xmin)
  p2 <- ggplot(inter, aes(log2FC, -log10(plot_FDR))) +
    geom_hline(yintercept = -log10(.05), color = "#999999", linetype = 2) +
    geom_vline(xintercept = 0, color = "#999999", linetype = 2) +
    geom_point(color = "#777777", alpha = .75, size = .9) +
    labs(
      x = "Exposure \u00d7 Environment interaction log2 effect",
      y = "\u2212log10 secondary BH FDR"
    )

  support_idx <- match(x$PG.ProteinGroups, wide$PG.ProteinGroups)
  source_d05 <- x
  source_d05$panel <- "a_environment_specific"
  source_d05$Environment_display <- ifelse(
    source_d05$Environment == "Humid-hot", "Humid-hot", "High-altitude"
  )
  source_d05$Support <- wide$Support[support_idx]
  source_d05$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_d05$source_contrast_key <- source_d05$Contrast
  source_d05$Contrast <- NULL
  source_d05$contrast <- paste0(
    "High exposure vs Low exposure in ", source_d05$Environment_display
  )
  source_d05$effect_estimate <- source_d05$log2FC
  source_d05$Primary_BH_FDR <- source_d05$BH_FDR
  source_d05$BH_FDR <- source_d05$Secondary_BH_FDR
  source_d05$selection_display_rule <- paste(
    "All 85 frozen candidates displayed in both finalized Environment strata;",
    "colors summarize finalized D05 secondary BH-FDR states."
  )

  source_d06 <- inter
  source_d06$panel <- "b_formal_interaction"
  source_d06$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_d06$source_contrast_key <- source_d06$Contrast
  source_d06$Contrast <- NULL
  source_d06$contrast <- "High exposure vs Low exposure x Environment interaction"
  source_d06$effect_estimate <- source_d06$log2FC
  source_d06$Primary_BH_FDR <- source_d06$BH_FDR
  source_d06$BH_FDR <- source_d06$Secondary_BH_FDR
  source_d06$selection_display_rule <- paste(
    "All 85 finalized D06 interaction tests displayed; no protein labels or",
    "protein-level display selection."
  )
  set_figure_source(bind_rows_fill(source_d05, source_d06))

  (p1 | p2) + plot_annotation(tag_levels = "a")
}

fig5 <- function() {
  x <- nonempty(
    read_result(
      "D08_validation",
      "D08_validation_results.csv",
      c(
        "PG.ProteinGroups",
        "Discovery_log2FC",
        "log2FC",
        "Direction_concordant",
        "Nominal_replication",
        "FDR_supported_replication"
      )
    ),
    "D08"
  )
  assert_exact_candidate_universe(x, "FIG5 D08")

  direction <- as_flag(x$Direction_concordant, "FIG5 Direction_concordant")
  nominal <- as_flag(x$Nominal_replication, "FIG5 Nominal_replication")
  fdr <- as_flag(x$FDR_supported_replication, "FIG5 FDR_supported_replication")

  if (any(nominal & !direction)) {
    stop("FIG5 hierarchy violation: nominal replication without direction concordance")
  }
  if (any(fdr & !nominal)) {
    stop("FIG5 hierarchy violation: FDR-supported replication without nominal replication")
  }

  x$Replication_evidence <- ifelse(
    fdr,
    "FDR-supported replication",
    ifelse(
      nominal,
      "Nominal replication only",
      ifelse(
        direction,
        "Direction concordant only",
        "Direction discordant"
      )
    )
  )

  x$Replication_evidence <- factor(
    x$Replication_evidence,
    levels = c(
      "Direction discordant",
      "Direction concordant only",
      "Nominal replication only",
      "FDR-supported replication"
    )
  )

  expected_counts <- c(
    "Direction discordant" = 2L,
    "Direction concordant only" = 54L,
    "Nominal replication only" = 28L,
    "FDR-supported replication" = 1L
  )
  observed_counts <- table(x$Replication_evidence)
  if (!identical(as.integer(observed_counts[names(expected_counts)]), unname(expected_counts))) {
    stop(
      "FIG5 D08 audit contract changed; expected mutually exclusive counts 2/54/28/1"
    )
  }

  p1 <- ggplot(x, aes(Discovery_log2FC, log2FC, color = Replication_evidence)) +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    geom_hline(yintercept = 0, color = "#BBBBBB") +
    geom_vline(xintercept = 0, color = "#BBBBBB") +
    geom_point(size = 1.2) +
    coord_equal() +
    scale_color_manual(values = evidence_pal) +
    labs(
      x = "Discovery log2 fold change",
      y = "Validation log2 fold change",
      color = NULL
    ) +
    guides(color = guide_legend(nrow = 2, byrow = TRUE)) +
    theme(legend.position = "bottom")

  summary <- data.frame(
    Evidence = factor(
      c("Direction concordant", "Nominal replication", "FDR-supported replication"),
      levels = rev(c("Direction concordant", "Nominal replication", "FDR-supported replication"))
    ),
    N = c(83L, 29L, 1L)
  )
  p2 <- ggplot(summary, aes(N, Evidence)) +
    geom_col(width = .58, fill = "#3274A1") +
    geom_text(aes(label = paste0(N, "/85")), hjust = -.2, size = 2.4) +
    scale_x_continuous(limits = c(0, 100), breaks = c(0, 20, 40, 60, 80)) +
    labs(x = "Locked candidates", y = NULL)

  source_scatter <- x
  source_scatter$panel <- "a_discovery_validation_effects"
  source_scatter$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_scatter$source_contrast_key <- source_scatter$Contrast
  source_scatter$Contrast <- NULL
  source_scatter$contrast <- "High exposure vs Low exposure"
  source_scatter$effect_estimate <- source_scatter$log2FC
  source_scatter$BH_FDR <- source_scatter$Candidate_family_BH_FDR
  source_scatter$selection_display_rule <- paste(
    "All 85 locked candidates displayed without protein labels; no display",
    "protein is selected using Validation P values, BH-FDR or effect direction."
  )
  source_summary <- data.frame(
    panel = "b_replication_summary",
    analysis_universe = "Frozen D03 locked candidate family (n=85)",
    contrast = "High exposure vs Low exposure",
    effect_estimate = summary$N,
    Model_status = "Finalized D08 evidence count",
    selection_display_rule = paste(
      "All three prespecified nested Validation evidence levels displayed."
    ),
    Evidence = as.character(summary$Evidence),
    N = summary$N,
    stringsAsFactors = FALSE
  )
  set_figure_source(bind_rows_fill(source_scatter, source_summary))

  p1 + p2 + plot_layout(widths = c(1.6, 1)) + plot_annotation(tag_levels = "a")
}

fig6 <- function() {
  required <- c(
    "PG.ProteinGroups",
    "Trajectory",
    "D06_Interaction_Long_vs_Short_Secondary_BH_FDR",
    "D07_All_direction_stable",
    "D08_Direction_concordant",
    "D08_Nominal_replication",
    "D08_FDR_supported_replication",
    "D09_All_Dose_GE_80pct",
    "D09_Peptide_support_status"
  )

  x <- nonempty(
    read_result(
      "D10_integrated_biology",
      "D10_integrated_candidate_evidence.csv",
      required
    ),
    "D10"
  )
  assert_exact_candidate_universe(x, "FIG6 D10")

  interaction_fdr <- suppressWarnings(
    as.numeric(x$D06_Interaction_Long_vs_Short_Secondary_BH_FDR)
  )
  if (anyNA(interaction_fdr)) {
    stop("FIG6 D06 interaction FDR contains missing/non-numeric values")
  }

  site_stable <- as_flag(x$D07_All_direction_stable, "FIG6 D07_All_direction_stable")
  direction <- as_flag(x$D08_Direction_concordant, "FIG6 D08_Direction_concordant")
  nominal <- as_flag(x$D08_Nominal_replication, "FIG6 D08_Nominal_replication")
  fdr <- as_flag(x$D08_FDR_supported_replication, "FIG6 D08_FDR_supported_replication")
  detection80 <- as_flag(x$D09_All_Dose_GE_80pct, "FIG6 D09_All_Dose_GE_80pct")

  if (any(nominal & !direction)) {
    stop("FIG6 hierarchy violation: nominal replication without direction concordance")
  }
  if (any(fdr & !nominal)) {
    stop("FIG6 hierarchy violation: FDR-supported replication without nominal replication")
  }

  # Audit contracts derived from finalized D06-D10 outputs.
  if (sum(interaction_fdr < .05) != 0L) {
    stop("FIG6 D06 audit contract changed: expected 0/85 FDR-supported Long-vs-Short interactions")
  }
  if (sum(site_stable) != 85L) {
    stop("FIG6 D07 audit contract changed: expected 85/85 all-direction-stable")
  }
  if (sum(direction) != 83L || sum(nominal) != 29L || sum(fdr) != 1L) {
    stop("FIG6 D08 audit contract changed: expected 83/85, 29/85, 1/85")
  }
  if (sum(detection80) != 81L) {
    stop("FIG6 D09 audit contract changed: expected 81/85 all-dose >=80% detection")
  }
  if (!all(x$D09_Peptide_support_status == "SOURCE_NOT_AVAILABLE")) {
    stop("FIG6 peptide-source status changed; review figure design before execution")
  }

  # Preserve the existing D10/D03 locked order. Do not rank by evidence.
  protein_levels <- rev(x$PG.ProteinGroups)

  trajectory_levels <- c(
    "Reversal_after_short_increase",
    "Transient_short_peak",
    "Delayed_decrease"
  )
  if (any(!x$Trajectory %in% trajectory_levels)) {
    stop("FIG6 unexpected D04 trajectory category")
  }

  evidence <- rbind(
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups,
      Evidence = "D04 trajectory",
      Status = x$Trajectory,
      stringsAsFactors = FALSE
    ),
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups,
      Evidence = "D06 formal interaction",
      Status = ifelse(interaction_fdr < .05, "FDR-supported", "Not FDR-supported"),
      stringsAsFactors = FALSE
    ),
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups,
      Evidence = "D07 site robustness",
      Status = ifelse(site_stable, "Direction stable", "Not direction stable"),
      stringsAsFactors = FALSE
    ),
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups,
      Evidence = "D08 validation",
      Status = ifelse(
        fdr,
        "FDR-supported replication",
        ifelse(
          nominal,
          "Nominal replication only",
          ifelse(direction, "Direction concordant only", "Direction discordant")
        )
      ),
      stringsAsFactors = FALSE
    ),
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups,
      Evidence = "D09 detection",
      Status = ifelse(detection80, "All-dose >=80%", "Below 80% in >=1 dose stratum"),
      stringsAsFactors = FALSE
    )
  )

  evidence$PG.ProteinGroups <- factor(
    evidence$PG.ProteinGroups,
    levels = protein_levels
  )
  evidence$Evidence <- factor(
    evidence$Evidence,
    levels = c(
      "D04 trajectory",
      "D06 formal interaction",
      "D07 site robustness",
      "D08 validation",
      "D09 detection"
    )
  )

  status_values <- c(
    "Reversal_after_short_increase" = "#3274A1",
    "Transient_short_peak" = "#B24C63",
    "Delayed_decrease" = "#777777",
    "FDR-supported" = "#2E7D65",
    "Not FDR-supported" = "#DDDDDD",
    "Direction stable" = "#2E7D65",
    "Not direction stable" = "#B24C63",
    "Direction discordant" = "#B24C63",
    "Direction concordant only" = "#777777",
    "Nominal replication only" = "#3274A1",
    "FDR-supported replication" = "#2E7D65",
    "All-dose >=80%" = "#2E7D65",
    "Below 80% in >=1 dose stratum" = "#C49A3D"
  )
  status_labels <- c(
    "Reversal_after_short_increase" = "Reversal after low-exposure increase",
    "Transient_short_peak" = "Transient low-exposure peak",
    "Delayed_decrease" = "Delayed decrease",
    "FDR-supported" = "FDR-supported",
    "Not FDR-supported" = "Not FDR-supported",
    "Direction stable" = "Direction stable",
    "Not direction stable" = "Not direction stable",
    "Direction discordant" = "Direction discordant",
    "Direction concordant only" = "Direction concordant only",
    "Nominal replication only" = "Nominal replication only",
    "FDR-supported replication" = "FDR-supported replication",
    "All-dose >=80%" = "All-exposure >=80%",
    "Below 80% in >=1 dose stratum" = "Below 80% in >=1 exposure stratum"
  )

  e_idx <- match(as.character(evidence$PG.ProteinGroups), x$PG.ProteinGroups)
  evidence$Gene_symbol <- if ("Gene_symbol.x" %in% names(x)) x$Gene_symbol.x[e_idx] else NA
  evidence$Display_label <- if ("Display_label.x" %in% names(x)) x$Display_label.x[e_idx] else NA
  evidence$panel <- "integrated_evidence_matrix"
  evidence$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  evidence$contrast <- c(
    "D04 trajectory" = "Control, Low exposure and High exposure trajectory",
    "D06 formal interaction" = "High exposure vs Low exposure x Environment interaction",
    "D07 site robustness" = "High exposure vs Low exposure leave-one-major-site-out robustness",
    "D08 validation" = "High exposure vs Low exposure",
    "D09 detection" = "Control, Low exposure and High exposure detection"
  )[as.character(evidence$Evidence)]
  evidence$effect_estimate <- NA_real_
  evidence$effect_estimate[evidence$Evidence == "D06 formal interaction"] <-
    x$D06_Interaction_Long_vs_Short_log2FC[e_idx[evidence$Evidence == "D06 formal interaction"]]
  evidence$effect_estimate[evidence$Evidence == "D07 site robustness"] <-
    x$D07_Max_abs_Delta_log2FC[e_idx[evidence$Evidence == "D07 site robustness"]]
  evidence$effect_estimate[evidence$Evidence == "D08 validation"] <-
    x$D08_log2FC[e_idx[evidence$Evidence == "D08 validation"]]
  evidence$effect_estimate[evidence$Evidence == "D09 detection"] <-
    x$D09_Min_Dose_detection_rate[e_idx[evidence$Evidence == "D09 detection"]]
  evidence$BH_FDR <- NA_real_
  evidence$BH_FDR[evidence$Evidence == "D06 formal interaction"] <-
    x$D06_Interaction_Long_vs_Short_Secondary_BH_FDR[e_idx[evidence$Evidence == "D06 formal interaction"]]
  evidence$BH_FDR[evidence$Evidence == "D08 validation"] <-
    x$D08_Candidate_family_BH_FDR[e_idx[evidence$Evidence == "D08 validation"]]
  evidence$Model_status <- paste("Finalized", as.character(evidence$Evidence), "state")
  evidence$selection_display_rule <- paste(
    "All 85 frozen candidates shown in original D10/D03 order across every",
    "prespecified evidence layer; no evidence score, ranking or display subset."
  )
  set_figure_source(evidence)

  ggplot(evidence, aes(Evidence, PG.ProteinGroups, fill = Status)) +
    geom_tile(color = "white", linewidth = .12) +
    scale_fill_manual(values = status_values, labels = status_labels, drop = FALSE) +
    labs(
      x = NULL,
      y = NULL,
      fill = "Evidence state"
    ) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid = element_blank()
    )
}

fig7 <- function() {
  x <- nonempty(
    read_result(
      "D07_site_robustness",
      "D07_leave_one_major_site_out.csv",
      c(
        "PG.ProteinGroups", "Site_removed", "log2FC", "Primary_log2FC",
        "Direction_stable", "Delta_log2FC"
      )
    ),
    "D07"
  )
  if (nrow(x) != 425L || length(unique(x$PG.ProteinGroups)) != 85L ||
      length(unique(x$Site_removed)) != 5L) {
    stop("FIG7 expected 85 candidates x 5 leave-one-site-out scenarios")
  }
  stable <- as_flag(x$Direction_stable, "FIG7 Direction_stable")
  if (!all(stable)) stop("FIG7 audit contract changed: expected 425/425 direction stable")

  x$PG.ProteinGroups <- factor(
    x$PG.ProteinGroups,
    levels = rev(unique(x$PG.ProteinGroups))
  )
  x$Site_removed <- factor(x$Site_removed, levels = sort(unique(x$Site_removed)))

  lim <- max(abs(x$Delta_log2FC), na.rm = TRUE)
  p1 <- ggplot(x, aes(Site_removed, PG.ProteinGroups, fill = Delta_log2FC)) +
    geom_tile(color = "white", linewidth = .1) +
    scale_fill_gradient2(
      low = "#3274A1",
      mid = "white",
      high = "#B24C63",
      midpoint = 0,
      limits = c(-lim, lim)
    ) +
    labs(x = "Major site removed", y = NULL, fill = expression(Delta*" log2FC")) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      axis.text.x = element_text(angle = 35, hjust = 1)
    )

  p2 <- ggplot(x, aes(Site_removed, Delta_log2FC, fill = Site_removed)) +
    geom_hline(yintercept = 0, color = "#999999", linetype = 2) +
    geom_boxplot(width = .58, outlier.shape = NA, linewidth = .35) +
    geom_jitter(width = .12, size = .35, alpha = .35, color = "#333333") +
    scale_fill_manual(values = rep(c("#87AFC7", "#C9A0AA", "#A7C7B8"), length.out = 5)) +
    labs(x = "Major site removed", y = "LOO minus primary log2 fold change") +
    theme(
      legend.position = "none",
      axis.text.x = element_text(angle = 35, hjust = 1)
    )

  source_x <- x
  source_x$panel <- "site_robustness"
  source_x$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_x$source_contrast_key <- source_x$Contrast
  source_x$Contrast <- NULL
  source_x$contrast <- "High exposure vs Low exposure"
  source_x$effect_estimate <- source_x$log2FC
  source_x$selection_display_rule <- paste(
    "All 85 frozen candidates displayed for all five finalized leave-one-major-site-out",
    "scenarios; rows preserve source order and no protein display subset is used."
  )
  set_figure_source(source_x)

  (p1 | p2) + plot_annotation(tag_levels = "a")
}

fig8 <- function() {
  x <- nonempty(
    read_result(
      "D09_missingness_detection_peptides",
      "D09_missingness_detection_by_stratum.csv",
      c(
        "PG.ProteinGroups", "Split", "Stratifier", "Level",
        "N_total", "N_detected", "Detection_rate", "Missing_rate"
      )
    ),
    "D09 detection by stratum"
  )
  x <- x[x$Stratifier == "Dose", ]
  if (nrow(x) != 510L) stop("FIG8 expected 85 candidates x 6 split-dose strata")
  x$Dose <- factor(
    x$Level,
    c("control", "low", "high"),
    c("Control", "Low exposure", "High exposure")
  )
  x$Stratum <- interaction(x$Split, x$Dose, sep = " / ", lex.order = TRUE)

  p1 <- ggplot(x, aes(Stratum, Detection_rate, fill = Split)) +
    geom_hline(yintercept = .8, color = "#999999", linetype = 2) +
    geom_boxplot(width = .56, outlier.shape = NA, linewidth = .35) +
    geom_jitter(width = .12, size = .35, alpha = .28, color = "#333333") +
    scale_fill_manual(values = c(Discovery = "#3274A1", Validation = "#C49A3D")) +
    scale_y_continuous(
      limits = c(.45, 1.01),
      breaks = seq(.5, 1, .1),
      labels = scales::percent_format(accuracy = 1)
    ) +
    labs(x = NULL, y = "Detection rate", fill = "Split") +
    theme(
      legend.position = "top",
      axis.text.x = element_text(angle = 35, hjust = 1)
    )

  grad <- nonempty(
    read_result(
      "D09_missingness_detection_peptides",
      "D09_detection_gradients.csv",
      c("PG.ProteinGroups", "Split", "Level", "Threshold", "Reaches_threshold")
    ),
    "D09 detection gradients"
  )
  grad$Reached <- as_flag(grad$Reaches_threshold, "FIG8 Reaches_threshold")
  gsum <- aggregate(
    Reached ~ Split + Level + Threshold,
    grad,
    sum
  )
  gsum$Dose <- factor(
    gsum$Level,
    c("control", "low", "high"),
    c("Control", "Low exposure", "High exposure")
  )
  gsum$Split <- factor(gsum$Split, c("Discovery", "Validation"))

  p2 <- ggplot(
    gsum,
    aes(Threshold, Reached, color = Dose, linetype = Split, group = interaction(Dose, Split))
  ) +
    geom_line(linewidth = .75) +
    geom_point(size = 1.2) +
    scale_color_manual(values = pal[c("Control", "Low exposure", "High exposure")]) +
    scale_x_continuous(labels = scales::percent_format(accuracy = 1)) +
    scale_y_continuous(limits = c(0, 87), breaks = c(0, 20, 40, 60, 80, 85)) +
    labs(
      x = "Detection threshold",
      y = "Candidates reaching threshold",
      color = "Exposure",
      linetype = "Split"
    ) +
    guides(
      color = guide_legend(nrow = 1, order = 1),
      linetype = guide_legend(nrow = 1, order = 2)
    ) +
    theme(
      legend.position = "bottom",
      legend.box = "vertical"
    )

  source_detection <- x
  source_detection$panel <- "a_detection_by_split_and_exposure"
  source_detection$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_detection$contrast <- paste(source_detection$Split, as.character(source_detection$Dose), "detection")
  source_detection$effect_estimate <- source_detection$Detection_rate
  source_detection$Model_status <- "Not applicable: finalized descriptive detection rate"
  source_detection$selection_display_rule <- paste(
    "All 85 frozen candidates displayed in all six Split x exposure strata;",
    "no protein-level display selection."
  )
  source_gradient <- gsum
  source_gradient$panel <- "b_detection_threshold_counts"
  source_gradient$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_gradient$contrast <- paste(source_gradient$Split, as.character(source_gradient$Dose), "detection")
  source_gradient$effect_estimate <- source_gradient$Reached
  source_gradient$Model_status <- "Not applicable: count of finalized threshold flags"
  source_gradient$selection_display_rule <- paste(
    "All prespecified thresholds and all Split x exposure strata displayed;",
    "counts use finalized D09 Reaches_threshold flags."
  )
  set_figure_source(bind_rows_fill(source_detection, source_gradient))

  (p1 | p2) + plot_annotation(tag_levels = "a")
}

read_frozen_csv <- function(...) {
  p <- file.path(root, ...)
  if (!file.exists(p)) stop("Missing frozen source: ", p)
  read.csv(p, check.names = FALSE)
}

representative_ids <- function() {
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  cls <- nonempty(
    read_result(
      "D04_dose_trajectory", "D04_trajectory_classification.csv",
      c("PG.ProteinGroups", "Trajectory")
    ),
    "D04 trajectory classification"
  )
  assert_exact_candidate_universe(locked, "Representative-candidate D03")
  cls <- cls[match(locked$PG.ProteinGroups, cls$PG.ProteinGroups), ]
  categories <- c(
    "Reversal_after_short_increase", "Transient_short_peak", "Delayed_decrease"
  )
  ids <- vapply(categories, function(z) cls$PG.ProteinGroups[match(z, cls$Trajectory)], character(1))
  if (anyNA(ids)) stop("Missing a finalized D04 trajectory category")
  ids
}

fig9 <- function() {
  hist <- read_frozen_csv(
    "descriptive", "limma_dose_analysis", "results", "01_PRIMARY",
    "PRIMARY_log2_dose_environment__High_vs_Low.csv"
  )
  disc <- nonempty(
    read_result(
      "D02_discovery_primary", "D02_Long_vs_Short_all_tested.csv",
      c("PG.ProteinGroups", "log2FC", "Model_status")
    ),
    "D02 Discovery primary"
  )
  master <- read_frozen_csv(
    "descriptive", "limma_dose_analysis", "results",
    "13A_canonical_256_DEP_master", "Stage13A_canonical_256_DEP_master.csv"
  )
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  assert_exact_candidate_universe(locked, "FIG9 D03")
  if (nrow(hist) != 1434L || nrow(disc) != 1445L || nrow(master) != 256L) {
    stop("FIG9 frozen workflow counts changed")
  }
  shared <- intersect(hist$PG.ProteinGroups, disc$PG.ProteinGroups)
  hist_only <- setdiff(hist$PG.ProteinGroups, disc$PG.ProteinGroups)
  disc_only <- setdiff(disc$PG.ProteinGroups, hist$PG.ProteinGroups)
  if (length(shared) != 1426L || length(hist_only) != 8L || length(disc_only) != 19L) {
    stop("FIG9 eligibility overlap changed; expected 1426/8/19")
  }

  flow <- data.frame(
    Branch = rep(c("Historical full-cohort", "Frozen Discovery"), each = 3),
    Step = rep(c("Raw protein groups", "Eligible proteins", "Final evidence set"), 2),
    N = c(3817L, 1434L, 256L, 3817L, 1445L, 85L),
    stringsAsFactors = FALSE
  )
  flow$Step <- factor(
    flow$Step,
    c("Raw protein groups", "Eligible proteins", "Final evidence set")
  )
  p1 <- ggplot(flow, aes(Step, N, group = Branch, color = Branch)) +
    geom_line(linewidth = .8) +
    geom_point(size = 2) +
    geom_text(aes(label = N), vjust = -.6, size = 2.2, show.legend = FALSE) +
    scale_y_log10(breaks = c(85, 256, 1000, 3817), labels = scales::comma) +
    scale_color_manual(values = c(
      "Historical full-cohort" = "#777777", "Frozen Discovery" = "#3274A1"
    )) +
    labs(x = NULL, y = "Proteins (log scale)", color = NULL) +
    theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "top")

  overlap <- data.frame(
    Membership = factor(
      c("Shared", "Historical-only", "Discovery-only"),
      c("Shared", "Historical-only", "Discovery-only")
    ),
    N = c(1426L, 8L, 19L)
  )
  p2 <- ggplot(overlap, aes(Membership, N, fill = Membership)) +
    geom_col(width = .65) +
    geom_text(aes(label = N), vjust = -.3, size = 2.3) +
    scale_fill_manual(values = c(
      Shared = "#6F9F8C", `Historical-only` = "#999999", `Discovery-only` = "#3274A1"
    )) +
    scale_y_continuous(expand = expansion(mult = c(0, .12))) +
    labs(x = NULL, y = "Eligible proteins") +
    theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "none")

  common <- merge(
    hist[, c("PG.ProteinGroups", "Gene_symbol", "Display_label", "logFC")],
    disc[, c("PG.ProteinGroups", "Gene_symbol", "Display_label", "log2FC", "Model_status")],
    by = "PG.ProteinGroups", suffixes = c("_historical", "_discovery"), sort = FALSE
  )
  if (nrow(common) != 1426L) stop("FIG9 common-protein merge changed")
  lim <- max(abs(c(common$logFC, common$log2FC)), na.rm = TRUE)
  p3 <- ggplot(common, aes(logFC, log2FC)) +
    geom_hline(yintercept = 0, color = "#CCCCCC") +
    geom_vline(xintercept = 0, color = "#CCCCCC") +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    geom_point(size = .65, alpha = .55, color = "#3274A1") +
    coord_equal(xlim = c(-lim, lim), ylim = c(-lim, lim)) +
    labs(
      x = "Historical full-cohort log2 fold change",
      y = "Frozen Discovery log2 fold change"
    )

  source_flow <- flow
  source_flow$panel <- "a_parallel_workflow"
  source_flow$analysis_branch <- source_flow$Branch
  source_flow$analysis_universe <- ifelse(
    source_flow$Branch == "Historical full-cohort",
    "Historical full-cohort protein workflow", "Frozen Discovery protein workflow"
  )
  source_flow$contrast <- "Workflow count"
  source_flow$effect_estimate <- source_flow$N
  source_flow$Model_status <- "Finalized frozen count"
  source_flow$display_selection_rule <- "All prespecified frozen workflow stages displayed."
  source_overlap <- overlap
  source_overlap$panel <- "b_eligibility_overlap"
  source_overlap$analysis_branch <- "Historical full-cohort vs frozen Discovery"
  source_overlap$analysis_universe <- "Union of historical and Discovery eligible proteins (n=1,453)"
  source_overlap$contrast <- "Eligibility membership"
  source_overlap$effect_estimate <- source_overlap$N
  source_overlap$Model_status <- "Exact identifier-set reconciliation"
  source_overlap$display_selection_rule <- "All three exact eligibility-membership classes displayed."
  source_common <- common
  source_common$panel <- "c_common_protein_effect_agreement"
  source_common$analysis_branch <- "Historical full-cohort vs frozen Discovery"
  source_common$analysis_universe <- "Shared eligible proteins (n=1,426)"
  source_common$contrast <- "High exposure vs Low exposure"
  source_common$effect_estimate <- source_common$log2FC
  source_common$historical_effect_estimate <- source_common$logFC
  source_common$Gene_symbol <- source_common$Gene_symbol_discovery
  source_common$Display_label <- source_common$Display_label_discovery
  source_common$display_selection_rule <- paste(
    "All 1,426 shared eligible proteins displayed; no protein labels or",
    "Validation-driven selection."
  )
  set_figure_source(bind_rows_fill(source_flow, source_overlap, source_common))
  (p1 | p2 | p3) + plot_layout(widths = c(1, .8, 1.25)) +
    plot_annotation(tag_levels = "a")
}

fig10 <- function() {
  x <- nonempty(
    read_result(
      "D08_validation", "D08_validation_results.csv",
      c(
        "PG.ProteinGroups", "Discovery_log2FC", "log2FC", "CI_low", "CI_high",
        "P_value", "Candidate_family_BH_FDR", "Model_status",
        "Direction_concordant", "Nominal_replication", "FDR_supported_replication",
        "Effect_difference_signed", "Effect_difference_absolute"
      )
    ),
    "D08 validation"
  )
  assert_exact_candidate_universe(x, "FIG10 D08")
  locked <- nrow(x)
  estimable <- sum(x$Model_status == "ESTIMABLE")
  same <- sum(as_flag(x$Direction_concordant, "FIG10 direction"))
  nominal <- sum(as_flag(x$Nominal_replication, "FIG10 nominal"))
  fdr <- sum(as_flag(x$FDR_supported_replication, "FIG10 FDR"))
  if (!identical(c(locked, estimable, same, nominal, fdr), c(85L, 85L, 83L, 29L, 1L))) {
    stop("FIG10 replication hierarchy changed; expected 85/85/83/29/1")
  }
  hierarchy <- data.frame(
    Level = factor(
      c("Locked", "Estimable", "Same direction", "Nominal P < 0.05", "BH FDR < 0.05"),
      levels = rev(c("Locked", "Estimable", "Same direction", "Nominal P < 0.05", "BH FDR < 0.05"))
    ),
    N = c(locked, estimable, same, nominal, fdr)
  )
  p1 <- ggplot(hierarchy, aes(N, Level)) +
    geom_col(width = .6, fill = "#3274A1") +
    geom_text(aes(label = paste0(N, "/85")), hjust = -.15, size = 2.2) +
    scale_x_continuous(limits = c(0, 96), breaks = c(0, 20, 40, 60, 80)) +
    labs(x = "Frozen candidates", y = NULL)

  x$Candidate_index <- seq_len(nrow(x))
  pair <- rbind(
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups, Candidate_index = x$Candidate_index,
      Branch = "Frozen Discovery", Effect = x$Discovery_log2FC
    ),
    data.frame(
      PG.ProteinGroups = x$PG.ProteinGroups, Candidate_index = x$Candidate_index,
      Branch = "Reused 129 hold-out", Effect = x$log2FC
    )
  )
  p2 <- ggplot() +
    geom_segment(
      data = x,
      aes(x = Discovery_log2FC, xend = log2FC, y = Candidate_index, yend = Candidate_index),
      color = "#C7C7C7", linewidth = .35
    ) +
    geom_point(data = pair, aes(Effect, Candidate_index, color = Branch), size = .8) +
    geom_vline(xintercept = 0, color = "#999999", linetype = 2) +
    scale_color_manual(values = c("Frozen Discovery" = "#3274A1", "Reused 129 hold-out" = "#C49A3D")) +
    labs(x = "High exposure vs Low exposure log2 fold change", y = "D03 frozen order", color = NULL) +
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(), legend.position = "top")

  p3 <- ggplot(x, aes(Effect_difference_signed)) +
    geom_vline(xintercept = 0, color = "#999999", linetype = 2) +
    geom_histogram(binwidth = .05, boundary = 0, fill = "#87AFC7", color = "white", linewidth = .2) +
    labs(
      x = "Validation minus Discovery log2 fold change",
      y = "Candidates"
    )

  source_h <- hierarchy
  source_h$panel <- "a_replication_hierarchy"
  source_h$analysis_branch <- "Frozen Discovery to reused 129 hold-out"
  source_h$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_h$contrast <- "High exposure vs Low exposure"
  source_h$effect_estimate <- source_h$N
  source_h$Model_status <- "Finalized D08 nested evidence count"
  source_h$display_selection_rule <- "All five prespecified nested evidence levels displayed."
  source_x <- x
  source_x$panel <- "b_paired_effects_and_c_effect_difference"
  source_x$analysis_branch <- "Frozen Discovery and reused 129 hold-out"
  source_x$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_x$contrast <- "High exposure vs Low exposure"
  source_x$source_contrast_key <- source_x$Contrast
  source_x$Contrast <- NULL
  source_x$effect_estimate <- source_x$log2FC
  source_x$BH_FDR <- source_x$Candidate_family_BH_FDR
  source_x$display_selection_rule <- paste(
    "All 85 candidates displayed in frozen D03 order; no protein labels and no",
    "Validation P-value, FDR, direction or effect-based display selection."
  )
  set_figure_source(bind_rows_fill(source_h, source_x))
  (p1 | p2 | p3) + plot_layout(widths = c(.9, 1.35, 1)) +
    plot_annotation(tag_levels = "a")
}

fig11 <- function() {
  x <- nonempty(
    read_result(
      "D04_dose_trajectory", "D04_modeled_abundance_by_dose.csv",
      c("PG.ProteinGroups", "Dose", "Modeled_mean", "N_observed")
    ),
    "D04 modeled abundance"
  )
  cls <- nonempty(
    read_result(
      "D04_dose_trajectory", "D04_trajectory_classification.csv",
      c("PG.ProteinGroups", "Trajectory")
    ),
    "D04 trajectory classes"
  )
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  assert_exact_candidate_universe(locked, "FIG11 D03")
  x <- merge(x, cls, by = "PG.ProteinGroups", sort = FALSE)
  control <- x$Modeled_mean[x$Dose == "control"]
  names(control) <- x$PG.ProteinGroups[x$Dose == "control"]
  x$Change_from_control <- x$Modeled_mean - control[x$PG.ProteinGroups]
  x$Dose <- factor(x$Dose, c("control", "low", "high"), c("Control", "Low exposure", "High exposure"))
  class_labels <- c(
    Reversal_after_short_increase = "Reversal after low-exposure increase",
    Transient_short_peak = "Transient low-exposure peak",
    Delayed_decrease = "Delayed decrease"
  )
  x$Trajectory_label <- unname(class_labels[x$Trajectory])
  reps <- representative_ids()
  rep_x <- x[x$PG.ProteinGroups %in% reps, ]
  rep_x <- add_identity(rep_x)
  rep_x$Panel_label <- paste0(rep_x$Display_label, " | ", rep_x$Trajectory_label)
  p1 <- ggplot(rep_x, aes(Dose, Change_from_control, group = PG.ProteinGroups)) +
    geom_hline(yintercept = 0, color = "#CCCCCC") +
    geom_line(color = "#3274A1", linewidth = .7) +
    geom_point(aes(color = Dose), size = 1.6) +
    scale_color_manual(values = pal[c("Control", "Low exposure", "High exposure")]) +
    facet_wrap(~Panel_label, nrow = 1) +
    labs(x = NULL, y = "Modeled change from Control (log2)", color = NULL) +
    theme(legend.position = "top", axis.text.x = element_text(angle = 25, hjust = 1))

  x$Protein_order <- factor(
    x$PG.ProteinGroups,
    levels = rev(locked$PG.ProteinGroups)
  )
  lim <- max(abs(x$Change_from_control), na.rm = TRUE)
  p2 <- ggplot(x, aes(Dose, Protein_order, fill = Change_from_control)) +
    geom_tile(color = "white", linewidth = .08) +
    scale_fill_gradient2(
      low = "#3274A1", mid = "white", high = "#B24C63", midpoint = 0,
      limits = c(-lim, lim)
    ) +
    labs(x = NULL, y = NULL, fill = "Change\nfrom Control") +
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

  counts <- as.data.frame(table(cls$Trajectory), stringsAsFactors = FALSE)
  names(counts) <- c("Trajectory", "N")
  counts$Trajectory_label <- unname(class_labels[counts$Trajectory])
  p3 <- ggplot(counts, aes(N, reorder(Trajectory_label, N), fill = Trajectory_label)) +
    geom_col(width = .6) +
    geom_text(aes(label = N), hjust = -.2, size = 2.2) +
    scale_x_continuous(limits = c(0, 83)) +
    scale_fill_manual(values = c("#3274A1", "#B24C63", "#777777")) +
    labs(x = "Candidates", y = NULL) +
    theme(legend.position = "none")

  source_rep <- rep_x
  source_rep$panel <- "a_representative_trajectories"
  source_rep$analysis_branch <- "Frozen Discovery D04"
  source_rep$analysis_universe <- "One D03-order representative per finalized D04 trajectory class"
  source_rep$contrast <- paste(as.character(source_rep$Dose), "vs Control")
  source_rep$effect_estimate <- source_rep$Change_from_control
  source_rep$Model_status <- "Finalized D04 modeled mean"
  source_rep$display_selection_rule <- paste(
    "First protein in frozen D03 order within each finalized trajectory class;",
    "no Validation information or effect-size ranking used."
  )
  source_all <- add_identity(x)
  source_all$panel <- "b_all85_trajectory_heatmap"
  source_all$analysis_branch <- "Frozen Discovery D04"
  source_all$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_all$contrast <- paste(as.character(source_all$Dose), "vs Control")
  source_all$effect_estimate <- source_all$Change_from_control
  source_all$Model_status <- "Finalized D04 modeled mean"
  source_all$display_selection_rule <- "All 85 candidates displayed in frozen D03 order."
  source_counts <- counts
  source_counts$panel <- "c_trajectory_category_counts"
  source_counts$analysis_branch <- "Frozen Discovery D04"
  source_counts$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_counts$contrast <- "Finalized trajectory category"
  source_counts$effect_estimate <- source_counts$N
  source_counts$Model_status <- "Finalized D04 category"
  source_counts$display_selection_rule <- "All finalized D04 trajectory categories displayed."
  set_figure_source(bind_rows_fill(source_rep, source_all, source_counts))
  (p1 / (p2 | p3)) + plot_layout(heights = c(.85, 1.15), widths = c(1.25, .8)) +
    plot_annotation(tag_levels = "a")
}

fig12 <- function() {
  x <- nonempty(
    read_result(
      "D05_environment_specific", "D05_candidate_environment_results.csv",
      c(
        "PG.ProteinGroups", "Environment", "Contrast", "log2FC", "CI_low", "CI_high",
        "P_value", "BH_FDR", "Secondary_BH_FDR", "Model_status"
      )
    ),
    "D05 environment-specific results"
  )
  x <- x[x$Contrast == "Long_vs_Short", ]
  if (nrow(x) != 170L) stop("FIG12 expected 85 candidates x 2 environments")
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  x$Candidate_index <- match(x$PG.ProteinGroups, locked$PG.ProteinGroups)
  x$Environment_display <- ifelse(x$Environment == "Humid-hot", "Humid-hot", "High-altitude")
  p <- ggplot(x, aes(log2FC, Candidate_index, color = Environment_display)) +
    geom_vline(xintercept = 0, color = "#999999", linetype = 2) +
    geom_segment(aes(x = CI_low, xend = CI_high, yend = Candidate_index), linewidth = .35) +
    geom_point(size = .75) +
    facet_wrap(~Environment_display, nrow = 1) +
    scale_color_manual(values = pal[c("Humid-hot", "High-altitude")]) +
    labs(
      x = "High exposure vs Low exposure log2 fold change (95% CI)",
      y = "D03 frozen order", color = NULL
    ) +
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank(), legend.position = "none")
  x <- add_identity(x)
  x$panel <- "environment_stratified_effect_forest"
  x$analysis_branch <- "Frozen Discovery D05"
  x$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  x$contrast <- paste("High exposure vs Low exposure in", x$Environment_display)
  x$source_contrast_key <- x$Contrast
  x$Contrast <- NULL
  x$effect_estimate <- x$log2FC
  x$BH_FDR <- x$Secondary_BH_FDR
  x$display_selection_rule <- paste(
    "All 85 candidates displayed in both environments in frozen D03 order;",
    "no subgroup-significance-based selection."
  )
  set_figure_source(x)
  p
}

fig13 <- function() {
  composition <- nonempty(
    read_result(
      "D07_site_robustness", "D07_site_dose_composition.csv",
      c("Site", "Dose", "Freq")
    ),
    "D07 site-dose composition"
  )
  composition$Dose_display <- factor(
    composition$Dose, c("control", "low", "high"),
    c("Control", "Low exposure", "High exposure")
  )
  p1 <- ggplot(composition, aes(Dose_display, Site, fill = Freq)) +
    geom_tile(color = "white", linewidth = .3) +
    geom_text(aes(label = Freq), size = 2.1) +
    scale_fill_gradient(low = "#F2F2F2", high = "#3274A1") +
    labs(x = NULL, y = "Site", fill = "Participants") +
    theme(axis.text.x = element_text(angle = 25, hjust = 1))

  summaries <- nonempty(
    read_result(
      "D07_site_robustness", "D07_candidate_site_summaries.csv",
      c("PG.ProteinGroups", "Site", "Dose", "N_total", "N_observed", "Median_abundance")
    ),
    "D07 candidate site summaries"
  )
  reps <- representative_ids()
  rep_x <- summaries[summaries$PG.ProteinGroups %in% reps, ]
  rep_x <- add_identity(rep_x)
  rep_x$Dose_display <- factor(
    rep_x$Dose, c("control", "low", "high"),
    c("Control", "Low exposure", "High exposure")
  )
  p2 <- ggplot(rep_x, aes(Dose_display, Median_abundance, group = Site, color = Site)) +
    geom_line(linewidth = .45, alpha = .8, na.rm = TRUE) +
    geom_point(size = .8, na.rm = TRUE) +
    facet_wrap(~Display_label, nrow = 1, scales = "free_y") +
    labs(x = NULL, y = "Median log2 abundance", color = "Site") +
    guides(color = guide_legend(nrow = 3, byrow = TRUE)) +
    theme(axis.text.x = element_text(angle = 25, hjust = 1), legend.position = "bottom")

  loo <- nonempty(
    read_result(
      "D07_site_robustness", "D07_leave_one_major_site_out.csv",
      c(
        "PG.ProteinGroups", "Site_removed", "log2FC", "CI_low", "CI_high",
        "P_value", "BH_FDR", "Model_status", "Primary_log2FC", "Delta_log2FC"
      )
    ),
    "D07 leave-one-site-out"
  )
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  loo$Candidate_index <- match(loo$PG.ProteinGroups, locked$PG.ProteinGroups)
  p3 <- ggplot(loo, aes(log2FC, Candidate_index)) +
    geom_vline(xintercept = 0, color = "#999999", linetype = 2) +
    geom_segment(aes(x = CI_low, xend = CI_high, yend = Candidate_index), color = "#A6A6A6", linewidth = .25) +
    geom_point(color = "#3274A1", size = .45) +
    facet_wrap(~Site_removed, nrow = 1) +
    labs(x = "Leave-one-site-out log2 fold change (95% CI)", y = "D03 frozen order") +
    theme(axis.text.y = element_blank(), axis.ticks.y = element_blank())

  source_comp <- composition
  source_comp$panel <- "a_site_by_exposure_sample_counts"
  source_comp$analysis_branch <- "Frozen Discovery D07"
  source_comp$analysis_universe <- "Frozen Discovery participants (n=386)"
  source_comp$contrast <- paste(source_comp$Site, as.character(source_comp$Dose_display))
  source_comp$effect_estimate <- source_comp$Freq
  source_comp$Model_status <- "Not applicable: finalized participant count"
  source_comp$display_selection_rule <- "All site by exposure cells in the finalized D07 table displayed."
  source_rep <- rep_x
  source_rep$panel <- "b_representative_candidate_site_summaries"
  source_rep$analysis_branch <- "Frozen Discovery D07"
  source_rep$analysis_universe <- "Three D03-order trajectory representatives across all sites and exposures"
  source_rep$contrast <- paste(source_rep$Site, as.character(source_rep$Dose_display))
  source_rep$effect_estimate <- source_rep$Median_abundance
  source_rep$Model_status <- "Finalized descriptive site median"
  source_rep$display_selection_rule <- paste(
    "Same first-in-D03-order representative per D04 trajectory class as FIG11;",
    "no Validation information or site effect ranking used."
  )
  source_loo <- add_identity(loo)
  source_loo$panel <- "c_leave_one_site_out_effect_forest"
  source_loo$analysis_branch <- "Frozen Discovery D07"
  source_loo$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_loo$contrast <- paste("High exposure vs Low exposure; site removed:", source_loo$Site_removed)
  source_loo$source_contrast_key <- source_loo$Contrast
  source_loo$Contrast <- NULL
  source_loo$effect_estimate <- source_loo$log2FC
  source_loo$display_selection_rule <- paste(
    "All 85 candidates and all five finalized leave-one-major-site-out scenarios",
    "displayed in frozen D03 order."
  )
  set_figure_source(bind_rows_fill(source_comp, source_rep, source_loo))
  (p1 | p2) / p3 + plot_layout(heights = c(.85, 1.15), widths = c(.8, 1.6)) +
    plot_annotation(tag_levels = "a")
}

fig14 <- function() {
  x <- nonempty(
    read_result(
      "D09_missingness_detection_peptides", "D09_missingness_detection_by_stratum.csv",
      c(
        "PG.ProteinGroups", "Split", "Stratifier", "Level", "N_total",
        "N_detected", "Detection_rate", "Missing_rate"
      )
    ),
    "D09 missingness and detection"
  )
  x <- x[x$Stratifier == "Dose", ]
  if (nrow(x) != 510L) stop("FIG14 expected 85 candidates x 6 split-dose strata")
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  x$Protein_order <- factor(x$PG.ProteinGroups, levels = rev(locked$PG.ProteinGroups))
  x$Dose_display <- factor(
    x$Level, c("control", "low", "high"), c("Control", "Low exposure", "High exposure")
  )
  x$Stratum <- interaction(x$Split, x$Dose_display, sep = " / ", lex.order = TRUE)
  p1 <- ggplot(x, aes(Stratum, Protein_order, fill = Detection_rate)) +
    geom_tile(color = "white", linewidth = .08) +
    scale_fill_gradient(limits = c(0, 1), low = "#F3E4D0", high = "#2E7D65", labels = scales::percent) +
    labs(x = NULL, y = NULL, fill = "Detection") +
    theme(
      axis.text.y = element_blank(), axis.ticks.y = element_blank(),
      axis.text.x = element_text(angle = 30, hjust = 1)
    )

  pep <- nonempty(
    read_result(
      "D09_missingness_detection_peptides", "D09_unique_peptide_support.csv",
      c("PG.ProteinGroups", "Unique_peptide_count", "Single_unique_peptide", "Peptide_support_status")
    ),
    "D09 peptide support"
  )
  assert_exact_candidate_universe(pep, "FIG14 peptide status")
  if (!all(pep$Peptide_support_status == "SOURCE_NOT_AVAILABLE")) {
    stop("FIG14 peptide source status changed; review before plotting")
  }
  pep_summary <- data.frame(
    Status = "SOURCE_NOT_AVAILABLE",
    N = nrow(pep),
    Detail = "Unique-peptide source was not available; no peptide evidence inferred."
  )
  p2 <- ggplot(pep_summary, aes(1, 1)) +
    geom_tile(fill = "#E6E6E6", color = "#777777", linewidth = .4) +
    annotate("text", x = 1, y = 1.08, label = "SOURCE_NOT_AVAILABLE", size = 3, fontface = "bold") +
    annotate("text", x = 1, y = .94, label = "85/85 candidates", size = 2.5) +
    annotate("text", x = 1, y = .82, label = "No peptide evidence inferred", size = 2.2) +
    coord_cartesian(xlim = c(.55, 1.45), ylim = c(.65, 1.25), expand = FALSE) +
    theme_void()

  source_det <- add_identity(x)
  source_det$panel <- "a_detection_missingness_heatmap"
  source_det$analysis_branch <- "Frozen Discovery and reused 129 hold-out D09"
  source_det$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_det$contrast <- paste(source_det$Split, as.character(source_det$Dose_display), "detection")
  source_det$effect_estimate <- source_det$Detection_rate
  source_det$Model_status <- "Not applicable: finalized descriptive detection rate"
  source_det$display_selection_rule <- "All 85 candidates in all six split by exposure strata displayed."
  source_pep <- add_identity(pep)
  source_pep$panel <- "b_peptide_support_status"
  source_pep$analysis_branch <- "Frozen D09 peptide-support audit"
  source_pep$analysis_universe <- "Frozen D03 locked candidate family (n=85)"
  source_pep$contrast <- "Unique-peptide support availability"
  source_pep$effect_estimate <- source_pep$Unique_peptide_count
  source_pep$Model_status <- source_pep$Peptide_support_status
  source_pep$display_selection_rule <- paste(
    "All 85 candidates retained; source unavailability displayed explicitly and",
    "no peptide evidence fabricated."
  )
  set_figure_source(bind_rows_fill(source_det, source_pep))
  (p1 | p2) + plot_layout(widths = c(1.7, .8)) + plot_annotation(tag_levels = "a")
}

fig15 <- function() {
  x <- nonempty(
    read_result(
      "D02_discovery_primary", "D02_Long_vs_Short_all_tested.csv",
      c(
        "PG.ProteinGroups", "log2FC", "AveExpr", "P_value", "BH_FDR",
        "CI_low", "CI_high", "Model_status"
      )
    ),
    "D02 Discovery primary"
  )
  if (nrow(x) != 1445L) stop("FIG15 expected 1,445 D02 proteins")
  locked <- nonempty(
    read_result("D03_candidate_lock", "D03_locked_candidates.csv", c("PG.ProteinGroups")),
    "D03 locked candidates"
  )
  x$Signal <- ifelse(x$PG.ProteinGroups %in% locked$PG.ProteinGroups, "Discovery candidate", "All tested proteins")
  x$Signal <- factor(x$Signal, c("All tested proteins", "Discovery candidate"))
  p1 <- ggplot(x, aes(AveExpr, log2FC, color = Signal)) +
    geom_hline(yintercept = 0, color = "#999999", linetype = 2) +
    geom_point(size = .65, alpha = .65) +
    scale_color_manual(values = evidence_pal) +
    labs(x = "Average log2 abundance", y = "High exposure vs Low exposure log2 fold change", color = NULL) +
    theme(legend.position = "top")

  x$Effect_rank <- rank(x$log2FC, ties.method = "first", na.last = "keep")
  p2 <- ggplot(x, aes(Effect_rank, log2FC, color = Signal)) +
    geom_hline(yintercept = 0, color = "#999999", linetype = 2) +
    geom_point(size = .65, alpha = .7) +
    scale_color_manual(values = evidence_pal) +
    labs(x = "Effect rank across all tested proteins", y = "High exposure vs Low exposure log2 fold change", color = NULL) +
    theme(legend.position = "top")

  x <- add_identity(x)
  x$panel <- "a_ma_and_b_effect_rank"
  x$analysis_branch <- "Frozen Discovery D02"
  x$analysis_universe <- "Discovery-only eligible protein universe (n=1,445)"
  x$contrast <- "High exposure vs Low exposure"
  x$source_contrast_key <- x$Contrast
  x$Contrast <- NULL
  x$effect_estimate <- x$log2FC
  x$display_selection_rule <- paste(
    "All 1,445 finalized D02 tests displayed; candidate highlighting uses only",
    "frozen D03 membership. Effect rank orders all proteins and selects none."
  )
  set_figure_source(x)
  (p1 | p2) + plot_annotation(tag_levels = "a")
}

fun <- switch(
  toupper(args[1]),
  FIG1 = fig1,
  FIG2 = fig2,
  FIG3 = fig3,
  FIG4 = fig4,
  FIG5 = fig5,
  FIG6 = fig6,
  FIG7 = fig7,
  FIG8 = fig8,
  FIG9 = fig9,
  FIG10 = fig10,
  FIG11 = fig11,
  FIG12 = fig12,
  FIG13 = fig13,
  FIG14 = fig14,
  FIG15 = fig15,
  stop("Unknown figure ID")
)

p <- fun()
stem <- args[2]
dir.create(dirname(stem), recursive = TRUE, showWarnings = FALSE)

if (is.null(figure_source) || !nrow(figure_source)) {
  stop("Figure source data were not registered")
}
missing_source_cols <- setdiff(source_required, names(figure_source))
if (length(missing_source_cols)) {
  stop("Figure source export missing required columns: ", paste(missing_source_cols, collapse = ", "))
}

outputs <- c(
  paste0(stem, c(".svg", ".pdf", ".tiff")),
  paste0(stem, "_source_data.csv")
)
existing <- outputs[file.exists(outputs)]
if (length(existing)) {
  stop(
    "Refusing to overwrite existing figure output(s): ",
    paste(existing, collapse = ", ")
  )
}

width_mm = 183
height_mm = 120
width_in <- width_mm / 25.4
height_in <- height_mm / 25.4
# Cairo truncates fractional PostScript points on this Windows build. Round the
# PDF width upward to the nearest point so the realized page remains within the
# declared 183 mm placement tolerance; SVG/TIFF retain the exact dimensions.
pdf_width_in <- ceiling(width_in * 72) / 72

svglite::svglite(
  outputs[1],
  width = width_in,
  height = height_in
)
print(p)
dev.off()

grDevices::cairo_pdf(
  outputs[2],
  width = pdf_width_in,
  height = height_in,
  family = "Arial"
)
print(p)
dev.off()

ragg::agg_tiff(
  outputs[3],
  width = width_in,
  height = height_in,
  units = "in",
  res = 600,
  compression = "lzw"
)
print(p)
dev.off()

write.csv(
  figure_source,
  outputs[4],
  row.names = FALSE,
  na = ""
)
