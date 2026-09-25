# Deterministic downstream annotation of Stage 11a pattern results.
# Gene symbols originate in Stage 01; this stage performs no online remapping.
suppressPackageStartupMessages(library(dplyr))

script_arg <- grep("^--file=", commandArgs(trailingOnly = FALSE), value = TRUE)
if (length(script_arg) != 1L) stop("Run this script with Rscript so --file= is available.")
ROOT_DIR <- dirname(normalizePath(sub("^--file=", "", script_arg), winslash = "/", mustWork = TRUE))
source(file.path(ROOT_DIR, "v21_common.R"))

INPUT_FILE <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results",
    "10_dose_pattern_classification_v2", "DEP_three_group_pattern.csv"
)
RESULT_DIR <- file.path(
    ROOT_DIR, "limma_dose_analysis", "results", "11_pattern_protein_annotation"
)

if (!file.exists(INPUT_FILE)) {
    stop("Required Stage 11a output is missing: ", INPUT_FILE,
         "\nRun 11a_dose_pattern_classification.R first.")
}
annotation <- v21_annotation(ROOT_DIR)
dep <- read.csv(INPUT_FILE, check.names = FALSE, stringsAsFactors = FALSE)
id_column <- if ("PG.ProteinGroups" %in% names(dep)) "PG.ProteinGroups" else "Protein"
v21_columns(dep, id_column, basename(INPUT_FILE))
names(dep)[names(dep) == id_column] <- "PG.ProteinGroups"
v21_ids(dep$PG.ProteinGroups, "Stage 11a pattern protein IDs")

# Replace any propagated display columns from the one canonical Stage 01 source.
dep$Gene_symbol <- NULL
dep$Display_label <- NULL
dep <- v21_annotate(dep, annotation)
dep <- dep[, c("PG.ProteinGroups", "Gene_symbol", "Display_label",
               setdiff(names(dep), c("PG.ProteinGroups", "Gene_symbol", "Display_label"))), drop = FALSE]

RESULT_DIR <- v21_output(RESULT_DIR)
v21_write(dep, file.path(RESULT_DIR, "01_DEP_protein_annotation.csv"))
if ("Pattern" %in% names(dep)) {
    v21_write(dplyr::count(dep, Pattern, name = "N_proteins"),
              file.path(RESULT_DIR, "02_DEP_pattern_summary.csv"))
}
if ("adj.P.Val" %in% names(dep)) {
    top_fdr <- head(dep[order(dep$adj.P.Val, dep$PG.ProteinGroups), , drop = FALSE], 30L)
    v21_write(top_fdr, file.path(RESULT_DIR, "03_DEP_top30_FDR.csv"))
}
if ("logFC" %in% names(dep)) {
    top_effect <- head(dep[order(-abs(dep$logFC), dep$PG.ProteinGroups), , drop = FALSE], 30L)
    v21_write(top_effect, file.path(RESULT_DIR, "04_DEP_top30_effect_size.csv"))
}
mapping_qc <- data.frame(
    Metric = c("total_protein_groups", "gene_symbol_mapped", "gene_symbol_unmapped",
               "mapping_rate", "duplicated_gene_symbol_rows", "display_label_fallback"),
    Value = c(nrow(dep), sum(!is.na(dep$Gene_symbol) & nzchar(dep$Gene_symbol)),
              sum(is.na(dep$Gene_symbol) | !nzchar(dep$Gene_symbol)),
              mean(!is.na(dep$Gene_symbol) & nzchar(dep$Gene_symbol)),
              sum(duplicated(dep$Gene_symbol) & !is.na(dep$Gene_symbol) & nzchar(dep$Gene_symbol)),
              sum(dep$Display_label == dep$PG.ProteinGroups))
)
v21_write(mapping_qc, file.path(RESULT_DIR, "05_canonical_gene_mapping_QC.csv"))
writeLines(c(
    "Gene_symbol and Display_label are propagated from canonical_protein_annotation.csv.",
    "PG.ProteinGroups remains the analytical key.",
    "Display_label uses Gene_symbol when available and otherwise the stable protein-group identifier.",
    "No online annotation request is performed."
), file.path(RESULT_DIR, "README_METHODS.md"))
