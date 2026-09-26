#!/usr/bin/env Rscript
source(file.path(dirname(normalizePath(sub("^--file=", "", commandArgs(FALSE)[grep("^--file=", commandArgs(FALSE))]))), "dv_shared.R"))
dv_require(c("limma","statmod","digest")); hash<-dv_assert_candidate_hash(); stage<-"D05_environment_specific"; outdir<-dv_stage_dir(stage)
meta<-dv_assignment("Discovery"); ef<-file.path(dv_stage_dir("D01_discovery_eligibility"),"D01_discovery_eligible_expression.csv.gz"); all_expr<-dv_read_expression(ef,meta$UniqueSampleID,TRUE)
lock<-dv_read_csv(file.path(dv_stage_dir("D03_candidate_lock"),"D03_locked_candidates.csv"),"PG.ProteinGroups"); expr<-all_expr[match(lock$PG.ProteinGroups,rownames(all_expr)),,drop=FALSE]
ans<-list(); counts<-list()
for(env in DV_ENV){keep<-meta$Environment==env;m<-droplevels(meta[keep,,drop=FALSE]);x<-expr[,keep,drop=FALSE];m$dose<-factor(m$TREAT1_clean,levels=DV_DOSE);d<-model.matrix(~0+dose,m);colnames(d)<-make.names(colnames(d));
 counts[[env]]<-as.data.frame(table(Environment=rep(env,nrow(m)),Dose=factor(m$TREAT1_clean,levels=DV_DOSE))); if(qr(d)$rank<ncol(d)){z<-expand.grid(PG.ProteinGroups=rownames(x),Contrast=c("Short_vs_Control","Long_vs_Control","Long_vs_Short"));z$Model_status<-"NON_ESTIMABLE";ans[[env]]<-z}else{z<-dv_fit(x,d,dv_three_contrasts(d),family_n=nrow(x));z$Environment<-env;ans[[env]]<-z}}
r<-do.call(rbind,ans); r$Secondary_BH_FDR<-ave(r$P_value,r$Environment,r$Contrast,FUN=function(p)p.adjust(p,"BH",n=nrow(expr)))
paths<-file.path(outdir,c("D05_candidate_environment_results.csv","D05_environment_dose_counts.csv","D05_manifest.csv"));dv_no_overwrite(paths);dv_write(dv_add_annotation(r),paths[1]);dv_write(do.call(rbind,counts),paths[2]);dv_write(dv_manifest(stage,c(ef,file.path(dv_stage_dir("D03_candidate_lock"),"D03_locked_candidates.csv")),paths[1:2],list(candidate_hash=hash,multiplicity="BH separately per Environment x contrast; investigator approval required before execution")),paths[3])
