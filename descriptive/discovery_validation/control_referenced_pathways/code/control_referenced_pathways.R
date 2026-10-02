#!/usr/bin/env Rscript
# Exploratory control-referenced pathway analysis for Overall Discovery
# Low-vs-Control and High-vs-Control. Reuses frozen M12 mapping + gene sets.
# READ-ONLY with respect to frozen M12 outputs.

suppressPackageStartupMessages({
  library(limma)
  library(AnnotationDbi)
  library(org.Hs.eg.db)
  library(GO.db)
  library(reactome.db)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
MAP_DIR <- file.path(M12, "mapping")
OUT <- "descriptive/discovery_validation/control_referenced_pathways"
RES <- file.path(OUT, "results")
DIAG <- file.path(OUT, "diagnostics")
dir.create(RES, recursive=TRUE, showWarnings=FALSE)
dir.create(DIAG, recursive=TRUE, showWarnings=FALSE)

set.seed(20260928, kind="Mersenne-Twister")

# ---- 1. Load mapping contract (same as M12) ----
contract <- read.csv(file.path(MAP_DIR, "M12_gene_mapping_contract.csv"),
                     stringsAsFactors=FALSE, check.names=FALSE)
reps <- contract[contract$representative_status %in% c("REPRESENTATIVE","SINGLE") &
                 contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", ]
prot_to_gene <- setNames(reps$Gene_symbol, reps$PG.ProteinGroups)
cat("Representative mapped genes:", nrow(reps), "\n")

# ---- 2. Load pairwise results ----
pw_dir <- "descriptive/discovery_validation/D02_pairwise_completion/results"
lvc <- read.csv(file.path(pw_dir, "overall_low_vs_control_all_tested.csv"),
                stringsAsFactors=FALSE, check.names=FALSE)
hvc <- read.csv(file.path(pw_dir, "overall_high_vs_control_all_tested.csv"),
                stringsAsFactors=FALSE, check.names=FALSE)
stopifnot(nrow(lvc) == 1445, nrow(hvc) == 1445)
stopifnot(sum(lvc$P_value < 0.05, na.rm=TRUE) == 114,
          sum(hvc$P_value < 0.05, na.rm=TRUE) == 145)

# ---- 3. Build gene sets (identical to M12) ----
go_map <- AnnotationDbi::select(org.Hs.eg.db,
    keys=keys(org.Hs.eg.db, keytype="ENTREZID"),
    columns=c("GO","ONTOLOGY","SYMBOL"), keytype="ENTREZID")
go_bp_map <- go_map[go_map$ONTOLOGY=="BP" & !is.na(go_map$GO) & !is.na(go_map$SYMBOL), ]
go_bp_terms <- split(go_bp_map$SYMBOL, go_bp_map$GO)
go_bp_terms <- lapply(go_bp_terms, unique)
go_bp_names <- AnnotationDbi::select(GO.db, keys=names(go_bp_terms),
                                      columns="TERM", keytype="GOID")
go_bp_name_map <- setNames(go_bp_names$TERM, go_bp_names$GOID)

rea_map <- AnnotationDbi::select(reactome.db,
    keys=keys(reactome.db, keytype="ENTREZID"),
    columns=c("REACTOMEID"), keytype="ENTREZID")
e2s <- AnnotationDbi::select(org.Hs.eg.db, keys=rea_map$ENTREZID,
                             columns="SYMBOL", keytype="ENTREZID")
rea_map$SYMBOL <- e2s$SYMBOL[match(rea_map$ENTREZID, e2s$ENTREZID)]
rea_map <- rea_map[!is.na(rea_map$SYMBOL), ]
rea_list <- split(rea_map$SYMBOL, rea_map$REACTOMEID)
rea_list <- lapply(rea_list, unique)
rea_sets <- rea_list[lengths(rea_list) >= 10]

# ---- 4. cameraPR runner (same as M12) ----
run_camerapr <- function(df, label) {
  est <- df[df$Model_status == "ESTIMABLE", ]
  est$moderated_t <- est$log2FC / est$SE
  est$Gene_symbol_mapped <- prot_to_gene[est$PG.ProteinGroups]
  st_df <- est[!is.na(est$Gene_symbol_mapped), c("Gene_symbol_mapped","moderated_t")]
  st_df <- st_df[!duplicated(st_df$Gene_symbol_mapped), ]
  stats <- setNames(st_df$moderated_t, st_df$Gene_symbol_mapped)
  stats <- sort(stats, decreasing=TRUE)
  cat(label, "ranked genes:", length(stats), "\n")

  run_one <- function(sets, db_label, name_map) {
    bg <- names(stats)
    sets_f <- lapply(sets, function(s) intersect(s, bg))
    keep <- lengths(sets_f) >= 10 & lengths(sets_f) <= 500
    sets_f <- sets_f[keep]
    res_list <- lapply(names(sets_f), function(nm) {
      members <- sets_f[[nm]]
      idx <- which(names(stats) %in% members)
      cam <- tryCatch(cameraPR(stats, index=idx, use.ranks=FALSE, inter.gene.cor=0.01),
                      error=function(e) NULL)
      if (is.null(cam)) return(NULL)
      pname <- if (!is.null(name_map) && nm %in% names(name_map)) name_map[[nm]] else nm
      data.frame(database=db_label, pathway_id=nm, pathway_name=pname,
                 pathway_size=length(members), direction=cam$Direction,
                 PValue=cam$PValue, FDR=NA, NGenes=cam$NGenes,
                 stringsAsFactors=FALSE)
    })
    res <- do.call(rbind, res_list)
    res$FDR <- p.adjust(res$PValue, method="BH")
    res[order(res$PValue), ]
  }
  go_res <- run_one(go_bp_terms, "GO_BP", go_bp_name_map)
  rea_res <- run_one(rea_sets, "Reactome", NULL)
  all <- rbind(go_res, rea_res)
  all$FDR_pooled <- p.adjust(all$PValue, method="BH")
  list(go=go_res, rea=rea_res, all=all, stats=stats)
}

cat("\n== cameraPR Low vs Control ==\n")
lvc_cam <- run_camerapr(lvc, "LVC")
cat("\n== cameraPR High vs Control ==\n")
hvc_cam <- run_camerapr(hvc, "HVC")

write.csv(lvc_cam$all, file.path(RES, "low_vs_control_cameraPR_all.csv"), row.names=FALSE)
write.csv(hvc_cam$all, file.path(RES, "high_vs_control_cameraPR_all.csv"), row.names=FALSE)
write.csv(lvc_cam$all[lvc_cam$all$FDR_pooled < 0.05, ],
          file.path(RES, "low_vs_control_cameraPR_significant.csv"), row.names=FALSE)
write.csv(hvc_cam$all[hvc_cam$all$FDR_pooled < 0.05, ],
          file.path(RES, "high_vs_control_cameraPR_significant.csv"), row.names=FALSE)

# ---- 5. ORA (directional, raw P<0.05, no FC cutoff) ----
run_ora <- function(df, stats, label) {
  est <- df[df$Model_status == "ESTIMABLE", ]
  bg <- names(stats)
  sets_f <- lapply(go_bp_terms, function(s) intersect(s, bg))
  sets_f <- c(sets_f, lapply(rea_sets, function(s) intersect(s, bg)))
  keep <- lengths(sets_f) >= 10 & lengths(sets_f) <= 500
  sets_f <- sets_f[keep]
  N <- length(bg)

  ora_one <- function(fg_genes, db_label) {
    K <- length(fg_genes)
    res_list <- lapply(names(sets_f), function(nm) {
      members <- sets_f[[nm]]
      x <- length(intersect(fg_genes, members))
      m <- length(members)
      if (x == 0) return(NULL)
      ft <- fisher.test(matrix(c(x, m-x, K-x, N-m-K+x), nrow=2), alternative="greater")
      db <- if (nm %in% names(go_bp_terms)) "GO_BP" else "Reactome"
      pname <- if (db=="GO_BP" && nm %in% names(go_bp_name_map)) go_bp_name_map[[nm]] else nm
      data.frame(database=db, pathway_id=nm, pathway_name=pname,
                 foreground_mapped=x, background_pathway=m,
                 foreground_total=K, background_total=N,
                 enrichment_ratio=(x/K)/(m/N),
                 odds_ratio=unname(ft$estimate),
                 PValue=ft$p.value, FDR=NA, stringsAsFactors=FALSE)
    })
    res <- do.call(rbind, res_list)
    res$FDR <- p.adjust(res$PValue, method="BH")
    res[order(res$PValue), ]
  }

  nom <- est[est$P_value < 0.05, ]
  up <- nom[nom$log2FC > 0, ]
  down <- nom[nom$log2FC < 0, ]
  up_genes <- unique(na.omit(prot_to_gene[up$PG.ProteinGroups]))
  down_genes <- unique(na.omit(prot_to_gene[down$PG.ProteinGroups]))
  up_genes <- intersect(up_genes, bg)
  down_genes <- intersect(down_genes, bg)

  cat(sprintf("  %s: UP=%d DOWN=%d (mapped, in bg)\n", label, length(up_genes), length(down_genes)))
  list(
    up=ora_one(up_genes, paste0(label,"_UP")),
    down=ora_one(down_genes, paste0(label,"_DOWN")),
    n_up=length(up_genes), n_down=length(down_genes),
    up_genes=up_genes, down_genes=down_genes
  )
}

cat("\n== ORA Low vs Control ==\n")
lvc_ora <- run_ora(lvc, lvc_cam$stats, "LVC")
cat("\n== ORA High vs Control ==\n")
hvc_ora <- run_ora(hvc, hvc_cam$stats, "HVC")

# Combine directional ORA (each direction as its own family already)
lvc_ora_all <- rbind(
  cbind(direction="UP", lvc_ora$up),
  cbind(direction="DOWN", lvc_ora$down)
)
hvc_ora_all <- rbind(
  cbind(direction="UP", hvc_ora$up),
  cbind(direction="DOWN", hvc_ora$down)
)
write.csv(lvc_ora_all, file.path(RES, "low_vs_control_ORA_all.csv"), row.names=FALSE)
write.csv(hvc_ora_all, file.path(RES, "high_vs_control_ORA_all.csv"), row.names=FALSE)
write.csv(lvc_ora_all[lvc_ora_all$FDR < 0.05, ],
          file.path(RES, "low_vs_control_ORA_significant.csv"), row.names=FALSE)
write.csv(hvc_ora_all[hvc_ora_all$FDR < 0.05, ],
          file.path(RES, "high_vs_control_ORA_significant.csv"), row.names=FALSE)

# Directional summary
dir_sum <- data.frame(
  contrast=c("Low_vs_Control","Low_vs_Control","High_vs_Control","High_vs_Control"),
  direction=c("UP","DOWN","UP","DOWN"),
  n_nominal_proteins=c(lvc_ora$n_up, lvc_ora$n_down, hvc_ora$n_up, hvc_ora$n_down),
  n_pathways_tested=c(nrow(lvc_ora$up), nrow(lvc_ora$down), nrow(hvc_ora$up), nrow(hvc_ora$down)),
  n_FDR_lt_0.05=c(sum(lvc_ora$up$FDR<0.05, na.rm=TRUE),
                  sum(lvc_ora$down$FDR<0.05, na.rm=TRUE),
                  sum(hvc_ora$up$FDR<0.05, na.rm=TRUE),
                  sum(hvc_ora$down$FDR<0.05, na.rm=TRUE))
)
write.csv(dir_sum, file.path(RES, "low_vs_control_ORA_directional_summary.csv"), row.names=FALSE)
write.csv(dir_sum, file.path(RES, "high_vs_control_ORA_directional_summary.csv"), row.names=FALSE)

# ---- 6. Reconciliation with frozen M12 HvL ----
frozen_rank <- read.csv(file.path(M12, "ranked", "M12_ranked_combined_FDR.csv"),
                        stringsAsFactors=FALSE, check.names=FALSE)
cat("\nFrozen M12 HvL pooled FDR<0.05:", sum(frozen_rank$FDR_pooled < 0.05),
    "GO_BP:", sum(frozen_rank$FDR_pooled<0.05 & frozen_rank$database=="GO_BP"),
    "Reactome:", sum(frozen_rank$FDR_pooled<0.05 & frozen_rank$database=="Reactome"), "\n")

# Merge LVC, HVC, frozen HvL by pathway_id
lvc_w <- lvc_cam$all[, c("pathway_id","database","direction","PValue","FDR_pooled")]
names(lvc_w)[3:5] <- paste0("LVC_", names(lvc_w)[3:5])
hvc_w <- hvc_cam$all[, c("pathway_id","direction","PValue","FDR_pooled")]
names(hvc_w)[2:4] <- paste0("HVC_", names(hvc_w)[2:4])
froz_w <- frozen_rank[, c("pathway_id","direction","PValue","FDR_pooled")]
names(froz_w)[2:4] <- paste0("FrozenHvL_", names(froz_w)[2:4])

rec <- merge(lvc_w, hvc_w, by="pathway_id", all=TRUE)
rec <- merge(rec, froz_w, by="pathway_id", all=TRUE)
write.csv(rec, file.path(RES, "control_contrast_pathway_reconciliation.csv"), row.names=FALSE)

# Direction comparison
comp <- rec[!is.na(rec$LVC_direction) & !is.na(rec$HVC_direction), ]
comp$opposite <- sign(ifelse(comp$LVC_direction=="Up",1,-1)) !=
                 sign(ifelse(comp$HVC_direction=="Up",1,-1))
comp_sig <- comp[(!is.na(comp$LVC_FDR_pooled) & comp$LVC_FDR_pooled<0.05) |
                (!is.na(comp$HVC_FDR_pooled) & comp$HVC_FDR_pooled<0.05), ]

write.csv(comp, file.path(RES, "high_vs_low_pathway_comparison.csv"), row.names=FALSE)

# ---- 7. Summary matrix ----
sum_mat <- data.frame(
  Analysis=c("Low vs Control","High vs Control","Low vs Control","High vs Control",
             "Frozen High vs Low (reference)"),
  Method=c("cameraPR pooled","cameraPR pooled","ORA nominal UP+DOWN","ORA nominal UP+DOWN",
           "cameraPR pooled"),
  GO_BP_FDR_lt_0.05=c(
    sum(lvc_cam$all$FDR_pooled<0.05 & lvc_cam$all$database=="GO_BP"),
    sum(hvc_cam$all$FDR_pooled<0.05 & hvc_cam$all$database=="GO_BP"),
    sum(lvc_ora_all$FDR<0.05 & lvc_ora_all$database=="GO_BP", na.rm=TRUE),
    sum(hvc_ora_all$FDR<0.05 & hvc_ora_all$database=="GO_BP", na.rm=TRUE),
    sum(frozen_rank$FDR_pooled<0.05 & frozen_rank$database=="GO_BP")
  ),
  Reactome_FDR_lt_0.05=c(
    sum(lvc_cam$all$FDR_pooled<0.05 & lvc_cam$all$database=="Reactome"),
    sum(hvc_cam$all$FDR_pooled<0.05 & hvc_cam$all$database=="Reactome"),
    sum(lvc_ora_all$FDR<0.05 & lvc_ora_all$database=="Reactome", na.rm=TRUE),
    sum(hvc_ora_all$FDR<0.05 & hvc_ora_all$database=="Reactome", na.rm=TRUE),
    sum(frozen_rank$FDR_pooled<0.05 & frozen_rank$database=="Reactome")
  )
)
sum_mat$Total_FDR_lt_0.05 <- sum_mat[,3] + sum_mat[,4]
write.csv(sum_mat, file.path(RES, "pathway_summary_matrix.csv"), row.names=FALSE)

# ---- 8. Diagnostics ----
diag <- data.frame(
  metric=c("Discovery_n","Universe_n","LVC_estimable","HVC_estimable",
           "LVC_raw_P_lt_0.05","HVC_raw_P_lt_0.05",
           "LVC_ranked_genes","HVC_ranked_genes",
           "LVC_cameraPR_tested","HVC_cameraPR_tested",
           "LVC_cameraPR_sig","HVC_cameraPR_sig",
           "LVC_ORA_UP_genes","LVC_ORA_DOWN_genes",
           "HVC_ORA_UP_genes","HVC_ORA_DOWN_genes",
           "N_comparable_LVC_HVC","N_opposite_direction",
           "Frozen_HvL_cameraPR_sig","Frozen_HvL_GO_BP_sig","Frozen_HvL_Reactome_sig"),
  value=c(386,1445,1445,1445,114,145,
          length(lvc_cam$stats), length(hvc_cam$stats),
          nrow(lvc_cam$all), nrow(hvc_cam$all),
          sum(lvc_cam$all$FDR_pooled<0.05), sum(hvc_cam$all$FDR_pooled<0.05),
          lvc_ora$n_up, lvc_ora$n_down, hvc_ora$n_up, hvc_ora$n_down,
          nrow(comp), sum(comp$opposite),
          sum(frozen_rank$FDR_pooled<0.05),
          sum(frozen_rank$FDR_pooled<0.05 & frozen_rank$database=="GO_BP"),
          sum(frozen_rank$FDR_pooled<0.05 & frozen_rank$database=="Reactome"))
)
write.csv(diag, file.path(DIAG, "analysis_validation.csv"), row.names=FALSE)

cat("\n=== DONE ===\n")
print(sum_mat)
