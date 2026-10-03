# =============================================================================
# M12_01_mapping.R — Gene mapping contract (v2.1 §10)
# Deterministic PG.ProteinGroups -> gene mapping for pathway analysis.
# =============================================================================
suppressPackageStartupMessages({
  library(AnnotationDbi)
  library(org.Hs.eg.db)
})

M12 <- "descriptive/analysis_v2.0/M12_pathway_v2.1"
MAP_DIR <- file.path(M12, "mapping")
dir.create(MAP_DIR, recursive=TRUE, showWarnings=FALSE)

# 1. Load the tested universe = the 1434 proteins in PRIMARY matrix
# [P2 FIX] 原代码使用 nrows=0 仅读取表头，导致 rownames(expr) 为空向量，
#          tested_prots 长度为 0，后续 mapping 全部失效。
#          修复：移除 nrows=0，完整读取矩阵以获取所有蛋白行名。
#          预期值（重跑后核验）：tested_prots = 1434
expr <- read.csv(gzfile("descriptive/PRIMARY_dose_log2_expression.csv.gz"),
                 row.names=1, check.names=FALSE)
tested_prots <- rownames(expr)
cat("Tested universe (PRIMARY matrix):", length(tested_prots), "proteins\n")
# [P2 FIX] Assertion: 预期重跑后 tested_prots 长度为 1434（来自 PROJECT_CONTEXT 第6节 universe）
#          此 assertion 为文档化预期，脚本本轮不运行，重跑后核验
stopifnot("P2-EXPECTED: tested_prots should be 1434 after rerun" =
            length(tested_prots) == 1434)

# 2. Load canonical annotation (3817 protein groups)
ann <- read.csv("descriptive/canonical_protein_annotation.csv",
                stringsAsFactors=FALSE, check.names=FALSE)
cat("Canonical annotation rows:", nrow(ann), "\n")

# 3. Restrict to tested universe
ann_test <- ann[match(tested_prots, ann$PG.ProteinGroups), ]
stopifnot(nrow(ann_test) == length(tested_prots))
cat("Annotated tested proteins:", sum(!is.na(ann_test$Gene_symbol)), "\n")

# 4. Per-protein-group mapping audit
# PG.ProteinGroups may be "A0A024R1R8;Q9Y2S6" (multiple accessions)
# PG.Genes may be "TMA7B;TMA7" (multiple genes)
parse_accessions <- function(x) trimws(strsplit(x, ";", fixed=TRUE)[[1]])
parse_genes      <- function(x) {
  if (is.na(x) || x == "") return(character(0))
  unique(trimws(strsplit(x, ";", fixed=TRUE)[[1]]))
}

contract <- data.frame(
  PG.ProteinGroups = ann_test$PG.ProteinGroups,
  source_accession_string = ann_test$PG.ProteinGroups,
  parsed_accessions = NA_character_,
  PG.Genes_raw = ann_test$PG.Genes,
  Gene_symbol_display = ann_test$Gene_symbol,
  mapped_gene_id = NA_character_,
  Gene_symbol = NA_character_,
  mapping_status = NA_character_,
  overall_detection_rate = NA_real_,
  duplicate_gene_group = NA_integer_,
  representative_status = NA_character_,
  representative_tiebreak_reason = NA_character_,
  stringsAsFactors=FALSE
)

# Detection rate from D515 universe (has N_detected, N_total)
d515 <- read.csv("descriptive/analysis_v2.0/universes/D515.csv",
                 stringsAsFactors=FALSE, check.names=FALSE)
det_lookup <- setNames(d515$Detection_rate, d515$PG.ProteinGroups)
contract$overall_detection_rate <- det_lookup[match(contract$PG.ProteinGroups, names(det_lookup))]

for (i in seq_len(nrow(contract))) {
  accs <- parse_accessions(contract$source_accession_string[i])
  contract$parsed_accessions[i] <- paste(accs, collapse=";")
  genes <- parse_genes(ann_test$PG.Genes[i])

  if (length(genes) == 0 || all(is.na(genes))) {
    contract$mapping_status[i] <- "UNMAPPED"
    next
  }
  # Also check Gene_symbol_display
  disp <- ann_test$Gene_symbol[i]
  disp_genes <- parse_genes(ifelse(is.na(disp), "", disp))
  all_genes <- unique(c(genes, disp_genes))
  all_genes <- all_genes[all_genes != ""]

  if (length(all_genes) == 1) {
    contract$mapping_status[i] <- "UNAMBIGUOUS_ONE_GENE"
    contract$Gene_symbol[i] <- all_genes
  } else {
    contract$mapping_status[i] <- "MULTI_GENE_AMBIGUOUS"
    contract$Gene_symbol[i] <- paste(all_genes, collapse=";")
  }
}

# 5. Resolve Uniprot -> Entrez for unambiguous genes (for msigdbr / GO/KEGG/Reactome)
# msigdbr uses gene symbols or Entrez. We'll use gene symbols.
# For unambiguous rows, map symbol -> Entrez for cross-database compatibility.
sym_to_entrez <- AnnotationDbi::select(org.Hs.eg.db,
                                       keys=contract$Gene_symbol[contract$mapping_status=="UNAMBIGUOUS_ONE_GENE"],
                                       keytype="SYMBOL", columns=c("ENTREZID","SYMBOL"))
entrez_lookup <- setNames(sym_to_entrez$ENTREZID, sym_to_entrez$SYMBOL)
contract$mapped_gene_id <- ifelse(contract$mapping_status=="UNAMBIGUOUS_ONE_GENE",
                                   entrez_lookup[contract$Gene_symbol], NA)

# 6. Duplicate-gene representative rule:
#    multiple PG -> same gene; keep highest detection rate; tiebreak lexical PG.
unamb <- contract[contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", ]
gene_tab <- table(unamb$Gene_symbol)
dup_genes <- names(gene_tab)[gene_tab > 1]
cat("Genes with >1 protein group:", length(dup_genes), "\n")

contract$representative_status <- "SINGLE"
for (g in dup_genes) {
  idx <- which(contract$Gene_symbol == g & contract$mapping_status=="UNAMBIGUOUS_ONE_GENE")
  # Sort by detection rate desc, then PG lexical
  ord <- order(-contract$overall_detection_rate[idx], contract$PG.ProteinGroups[idx])
  rep_idx <- idx[ord[1]]
  contract$representative_status[idx] <- "DUP_GROUP_MEMBER"
  contract$representative_status[rep_idx] <- "REPRESENTATIVE"
  for (j in idx) {
    contract$duplicate_gene_group[j] <- g
    contract$representative_tiebreak_reason[j] <-
      ifelse(j==rep_idx, "highest_detection_rate", "dropped_duplicate_of_representative")
  }
}

# 7. Write contract
write.csv(contract, file.path(MAP_DIR, "M12_gene_mapping_contract.csv"), row.names=FALSE)

# 8. Summary
n_total <- nrow(contract)
n_unamb <- sum(contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", na.rm=TRUE)
n_multi <- sum(contract$mapping_status=="MULTI_GENE_AMBIGUOUS", na.rm=TRUE)
n_unmap <- sum(contract$mapping_status=="UNMAPPED", na.rm=TRUE)
# [P2 FIX] Assertions: 预期重跑后 universe 数值与 PROJECT_CONTEXT 第6节一致
#          tested=1434 / mapped(unambiguous)=1414 / multi-gene ambiguous=15 / unmapped=5
#          这些 assertion 是文档化预期，脚本本轮不运行，重跑后核验
stopifnot("P2-EXPECTED: total tested should be 1434" = n_total == 1434)
stopifnot("P2-EXPECTED: unambiguous (mapped) should be 1414" = n_unamb == 1414)
stopifnot("P2-EXPECTED: multi-gene ambiguous should be 15" = n_multi == 15)
stopifnot("P2-EXPECTED: unmapped should be 5" = n_unmap == 5)
n_dup_groups <- length(dup_genes)
n_rep <- sum(contract$representative_status %in% c("REPRESENTATIVE","SINGLE") &
             contract$mapping_status=="UNAMBIGUOUS_ONE_GENE", na.rm=TRUE)

summary_df <- data.frame(
  item=c("total_protein_groups_tested",
         "unambiguous_one_gene",
         "multi_gene_ambiguous",
         "unmapped",
         "duplicate_gene_groups",
         "retained_representative_genes",
         "mapping_coverage_pct"),
  value=c(n_total, n_unamb, n_multi, n_unmap, n_dup_groups, n_rep,
          round(100*n_unamb/n_total, 2)),
  stringsAsFactors=FALSE
)
write.csv(summary_df, file.path(MAP_DIR, "M12_gene_mapping_summary.csv"), row.names=FALSE)

cat("\n=== Mapping summary ===\n")
print(summary_df)
cat("\nRepresentative genes (for pathway analysis):", n_rep, "\n")
