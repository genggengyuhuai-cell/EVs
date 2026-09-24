# ============================================================
# 10 PROTEIN CLUSTERING
#
# High vs Low DEP protein expression pattern
#
# Input:
#   High_vs_Low_DEP_all.csv
#   PRIMARY_dose_log2_expression.csv.gz
#
# Method:
#   protein-wise z-score
#   hierarchical clustering
#   k-means sensitivity
#
# ============================================================


rm(list=ls())
gc()


# ============================================================
# Packages
# ============================================================

suppressPackageStartupMessages({

    library(dplyr)
    library(pheatmap)
    library(ggplot2)
    library(readr)

})



# ============================================================
# Paths
# ============================================================


ROOT_DIR <- normalizePath(
    getwd(),
    winslash="/"
)


source(file.path(ROOT_DIR, "v21_common.R"))
v21_packages(c("svglite", "ragg"))

DEP_FILE <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "09_DEP_characterization",
    "High_vs_Low_DEP_all.csv"
)


EXPR_FILE <- file.path(
    ROOT_DIR,
    "PRIMARY_dose_log2_expression.csv.gz"
)


META_FILE <- file.path(
    ROOT_DIR,
    "dose_defined_metadata.csv"
)


RESULT_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "results",
    "10_protein_clustering"
)


FIG_DIR <- file.path(
    ROOT_DIR,
    "limma_dose_analysis",
    "figures_final",
    "10_protein_clustering", "figures_nature_v2.2"
)



dir.create(
    RESULT_DIR,
    recursive=TRUE,
    showWarnings=FALSE
)


dir.create(
    FIG_DIR,
    recursive=TRUE,
    showWarnings=FALSE
)



# ============================================================
# 1. Read DEP
# ============================================================


dep <- read.csv(
    DEP_FILE,
    check.names=FALSE,
    stringsAsFactors=FALSE
)



dep_ids <- dep$PG.ProteinGroups



cat(
    "DEP proteins:",
    length(dep_ids),
    "\n"
)



# ============================================================
# 2. Read expression matrix
# ============================================================


expr_df <- read.csv(
    gzfile(EXPR_FILE),
    check.names=FALSE,
    stringsAsFactors=FALSE
)



expr <- as.matrix(
    expr_df[
        ,
        -1,
        drop=FALSE
    ]
)


rownames(expr) <-
    expr_df$PG.ProteinGroups



storage.mode(expr) <- "numeric"



# ============================================================
# 3. Extract DEP expression
# ============================================================


common <- intersect(
    dep_ids,
    rownames(expr)
)



if(
    length(common)<10
){

    stop(
        "Too few DEP proteins found in expression matrix"
    )

}



dep_expr <- expr[
    common,
    ,
    drop=FALSE
]



cat(
    "Expression proteins:",
    nrow(dep_expr),
    "\n"
)



# ============================================================
# 4. Clustering-specific missing value handling
#
# Visualization only
#
# Missing values:
#     NA -> 0
#
# IMPORTANT:
#     This matrix is NOT used for limma.
#
# ============================================================


cat(
    "Missing values before replacement:",
    sum(is.na(dep_expr)),
    "\n"
)



# Replace missing values with zero

dep_expr[
    is.na(dep_expr)
] <- 0



cat(
    "Missing values after replacement:",
    sum(is.na(dep_expr)),
    "\n"
)



# ============================================================
# Protein-wise z-score
# ============================================================


z_expr <- t(
    scale(
        t(dep_expr)
    )
)



rownames(z_expr) <-
    rownames(dep_expr)



# remove any numerical problem

z_expr <- z_expr[
    complete.cases(z_expr),
    ,
    drop = FALSE
]



cat(
    "Proteins after z-score:",
    nrow(z_expr),
    "\n"
)


# ============================================================
# 5. Metadata annotation
# ============================================================


meta <- read.csv(
    META_FILE,
    check.names=FALSE,
    stringsAsFactors=FALSE
)



meta <- meta[
    match(
        colnames(z_expr),
        meta$UniqueSampleID
    ),
]



annotation_col <- data.frame(

    Exposure_duration =
        factor(meta$TREAT1_clean, levels = c("control", "low", "high"),
               labels = c("Control", "Short exposure", "Long exposure")),

    Environment =
        meta$condition

)


rownames(annotation_col) <-
    meta$UniqueSampleID


# Display-only annotation colours; clustering inputs and assignments are unchanged.
annotation_colors <- list(
    Exposure_duration = c(
        "Control" = EXPOSURE_COLORS[["control"]],
        "Short exposure" = EXPOSURE_COLORS[["low"]],
        "Long exposure" = EXPOSURE_COLORS[["high"]]
    )
)



# ============================================================
# 6. Hierarchical clustering
# ============================================================
cat(
    "NA in z matrix:",
    sum(is.na(z_expr)),
    "\n"
)

cat(
    "Inf in z matrix:",
    sum(is.infinite(z_expr)),
    "\n"
)

row_dist <- as.dist(
    1-cor(
        t(z_expr),
        method="pearson"
    )
)



row_hc <- hclust(
    row_dist,
    method="complete"
)



# choose clusters

k <- 4



cluster_hc <- cutree(
    row_hc,
    k=k
)



cluster_table <- data.frame(

    Protein =
        names(cluster_hc),

    Cluster =
        cluster_hc

)



cluster_table <- cluster_table %>%
    left_join(
        dep %>%
            select(
                PG.ProteinGroups,
                logFC,
                adj.P.Val
            ),
        by=c(
            "Protein"="PG.ProteinGroups"
        )
    )



write.csv(
    cluster_table,
    file.path(
        RESULT_DIR,
        "DEP_cluster_membership_hclust.csv"
    ),
    row.names=FALSE
)



# ============================================================
# 7. Heatmap all DEP
# ============================================================


v22_heatmap(z_expr, FIG_DIR, "Figure_10_protein_clustering_all_DEP_heatmap", scale = "none",
    clustering_distance_rows = row_dist, clustering_method = "complete",
    annotation_col = annotation_col, annotation_colors = annotation_colors,
    show_rownames = FALSE, show_colnames = FALSE,
    main = "All Long vs Short exposure DEPs (clustering-only NA -> 0)", height_mm = 180)



# ============================================================
# 8. Top50 heatmap
#
# ranked by FDR
#
# ============================================================


top50 <- dep %>%
    arrange(
        adj.P.Val
    ) %>%
    slice_head(
        n=50
    ) %>%
    pull(
        PG.ProteinGroups
    )


top50 <- intersect(
    top50,
    rownames(z_expr)
)



v22_heatmap(z_expr[top50, , drop = FALSE], FIG_DIR, "Figure_10_protein_clustering_top50_DEP_heatmap", scale = "none",
    annotation_col = annotation_col, annotation_colors = annotation_colors,
    clustering_method = "complete",
    show_rownames = TRUE, show_colnames = FALSE,
    main = "Top 50 Long vs Short exposure DEPs by FDR (clustering-only NA -> 0)", height_mm = 220)



# ============================================================
# 9. K-means sensitivity
# ============================================================


set.seed(123)



km_result <- data.frame()


for(
    kk in 2:6
){

    km <- kmeans(
        z_expr,
        centers=kk,
        nstart=100
    )


    tmp <- data.frame(

        Protein =
            rownames(z_expr),

        K =
            kk,

        Cluster =
            km$cluster

    )


    km_result <-
        rbind(
            km_result,
            tmp
        )

}



write.csv(
    km_result,
    file.path(
        RESULT_DIR,
        "DEP_cluster_membership_kmeans.csv"
    ),
    row.names=FALSE
)



# ============================================================
# 10. Cluster summary
# ============================================================


summary <- cluster_table %>%
    group_by(
        Cluster
    ) %>%
    summarise(

        N =
            n(),

        Mean_logFC =
            mean(
                logFC,
                na.rm=TRUE
            ),

        Median_FDR =
            median(
                adj.P.Val,
                na.rm=TRUE
            )

    )



write.csv(
    summary,
    file.path(
        RESULT_DIR,
        "DEP_cluster_summary.csv"
    ),
    row.names=FALSE
)



print(summary)


cat(
    "\nProtein clustering completed.\n"
)

# Existing cluster membership and effects, displayed without choosing a new K.
p <- ggplot(summary, aes(factor(Cluster), N)) + geom_col(fill = "#3178A5", width = 0.65) +
    labs(x = "Hierarchical cluster", y = "Protein groups", title = "Exploratory hierarchical cluster sizes (K = 4)")
v21_save(p, FIG_DIR, "Figure_10_protein_clustering_hierarchical_cluster_sizes", summary)
p <- ggplot(cluster_table, aes(factor(Cluster), logFC)) +
    geom_hline(yintercept = 0, linetype = 2, linewidth = 0.35) +
    geom_boxplot(fill = "#DCE8EF", outlier.size = 0.6, linewidth = 0.35) +
    labs(x = "Hierarchical cluster", y = "log2 fold change (Long - Short exposure)", title = "Long vs Short exposure effects by exploratory cluster")
v21_save(p, FIG_DIR, "Figure_10_protein_clustering_cluster_effect_distributions", cluster_table)
for (kk in sort(unique(km_result$K))) {
    shown <- count(km_result[km_result$K == kk, , drop = FALSE], Cluster, name = "N")
    p <- ggplot(shown, aes(factor(Cluster), N)) + geom_col(fill = "#3178A5", width = 0.65) +
        labs(x = "K-means cluster", y = "Protein groups", title = paste("Exploratory K-means sensitivity: K =", kk))
    v21_save(p, FIG_DIR, paste0("Figure_10_protein_clustering_kmeans_cluster_sizes_K", kk), shown)
}
