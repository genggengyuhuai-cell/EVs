# V2-02B — Sample Header Matching Bug Fix + Canonical Universe Rebuild
# Fix: positional column matching with clean_header() canonicalization
# Historical code uses POSITIONAL matching (Excel order = metadata order), not name matching.

library(readxl)
library(digest)

ROOT <- "F:/env"
OUT_DIR <- file.path(ROOT, "descriptive/analysis_v2.0")
UNIV_DIR <- file.path(OUT_DIR, "universes")
MANIFEST_DIR <- file.path(OUT_DIR, "manifests")
QC_DIR <- file.path(OUT_DIR, "qc")
dir.create(UNIV_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(MANIFEST_DIR, showWarnings=FALSE, recursive=TRUE)
dir.create(QC_DIR, showWarnings=FALSE, recursive=TRUE)

# ---- clean_header canonicalization (matches historical Python) ----
clean_header <- function(x) {
  x <- as.character(x)
  x <- trimws(x)
  x <- sub("\\.0$", "", x)
  x
}

# ---- Load U0 ----
cat("Loading U0...\n")
raw <- read_excel(file.path(ROOT, "rawdata/processed.xlsx"),
                  n_max=3817, .name_repair="minimal")
annot <- data.frame(
  PG.ProteinGroups = raw$PG.ProteinGroups,
  Gene_symbol = raw$PG.Genes,
  stringsAsFactors = FALSE
)
sample_cols_raw <- names(raw)[8:ncol(raw)]
sample_cols_clean <- clean_header(sample_cols_raw)
abundance <- as.data.frame(raw[, 8:ncol(raw)])
rownames(abundance) <- annot$PG.ProteinGroups

cat("U0 proteins:", nrow(annot), "\n")
cat("Sample columns:", length(sample_cols_clean), "\n")

# ---- Load sample_statistics.csv (historical 519-row, positional order) ----
ss <- read.csv(file.path(ROOT, "descriptive/sample_statistics.csv"),
               stringsAsFactors=FALSE)
ss$Sheet1_clean <- clean_header(ss$Sheet1_raw_header)
cat("sample_statistics rows:", nrow(ss), "\n")

# Positional verification
stopifnot(length(sample_cols_clean) == nrow(ss))
pos_match <- sample_cols_clean == ss$Sheet1_clean
if (!all(pos_match)) {
  bad <- which(!pos_match)
  cat("Positional mismatches (first 10):\n")
  for (b in head(bad, 10)) {
    cat(sprintf("  pos %d: excel='%s' vs meta='%s'\n", b, sample_cols_clean[b], ss$Sheet1_clean[b]))
  }
  stop("Positional header mismatch")
}
cat("POSITIONAL HEADER MATCH: PASS (519 columns match in order)\n")

# ---- Dose-defined samples by position ----
dose_mask <- ss$TREAT1_clean %in% c("control", "low", "high")
cat("Dose-defined samples:", sum(dose_mask), "\n")

ctrl_idx <- which(dose_mask & ss$TREAT1_clean == "control")
low_idx  <- which(dose_mask & ss$TREAT1_clean == "low")
high_idx <- which(dose_mask & ss$TREAT1_clean == "high")
n_ctrl <- length(ctrl_idx)
n_low  <- length(low_idx)
n_high <- length(high_idx)
cat(sprintf("Control=%d, Low=%d, High=%d, Total=%d\n", n_ctrl, n_low, n_high,
            n_ctrl+n_low+n_high))
stopifnot(n_ctrl==153, n_low==186, n_high==176)

# ---- Sample column map audit ----
map_df <- data.frame(
  Column_position = which(dose_mask),
  Canonical_sample_ID = ss$Sheet1_clean[dose_mask],
  Metadata_raw = ss$Sheet1_raw_header[dose_mask],
  Metadata_clean = ss$Sheet1_clean[dose_mask],
  Excel_col_raw = sample_cols_raw[dose_mask],
  Excel_col_clean = sample_cols_clean[dose_mask],
  TREAT1_clean = ss$TREAT1_clean[dose_mask],
  Match_status = "POSITIONAL_EXACT",
  Notes = ifelse(ss$Sheet1_raw_header[dose_mask] != ss$Sheet1_clean[dose_mask],
                  "cleaned from raw", ""),
  stringsAsFactors=FALSE
)
write.csv(map_df, file.path(QC_DIR, "V2_02B_SAMPLE_COLUMN_MAP.csv"),
          row.names=FALSE, fileEncoding="UTF-8")
n_affected <- sum(map_df$Notes != "")
cat("Affected samples (cleaned):", n_affected, "\n")
write.csv(map_df[map_df$Notes != "", ],
          file.path(QC_DIR, "V2_02B_HEADER_FIX_AUDIT.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ---- Detection function ----
is_detected <- function(x) is.finite(x) & x > 0

# ============================================================
# STEP 4: Historical parity gate on U0 (no Freeze 3)
# ============================================================
cat("\n===== HISTORICAL PARITY GATE (U0=3817) =====\n")
thr_ctrl <- ceiling(0.70 * n_ctrl)
thr_low  <- ceiling(0.70 * n_low)
thr_high <- ceiling(0.70 * n_high)
stopifnot(thr_ctrl==108, thr_low==131, thr_high==124)
cat("Thresholds: Control=", thr_ctrl, " Low=", thr_low, " High=", thr_high, "\n")

det_ctrl_u0 <- rowSums(is_detected(as.matrix(abundance[, ctrl_idx])))
det_low_u0  <- rowSums(is_detected(as.matrix(abundance[, low_idx])))
det_high_u0 <- rowSums(is_detected(as.matrix(abundance[, high_idx])))
q515_u0 <- (det_ctrl_u0 >= thr_ctrl) & (det_low_u0 >= thr_low) & (det_high_u0 >= thr_high)
cat("Reconstructed Q515 on U0:", sum(q515_u0), "\n")

hist <- read.csv(file.path(ROOT, "descriptive/dose_filter_membership.csv"),
                 stringsAsFactors=FALSE)
hist_set <- hist$PG.ProteinGroups[hist$all_doses_ge70pct=="True" | hist$all_doses_ge70pct==TRUE]
cat("Historical Q515:", length(hist_set), "\n")

recon_set <- annot$PG.ProteinGroups[q515_u0]
ov <- intersect(hist_set, recon_set)
ho <- setdiff(hist_set, recon_set)
ro <- setdiff(recon_set, hist_set)
cat("Overlap:", length(ov), " hist-only:", length(ho), " recon-only:", length(ro), "\n")
if (length(ho)!=0 || length(ro)!=0) {
  stop("PARITY FAILED")
}
cat("HISTORICAL PARITY: PASS (exact 1434)\n")

# ============================================================
# STEP 5: Freeze 3 verification
# ============================================================
cat("\n===== FREEZE 3 VERIFICATION =====\n")
f3 <- read.csv(file.path(OUT_DIR, "registry/contaminant_candidate_registry.csv"),
               stringsAsFactors=FALSE)
excl_pgs <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible=="TRUE"]
stopifnot(length(excl_pgs)==8)
in_hist <- excl_pgs %in% hist_set
cat("Exclusions in historical 1434:", sum(in_hist), "\n")
cat("Exclusions NOT in historical 1434:", sum(!in_hist), "\n")
stopifnot(sum(in_hist)==4, sum(!in_hist)==4)
expected_q515 <- 1434 - 4
cat("Expected canonical Q515:", expected_q515, "\n")

# ============================================================
# STEP 6: Canonical Q515 from Utech
# ============================================================
cat("\n===== CANONICAL Q515 =====\n")
utech_mask <- !annot$PG.ProteinGroups %in% excl_pgs
utech_n <- sum(utech_mask)
stopifnot(utech_n==3809)
cat("Utech_primary:", utech_n, "\n")

det_ctrl_ut <- det_ctrl_u0[utech_mask]
det_low_ut  <- det_low_u0[utech_mask]
det_high_ut <- det_high_u0[utech_mask]
q515_pass <- (det_ctrl_ut >= thr_ctrl) & (det_low_ut >= thr_low) & (det_high_ut >= thr_high)
q515_n <- sum(q515_pass)
cat("Canonical Q515:", q515_n, "\n")
stopifnot(q515_n==1430)
cat("Q515 GATE: PASS (1430)\n")

utech_annot <- annot[utech_mask, ]
q515_df <- data.frame(
  PG.ProteinGroups=utech_annot$PG.ProteinGroups,
  Gene_symbol=utech_annot$Gene_symbol,
  Display_label=utech_annot$Gene_symbol,
  N_detect_Control=det_ctrl_ut, N_Control=n_ctrl,
  Rate_Control=round(det_ctrl_ut/n_ctrl,4), Threshold_Control=thr_ctrl,
  N_detect_Low=det_low_ut, N_Low=n_low,
  Rate_Low=round(det_low_ut/n_low,4), Threshold_Low=thr_low,
  N_detect_High=det_high_ut, N_High=n_high,
  Rate_High=round(det_high_ut/n_high,4), Threshold_High=thr_high,
  Q515=q515_pass, stringsAsFactors=FALSE)
write.csv(q515_df, file.path(UNIV_DIR,"Q515_eligibility_all_Utech.csv"),
          row.names=FALSE, fileEncoding="UTF-8")
write.csv(q515_df[q515_pass,], file.path(UNIV_DIR,"Q515.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ============================================================
# STEP 7: D515
# ============================================================
cat("\n===== D515 =====\n")
all_idx <- c(ctrl_idx, low_idx, high_idx)
det_total <- rowSums(is_detected(as.matrix(abundance[, all_idx])))[utech_mask]
not_det_total <- length(all_idx) - det_total
d515_pass <- (det_total >= 10) & (not_det_total >= 10)
d515_n <- sum(d515_pass)
cat("Canonical D515:", d515_n, "\n")

d515_df <- data.frame(
  PG.ProteinGroups=utech_annot$PG.ProteinGroups,
  Gene_symbol=utech_annot$Gene_symbol,
  Display_label=utech_annot$Gene_symbol,
  N_detected=det_total, N_not_detected=not_det_total,
  N_total=length(all_idx),
  Detection_rate=round(det_total/length(all_idx),4),
  D515=d515_pass, stringsAsFactors=FALSE)
write.csv(d515_df, file.path(UNIV_DIR,"D515_eligibility_all_Utech.csv"),
          row.names=FALSE, fileEncoding="UTF-8")
write.csv(d515_df[d515_pass,], file.path(UNIV_DIR,"D515.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ============================================================
# STEP 8: Logical QA
# ============================================================
cat("\n===== LOGICAL QA =====\n")
min_total <- thr_ctrl + thr_low + thr_high
q515_det <- det_total[q515_pass]
q515_too_few <- sum(q515_det < min_total)
cat("Q515 with N_detected <", min_total, ":", q515_too_few, "\n")
stopifnot(q515_too_few==0)

both <- q515_pass & d515_pass
d515_only <- !q515_pass & d515_pass
q515_only <- q515_pass & !d515_pass
cat("Q515 ∩ D515:", sum(both), "\n")
cat("D515 only:", sum(d515_only), "\n")
cat("Q515 only:", sum(q515_only), "\n")

q515_only_nd <- not_det_total[q515_pass & !d515_pass]
q515_only_d <- det_total[q515_pass & !d515_pass]
fail_nd <- sum(q515_only_nd < 10)
fail_d <- sum(q515_only_d < 10)
cat("Q515-only due N_not_detected<10:", fail_nd, "\n")
cat("Q515-only due N_detected<10:", fail_d, "\n")
stopifnot(fail_d==0)
cat("LOGICAL QA: PASS\n")

# ============================================================
# STEP 9: Utech semantics fix
# ============================================================
cat("\n===== UTECH SEMANTICS FIX =====\n")
old_up <- file.path(UNIV_DIR, "Utech_primary.csv")
if (file.exists(old_up)) {
  file.rename(old_up, file.path(UNIV_DIR, "Utech_membership_all_U0.csv"))
}
write.csv(utech_annot, file.path(UNIV_DIR, "Utech_primary.csv"),
          row.names=FALSE, fileEncoding="UTF-8")
cat("Utech_primary.csv:", nrow(utech_annot), "rows (members only)\n")

excl_df <- data.frame(
  PG.ProteinGroups=excl_pgs,
  Gene_symbol=f3$Gene_symbol[match(excl_pgs, f3$PG.ProteinGroups)],
  Freeze3_category=f3$Project_category[match(excl_pgs, f3$PG.ProteinGroups)],
  Historical_Q515_member=excl_pgs %in% hist_set,
  stringsAsFactors=FALSE)
write.csv(excl_df, file.path(UNIV_DIR,"Utech_primary_exclusions.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

# ============================================================
# STEP 11: Master registry
# ============================================================
cat("\n===== MASTER REGISTRY =====\n")
master <- data.frame(
  PG.ProteinGroups=annot$PG.ProteinGroups,
  Gene_symbol=annot$Gene_symbol,
  Display_label=annot$Gene_symbol,
  U0=TRUE, stringsAsFactors=FALSE)
f3c <- f3$Project_category[match(master$PG.ProteinGroups, f3$PG.ProteinGroups)]
f3p <- f3$Primary_exclusion_eligible[match(master$PG.ProteinGroups, f3$PG.ProteinGroups)]
master$Freeze3_category <- ifelse(is.na(f3c), "NOT_CANDIDATE", f3c)
master$Primary_exclusion <- ifelse(is.na(f3p), "FALSE", f3p)
master$Utech_primary <- master$Primary_exclusion != "TRUE"

q515_map <- setNames(q515_df$Q515, q515_df$PG.ProteinGroups)
master$Q515 <- ifelse(master$Utech_primary, q515_map[master$PG.ProteinGroups], NA)
q515_fr <- rep(NA, nrow(master))
for (i in which(master$Utech_primary & !master$Q515)) {
  pg <- master$PG.ProteinGroups[i]
  row <- q515_df[q515_df$PG.ProteinGroups==pg,]
  r <- c()
  if (row$N_detect_Control < row$Threshold_Control) r <- c(r,"Control_below_threshold")
  if (row$N_detect_Low < row$Threshold_Low) r <- c(r,"Low_below_threshold")
  if (row$N_detect_High < row$Threshold_High) r <- c(r,"High_below_threshold")
  q515_fr[i] <- paste(r, collapse=";")
}
master$Q515_failure_reason <- ifelse(master$Utech_primary & !master$Q515, q515_fr,
                              ifelse(!master$Utech_primary, "FROZEN3_EXCLUDED", NA))

d515_map <- setNames(d515_df$D515, d515_df$PG.ProteinGroups)
master$D515 <- ifelse(master$Utech_primary, d515_map[master$PG.ProteinGroups], NA)
d515_fr <- rep(NA, nrow(master))
for (i in which(master$Utech_primary & !master$D515)) {
  pg <- master$PG.ProteinGroups[i]
  row <- d515_df[d515_df$PG.ProteinGroups==pg,]
  r <- c()
  if (row$N_detected < 10) r <- c(r,"N_detected_lt10")
  if (row$N_not_detected < 10) r <- c(r,"N_not_detected_lt10")
  d515_fr[i] <- paste(r, collapse=";")
}
master$D515_failure_reason <- ifelse(master$Utech_primary & !master$D515, d515_fr,
                              ifelse(!master$Utech_primary, "FROZEN3_EXCLUDED", NA))
master$Contact_flag <- grepl("A3", master$Freeze3_category) | grepl("SALIVARY", master$Freeze3_category)
master$Category_B_flag <- grepl("^B", master$Freeze3_category)
master$Category_C_flag <- master$Freeze3_category=="C"
write.csv(master, file.path(UNIV_DIR,"V2_universe_membership_master.csv"),
          row.names=FALSE, fileEncoding="UTF-8")
cat("Master:", nrow(master), "rows\n")

# ============================================================
# STEP 12: Manifest
# ============================================================
sha256_file <- function(p) digest(file=p, algo="sha256")
manifest <- data.frame(
  item=c("source_processed_xlsx","sample_statistics_csv","freeze3_registry_csv",
         "script","clean_header_spec","affected_samples_n","historical_parity",
         "U0_n","exclusion_n","Utech_n","Q515_n","D515_n","Q515_thresholds","timestamp"),
  value=c(sha256_file(file.path(ROOT,"rawdata/processed.xlsx")),
          sha256_file(file.path(ROOT,"descriptive/sample_statistics.csv")),
          sha256_file(file.path(OUT_DIR,"registry/contaminant_candidate_registry.csv")),
          sha256_file(file.path(OUT_DIR,"code/V2_02b_rebuild.R")),
          "trimws + remove trailing .0 (positional matching)",
          as.character(n_affected), "1434=1434 exact",
          "3817","8","3809",as.character(q515_n),as.character(d515_n),
          "108/131/124", format(Sys.time(),"%Y-%m-%d %H:%M:%S %Z")),
  stringsAsFactors=FALSE)
write.csv(manifest, file.path(MANIFEST_DIR,"V2_02B_universe_manifest.csv"),
          row.names=FALSE, fileEncoding="UTF-8")

cat("\n===== FINAL SUMMARY =====\n")
cat("Affected samples:", n_affected, "\n")
cat("Historical parity: 1434=1434 EXACT\n")
cat("U0:", nrow(annot), " Exclusions:", length(excl_pgs), " Utech:", utech_n, "\n")
cat("Q515:", q515_n, " D515:", d515_n, "\n")
cat("Q515∩D515:", sum(both), " D515-only:", sum(d515_only), " Q515-only:", sum(q515_only), "\n")
cat("Q515-only fail N_det<10:", fail_d, " fail N_ndet<10:", fail_nd, "\n")
cat("Done.\n")

