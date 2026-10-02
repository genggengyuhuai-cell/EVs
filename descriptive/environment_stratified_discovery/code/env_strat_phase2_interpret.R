#!/usr/bin/env Rscript
# Phase 2: interpretation, frozen-85 reconciliation, M10 join.
# Discovery-only. No hold-out. No new models.

here <- dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])))
branch <- normalizePath(file.path(here, ".."), winslash="/")
dv_code <- normalizePath(file.path(branch, "..", "discovery_validation", "code"), winslash="/")
source(file.path(dv_code, "dv_shared.R"))
dv_require(c("limma", "statmod", "digest"))

cmp_dir <- file.path(branch, "results", "comparison")
dir.create(cmp_dir, recursive=TRUE, showWarnings=FALSE)

# ---- inputs ----
d02 <- dv_read_csv(file.path(DV_BASE, "D02_discovery_primary", "D02_Long_vs_Short_all_tested.csv"),
                   c("PG.ProteinGroups","Contrast","log2FC","P_value","BH_FDR","SE","CI_low","CI_high"))
d02 <- d02[d02$Contrast == "Long_vs_Short", ]

lock <- dv_read_csv(file.path(DV_BASE, "D03_candidate_lock", "D03_locked_candidates.csv"), "PG.ProteinGroups")
frozen85 <- lock$PG.ProteinGroups
stopifnot(length(frozen85) == 85L, !anyDuplicated(frozen85))

hh <- dv_read_csv(file.path(branch, "results", "humid_heat", "humid_heat_all_tested.csv"),
                  c("PG.ProteinGroups","Contrast","log2FC","SE","P_value","BH_FDR","CI_low","CI_high","Model_status","Environment"))
ha <- dv_read_csv(file.path(branch, "results", "high_altitude", "high_altitude_all_tested.csv"),
                  c("PG.ProteinGroups","Contrast","log2FC","SE","P_value","BH_FDR","CI_low","CI_high","Model_status","Environment"))

m10 <- dv_read_csv(file.path(DV_ROOT, "descriptive", "analysis_v2.0", "M10_environment_interaction",
                             "corrected_pure_interaction", "M10_pure_interaction.csv"),
                   c("PG.ProteinGroups","E_Humid","E_HighAlt","interaction_F","interaction_P","interaction_BH","dir_concordant"))

# ---- Part 1: frozen-85 reconciliation for Long_vs_Short ----
pick <- function(df, env, contrast) {
  z <- df[df$Contrast == contrast, c("PG.ProteinGroups","log2FC","SE","CI_low","CI_high","P_value","BH_FDR","Model_status")]
  names(z)[-1] <- paste0(env, "_", names(z)[-1])
  z
}
hh_lv <- pick(hh, "HH", "Long_vs_Short")
ha_lv <- pick(ha, "HA", "Long_vs_Short")
d02m <- d02[, c("PG.ProteinGroups","log2FC","SE","CI_low","CI_high","P_value","BH_FDR","Gene_symbol","Display_label")]
names(d02m)[2:8] <- c("D02_pooled_log2FC","D02_pooled_SE","D02_CI_low","D02_CI_high","D02_P_value","D02_BH_FDR","D02_AveExpr")

rec <- data.frame(PG.ProteinGroups=frozen85, stringsAsFactors=FALSE)
rec <- merge(rec, d02m, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec <- merge(rec, hh_lv, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec <- merge(rec, ha_lv, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
rec <- merge(rec, m10[, c("PG.ProteinGroups","E_Humid","E_HighAlt","interaction_F","interaction_P","interaction_BH","dir_concordant")],
             by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
names(rec)[names(rec)=="E_Humid"] <- "M10_E_Humid"
names(rec)[names(rec)=="E_HighAlt"] <- "M10_E_HighAlt"
names(rec)[names(rec)=="interaction_F"] <- "M10_interaction_F"
names(rec)[names(rec)=="interaction_P"] <- "M10_interaction_P"
names(rec)[names(rec)=="interaction_BH"] <- "M10_interaction_BH_FDR"
names(rec)[names(rec)=="dir_concordant"] <- "M10_dir_concordant"

rec$HH_direction_vs_D02 <- sign(rec$HH_log2FC) == sign(rec$D02_pooled_log2FC)
rec$HA_direction_vs_D02 <- sign(rec$HA_log2FC) == sign(rec$D02_pooled_log2FC)
rec$HH_vs_HA_same_direction <- sign(rec$HH_log2FC) == sign(rec$HA_log2FC)
rec$M10_interaction_status <- ifelse(is.na(rec$M10_interaction_P), "NOT_IN_M10_UNIVERSE",
                              ifelse(rec$M10_interaction_BH_FDR < 0.05, "BH_SIGNIFICANT",
                              ifelse(rec$M10_interaction_P < 0.05, "NOMINAL_ONLY", "NS")))

dv_write(rec, file.path(cmp_dir, "frozen85_environment_effect_reconciliation.csv"))

# ---- Part 2: effect stability summary ----
ok <- complete.cases(rec[, c("D02_pooled_log2FC","HH_log2FC","HA_log2FC")])
stab <- data.frame(
  metric=c(
    "HH_vs_D02_Pearson", "HH_vs_D02_Spearman",
    "HA_vs_D02_Pearson", "HA_vs_D02_Spearman",
    "HH_vs_HA_Pearson", "HH_vs_HA_Spearman",
    "HH_same_sign_as_D02", "HA_same_sign_as_D02",
    "both_HH_HA_same_sign_as_D02", "HH_HA_same_sign_each_other",
    "median_abs_log2FC_D02", "median_abs_log2FC_HH", "median_abs_log2FC_HA",
    "median_SE_HH", "median_SE_HA",
    "N_frozen85"
  ),
  value=c(
    cor(rec$D02_pooled_log2FC[ok], rec$HH_log2FC[ok], method="pearson", use="complete.obs"),
    cor(rec$D02_pooled_log2FC[ok], rec$HH_log2FC[ok], method="spearman", use="complete.obs"),
    cor(rec$D02_pooled_log2FC[ok], rec$HA_log2FC[ok], method="pearson", use="complete.obs"),
    cor(rec$D02_pooled_log2FC[ok], rec$HA_log2FC[ok], method="spearman", use="complete.obs"),
    cor(rec$HH_log2FC[ok], rec$HA_log2FC[ok], method="pearson", use="complete.obs"),
    cor(rec$HH_log2FC[ok], rec$HA_log2FC[ok], method="spearman", use="complete.obs"),
    mean(rec$HH_direction_vs_D02, na.rm=TRUE),
    mean(rec$HA_direction_vs_D02, na.rm=TRUE),
    mean(rec$HH_direction_vs_D02 & rec$HA_direction_vs_D02, na.rm=TRUE),
    mean(rec$HH_vs_HA_same_direction, na.rm=TRUE),
    median(abs(rec$D02_pooled_log2FC), na.rm=TRUE),
    median(abs(rec$HH_log2FC), na.rm=TRUE),
    median(abs(rec$HA_log2FC), na.rm=TRUE),
    median(rec$HH_SE, na.rm=TRUE),
    median(rec$HA_SE, na.rm=TRUE),
    nrow(rec)
  )
)
dv_write(stab, file.path(cmp_dir, "frozen85_effect_stability_summary.csv"))

# ---- Part 3: M10 summary for 85 ----
m10_for_85 <- rec[!is.na(rec$M10_interaction_P), ]
m10_sum <- data.frame(
  metric=c("N_frozen85", "N_with_valid_M10", "N_M10_nominal_P_lt_0.05",
           "N_M10_BH_FDR_lt_0.05", "whole_universe_M10_BH_sig",
           "whole_universe_M10_N"),
  value=c(
    nrow(rec),
    nrow(m10_for_85),
    sum(m10_for_85$M10_interaction_P < 0.05, na.rm=TRUE),
    sum(m10_for_85$M10_interaction_BH_FDR < 0.05, na.rm=TRUE),
    sum(m10$interaction_BH < 0.05, na.rm=TRUE),
    nrow(m10)
  )
)
dv_write(m10_sum, file.path(cmp_dir, "frozen85_M10_interaction_summary.csv"))

# ---- Part 4: HA Long_vs_Control 75 supportive ----
ha_hc <- ha[ha$Contrast == "Long_vs_Control", ]
ha_hc_sig <- ha_hc[ha_hc$Model_status == "ESTIMABLE" & ha_hc$BH_FDR < 0.05, ]
hh_hc <- hh[hh$Contrast == "Long_vs_Control", c("PG.ProteinGroups","log2FC","P_value","BH_FDR")]
names(hh_hc)[-1] <- paste0("HH_Long_vs_Control_", names(hh_hc)[-1])

sup <- ha_hc_sig[, c("PG.ProteinGroups","Gene_symbol","Display_label","log2FC","SE","CI_low","CI_high","P_value","BH_FDR","AveExpr")]
names(sup)[4:10] <- paste0("HA_Long_vs_Control_", names(sup)[4:10])
sup <- merge(sup, hh_hc, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
sup$frozen85_member <- sup$PG.ProteinGroups %in% frozen85
sup <- merge(sup, m10[, c("PG.ProteinGroups","interaction_P","interaction_BH","dir_concordant")],
            by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
names(sup)[names(sup)=="interaction_P"] <- "M10_interaction_P"
names(sup)[names(sup)=="interaction_BH"] <- "M10_interaction_BH_FDR"
names(sup)[names(sup)=="dir_concordant"] <- "M10_dir_concordant"

# trajectory descriptor (descriptive only, based on already-fitted contrasts)
# Long_vs_Control and Short_vs_Control give means relative to Control=0.
hh_sc <- hh[hh$Contrast == "Short_vs_Control", c("PG.ProteinGroups","log2FC")]
names(hh_sc)[2] <- "HH_Short_vs_Control_log2FC"
ha_sc <- ha[ha$Contrast == "Short_vs_Control", c("PG.ProteinGroups","log2FC")]
names(ha_sc)[2] <- "HA_Short_vs_Control_log2FC"
sup <- merge(sup, ha_sc, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)

classify_trajectory <- function(low_eff, high_eff) {
  if (is.na(low_eff) || is.na(high_eff)) return("insufficient descriptive evidence")
  # Control = 0. low_eff = Low - Control; high_eff = High - Control.
  low_near0 <- abs(low_eff) < 0.2
  high_aligned <- sign(high_eff) == sign(low_eff) || low_near0
  if (low_near0 && !is.na(high_eff) && abs(high_eff) > 0.2) return("Long shifted vs Control, Low similar to Control")
  if (!low_near0 && sign(high_eff) == sign(low_eff) && abs(high_eff) > abs(low_eff)) return("Long shifted vs Control, Low intermediate")
  if (sign(high_eff) == -sign(low_eff) && abs(high_eff) > 0.2 && abs(low_eff) > 0.2) return("discordant/non-monotonic")
  if (abs(high_eff - low_eff) < 0.2) return("Low and Long similar")
  "insufficient descriptive evidence"
}
sup$HA_trajectory_descriptor <- vapply(seq_len(nrow(sup)), function(i)
  classify_trajectory(sup$HA_Short_vs_Control_log2FC[i], sup$HA_Long_vs_Control_log2FC[i]),
  character(1))

dv_write(sup, file.path(cmp_dir, "HA_Long_vs_Control_75_supportive.csv"))

# trajectory summary
traj_sum <- as.data.frame(table(sup$HA_trajectory_descriptor))
names(traj_sum) <- c("trajectory", "n")
dv_write(traj_sum, file.path(cmp_dir, "HA_Long_vs_Control_trajectory_summary.csv"))

# ---- Part 5: cross-environment effect comparison (all eligible) ----
cross_summary <- data.frame()
for (cc in c("Long_vs_Short","Long_vs_Control","Short_vs_Control")) {
  a <- hh[hh$Contrast == cc, c("PG.ProteinGroups","log2FC","P_value","BH_FDR","Model_status")]
  b <- ha[ha$Contrast == cc, c("PG.ProteinGroups","log2FC","P_value","BH_FDR","Model_status")]
  m <- merge(a, b, by="PG.ProteinGroups", suffixes=c("_HH","_HA"))
  m <- m[complete.cases(m[, c("log2FC_HH","log2FC_HA")]), ]
  cross_summary <- rbind(cross_summary, data.frame(
    Contrast=cc,
    N_compared=nrow(m),
    Pearson=cor(m$log2FC_HH, m$log2FC_HA, method="pearson"),
    Spearman=cor(m$log2FC_HH, m$log2FC_HA, method="spearman"),
    direction_concordance=mean(sign(m$log2FC_HH) == sign(m$log2FC_HA))
  ))
}
dv_write(cross_summary, file.path(cmp_dir, "allprotein_cross_environment_effect_summary.csv"))

message("PHASE2_DONE")
message("frozen85 rows: ", nrow(rec))
message("HA Long_vs_Control BH<0.05: ", nrow(ha_hc_sig))
message("M10 85 nominal<0.05: ", sum(m10_for_85$M10_interaction_P < 0.05, na.rm=TRUE))
message("M10 85 BH<0.05: ", sum(m10_for_85$M10_interaction_BH_FDR < 0.05, na.rm=TRUE))
