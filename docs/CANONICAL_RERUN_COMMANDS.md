# Canonical Rerun Commands

> 日期：2026-10-01 (Phase 7)
> 说明：只记录已验证 canonical 命令。本轮不运行。
> 工作目录：F:\env（所有命令从项目根运行）

---

## 0. P1/P2/P3 Identity Checks (sample mapping chain)

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 0a | `cd code; python P1.py` | rawdata/processed.xlsx | rawdata/sample_mapping_audit.xlsx | Provenance OK + mapping complete | ACTIVE (provenance guard added Phase7) |
| 0b | `cd code; python P2.py` | rawdata/sample_mapping_audit.xlsx | rawdata/sample_mapping_ambiguous_context.xlsx | Provenance OK + ambiguous list generated | ACTIVE (provenance guard added Phase7) |
| 0c | `cd code; python P3.py` | rawdata/processed.xlsx + rawdata/sample_mapping_audit.xlsx | rawdata/sample_mapping_FINAL.xlsx | Provenance OK + all mapping gates PASS | ACTIVE (provenance + validation gates P18) |

---

## 1. Discovery Primary Chain (D01–D08) — FROZEN, DO NOT RERUN

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 1a | D01_discovery_eligibility.py | sample_mapping_FINAL.xlsx + primary matrix | D01_eligible_proteins.csv (1445) | eligible=1445 | FROZEN (no rerun) |
| 1b | D02_discovery_primary.R | D01 eligible + expression matrix | D02_Long_vs_Short_all_tested.csv (1445) | 85 DEPs at BH<0.05 | FROZEN (no rerun) |
| 1c | D03_candidate_lock.R | D02 results | D03_locked_candidates.csv (85) | 85 locked DEPs | FROZEN (no rerun) |
| 1d | D08_validation.R | D03 locked + holdout split | D08_validation_results.csv (85/83/29/1) | 85 reused / 83 direction / 29 nominal / 1 FDR | FROZEN (no rerun) |

---

## 2. ML Chain (fixed-85 + strict nested)

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 2a | run_v2_1_ml.R (fixed-85) | D03_locked_candidates.csv + expression | ml_v2.1/results/integrated_table_85.csv | 85 rows, XGB/EN/LASSO metrics | REPAIRED (P0-1/P0-2) |
| 2b | strict_nested_sensitivity.R | D01 eligible + split | ml_v2.1/strict_nested/*.csv | 15 outer folds, 8 fit / 7 zero-feature | REPAIR_PENDING |

---

## 3. Sensitivity Modules

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 3a | V2_M09_knn_sensitivity.R | Primary matrix + M05 E results | M09.../KNN_sensitivity/ | Pearson~0.97, direction concordance~1343/1430 | REPAIRED (Phase 3) |
| 3b | V2_M11_site_robustness.R | Primary matrix + site composition | M11_site_robustness/ | 9 sites LOO sensitivity | REPAIRED (Phase 4) |

---

## 4. M12 Pathway Chain (Phase 5 repaired)

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 4a | `cd descriptive/analysis_v2.0/M12_pathway_v2.1; Rscript M12_01_mapping.R` | PRIMARY matrix + annotation | mapping/M12_gene_mapping_contract.csv | tested=1434 / mapped=1414 / multi=15 / unmapped=5 | REPAIRED_RERUN_COMPLETE |
| 4b | `cd descriptive/analysis_v2.0/M12_pathway_v2.1; Rscript M12_02_ranked_ora.R` | D02 moderated t + mapping contract + D03 locked | ranked/ + ora/ + ranked_gsea/ | cameraPR 205 sig pooled; ORA 23 sig pooled; fgsea 1016 tested | REPAIRED_RERUN_COMPLETE |
| 4c | `cd descriptive/analysis_v2.0/M12_pathway_v2.1; Rscript M12_03_integration.R` | M12_02 outputs + D08 + ML integrated | integration/ + environment/ + diagnostics/ | core genes 2101 rows, env concordance 545/761 | REPAIRED_RERUN_COMPLETE |

### ⚠️ DO NOT RUN

| Script | Status | Reason |
|--------|--------|--------|
| **M12_02b_kegg_fix.R** | **DO_NOT_RUN / HISTORICAL** | KEGG chain removed per v2.1 §16. KEGG = NOT_RUN. REST returned incomplete list; download_KEGG failed. Never execute this script. |

---

## 5. M12B Biological Context (Phase 5 repaired)

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 5a | `cd descriptive/analysis_v2.0/M12B_biological_context_v2.1; Rscript M12B_all.R` | Repaired M12 outputs + D02 + D03 + ML | network/ + correlation/ + environment/ + integration/ | fgsea 1016 tested / 44 family-sig / 41 pooled-sig; integrated=85 rows | REPAIRED_RERUN_COMPLETE |

---

## 6. Figure Rebuild

| Step | Command | Input | Output | Expected_Gate | Current_Status |
|------|---------|-------|--------|---------------|----------------|
| 6a | V2_M17_figures_v2.R | All repaired outputs | figures_final_v2/Fig1-6 | Fig6 from repaired M12 chain | BLOCKED_REBUILD_FIGS |
| 6b | V2_M17_figures_v3_ml_supplement.R | Repaired ML results | figures_final_v2/SuppFig_ML_*.pdf | ML supplement from repaired data | Needs rebuild |
| 6c | supplement_figures/make_S-PATH3_fgsea_fig.R | fgsea_combined.csv | supplement_figures/SuppFig_S-PATH3_*.pdf | Dual FDR columns | DONE (Phase 6) |
| 6d | supplement_figures/make_S-PATH4_overlap_fig.R | PATHWAY_METHOD_OVERLAP.csv | supplement_figures/SuppFig_S-PATH4_*.pdf | 363 pathways overlap | DONE (Phase 6) |
| 6e | supplement_figures/make_S-ML_S-M09_S-M11_figs.R | ML + M09 + M11 repaired CSVs | supplement_figures/SuppFig_S-ML*.pdf | 5 figures | DONE (Phase 6) |

---

## Rerun Order Summary

```
P1 → P2 → P3 (sample mapping provenance chain)
    ↓
D01 → D02 → D03 → D08 (FROZEN, no rerun)
    ↓
fixed-85 ML → strict nested ML
    ↓
M09 KNN sensitivity → M11 site LOO
    ↓
M12_01_mapping → M12_02_ranked_ora → M12_03_integration
    ↓
M12B_all.R
    ↓
Figure rebuild (main + supplement)

DO NOT RUN: M12_02b_kegg_fix.R (HISTORICAL / KEGG NOT_RUN)
```
