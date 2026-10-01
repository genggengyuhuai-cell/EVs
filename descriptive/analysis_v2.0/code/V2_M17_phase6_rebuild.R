#!/usr/bin/env Rscript
# Phase 6 rebuild — re-render Fig3/4/5 from repaired outputs + redesigned Fig6.
# Rendering only: reads repaired canonical CSVs; no model refit, no new statistics.
setwd("F:/env")
suppressPackageStartupMessages({
  library(ggplot2); library(patchwork); library(dplyr); library(tidyr)
  library(scales)
})
root <- normalizePath(getwd(), winslash = "/", mustWork = TRUE)
source(file.path(root, "descriptive", "figure_display_labels.R"), local = TRUE)
v2 <- file.path(root, "descriptive", "analysis_v2.0")
fig_dir <- file.path(v2, "figures_final_v2")
dir.create(fig_dir, recursive = TRUE, showWarnings = FALSE)
read_result <- function(...) read.csv(file.path(v2, ...), check.names = FALSE)

# ---- inputs (repaired canonical outputs) ----
m06_means <- read_result("M06_ordered_omnibus_architecture", "M06_adjusted_means_architecture_table.csv")
m09 <- read_result("M09_missingness_sensitivity", "KNN_sensitivity", "M09_KNN_E_comparison.csv")
m10 <- read_result("M10_environment_interaction", "corrected_pure_interaction", "M10_pure_interaction.csv")
m11_site <- read_result("M11_site_robustness", "M11_site_composition.csv"); names(m11_site)[1] <- "Site"
m11_loo <- read_result("M11_site_robustness", "M11_site_LOO_stability.csv")
m14 <- read_result("M14_frozen_replication", "M14_replication_hierarchy.csv")
ml85 <- read_result("ml_v2.1", "results", "integrated_table_85.csv")
ml_cv <- read_result("ml_v2.1", "results", "outer_cv_metrics.csv")
strict_cv <- read_result("ml_v2.1", "strict_nested", "strict_nested_outer_metrics.csv")
ranked <- read_result("M12_pathway_v2.1", "ranked", "M12_ranked_combined_FDR.csv")
ora <- read_result("M12_pathway_v2.1", "ora", "M12_ORA_combined_FDR.csv")
redund <- read_result("M12_pathway_v2.1", "integration", "M12_pathway_redundancy_clusters.csv")
path_member <- read_result("M12_pathway_v2.1", "integration", "M12_ML_candidate_pathway_membership.csv")

# Phase7: Reactome human-readable names for Fig6b y-axis labels (annotation lookup only; no analysis).
# Use loadNamespace + :: so AnnotationDbi is NOT attached (its select() would mask dplyr::select).
suppressPackageStartupMessages(loadNamespace("reactome.db"))
.rxdb <- get("reactome.db", envir=asNamespace("reactome.db"))
.rx_map <- AnnotationDbi::select(.rxdb,
  keys=unique(ranked$pathway_id[ranked$database=="Reactome"]),
  columns="PATHNAME", keytype="PATHID")
.rx_map$PATHNAME <- sub("^Homo sapiens: ", "", .rx_map$PATHNAME)
rx_name <- setNames(.rx_map$PATHNAME, .rx_map$PATHID)
rx_annot_version <- as.character(packageVersion("reactome.db"))

pal <- c(Control="#A6A6A6", Low="#4A85B3", High="#FF6347",
         Humid_hot="#B266C4", High_altitude="#4BBEB6",
         positive="#FF6347", negative="#4A85B3", neutral="#A6A6A6",
         dark="#2F3337", light="#D8DDE2", accent="#FFB84D")
theme_m17 <- function(base_size=7.2){ theme_classic(base_size=base_size, base_family="Arial") +
  theme(axis.line=element_line(linewidth=0.35,colour=pal[["dark"]]),
        axis.ticks=element_line(linewidth=0.35,colour=pal[["dark"]]),
        axis.text=element_text(colour=pal[["dark"]],size=base_size-0.4),
        axis.title=element_text(colour=pal[["dark"]],size=base_size),
        legend.title=element_text(size=base_size-0.2,face="bold"),
        legend.text=element_text(size=base_size-0.5),
        strip.background=element_blank(),
        strip.text=element_text(size=base_size,face="bold",colour=pal[["dark"]]),
        plot.title=element_text(size=base_size+0.5,face="bold",hjust=0),
        plot.subtitle=element_text(size=base_size-0.2,colour="#555555"),
        panel.grid.major.y=element_line(linewidth=0.22,colour="#ECECEC"),
        panel.grid.major.x=element_blank(),panel.grid.minor=element_blank(),
        plot.tag=element_text(size=base_size+1.8,face="bold"),
        plot.tag.position=c(0,1),plot.margin=margin(5,6,5,6)) }
theme_set(theme_m17())
write_source <- function(x, stem) write.csv(x, file.path(fig_dir, paste0(stem,"_source_data.csv")), row.names=FALSE, na="")
save_figure <- function(plot, stem, width_mm=183, height_mm=130){
  w<-width_mm/25.4; h<-height_mm/25.4
  svglite::svglite(file.path(fig_dir,paste0(stem,".svg")),width=w,height=h,bg="white"); print(plot); dev.off()
  grDevices::cairo_pdf(file.path(fig_dir,paste0(stem,".pdf")),width=w,height=h,family="Arial",bg="white"); print(plot); dev.off()
  ragg::agg_png(file.path(fig_dir,paste0(stem,"_preview.png")),width=width_mm,height=height_mm,units="mm",res=300,background="white"); print(plot); dev.off()
}
short_label <- function(x,width=38) vapply(x,function(z) paste(strwrap(z,width=width),collapse="\n"),character(1))
safe_log10 <- function(x) -log10(pmax(x,.Machine$double.xmin))
cand_ids <- ml85$PG.ProteinGroups

# ============ FIG 3 (panel c rebuilt from repaired M09; a/b/d unchanged sources) ============
cand <- ml85 %>% transmute(PG.ProteinGroups, Gene=Display_label, Discovery_effect=Discovery_log2FC.x,
  Holdout_effect=log2FC, Holdout_low=CI_low, Holdout_high=CI_high,
  Replication=case_when(FDR_supported_replication~"FDR-supported", Nominal_replication~"Nominal",
    Direction_concordant~"Same direction", TRUE~"Discordant")) %>%
  left_join(m06_means %>% select(PG.ProteinGroups, adjusted_mean_Control, adjusted_mean_Low, adjusted_mean_High, descriptive_architecture_class), by="PG.ProteinGroups") %>%
  left_join(m09, by="PG.ProteinGroups") %>% arrange(Gene) %>% mutate(candidate_index=row_number())
p3a <- ggplot(cand, aes(Discovery_effect, candidate_index, colour=Discovery_effect>=0)) +
  geom_vline(xintercept=0,linewidth=0.35,linetype=2) +
  geom_segment(aes(x=0,xend=Discovery_effect,yend=candidate_index),linewidth=0.35,alpha=0.75)+geom_point(size=1.2)+
  scale_colour_manual(values=c(`FALSE`=pal[["negative"]],`TRUE`=pal[["positive"]]),guide="none")+
  scale_y_continuous(breaks=c(1,22,43,64,85))+
  labs(x="Discovery High - Low effect (log2 FC)",y="Candidate index (alphabetical)",title="Locked 85-protein effect landscape")
profiles <- cand %>% select(PG.ProteinGroups,Gene,candidate_index,adjusted_mean_Control,adjusted_mean_Low,adjusted_mean_High) %>%
  pivot_longer(starts_with("adjusted_mean_"),names_to="Group",values_to="adjusted_mean") %>%
  mutate(Group=factor(sub("adjusted_mean_","",Group),levels=c("Control","Low","High")),
         row_z=ave(adjusted_mean,PG.ProteinGroups,FUN=function(z) as.numeric(scale(z))))
p3b <- ggplot(profiles,aes(Group,candidate_index,fill=row_z))+geom_tile()+
  scale_fill_gradient2(low=pal[["negative"]],mid="white",high=pal[["positive"]],midpoint=0,limits=c(-1.2,1.2),oob=squish)+
  scale_y_continuous(breaks=c(1,22,43,64,85))+
  labs(x=NULL,y="Candidate index (alphabetical)",fill="Row z-score",title="Adjusted Control / Low / High profiles")+
  theme(legend.position="top")
p3c <- ggplot(cand,aes(E_primary,E_knn,colour=Replication))+
  geom_abline(slope=1,intercept=0,linewidth=0.35,linetype=2,colour="#777777")+geom_point(size=1.15,alpha=0.8)+
  scale_colour_manual(values=c("Discordant"=pal[["neutral"]],"Same direction"="#9CB7C3","Nominal"=pal[["accent"]],"FDR-supported"=pal[["positive"]]))+
  coord_equal()+
  labs(x="Primary overall-exposure effect E",y="impute.knn sensitivity effect E",
       title="Overall-exposure imputation sensitivity",
       subtitle="Prespecified impute.knn, full 515 cohort, Q515 universe; sensitivity, not validation",colour=NULL)+
  guides(colour=guide_legend(nrow=2,byrow=TRUE,override.aes=list(size=2)))+
  theme(legend.position="top",legend.text=element_text(size=5.4),legend.key.width=unit(2.5,"mm"))
cand_arch <- cand %>% count(descriptive_architecture_class,name="n") %>% arrange(n) %>% mutate(descriptive_architecture_class=factor(descriptive_architecture_class,levels=descriptive_architecture_class))
p3d <- ggplot(cand_arch,aes(descriptive_architecture_class,n))+geom_col(fill=pal[["neutral"]],width=0.72)+coord_flip()+
  geom_text(aes(label=n),hjust=-0.12,size=2.2)+scale_y_continuous(expand=expansion(mult=c(0,0.18)))+
  labs(x=NULL,y="Candidates",title="Candidate architecture")
fig3 <- ((p3a|p3b)/(p3c+p3d+plot_layout(widths=c(0.8,1.7))))+plot_annotation(tag_levels="a")
save_figure(fig3,"Fig3_candidate_biology",height_mm=150)
write_source(bind_rows(
  cand %>% transmute(panel="a_effect_landscape",PG.ProteinGroups,Gene,candidate_index,estimate=Discovery_effect,holdout_estimate=Holdout_effect,ci_low=Holdout_low,ci_high=Holdout_high,replication=Replication),
  profiles %>% transmute(panel="b_profiles",PG.ProteinGroups,Gene,candidate_index,category=Group,value=adjusted_mean,scaled_value=row_z),
  cand %>% transmute(panel="c_missingness",PG.ProteinGroups,Gene,primary_effect=E_primary,knn_effect=E_knn,difference=diff,replication=Replication),
  cand_arch %>% transmute(panel="d_architecture",category=descriptive_architecture_class,n)),"Fig3_candidate_biology")

# ============ FIG 4 (panel d rebuilt from repaired M11 LOO; a/b/c unchanged) ============
m10p <- m10 %>% mutate(candidate=PG.ProteinGroups %in% cand_ids)
p4a <- ggplot(m10p,aes(E_Humid,E_HighAlt))+
  geom_hline(yintercept=0,linewidth=0.3,colour="#BBBBBB")+geom_vline(xintercept=0,linewidth=0.3,colour="#BBBBBB")+
  geom_abline(slope=1,intercept=0,linewidth=0.35,linetype=2,colour="#777777")+
  geom_point(aes(colour=candidate),size=0.8,alpha=0.55)+
  scale_colour_manual(values=c(`FALSE`=pal[["neutral"]],`TRUE`=pal[["accent"]]))+coord_equal()+
  labs(x=paste("Overall exposure effect:",display_environment("Humid-hot")),
       y=paste("Overall exposure effect:",display_environment("High-pressure/high-altitude")),
       title="Environment-stratified estimates",colour="Locked 85")+theme(legend.position="top")
interaction_df <- m10p %>% mutate(fdr_bin=cut(interaction_BH,breaks=c(0,.05,.25,.5,.75,1),include.lowest=TRUE)) %>% count(fdr_bin,name="n")
p4b <- ggplot(interaction_df,aes(fdr_bin,n))+geom_col(fill=pal[["neutral"]],width=0.72)+
  geom_text(aes(label=n),vjust=-0.35,size=2.3)+scale_y_continuous(expand=expansion(mult=c(0,0.13)))+
  labs(x="Pure 2-df interaction BH-FDR",y="Proteins",title="Formal interaction evidence",subtitle="0/1,430 at BH-FDR < 0.05")
site_df <- m11_site %>% pivot_longer(c(Control,Low,High),names_to="Group",values_to="n") %>%
  mutate(Group=factor(Group,levels=c("Control","Low","High")))
p4c <- ggplot(site_df,aes(reorder(Site,n,FUN=sum),n,fill=Group))+geom_col(width=0.75)+coord_flip()+
  scale_fill_manual(values=pal[c("Control","Low","High")])+
  labs(x=NULL,y="Participants",title="Site x Group composition",fill="Group")+theme(legend.position="top")
loo_plot <- m11_loo %>% mutate(candidate=PG.ProteinGroups %in% cand_ids, consistency=ifelse(loo_dir_consistent,"Direction consistent","Direction changed"))
p4d <- ggplot(loo_plot,aes(E_loo_max_shift,fill=consistency))+
  geom_histogram(bins=35,position="identity",alpha=0.72,colour="white",linewidth=0.15)+
  scale_fill_manual(values=c("Direction consistent"=pal[["negative"]],"Direction changed"=pal[["light"]]))+
  labs(x="Maximum absolute LOO shift (log2 FC)",y="Proteins",title="Leave-one-site-out influence",
       subtitle="Primary-contract adjusted LOO; robustness, not proof of no site heterogeneity",fill=NULL)+theme(legend.position="top")
fig4 <- ((p4a+p4b+plot_layout(widths=c(0.8,1.7)))/(p4c+p4d+plot_layout(widths=c(1,1.15))))+plot_annotation(tag_levels="a")
save_figure(fig4,"Fig4_environment_site",height_mm=145)
write_source(bind_rows(
  m10p %>% transmute(panel="a_environment",PG.ProteinGroups,Display_label,humid_effect=E_Humid,high_altitude_effect=E_HighAlt,interaction_p=interaction_P,interaction_fdr=interaction_BH,direction_concordant=dir_concordant,candidate),
  interaction_df %>% transmute(panel="b_interaction",category=fdr_bin,n),
  site_df %>% transmute(panel="c_site",category=Site,group=Group,n),
  loo_plot %>% transmute(panel="d_loo",PG.ProteinGroups,full_effect=E_full,max_shift=E_loo_max_shift,effect_range=E_loo_range,direction_consistent=loo_dir_consistent,candidate)),"Fig4_environment_site")

# ============ FIG 5 (fixed-85 vs strict nested SEPARATE; strict conditional on 8 fit folds) ============
m14p <- m14 %>% mutate(stage=factor(stage,levels=rev(stage)))
p5a <- ggplot(m14p,aes(stage,n))+geom_col(fill=pal[["neutral"]],width=0.7)+coord_flip()+
  geom_text(aes(label=n),hjust=-0.15,size=2.35)+scale_y_continuous(limits=c(0,96),expand=c(0,0))+
  labs(x=NULL,y="Proteins (denominator = 85)",title="Reused hold-out replication hierarchy")
# fixed-85: all 15 folds fit
fixed_cv <- bind_rows(
  ml_cv %>% transmute(strategy="Fixed-85 conditional ML",method="LASSO",AUROC=lasso_auroc),
  ml_cv %>% transmute(strategy="Fixed-85 conditional ML",method="XGBoost",AUROC=xgb_auroc))
# strict nested: performance shown only on the 8 folds that fit a model; 7 zero-feature folds annotated
strict_fit <- strict_cv %>% filter(n_features_ml>0)
strict_cv_long <- bind_rows(
  strict_fit %>% transmute(strategy="Strict nested ML",method="LASSO",AUROC=lasso_auroc),
  strict_fit %>% transmute(strategy="Strict nested ML",method="Elastic Net",AUROC=en_auroc))
cv_plot <- bind_rows(fixed_cv, strict_cv_long)
ann_df <- data.frame(strategy="Strict nested ML",method="LASSO",AUROC=0.40,
                     label="7/15 outer folds:\nno features at threshold\n(points = 8 fit folds)")
p5b <- ggplot(cv_plot,aes(method,AUROC,fill=method))+
  geom_hline(yintercept=0.5,linewidth=0.35,linetype=2,colour="#777777")+
  geom_boxplot(width=0.62,outlier.shape=NA,linewidth=0.4)+geom_jitter(width=0.09,size=0.7,alpha=0.55)+
  geom_text(data=ann_df,aes(label=label),size=1.9,colour="#555555",lineheight=0.85)+
  facet_wrap(~strategy,scales="free_x")+
  scale_fill_manual(values=c("LASSO"="#4A85B3","Elastic Net"="#4BBEB6","XGBoost"="#FFB84D"))+
  coord_cartesian(ylim=c(0.35,0.82))+
  labs(x=NULL,y="Outer-fold AUROC",title="Predictive performance by prespecified branch",
       subtitle="Fixed-85: locked 85 universe; strict nested: discovery redone in folds")+
  theme(legend.position="none",axis.text.x=element_text(angle=25,hjust=1))
ml_long <- ml85 %>% arrange(Display_label) %>% mutate(candidate_index=row_number()) %>%
  transmute(PG.ProteinGroups,Gene=Display_label,candidate_index,
    Replication=case_when(FDR_supported_replication~"FDR",Nominal_replication~"Nominal",Direction_concordant~"Direction",TRUE~"No support"),
    LASSO=LASSO_selection_freq,`Elastic Net`=EN_selection_freq,Boruta=Boruta_confirmed_freq,
    XGBoost=1-(XGBoost_mean_rank-1)/max(XGBoost_mean_rank-1,na.rm=TRUE)) %>%
  pivot_longer(c(LASSO,`Elastic Net`,Boruta,XGBoost),names_to="Method",values_to="Stability")
p5c <- ggplot(ml_long,aes(Method,candidate_index,size=Stability,colour=Replication))+geom_point(alpha=0.82)+
  scale_size(range=c(0.15,2.3),limits=c(0,1))+
  scale_colour_manual(values=c("No support"=pal[["light"]],Direction="#9CB7C3",Nominal=pal[["accent"]],FDR=pal[["positive"]]))+
  scale_y_continuous(breaks=c(1,22,43,64,85))+
  labs(x=NULL,y="Candidate index (alphabetical)",title="Candidate-level evidence convergence",
       subtitle="Point size is within-method stability/importance; no composite rank",size="Scaled evidence",colour="Replication")+theme(legend.position="top")
summary_ml <- ml85 %>% summarise(`LASSO selected >=50%`=sum(LASSO_selection_freq>=0.5,na.rm=TRUE),
  `Elastic Net selected >=50%`=sum(EN_selection_freq>=0.5,na.rm=TRUE),`Boruta confirmed`=sum(Boruta_full_status=="Confirmed",na.rm=TRUE),
  `XGBoost top-20 mean rank`=sum(XGBoost_mean_rank<=20,na.rm=TRUE)) %>% pivot_longer(everything(),names_to="criterion",values_to="n") %>%
  mutate(criterion=factor(criterion,levels=rev(criterion)))
p5d <- ggplot(summary_ml,aes(criterion,n))+geom_col(fill=pal[["neutral"]],width=0.7)+coord_flip()+
  geom_text(aes(label=n),hjust=-0.15,size=2.3)+scale_y_continuous(limits=c(0,92),expand=c(0,0))+
  labs(x=NULL,y="Candidates",title="Method-specific support counts",subtitle="Criteria shown separately; no winner implied")
fig5 <- ((p5a|p5b)/(p5c|p5d))+plot_annotation(tag_levels="a")
save_figure(fig5,"Fig5_replication_ml",height_mm=150)
write_source(bind_rows(m14p %>% transmute(panel="a_replication",category=stage,n,status,note=terminology_note),
  cv_plot %>% transmute(panel="b_cv",strategy,method,value=AUROC),
  strict_cv %>% transmute(panel="b_strict_nested_meta",rep_id,fold,n_input_proteins,n_tested,n_bh_significant,n_selected,n_features_ml,lasso_auroc,en_auroc,failure),
  ml_long %>% transmute(panel="c_convergence",PG.ProteinGroups,Gene,candidate_index,method=Method,value=Stability,replication=Replication),
  summary_ml %>% transmute(panel="d_support_counts",category=criterion,n)),"Fig5_replication_ml")

# ============ FIG 6 REDESIGNED: a=rep GO-BP, b=rep Reactome, c=ORA, d=M12B context ============
# selection rule: FDR_pooled<0.05 -> (Reactome: keep redundancy-cluster REPRESENTATIVE only) -> arrange FDR_pooled -> top N.
rep_ids <- redund %>% filter(representative_theme=="REPRESENTATIVE") %>% distinct(pathway_id)
# a: representative GO-BP (GO-BP not clustered; take top by FDR_pooled)
bp_top <- ranked %>% filter(database=="GO_BP", FDR_pooled<0.05) %>% arrange(FDR_pooled) %>% slice_head(n=8) %>%
  mutate(label=factor(short_label(pathway_name,30),levels=rev(short_label(pathway_name,30))),
         signed_score=ifelse(direction=="Up",1,-1)*safe_log10(FDR_pooled))
p6a <- ggplot(bp_top,aes(signed_score,label,colour=direction,size=pathway_size))+
  geom_vline(xintercept=0,linewidth=0.35,colour="#777777")+geom_point(alpha=0.9)+
  scale_colour_manual(values=c(Up=pal[["positive"]],Down=pal[["negative"]]))+
  labs(x="Signed -log10(pooled FDR)",y=NULL,title="Representative GO-BP (cameraPR)",colour="Direction",size="Genes")+
  theme(legend.position="top",axis.text.y=element_text(size=5.9,lineheight=0.9))
# b: representative Reactome (nonredundant cluster representatives, top by FDR_pooled)
rx_top <- ranked %>% filter(database=="Reactome", FDR_pooled<0.05, pathway_id %in% rep_ids$pathway_id) %>%
  arrange(FDR_pooled) %>% slice_head(n=8) %>%
  mutate(readable_name = ifelse(is.na(rx_name[pathway_id]) | rx_name[pathway_id]=="", "UNRESOLVED", rx_name[pathway_id]),
         rxlab = ifelse(readable_name=="UNRESOLVED", sub("R-HSA-","R-",pathway_id), short_label(readable_name, 26)),
         label=factor(rxlab,levels=rev(rxlab)),
         signed_score=ifelse(direction=="Up",1,-1)*safe_log10(FDR_pooled))
p6b <- ggplot(rx_top,aes(signed_score,label,colour=direction,size=pathway_size))+
  geom_vline(xintercept=0,linewidth=0.35,colour="#777777")+geom_point(alpha=0.9)+
  scale_colour_manual(values=c(Up=pal[["positive"]],Down=pal[["negative"]]))+
  labs(x="Signed -log10(pooled FDR)",y=NULL,title="Representative Reactome (cameraPR)",colour="Direction",size="Genes")+
  theme(legend.position="top",axis.text.y=element_text(size=5.9,lineheight=0.9))
# c: ORA representative (GO-BP all 3 + top Reactome reps)
ora_bp <- ora %>% filter(database=="GO_BP", FDR_pooled<0.05)
ora_rx <- ora %>% filter(database=="Reactome", FDR_pooled<0.05, pathway_id %in% rep_ids$pathway_id) %>% arrange(FDR_pooled) %>% slice_head(n=5)
ora_sel <- bind_rows(ora_bp, ora_rx) %>% arrange(FDR_pooled) %>%
  mutate(short=ifelse(database=="GO_BP",short_label(pathway_name,30),sub("R-HSA-","R-",pathway_id)),
         label=factor(short,levels=rev(short)))
p6c <- ggplot(ora_sel,aes(enrichment_ratio,label,size=foreground_mapped,colour=safe_log10(FDR_pooled)))+geom_point(alpha=0.9)+
  scale_colour_gradient(low="#A9C3CC",high=pal[["negative"]])+
  labs(x="Enrichment ratio",y=NULL,title="Candidate-family ORA",size="Candidates",colour="-log10(FDR)")+
  theme(legend.position="top",axis.text.y=element_text(size=5.9,lineheight=0.9))
# d: M12B contextual network — representative pathways (incl Reactome) x candidate genes
net_src <- path_member %>% filter(!is.na(ranked_pathway_FDR), ranked_pathway_FDR!="NA") %>%
  mutate(ranked_pathway_FDR=as.numeric(ranked_pathway_FDR))
# prefer representative pathways; take top 4 by pathway FDR across GO-BP + Reactome
top_pw <- net_src %>% distinct(pathway_id,pathway_name,pathway_database,pathway_fdr=ranked_pathway_FDR) %>%
  arrange(pathway_fdr) %>% slice_head(n=4) %>% pull(pathway_id)
net <- net_src %>% filter(pathway_id %in% top_pw) %>% mutate(pathway_fdr=ranked_pathway_FDR, pathway_short=sub("R-HSA-","R-",short_label(pathway_name,22)), candidate=Gene_symbol)
path_levels <- unique(net$pathway_short[order(net$pathway_fdr)]); gene_levels <- sort(unique(net$candidate))
net <- net %>% mutate(x=match(pathway_short,path_levels), y=match(candidate,gene_levels))
net_nodes_path <- net %>% distinct(pathway_short,x,pathway_fdr) %>% mutate(y=length(gene_levels)+2)
net_nodes_gene <- net %>% distinct(candidate,y) %>% mutate(x=seq(1,length(path_levels),length.out=n()))
net_edges <- net %>% left_join(net_nodes_gene %>% select(candidate,gene_x=x,gene_y=y),by="candidate") %>% mutate(path_y=length(gene_levels)+2)
p6d <- ggplot()+
  geom_segment(data=net_edges,aes(x=x,y=path_y-0.35,xend=gene_x,yend=gene_y+0.35),linewidth=0.28,colour="#BCC2C7",alpha=0.65)+
  geom_point(data=net_nodes_path,aes(x,y,size=safe_log10(pathway_fdr)),shape=22,fill=pal[["negative"]],colour="white")+
  geom_text(data=net_nodes_path,aes(x,y+0.7,label=pathway_short),size=1.85,lineheight=0.85)+
  geom_point(data=net_nodes_gene,aes(x,y),size=1.8,colour=pal[["accent"]])+
  geom_text(data=net_nodes_gene,aes(x,y-0.55,label=candidate),size=1.75,angle=45,hjust=1)+
  scale_size(range=c(2.2,4.2),guide="none")+coord_cartesian(clip="off")+
  labs(title="Compact pathway-candidate context (M12B)")+
  theme_void(base_family="Arial",base_size=7)+theme(plot.title=element_text(size=7.7,face="bold"),plot.margin=margin(8,10,14,10))
fig6 <- ((p6a|p6b)/(p6c|p6d))+plot_annotation(tag_levels="a")
save_figure(fig6,"Fig6_pathway_integration",height_mm=158)
write_source(bind_rows(
  bp_top %>% transmute(panel="a_go_bp_rep",database,pathway_id,pathway_name,pathway_size,direction,p_value=PValue,fdr=FDR_pooled,signed_score,selection_rule="FDR_pooled<0.05; arrange FDR_pooled; top8 GO-BP"),
  rx_top %>% transmute(panel="b_reactome_rep",database,pathway_id,pathway_name,readable_name,annotation_source=paste0("reactome.db ",rx_annot_version," PATHID->PATHNAME"),pathway_size,direction,p_value=PValue,fdr=FDR_pooled,signed_score,selection_rule="FDR_pooled<0.05; redundancy-cluster REPRESENTATIVE; arrange FDR_pooled; top8; Phase7 label-only update"),
  ora_sel %>% transmute(panel="c_ora",database,pathway_id,pathway_name,foreground_mapped,background_pathway,foreground_total,background_total,enrichment_ratio,odds_ratio,p_value=PValue,fdr=FDR_pooled,selection_rule="ORA FDR_pooled<0.05; GO-BP all; Reactome nonredundant rep top5"),
  net %>% transmute(panel="d_network",pathway_id,pathway_name,pathway_database,pathway_fdr,PG.ProteinGroups,Gene_symbol,candidate,ML_branch,ML_stability,D08_replication,selection_rule="M12B membership; top4 pathways by ranked_pathway_FDR")),"Fig6_pathway_integration")

cat("Phase6 rebuild written to:",fig_dir,"\n")
cat("Fig6a GO-BP shown:",nrow(bp_top)," Fig6b Reactome rep shown:",nrow(rx_top),
    " Fig6c ORA shown:",nrow(ora_sel)," Fig6d pathways:",length(unique(net$pathway_id)),
    " genes:",length(unique(net$candidate)),"\n")
