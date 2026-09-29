# V2_ML_01_prepare.R — Data preparation for ML (no model training)
# Loads canonical data, splits Discovery/hold-out, prepares feature matrix.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")

#' Load frozen Discovery/Validation split assignment
load_split_assignment <- function(path="descriptive/discovery_validation_split/discovery_validation_assignment.csv") {
  meta <- read.csv(path, stringsAsFactors=FALSE)
  assert_split_assignment_complete(meta)
  assert_sample_ids_unique(meta$UniqueSampleID)
  # Parse environment from Stratum (format: "Humid-hot / Control")
  meta$Environment <- sub(" / .*$", "", meta$Stratum)
  meta$Group_v2 <- map_group(meta$TREAT1_clean)
  meta$Primary_target <- ifelse(meta$TREAT1_clean == "control", "Control", "Exposure")
  meta
}

map_group <- function(treat1) {
  out <- rep(NA, length(treat1))
  out[treat1 == "control"] <- "Control"
  out[treat1 == "low"] <- "Low"
  out[treat1 == "high"] <- "High"
  out
}

#' Get Discovery sample IDs
get_discovery_ids <- function(meta) {
  ids <- meta$UniqueSampleID[meta$Split == "Discovery"]
  assert_sample_ids_unique(ids)
  ids
}

#' Get hold-out sample IDs
get_holdout_ids <- function(meta) {
  ids <- meta$UniqueSampleID[meta$Split == "Validation"]
  assert_sample_ids_unique(ids)
  ids
}

#' Load abundance matrix for given sample IDs
#' Uses positional matching via clean_header per V2-02B
load_abundance_for_samples <- function(sample_ids,
                                       xlsx_path="rawdata/processed.xlsx") {
  # This function requires the same positional matching as V2-02B.
  # For ML, we load via sample_statistics.csv positional order.
  ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
  clean_header <- function(x) { x <- trimws(as.character(x)); sub("\\.0$","",x) }
  ss$clean <- clean_header(ss$Sheet1_raw_header)

  # Read xlsx
  library(readxl)
  raw <- read_excel(xlsx_path, n_max=3817, .name_repair="minimal")
  annot <- data.frame(
    PG.ProteinGroups = raw$PG.ProteinGroups,
    Gene_symbol = raw$PG.Genes,
    stringsAsFactors=FALSE
  )
  excel_cols <- names(raw)[8:ncol(raw)]
  excel_clean <- clean_header(excel_cols)
  # Positional verification
  stopifnot(length(excel_clean) == nrow(ss))
  stopifnot(all(excel_clean == ss$clean))

  abund <- as.data.frame(raw[, 8:ncol(raw)])
  rownames(abund) <- annot$PG.ProteinGroups

  # Find positions for requested samples
  pos <- match(sample_ids, ss$clean)
  if (any(is.na(pos))) stop("Samples not found in matrix: ",
    paste(sample_ids[is.na(pos)][1:5], collapse=", "))
  abund[, pos, drop=FALSE]
}

#' Prepare primary target vector (Control=0, Exposure=1)
prepare_primary_target <- function(meta, sample_ids) {
  g <- meta$Primary_target[match(sample_ids, meta$UniqueSampleID)]
  y <- as.integer(g == "Exposure")
  y
}
