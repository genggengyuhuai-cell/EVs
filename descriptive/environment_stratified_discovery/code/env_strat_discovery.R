#!/usr/bin/env Rscript
# Environment-stratified de novo differential discovery (Phase 1, Discovery-only).
# Does NOT touch Validation, hold-out, or frozen v2.1 outputs.

here <- dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))])))
branch <- normalizePath(file.path(here, ".."), winslash="/")
dv_code <- normalizePath(file.path(branch, "..", "discovery_validation", "code"), winslash="/")
source(file.path(dv_code, "dv_shared.R"))
dv_require(c("limma", "statmod", "digest"))

# ---- paths ----
elig_path <- file.path(branch, "results", "environment_eligibility_all_1445.csv")
expr_path <- file.path(DV_BASE, "D01_discovery_eligibility", "D01_discovery_eligible_expression.csv.gz")
lock_path <- file.path(DV_BASE, "D03_candidate_lock", "D03_locked_candidates.csv")

# ---- read meta (Discovery only) ----
meta <- dv_assignment("Discovery")
stopifnot(nrow(meta) == 386L)

# ---- read eligibility ----
elig <- dv_read_csv(elig_path, c("PG.ProteinGroups", "hh_eligible", "ha_eligible"))
q_hh <- elig$PG.ProteinGroups[as.logical(elig$hh_eligible)]
q_ha <- elig$PG.ProteinGroups[as.logical(elig$ha_eligible)]
message("N_Q_HH=", length(q_hh), " N_Q_HA=", length(q_ha))

# ---- read D01 eligible expression (log2) ----
disc_ids <- meta$UniqueSampleID
expr_all <- dv_read_expression(expr_path, disc_ids, raw=TRUE)
stopifnot(ncol(expr_all) == 386L, nrow(expr_all) == 1445L)

# ---- per-environment fit ----
fit_env <- function(env_label, qset) {
  keep <- meta$Environment == env_label
  m <- droplevels(meta[keep, , drop=FALSE])
  m$dose <- factor(m$TREAT1_clean, levels=DV_DOSE)
  x <- expr_all[qset, keep, drop=FALSE]
  d <- model.matrix(~0+dose, m); colnames(d) <- make.names(colnames(d))
  if (qr(d)$rank != ncol(d)) stop("rank-deficient design for ", env_label)
  ct <- dv_three_contrasts(d)
  z <- dv_fit(x, d, ct, family_n=nrow(x))
  # authoritative single BH: only ESTIMABLE P-values, per contrast
  z$BH_FDR <- NA_real_
  est <- z$Model_status == "ESTIMABLE"
  # per-contrast BH family
  for (cc in unique(z$Contrast)) {
    idx <- z$Contrast == cc
    e <- idx & est
    z$BH_FDR[e] <- p.adjust(z$P_value[e], method="BH")
  }
  # per-contrast denominators
  n_env <- nrow(x)
  z$N_parent <- 1445L
  z$N_environment_eligible <- n_env
  z$N_estimable <- as.integer(ave(est, z$Contrast, FUN=sum))
  z$N_non_estimable <- n_env - z$N_estimable
  z$Environment <- env_label
  z <- dv_add_annotation(z)
  z
}

res_hh <- fit_env("Humid-hot", q_hh)
res_ha <- fit_env("High-pressure/high-altitude", q_ha)

write_env <- function(z, outdir, env_tag) {
  dir.create(outdir, recursive=TRUE, showWarnings=FALSE)
  dv_write(z, file.path(outdir, paste0(env_tag, "_all_tested.csv")))
  disc <- z[z$Contrast == "Long_vs_Short" & z$Model_status == "ESTIMABLE" & z$BH_FDR < 0.05, ]
  disc <- disc[order(disc$BH_FDR), ]
  dv_write(disc, file.path(outdir, paste0(env_tag, "_discoveries.csv")))
  invisible(disc)
}

dir.create(file.path(branch, "results", "humid_heat"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(branch, "results", "high_altitude"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(branch, "results", "comparison"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(branch, "diagnostics"), recursive=TRUE, showWarnings=FALSE)
dir.create(file.path(branch, "manifest"), recursive=TRUE, showWarnings=FALSE)

disc_hh <- write_env(res_hh, file.path(branch, "results", "humid_heat"), "humid_heat")
disc_ha <- write_env(res_ha, file.path(branch, "results", "high_altitude"), "high_altitude")

# ---- family summary ----
fam <- do.call(rbind, lapply(split(rbind(res_hh, res_ha),
  list(rbind(res_hh, res_ha)$Environment, rbind(res_hh, res_ha)$Contrast)), function(z) {
    data.frame(
      Environment=z$Environment[1], Contrast=z$Contrast[1],
      N_parent=z$N_parent[1], N_environment_eligible=z$N_environment_eligible[1],
      N_estimable=z$N_estimable[1], N_non_estimable=z$N_non_estimable[1],
      N_raw_P_lt_0.05=sum(z$Model_status=="ESTIMABLE" & z$P_value < 0.05, na.rm=TRUE),
      N_BH_FDR_lt_0.05=sum(z$Model_status=="ESTIMABLE" & z$BH_FDR < 0.05, na.rm=TRUE),
      median_SE=median(z$SE[z$Model_status=="ESTIMABLE"], na.rm=TRUE),
      median_CI_width=median((z$CI_high - z$CI_low)[z$Model_status=="ESTIMABLE"], na.rm=TRUE),
      median_residual_df=median(z$residual_df[z$Model_status=="ESTIMABLE"], na.rm=TRUE)
    )
}))
dv_write(fam, file.path(branch, "diagnostics", "model_family_summary.csv"))

# ---- discovery set overlap (primary Long_vs_Short only) ----
hh_ids <- disc_hh$PG.ProteinGroups
ha_ids <- disc_ha$PG.ProteinGroups
overlap <- data.frame(
  metric=c("N_HH_discovered", "N_HA_discovered", "N_shared_discovered",
           "N_HH_only_discovered", "N_HA_only_discovered"),
  value=c(length(hh_ids), length(ha_ids),
          length(intersect(hh_ids, ha_ids)),
          length(setdiff(hh_ids, ha_ids)),
          length(setdiff(ha_ids, hh_ids)))
)
dv_write(overlap, file.path(branch, "results", "comparison", "discovery_set_overlap.csv"))

# ---- frozen 85 overlap ----
lock <- dv_read_csv(lock_path, "PG.ProteinGroups")
frozen85 <- lock$PG.ProteinGroups
overlap85 <- data.frame(
  metric=c("frozen85_N", "HH_discovery_in_frozen85", "HA_discovery_in_frozen85",
           "shared_env_discovery_in_frozen85"),
  value=c(length(frozen85),
          length(intersect(hh_ids, frozen85)),
          length(intersect(ha_ids, frozen85)),
          length(intersect(intersect(hh_ids, ha_ids), frozen85)))
)
dv_write(overlap85, file.path(branch, "results", "comparison", "frozen85_overlap_discovery_only.csv"))

# ---- discovery diagnostics (non-estimability) ----
diag <- do.call(rbind, lapply(split(rbind(res_hh, res_ha),
  list(rbind(res_hh, res_ha)$Environment, rbind(res_hh, res_ha)$Contrast)), function(z) {
    ne <- z[z$Model_status=="NON_ESTIMABLE", ]
    data.frame(
      Environment=z$Environment[1], Contrast=z$Contrast[1],
      N_non_estimable=nrow(ne),
      N_non_estimable_in_Q=z$N_non_estimable[1]
    )
}))
dv_write(diag, file.path(branch, "diagnostics", "discovery_diagnostics.csv"))

# ---- session info ----
sink(file.path(branch, "manifest", "session_info.txt"))
print(sessionInfo())
sink()

# ---- manifest ----
man <- dv_manifest("env_strat_discovery",
  c(elig_path, expr_path, lock_path, DV_ASSIGNMENT),
  c(
    file.path(branch, "results", "humid_heat", "humid_heat_all_tested.csv"),
    file.path(branch, "results", "humid_heat", "humid_heat_discoveries.csv"),
    file.path(branch, "results", "high_altitude", "high_altitude_all_tested.csv"),
    file.path(branch, "results", "high_altitude", "high_altitude_discoveries.csv"),
    file.path(branch, "results", "comparison", "discovery_set_overlap.csv"),
    file.path(branch, "results", "comparison", "frozen85_overlap_discovery_only.csv"),
    file.path(branch, "diagnostics", "model_family_summary.csv"),
    file.path(branch, "diagnostics", "discovery_diagnostics.csv")
  ),
  list(model="log2_abundance ~ 0 + dose", contrasts="Short_vs_Control,Long_vs_Control,Long_vs_Short",
       ebayes="trend=TRUE,robust=TRUE", BH="BH over ESTIMABLE P per Environment x Contrast")
)
dv_write(man, file.path(branch, "manifest", "analysis_manifest.csv"))

message("PHASE1_DISCOVERY_DONE")
message("HH discoveries (Long_vs_Short BH<0.05): ", length(hh_ids))
message("HA discoveries (Long_vs_Short BH<0.05): ", length(ha_ids))
