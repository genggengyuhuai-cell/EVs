#!/usr/bin/env Rscript
# Contrast reconciliation: READ-ONLY. No model refit. No BH recompute.
# Aggregates existing frozen/current results into one master matrix.

here <- dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])))
branch <- normalizePath(file.path(here, ".."), winslash="/")
dv_code <- normalizePath(file.path(branch, "..", "discovery_validation", "code"), winslash="/")
source(file.path(dv_code, "dv_shared.R"))
dv_require(c("digest"))

out <- file.path(branch, "results", "contrast_reconciliation")
dir.create(out, recursive=TRUE, showWarnings=FALSE)

# ---- helpers ----
cnt_bh <- function(df, pcol="P_value", bhcol="BH_FDR") {
  est <- df[!is.na(df[[pcol]]) & df[[pcol]] != "", ]
  list(
    n_total=nrow(df),
    n_estimable=nrow(est),
    n_raw_lt_0.05=sum(as.numeric(est[[pcol]]) < 0.05, na.rm=TRUE),
    n_bh_lt_0.05=sum(as.numeric(est[[bhcol]]) < 0.05, na.rm=TRUE),
    n_positive=sum(as.numeric(est$log2FC) > 0, na.rm=TRUE),
    n_negative=sum(as.numeric(est$log2FC) < 0, na.rm=TRUE),
    median_log2FC=median(as.numeric(est$log2FC), na.rm=TRUE)
  )
}

# ---- 1. Overall Discovery (frozen D02, 386/1445) ----
d02_hvl <- dv_read_csv(file.path(DV_BASE, "D02_discovery_primary", "D02_Long_vs_Short_all_tested.csv"),
                       "PG.ProteinGroups")
# D02 only exported Long_vs_Short. Short/Long vs Control were NOT exported on this universe.

# ---- 2. M07 full-cohort Q515/1430/515 (different universe) ----
m07_lvc <- dv_read_csv(file.path(DV_ROOT, "descriptive", "analysis_v2.0", "M07_pairwise_contrasts", "M07_Low_vs_Control.csv"),
                       "PG.ProteinGroups")
m07_hvc <- dv_read_csv(file.path(DV_ROOT, "descriptive", "analysis_v2.0", "M07_pairwise_contrasts", "M07_High_vs_Control.csv"),
                       "PG.ProteinGroups")
m07_hvl <- dv_read_csv(file.path(DV_ROOT, "descriptive", "analysis_v2.0", "M07_pairwise_contrasts", "M07_High_vs_Low.csv"),
                       "PG.ProteinGroups")

# ---- 3. Phase 3 Overall Exposure vs Control (386/1445) ----
oec <- dv_read_csv(file.path(branch, "results", "exposure_vs_control", "overall_exposure_vs_control_all_tested.csv"),
                   "PG.ProteinGroups")

# ---- 4. Phase 1 HH/HA (Q_HH=1373, Q_HA=1394) ----
hh_all <- dv_read_csv(file.path(branch, "results", "humid_heat", "humid_heat_all_tested.csv"),
                      "PG.ProteinGroups")
ha_all <- dv_read_csv(file.path(branch, "results", "high_altitude", "high_altitude_all_tested.csv"),
                      "PG.ProteinGroups")

# ---- 5. Phase 3 HH/HA Exposure vs Control ----
hh_ec <- dv_read_csv(file.path(branch, "results", "exposure_vs_control", "humid_heat_exposure_vs_control_all_tested.csv"),
                     "PG.ProteinGroups")
ha_ec <- dv_read_csv(file.path(branch, "results", "exposure_vs_control", "high_altitude_exposure_vs_control_all_tested.csv"),
                     "PG.ProteinGroups")

# ---- master matrix ----
cell <- function(pop, contrast, source, file, n_samples, universe_n, estimable, raw05, bh05,
                 family, median_lfc, n_pos, n_neg, status) {
  data.frame(
    Population=pop, Contrast=contrast, Source_module=source, Source_file=file,
    N_samples=n_samples, Universe_N=universe_n, N_estimable=estimable,
    N_raw_P_lt_0.05=raw05, N_BH_FDR_lt_0.05=bh05, BH_family=family,
    Median_log2FC=median_lfc, N_positive=n_pos, N_negative=n_neg,
    Status=status, stringsAsFactors=FALSE
  )
}

c_d02 <- cnt_bh(d02_hvl)
c_oec <- cnt_bh(oec)
c_m07_lvc <- list(n_total=nrow(m07_lvc), n_estimable=nrow(m07_lvc),
                  n_raw_lt_0.05=sum(as.numeric(m07_lvc$P_raw)<0.05),
                  n_bh_lt_0.05=sum(as.numeric(m07_lvc$BH_FDR)<0.05),
                  n_positive=sum(as.numeric(m07_lvc$effect)>0),
                  n_negative=sum(as.numeric(m07_lvc$effect)<0),
                  median_log2FC=median(as.numeric(m07_lvc$effect)))
c_m07_hvc <- list(n_total=nrow(m07_hvc), n_estimable=nrow(m07_hvc),
                  n_raw_lt_0.05=sum(as.numeric(m07_hvc$P_raw)<0.05),
                  n_bh_lt_0.05=sum(as.numeric(m07_hvc$BH_FDR)<0.05),
                  n_positive=sum(as.numeric(m07_hvc$effect)>0),
                  n_negative=sum(as.numeric(m07_hvc$effect)<0),
                  median_log2FC=median(as.numeric(m07_hvc$effect)))
c_m07_hvl <- list(n_total=nrow(m07_hvl), n_estimable=nrow(m07_hvl),
                  n_raw_lt_0.05=sum(as.numeric(m07_hvl$P_raw)<0.05),
                  n_bh_lt_0.05=sum(as.numeric(m07_hvl$BH_FDR)<0.05),
                  n_positive=sum(as.numeric(m07_hvl$effect)>0),
                  n_negative=sum(as.numeric(m07_hvl$effect)<0),
                  median_log2FC=median(as.numeric(m07_hvl$effect)))

hh_by_ct <- split(hh_all, hh_all$Contrast)
ha_by_ct <- split(ha_all, ha_all$Contrast)

master <- rbind(
  # Overall Discovery (frozen 386/1445)
  cell("Overall_Discovery_386", "Low_vs_Control", "D02 (not exported)", "D02_Long_vs_Short_all_tested.csv",
       386, 1445, NA, NA, NA, "NA (not exported)", NA, NA, NA, "NOT_EXPORTED_FROM_D02"),
  cell("Overall_Discovery_386", "High_vs_Control", "D02 (not exported)", "D02_Long_vs_Short_all_tested.csv",
       386, 1445, NA, NA, NA, "NA (not exported)", NA, NA, NA, "NOT_EXPORTED_FROM_D02"),
  cell("Overall_Discovery_386", "High_vs_Low", "D02", "D02_Long_vs_Short_all_tested.csv",
       386, 1445, c_d02$n_estimable, c_d02$n_raw_lt_0.05, c_d02$n_bh_lt_0.05,
       "BH over 1445 D01-eligible", c_d02$median_log2FC, c_d02$n_positive, c_d02$n_negative, "FROZEN_PRIMARY"),
  cell("Overall_Discovery_386", "Exposure_vs_Control", "Phase3", "overall_exposure_vs_control_all_tested.csv",
       386, 1445, c_oec$n_estimable, c_oec$n_raw_lt_0.05, c_oec$n_bh_lt_0.05,
       "BH over 1445 D01-eligible", c_oec$median_log2FC, c_oec$n_positive, c_oec$n_negative, "PHASE3"),

  # M07 full-cohort (Q515/1430/515) — different universe, reference only
  cell("FullCohort_Q515_515_REF", "Low_vs_Control", "M07", "M07_Low_vs_Control.csv",
       515, 1430, c_m07_lvc$n_estimable, c_m07_lvc$n_raw_lt_0.05, c_m07_lvc$n_bh_lt_0.05,
       "BH over 1430 Q515", c_m07_lvc$median_log2FC, c_m07_lvc$n_positive, c_m07_lvc$n_negative, "REFERENCE_DIFF_UNIVERSE"),
  cell("FullCohort_Q515_515_REF", "High_vs_Control", "M07", "M07_High_vs_Control.csv",
       515, 1430, c_m07_hvc$n_estimable, c_m07_hvc$n_raw_lt_0.05, c_m07_hvc$n_bh_lt_0.05,
       "BH over 1430 Q515", c_m07_hvc$median_log2FC, c_m07_hvc$n_positive, c_m07_hvc$n_negative, "REFERENCE_DIFF_UNIVERSE"),
  cell("FullCohort_Q515_515_REF", "High_vs_Low", "M07", "M07_High_vs_Low.csv",
       515, 1430, c_m07_hvl$n_estimable, c_m07_hvl$n_raw_lt_0.05, c_m07_hvl$n_bh_lt_0.05,
       "BH over 1430 Q515", c_m07_hvl$median_log2FC, c_m07_hvl$n_positive, c_m07_hvl$n_negative, "REFERENCE_DIFF_UNIVERSE"),

  # HH (Phase 1, Q_HH=1373)
  cell("HumidHeat_Discovery_209", "Low_vs_Control", "Phase1", "humid_heat_all_tested.csv",
       209, 1373, cnt_bh(hh_by_ct[["Short_vs_Control"]])$n_estimable,
       cnt_bh(hh_by_ct[["Short_vs_Control"]])$n_raw_lt_0.05,
       cnt_bh(hh_by_ct[["Short_vs_Control"]])$n_bh_lt_0.05,
       "BH over 1373 Q_HH", cnt_bh(hh_by_ct[["Short_vs_Control"]])$median_log2FC,
       cnt_bh(hh_by_ct[["Short_vs_Control"]])$n_positive,
       cnt_bh(hh_by_ct[["Short_vs_Control"]])$n_negative, "PHASE1"),
  cell("HumidHeat_Discovery_209", "High_vs_Control", "Phase1", "humid_heat_all_tested.csv",
       209, 1373, cnt_bh(hh_by_ct[["Long_vs_Control"]])$n_estimable,
       cnt_bh(hh_by_ct[["Long_vs_Control"]])$n_raw_lt_0.05,
       cnt_bh(hh_by_ct[["Long_vs_Control"]])$n_bh_lt_0.05,
       "BH over 1373 Q_HH", cnt_bh(hh_by_ct[["Long_vs_Control"]])$median_log2FC,
       cnt_bh(hh_by_ct[["Long_vs_Control"]])$n_positive,
       cnt_bh(hh_by_ct[["Long_vs_Control"]])$n_negative, "PHASE1"),
  cell("HumidHeat_Discovery_209", "High_vs_Low", "Phase1", "humid_heat_all_tested.csv",
       209, 1373, cnt_bh(hh_by_ct[["Long_vs_Short"]])$n_estimable,
       cnt_bh(hh_by_ct[["Long_vs_Short"]])$n_raw_lt_0.05,
       cnt_bh(hh_by_ct[["Long_vs_Short"]])$n_bh_lt_0.05,
       "BH over 1373 Q_HH", cnt_bh(hh_by_ct[["Long_vs_Short"]])$median_log2FC,
       cnt_bh(hh_by_ct[["Long_vs_Short"]])$n_positive,
       cnt_bh(hh_by_ct[["Long_vs_Short"]])$n_negative, "PHASE1"),
  cell("HumidHeat_Discovery_209", "Exposure_vs_Control", "Phase3", "humid_heat_exposure_vs_control_all_tested.csv",
       209, 1373, cnt_bh(hh_ec)$n_estimable, cnt_bh(hh_ec)$n_raw_lt_0.05, cnt_bh(hh_ec)$n_bh_lt_0.05,
       "BH over 1373 Q_HH", cnt_bh(hh_ec)$median_log2FC, cnt_bh(hh_ec)$n_positive, cnt_bh(hh_ec)$n_negative, "PHASE3"),

  # HA (Phase 1, Q_HA=1394)
  cell("HighAltitude_Discovery_177", "Low_vs_Control", "Phase1", "high_altitude_all_tested.csv",
       177, 1394, cnt_bh(ha_by_ct[["Short_vs_Control"]])$n_estimable,
       cnt_bh(ha_by_ct[["Short_vs_Control"]])$n_raw_lt_0.05,
       cnt_bh(ha_by_ct[["Short_vs_Control"]])$n_bh_lt_0.05,
       "BH over 1394 Q_HA", cnt_bh(ha_by_ct[["Short_vs_Control"]])$median_log2FC,
       cnt_bh(ha_by_ct[["Short_vs_Control"]])$n_positive,
       cnt_bh(ha_by_ct[["Short_vs_Control"]])$n_negative, "PHASE1"),
  cell("HighAltitude_Discovery_177", "High_vs_Control", "Phase1", "high_altitude_all_tested.csv",
       177, 1394, cnt_bh(ha_by_ct[["Long_vs_Control"]])$n_estimable,
       cnt_bh(ha_by_ct[["Long_vs_Control"]])$n_raw_lt_0.05,
       cnt_bh(ha_by_ct[["Long_vs_Control"]])$n_bh_lt_0.05,
       "BH over 1394 Q_HA", cnt_bh(ha_by_ct[["Long_vs_Control"]])$median_log2FC,
       cnt_bh(ha_by_ct[["Long_vs_Control"]])$n_positive,
       cnt_bh(ha_by_ct[["Long_vs_Control"]])$n_negative, "PHASE1"),
  cell("HighAltitude_Discovery_177", "High_vs_Low", "Phase1", "high_altitude_all_tested.csv",
       177, 1394, cnt_bh(ha_by_ct[["Long_vs_Short"]])$n_estimable,
       cnt_bh(ha_by_ct[["Long_vs_Short"]])$n_raw_lt_0.05,
       cnt_bh(ha_by_ct[["Long_vs_Short"]])$n_bh_lt_0.05,
       "BH over 1394 Q_HA", cnt_bh(ha_by_ct[["Long_vs_Short"]])$median_log2FC,
       cnt_bh(ha_by_ct[["Long_vs_Short"]])$n_positive,
       cnt_bh(ha_by_ct[["Long_vs_Short"]])$n_negative, "PHASE1"),
  cell("HighAltitude_Discovery_177", "Exposure_vs_Control", "Phase3", "high_altitude_exposure_vs_control_all_tested.csv",
       177, 1394, cnt_bh(ha_ec)$n_estimable, cnt_bh(ha_ec)$n_raw_lt_0.05, cnt_bh(ha_ec)$n_bh_lt_0.05,
       "BH over 1394 Q_HA", cnt_bh(ha_ec)$median_log2FC, cnt_bh(ha_ec)$n_positive, cnt_bh(ha_ec)$n_negative, "PHASE3")
)
dv_write(master, file.path(out, "ALL_CONTRAST_MASTER_MATRIX.csv"))

# ---- overall summary ----
overall <- master[master$Population == "Overall_Discovery_386",
                  c("Contrast", "N_samples", "Universe_N", "N_BH_FDR_lt_0.05", "Status")]
dv_write(overall, file.path(out, "OVERALL_CONTRAST_SUMMARY.csv"))

# ---- significant set overlap ----
s85 <- d02_hvl$PG.ProteinGroups[as.numeric(d02_hvl$BH_FDR) < 0.05]
# Overall LVC/HVC on frozen 386/1445: NOT EXPORTED -> NA
# M07 LVC/HVC on Q515/1430: reference
m07_lvc_sig <- m07_lvc$PG.ProteinGroups[as.numeric(m07_lvc$BH_FDR) < 0.05]
m07_hvc_sig <- m07_hvc$PG.ProteinGroups[as.numeric(m07_hvc$BH_FDR) < 0.05]
ha_hvc_sig <- ha_by_ct[["Long_vs_Control"]]$PG.ProteinGroups[
  ha_by_ct[["Long_vs_Control"]]$Model_status == "ESTIMABLE" &
  as.numeric(ha_by_ct[["Long_vs_Control"]]$BH_FDR) < 0.05]
ha_ec_sig <- ha_ec$PG.ProteinGroups[
  ha_ec$Model_status == "ESTIMABLE" & as.numeric(ha_ec$BH_FDR) < 0.05]

ov <- data.frame(
  comparison=c(
    "Overall_HvL_85_vs_M07_LVC_13",
    "Overall_HvL_85_vs_M07_HVC_0",
    "HA_HvC_75_vs_HA_EC_7",
    "HA_EC_7_in_Overall_HvL_85",
    "HA_EC_7_in_M07_HVC_ref",
    "HA_EC_7_in_M07_LVC_ref",
    "HA_EC_7_in_HA_HvC_75"
  ),
  intersection=c(
    length(intersect(s85, m07_lvc_sig)),
    length(intersect(s85, m07_hvc_sig)),
    length(intersect(ha_hvc_sig, ha_ec_sig)),
    length(intersect(ha_ec_sig, s85)),
    length(intersect(ha_ec_sig, m07_hvc_sig)),
    length(intersect(ha_ec_sig, m07_lvc_sig)),
    length(intersect(ha_ec_sig, ha_hvc_sig))
  ),
  set_A_size=c(length(s85), length(s85), length(ha_hvc_sig), length(ha_ec_sig),
               length(ha_ec_sig), length(ha_ec_sig), length(ha_ec_sig)),
  set_B_size=c(length(m07_lvc_sig), length(m07_hvc_sig), length(ha_ec_sig), length(s85),
               length(m07_hvc_sig), length(m07_lvc_sig), length(ha_hvc_sig))
)
dv_write(ov, file.path(out, "SIGNIFICANT_SET_OVERLAP.csv"))

# ---- frozen 85 all-contrast reconciliation ----
rec <- data.frame(PG.ProteinGroups=s85, stringsAsFactors=FALSE)
ann <- dv_annotation(s85)
rec <- merge(rec, ann[, c("PG.ProteinGroups","Gene_symbol","Display_label")], by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)

# Overall D02 HvL
d02_small <- d02_hvl[, c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
names(d02_small)[-1] <- paste0("Overall_HvL_", names(d02_small)[-1])
rec <- merge(rec, d02_small, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)

# Overall Exposure vs Control (Phase 3)
oec_small <- oec[, c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
names(oec_small)[-1] <- paste0("Overall_EC_", names(oec_small)[-1])
rec <- merge(rec, oec_small, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)

# HH/HA per contrast
for (env in c("HH","HA")) {
  z <- if(env=="HH") hh_all else ha_all
  for (ct in c("Short_vs_Control","Long_vs_Control","Long_vs_Short")) {
    zz <- z[z$Contrast==ct, c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
    tag <- paste0(env, "_", if(ct=="Short_vs_Control")"LVC" else if(ct=="Long_vs_Control")"HVC" else "HvL")
    names(zz)[-1] <- paste0(tag, "_", names(zz)[-1])
    rec <- merge(rec, zz, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
  }
  ec <- if(env=="HH") hh_ec else ha_ec
  ecs <- ec[, c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
  names(ecs)[-1] <- paste0(env, "_EC_", names(ecs)[-1])
  rec <- merge(rec, ecs, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
}
dv_write(rec, file.path(out, "FROZEN85_ALL_CONTRAST_RECONCILIATION.csv"))

# ---- HA 75 / HA 7 reconciliation ----
ha75 <- ha_hvc_sig
ha7 <- ha_ec_sig
r75 <- data.frame(PG.ProteinGroups=ha75, stringsAsFactors=FALSE)
r75 <- merge(r75, ann[, c("PG.ProteinGroups","Gene_symbol")], by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
r75$in_HA_EC_7 <- r75$PG.ProteinGroups %in% ha7
r75$in_frozen85 <- r75$PG.ProteinGroups %in% s85
# HA LVC direction
ha_lvc <- ha_by_ct[["Short_vs_Control"]]
r75 <- merge(r75, ha_lvc[, c("PG.ProteinGroups","log2FC")], by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
names(r75)[names(r75)=="log2FC"] <- "HA_LVC_log2FC"
# HA HvL direction
ha_hvl <- ha_by_ct[["Long_vs_Short"]]
r75 <- merge(r75, ha_hvl[, c("PG.ProteinGroups","log2FC")], by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
names(r75)[names(r75)=="log2FC"] <- "HA_HvL_log2FC"
dv_write(r75, file.path(out, "HA75_HA7_RECONCILIATION.csv"))

message("RECON_DONE")
message("Overall D02 HvL: ", length(s85))
message("M07 LVC (Q515 ref): ", length(m07_lvc_sig))
message("M07 HVC (Q515 ref): ", length(m07_hvc_sig))
message("HA HvC 75: ", length(ha_hvc_sig))
message("HA EC 7: ", length(ha_ec_sig))
message("HA EC 7 in HA HvC 75: ", length(intersect(ha_ec_sig, ha_hvc_sig)))
message("HA EC 7 in frozen85: ", length(intersect(ha_ec_sig, s85)))
