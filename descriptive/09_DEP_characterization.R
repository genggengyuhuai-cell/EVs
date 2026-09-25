# ============================================================
# 09 DEP CHARACTERIZATION
#
# High vs Low exposure
#
# Input:
#   limma High_vs_Low result
#
# Output:
#   DEP tables for downstream biology
#
# ============================================================


rm(list=ls())
gc()


library(dplyr)
library(readr)



get_script_dir <- function() {
    args <- commandArgs(trailingOnly = FALSE)
    file_arg <- grep("^--file=", args, value = TRUE)
    if (length(file_arg) == 1L) {
        return(dirname(normalizePath(sub("^--file=", "", file_arg),
                                     winslash = "/", mustWork = TRUE)))
    }
    normalizePath(getwd(), winslash = "/", mustWork = TRUE)
}

ROOT_DIR <- get_script_dir()


INPUT <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "01_PRIMARY",
    "PRIMARY_log2_dose_environment__High_vs_Low.csv"
)


OUTDIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "09_DEP_characterization"
)


dir.create(
    OUTDIR,
    recursive=TRUE,
    showWarnings=FALSE
)



# ============================================================
# Read
# ============================================================


res <- read.csv(
    INPUT,
    check.names=FALSE,
    stringsAsFactors=FALSE
)



# ============================================================
# DEP definition
#
# locked:
# BH FDR <0.05
#
# ============================================================


DEP <- res %>%
    filter(
        adj.P.Val < 0.05
    )


DEP <- DEP %>%
    mutate(

        Direction = case_when(

            logFC > 0 ~ "Higher_in_High",

            logFC < 0 ~ "Higher_in_Low",

            TRUE ~ "No_change"

        )

    )



# ============================================================
# Save all DEP
# ============================================================


write.csv(
    DEP,
    file.path(
        OUTDIR,
        "High_vs_Low_DEP_all.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Split direction
# ============================================================


write.csv(
    DEP %>% filter(
        Direction=="Higher_in_High"
    ),
    file.path(
        OUTDIR,
        "High_vs_Low_DEP_High_up.csv"
    ),
    row.names=FALSE
)



write.csv(
    DEP %>% filter(
        Direction=="Higher_in_Low"
    ),
    file.path(
        OUTDIR,
        "High_vs_Low_DEP_High_down.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Top proteins
#
# ranking by FDR
#
# ============================================================


top30 <- DEP %>%
    arrange(
        adj.P.Val
    ) %>%
    slice(
        1:30
    )



write.csv(
    top30,
    file.path(
        OUTDIR,
        "High_vs_Low_TOP30_FDR.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Effect ranking
#
# moderated t
#
# ============================================================


top30_t <- DEP %>%
    arrange(
        desc(abs(t))
    ) %>%
    slice(
        1:30
    )



write.csv(
    top30_t,
    file.path(
        OUTDIR,
        "High_vs_Low_TOP30_absT.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Summary
# ============================================================


summary <- data.frame(

    Total_DEP =
        nrow(DEP),

    Higher_in_High =
        sum(
            DEP$logFC>0
        ),

    Higher_in_Low =
        sum(
            DEP$logFC<0
        ),

    Median_logFC =
        median(
            DEP$logFC
        ),

    Mean_logFC =
        mean(
            DEP$logFC
        )

)


write.csv(
    summary,
    file.path(
        OUTDIR,
        "DEP_summary.csv"
    ),
    row.names=FALSE
)


print(summary)

# Standalone displays of the existing DEP tables; ranking is unchanged.
source(file.path(ROOT_DIR, "v21_common.R"))
v21_packages(c("ggplot2", "svglite", "ragg"))
library(ggplot2)
FIG_DIR <- file.path(ROOT_DIR, "limma_dose_analysis", "figures_final", "09_DEP_characterization", "figures_nature_v2.2")
counts <- count(DEP, Direction, name = "N")
counts$Direction <- recode(counts$Direction, Higher_in_High = "Higher in Long", Higher_in_Low = "Higher in Short", No_change = "Zero estimated difference")
p <- ggplot(counts, aes(Direction, N)) + geom_col(fill = "#3178A5", width = 0.65) + coord_flip() +
    labs(x = NULL, y = "Protein groups", title = "Long vs Short exposure: DEP directions", subtitle = "Locked primary BH FDR < 0.05")
v21_save(p, FIG_DIR, "Figure_09_DEP_characterization_direction_counts", counts)
for (ranking in c("FDR", "absT")) {
    shown <- if (ranking == "FDR") top30 else top30_t
    if (!nrow(shown)) next
    shown$Protein_label <- factor(shown$PG.ProteinGroups, levels = rev(shown$PG.ProteinGroups))
    p <- ggplot(shown, aes(logFC, Protein_label)) + geom_vline(xintercept = 0, linetype = 2, linewidth = 0.35) +
        geom_point(colour = "#3178A5", size = 2) +
        labs(x = "log2 fold change (Long - Short)", y = NULL,
             title = paste("Top 30 Long vs Short DEP ranked by", if (ranking == "FDR") "BH FDR" else "absolute moderated t"),
             subtitle = "Point estimates; no uncertainty intervals shown")
    v21_save(p, FIG_DIR, paste0("Figure_09_DEP_characterization_top30_", v22_slug(ranking)), shown,
             height_mm = max(120, 40 + 5 * nrow(shown)))
}
