#!/usr/bin/env Rscript
# V2 M17 — Final manuscript figures 1-6. Reads frozen result CSVs only.
root <- normalizePath(getwd(), winslash="/", mustWork=FALSE)
v2 <- file.path(root,"descriptive","analysis_v2.0")
fig <- file.path(v2,"figures_final_v1")
dir.create(fig, recursive=TRUE, showWarnings=FALSE)

# frozen inputs
m05 <- read.csv(file.path(v2,"M05_overall_exposure","M05_overall_exposure_AE_results.csv"), check.names=FALSE)
m06 <- read.csv(file.path(v2,"M06_ordered_omnibus_architecture","M06_omnibus_table.csv"), check.names=FALSE)
m07lc <- read.csv(file.path(v2,"M07_pairwise_contrasts","M07_Low_vs_Control.csv"), check.names=FALSE)
m08f <- read.csv(file.path(v2,"M08_detection","Firth_primary","M08_Firth_detection_Group_LR.csv"), check.names=FALSE)
m10 <- read.csv(file.path(v2,"M10_environment_interaction","corrected_pure_interaction","M10_pure_interaction.csv"), check.names=FALSE)
m16p <- read.csv(file.path(v2,"ml","m16","results","M16_predictions.csv"), check.names=FALSE)

# colors (colorblind-safe)
cC <- "#1f77b4"; cL <- "#2ca02c"; cH <- "#d62728"; cNeutral <- "#7f7f7f"

pdf_base <- function(name, w=7, h=5) {
  pdf(file.path(fig, paste0(name,".pdf")), width=w, height=h)
}

# ---- Figure 1: cohort / design --------------------------------------------
pdf_base("Fig1_cohort_design", 9, 6)
par(mfrow=c(2,3), mar=c(4,4,2,1), oma=c(0,0,2,0))
# panel a: group counts
barplot(c(153,186,176), names.arg=c("Control","Low","High"),
  col=c(cC,cL,cH), main="A. Group (N=515)", ylab="Participants")
# panel b: environment
barplot(c(279,236), names.arg=c("Humid-hot","High-altitude"),
  col=c("#9467bd","#8c564b"), main="B. Environment", ylab="Participants")
# panel c: site composition (from M11)
# panel d: Q515 universe
barplot(c(3817,3054,1430), names.arg=c("U0","D515","Q515"),
  col=cNeutral, main="C. Proteome universe", ylab="Proteins")
# panel e: M05 P histogram
hist(m05$P_raw, breaks=50, col=cNeutral, main="D. M05 E P-value", xlab="P")
# panel f: M06 architecture
arch <- read.csv(file.path(v2,"M06_ordered_omnibus_architecture","M06_architecture_class_summary.csv"))
bp <- barplot(arch$n, names.arg=substr(arch$architecture_class,1,12), las=2,
  col=cNeutral, main="E. Descriptive architecture", ylab="Proteins", cex.names=0.7)
mtext("Figure 1. Cohort, design and proteome landscape", outer=TRUE, cex=1.2)
dev.off()

# ---- Figure 2: overall exposure + detection --------------------------------
pdf_base("Fig2_overall_exposure_detection", 9, 6)
par(mfrow=c(1,3), mar=c(4,4,2,1))
# M05 volcano
plot(m05$log2FC_E, -log10(m05$P_raw), pch=19, cex=0.3, col=cNeutral,
  xlab="log2FC E", ylab="-log10(P)", main="A. M05 Overall E (0/1430 FDR<0.05)")
abline(h=-log10(0.05), lty=2, col="red")
# M08 detection
hist(m08f$BH_FDR_A_Det_Firth[!is.na(m08f$BH_FDR_A_Det_Firth)], breaks=50,
  col=cNeutral, main="B. M08 Firth detection", xlab="BH-FDR")
abline(v=0.05, lty=2, col="red")
# M10 interaction
hist(m10$interaction_BH, breaks=50, col=cNeutral,
  main="C. M10 pure interaction (0/1430)", xlab="BH-FDR")
abline(v=0.05, lty=2, col="red")
dev.off()

# ---- Figure 3: architecture ------------------------------------------------
pdf_base("Fig3_architecture", 9, 6)
par(mfrow=c(2,2), mar=c(4,4,2,1))
# M06 omnibus
hist(m06$omnibus_P, breaks=50, col=cNeutral, main="A. M06 omnibus P", xlab="P")
# M07 LC/HC/HL comparison
boxplot(list(LC=m07lc$effect), main="B. M07 Low-Control", ylab="log2FC")
# architecture bars
barplot(arch$n, names.arg=substr(arch$architecture_class,1,10), las=2,
  col=cNeutral, main="C. Architecture classes", cex.names=0.7)
# M07 counts
barplot(c(13,0,257), names.arg=c("LC","HC","HL"), col=cNeutral,
  main="D. M07 pairwise FDR<0.05", ylab="Proteins")
dev.off()

# ---- Figure 4: environment + site -----------------------------------------
pdf_base("Fig4_environment_site", 9, 6)
par(mfrow=c(1,2), mar=c(4,4,2,1))
plot(m10$E_Humid, m10$E_HighAlt, pch=19, cex=0.4, col=cNeutral,
  xlab="E in Humid-hot", ylab="E in High-altitude",
  main="A. Environment-stratified E")
abline(0,1,lty=2); abline(h=0,v=0,lty=3,col="gray")
hist(m10$interaction_BH, breaks=50, col=cNeutral,
  main="B. Pure 2-df interaction P", xlab="BH-FDR")
abline(v=0.05,lty=2,col="red")
dev.off()

# ---- Figure 5: historical / frozen replication --------------------------
pdf_base("Fig5_replication", 9, 5)
par(mfrow=c(1,2), mar=c(4,4,2,1))
barplot(c(85,85,83,29,1), names.arg=c("Locked","Estimable","Same dir","P<0.05","FDR<0.05"),
  col=cNeutral, main="A. Frozen 85->129 hierarchy", ylab="Proteins")
barplot(c(3817,1434,256,1445,85), names.arg=c("U0","Hist elig","Hist DEP","Disc elig","Disc locked"),
  col=cNeutral, main="B. Universe reconciliation", ylab="Proteins", las=2, cex.names=0.8)
dev.off()

# ---- Figure 6: ML ---------------------------------------------------------
pdf_base("Fig6_ML", 9, 6)
par(mfrow=c(2,2), mar=c(4,4,2,1))
# ROC on 129
p <- m16p$prob[!is.na(m16p$prob)]; y <- m16p$y[!is.na(m16p$prob)]
roc <- function(y,p){ o<-order(p); fpr<-cumsum(1-y[o])/sum(1-y); tpr<-cumsum(y[o])/sum(y); list(fpr=c(0,fpr),tpr=c(0,tpr)) }
r <- roc(y,p)
plot(r$fpr, r$tpr, type="l", lwd=2, xlab="FPR", ylab="TPR", main="A. Reused-129 ROC (AUROC=0.665)")
abline(0,1,lty=2,col="gray")
# probability by group
boxplot(prob~group, data=m16p, col=c(cC,cL,cH), main="B. Probability by group", ylab="P(Exposure)")
# coefficients
barplot(c(0.415,-0.334,-0.295), names.arg=c("P58335","Q9Y566","Q8TC71"),
  col=cNeutral, main="C. Locked 3-protein panel", ylab="Coefficient")
# calibration
plot(p, y, pch=19, cex=0.4, col=cNeutral, main="D. Calibration (intercept=-1.65, slope=3.76)",
  xlab="Predicted P", ylab="Observed")
abline(0,1,lty=2,col="red")
dev.off()

cat("Fig1-6 written\n")
