# Shared v2.1 I/O and Nature-style R figure contract. Sourcing does not run analysis.
V21_VERSION <- "2.1"
EXPOSURE_LEVELS <- c("control", "low", "high")
EXPOSURE_LABELS <- c(control = "Control", low = "Short exposure", high = "Long exposure")
EXPOSURE_COLORS <- c(control = "#595959", low = "#3178A5", high = "#C78132")
CONTRAST_LABELS <- c(Low_vs_Control = "Short exposure vs Control",
                     High_vs_Control = "Long exposure vs Control",
                     High_vs_Low = "Long vs Short exposure")
v21_packages <- function(packages) {
    missing <- packages[!vapply(packages, requireNamespace, quietly = TRUE, FUN.VALUE = logical(1))]
    if (length(missing)) stop("Missing packages (no auto-install): ", paste(missing, collapse = ", "))
}
v21_columns <- function(data, columns, label) {
    missing <- setdiff(columns, names(data))
    if (length(missing)) stop(label, " missing columns: ", paste(missing, collapse = ", "))
}
v21_ids <- function(ids, label) {
    if (!length(ids) || anyNA(ids) || any(!nzchar(trimws(ids))) || anyDuplicated(ids))
        stop(label, " must contain unique non-empty IDs.")
}
v21_read <- function(path, required = character(), id = NULL, character_only = FALSE) {
    if (!file.exists(path)) stop("Required input missing: ", path)
    # Preserve literal Unknown, NA, missing and 0; only empty fields are absent.
    data <- read.csv(path, check.names = FALSE, stringsAsFactors = FALSE,
                     na.strings = "", colClasses = if (character_only) "character" else NA)
    v21_columns(data, required, basename(path))
    if (!is.null(id)) v21_ids(data[[id]], paste(basename(path), id))
    data
}
v21_match <- function(reference_ids, other, label, exact = TRUE) {
    v21_ids(reference_ids, "Reference sample IDs")
    v21_ids(other$UniqueSampleID, label)
    if ((exact && !setequal(reference_ids, other$UniqueSampleID)) ||
        !all(reference_ids %in% other$UniqueSampleID)) stop("Sample-ID mismatch: ", label)
    other[match(reference_ids, other$UniqueSampleID), , drop = FALSE]
}
v21_output <- function(path) {
    if (dir.exists(path) && length(list.files(path, all.files = TRUE, no.. = TRUE)))
        stop("Output directory is non-empty; preserve it and choose a new destination: ", path)
    dir.create(path, recursive = TRUE, showWarnings = FALSE)
    path
}
v21_write <- function(data, path) write.csv(data, path, row.names = FALSE, na = "")
v21_annotation <- function(root_dir) {
    path <- file.path(root_dir, "canonical_protein_annotation.csv")
    annotation <- v21_read(path, c("PG.ProteinGroups", "Gene_symbol", "Display_label"),
                           "PG.ProteinGroups")
    if (anyNA(annotation$Display_label) || any(!nzchar(trimws(annotation$Display_label))))
        stop("Canonical annotation contains empty Display_label values.")
    annotation
}
v21_annotate <- function(data, annotation, require_all = TRUE) {
    v21_columns(data, "PG.ProteinGroups", "Protein-level table")
    index <- match(data$PG.ProteinGroups, annotation$PG.ProteinGroups)
    if (require_all && anyNA(index))
        stop("Canonical annotation does not cover every PG.ProteinGroups value.")
    data$Gene_symbol <- annotation$Gene_symbol[index]
    data$Display_label <- annotation$Display_label[index]
    data
}
v21_provenance <- function(out, inputs, parameters, packages = character()) {
    inputs <- unique(inputs[file.exists(inputs)])
    v21_write(data.frame(Input = normalizePath(inputs, winslash = "/"),
                         MD5 = unname(tools::md5sum(inputs))), file.path(out, "input_provenance.csv"))
    values <- c(script_version = V21_VERSION, analysis_time_UTC = format(Sys.time(), tz = "UTC"),
                R_version = R.version.string, parameters,
                setNames(vapply(packages, function(p) as.character(utils::packageVersion(p)), character(1)),
                         paste0("package_", packages)))
    v21_write(data.frame(Parameter = names(values), Value = unname(values)),
              file.path(out, "method_parameters.csv"))
}
v21_theme <- function(base_size = 8) {
    ggplot2::theme_classic(base_size = base_size, base_family = "sans") +
        ggplot2::theme(axis.line = ggplot2::element_line(linewidth = 0.35),
                       axis.ticks = ggplot2::element_line(linewidth = 0.35),
                       axis.text = ggplot2::element_text(size = 7, colour = "black"),
                       axis.title = ggplot2::element_text(size = 8),
                       legend.text = ggplot2::element_text(size = 7),
                       legend.title = ggplot2::element_text(size = 7.5),
                       strip.text = ggplot2::element_text(size = 8, face = "bold"),
                       plot.title = ggplot2::element_text(size = 10, face = "bold", margin = ggplot2::margin(b = 7)),
                       plot.subtitle = ggplot2::element_text(size = 8, margin = ggplot2::margin(b = 8)),
                       plot.caption = ggplot2::element_text(size = 7),
                       plot.tag = ggplot2::element_text(size = 8, face = "bold"),
                       legend.position = "bottom", legend.box = "vertical",
                       plot.margin = ggplot2::margin(10, 12, 10, 10),
                       panel.grid = ggplot2::element_blank())
}
v21_save <- function(plot, out, name, source, width_mm = 183, height_mm = 120) {
    # v2.2 contract: each caller supplies one plot, not a patchwork or facet grid.
    dir.create(out, recursive = TRUE, showWarnings = FALSE)
    for (label in c("title", "subtitle", "caption")) {
        value <- plot$labels[[label]]
        if (is.character(value) && length(value) == 1L)
            plot$labels[[label]] <- paste(strwrap(sub("^[A-Fa-f]  ", "", value), width = 75), collapse = "\n")
    }
    plot <- plot + v21_theme() + ggplot2::guides(
        colour = ggplot2::guide_legend(nrow = 2, byrow = TRUE),
        shape = ggplot2::guide_legend(nrow = 2, byrow = TRUE))
    # Editable vector PDF + 600 dpi PNG; no rendering occurs until explicitly run.
    grDevices::cairo_pdf(file.path(out, paste0(name, ".pdf")), width = width_mm / 25.4,
                         height = height_mm / 25.4, family = "sans")
    tryCatch(print(plot), finally = grDevices::dev.off())
    svglite::svglite(file.path(out, paste0(name, ".svg")), width = width_mm / 25.4,
                     height = height_mm / 25.4)
    tryCatch(print(plot), finally = grDevices::dev.off())
    ggplot2::ggsave(file.path(out, paste0(name, ".png")), plot, device = ragg::agg_png,
                    width = width_mm, height = height_mm, units = "mm", dpi = 600, bg = "white")
    if (!is.null(source)) v21_write(source, file.path(out, paste0(name, "_source.csv")))
}

v22_slug <- function(x) gsub("[^A-Za-z0-9_-]+", "_", x)

v22_draw <- function(draw, out, name, width_mm = 183, height_mm = 140) {
    # Base-R diagnostics and grid heatmaps use the same physical export contract.
    v21_packages(c("svglite", "ragg"))
    dir.create(out, recursive = TRUE, showWarnings = FALSE)
    devices <- list(
        pdf = function(path) grDevices::cairo_pdf(path, width = width_mm / 25.4, height = height_mm / 25.4, family = "sans"),
        svg = function(path) svglite::svglite(path, width = width_mm / 25.4, height = height_mm / 25.4),
        png = function(path) ragg::agg_png(path, width = width_mm, height = height_mm, units = "mm", res = 600))
    for (extension in names(devices)) {
        devices[[extension]](file.path(out, paste0(name, ".", extension)))
        tryCatch(draw(), finally = grDevices::dev.off())
    }
}

v22_heatmap <- function(matrix, out, name, ..., display_labels = NULL,
                        width_mm = 183, height_mm = 150) {
    # Clustering, ordering, scaling and missing-data decisions belong to the caller.
    v21_packages("pheatmap")
    dots <- list(...)
    defaults <- list(fontsize = 8, fontsize_row = 7, fontsize_col = 7,
                     fontfamily = "sans", border_color = NA, silent = TRUE)
    for (key in names(defaults)) if (is.null(dots[[key]])) dots[[key]] <- defaults[[key]]
    if (!is.null(display_labels)) {
        if (length(display_labels) != nrow(matrix)) stop("Heatmap display-label length mismatch.")
        dots$labels_row <- display_labels
    }
    heatmap <- do.call(pheatmap::pheatmap, c(list(mat = matrix), dots))
    v22_draw(function() { grid::grid.newpage(); grid::grid.draw(heatmap$gtable) },
              out, name, width_mm, height_mm)
    v21_write(data.frame(Protein = rownames(matrix), matrix, check.names = FALSE),
              file.path(out, paste0(name, "_source.csv")))
}
# Literal placeholder tokens are retained in QC. This helper only selects an alias;
# numeric/model eligibility is separately recorded by each consumer.
v21_alias <- function(data, aliases, label) {
    hits <- aliases[aliases %in% names(data)]
    if (!length(hits)) return(NA_character_)
    if (length(hits) > 1L) {
        first <- as.character(data[[hits[1]]])
        same <- vapply(hits[-1], function(h) identical(first, as.character(data[[h]])), logical(1))
        if (!all(same)) stop("Conflicting metadata aliases for ", label, ": ", paste(hits, collapse = ", "))
    }
    hits[1]
}
