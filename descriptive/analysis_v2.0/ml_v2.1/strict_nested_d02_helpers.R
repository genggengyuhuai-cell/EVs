# D02-compatible helpers for strict_nested_sensitivity.R.
# Functions only; sourcing this file performs no analysis and writes no files.

STRICT_ENV_LEVELS <- c("Humid-hot", "High-pressure/high-altitude")
STRICT_SITE_ENV <- c(
  FJ_FQ="Humid-hot", FJ_PT="Humid-hot", FJ_QZ="Humid-hot", GZ_TH="Humid-hot",
  XZ_GG="High-pressure/high-altitude", XZ_YA="High-pressure/high-altitude",
  XZ_YB="High-pressure/high-altitude", XZ_YC="High-pressure/high-altitude",
  XZ_YD="High-pressure/high-altitude"
)

load_strict_nested_raw_data <- function(
    raw_workbook="rawdata/processed.xlsx",
    assignment_file="descriptive/discovery_validation_split/discovery_validation_assignment.csv",
    mapping_file="descriptive/discovery_validation/D01_discovery_eligibility/D01_participant_mapping_diagnostics.csv") {
  if (!requireNamespace("openxlsx", quietly=TRUE)) stop("Missing package: openxlsx")
  meta <- read.csv(assignment_file, stringsAsFactors=FALSE, check.names=FALSE)
  meta <- meta[meta$Split == "Discovery" & meta$TREAT1_clean %in% c("high", "low"), , drop=FALSE]
  mapping <- read.csv(mapping_file, stringsAsFactors=FALSE, check.names=FALSE)
  mapping <- mapping[match(meta$UniqueSampleID, mapping$UniqueSampleID), , drop=FALSE]
  if (anyNA(mapping$Sheet1_position) || !identical(meta$UniqueSampleID, mapping$UniqueSampleID)) {
    stop("Frozen participant-to-raw-column mapping is incomplete or reordered")
  }
  positions <- as.integer(mapping$Sheet1_position)
  sorted_positions <- sort(unique(positions))
  raw <- openxlsx::read.xlsx(
    raw_workbook, sheet=1,
    cols=c(1L, 7L + sorted_positions),
    colNames=TRUE, check.names=FALSE, skipEmptyRows=FALSE
  )
  if (nrow(raw) != 3817L || names(raw)[1] != "PG.ProteinGroups") {
    stop("Raw protein universe contract failed: expected 3,817 rows keyed by PG.ProteinGroups")
  }
  protein_ids <- as.character(raw[[1]])
  if (anyNA(protein_ids) || any(!nzchar(protein_ids)) || anyDuplicated(protein_ids)) {
    stop("Raw PG.ProteinGroups keys are missing or duplicated")
  }
  abundance_sorted <- as.matrix(raw[-1])
  storage.mode(abundance_sorted) <- "double"
  abundance <- abundance_sorted[, match(positions, sorted_positions), drop=FALSE]
  colnames(abundance) <- meta$UniqueSampleID
  rownames(abundance) <- protein_ids
  X_raw <- t(abundance)
  meta$Environment <- unname(STRICT_SITE_ENV[meta$group])
  if (anyNA(meta$Environment)) stop("Unexpected site token while deriving Environment")
  y <- as.integer(meta$TREAT1_clean == "high")
  if (length(y) != 271L || sum(y == 0L) != 139L || sum(y == 1L) != 132L) {
    stop("Frozen High/Low sample-count contract failed")
  }
  list(X_raw=X_raw, meta=meta, y=y, protein_ids=protein_ids)
}

fold_local_d02_screen <- function(Xtr_raw, meta_tr, det_rate=0.70, fdr_thresh=0.05) {
  n_input <- ncol(Xtr_raw)
  is_high <- meta_tr$TREAT1_clean == "high"
  is_low <- meta_tr$TREAT1_clean == "low"
  n_high <- sum(is_high); n_low <- sum(is_low)
  detected <- is.finite(Xtr_raw) & Xtr_raw > 0
  count_high <- colSums(detected[is_high, , drop=FALSE])
  count_low <- colSums(detected[is_low, , drop=FALSE])
  eligible <- count_high * 100 >= det_rate * 100 * n_high &
              count_low * 100 >= det_rate * 100 * n_low
  eligible_ids <- colnames(Xtr_raw)[eligible]
  base <- list(
    n_input=n_input, n_eligible=length(eligible_ids), n_tested=0L,
    n_bh_significant=0L, n_selected=0L, eligible=eligible,
    selected=character(), results=data.frame(), design_rank=NA_integer_,
    design_columns=NA_integer_, status="OK", reason=NA_character_
  )
  if (!length(eligible_ids)) {
    base$status <- "MODEL_NOT_FIT_NO_FEATURES"
    base$reason <- "No proteins passed fold-local 70% detection in both High and Low"
    return(base)
  }
  meta_model <- meta_tr
  meta_model$dose <- factor(meta_model$TREAT1_clean, levels=c("low", "high"))
  meta_model$environment <- factor(meta_model$Environment, levels=STRICT_ENV_LEVELS)
  if (nlevels(droplevels(meta_model$environment)) < 2L) {
    base$status <- "DISCOVERY_MODEL_NONESTIMABLE"
    base$reason <- "Environment has a single observed level in outer train"
    return(base)
  }
  design <- model.matrix(~0 + dose + environment, meta_model)
  colnames(design) <- make.names(colnames(design))
  base$design_rank <- qr(design)$rank
  base$design_columns <- ncol(design)
  if (qr(design)$rank != ncol(design)) {
    base$status <- "DISCOVERY_MODEL_NONESTIMABLE"
    base$reason <- "Environment-adjusted design is rank deficient"
    return(base)
  }
  expr <- t(Xtr_raw[, eligible_ids, drop=FALSE])
  expr[!is.finite(expr) | expr <= 0] <- NA_real_
  expr[is.finite(expr)] <- log2(expr[is.finite(expr)])
  contrast <- limma::makeContrasts(Long_vs_Short=dosehigh-doselow, levels=design)
  fit_result <- tryCatch({
    fit <- limma::lmFit(expr, design)
    fit <- limma::contrasts.fit(fit, contrast)
    fit <- limma::eBayes(fit, trend=TRUE, robust=TRUE)
    tab <- limma::topTable(fit, coef="Long_vs_Short", number=Inf,
                           sort.by="none", adjust.method="none")
    se <- abs(tab$logFC / tab$t)
    se[!is.finite(se)] <- NA_real_
    status <- ifelse(is.finite(tab$logFC) & is.finite(se) & is.finite(tab$P.Value),
                     "ESTIMABLE", "NON_ESTIMABLE")
    data.frame(
      PG.ProteinGroups=rownames(tab), log2fc_train=tab$logFC, SE=se,
      P_value=tab$P.Value,
      BH_FDR=p.adjust(tab$P.Value, method="BH", n=length(eligible_ids)),
      AveExpr=tab$AveExpr, residual_df=fit$df.residual,
      Model_status=status, stringsAsFactors=FALSE
    )
  }, error=function(e) e)
  if (inherits(fit_result, "error")) {
    base$status <- "DISCOVERY_MODEL_NONESTIMABLE"
    base$reason <- conditionMessage(fit_result)
    return(base)
  }
  base$results <- fit_result
  base$n_tested <- sum(fit_result$Model_status == "ESTIMABLE")
  base$n_bh_significant <- sum(is.finite(fit_result$BH_FDR) & fit_result$BH_FDR < fdr_thresh)
  base$selected <- fit_result$PG.ProteinGroups[
    fit_result$Model_status == "ESTIMABLE" &
    is.finite(fit_result$BH_FDR) & fit_result$BH_FDR < fdr_thresh
  ]
  base$n_selected <- length(base$selected)
  base
}

make_stratified_foldid <- function(y, k=5L, seed) {
  foldid <- integer(length(y))
  set.seed(seed, kind="Mersenne-Twister")
  for (cls in c(0L, 1L)) {
    idx <- which(y == cls)
    foldid[idx] <- sample(rep(seq_len(k), length.out=length(idx)))
  }
  balance <- do.call(rbind, lapply(seq_len(k), function(f) {
    data.frame(Inner_fold=f, N=sum(foldid==f),
               N_High=sum(y[foldid==f]==1L), N_Low=sum(y[foldid==f]==0L))
  }))
  if (any(balance$N_High == 0L | balance$N_Low == 0L)) {
    stop("INNER_CV_CLASS_MISSING")
  }
  list(foldid=foldid, balance=balance)
}

fit_outer_preprocess <- function(Xtr) {
  med <- apply(Xtr, 2, median, na.rm=TRUE)
  if (any(!is.finite(med))) stop("Non-finite training median after fold-local eligibility")
  Ximp <- Xtr
  for (j in seq_len(ncol(Ximp))) Ximp[is.na(Ximp[,j]),j] <- med[j]
  mu <- colMeans(Ximp)
  sd_ <- apply(Ximp, 2, sd)
  sd_[!is.finite(sd_)] <- 0
  list(median=med, center=mu, scale=sd_)
}

prepare_outer_ml_matrices <- function(Xtr_raw, Xte_raw) {
  to_log2 <- function(x) {
    x[!is.finite(x) | x <= 0] <- NA_real_
    x[is.finite(x)] <- log2(x[is.finite(x)])
    x
  }
  Xtr_log2 <- to_log2(Xtr_raw)
  Xte_log2 <- to_log2(Xte_raw)
  pp <- fit_outer_preprocess(Xtr_log2)
  Xtr <- Xtr_log2
  Xte <- Xte_log2
  for (j in seq_len(ncol(Xtr))) {
    Xtr[is.na(Xtr[,j]),j] <- pp$median[j]
    Xte[is.na(Xte[,j]),j] <- pp$median[j]
    Xtr[,j] <- (Xtr[,j]-pp$center[j]) / ifelse(pp$scale[j]==0,1,pp$scale[j])
    Xte[,j] <- (Xte[,j]-pp$center[j]) / ifelse(pp$scale[j]==0,1,pp$scale[j])
  }
  list(train=Xtr, test=Xte, pp=pp)
}

strict_auprc <- function(ytrue, ypred) {
  ord <- order(ypred, decreasing=TRUE)
  ys <- ytrue[ord]
  tp <- cumsum(ys == 1L); fp <- cumsum(ys == 0L)
  precision <- c(1, tp/(tp+fp))
  recall <- c(0, tp/sum(ytrue == 1L))
  sum(diff(recall) * (head(precision,-1) + tail(precision,-1))/2)
}
