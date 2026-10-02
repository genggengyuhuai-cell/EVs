#!/usr/bin/env Rscript
# Phase 3: Exposure (Low+High) vs Control binary contrast.
# Discovery-only. No hold-out. No re-eligibility.

here <- dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])))
branch <- normalizePath(file.path(here, ".."), winslash="/")
dv_code <- normalizePath(file.path(branch, "..", "discovery_validation", "code"), winslash="/")
source(file.path(dv_code, "dv_shared.R"))
dv_require(c("limma", "statmod", "digest"))

out_dir <- file.path(branch, "results", "exposure_vs_control")
dir.create(out_dir, recursive=TRUE, showWarnings=FALSE)
cmp_dir <- file.path(branch, "results", "comparison")

# ---- meta ----
meta <- dv_assignment("Discovery")
stopifnot(nrow(meta) == 386L)
meta$ExposureGroup <- ifelse(meta$TREAT1_clean == "control", "Control", "Exposure")
meta$ExposureGroup <- factor(meta$ExposureGroup, levels=c("Control","Exposure"))

# gate sample counts
cnt <- table(meta$ExposureGroup, meta$Environment)
stopifnot(cnt["Control","Humid-hot"] == 71L)
stopifnot(cnt["Exposure","Humid-hot"] == 138L)
stopifnot(cnt["Control","High-pressure/high-altitude"] == 44L)
stopifnot(cnt["Exposure","High-pressure/high-altitude"] == 133L)
stopifnot(sum(meta$ExposureGroup=="Control") == 115L)
stopifnot(sum(meta$ExposureGroup=="Exposure") == 271L)

# ---- eligibility universe ----
elig <- dv_read_csv(file.path(branch, "results", "environment_eligibility_all_1445.csv"),
                    c("PG.ProteinGroups","hh_eligible","ha_eligible"))
q_hh <- elig$PG.ProteinGroups[as.logical(elig$hh_eligible)]
q_ha <- elig$PG.ProteinGroups[as.logical(elig$ha_eligible)]
q_all <- elig$PG.ProteinGroups
stopifnot(length(q_all) == 1445L, length(q_hh) == 1373L, length(q_ha) == 1394L)

# ---- expression (log2) ----
expr_all <- dv_read_expression(
  file.path(DV_BASE, "D01_discovery_eligibility", "D01_discovery_eligible_expression.csv.gz"),
  meta$UniqueSampleID, raw=TRUE)
stopifnot(ncol(expr_all) == 386L, nrow(expr_all) == 1445L)

# ---- generic fit function for binary ExposureGroup ----
fit_ec <- function(ids, samples, design_formula, universe_label) {
  m <- meta[samples, , drop=FALSE]
  m$ExposureGroup <- factor(m$ExposureGroup, levels=c("Control","Exposure"))
  x <- expr_all[ids, samples, drop=FALSE]
  d <- model.matrix(design_formula, m)
  colnames(d) <- make.names(colnames(d))
  if (qr(d)$rank < ncol(d)) stop("rank-deficient design for ", universe_label)
  # contrast vector: Exposure - Control (binary factor coded 0+ with two levels)
  exposure_col <- grep("ExposureGroupExposure$", colnames(d), value=TRUE)
  control_col <- grep("ExposureGroupControl$", colnames(d), value=TRUE)
  if (length(exposure_col) != 1L || length(control_col) != 1L)
    stop("cannot resolve Exposure/Control columns: ", paste(colnames(d), collapse=","))
  ct <- matrix(0, nrow=ncol(d), ncol=1, dimnames=list(colnames(d), "Exposure_minus_Control"))
  ct[exposure_col, 1] <- 1
  ct[control_col, 1] <- -1
  fit <- limma::lmFit(x, d)
  fit <- limma::contrasts.fit(fit, ct)
  fit <- limma::eBayes(fit, trend=TRUE, robust=TRUE)
  z <- limma::topTable(fit, coef="Exposure_minus_Control", number=Inf, sort.by="none", adjust.method="none")
  se <- abs(z$logFC / z$t); se[!is.finite(se)] <- NA_real_
  status <- ifelse(is.finite(z$logFC) & is.finite(se) & is.finite(z$P.Value), "ESTIMABLE", "NON_ESTIMABLE")
  res <- data.frame(
    PG.ProteinGroups=rownames(z),
    Contrast="Exposure_vs_Control",
    log2FC=z$logFC, SE=se,
    CI_low=z$logFC - qnorm(.975)*se,
    CI_high=z$logFC + qnorm(.975)*se,
    P_value=z$P.Value,
    BH_FDR=NA_real_,
    AveExpr=z$AveExpr,
    residual_df=fit$df.residual,
    Model_status=status,
    Universe=universe_label,
    stringsAsFactors=FALSE
  )
  est <- status == "ESTIMABLE"
  res$BH_FDR[est] <- p.adjust(res$P_value[est], method="BH")
  res$N_universe <- length(ids)
  res$N_estimable <- sum(est)
  res$N_non_estimable <- sum(!est)
  res <- dv_add_annotation(res)
  res
}

# ---- Overall: ~0 + ExposureGroup + Environment ----
m_all <- meta
m_all$Environment <- factor(m_all$Environment, levels=DV_ENV)
overall <- fit_ec(q_all, meta$UniqueSampleID %in% m_all$UniqueSampleID,
                  ~0 + ExposureGroup + Environment, "OVERALL")

# ---- HH: ~0 + ExposureGroup ----
hh_keep <- meta$Environment == "Humid-hot"
hh <- fit_ec(q_hh, hh_keep, ~0 + ExposureGroup, "HH")

# ---- HA: ~0 + ExposureGroup ----
ha_keep <- meta$Environment == "High-pressure/high-altitude"
ha <- fit_ec(q_ha, ha_keep, ~0 + ExposureGroup, "HA")

# ---- write all_tested + discoveries ----
write_one <- function(res, tag) {
  dv_write(res, file.path(out_dir, paste0(tag, "_exposure_vs_control_all_tested.csv")))
  disc <- res[res$Model_status == "ESTIMABLE" & res$BH_FDR < 0.05, ]
  disc <- disc[order(disc$BH_FDR), ]
  dv_write(disc, file.path(out_dir, paste0(tag, "_exposure_vs_control_discoveries.csv")))
  disc
}
disc_o <- write_one(overall, "overall")
disc_hh <- write_one(hh, "humid_heat")
disc_ha <- write_one(ha, "high_altitude")

# ---- summary ----
summ <- do.call(rbind, lapply(list(overall, hh, ha), function(z) {
  est <- z[z$Model_status=="ESTIMABLE",]
  data.frame(
    Universe=z$Universe[1],
    N_Control=if(z$Universe[1]=="OVERALL") 115L else if(z$Universe[1]=="HH") 71L else 44L,
    N_Exposure=if(z$Universe[1]=="OVERALL") 271L else if(z$Universe[1]=="HH") 138L else 133L,
    Exposure_to_Control_ratio=NA_real_,
    N_universe=z$N_universe[1],
    N_estimable=z$N_estimable[1],
    N_non_estimable=z$N_non_estimable[1],
    N_raw_P_lt_0.05=sum(est$P_value < 0.05, na.rm=TRUE),
    N_BH_FDR_lt_0.05=sum(est$BH_FDR < 0.05, na.rm=TRUE),
    median_SE=median(est$SE, na.rm=TRUE),
    median_CI_width=median(est$CI_high - est$CI_low, na.rm=TRUE),
    median_residual_df=median(est$residual_df, na.rm=TRUE)
  )
}))
summ$Exposure_to_Control_ratio <- summ$N_Exposure / summ$N_Control
dv_write(summ, file.path(out_dir, "exposure_vs_control_summary.csv"))

# ---- cross-environment comparison (HH vs HA) ----
mm <- merge(hh[, c("PG.ProteinGroups","log2FC","P_value","BH_FDR","Model_status")],
            ha[, c("PG.ProteinGroups","log2FC","P_value","BH_FDR","Model_status")],
            by="PG.ProteinGroups", suffixes=c("_HH","_HA"))
mm_e <- mm[mm$Model_status_HH=="ESTIMABLE" & mm$Model_status_HA=="ESTIMABLE", ]
cross <- data.frame(
  Comparison="HH_vs_HA_Exposure_vs_Control",
  N_compared=nrow(mm_e),
  Pearson=cor(mm_e$log2FC_HH, mm_e$log2FC_HA, method="pearson"),
  Spearman=cor(mm_e$log2FC_HH, mm_e$log2FC_HA, method="spearman"),
  direction_concordance=mean(sign(mm_e$log2FC_HH) == sign(mm_e$log2FC_HA))
)
dv_write(cross, file.path(out_dir, "exposure_vs_control_cross_environment_comparison.csv"))

# ---- precision diagnostics (per group detection rate) ----
# detection rate by ExposureGroup within each universe (descriptive)
detect_by_group <- function(ids, samples, label) {
  m <- meta[samples, ]
  x <- expr_all[ids, samples, drop=FALSE]
  det <- is.finite(x) & x > 0  # raw positive; after log2 finite means detected
  data.frame(
    Universe=label,
    N_Control=sum(m$ExposureGroup=="Control"),
    N_Exposure=sum(m$ExposureGroup=="Exposure"),
    median_detection_rate_Control=mean(det[, m$ExposureGroup=="Control"]),
    median_detection_rate_Exposure=mean(det[, m$ExposureGroup=="Exposure"])
  )
}
prec <- rbind(
  detect_by_group(q_all, meta$Environment %in% DV_ENV, "OVERALL"),
  detect_by_group(q_hh, hh_keep, "HH"),
  detect_by_group(q_ha, ha_keep, "HA")
)
dv_write(prec, file.path(out_dir, "exposure_vs_control_precision_diagnostics.csv"))

# ---- frozen 85 reconciliation ----
lock <- dv_read_csv(file.path(DV_BASE, "D03_candidate_lock", "D03_locked_candidates.csv"), "PG.ProteinGroups")
frozen85 <- lock$PG.ProteinGroups
rec85 <- data.frame(PG.ProteinGroups=frozen85, stringsAsFactors=FALSE)
pick_ec <- function(df) df[df$PG.ProteinGroups %in% frozen85, c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
o85 <- pick_ec(overall); names(o85)[-1] <- c("Overall_EC_log2FC","Overall_EC_P","Overall_EC_BH_FDR")
h85 <- pick_ec(hh);      names(h85)[-1] <- c("HH_EC_log2FC","HH_EC_P","HH_EC_BH_FDR")
a85 <- pick_ec(ha);      names(a85)[-1] <- c("HA_EC_log2FC","HA_EC_P","HA_EC_BH_FDR")
rec85 <- merge(rec85, o85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec85 <- merge(rec85, h85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec85 <- merge(rec85, a85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
ann <- dv_annotation(frozen85)
rec85 <- merge(rec85, ann[, c("PG.ProteinGroups","Gene_symbol","Display_label")], by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec85$direction_concordant_Overall_HH_HA <-
  sign(rec85$Overall_EC_log2FC) == sign(rec85$HH_EC_log2FC) &
  sign(rec85$Overall_EC_log2FC) == sign(rec85$HA_EC_log2FC)
dv_write(rec85, file.path(cmp_dir, "frozen85_exposure_vs_control_reconciliation.csv"))

message("PHASE3_DONE")
message("Overall discoveries: ", nrow(disc_o))
message("HH discoveries: ", nrow(disc_hh))
message("HA discoveries: ", nrow(disc_ha))
