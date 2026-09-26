# Shared contracts for the prospective Discovery-Validation branch.
# This file defines functions only. It never runs a stage when sourced.

`%||%` <- function(x, y) if (is.null(x)) y else x
options(stringsAsFactors = FALSE)
DV_ROOT <- normalizePath(file.path(dirname(sys.frame(1)$ofile %||% "descriptive/discovery_validation/code/dv_shared.R"), "..", "..", ".."), winslash = "/", mustWork = FALSE)
DV_BASE <- file.path(DV_ROOT, "descriptive", "discovery_validation")
DV_ASSIGNMENT <- file.path(DV_ROOT, "descriptive", "discovery_validation_split", "discovery_validation_assignment.csv")
DV_ASSIGNMENT_SHA256 <- "062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791"
DV_PROTOCOL <- "DiscoveryValidationProtocol_v1.0"
DV_DOSE <- c("control", "low", "high")
DV_ENV <- c("Humid-hot", "High-pressure/high-altitude")
DV_SITES <- c("FJ_FQ", "FJ_PT", "FJ_QZ", "GZ_TH", "XZ_GG", "XZ_YA", "XZ_YB", "XZ_YC", "XZ_YD")
DV_SITE_ENV <- c(FJ_FQ="Humid-hot", FJ_PT="Humid-hot", FJ_QZ="Humid-hot", GZ_TH="Humid-hot",
                 XZ_GG="High-pressure/high-altitude", XZ_YA="High-pressure/high-altitude",
                 XZ_YB="High-pressure/high-altitude", XZ_YC="High-pressure/high-altitude",
                 XZ_YD="High-pressure/high-altitude")

dv_stop <- function(...) stop(paste0(...), call. = FALSE)
dv_require <- function(pkgs) {
  absent <- pkgs[!vapply(pkgs, requireNamespace, quietly=TRUE, FUN.VALUE=logical(1))]
  if (length(absent)) dv_stop("Missing required package(s): ", paste(absent, collapse=", "))
}
dv_sha256 <- function(path) {
  dv_require("digest"); if (!file.exists(path)) dv_stop("Missing input: ", path)
  digest::digest(file=path, algo="sha256", serialize=FALSE)
}
dv_assert_hash <- function(path, expected, label=basename(path)) {
  observed <- dv_sha256(path); if (!identical(observed, expected)) dv_stop(label, " SHA-256 mismatch: ", observed)
  invisible(observed)
}
dv_read_csv <- function(path, required=NULL) {
  if (!file.exists(path)) dv_stop("Missing input: ", path)
  x <- read.csv(path, check.names=FALSE, stringsAsFactors=FALSE, na.strings=c("", "NA"))
  miss <- setdiff(required %||% character(), names(x)); if (length(miss)) dv_stop(basename(path), " missing: ", paste(miss, collapse=", "))
  x
}
dv_assert_keys <- function(x, key, label) {
  if (anyNA(x[[key]]) || any(!nzchar(x[[key]])) || anyDuplicated(x[[key]])) dv_stop(label, " has invalid/duplicate ", key)
}
dv_assignment <- function(split=NULL) {
  dv_assert_hash(DV_ASSIGNMENT, DV_ASSIGNMENT_SHA256, "Frozen assignment")
  a <- dv_read_csv(DV_ASSIGNMENT, c("UniqueSampleID","TREAT1_clean","group","Split","Protocol_version"))
  dv_assert_keys(a, "UniqueSampleID", "assignment")
  split_counts <- table(a$Split)
  if (
    !identical(as.integer(split_counts["Discovery"]), 386L) ||
    !identical(as.integer(split_counts["Validation"]), 129L) ||
    sum(split_counts) != 515L
  ) dv_stop("Frozen split counts changed")
  if (!all(a$Protocol_version == DV_PROTOCOL)) dv_stop("Protocol version mismatch")
  if (!all(a$TREAT1_clean %in% DV_DOSE) || !all(a$group %in% DV_SITES)) dv_stop("Unexpected dose/site token")
  a$Environment <- unname(DV_SITE_ENV[a$group])
  if (!is.null(split)) a <- a[a$Split == split, , drop=FALSE]
  a
}
dv_stage_dir <- function(stage) file.path(DV_BASE, stage)
dv_no_overwrite <- function(paths) {
  hit <- paths[file.exists(paths)]; if (length(hit)) dv_stop("Refusing silent overwrite: ", paste(hit, collapse=", "))
  invisible(TRUE)
}
dv_write <- function(x, path) { dir.create(dirname(path), recursive=TRUE, showWarnings=FALSE); write.csv(x, path, row.names=FALSE, na="") }
dv_manifest <- function(stage, inputs, outputs, parameters=list()) {
  rows <- do.call(rbind, lapply(inputs, function(p) data.frame(kind="input", path=normalizePath(p, winslash="/", mustWork=FALSE), sha256=dv_sha256(p))))
  out <- do.call(rbind, lapply(outputs[file.exists(outputs)], function(p) data.frame(kind="output", path=normalizePath(p, winslash="/", mustWork=FALSE), sha256=dv_sha256(p))))
  params <- if(length(parameters)) data.frame(kind="parameter", path=names(parameters), sha256=unlist(parameters, use.names=FALSE)) else NULL
  rbind(rows, out, params)
}
dv_read_expression <- function(path, ids=NULL, raw=FALSE) {
  x <- dv_read_csv(path, "PG.ProteinGroups"); dv_assert_keys(x, "PG.ProteinGroups", basename(path))
  if (!is.null(ids) && !setequal(names(x)[-1], ids)) dv_stop("Expression columns are not exactly the expected participant IDs")
  if (!is.null(ids)) x <- x[c("PG.ProteinGroups", ids)]
  m <- as.matrix(x[-1]); storage.mode(m) <- "double"; rownames(m) <- x$PG.ProteinGroups
  if (any(is.infinite(m), na.rm=TRUE)) dv_stop("Infinite abundance")
  if (raw) { bad <- is.finite(m) & m <= 0; m[bad] <- NA_real_; m[is.finite(m)] <- log2(m[is.finite(m)]) }
  m
}
dv_fit <- function(expr, design, contrasts, family_n=nrow(expr)) {
  dv_require(c("limma","statmod")); if (qr(design)$rank < ncol(design)) dv_stop("NON_ESTIMABLE: rank-deficient design")
  fit <- limma::lmFit(expr, design); fit <- limma::contrasts.fit(fit, contrasts); fit <- limma::eBayes(fit, trend=TRUE, robust=TRUE)
  out <- lapply(colnames(contrasts), function(nm) {
    z <- limma::topTable(fit, coef=nm, number=Inf, sort.by="none", adjust.method="none")
    se <- abs(z$logFC / z$t); se[!is.finite(se)] <- NA_real_
    status <- ifelse(is.finite(z$logFC) & is.finite(se) & is.finite(z$P.Value), "ESTIMABLE", "NON_ESTIMABLE")
    data.frame(PG.ProteinGroups=rownames(z), Contrast=nm, log2FC=z$logFC, SE=se,
      CI_low=z$logFC-qnorm(.975)*se, CI_high=z$logFC+qnorm(.975)*se,
      P_value=z$P.Value, BH_FDR=p.adjust(z$P.Value, "BH", n=family_n), AveExpr=z$AveExpr,
      residual_df=fit$df.residual, Model_status=status, check.names=FALSE)
  })
  do.call(rbind, out)
}
dv_design <- function(meta, interaction=FALSE) {
  meta$dose <- factor(meta$TREAT1_clean, levels=DV_DOSE)
  meta$environment <- factor(meta$Environment, levels=DV_ENV)
  if (interaction) {
    meta$cell <- factor(paste(meta$dose, meta$environment, sep="__"))
    d <- model.matrix(~0+cell, meta); colnames(d) <- make.names(sub("^cell", "", colnames(d)))
  } else {
    d <- model.matrix(~0+dose+environment, meta); colnames(d) <- make.names(colnames(d))
  }
  attr(d, "rank") <- qr(d)$rank; d
}
dv_primary_contrast <- function(design) limma::makeContrasts(Long_vs_Short=dosehigh-doselow, levels=design)
dv_three_contrasts <- function(design) limma::makeContrasts(Short_vs_Control=doselow-dosecontrol, Long_vs_Control=dosehigh-dosecontrol, Long_vs_Short=dosehigh-doselow, levels=design)
dv_annotation <- function(ids) {
  p <- file.path(DV_ROOT, "descriptive", "canonical_protein_annotation.csv")
  a <- dv_read_csv(p, "PG.ProteinGroups"); dv_assert_keys(a, "PG.ProteinGroups", "canonical annotation")
  a[match(ids, a$PG.ProteinGroups), , drop=FALSE]
}
dv_add_annotation <- function(x) {
  a <- dv_annotation(x$PG.ProteinGroups); cbind(x, a[setdiff(names(a), "PG.ProteinGroups")])
}
dv_assert_candidate_hash <- function() {
  m <- file.path(dv_stage_dir("D03_candidate_lock"), "D03_candidate_lock_manifest.csv")
  l <- file.path(dv_stage_dir("D03_candidate_lock"), "D03_locked_candidates.csv")
  z <- dv_read_csv(m, c("Key","Value")); expected <- z$Value[z$Key=="candidate_list_sha256"]
  if (length(expected)!=1L) dv_stop("Candidate hash absent/ambiguous")
  dv_assert_hash(l, expected, "D03 candidate lock"); expected
}
dv_assert_unlock <- function() {
  marker <- file.path(DV_BASE, "VALIDATION_UNLOCKED.txt")
  if (!file.exists(marker)) dv_stop("VALIDATION_LOCKED: investigator-created VALIDATION_UNLOCKED.txt is required")
  marker
}
dv_binom_ci <- function(k, n) if (!n) c(NA_real_,NA_real_) else binom.test(k,n)$conf.int
