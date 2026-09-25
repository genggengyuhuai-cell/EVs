# ============================================================
# DEP EFFECT-SIZE SUMMARY (renamed from 07_DEP_threshold_summary.R)
#
# Long vs Short exposure differential proteins (legacy key: High_vs_Low).
# Historical output paths and table columns are retained for compatibility.
#
# Primary:
#   BH FDR <0.05
#
# Additional effect-size layers:
#   FDR <0.05 & |log2FC| >=0.5
#   FDR <0.05 & |log2FC| >=1
#
# No refitting
# ============================================================


rm(list = ls())
gc()


library(dplyr)
library(readr)



# ============================================================
# Path
# ============================================================


get_script_dir <- function() {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) == 1L) {
        return(dirname(normalizePath(sub("^--file=", "", file_arg),
                                     winslash = "/", mustWork = TRUE)))
    }
    stop("Run this stage with Rscript so --file= is available.")
}

ROOT_DIR <- get_script_dir()


RESULT_FILE <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "01_PRIMARY",
    "PRIMARY_log2_dose_environment__High_vs_Low.csv"
)


OUTPUT_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "09_DEP_threshold_summary"
)


dir.create(
    OUTPUT_DIR,
    recursive=TRUE,
    showWarnings=FALSE
)



# ============================================================
# Read result
# ============================================================


res <- read.csv(
    RESULT_FILE,
    stringsAsFactors = FALSE,
    check.names = FALSE
)


cat(
    "Input proteins:",
    nrow(res),
    "\n"
)



# ============================================================
# Check columns
# ============================================================


required <- c(
    "PG.ProteinGroups",
    "logFC",
    "adj.P.Val"
)


if(
    !all(required %in% colnames(res))
){

    stop(
        paste(
            "Missing columns:",
            paste(
                setdiff(required,colnames(res)),
                collapse=", "
            )
        )
    )

}



# ============================================================
# Define thresholds
# ============================================================


res <- res %>%
    mutate(

        FDR05 =
            !is.na(adj.P.Val) &
            is.finite(adj.P.Val) &
            adj.P.Val < 0.05,

        FC05 =
            !is.na(logFC) &
            is.finite(logFC) &
            abs(logFC) >= 0.5,

        FC10 =
            !is.na(logFC) &
            is.finite(logFC) &
            abs(logFC) >= 1,


        DEP_FDR =
            FDR05,


        DEP_FDR_FC05 =
            FDR05 & FC05,


        DEP_FDR_FC10 =
            FDR05 & FC10,


        Direction =
            case_when(

                logFC > 0 ~ "Higher in High",

                logFC < 0 ~ "Higher in Low",

                TRUE ~ "No change"

            )

    )



# ============================================================
# Save classified proteins
# ============================================================


write.csv(
    res,
    file.path(
        OUTPUT_DIR,
        "High_vs_Low_all_classified.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Summary function
# ============================================================


summary_fun <- function(
    data,
    variable
){

    x <- data[
        data[[variable]],
        ,
        drop=FALSE
    ]


    data.frame(

        Threshold = variable,

        Total = nrow(x),

        Higher_in_High =
            sum(
                x$logFC > 0
            ),

        Higher_in_Low =
            sum(
                x$logFC < 0
            )

    )

}



summary_table <- bind_rows(

    summary_fun(
        res,
        "DEP_FDR"
    ),

    summary_fun(
        res,
        "DEP_FDR_FC05"
    ),

    summary_fun(
        res,
        "DEP_FDR_FC10"
    )

)



write.csv(
    summary_table,
    file.path(
        OUTPUT_DIR,
        "High_vs_Low_DEP_threshold_summary.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Print
# ============================================================


print(
    summary_table
)

# Display existing threshold layers; no refitting or threshold changes.
source(file.path(ROOT_DIR, "v21_common.R"))
v21_packages(c("ggplot2", "tidyr", "svglite", "ragg"))
library(ggplot2)
FIG_DIR <- file.path(OUTPUT_DIR, "figures_nature_v2.2")
shown <- tidyr::pivot_longer(summary_table, c(Higher_in_High, Higher_in_Low),
                             names_to = "Direction", values_to = "N")
shown$Direction <- ifelse(shown$Direction == "Higher_in_High", "Higher in Long", "Higher in Short")
shown$Threshold <- factor(shown$Threshold, levels = summary_table$Threshold,
                          labels = c("FDR < 0.05", "FDR < 0.05 and |log2FC| ≥ 0.5", "FDR < 0.05 and |log2FC| ≥ 1"))
p <- ggplot(shown, aes(Threshold, N, fill = Direction)) + geom_col(width = 0.65) +
    coord_flip() + scale_fill_manual(values = c("Higher in Long" = "#C78132", "Higher in Short" = "#3178A5")) +
    labs(x = NULL, y = "Protein groups", title = "Long vs Short exposure: effect-size layers",
         subtitle = "Nested thresholds from the locked primary contrast")
v21_save(p, FIG_DIR, "Figure_DEP_effect_size_summary_threshold_counts", shown)
shown <- res[is.finite(res$logFC), , drop = FALSE]
p <- ggplot(shown, aes(logFC)) + geom_histogram(bins = 50, fill = "#3178A5", colour = "white", linewidth = 0.2) +
    geom_vline(xintercept = 0, linewidth = 0.35, linetype = 2) +
    labs(x = "log2 fold change (Long - Short exposure)", y = "Protein groups",
         title = "Long vs Short exposure: effect sizes across all tested proteins")
v21_save(p, FIG_DIR, "Figure_DEP_effect_size_summary_all_tested_log2FC_distribution", shown)


cat(
    "\nCompleted.\n"
)
