# ============================================================
# 07 DOSE TREND LIMMA ANALYSIS
#
# Plasma proteomics dose-response analysis
#
# Purpose:
#   Identify proteins showing monotonic dose-associated changes.
#
# Dose coding:
#   control = 0
#   low     = 1
#   high    = 2
#
# Model:
#   abundance ~ dose_numeric + environment
#
# Input:
#   PRIMARY_dose_log2_expression.csv.gz
#   dose_defined_metadata.csv
#
# No:
#   imputation
#   normalization
#   batch correction
#
# Output:
#   07_SECONDARY_dose_trend
#
# ============================================================


rm(list = ls())
gc()


# ============================================================
# Packages
# ============================================================

suppressPackageStartupMessages({

    library(limma)
    library(dplyr)
    library(readr)

})


# ============================================================
# Paths
# ============================================================


ROOT_DIR <- normalizePath(
    getwd(),
    winslash = "/"
)


EXPR_FILE <- file.path(
    ROOT_DIR,
    "PRIMARY_dose_log2_expression.csv.gz"
)


META_FILE <- file.path(
    ROOT_DIR,
    "dose_defined_metadata.csv"
)


OUTPUT_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "07_SECONDARY_dose_trend"
)


dir.create(
    OUTPUT_DIR,
    recursive = TRUE,
    showWarnings = FALSE
)



# ============================================================
# Read metadata
# ============================================================


meta <- read.csv(
    META_FILE,
    check.names = FALSE,
    stringsAsFactors = FALSE
)


required_meta <- c(
    "UniqueSampleID",
    "TREAT1_clean",
    "condition"
)


missing_meta <- setdiff(
    required_meta,
    colnames(meta)
)


if(length(missing_meta)>0){

    stop(
        paste(
            "Missing metadata:",
            paste(missing_meta,collapse=", ")
        )
    )

}



# dose factor

meta$dose <- factor(
    meta$TREAT1_clean,
    levels=c(
        "control",
        "low",
        "high"
    )
)



# numeric trend

meta$dose_numeric <- c(
    control = 0,
    low = 1,
    high = 2
)[
    as.character(meta$dose)
]



meta$environment <- factor(
    meta$condition,
    levels=c(
        "high_stress",
        "high_temperature"
    )
)



# ============================================================
# Read expression matrix
# ============================================================


expr_df <- read.csv(
    gzfile(EXPR_FILE),
    check.names = FALSE,
    stringsAsFactors = FALSE
)



if(
    !"PG.ProteinGroups" %in% colnames(expr_df)
){

    stop(
        "Missing PG.ProteinGroups"
    )

}



expr <- as.matrix(
    expr_df[
        ,
        -1,
        drop=FALSE
    ]
)


storage.mode(expr) <- "double"


rownames(expr) <-
    expr_df$PG.ProteinGroups



# check sample order

if(
    !identical(
        colnames(expr),
        meta$UniqueSampleID
    )
){

    stop(
        "Expression columns do not match metadata order"
    )

}



# ============================================================
# Design matrix
# ============================================================


design <- model.matrix(
    ~ dose_numeric + environment,
    data = meta
)


colnames(design) <- make.names(
    colnames(design)
)



print(design)



if(
    qr(design)$rank != ncol(design)
){

    stop(
        "Design matrix is not full rank"
    )

}



# ============================================================
# limma trend model
# ============================================================


fit <- lmFit(
    expr,
    design
)


fit <- eBayes(
    fit,
    trend = TRUE,
    robust = TRUE
)



# dose_numeric coefficient

coef_name <- "dose_numeric"


if(
    !coef_name %in% colnames(fit$coefficients)
){

    stop(
        "dose_numeric coefficient not found"
    )

}



result <- topTable(
    fit,
    coef = coef_name,
    number = Inf,
    adjust.method = "BH",
    sort.by = "P"
)



result$PG.ProteinGroups <-
    rownames(result)



rownames(result) <- NULL



# reorder

result <- result[
    ,
    c(
        "PG.ProteinGroups",
        "logFC",
        "AveExpr",
        "t",
        "P.Value",
        "adj.P.Val",
        "B"
    )
]



# ============================================================
# Save full result
# ============================================================


write.csv(
    result,
    file.path(
        OUTPUT_DIR,
        "TREND_dose_numeric_all_proteins.csv"
    ),
    row.names = FALSE
)



# ============================================================
# Significant trend proteins
# ============================================================


trend_sig <- result %>%
    filter(
        adj.P.Val < 0.05
    )


write.csv(
    trend_sig,
    file.path(
        OUTPUT_DIR,
        "TREND_dose_numeric_significant.csv"
    ),
    row.names = FALSE
)



# ============================================================
# Direction
#
# logFC >0:
#   abundance increases with dose
#
# logFC <0:
#   abundance decreases with dose
#
# ============================================================


trend_up <- trend_sig %>%
    filter(
        logFC > 0
    )


trend_down <- trend_sig %>%
    filter(
        logFC < 0
    )



write.csv(
    trend_up,
    file.path(
        OUTPUT_DIR,
        "TREND_up_increasing_with_dose.csv"
    ),
    row.names = FALSE
)



write.csv(
    trend_down,
    file.path(
        OUTPUT_DIR,
        "TREND_down_decreasing_with_dose.csv"
    ),
    row.names = FALSE
)



# ============================================================
# Summary
# ============================================================


summary <- data.frame(

    total_proteins =
        nrow(result),

    FDR05 =
        nrow(trend_sig),

    increasing =
        nrow(trend_up),

    decreasing =
        nrow(trend_down)

)



write.csv(
    summary,
    file.path(
        OUTPUT_DIR,
        "TREND_summary.csv"
    ),
    row.names = FALSE
)



print(summary)


cat(
    "\nDose trend analysis completed.\n"
)