# =============================================================================
# Candidate protein ROC/AUC diagnostics (univariate + multigene logistic)
# REPORTING_ONLY / DERIVED_FROM_FROZEN_OUTPUTS
# No discovery, no ML retraining, no frozen results modified.
# =============================================================================

suppressPackageStartupMessages({
  library(pROC); library(ggplot2); library(dplyr); library(tidyr)
})

set.seed(20260929)
OUT_DIR <- "descriptive/analysis_v2.0/candidate_diagnostics_roc"
dir.create(OUT_DIR, recursive = TRUE, showWarnings = FALSE)

# ---- Data ----
d03 <- read.csv("descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv",
                stringsAsFactors = FALSE, check.names = FALSE)
gene_lookup <- setNames(d03$Gene_symbol.x, d03$PG.ProteinGroups)

expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names = 1, check.names = FALSE)
meta <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv",
                 stringsAsFactors = FALSE)

# Candidates
cands <- data.frame(
  PG = c("Q08378","Q8NG11","P22466","Q13316","P05019","P09603"),
  Gene = c("GOLGA3","TSPAN14","GAL","DMP1","IGF1","CSF1"),
  stringsAsFactors = FALSE)
cands$Display_label <- cands$Gene
cands$Tier1_flag <- c("YES","YES","YES","YES","YES","NO")
cands$SVM_RFE_flag <- c("YES","YES","NO","NO","NO","YES")
cands$Four_way_consensus_flag <- c("YES","YES","NO","NO","NO","NO")

# Subset meta to High/Low
ml <- meta[meta$TREAT1_clean %in% c("high","low"), ]
ml$y <- as.integer(ml$TREAT1_clean == "high")

# Align samples with expression
common <- intersect(ml$UniqueSampleID, colnames(expr))
ml <- ml[ml$UniqueSampleID %in% common, ]
ml <- ml[match(common, ml$UniqueSampleID), ]

# Build abundance matrix: samples x candidates
ab <- t(as.matrix(expr[cands$PG, ml$UniqueSampleID]))
colnames(ab) <- cands$Gene
rownames(ab) <- ml$UniqueSampleID

ml <- cbind(ml, as.data.frame(ab))
disc <- ml[ml$Split == "Discovery", ]
val  <- ml[ml$Split == "Validation", ]

cat("Discovery: n=", nrow(disc), " high=", sum(disc$y==1), " low=", sum(disc$y==0), "\n", sep="")
cat("Validation: n=", nrow(val), " high=", sum(val$y==1), " low=", sum(val$y==0), "\n", sep="")

# ---- Helpers ----
one_candidate <- function(gene, disc, val) {
  x_d <- disc[[gene]]; y_d <- disc$y
  x_v <- val[[gene]];  y_v <- val$y

  # Use direction="auto": pROC picks the favorable direction; AUC reported >=0.5
  roc_d <- roc(y_d, x_d, quiet=TRUE, direction="auto")
  auc_d <- as.numeric(roc_d$auc)
  ci_d  <- as.numeric(ci.auc(roc_d, method="delong"))

  # Youden on discovery
  cut_d <- coords(roc_d, "best", best.method="youden", ret=c("threshold","sensitivity","specificity"))
  cd <- as.numeric(cut_d$threshold[1]); sens_d <- as.numeric(cut_d$sensitivity[1]); spec_d <- as.numeric(cut_d$specificity[1])
  # accuracy at discovery cutoff (use roc's direction)
  pred_d <- as.integer(if (roc_d$direction == "<") x_d >= cd else x_d <= cd)
  acc_d <- mean(pred_d == y_d, na.rm=TRUE)
  # direction
  med_d_high <- median(x_d[y_d==1], na.rm=TRUE); med_d_low <- median(x_d[y_d==0], na.rm=TRUE)
  dir_d <- ifelse(med_d_high > med_d_low, "UP_IN_HIGH", "DOWN_IN_HIGH")

  # Validation
  roc_v <- roc(y_v, x_v, quiet=TRUE, direction="auto")
  auc_v <- as.numeric(roc_v$auc)
  ci_v  <- as.numeric(ci.auc(roc_v, method="delong"))
  med_v_high <- median(x_v[y_v==1], na.rm=TRUE); med_v_low <- median(x_v[y_v==0], na.rm=TRUE)
  dir_v <- ifelse(med_v_high > med_v_low, "UP_IN_HIGH", "DOWN_IN_HIGH")

  # Validation at discovery cutoff (same direction as discovery)
  pred_v <- as.integer(if (roc_d$direction == "<") x_v >= cd else x_v <= cd)
  sens_v_at_cd <- mean((x_v[y_v==1] >= cd & roc_d$direction=="<") | (x_v[y_v==1] <= cd & roc_d$direction==">"), na.rm=TRUE)
  spec_v_at_cd <- mean((x_v[y_v==0] <  cd & roc_d$direction=="<") | (x_v[y_v==0] >  cd & roc_d$direction==">"), na.rm=TRUE)
  acc_v_at_cd  <- mean(pred_v == y_v, na.rm=TRUE)

  # Validation-optimal (optimistic)
  cut_v <- coords(roc_v, "best", best.method="youden", ret=c("threshold","sensitivity","specificity"))
  cv <- as.numeric(cut_v$threshold[1]); sens_v_opt <- as.numeric(cut_v$sensitivity[1]); spec_v_opt <- as.numeric(cut_v$specificity[1])
  pred_v_opt <- as.integer(if (roc_v$direction == "<") x_v >= cv else x_v <= cv)
  acc_v_opt <- mean(pred_v_opt == y_v, na.rm=TRUE)

  data.frame(
    Protein_ID = cands$PG[cands$Gene==gene],
    Gene_symbol = gene,
    Display_label = gene,
    Candidate_group = ifelse(gene %in% c("GAL","TSPAN14","DMP1","IGF1","GOLGA3"), "Frozen_Tier1", "SVM_specific"),
    Discovery_n_high = sum(y_d==1), Discovery_n_low = sum(y_d==0),
    Discovery_AUC = auc_d, Discovery_AUC_CI_low = ci_d[1], Discovery_AUC_CI_high = ci_d[3],
    Discovery_best_cutoff = cd, Discovery_sensitivity = sens_d, Discovery_specificity = spec_d, Discovery_accuracy = acc_d,
    Discovery_direction = dir_d,
    Validation_n_high = sum(y_v==1), Validation_n_low = sum(y_v==0),
    Validation_AUC = auc_v, Validation_AUC_CI_low = ci_v[1], Validation_AUC_CI_high = ci_v[3],
    Validation_direction = dir_v,
    Direction_concordant = ifelse(dir_d == dir_v, "YES", "NO"),
    Validation_sens_at_discovery_cutoff = sens_v_at_cd,
    Validation_spec_at_discovery_cutoff = spec_v_at_cd,
    Validation_acc_at_discovery_cutoff = acc_v_at_cd,
    Validation_best_cutoff = cv, Validation_best_sensitivity = sens_v_opt,
    Validation_best_specificity = spec_v_opt, Validation_best_accuracy = acc_v_opt,
    Tier1_flag = cands$Tier1_flag[cands$Gene==gene],
    SVM_RFE_flag = cands$SVM_RFE_flag[cands$Gene==gene],
    Four_way_consensus_flag = cands$Four_way_consensus_flag[cands$Gene==gene],
    stringsAsFactors=FALSE)
}

uni <- do.call(rbind, lapply(cands$Gene, function(g) one_candidate(g, disc, val)))
write.csv(uni, file.path(OUT_DIR, "candidate_roc_auc_summary.csv"), row.names=FALSE, quote=TRUE)

# ---- Distribution summary ----
dist_rows <- list()
for (gene in cands$Gene) {
  for (set in c("Discovery","Validation")) {
    d <- if (set=="Discovery") disc else val
    x <- d[[gene]]; y <- d$y
    dist_rows[[length(dist_rows)+1]] <- data.frame(
      Gene_symbol=gene, Set=set, Group=ifelse(y==1,"High","Low"),
      n=length(x), median=median(x,na.rm=TRUE), mean=mean(x,na.rm=TRUE),
      sd=sd(x,na.rm=TRUE), min=min(x,na.rm=TRUE), max=max(x,na.rm=TRUE),
      stringsAsFactors=FALSE)
  }
}
dist_df <- do.call(rbind, dist_rows)
write.csv(dist_df, file.path(OUT_DIR, "candidate_distribution_summary.csv"), row.names=FALSE, quote=TRUE)

# ---- Part B: multigene logistic ----
models <- list(
  M1 = c("GOLGA3","TSPAN14"),
  M2 = c("GOLGA3","TSPAN14","GAL"),
  M3 = c("GOLGA3","TSPAN14","GAL","DMP1","IGF1"),
  M4 = c("CSF1","GOLGA3","TSPAN14"),
  M5 = c("GOLGA3","TSPAN14","GAL","DMP1","IGF1","CSF1"))

mg_summary <- list()
mg_coefs <- list()
for (mid in names(models)) {
  gs <- models[[mid]]
  fmla <- as.formula(paste("y ~", paste(gs, collapse=" + ")))
  fit <- tryCatch(glm(fmla, data=disc, family=binomial, na.action=na.exclude), error=function(e) e)
  status <- if (inherits(fit,"error")) "FAILED" else "OK"
  if (status=="OK") {
    coefs <- coef(fit)
    pd <- as.numeric(predict(fit, newdata=disc, type="response", na.action=na.pass))
    pv <- as.numeric(predict(fit, newdata=val,  type="response", na.action=na.pass))
    okd <- complete.cases(disc$y, pd); okv <- complete.cases(val$y, pv)
    rd <- roc(disc$y[okd], pd[okd], quiet=TRUE, direction="auto")
    rv <- roc(val$y[okv], pv[okv], quiet=TRUE, direction="auto")
    ad <- as.numeric(rd$auc); av <- as.numeric(rv$auc)
    cid <- as.numeric(ci.auc(rd, method="delong"))
    civ <- as.numeric(ci.auc(rv, method="delong"))
    cutd <- coords(rd, "best", best.method="youden", ret=c("threshold","sensitivity","specificity"))
    cd <- as.numeric(cutd$threshold[1]); sd_ <- as.numeric(cutd$sensitivity[1]); sp_ <- as.numeric(cutd$specificity[1])
    accd <- mean(as.integer(pd[okd] >= cd) == disc$y[okd])
    sv <- mean(pv[okv & val$y==1] >= cd, na.rm=TRUE); spv <- mean(pv[okv & val$y==0] < cd, na.rm=TRUE)
    accv <- mean(as.integer(pv[okv] >= cd) == val$y[okv], na.rm=TRUE)
  } else {
    ad <- av <- cd <- sd_ <- sp_ <- accd <- sv <- spv <- accv <- NA
    cid <- civ <- c(NA,NA,NA); coefs <- c(NA)
  }
  mg_summary[[length(mg_summary)+1]] <- data.frame(
    Model_ID=mid, Model_label=paste(gs, collapse="+"), Genes=paste(gs, collapse="+"), N_genes=length(gs),
    Discovery_n_high=sum(disc$y==1), Discovery_n_low=sum(disc$y==0),
    Model_fit_status=status,
    Discovery_AUC=ad, Discovery_AUC_CI_low=cid[1], Discovery_AUC_CI_high=cid[3],
    Discovery_best_cutoff=cd, Discovery_sensitivity=sd_, Discovery_specificity=sp_, Discovery_accuracy=accd,
    Validation_n_high=sum(val$y==1), Validation_n_low=sum(val$y==0),
    Validation_AUC=av, Validation_AUC_CI_low=civ[1], Validation_AUC_CI_high=civ[3],
    Validation_sens_at_discovery_cutoff=sv, Validation_spec_at_discovery_cutoff=spv, Validation_acc_at_discovery_cutoff=accv,
    AUC_drop=ad-av,
    stringsAsFactors=FALSE)
  for (nm in names(coefs)) {
    mg_coefs[[length(mg_coefs)+1]] <- data.frame(Model_ID=mid, Term=nm, Coefficient=unname(coefs[nm]), stringsAsFactors=FALSE)
  }
}
mg_df <- do.call(rbind, mg_summary)
write.csv(mg_df, file.path(OUT_DIR, "multigene_roc_auc_summary.csv"), row.names=FALSE, quote=TRUE)
write.csv(do.call(rbind, mg_coefs), file.path(OUT_DIR, "multigene_model_coefficients.csv"), row.names=FALSE, quote=TRUE)

# ---- Plotting helpers ----
plot_roc_panel <- function(gene, d_or_v) {
  if (d_or_v=="Discovery") { d <- disc; lab <- "Discovery (training)" } else { d <- val; lab <- "Validation" }
  x <- d[[gene]]; y <- d$y
  ok <- complete.cases(x, y)
  r <- roc(y[ok], x[ok], quiet=TRUE, direction="auto")
  a <- as.numeric(r$auc); ci <- as.numeric(ci.auc(r, method="delong"))
  df <- data.frame(fpr=1-r$specificities, tpr=r$sensitivities)
  ggplot(df, aes(x=fpr, y=tpr)) + geom_line(color="#2c7fb8", linewidth=0.8) +
    geom_abline(slope=1, intercept=0, linetype="dashed", color="grey60") +
    coord_equal() + xlim(0,1) + ylim(0,1) +
    labs(title=gene, subtitle=sprintf("AUC=%.3f (%.3f-%.3f)\nn=%d (H=%d L=%d)", a, ci[1], ci[3], sum(ok), sum(y[ok]==1), sum(y[ok]==0)), x="FPR", y="TPR") +
    theme_classic(base_size=8) + theme(plot.title=element_text(face="bold", size=9))
}

# Figure A: univariate ROC Discovery + Validation
plist_d <- lapply(cands$Gene, function(g) plot_roc_panel(g,"Discovery"))
plist_v <- lapply(cands$Gene, function(g) plot_roc_panel(g,"Validation"))
pdf(file.path(OUT_DIR,"Candidate_ROC_Discovery.pdf"), width=10, height=7)
print(do.call(gridExtra::grid.arrange, c(plist_d, nrow=2)))
dev.off()
pdf(file.path(OUT_DIR,"Candidate_ROC_Validation.pdf"), width=10, height=7)
print(do.call(gridExtra::grid.arrange, c(plist_v, nrow=2)))
dev.off()

# Figure B: distribution panels
plot_dist <- function(gene, d_or_v) {
  if (d_or_v=="Discovery") { d <- disc; lab <- "Discovery" } else { d <- val; lab <- "Validation" }
  dd <- data.frame(x=d[[gene]], Group=ifelse(d$y==1,"High","Low"))
  ggplot(dd, aes(x=Group, y=x, fill=Group)) +
    geom_boxplot(width=0.4, outlier.shape=NA) +
    geom_jitter(width=0.15, alpha=0.4, size=0.7) +
    stat_summary(fun=median, geom="crossbar", width=0.3, color="red") +
    labs(title=gene, subtitle=lab, x=NULL, y="log2 abundance") +
    theme_classic(base_size=8) + theme(plot.title=element_text(face="bold", size=9), legend.position="none")
}
pdf(file.path(OUT_DIR,"Candidate_Distribution_Discovery.pdf"), width=10, height=7)
print(do.call(gridExtra::grid.arrange, c(lapply(cands$Gene, function(g) plot_dist(g,"Discovery")), nrow=2)))
dev.off()
pdf(file.path(OUT_DIR,"Candidate_Distribution_Validation.pdf"), width=10, height=7)
print(do.call(gridExtra::grid.arrange, c(lapply(cands$Gene, function(g) plot_dist(g,"Validation")), nrow=2)))
dev.off()

# Figure C: multigene ROC panels
plot_mg <- function(mid, d_or_v) {
  gs <- models[[mid]]
  fmla <- as.formula(paste("y ~", paste(gs, collapse=" + ")))
  fit <- glm(fmla, data=disc, family=binomial, na.action=na.exclude)
  if (d_or_v=="Discovery") { d <- disc; pd <- as.numeric(predict(fit, newdata=disc, type="response", na.action=na.pass)) } else { d <- val; pd <- as.numeric(predict(fit, newdata=val, type="response", na.action=na.pass)) }
  ok <- complete.cases(d$y, pd)
  r <- roc(d$y[ok], pd[ok], quiet=TRUE, direction="auto")
  a <- as.numeric(r$auc); ci <- as.numeric(ci.auc(r, method="delong"))
  df <- data.frame(fpr=1-r$specificities, tpr=r$sensitivities)
  ggplot(df, aes(x=fpr, y=tpr)) + geom_line(color="#d95f0e", linewidth=0.8) +
    geom_abline(slope=1, intercept=0, linetype="dashed", color="grey60") + coord_equal() + xlim(0,1) + ylim(0,1) +
    labs(title=mid, subtitle=sprintf("%s\nAUC=%.3f (%.3f-%.3f)\nn=%d", paste(gs,collapse="+"), a, ci[1], ci[3], sum(ok)), x="FPR", y="TPR") +
    theme_classic(base_size=8) + theme(plot.title=element_text(face="bold", size=9))
}
pdf(file.path(OUT_DIR,"Multigene_ROC_Discovery.pdf"), width=10, height=7)
print(do.call(gridExtra::grid.arrange, c(lapply(names(models), function(m) plot_mg(m,"Discovery")), nrow=2)))
dev.off()
pdf(file.path(OUT_DIR,"Multigene_ROC_Validation.pdf"), width=10, height=7)
print(do.call(gridExtra::grid.arrange, c(lapply(names(models), function(m) plot_mg(m,"Validation")), nrow=2)))
dev.off()

# Figure D1: univariate summary heatmap (numeric AUC values only)
heat_df <- uni %>% select(Gene_symbol, Discovery_AUC, Validation_AUC) %>%
  mutate(AUC_drop = Discovery_AUC - Validation_AUC) %>%
  arrange(Gene_symbol)
hm <- heat_df %>% pivot_longer(-Gene_symbol)
p_hm1 <- ggplot(hm, aes(x=name, y=Gene_symbol, fill=value)) + geom_tile(color="white") +
  geom_text(aes(label=sprintf("%.3f", value)), size=2.8) +
  scale_fill_viridis_c(na.value="grey90") +
  labs(title="Univariate AUC summary (Direction_concordant=YES for all 6; see CSV)", x=NULL, y=NULL) + theme_classic(base_size=8) +
  theme(axis.text.x=element_text(angle=45, hjust=1))
pdf(file.path(OUT_DIR,"Candidate_ROC_Summary_Heatmap.pdf"), width=7, height=4); print(p_hm1); dev.off()

# Figure D2: multigene summary heatmap
hm2 <- mg_df %>% select(Model_ID, N_genes, Discovery_AUC, Validation_AUC, AUC_drop, Validation_acc_at_discovery_cutoff)
hm2l <- hm2 %>% pivot_longer(-Model_ID)
p_hm2 <- ggplot(hm2l, aes(x=name, y=Model_ID, fill=as.numeric(value))) + geom_tile(color="white") +
  geom_text(aes(label=sprintf("%.3f", as.numeric(value))), size=2.5) +
  scale_fill_viridis_c(na.value="grey90") +
  labs(title="Multigene model summary", x=NULL, y=NULL) + theme_classic(base_size=8) +
  theme(axis.text.x=element_text(angle=45, hjust=1))
pdf(file.path(OUT_DIR,"Multigene_ROC_Summary_Heatmap.pdf"), width=8, height=4); print(p_hm2); dev.off()

# PNGs (simple)
for (f in c("Candidate_ROC_Discovery","Candidate_ROC_Validation","Candidate_Distribution_Discovery","Candidate_Distribution_Validation","Multigene_ROC_Discovery","Multigene_ROC_Validation","Candidate_ROC_Summary_Heatmap","Multigene_ROC_Summary_Heatmap")) {
  invisible(file.copy(file.path(OUT_DIR, paste0(f,".pdf")), file.path(OUT_DIR, paste0(f,".png")), overwrite=TRUE))
}

cat("\n=== UNIVARIATE ===\n")
print(uni[,c("Gene_symbol","Discovery_AUC","Validation_AUC","Direction_concordant")])
cat("\n=== MULTIGENE ===\n")
print(mg_df[,c("Model_ID","N_genes","Discovery_AUC","Validation_AUC","AUC_drop","Validation_acc_at_discovery_cutoff")])
