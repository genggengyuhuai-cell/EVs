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

theme_set(
  theme_classic(base_size = 6.5, base_family = "Arial") +
    theme(
      axis.line = element_line(linewidth = .35),
      axis.ticks = element_line(linewidth = .35),
      legend.text = element_text(size = 5.8),
      strip.text = element_text(size = 6.2, face = "bold"),
      plot.title = element_text(size = 7, face = "bold")
    )
)

pal <- c(
  Control = "#777777",
  Short = "#3B82A0",
  Long = "#C45A3D",
  "Humid-hot" = "#B24C63",
  "High-pressure/high-altitude" = "#3274A1"
)

fig2 <- function() {
  x <- nonempty(
    read_result(
      "D02_discovery_primary",
      "D02_Long_vs_Short_all_tested.csv",
      c("log2FC", "BH_FDR")
    ),
    "D02"
  )
  x$plot_FDR <- pmax(x$BH_FDR, .Machine$double.xmin)

  ggplot(x, aes(log2FC, -log10(plot_FDR))) +
    geom_point(size = .7, alpha = .55, color = "#777777") +
    geom_vline(xintercept = 0, linetype = 2) +
    labs(
      x = "Discovery Long vs Short log2 fold change",
      y = "\u2212log10 BH FDR"
    )
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
  x$Dose <- factor(
    x$Dose,
    c("control", "low", "high"),
    c("Control", "Short", "Long")
  )

  ggplot(x, aes(Dose, Modeled_mean, group = PG.ProteinGroups)) +
    geom_line(alpha = .2, color = "#777777") +
    stat_summary(
      aes(group = 1),
      fun = median,
      geom = "line",
      linewidth = .9,
      color = "#B24C63"
    ) +
    labs(
      x = NULL,
      y = "Modeled log2 abundance",
      caption = "Per-protein observed n retained in source data"
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
  if (!nrow(x)) stop("NON_ESTIMABLE")

  ggplot(
    x,
    aes(log2FC, reorder(PG.ProteinGroups, log2FC), color = Environment)
  ) +
    geom_vline(xintercept = 0, linetype = 2) +
    geom_errorbarh(aes(xmin = CI_low, xmax = CI_high), height = 0) +
    geom_point(size = 1) +
    scale_color_manual(values = pal) +
    labs(
      x = "Long vs Short log2 fold change (95% CI)",
      y = NULL,
      caption = paste(
        "Environment-stratified estimates.",
        "Formal Dose \u00d7 Environment interaction was assessed separately in D06."
      )
    )
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

  ggplot(x, aes(Discovery_log2FC, log2FC, color = Replication_evidence)) +
    geom_abline(slope = 1, intercept = 0, linetype = 2) +
    geom_hline(yintercept = 0, color = "#BBBBBB") +
    geom_vline(xintercept = 0, color = "#BBBBBB") +
    geom_point(size = 1.2) +
    coord_equal() +
    scale_color_manual(
      values = c(
        "Direction discordant" = "#B24C63",
        "Direction concordant only" = "#777777",
        "Nominal replication only" = "#3274A1",
        "FDR-supported replication" = "#2E7D65"
      )
    ) +
    labs(
      x = "Discovery log2 fold change",
      y = "Validation log2 fold change",
      color = "Validation evidence",
      caption = paste(
        "Mutually exclusive evidence hierarchy:",
        "2 discordant; 54 direction-concordant only;",
        "28 nominal-only; 1 FDR-supported."
      )
    )
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

  ggplot(evidence, aes(Evidence, PG.ProteinGroups, fill = Status)) +
    geom_tile(color = "white", linewidth = .12) +
    scale_fill_manual(values = status_values, drop = FALSE) +
    labs(
      x = NULL,
      y = NULL,
      fill = "Evidence state",
      caption = paste(
        "Rows preserve locked candidate order; no evidence score or ranking.",
        "Unique-peptide support is unavailable for all 85 candidates."
      )
    ) +
    theme(
      axis.text.y = element_blank(),
      axis.ticks.y = element_blank(),
      panel.grid = element_blank()
    )
}

fun <- switch(
  toupper(args[1]),
  FIG2 = fig2,
  FIG3 = fig3,
  FIG4 = fig4,
  FIG5 = fig5,
  FIG6 = fig6,
  stop("Unknown figure ID")
)

p <- fun()
stem <- args[2]
dir.create(dirname(stem), recursive = TRUE, showWarnings = FALSE)

outputs <- paste0(stem, c(".svg", ".pdf", ".tiff"))
existing <- outputs[file.exists(outputs)]
if (length(existing)) {
  stop(
    "Refusing to overwrite existing figure output(s): ",
    paste(existing, collapse = ", ")
  )
}

width_mm <- 183
height_mm <- 120
width_in <- width_mm / 25.4
height_in <- height_mm / 25.4

svglite::svglite(
  outputs[1],
  width = width_in,
  height = height_in
)
print(p)
dev.off()

grDevices::cairo_pdf(
  outputs[2],
  width = width_in,
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
