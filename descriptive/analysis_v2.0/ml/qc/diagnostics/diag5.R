library(readxl); library(glmnet)
ROOT <- "F:/env"; setwd(ROOT)
ss <- read.csv("descriptive/sample_statistics.csv", stringsAsFactors=FALSE)
ch <- function(x){x<-trimws(as.character(x));sub("\\.0$","",x)}
ss$clean <- ch(ss$Sheet1_raw_header)
sm <- read.csv("descriptive/discovery_validation_split/discovery_validation_assignment.csv", stringsAsFactors=FALSE)
disc <- sm[sm$Split=="Discovery",]; disc$y <- as.integer(disc$TREAT1_clean!="control")
raw <- read_excel("rawdata/processed.xlsx", n_max=3817, .name_repair="minimal")
abund <- as.data.frame(raw[,8:ncol(raw)]); rownames(abund) <- raw$PG.ProteinGroups
f3 <- read.csv("descriptive/analysis_v2.0/registry/contaminant_candidate_registry.csv", stringsAsFactors=FALSE)
excl <- f3$PG.ProteinGroups[f3$Primary_exclusion_eligible=="TRUE"]
abund_u <- abund[!rownames(abund)%in%excl,]
ss_d <- ss[match(disc$UniqueSampleID,ss$UniqueSampleID),]
dpos <- match(ss_d$clean, ss$clean)
X_all <- t(abund_u[,dpos]); colnames(X_all)<-rownames(abund_u); rownames(X_all)<-disc$UniqueSampleID

of <- read.csv("descriptive/analysis_v2.0/ml/folds/outer_folds.csv", stringsAsFactors=FALSE)
rep1 <- of[of$Repeat==1,]
ts <- rep1$Participant_ID[rep1$Outer_fold==1]
tr <- rep1$Participant_ID[rep1$Outer_fold!=1]
cat("Train:",length(tr),"Test:",length(ts),"\n")

# Eligibility
is_det <- function(x) is.finite(x)&x>0
grp <- disc$TREAT1_clean[match(tr,disc$UniqueSampleID)]
e <- rep(TRUE,ncol(X_all)); names(e)<-colnames(X_all)
for(g in c("control","low","high")){
  gs <- tr[grp==g]; th <- ceiling(0.70*length(gs))
  e <- e & (colSums(is_det(X_all[gs,,drop=FALSE]))>=th)
}
ep <- names(e)[e]
cat("Eligible:",length(ep),"\n")

xot <- X_all[tr,ep,drop=FALSE]; yot <- disc$y[match(tr,disc$UniqueSampleID)]
# prep
med <- apply(xot,2,median,na.rm=TRUE); imp <- xot
for(j in 1:ncol(imp))imp[is.na(imp[,j]),j]<-med[j]
mu<-colMeans(imp);sd<-apply(imp,2,sd);zv<-is.na(sd)|sd==0
kp<-!zv
xt <- imp[,kp,drop=FALSE]
for(j in 1:ncol(xt))xt[,j]<-(xt[,j]-mu[kp][j])/sd[kp][j]
cat("xt dim:",dim(xt),"any NA:",any(is.na(xt)),"\n")

# Test prep
xotest <- X_all[ts,ep,drop=FALSE]
imp2 <- xotest
for(j in 1:ncol(imp2))imp2[is.na(imp2[,j]),j]<-med[j]
xte <- imp2[,kp,drop=FALSE]
for(j in 1:ncol(xte))xte[,j]<-(xte[,j]-mu[kp][j])/sd[kp][j]
cat("xte dim:",dim(xte),"any NA:",any(is.na(xte)),"\n")
cat("colnames match:",all(colnames(xt)==colnames(xte)),"\n")

fit <- glmnet(xt, yot, family="binomial", alpha=0.1, nlambda=50, standardize=FALSE)
cat("Fit lambda[1]:",fit$lambda[1]," a0[1]:",fit$a0[1],"\n")
pred1 <- as.numeric(predict(fit, newx=xte, s=fit$lambda[1], type="response"))
cat("lambda[1] predict: mean=",mean(pred1),"range:",min(pred1),max(pred1),"\n")
pred10 <- as.numeric(predict(fit, newx=xte, s=fit$lambda[10], type="response"))
cat("lambda[10] predict: mean=",mean(pred10),"range:",min(pred10),max(pred10),"\n")
