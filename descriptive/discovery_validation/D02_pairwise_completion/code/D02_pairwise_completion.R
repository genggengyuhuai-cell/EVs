#!/usr/bin/env Rscript
# D02 pairwise completion: Overall Low-vs-Control and High-vs-Control on the
# SAME frozen Discovery 386 / D01 1445 framework. Does NOT overwrite frozen D02.

here <- dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])))
stage_dir <- normalizePath(file.path(here, ".."), winslash="/")
dv_code <- normalizePath(file.path(here, "..", "..", "code"), winslash="/")
source(file.path(dv_code, "dv_shared.R"))
dv_require(c("limma","statmod","digest"))

outdir <- stage_dir
res_dir <- file.path(outdir, "results")
diag_dir <- file.path(outdir, "diagnostics")
dir.create(res_dir, recursive=TRUE, showWarnings=FALSE)
dir.create(diag_dir, recursive=TRUE, showWarnings=FALSE)

# ---- frozen inputs (same as D02) ----
d01 <- dv_stage_dir("D01_discovery_eligibility")
expr_file <- file.path(d01, "D01_discovery_eligible_expression.csv.gz")
prot_file <- file.path(d01, "D01_discovery_eligible_proteins.csv")
frozen_d02_file <- file.path(dv_stage_dir("D02_discovery_primary"), "D02_Long_vs_Short_all_tested.csv")

# gate hashes
dv_assert_hash(DV_ASSIGNMENT, DV_ASSIGNMENT_SHA256, "assignment")

meta <- dv_assignment("Discovery")
stopifnot(nrow(meta) == 386L)
grp <- table(meta$TREAT1_clean)
stopifnot(grp["control"] == 115L, grp["low"] == 139L, grp["high"] == 132L)

expr <- dv_read_expression(expr_file, meta$UniqueSampleID, raw=TRUE)
prot <- dv_read_csv(prot_file, "PG.ProteinGroups")
stopifnot(identical(rownames(expr), prot$PG.ProteinGroups))
stopifnot(nrow(expr) == 1445L)

design <- dv_design(meta)
if (attr(design,"rank") != ncol(design)) dv_stop("design not full rank")
message("Design columns: ", paste(colnames(design), collapse=","))

# ---- fit all three contrasts (same as dv_three_contrasts) ----
ct <- dv_three_contrasts(design)
all_res <- dv_fit(expr, design, ct, family_n=nrow(expr))
all_res <- dv_add_annotation(all_res)

# ---- per-contrast authoritative BH over ESTIMABLE only ----
all_res$BH_FDR <- NA_real_
for (cc in unique(all_res$Contrast)) {
  idx <- all_res$Contrast == cc
  est <- idx & (all_res$Model_status == "ESTIMABLE")
  all_res$BH_FDR[est] <- p.adjust(all_res$P_value[est], method="BH")
}

# ---- consistency check: Long_vs_Short vs frozen D02 ----
frozen <- dv_read_csv(frozen_d02_file, "PG.ProteinGroups")
frozen_hvl <- frozen[frozen$Contrast == "Long_vs_Short", c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
new_hvl <- all_res[all_res$Contrast == "Long_vs_Short", c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
mm <- merge(frozen_hvl, new_hvl, by="PG.ProteinGroups", suffixes=c("_frozen","_new"))
stopifnot(nrow(mm) == 1445L)
max_diff_logfc <- max(abs(mm$log2FC_frozen - mm$log2FC_new), na.rm=TRUE)
max_diff_p <- max(abs(mm$P_value_frozen - mm$P_value_new), na.rm=TRUE)
message("Long_vs_Short consistency: max|dlog2FC|=", signif(max_diff_logfc,4),
        " max|dP|=", signif(max_diff_p,4))
if (max_diff_logfc > 1e-6 || max_diff_p > 1e-12) dv_stop("Long_vs_Short mismatch with frozen D02")

# ---- extract new contrasts ----
extract <- function(cc, tag) {
  z <- all_res[all_res$Contrast == cc, ]
  z$N_parent <- 1445L
  z$N_estimable <- sum(z$Model_status == "ESTIMABLE")
  z$N_non_estimable <- sum(z$Model_status != "ESTIMABLE")
  dv_write(z, file.path(res_dir, paste0("overall_", tag, "_all_tested.csv")))
  disc <- z[z$Model_status == "ESTIMABLE" & z$BH_FDR < 0.05, ]
  disc <- disc[order(disc$BH_FDR), ]
  dv_write(disc, file.path(res_dir, paste0("overall_", tag, "_discoveries.csv")))
  z
}
lvc <- extract("Short_vs_Control", "low_vs_control")
hvc <- extract("Long_vs_Control", "high_vs_control")

# ---- summary ----
summ <- do.call(rbind, lapply(list(lvc, hvc), function(z) {
  est <- z[z$Model_status=="ESTIMABLE",]
  data.frame(
    Contrast=z$Contrast[1],
    N_parent=1445L,
    N_estimable=nrow(est),
    N_non_estimable=nrow(z)-nrow(est),
    N_raw_P_lt_0.05=sum(est$P_value<0.05),
    N_BH_FDR_lt_0.05=sum(est$BH_FDR<0.05),
    N_positive=sum(est$log2FC>0),
    N_negative=sum(est$log2FC<0),
    median_log2FC=median(est$log2FC),
    median_abs_log2FC=median(abs(est$log2FC)),
    median_SE=median(est$SE),
    median_CI_width=median(est$CI_high-est$CI_low)
  )
}))
dv_write(summ, file.path(res_dir, "overall_pairwise_summary.csv"))

# ---- frozen 85 reconciliation ----
lock <- dv_read_csv(file.path(dv_stage_dir("D03_candidate_lock"), "D03_locked_candidates.csv"), "PG.ProteinGroups")
frozen85 <- lock$PG.ProteinGroups
rec <- data.frame(PG.ProteinGroups=frozen85, stringsAsFactors=FALSE)
ann <- dv_annotation(frozen85)
rec <- merge(rec, ann[, c("PG.ProteinGroups","Gene_symbol","Display_label")], by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)

grab <- function(df, cc) {
  z <- df[df$Contrast==cc & df$PG.ProteinGroups %in% frozen85,
          c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
  z
}
lvc85 <- grab(lvc, "Short_vs_Control"); names(lvc85)[-1] <- paste0("LVC_", names(lvc85)[-1])
hvc85 <- grab(hvc, "Long_vs_Control"); names(hvc85)[-1] <- paste0("HVC_", names(hvc85)[-1])
hvl85 <- frozen[frozen$Contrast=="Long_vs_Short" & frozen$PG.ProteinGroups %in% frozen85,
                c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
names(hvl85)[-1] <- paste0("Frozen_HvL_", names(hvl85)[-1])
# Exposure vs Control from Phase 3
oec <- dv_read_csv(file.path(DV_ROOT, "descriptive", "environment_stratified_discovery",
                              "results", "exposure_vs_control",
                              "overall_exposure_vs_control_all_tested.csv"),
                    "PG.ProteinGroups")
oec85 <- oec[oec$PG.ProteinGroups %in% frozen85, c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
names(oec85)[-1] <- paste0("EC_", names(oec85)[-1])

rec <- merge(rec, lvc85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec <- merge(rec, hvc85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec <- merge(rec, hvl85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec <- merge(rec, oec85, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)

# descriptive trajectory classification
classify <- function(l, h) {
  if (is.na(l) || is.na(h)) return("other/unclear")
  if (sign(l) == sign(h) && abs(l) > 0.1 && abs(h) > 0.1) {
    if (abs(h) > abs(l) * 1.2) return("Control_to_Low_to_High_same_direction")
    if (abs(h) < abs(l) * 0.8) return("Low_and_High_opposite")
    return("Low_shift_then_plateau")
  }
  if (abs(l) < 0.1 && abs(h) > 0.1) return("High_only_shift")
  if (sign(l) == -sign(h)) return("Low_and_High_opposite")
  "other/unclear"
}
rec$trajectory_descriptor <- vapply(seq_len(nrow(rec)), function(i)
  classify(rec$LVC_log2FC[i], rec$HVC_log2FC[i]), character(1))
dv_write(rec, file.path(res_dir, "frozen85_overall_pairwise_reconciliation.csv"))

# ---- overlap with environment results ----
lvc_sig <- lvc$PG.ProteinGroups[lvc$Model_status=="ESTIMABLE" & lvc$BH_FDR<0.05]
hvc_sig <- hvc$PG.ProteinGroups[hvc$Model_status=="ESTIMABLE" & hvc$BH_FDR<0.05]
ha_hvc <- read.csv(file.path(DV_ROOT, "descriptive", "environment_stratified_discovery",
                             "results", "comparison", "HA_Long_vs_Control_75_supportive.csv"),
                   stringsAsFactors=FALSE)
ha_hvc_ids <- ha_hvc$PG.ProteinGroups
ha_ec <- read.csv(file.path(DV_ROOT, "descriptive", "environment_stratified_discovery",
                            "results", "exposure_vs_control",
                            "high_altitude_exposure_vs_control_discoveries.csv"),
                  stringsAsFactors=FALSE)
ha_ec_ids <- ha_ec$PG.ProteinGroups

ov <- data.frame(
  comparison=c(
    "Overall_LVC_vs_Frozen_HvL_85",
    "Overall_HVC_vs_Frozen_HvL_85",
    "Overall_LVC_vs_HA_HvC_75",
    "Overall_HVC_vs_HA_HvC_75",
    "Overall_LVC_vs_HA_EC_7",
    "Overall_HVC_vs_HA_EC_7",
    "HA_EC_7_in_Overall_LVC",
    "HA_EC_7_in_Overall_HVC",
    "HA_EC_7_in_Frozen_HvL_85"
  ),
  intersection=c(
    length(intersect(lvc_sig, frozen85)),
    length(intersect(hvc_sig, frozen85)),
    length(intersect(lvc_sig, ha_hvc_ids)),
    length(intersect(hvc_sig, ha_hvc_ids)),
    length(intersect(lvc_sig, ha_ec_ids)),
    length(intersect(hvc_sig, ha_ec_ids)),
    length(intersect(ha_ec_ids, lvc_sig)),
    length(intersect(ha_ec_ids, hvc_sig)),
    length(intersect(ha_ec_ids, frozen85))
  ),
  set_A_size=c(length(lvc_sig), length(hvc_sig), length(lvc_sig), length(hvc_sig),
               length(lvc_sig), length(hvc_sig), length(ha_ec_ids), length(ha_ec_ids), length(ha_ec_ids)),
  set_B_size=c(length(frozen85), length(frozen85), length(ha_hvc_ids), length(ha_hvc_ids),
               length(ha_ec_ids), length(ha_ec_ids), length(lvc_sig), length(hvc_sig), length(frozen85))
)
dv_write(ov, file.path(res_dir, "HA75_HA7_overall_overlap.csv"))

# ---- diagnostics / hashes ----
diag <- data.frame(
  metric=c("Discovery_n","Control_n","Low_n","High_n","Universe_n",
           "design_rank","Long_vs_Short_consistency_max_dlog2FC",
           "Long_vs_Short_consistency_max_dP","model","ebayes"),
  value=c(386,115,139,132,1445,qr(design)$rank,
          signif(max_diff_logfc,6), signif(max_diff_p,6),
          "abundance ~ 0 + dose + environment","trend=TRUE; robust=TRUE")
)
dv_write(diag, file.path(diag_dir, "model_validation.csv"))

hash_df <- data.frame(
  kind=c("input","input","input","input"),
  path=c(expr_file, prot_file, DV_ASSIGNMENT, frozen_d02_file),
  sha256=c(dv_sha256(expr_file), dv_sha256(prot_file), dv_sha256(DV_ASSIGNMENT), dv_sha256(frozen_d02_file))
)
dv_write(hash_df, file.path(diag_dir, "input_hashes.csv"))

message("PAIRWISE_DONE")
message("Overall LVC BH<0.05: ", length(lvc_sig))
message("Overall HVC BH<0.05: ", length(hvc_sig))
