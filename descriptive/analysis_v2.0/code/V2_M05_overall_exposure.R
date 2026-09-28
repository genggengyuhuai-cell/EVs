#!/usr/bin/env Rscript
# V2 M05 — Overall Exposure vs Control abundance (full 515, Q515 universe).
#
# ANALYSIS_PLAN_v2.0, Module 05 + Contract A + Estimand E:
#   model:  ~ 0 + Group + Environment on observed log2 quantities
#   fit:    limma lmFit + eBayes(trend=TRUE, robust=TRUE)
#   E:      (186/362)*mu_Low + (176/362)*mu_High - mu_Control
#           (exposed-minus-Control, observed sample weights 186/176)
#   exact scalar contrast via contrastAsCoef + refit (not contrasts.fit)
#   CI:     b +/- qt(.975, df.total) * SE
#   FDR:    BH across Q515, family A-E; non-estimable P=1 for adjustment,
#           raw P left NA.
#
# This script READS frozen inputs and writes to analysis_v2.0/M05/.
# It does NOT modify any historical or frozen file. No-overwrite guard on.

suppressPackageStartupMessages({
  library(limma)
})

args <- commandArgs(trailingOnly = TRUE)
# Optional: Rscript V2_M05_overall_exposure.R [EXECUTE|CHECK]
mode <- if (length(args) >= 1) args[1] else "EXECUTE"

root <- normalizePath(file.path(getwd()), winslash = "/", mustWork = FALSE)
v2   <- file.path(root, "descriptive", "analysis_v2.0")
out_dir <- file.path(v2, "M05_overall_exposure")

# ---- frozen inputs (read-only) --------------------------------------------
log2_path <- file.path(root, "descriptive", "PRIMARY_dose_log2_expression.csv.gz")
meta_path <- file.path(root, "descriptive", "dose_defined_metadata.csv")
universe_path <- file.path(v2, "universes", "Q515.csv")
annot_path <- file.path(root, "descriptive", "canonical_protein_annotation.csv")

for (p in c(log2_path, meta_path, universe_path, annot_path)) {
  if (!file.exists(p)) stop("M05 missing required input: ", p)
}

log2mat <- read.csv(gzfile(log2_path), check.names = FALSE, row.names = 1)
meta    <- read.csv(meta_path, check.names = FALSE, stringsAsFactors = FALSE)
univ    <- read.csv(universe_path, check.names = FALSE, stringsAsFactors = FALSE)
annot   <- read.csv(annot_path, check.names = FALSE, stringsAsFactors = FALSE)

# ---- contract: Q515 universe ------------------------------------------------
q515_ids <- univ$PG.ProteinGroups[univ$Q515 == TRUE]
stopifnot(is.character(q515_ids), length(q515_ids) == 1430)
cat("Q515 universe:", length(q515_ids), "proteins\n")

# ---- align metadata to matrix columns -------------------------------------
# matrix columns are sample IDs; metadata has UniqueSampleID.
mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
stopifnot(all(mat_samples %in% meta$UniqueSampleID))
m <- meta[mat_samples, ]

# Group: control/low/high -> Control/Low/High
m$Group <- factor(m$TREAT1_clean, c("control", "low", "high"),
                  c("Control", "Low", "High"))
stopifnot(!anyNA(m$Group))
cat("Group counts:", paste(names(table(m$Group)), table(m$Group), collapse=" "), "\n")

# Environment: Humid-hot vs High-altitude (from Region/Stratum in metadata)
# Use canonical keys; metadata 'Region' or 'group' field.
# The frozen design audit says Humid-hot = FJ_*, GZ_*; High-altitude = XZ_*.
site_to_env <- function(site) {
  ifelse(grepl("^XZ_", site), "High_altitude",
         ifelse(grepl("^(FJ_|GZ_)", site), "Humid_hot", NA_character_))
}
# metadata has 'group' column = site code (e.g. FJ_QZ, XZ_GG)
m$Environment <- factor(site_to_env(m$group), c("Humid_hot", "High_altitude"))
stopifnot(!anyNA(m$Environment))
cat("Environment counts:", paste(names(table(m$Environment)), table(m$Environment), collapse=" "), "\n")

# weights for E: observed Group sizes (exposed = Low + High)
nL <- sum(m$Group == "Low"); nH <- sum(m$Group == "High"); nC <- sum(m$Group == "Control")
stopifnot(nL == 186, nH == 176, nC == 153)
wL <- nL / (nL + nH); wH <- nH / (nL + nH)
cat(sprintf("E weights: Low=%.4f High=%.4f\n", wL, wH))

# ---- subset matrix to Q515 -------------------------------------------------
rownames(log2mat) <- rownames(log2mat)
common <- intersect(rownames(log2mat), q515_ids)
stopifnot(length(common) == length(q515_ids))
y <- as.matrix(log2mat[common, mat_samples])
storage.mode(y) <- "numeric"
cat("Model matrix:", nrow(y), "proteins x", ncol(y), "samples\n")

# ---- design: ~ 0 + Group + Environment -----------------------------------
design <- model.matrix(~ 0 + Group + Environment, data = m)
cat("Design rank:", qr(design)$rank, " ncol:", ncol(design), "\n")
stopifnot(qr(design)$rank == ncol(design))

# ---- exact scalar contrast E via contrastAsCoef + refit -------------------
# coefficient names
cn <- colnames(design)
# E = wL*GroupLow + wH*GroupHigh - GroupControl
e_vec <- setNames(rep(0, length(cn)), cn)
e_vec["GroupLow"]  <- wL
e_vec["GroupHigh"] <- wH
e_vec["GroupControl"] <- -1
cat("E contrast vector:", paste(names(e_vec), "=", e_vec, collapse = ", "), "\n")

# contrastAsCoef: append E as a new coefficient column, refit
# Build a design with E as an additional coefficient while keeping main effects.
# We use limma::contrastAsCoef on the Group block.
cont_mat <- matrix(e_vec, ncol = 1,
                   dimnames = list(names(e_vec), "E"))
design2 <- contrastAsCoef(design, cont_mat)[["design"]]
cat("Augmented design columns:", paste(colnames(design2), collapse=", "), "\n")

# ---- limfit ----------------------------------------------------------------
fit <- lmFit(y, design2)
fit <- eBayes(fit, trend = TRUE, robust = TRUE)

# extract E row (E is the first coefficient after contrastAsCoef)
coef_names <- colnames(fit$coefficients)
cat("fit coefficients:", paste(coef_names, collapse=", "), "\n")

# Manual extraction (robust across limma versions)
b   <- fit$coefficients[, "E"]
se  <- fit$stdev.unscaled[, "E"] * sqrt(fit$s2.post)
df.tot <- fit$df.total
praw <- 2 * pt(-abs(b / se), df = df.tot)
tcrit <- qt(0.975, df = df.tot)
lo <- b - tcrit * se
hi <- b + tcrit * se

res <- data.frame(
  PG.ProteinGroups = names(b),
  logFC = b, SE = se, CI.L = lo, CI.R = hi,
  t = b / se, P.Value = praw, df.total = df.tot,
  stringsAsFactors = FALSE
)

# observed N per protein (non-missing samples)
obs_n <- rowSums(!is.na(y))

# estimability: require >=10 observed per Group and >=5 residual df
est <- data.frame(
  PG.ProteinGroups = res$PG.ProteinGroups,
  stringsAsFactors = FALSE
)
est$N_total <- obs_n[est$PG.ProteinGroups]
# per-group observed
nGC <- rowSums(!is.na(y[, m$Group == "Control", drop = FALSE]))
nGL <- rowSums(!is.na(y[, m$Group == "Low", drop = FALSE]))
nGH <- rowSums(!is.na(y[, m$Group == "High", drop = FALSE]))
est$N_Control <- nGC[est$PG.ProteinGroups]
est$N_Low     <- nGL[est$PG.ProteinGroups]
est$N_High    <- nGH[est$PG.ProteinGroups]
est$Estimable <- (est$N_Control >= 10 & est$N_Low >= 10 & est$N_High >= 10)

out <- data.frame(
  PG.ProteinGroups = res$PG.ProteinGroups,
  log2FC_E = res$logFC,
  SE_E = res$SE,
  CI_low = res$CI.L,
  CI_high = res$CI.R,
  t_E = res$t,
  df_total = res$df.total,
  P_raw = res$P.Value,
  stringsAsFactors = FALSE
)
out <- cbind(out, est[, c("N_total","N_Control","N_Low","N_High","Estimable")])
# BH family A-E across Q515; non-estimable -> P=1 for adjustment, raw P=NA
out$P_for_BH <- ifelse(out$Estimable, out$P_raw, 1)
out$BH_FDR_AE <- p.adjust(out$P_for_BH, method = "BH")
out$P_for_BH <- NULL
out$Direction <- ifelse(!out$Estimable, "NON_ESTIMABLE",
                ifelse(out$log2FC_E > 0, "Higher_in_exposed", "Lower_in_exposed"))
out <- out[order(out$PG.ProteinGroups), ]

# annotate
ann_sub <- annot[, c("PG.ProteinGroups","Gene_symbol","Display_label")]
out <- merge(out, ann_sub, by = "PG.ProteinGroups", all.x = TRUE, sort = FALSE)

# summary
n_sig <- sum(out$Estimable & out$BH_FDR_AE < 0.05, na.rm = TRUE)
cat(sprintf("M05 A-E: %d/%d proteins FDR<0.05; non-estimable=%d\n",
            n_sig, nrow(out), sum(!out$Estimable)))

# ---- write (no-overwrite guard) -------------------------------------------
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)
out_csv <- file.path(out_dir, "M05_overall_exposure_AE_results.csv")
manifest <- file.path(out_dir, "M05_manifest.csv")
if (file.exists(out_csv)) stop("M05 refusing to overwrite existing: ", out_csv)
write.csv(out, out_csv, row.names = FALSE, na = "")

man <- data.frame(
  item = c("module","analysis_plan","n_proteins_Q515","n_samples",
           "n_Control","n_Low","n_High","E_weight_Low","E_weight_High",
           "model","eBayes","family","n_AE_FDR_lt_0.05","n_non_estimable",
           "source_log2","source_universe","seed"),
  value = c("M05_overall_exposure","ANALYSIS_PLAN_v2.0",nrow(out),ncol(y),
            nC,nL,nH,wL,wH,"limma lmFit ~0+Group+Environment",
            "eBayes(trend=TRUE, robust=TRUE)","A-E BH across Q515",
            n_sig, sum(!out$Estimable),
            "PRIMARY_dose_log2_expression.csv.gz","universes/Q515.csv",
            "NA (no random component)")
)
if (file.exists(manifest)) stop("M05 refusing to overwrite manifest")
write.csv(man, manifest, row.names = FALSE)

cat("M05_DONE\n")
