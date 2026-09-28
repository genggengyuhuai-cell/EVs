#!/usr/bin/env Rscript
# V2 M06 — Ordered exposure levels, omnibus and response architecture (full 515, Q515).
#
# ANALYSIS_PLAN_v2.0, Module 06:
#   model:  ~ 0 + Group + Environment on observed log2 quantities
#   fit:    limma lmFit + eBayes(trend=TRUE, robust=TRUE)
#   omnibus: 2-df Group F (Control=Low=High vs any difference)
#   ordered: bidirectional IUT on a=Low-Control, b=High-Low:
#              p_inc = max(p_a+, p_b+); p_dec = max(p_a-, p_b-)
#              p_order = min(1, 2*min(p_inc, p_dec))
#            BH across Q515 (family A-O)
#   adjusted means: fitted Group means at reference Environment
#   descriptive architecture: epsilon=0.05 log2, v2 rules (NOT historical Stage 11a)
#
# Writes to analysis_v2.0/M06_ordered_omnibus_architecture/.
# No-overwrite guard. No frozen file modified.

suppressPackageStartupMessages({ library(limma) })

root <- normalizePath(getwd(), winslash = "/", mustWork = FALSE)
v2   <- file.path(root, "descriptive", "analysis_v2.0")
out_dir <- file.path(v2, "M06_ordered_omnibus_architecture")
dir.create(out_dir, recursive = TRUE, showWarnings = FALSE)

# ---- frozen inputs ---------------------------------------------------------
log2_path <- file.path(root, "descriptive", "PRIMARY_dose_log2_expression.csv.gz")
meta_path <- file.path(root, "descriptive", "dose_defined_metadata.csv")
universe_path <- file.path(v2, "universes", "Q515.csv")
annot_path <- file.path(root, "descriptive", "canonical_protein_annotation.csv")

log2mat <- read.csv(gzfile(log2_path), check.names = FALSE, row.names = 1)
meta    <- read.csv(meta_path, check.names = FALSE, stringsAsFactors = FALSE)
univ    <- read.csv(universe_path, check.names = FALSE, stringsAsFactors = FALSE)
annot   <- read.csv(annot_path, check.names = FALSE, stringsAsFactors = FALSE)

# ---- Q515 universe contract ------------------------------------------------
q515_ids <- univ$PG.ProteinGroups[univ$Q515 == TRUE]
stopifnot(length(q515_ids) == 1430, !any(duplicated(q515_ids)))
cat("Q515:", length(q515_ids), "unique proteins\n")

# ---- metadata alignment ----------------------------------------------------
mat_samples <- colnames(log2mat)
rownames(meta) <- meta$UniqueSampleID
stopifnot(all(mat_samples %in% meta$UniqueSampleID))
m <- meta[mat_samples, ]
m$Group <- factor(m$TREAT1_clean, c("control","low","high"),
                  c("Control","Low","High"))
site_to_env <- function(s) ifelse(grepl("^XZ_",s),"High_altitude",
                           ifelse(grepl("^(FJ_|GZ_)",s),"Humid_hot",NA))
m$Environment <- factor(site_to_env(m$group), c("Humid_hot","High_altitude"))
stopifnot(!anyNA(m$Group), !anyNA(m$Environment))
nC <- sum(m$Group=="Control"); nL <- sum(m$Group=="Low"); nH <- sum(m$Group=="High")
stopifnot(nC==153, nL==186, nH==176, nrow(m)==515)
cat(sprintf("Samples: Control=%d Low=%d High=%d total=%d\n", nC,nL,nH,nrow(m)))

# ---- matrix subset ---------------------------------------------------------
y <- as.matrix(log2mat[q515_ids, mat_samples]); storage.mode(y) <- "numeric"

# ---- design: ~0+Group+Environment -----------------------------------------
design <- model.matrix(~0 + Group + Environment, data = m)
stopifnot(qr(design)$rank == ncol(design))
cat("Design columns:", paste(colnames(design), collapse=", "), "\n")

# ---- fit original model for adjusted Group means ---------------------------
fit0 <- lmFit(y, design)
fit0 <- eBayes(fit0, trend = TRUE, robust = TRUE)
# adjusted Group means at reference Environment (Humid_hot = intercept reference)
mu_C <- fit0$coefficients[, "GroupControl"]
mu_L <- fit0$coefficients[, "GroupLow"]
mu_H <- fit0$coefficients[, "GroupHigh"]

# ---- exact contrasts a=Low-Control, b=High-Low via contrastAsCoef --------
cn <- colnames(design)
ca <- setNames(rep(0,length(cn)), cn); ca["GroupLow"] <- 1; ca["GroupControl"] <- -1
cb <- setNames(rep(0,length(cn)), cn); cb["GroupHigh"] <- 1; cb["GroupLow"] <- -1
cont <- cbind(a=ca, b=cb)
design2 <- contrastAsCoef(design, cont)[["design"]]
fit2 <- lmFit(y, design2)
fit2 <- eBayes(fit2, trend = TRUE, robust = TRUE)

# omnibus F on a,b (2-df): topTable with coef=c("a","b") gives moderated F
omni_tt <- topTable(fit2, coef = c("a","b"), number = Inf, sort.by = "none")
# rownames of omni_tt are protein IDs
omni_tt <- omni_tt[rownames(y), ]
F_omnibus <- omni_tt$F
P_omnibus <- omni_tt$P.Value
names(F_omnibus) <- names(P_omnibus) <- rownames(y)
df1 <- 2L
df2 <- fit2$df.total

b_a <- fit2$coefficients[, "a"]
b_b <- fit2$coefficients[, "b"]
se_a <- fit2$stdev.unscaled[, "a"] * sqrt(fit2$s2.post)
se_b <- fit2$stdev.unscaled[, "b"] * sqrt(fit2$s2.post)
dft <- fit2$df.total
ta <- b_a / se_a; tb <- b_b / se_b

# two-sided P
P_a <- 2*pt(-abs(ta), df=dft)
P_b <- 2*pt(-abs(tb), df=dft)
# one-sided upper/lower
p_aplus <- pt(ta, df=dft, lower.tail=FALSE)
p_aminus<- pt(ta, df=dft, lower.tail=TRUE)
p_bplus <- pt(tb, df=dft, lower.tail=FALSE)
p_bminus<- pt(tb, df=dft, lower.tail=TRUE)

# IUT bidirectional ordered
p_inc <- pmax(p_aplus, p_bplus)
p_dec <- pmax(p_aminus, p_bminus)
p_order <- pmin(1, 2*pmin(p_inc, p_dec))
ordered_direction <- ifelse(p_inc < p_dec, "Ordered_increasing",
                     ifelse(p_dec < p_inc, "Ordered_decreasing", "Tied"))
# when equal, pick based on effect sign
ordered_direction <- ifelse(p_inc == p_dec,
                    ifelse(b_a > 0, "Ordered_increasing", "Ordered_decreasing"),
                    ordered_direction)

# BH families
# A-G omnibus: P=1 for non-estimable (none expected in Q515), BH over all 1430
# A-O ordered: same
P_om_BH <- p.adjust(P_omnibus, method="BH")
P_order_BH <- p.adjust(p_order, method="BH")

# ---- pairwise adjusted differences -----------------------------------------
a_diff <- b_a            # Low - Control
b_diff <- b_b            # High - Low
c_diff <- b_a + b_b      # High - Control

# ---- descriptive architecture (epsilon=0.05 log2) --------------------------
eps <- 0.05
arch_class <- character(length(a_diff))
rule_used  <- character(length(a_diff))
for (i in seq_along(a_diff)) {
  ai <- a_diff[i]; bi <- b_diff[i]; ci <- c_diff[i]
  if (is.na(ai) || is.na(bi) || is.na(ci)) {
    arch_class[i] <- "Uncertain_or_other"; rule_used[i] <- "missing_non_estimable"; next
  }
  if (abs(ai) <= eps && bi > eps) {
    arch_class[i] <- "High-selective_increase"; rule_used[i] <- "rule1_high_sel_inc"
  } else if (abs(ai) <= eps && bi < -eps) {
    arch_class[i] <- "High-selective_decrease"; rule_used[i] <- "rule1_high_sel_dec"
  } else if (ai > eps && bi < -eps && abs(ci) <= eps) {
    arch_class[i] <- "Low-selective_elevation"; rule_used[i] <- "rule2_low_sel_elev"
  } else if (ai < -eps && bi > eps && abs(ci) <= eps) {
    arch_class[i] <- "Low-selective_suppression"; rule_used[i] <- "rule2_low_sel_supp"
  } else if (sign(ai) == -sign(bi) && abs(ai) > eps && abs(bi) > eps) {
    arch_class[i] <- ifelse(ai > 0, "Nonmonotonic_Low_peak", "Nonmonotonic_Low_trough")
    rule_used[i] <- "rule3_reversal"
  } else if (ai >= -eps && bi >= -eps && ci > eps) {
    arch_class[i] <- "Monotonic_increase"; rule_used[i] <- "rule4_monotonic_inc"
  } else if (ai <= eps && bi <= eps && ci < -eps) {
    arch_class[i] <- "Monotonic_decrease"; rule_used[i] <- "rule5_monotonic_dec"
  } else {
    arch_class[i] <- "Uncertain_or_other"; rule_used[i] <- "rule6_other"
  }
}

# ---- observed N per protein per Group --------------------------------------
nGC <- rowSums(!is.na(y[, m$Group=="Control",drop=FALSE]))
nGL <- rowSums(!is.na(y[, m$Group=="Low",drop=FALSE]))
nGH <- rowSums(!is.na(y[, m$Group=="High",drop=FALSE]))
est_flag <- (nGC >= 10 & nGL >= 10 & nGH >= 10)

# ---- assemble protein-level tables -----------------------------------------
res <- data.frame(
  PG.ProteinGroups = rownames(y),
  adjusted_mean_Control = mu_C,
  adjusted_mean_Low = mu_L,
  adjusted_mean_High = mu_H,
  diff_Low_minus_Control = a_diff,
  diff_High_minus_Low = b_diff,
  diff_High_minus_Control = c_diff,
  SE_a = se_a, SE_b = se_b,
  t_a = ta, t_b = tb,
  P_a_two_sided = P_a, P_b_two_sided = P_b,
  omnibus_F = F_omnibus,
  omnibus_df_num = df1,
  omnibus_df_resid = df2,
  omnibus_P = P_omnibus,
  BH_FDR_A_G = P_om_BH,
  IUT_p_inc = p_inc, IUT_p_dec = p_dec,
  IUT_p_order = p_order,
  ordered_direction = ordered_direction,
  BH_FDR_A_O = P_order_BH,
  N_Control = nGC, N_Low = nGL, N_High = nGH,
  Estimable = est_flag,
  stringsAsFactors = FALSE
)
# annotate
ann_sub <- annot[, c("PG.ProteinGroups","Gene_symbol","Display_label")]
res <- merge(res, ann_sub, by="PG.ProteinGroups", all.x=TRUE, sort=FALSE)
res <- res[order(res$PG.ProteinGroups), ]

# architecture table (subset)
arch <- res[, c("PG.ProteinGroups","Gene_symbol","Display_label",
                "adjusted_mean_Control","adjusted_mean_Low","adjusted_mean_High",
                "diff_Low_minus_Control","diff_High_minus_Low","diff_High_minus_Control")]
arch$descriptive_architecture_class <- arch_class
arch$rule_used <- rule_used
arch$omnibus_BH_FDR <- res$BH_FDR_A_G
arch$ordered_BH_FDR <- res$BH_FDR_A_O
arch$ordered_direction <- res$ordered_direction

# omnibus table
omni_tbl <- res[, c("PG.ProteinGroups","Gene_symbol","Display_label",
                    "omnibus_F","omnibus_df_num","omnibus_df_resid",
                    "omnibus_P","BH_FDR_A_G","Estimable",
                    "N_Control","N_Low","N_High")]

# ordered table
ord_tbl <- res[, c("PG.ProteinGroups","Gene_symbol","Display_label",
                   "diff_Low_minus_Control","SE_a","t_a","P_a_two_sided",
                   "diff_High_minus_Low","SE_b","t_b","P_b_two_sided",
                   "IUT_p_inc","IUT_p_dec","IUT_p_order",
                   "ordered_direction","BH_FDR_A_O","Estimable")]

# class summary
class_summary <- as.data.frame(table(arch_class), stringsAsFactors=FALSE)
names(class_summary) <- c("architecture_class","n")
class_summary$pct <- round(100*class_summary$n/nrow(arch), 2)

# ---- write (no-overwrite) ---------------------------------------------------
f1 <- file.path(out_dir, "M06_omnibus_table.csv")
f2 <- file.path(out_dir, "M06_ordered_IUT_table.csv")
f3 <- file.path(out_dir, "M06_adjusted_means_architecture_table.csv")
f4 <- file.path(out_dir, "M06_architecture_class_summary.csv")
f5 <- file.path(out_dir, "M06_manifest.csv")
for (f in c(f1,f2,f3,f4,f5)) if (file.exists(f)) stop("M06 refusing overwrite: ", f)

write.csv(omni_tbl, f1, row.names=FALSE, na="")
write.csv(ord_tbl, f2, row.names=FALSE, na="")
write.csv(arch, f3, row.names=FALSE, na="")
write.csv(class_summary, f4, row.names=FALSE, na="")

# ---- counts report ---------------------------------------------------------
n_omni_sig <- sum(res$Estimable & res$BH_FDR_A_G < 0.05, na.rm=TRUE)
n_ord_inc  <- sum(res$Estimable & res$BH_FDR_A_O < 0.05 & res$ordered_direction=="Ordered_increasing", na.rm=TRUE)
n_ord_dec  <- sum(res$Estimable & res$BH_FDR_A_O < 0.05 & res$ordered_direction=="Ordered_decreasing", na.rm=TRUE)

man <- data.frame(
  item = c("module","analysis_plan","universe","n_proteins","n_samples",
           "n_Control","n_Low","n_High","model","eBayes",
           "omnibus_family","ordered_family","epsilon_descriptive",
           "n_omnibus_FDR_lt_0.05","n_ordered_increasing_FDR_lt_0.05",
           "n_ordered_decreasing_FDR_lt_0.05","n_non_estimable",
           "source_log2","source_universe","timestamp"),
  value = c("M06_ordered_omnibus_architecture","ANALYSIS_PLAN_v2.0","Q515",
            nrow(res),515,nC,nL,nH,"~0+Group+Environment",
            "eBayes(trend=TRUE, robust=TRUE)","A-G","A-O","0.05 log2",
            n_omni_sig,n_ord_inc,n_ord_dec,sum(!res$Estimable),
            "PRIMARY_dose_log2_expression.csv.gz","universes/Q515.csv",
            format(Sys.time(),"%Y-%m-%d %H:%M:%S %z"))
)
write.csv(man, f5, row.names=FALSE)

cat(sprintf("\n=== M06 COUNTS ===\n"))
cat(sprintf("Proteins: %d\n", nrow(res)))
cat(sprintf("Omnibus A-G FDR<0.05: %d\n", n_omni_sig))
cat(sprintf("Ordered inc A-O FDR<0.05: %d\n", n_ord_inc))
cat(sprintf("Ordered dec A-O FDR<0.05: %d\n", n_ord_dec))
cat("Architecture class counts:\n")
print(class_summary)
cat("M06_DONE\n")
