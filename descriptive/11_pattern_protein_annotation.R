# ============================================================
# 11 PATTERN PROTEIN ANNOTATION
#
# Analyze Low_peak proteins
#
# Purpose:
#   Characterize proteins showing:
#
#       Control < Low > High
#
# Input:
#   DEP_three_group_pattern.csv
#
# Output:
#   Annotated Low_peak proteins
#
# ============================================================


rm(list=ls())
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
    winslash="/"
)



INPUT_FILE <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "10_dose_pattern_classification",
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
    recursive=TRUE,
    showWarnings=FALSE
)



# ============================================================
# UniProt annotation
# ============================================================


uniprot_annotation <- function(ids){


    ids <- unique(ids)


    ids <- ids[
        !is.na(ids) &
        ids!=""
    ]


    query <- paste(
        ids,
        collapse=","
    )


    url <- paste0(
        "https://rest.uniprot.org/uniprotkb/search?",
        "query=accession_id:",
        query,
        "&format=tsv",
        "&fields=accession,gene_names,protein_name"
    )


    r <- GET(url)


    if(
        status_code(r)!=200
    ){

        warning(
            "UniProt annotation failed"
        )

        return(
            data.frame()
        )

    }



    txt <- content(
        r,
        "text"
    )


    tab <- read.delim(
        textConnection(txt),
        stringsAsFactors=FALSE
    )


    colnames(tab) <- c(
        "Protein",
        "GeneSymbol",
        "ProteinName"
    )


    tab

}




# ============================================================
# Read pattern table
# ============================================================


pattern <- read.csv(
    INPUT_FILE,
    check.names=FALSE,
    stringsAsFactors=FALSE
)



cat(
    "Input proteins:",
    nrow(pattern),
    "\n"
)



# ============================================================
# Select Low_peak
# ============================================================


low_peak <- pattern %>%

    filter(
        Pattern=="Low_peak"
    )



cat(
    "Low_peak proteins:",
    nrow(low_peak),
    "\n"
)



# ============================================================
# Calculate additional statistics
# ============================================================


low_peak <- low_peak %>%

    mutate(

        Low_minus_Control =
            Low - Control,

        Low_minus_High =
            Low - High,

        High_minus_Control =
            High - Control

    )



# ============================================================
# UniProt annotation
# ============================================================


anno <- uniprot_annotation(
    low_peak$Protein
)



low_peak_anno <- low_peak %>%

    left_join(
        anno,
        by="Protein"
    )



write.csv(
    low_peak_anno,
    file.path(
        RESULT_DIR,
        "Low_peak_protein_annotation.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Top proteins:
#
# Largest Low-High difference
#
# ============================================================


top_Low_High <- low_peak_anno %>%

    arrange(
        desc(
            Low_minus_High
        )
    ) %>%

    slice_head(
        n=30
    )



write.csv(
    top_Low_High,
    file.path(
        RESULT_DIR,
        "Low_peak_top30_Low_vs_High.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Top proteins:
# strongest statistical evidence
#
# ============================================================


top_FDR <- low_peak_anno %>%

    arrange(
        adj.P.Val
    ) %>%

    slice_head(
        n=30
    )



write.csv(
    top_FDR,
    file.path(
        RESULT_DIR,
        "Low_peak_top30_FDR.csv"
    ),
    row.names=FALSE
)



# ============================================================
# Summary
# ============================================================


summary <- data.frame(

    Total_Low_peak =
        nrow(low_peak_anno),


    Mean_Control =
        mean(
            low_peak_anno$Control,
            na.rm=TRUE
        ),


    Mean_Low =
        mean(
            low_peak_anno$Low,
            na.rm=TRUE
        ),


    Mean_High =
        mean(
            low_peak_anno$High,
            na.rm=TRUE
        ),


    Mean_Low_vs_High =
        mean(
            low_peak_anno$Low_minus_High,
            na.rm=TRUE
        )

)



write.csv(
    summary,
    file.path(
        RESULT_DIR,
        "Low_peak_summary.csv"
    ),
    row.names=FALSE
)



print(summary)


cat(
    "\nLow_peak annotation completed.\n"
)