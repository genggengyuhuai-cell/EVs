# =============================================================================
# Candidate ROC overlay redraw (reference style)
# REPORTING_ONLY / DERIVED_FROM_FROZEN_OUTPUTS — figure style change only.
# Recomputes ROC curves from the SAME frozen data, VERIFIES AUCs match the
# previously reported summary, and redraws in overlay layout.
# No discovery / ML rerun, no frozen outputs modified, no AUC values changed.
# =============================================================================

suppressPackageStartupMessages({
  library(pROC); library(ggplot2); library(dplyr); library(tidyr); library(gridExtra)
})
set.seed(20260930)
OUT_DIR <- "descriptive/analysis_v2.0/candidate_diagnostics_roc"
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# ---- Data (identical to prior diagnostics run) ----
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names = 1, check.names = FALSE)
meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors = FALSE)

cands <- data.frame(
  PG = c("Q08378","Q8NG11","P22466","Q13316","P05019","P09603"),
  Gene = c("GOLGA3","TSPAN14","GAL","DMP1","IGF1","CSF1"),
  stringsAsFactors = FALSE)

ml <- meta[meta$TREAT1_clean %in% c("high","low"), ]
ml$y <- as.integer(ml$TREAT1_clean == "high")
common <- intersect(ml$UniqueSampleID, colnames(expr))
ml <- ml[ml$UniqueSampleID %in% common, ]
ml <- ml[match(common, ml$UniqueSampleID), ]
ab <- t(as.matrix(expr[cands$PG, ml$UniqueSampleID]))
colnames(ab) <- cands$Gene
ml <- cbind(ml, as.data.frame(ab))
disc <- ml[ml$Split == "Discovery", ]
val  <- ml[ml$Split == "Validation", ]

# ---- Previously reported AUC (reference) ----
ref_disc <- c(GOLGA3=0.693, TSPAN14=0.681, GAL=0.653, DMP1=0.662, IGF1=0.622, CSF1=0.639)
ref_val  <- c(GOLGA3=0.703, TSPAN14=0.617, GAL=0.660, DMP1=0.595, IGF1=0.539, CSF1=0.631)

# ---- Recompute AUCs and VERIFY against reference ----
comp_auc <- function(g, d) {
  r <- roc(d$y, d[[g]], quiet=TRUE, direction="auto")
  as.numeric(r$auc)
}
auc_d <- sapply(cands$Gene, function(g) comp_auc(g, disc))
auc_v <- sapply(cands$Gene, function(g) comp_auc(g, val))
names(auc_d) <- names(auc_v) <- cands$Gene

tol <- 0.002
bad_d <- names(auc_d)[abs(auc_d - ref_disc[names(auc_d)]) > tol]
bad_v <- names(auc_v)[abs(auc_v - ref_val[names(auc_v)]) > tol]
cat("=== AUC consistency check ===\n")
cat("Discovery recomputed:\n"); print(round(auc_d,3))
cat("Reference Discovery:\n"); print(ref_disc)
cat("Validation recomputed:\n"); print(round(auc_v,3))
cat("Reference Validation:\n"); print(ref_val)
if (length(bad_d) || length(bad_v)) {
  stop("AUC mismatch vs prior summary: Discovery=", paste(bad_d,collapse=","),
       " Validation=", paste(bad_v,collapse=","), ". Stopping; not overwriting.")
} else {
  cat("CONSISTENT: all recomputed AUCs match prior reported summary.\n")
}

# ---- Colors: reference publication palette (soft) ----
# Gray #A6A6A6, Orange #FFB84D, Blue #4A85B3, Coral #FF6347, Teal #4BBEB6, Purple #B266C4
pal <- c(GOLGA3="#FF6347", TSPAN14="#4A85B3", GAL="#B266C4",
         DMP1="#4BBEB6", IGF1="#FFB84D", CSF1="#A6A6A6")

# ---- Build ROC curve data for each panel ----
roc_df <- function(d) {
  out <- list()
  for (g in cands$Gene) {
    r <- roc(d$y, d[[g]], quiet=TRUE, direction="auto")
    out[[length(out)+1]] <- data.frame(
      Gene=g, fpr=1-r$specificities, tpr=r$sensitivities,
      stringsAsFactors=FALSE)
  }
  do.call(rbind, out)
}
disc_roc <- roc_df(disc)
val_roc  <- roc_df(val)

# legend order: by validation AUC descending (for both panels, keep same gene color)
order_genes <- names(sort(auc_v, decreasing=TRUE))

make_panel <- function(curves, auc, panel_letter, title_lines) {
  # curves: data.frame with Gene,fpr,tpr ; auc: named vector
  legend_lab <- sprintf("%s (%.3f)", names(auc)[match(unique(curves$Gene), names(auc))],
                        auc[match(unique(curves$Gene), names(auc))])
  # build legend labels aligned to ordered genes
  lab_map <- setNames(sprintf("%s (%.3f)", names(auc), auc), names(auc))
  curves$Gene <- factor(curves$Gene, levels=order_genes)
  ggplot(curves, aes(x=fpr, y=tpr, color=Gene)) +
    geom_line(linewidth=1.1) +
    geom_abline(slope=1, intercept=0, linetype="dashed", color="grey55", linewidth=0.6) +
    coord_equal() + xlim(0,1) + ylim(0,1) +
    scale_color_manual(values=pal, breaks=order_genes, labels=lab_map[order_genes],
                       name="Gene name (AUC)") +
    labs(title=title_lines, x="1 - Specificity", y="Sensitivity") +
    theme_classic(base_size=10) +
    theme(plot.title=element_text(size=10, hjust=0.5),
          legend.position="right",
          legend.title=element_text(size=8, face="bold"),
          legend.text=element_text(size=8),
          panel.border=element_rect(color="black", fill=NA))
}

p_disc <- make_panel(disc_roc, auc_d, "C",
                     sprintf("Panel C  Discovery / training  n=271 (High=132, Low=139)"))
p_val  <- make_panel(val_roc, auc_v, "D",
                     sprintf("Panel D  Validation / reused hold-out  n=91 (High=44, Low=47)"))

pdf(file.path(OUT_DIR,"Candidate_ROC_Overlay_Train_Validation.pdf"), width=13, height=5.5)
grid.arrange(p_disc, p_val, nrow=1)
dev.off()

# PNG
png(file.path(OUT_DIR,"Candidate_ROC_Overlay_Train_Validation.png"), width=2600, height=1100, res=200)
grid.arrange(p_disc, p_val, nrow=1)
dev.off()

# SVG (base)
svg(file.path(OUT_DIR,"Candidate_ROC_Overlay_Train_Validation.svg"), width=13, height=5.5)
grid.arrange(p_disc, p_val, nrow=1)
dev.off()

cat("\nUnivariate overlay written.\n")

# =============================================================================
# Optional: multigene overlay
# =============================================================================
models <- list(
  M1 = c("GOLGA3","TSPAN14"),
  M2 = c("GOLGA3","TSPAN14","GAL"),
  M3 = c("GOLGA3","TSPAN14","GAL","DMP1","IGF1"),
  M4 = c("CSF1","GOLGA3","TSPAN14"),
  M5 = c("GOLGA3","TSPAN14","GAL","DMP1","IGF1","CSF1"))
ref_mg_d <- c(M1=0.733, M2=0.741, M3=0.769, M4=0.733, M5=0.778)
ref_mg_v <- c(M1=0.651, M2=0.685, M3=0.633, M4=0.652, M5=0.614)

mg_disc <- list(); mg_val <- list(); mg_auc_d <- c(); mg_auc_v <- c()
for (mid in names(models)) {
  gs <- models[[mid]]
  fmla <- as.formula(paste("y ~", paste(gs, collapse=" + ")))
  fit <- glm(fmla, data=disc, family=binomial, na.action=na.exclude)
  pd <- as.numeric(predict(fit, newdata=disc, type="response", na.action=na.pass))
  pv <- as.numeric(predict(fit, newdata=val,  type="response", na.action=na.pass))
  rd <- roc(disc$y, pd, quiet=TRUE, direction="auto")
  rv <- roc(val$y, pv, quiet=TRUE, direction="auto")
  mg_auc_d[mid] <- as.numeric(rd$auc); mg_auc_v[mid] <- as.numeric(rv$auc)
  mg_disc[[length(mg_disc)+1]] <- data.frame(Model=mid, fpr=1-rd$specificities, tpr=rd$sensitivities)
  mg_val[[length(mg_val)+1]]  <- data.frame(Model=mid, fpr=1-rv$specificities, tpr=rv$sensitivities)
}
mg_disc <- do.call(rbind, mg_disc); mg_val <- do.call(rbind, mg_val)

bad_mg_d <- names(mg_auc_d)[abs(mg_auc_d - ref_mg_d[names(mg_auc_d)]) > 0.005]
bad_mg_v <- names(mg_auc_v)[abs(mg_auc_v - ref_mg_v[names(mg_auc_v)]) > 0.005]
cat("=== Multigene AUC consistency ===\n")
cat("Disc recomputed:", paste(round(mg_auc_d,3), collapse=", "), "\n")
cat("Val  recomputed:", paste(round(mg_auc_v,3), collapse=", "), "\n")
if (length(bad_mg_d) || length(bad_mg_v)) {
  cat("WARNING: multigene AUC mismatch vs prior summary: Disc=",paste(bad_mg_d,collapse=","),
      " Val=",paste(bad_mg_v,collapse=","),"\n")
} else {
  cat("CONSISTENT: multigene AUCs match prior summary.\n")
}

mg_pal <- c(M1="#4A85B3", M2="#FF6347", M3="#B266C4", M4="#4BBEB6", M5="#FFB84D")
mg_order <- names(sort(mg_auc_v, decreasing=TRUE))
make_mg_panel <- function(curves, auc, title_lines) {
  curves$Model <- factor(curves$Model, levels=mg_order)
  lab <- setNames(sprintf("%s (%.3f)", names(auc), auc), names(auc))
  ggplot(curves, aes(x=fpr, y=tpr, color=Model)) +
    geom_line(linewidth=1.1) +
    geom_abline(slope=1, intercept=0, linetype="dashed", color="grey55", linewidth=0.6) +
    coord_equal() + xlim(0,1) + ylim(0,1) +
    scale_color_manual(values=mg_pal, breaks=mg_order, labels=lab[mg_order],
                       name="Model (AUC)") +
    labs(title=title_lines, x="1 - Specificity", y="Sensitivity") +
    theme_classic(base_size=10) +
    theme(plot.title=element_text(size=10, hjust=0.5),
          legend.position="right", legend.title=element_text(size=8, face="bold"),
          legend.text=element_text(size=8), panel.border=element_rect(color="black", fill=NA))
}
p_mg_d <- make_mg_panel(mg_disc, mg_auc_d,
  sprintf("Panel C  Discovery / training  n=271 (High=132, Low=139)"))
p_mg_v <- make_mg_panel(mg_val, mg_auc_v,
  sprintf("Panel D  Validation / reused hold-out  n=91 (High=44, Low=47)"))

pdf(file.path(OUT_DIR,"Multigene_ROC_Overlay_Train_Validation.pdf"), width=13, height=5.5)
grid.arrange(p_mg_d, p_mg_v, nrow=1); dev.off()
png(file.path(OUT_DIR,"Multigene_ROC_Overlay_Train_Validation.png"), width=2600, height=1100, res=200)
grid.arrange(p_mg_d, p_mg_v, nrow=1); dev.off()
svg(file.path(OUT_DIR,"Multigene_ROC_Overlay_Train_Validation.svg"), width=13, height=5.5)
grid.arrange(p_mg_d, p_mg_v, nrow=1); dev.off()

cat("\nMultigene overlay written.\n")
cat("Discovery legend order: ", paste(mg_order, sprintf("(%.3f)", mg_auc_v[mg_order]), sep="", collapse="  "), "\n")
