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

# Simple: fit on first 300, predict last 86
tr <- 1:300; te <- 301:386
xtr <- X_all[tr,1:100,drop=FALSE]; ytr <- disc$y[tr]
xte <- X_all[te,1:100,drop=FALSE]; yte <- disc$y[te]
# median impute + scale
med <- apply(xtr,2,median,na.rm=TRUE)
for(j in 1:ncol(xtr))xtr[is.na(xtr[,j]),j]<-med[j]
for(j in 1:ncol(xte))xte[is.na(xte[,j]),j]<-med[j]
mu<-colMeans(xtr);sd<-apply(xtr,2,sd)
for(j in 1:ncol(xtr))xtr[,j]<-(xtr[,j]-mu[j])/sd[j]
for(j in 1:ncol(xte))xte[,j]<-(xte[,j]-mu[j])/sd[j]
xtr[is.na(xtr)]<-0;xte[is.na(xte)]<-0;fit<-glmnet(xtr,ytr,family="binomial",alpha=0.5,nlambda=20)
pred<-as.numeric(predict(fit,newx=xte,s=fit$lambda[5],type="response"))
cat("Test predict range:",min(pred),max(pred),"mean:",mean(pred),"\n")
cat("Test y distribution: table(yte)\n");print(table(yte))
# Also check lambda[1] (max penalty)
pred0<-as.numeric(predict(fit,newx=xte,s=fit$lambda[1],type="response"))
cat("Lambda[1] predict: mean=",mean(pred0),"range:",min(pred0),max(pred0),"\n")
cat("a0[1]=",fit$a0[1]," plogis=",plogis(fit$a0[1]),"\n")
