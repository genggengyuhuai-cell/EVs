# ============================================================
# 11 PATTERN / DEP PROTEIN ANNOTATION
#
# Purpose:
#   Annotate the complete primary Long-vs-Short DEP set from
#   exposure-pattern v2.
#
# Scientific contract:
#   - Input proteins are the primary Long-vs-Short DEP
#     (BH FDR < 0.05) carried forward by
#     10_dose_pattern_classification.R.
#   - ALL input DEP are annotated.
#   - Pattern is retained only as descriptive metadata based on
#     unadjusted observed group means.
#   - Pattern is NOT treated as an independent inferential result.
#   - No protein is excluded because of Pattern.
#   - No missing abundance value is imputed.
#   - Primary inferential effect size remains the limma logFC.
#
# Expected current input:
#   DEP_three_group_pattern.csv
#
# Current expected primary set:
#   Long_vs_Short DEP = 256
#
# Output:
#   01_DEP_protein_annotation.csv
#   02_DEP_pattern_summary.csv
#   03_DEP_top30_FDR.csv
#   04_DEP_top30_effect_size.csv
#   05_UniProt_mapping_QC.csv
#   06_UniProt_unmapped_proteins.csv
#
# ============================================================


rm(list = ls())
gc()


# ============================================================
# Packages
# ============================================================

suppressPackageStartupMessages({

    library(dplyr)
    library(stringr)
    library(httr)

})


# ============================================================
# Paths
# ============================================================

ROOT_DIR <- normalizePath(
    getwd(),
    winslash = "/"
)


INPUT_FILE <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "10_dose_pattern_classification_v2",
    "DEP_three_group_pattern.csv"
)

RESULT_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "11_pattern_protein_annotation"
)


dir.create(
    RESULT_DIR,
    recursive = TRUE,
    showWarnings = FALSE
)


if (!file.exists(INPUT_FILE)) {

    stop(
        "Input file not found: ",
        INPUT_FILE
    )

}


# ============================================================
# Read pattern / DEP table
# ============================================================

dep <- read.csv(
    INPUT_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)


cat(
    "\nInput proteins:",
    nrow(dep),
    "\n"
)


# ============================================================
# Input contract checks
# ============================================================

required_cols <- c(
    "Protein",
    "Control",
    "N_observed_Control",
    "N_total_Control",
    "Short",
    "N_observed_Short",
    "N_total_Short",
    "Long",
    "N_observed_Long",
    "N_total_Long",
    "Short_minus_Control",
    "Long_minus_Short",
    "Long_minus_Control",
    "Pattern",
    "logFC",
    "adj.P.Val",
    "Pattern_version",
    "Tolerance_log2"
)


missing_cols <- setdiff(
    required_cols,
    colnames(dep)
)


if (length(missing_cols) > 0) {

    stop(
        "Missing required columns: ",
        paste(
            missing_cols,
            collapse = ", "
        )
    )

}


if (any(is.na(dep$Protein) | dep$Protein == "")) {

    stop(
        "Missing Protein IDs detected."
    )

}


if (anyDuplicated(dep$Protein)) {

    stop(
        "Duplicate Protein IDs detected."
    )

}


if (nrow(dep) == 0) {

    stop(
        "Input DEP table contains zero proteins."
    )

}


# Input from script 10 is expected to contain primary
# Long-vs-Short DEP only.

if (
    any(
        is.na(dep$adj.P.Val) |
        dep$adj.P.Val >= 0.05
    )
) {

    stop(
        paste0(
            "Input contains proteins that are not primary ",
            "Long-vs-Short DEP at BH FDR < 0.05."
        )
    )

}


cat(
    "Primary DEP with FDR < 0.05:",
    sum(dep$adj.P.Val < 0.05),
    "\n"
)


# ============================================================
# Pattern audit
#
# Pattern remains descriptive only.
# Do NOT filter the annotation universe by Pattern.
# ============================================================

pattern_counts <- dep %>%

    count(
        Pattern,
        name = "N"
    ) %>%

    arrange(
        desc(N),
        Pattern
    ) %>%

    mutate(
        Percent = 100 * N / sum(N)
    )


cat(
    "\nPattern counts:\n"
)

print(pattern_counts)


if (sum(pattern_counts$N) != nrow(dep)) {

    stop(
        "Pattern counts do not sum to the input DEP universe."
    )

}


# ============================================================
# Descriptive display labels
#
# These labels are intentionally conservative.
# Computational Pattern values from script 10 are preserved.
# ============================================================

dep <- dep %>%

    mutate(

        Pattern_display = case_when(

            Pattern == "Short_peak" ~
                "Short-high profile",

            Pattern == "Long_suppression" ~
                "Control/Short-similar, Long-low profile",

            Pattern == "Ordered_increase" ~
                "Ordered increase profile",

            Pattern == "Ordered_decrease" ~
                "Ordered decrease profile",

            Pattern == "Short_trough" ~
                "Short-low profile",

            Pattern == "Long_elevation" ~
                "Control/Short-similar, Long-high profile",

            Pattern == "Short_elevation_plateau" ~
                "Short elevation plateau profile",

            Pattern == "Short_suppression_plateau" ~
                "Short suppression plateau profile",

            Pattern == "Adjacent_changes_within_tolerance" ~
                "Adjacent changes within tolerance",

            TRUE ~ Pattern
        )
    )


# ============================================================
# UniProt annotation
#
# Use UniProt REST search in batches.
#
# Important:
#   - Protein accession remains the join key.
#   - Annotation failure does NOT remove proteins.
#   - Unmapped proteins are written explicitly.
# ============================================================

uniprot_annotation_batch <- function(ids) {

    ids <- unique(ids)

    ids <- ids[
        !is.na(ids) &
        ids != ""
    ]


    if (length(ids) == 0) {

        return(
            data.frame(
                Protein = character(),
                GeneSymbol = character(),
                ProteinName = character(),
                stringsAsFactors = FALSE
            )
        )

    }


    # Explicit OR query is safer than treating a comma-separated
    # accession list as one accession expression.

    query <- paste0(
        "accession:",
        ids,
        collapse = " OR "
    )


    r <- GET(
        "https://rest.uniprot.org/uniprotkb/search",
        query = list(
            query = query,
            format = "tsv",
            fields = "accession,gene_names,protein_name",
            size = length(ids)
        ),
        timeout(60)
    )


    if (status_code(r) != 200) {

        warning(
            paste0(
                "UniProt annotation batch failed. HTTP status: ",
                status_code(r)
            )
        )

        return(
            data.frame(
                Protein = character(),
                GeneSymbol = character(),
                ProteinName = character(),
                stringsAsFactors = FALSE
            )
        )

    }


    txt <- content(
        r,
        "text",
        encoding = "UTF-8"
    )


    if (
        is.na(txt) ||
        !nzchar(txt)
    ) {

        return(
            data.frame(
                Protein = character(),
                GeneSymbol = character(),
                ProteinName = character(),
                stringsAsFactors = FALSE
            )
        )

    }


    tab <- tryCatch(

        read.delim(
            textConnection(txt),
            stringsAsFactors = FALSE,
            check.names = FALSE
        ),

        error = function(e) {

            warning(
                paste0(
                    "Failed to parse UniProt response: ",
                    conditionMessage(e)
                )
            )

            NULL
        }
    )


    if (
        is.null(tab) ||
        nrow(tab) == 0
    ) {

        return(
            data.frame(
                Protein = character(),
                GeneSymbol = character(),
                ProteinName = character(),
                stringsAsFactors = FALSE
            )
        )

    }


    if (ncol(tab) < 3) {

        warning(
            "Unexpected UniProt response structure."
        )

        return(
            data.frame(
                Protein = character(),
                GeneSymbol = character(),
                ProteinName = character(),
                stringsAsFactors = FALSE
            )
        )

    }


    tab <- tab[, 1:3, drop = FALSE]


    colnames(tab) <- c(
        "Protein",
        "GeneSymbol",
        "ProteinName"
    )


    # UniProt gene_names may contain aliases.
    # Preserve the full returned field and also derive the
    # first token as a convenient primary display symbol.

    tab <- tab %>%

        mutate(

            GeneNames_UniProt = GeneSymbol,

            GeneSymbol = ifelse(
                is.na(GeneSymbol) |
                GeneSymbol == "",
                NA_character_,
                sub(
                    "\\s+.*$",
                    "",
                    GeneSymbol
                )
            )

        ) %>%

        select(
            Protein,
            GeneSymbol,
            GeneNames_UniProt,
            ProteinName
        )


    tab
}


# ============================================================
# Run UniProt annotation in manageable batches
# ============================================================

BATCH_SIZE <- 100L


protein_ids <- unique(
    dep$Protein
)


batch_id <- ceiling(
    seq_along(protein_ids) / BATCH_SIZE
)


protein_batches <- split(
    protein_ids,
    batch_id
)


cat(
    "\nUniProt annotation batches:",
    length(protein_batches),
    "\n"
)


anno_list <- vector(
    "list",
    length(protein_batches)
)


for (i in seq_along(protein_batches)) {

    cat(
        "Annotating UniProt batch",
        i,
        "of",
        length(protein_batches),
        " (n=",
        length(protein_batches[[i]]),
        ")...\n",
        sep = ""
    )


    anno_list[[i]] <- uniprot_annotation_batch(
        protein_batches[[i]]
    )


    # Small delay to avoid unnecessary pressure on the API.
    if (i < length(protein_batches)) {
        Sys.sleep(0.5)
    }

}


anno <- bind_rows(
    anno_list
)


# Remove accidental duplicated accessions returned by API.

if (nrow(anno) > 0) {

    anno <- anno %>%

        distinct(
            Protein,
            .keep_all = TRUE
        )

}


# ============================================================
# Join annotation to complete DEP universe
# ============================================================

dep_anno <- dep %>%

    left_join(
        anno,
        by = "Protein"
    )


if (nrow(dep_anno) != nrow(dep)) {

    stop(
        "Annotation join changed the number of DEP rows."
    )

}


if (!setequal(dep_anno$Protein, dep$Protein)) {

    stop(
        "Protein universe changed during annotation join."
    )

}


# ============================================================
# Mapping status
# ============================================================

dep_anno <- dep_anno %>%

    mutate(

        UniProt_mapped =
            !is.na(ProteinName) &
            ProteinName != ""

    )


n_input <- nrow(dep_anno)

n_mapped <- sum(
    dep_anno$UniProt_mapped
)

n_unmapped <- sum(
    !dep_anno$UniProt_mapped
)


mapping_rate <- if (
    n_input > 0
) {

    100 * n_mapped / n_input

} else {

    NA_real_

}


cat(
    "\nUniProt mapping:\n",
    "Input:    ", n_input, "\n",
    "Mapped:   ", n_mapped, "\n",
    "Unmapped: ", n_unmapped, "\n",
    "Rate:     ", round(mapping_rate, 2), "%\n",
    sep = ""
)


# ============================================================
# Main annotated DEP table
# ============================================================

main_output <- dep_anno %>%

    select(

        Protein,
        GeneSymbol,
        GeneNames_UniProt,
        ProteinName,
        UniProt_mapped,

        Control,
        N_observed_Control,
        N_total_Control,

        Short,
        N_observed_Short,
        N_total_Short,

        Long,
        N_observed_Long,
        N_total_Long,

        Short_minus_Control,
        Long_minus_Short,
        Long_minus_Control,

        Pattern,
        Pattern_display,

        logFC,
        adj.P.Val,

        Pattern_version,
        Tolerance_log2

    )


write.csv(
    main_output,
    file.path(
        RESULT_DIR,
        "01_DEP_protein_annotation.csv"
    ),
    row.names = FALSE
)


# ============================================================
# Pattern summary
#
# Descriptive only.
# ============================================================

pattern_summary <- dep_anno %>%

    group_by(
        Pattern,
        Pattern_display
    ) %>%

    summarise(

        N = n(),

        Percent =
            100 * n() / nrow(dep_anno),

        Mean_Control =
            mean(
                Control,
                na.rm = TRUE
            ),

        Mean_Short =
            mean(
                Short,
                na.rm = TRUE
            ),

        Mean_Long =
            mean(
                Long,
                na.rm = TRUE
            ),

        Mean_Short_minus_Control =
            mean(
                Short_minus_Control,
                na.rm = TRUE
            ),

        Mean_Long_minus_Short =
            mean(
                Long_minus_Short,
                na.rm = TRUE
            ),

        Mean_Long_minus_Control =
            mean(
                Long_minus_Control,
                na.rm = TRUE
            ),

        .groups = "drop"

    ) %>%

    arrange(
        desc(N),
        Pattern
    )


write.csv(
    pattern_summary,
    file.path(
        RESULT_DIR,
        "02_DEP_pattern_summary.csv"
    ),
    row.names = FALSE
)


# ============================================================
# Top 30:
# strongest statistical evidence
#
# Ranking variable:
#   primary Long-vs-Short BH-adjusted P value
# ============================================================

top_FDR <- dep_anno %>%

    arrange(
        adj.P.Val,
        desc(abs(logFC))
    ) %>%

    slice_head(
        n = 30
    )


write.csv(
    top_FDR,
    file.path(
        RESULT_DIR,
        "03_DEP_top30_FDR.csv"
    ),
    row.names = FALSE
)


# ============================================================
# Top 30:
# largest primary model effect size
#
# Ranking variable:
#   |Long-vs-Short limma logFC|
#
# This is intentionally NOT ranked by raw group-mean
# differences.
# ============================================================

top_effect <- dep_anno %>%

    arrange(
        desc(abs(logFC)),
        adj.P.Val
    ) %>%

    slice_head(
        n = 30
    )


write.csv(
    top_effect,
    file.path(
        RESULT_DIR,
        "04_DEP_top30_effect_size.csv"
    ),
    row.names = FALSE
)


# ============================================================
# UniProt mapping QC
# ============================================================

mapping_qc <- data.frame(

    Metric = c(
        "Input_DEP",
        "UniProt_mapped",
        "UniProt_unmapped",
        "UniProt_mapping_rate_percent"
    ),

    Value = c(
        n_input,
        n_mapped,
        n_unmapped,
        mapping_rate
    ),

    stringsAsFactors = FALSE

)


write.csv(
    mapping_qc,
    file.path(
        RESULT_DIR,
        "05_UniProt_mapping_QC.csv"
    ),
    row.names = FALSE
)


# ============================================================
# Explicit unmapped protein table
# ============================================================

unmapped <- dep_anno %>%

    filter(
        !UniProt_mapped
    ) %>%

    select(
        Protein,
        Pattern,
        Pattern_display,
        logFC,
        adj.P.Val
    )


write.csv(
    unmapped,
    file.path(
        RESULT_DIR,
        "06_UniProt_unmapped_proteins.csv"
    ),
    row.names = FALSE
)


# ============================================================
# Final runtime checks
# ============================================================

if (nrow(main_output) != nrow(dep)) {

    stop(
        "Final annotated table does not match input DEP N."
    )

}


if (
    n_mapped + n_unmapped != n_input
) {

    stop(
        "UniProt mapping accounting does not sum to input N."
    )

}


if (
    sum(pattern_summary$N) != n_input
) {

    stop(
        "Pattern summary does not sum to input DEP N."
    )

}


# ============================================================
# Console summary
# ============================================================

cat(
    "\n========================================\n"
)

cat(
    "11 DEP PROTEIN ANNOTATION COMPLETE\n"
)

cat(
    "========================================\n"
)

cat(
    "Input primary DEP: ",
    n_input,
    "\n",
    sep = ""
)

cat(
    "UniProt mapped:    ",
    n_mapped,
    "\n",
    sep = ""
)

cat(
    "UniProt unmapped:  ",
    n_unmapped,
    "\n",
    sep = ""
)

cat(
    "Mapping rate:      ",
    round(mapping_rate, 2),
    "%\n",
    sep = ""
)


cat(
    "\nDescriptive pattern summary:\n"
)

print(
    pattern_summary %>%
        select(
            Pattern,
            Pattern_display,
            N,
            Percent
        )
)


cat(
    "\nIMPORTANT:\n",
    "- Primary inferential universe = all input Long-vs-Short DEP.\n",
    "- Pattern labels are descriptive metadata only.\n",
    "- No protein was excluded based on Pattern.\n",
    "- No missing abundance value was imputed.\n",
    "- Top effect-size ranking uses primary limma logFC.\n",
    sep = ""
)


cat(
    "\nOutput directory:\n",
    RESULT_DIR,
    "\n",
    sep = ""
)