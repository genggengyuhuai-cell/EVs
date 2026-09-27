# V2-02 Build Universes: Utech_primary, Q515, D515
# Freeze 3 FROZEN. No inferential analysis.
# Output: descriptive/analysis_v2.0/universes/

library(readxl)
library(digest)

# ---- Config ----
ROOT <- "F:/env"
OUT_DIR <- file.path(ROOT, "descriptive/analysis_v2.0")
UNIV_DIR <- file.path(OUT_DIR, "universes")
MANIFEST_DIR <- file.path(OUT_DIR, "manifests")
QC_DIR <- file.path(OUT_DIR, "qc")
dir.create(UNIV_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(MANIFEST_DIR, showWarnings = FALSE, recursive = TRUE)
dir.create(QC_DIR, showWarnings = FALSE, recursive = TRUE)

# ---- No-overwrite guard ----
no_overwrite <- function(path) {
  if (file.exists(path)) {
    stop(paste0("NO-OVERWRITE: ", path, " already exists. Delete manually to regenerate."))
  }
}

# ---- Load U0 ----
cat("Loading U0 from processed.xlsx...\n")
raw <- read_excel(file.path(ROOT, "rawdata/processed.xlsx"),
                  n_max = 3817, .name_repair = "minimal")
annot <- data.frame(
  PG.ProteinGroups = raw$PG.ProteinGroups,
  Gene_symbol = raw$PG.Genes,
  Protein_descriptions = raw$PG.ProteinDescriptions,
  Protein_names = raw$PG.ProteinNames,
  stringsAsFactors = FALSE
)

# First 7 columns are annotation; rest are samples
sample_cols_all <- names(raw)[8:ncol(raw)]
abundance <- as.data.frame(raw[, 8:ncol(raw)])
rownames(abundance) <- annot$PG.ProteinGroups

cat("U0 proteins:", nrow(annot), "\n")
cat("Sample columns in data:", length(sample_cols_all), "\n")

# ---- Load sample metadata ----
meta <- read.csv(file.path(ROOT, "descriptive/dose_defined_metadata.csv"),
                 stringsAsFactors = FALSE)
cat("Metadata rows:", nrow(meta), "\n")

# Map TREAT1_clean to canonical v2 labels
# control -> Control, low -> Low, high -> High
meta$v2_group <- NA
meta$v2_group[meta$TREAT1_clean == "control"] <- "Control"
meta$v2_group[meta$TREAT1_clean == "low"] <- "Low"
meta$v2_group[meta$TREAT1_clean == "high"] <- "High"

cat("V2 group counts:\n")
print(table(meta$v2_group, useNA = "ifany"))

# Identify analytical samples (in both metadata and data columns)
analytical_samples <- intersect(meta$Sheet1_raw_header, sample_cols_all)
cat("Analytical samples (in both):", length(analytical_samples), "\n")

# Subset metadata to analytical
meta_an <- meta[meta$Sheet1_raw_header %in% analytical_samples, ]
cat("Analytical metadata rows:", nrow(meta_an), "\n")

# Group sample lists
ctrl_samps <- meta_an$Sheet1_raw_header[meta_an$v2_group == "Control"]
low_samps  <- meta_an$Sheet1_raw_header[meta_an$v2_group == "Low"]
high_samps <- meta_an$Sheet1_raw_header[meta_an$v2_group == "High"]

n_ctrl <- length(ctrl_samps)
n_low  <- length(low_samps)
n_high <- length(high_samps)
cat(sprintf("Control=%d, Low=%d, High=%d, Total=%d\n",
            n_ctrl, n_low, n_high, n_ctrl+n_low+n_high))

# ---- Sample QA gate ----
stopifnot(n_ctrl == 153, n_low == 186, n_high == 176,
          n_ctrl+n_low+n_high == 515)
cat("SAMPLE GATE: PASS\n")

# ---- U0 gate ----
stopifnot(nrow(annot) == 3817)
stopifnot(length(unique(annot$PG.ProteinGroups)) == 3817)
cat("U0 GATE: PASS (3817)\n")

# ---- Load Freeze 3 registry for exclusion ----
f3 <- read.csv(file.path(OUT_DIR, "registry/contaminant_candidate_registry.csv"),
               stringsAsFactors = FALSE)
primary_excl <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible == "TRUE"]
cat("Primary exclusion from Freeze 3:", length(primary_excl), "protein groups\n")
print(primary_excl)

# ---- Build Utech_primary ----
utech_mask <- !annot$PG.ProteinGroups %in% primary_excl
utech_n <- sum(utech_mask)
cat("Utech_primary:", utech_n, "\n")

# Freeze 3 gate
stopifnot(length(primary_excl) == 8)
stopifnot(utech_n == 3809)
cat("FREEZE 3 GATE: PASS (excl=8, Utech=3809)\n")

# Utech annotation
utech_annot <- annot[utech_mask, ]
utech_abundance <- abundance[utech_mask, analytical_samples]

# Utech primary output
utech_out <- data.frame(
  PG.ProteinGroups = annot$PG.ProteinGroups,
  Gene_symbol = annot$Gene_symbol,
  Display_label = annot$Gene_symbol,
  Freeze3_category = ifelse(annot$PG.ProteinGroups %in% primary_excl,
                              "PRIMARY_EXCLUSION", "RETAINED"),
  Utech_primary = utech_mask,
  Exclusion_reason = ifelse(annot$PG.ProteinGroups %in% primary_excl,
    f3$Project_category[match(annot$PG.ProteinGroups, f3$PG.ProteinGroups)],
    NA),
  stringsAsFactors = FALSE
)
write.csv(utech_out, file.path(UNIV_DIR, "Utech_primary.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

# Exclusions audit
excl_out <- utech_out[utech_out$Utech_primary == FALSE, ]
write.csv(excl_out, file.path(UNIV_DIR, "Utech_primary_exclusions.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Utech_primary.csv and exclusions written\n")

# ---- Detection function ----
# detected = finite AND > 0
is_detected <- function(x) {
  is.finite(x) & x > 0
}

# ---- Build Q515 ----
cat("\nBuilding Q515...\n")
thr_ctrl <- ceiling(0.70 * n_ctrl)
thr_low  <- ceiling(0.70 * n_low)
thr_high <- ceiling(0.70 * n_high)
cat(sprintf("Thresholds: Control>=%d, Low>=%d, High>=%d\n", thr_ctrl, thr_low, thr_high))

# Q515 gate
stopifnot(thr_ctrl == 108, thr_low == 131, thr_high == 124)
cat("Q515 THRESHOLD GATE: PASS\n")

# Compute detection counts per group
det_ctrl <- rowSums(is_detected(as.matrix(utech_abundance[, ctrl_samps])))
det_low  <- rowSums(is_detected(as.matrix(utech_abundance[, low_samps])))
det_high <- rowSums(is_detected(as.matrix(utech_abundance[, high_samps])))

q515_pass <- (det_ctrl >= thr_ctrl) & (det_low >= thr_low) & (det_high >= thr_high)
cat("Q515 pass:", sum(q515_pass), "\n")

# Q515 eligibility registry (all 3809)
q515_all <- data.frame(
  PG.ProteinGroups = utech_annot$PG.ProteinGroups,
  Gene_symbol = utech_annot$Gene_symbol,
  Display_label = utech_annot$Gene_symbol,
  N_detect_Control = det_ctrl,
  N_Control = n_ctrl,
  Rate_Control = round(det_ctrl / n_ctrl, 4),
  Threshold_Control = thr_ctrl,
  N_detect_Low = det_low,
  N_Low = n_low,
  Rate_Low = round(det_low / n_low, 4),
  Threshold_Low = thr_low,
  N_detect_High = det_high,
  N_High = n_high,
  Rate_High = round(det_high / n_high, 4),
  Threshold_High = thr_high,
  Q515 = q515_pass,
  stringsAsFactors = FALSE
)
write.csv(q515_all, file.path(UNIV_DIR, "Q515_eligibility_all_Utech.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

# Q515 pass list
q515_pass_df <- q515_all[q515_all$Q515 == TRUE, ]
write.csv(q515_pass_df, file.path(UNIV_DIR, "Q515.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Q515.csv written (", nrow(q515_pass_df), "proteins)\n", sep="")

# ---- Build D515 ----
cat("\nBuilding D515...\n")
all_analytical <- c(ctrl_samps, low_samps, high_samps)
det_total <- rowSums(is_detected(as.matrix(utech_abundance[, all_analytical])))
not_det_total <- length(all_analytical) - det_total

d515_pass <- (det_total >= 10) & (not_det_total >= 10)
cat("D515 pass:", sum(d515_pass), "\n")

# D515 eligibility registry (all 3809)
d515_all <- data.frame(
  PG.ProteinGroups = utech_annot$PG.ProteinGroups,
  Gene_symbol = utech_annot$Gene_symbol,
  Display_label = utech_annot$Gene_symbol,
  N_detected = det_total,
  N_not_detected = not_det_total,
  N_total = length(all_analytical),
  Detection_rate = round(det_total / length(all_analytical), 4),
  D515 = d515_pass,
  stringsAsFactors = FALSE
)
write.csv(d515_all, file.path(UNIV_DIR, "D515_eligibility_all_Utech.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")

# D515 pass list
d515_pass_df <- d515_all[d515_all$D515 == TRUE, ]
write.csv(d515_pass_df, file.path(UNIV_DIR, "D515.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("D515.csv written (", nrow(d515_pass_df), "proteins)\n", sep="")

# ---- D515 independence gate ----
# D515 should not depend on Q515
cat("\nD515 independence check:\n")
cat("D515 ∩ Q515:", sum(d515_pass & q515_pass), "\n")
cat("D515 only:", sum(d515_pass & !q515_pass), "\n")
cat("Q515 only:", sum(!d515_pass & q515_pass), "\n")

# ---- Master universe registry ----
cat("\nBuilding master registry...\n")
# Merge everything at U0 level
master <- data.frame(
  PG.ProteinGroups = annot$PG.ProteinGroups,
  Gene_symbol = annot$Gene_symbol,
  Display_label = annot$Gene_symbol,
  U0 = TRUE,
  stringsAsFactors = FALSE
)

# Freeze 3 category
f3_cat <- f3$Project_category[match(master$PG.ProteinGroups, f3$PG.ProteinGroups)]
f3_prim <- f3$Primary_exclusion_eligible[match(master$PG.ProteinGroups, f3$PG.ProteinGroups)]
master$Freeze3_category <- ifelse(is.na(f3_cat), "NOT_CANDIDATE", f3_cat)
master$Primary_exclusion <- ifelse(is.na(f3_prim), "FALSE", f3_prim)

# Utech_primary
master$Utech_primary <- master$PG.ProteinGroups %in% utech_annot$PG.ProteinGroups

# Q515 (NA for excluded)
q515_map <- setNames(q515_all$Q515, q515_all$PG.ProteinGroups)
master$Q515 <- ifelse(master$Utech_primary,
                       q515_map[master$PG.ProteinGroups], NA)

# Q515 failure reason
q515_fail_reason <- rep(NA, nrow(master))
for (i in which(master$Utech_primary & !master$Q515)) {
  pg <- master$PG.ProteinGroups[i]
  row <- q515_all[q515_all$PG.ProteinGroups == pg, ]
  reasons <- c()
  if (row$N_detect_Control < row$Threshold_Control) reasons <- c(reasons, "Control_below_threshold")
  if (row$N_detect_Low < row$Threshold_Low) reasons <- c(reasons, "Low_below_threshold")
  if (row$N_detect_High < row$Threshold_High) reasons <- c(reasons, "High_below_threshold")
  q515_fail_reason[i] <- paste(reasons, collapse=";")
}
master$Q515_failure_reason <- ifelse(master$Utech_primary & !master$Q515, q515_fail_reason,
                              ifelse(!master$Utech_primary, "FROZEN3_EXCLUDED", NA))

# D515
d515_map <- setNames(d515_all$D515, d515_all$PG.ProteinGroups)
master$D515 <- ifelse(master$Utech_primary,
                      d515_map[master$PG.ProteinGroups], NA)

# D515 failure reason
d515_fail_reason <- rep(NA, nrow(master))
for (i in which(master$Utech_primary & !master$D515)) {
  pg <- master$PG.ProteinGroups[i]
  row <- d515_all[d515_all$PG.ProteinGroups == pg, ]
  reasons <- c()
  if (row$N_detected < 10) reasons <- c(reasons, "N_detected_lt10")
  if (row$N_not_detected < 10) reasons <- c(reasons, "N_not_detected_lt10")
  d515_fail_reason[i] <- paste(reasons, collapse=";")
}
master$D515_failure_reason <- ifelse(master$Utech_primary & !master$D515, d515_fail_reason,
                              ifelse(!master$Utech_primary, "FROZEN3_EXCLUDED", NA))

# Flags
master$Contact_flag <- grepl("A3", master$Freeze3_category) | grepl("SALIVARY", master$Freeze3_category)
master$Category_B_flag <- grepl("^B", master$Freeze3_category)
master$Category_C_flag <- master$Freeze3_category == "C"

write.csv(master, file.path(UNIV_DIR, "V2_universe_membership_master.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Master registry written:", nrow(master), "rows\n")

# ---- Historical reconciliation ----
cat("\n=== HISTORICAL RECONCILIATION ===\n")
# Historical 1434 = proteins with >=70% detection in historical analysis
# We don't have the exact historical list, but we know it was based on full cohort
# Let's compare Q515 to expected 1434
cat("v2 Q515:", nrow(q515_pass_df), "\n")
cat("Historical 1434: 1434\n")
cat("Note: Historical 1434 was from full-cohort v1.0 without Freeze 3 exclusions.\n")
cat("v2 Q515 starts from Utech_primary (3809) with frozen 70% rule.\n")
cat("D515:", nrow(d515_pass_df), "— no directly equivalent historical universe.\n")

# ---- Provenance manifest ----
cat("\nBuilding manifest...\n")
sha256_file <- function(path) {
  digest(file = path, algo = "sha256")
}

manifest <- data.frame(
  item = c(
    "source_processed_xlsx",
    "sample_metadata_csv",
    "freeze3_registry_csv",
    "analysis_plan_version",
    "execution_timestamp",
    "U0_proteins",
    "analytical_samples",
    "Control_n", "Low_n", "High_n",
    "primary_exclusion_n",
    "Utech_primary_n",
    "Q515_n",
    "D515_n",
    "Control_threshold", "Low_threshold", "High_threshold"
  ),
  value = c(
    sha256_file(file.path(ROOT, "rawdata/processed.xlsx")),
    sha256_file(file.path(ROOT, "descriptive/dose_defined_metadata.csv")),
    sha256_file(file.path(OUT_DIR, "registry/contaminant_candidate_registry.csv")),
    "ANALYSIS_PLAN_v2.0",
    format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"),
    "3817",
    as.character(length(analytical_samples)),
    as.character(n_ctrl), as.character(n_low), as.character(n_high),
    as.character(length(primary_excl)),
    as.character(utech_n),
    as.character(sum(q515_pass)),
    as.character(sum(d515_pass)),
    as.character(thr_ctrl), as.character(thr_low), as.character(thr_high)
  ),
  stringsAsFactors = FALSE
)
write.csv(manifest, file.path(MANIFEST_DIR, "V2_02_universe_manifest.csv"),
          row.names = FALSE, fileEncoding = "UTF-8")
cat("Manifest written\n")

# ---- Final summary ----
cat("\n===== V2-02 FINAL SUMMARY =====\n")
cat("U0:", nrow(annot), "\n")
cat("Primary exclusion:", length(primary_excl), "\n")
cat("Utech_primary:", utech_n, "\n")
cat("Q515:", sum(q515_pass), "\n")
cat("D515:", sum(d515_pass), "\n")
cat("Q515 ∩ D515:", sum(q515_pass & d515_pass), "\n")
cat("D515 only:", sum(d515_pass & !q515_pass), "\n")
cat("Q515 only:", sum(!d515_pass & q515_pass), "\n")
cat("\nDone.\n")
