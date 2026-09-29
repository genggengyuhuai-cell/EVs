# Minimal test: replicate v5's prediction path for one fold
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
rep1 <- of[of$Repeat==1 & of$Outer_fold==1,]
ts <- rep1$Participant_ID
tr <- of$Participant_ID[of$Repeat==1 & of$Outer_fold!=1]

is_det <- function(x) is.finite(x)&x>0
grp <- disc$TREAT1_clean[match(tr,disc$UniqueSampleID)]
e <- rep(TRUE,ncol(X_all)); names(e)<-colnames(X_all)
for(g in c("control","low","high")){
  gs <- tr[grp==g]; th <- ceiling(0.70*length(gs))
  e <- e & (colSums(is_det(X_all[gs,,drop=FALSE]))>=th)
}
ep <- names(e)[e]
xot <- X_all[tr,ep,drop=FALSE]; yot <- disc$y[match(tr,disc$UniqueSampleID)]

# Same fit_prep and aply as v5
fit_prep <- function(mat) {
  med <- apply(mat,2,median,na.rm=TRUE); imp <- mat
  for(j in 1:ncol(imp)) imp[is.na(imp[,j]),j] <- med[j]
  mu <- colMeans(imp); sd <- apply(imp,2,sd); zv <- is.na(sd)|sd==0
  list(med=med,mu=mu,sd=sd,zv=zv)
}
aply <- function(mat,p) {
  o <- mat
  for(j in 1:ncol(o)) o[is.na(o[,j]),j] <- p$med[j]
  for(j in 1:ncol(o)) o[,j] <- (o[,j]-p$mu[j])/p$sd[j]
  o
}
pp <- fit_prep(xot); kp <- !pp$zv
xt <- aply(xot,pp)[,kp,drop=FALSE]
cat("xt dim:",dim(xt)," anyNA:",any(is.na(xt))," anyNaN:",any(is.nan(as.matrix(xt))),"\n")

xotest <- X_all[ts,ep,drop=FALSE]
xte <- aply(xotest,pp)[,kp,drop=FALSE]
cat("xte dim:",dim(xte)," anyNA:",any(is.na(xte))," anyNaN:",any(is.nan(as.matrix(xte))),"\n")
cat("colnames match:",all(colnames(xt)==colnames(xte)),"\n")

ff <- glmnet(xt, yot, family="binomial", alpha=0.1, nlambda=50, standardize=FALSE)
cat("nlambda:",length(ff$lambda)," a0[1]:",ff$a0[1],"\n")
pred1 <- as.numeric(predict(ff, newx=xte, s=ff$lambda[1], type="response"))
cat("lambda[1]: mean=",mean(pred1)," range:",min(pred1),max(pred1),"\n")
# Try without s=
pred_all <- predict(ff, newx=xte, type="response")
cat("predict all lambda: dim=",dim(pred_all)," mean at col1:",mean(pred_all[,1]),"\n")
