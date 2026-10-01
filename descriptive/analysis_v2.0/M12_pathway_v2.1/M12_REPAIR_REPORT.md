# M12 / M12B Phase 5 修复重跑报告

> 日期：2026-10-01
> 执行模式：Phase 5 canonical chain 重跑（M12 mapping → M12_02 → M12_03 → M12B_all）
> 方法合同：M12_CANONICAL_METHOD_CONTRACT.md（2026-10-01 冻结版）

---

## 执行链日志

```
1. M12_01_mapping.R          → PASS (1434/1414/15/5)
2. M12_02_ranked_ora.R       → PASS (cameraPR + ORA)
3. M12_03_integration.R      → PASS (core genes + env + ML + redundancy)
4. M12B_all.R                → PASS (fgsea + MF/CC + network + correlation + integrated)
```

工作目录：`F:\env`（脚本均使用相对路径从项目根运行）

---

## Stop Gates 结果表

| Gate | 检查项 | 结果 | 数值 |
|------|--------|------|------|
| Gate 1 | Mapping universe (tested/unambiguous/multi/unmapped) | PASS | 1434 / 1414 / 15 / 5 |
| Gate 2 | D02 ranking universe (N_primary_tested / N_ranked) | PASS | 1445 / 1406 |
| Gate 3 | cameraPR primary (GO-BP + Reactome pooled) | PASS | 272+486=758 tested, 29+176=205 sig |
| Gate 4 | ORA primary (GO-BP + Reactome pooled) | PASS | sig=3+20=23 |
| Gate 5 | fgsea 4 families output | PASS | 272+107+151+486=1016 tested |
| Gate 6 | M12B integrated table = 85 rows | PASS | 85 rows |

---

## A. Mapping 重跑结果

| 指标 | Old (pre-repair) | Repaired | 变化 |
|------|-----------------|----------|------|
| tested_prots | 1434 (预期) | 1434 | 一致 |
| unambiguous (mapped) | 1414 (预期) | 1414 | 一致 |
| multi-gene ambiguous | 15 (预期) | 15 | 一致 |
| unmapped | 5 (预期) | 5 | 一致 |
| duplicate_gene_groups | 0 | 0 | 一致 |
| mapping_coverage_pct | 98.61% | 98.61% | 一致 |

**结论**：Mapping 修复后重跑结果与预期完全一致（1434/1414/15/5）。nrows=0 bug 已修复，mapping universe 复现成功。

---

## B. Ranking 与合并出入

| P7 字段 | 数值 | 说明 |
|---------|------|------|
| N_primary_tested | 1445 | D02 all tested proteins |
| N_gene_mapped | 1414 | Mapping contract representative genes |
| N_ranked | 1406 | D02 ESTIMABLE ∩ mapped genes（去重后） |
| N_ORA_background | 1406 | = N_ranked（mapped + estimable） |
| N_excluded_multigene | 15 | 多基因歧义，排除 |
| N_unmapped | 5 | 无基因映射，排除 |

**出入说明**：
- D02 = 1445 蛋白，mapping = 1414 基因（来自 Q515=1434 映射）
- 交集 N_ranked = 1406
- 差异：1445 - 1406 = 39 个 D02 蛋白不在 mapped set（部分在 D01 eligible 但不在 Q515 tested universe，或属 multi-gene/unmapped）
- 差异：1414 - 1406 = 8 个 mapped 基因不在 D02 ESTIMABLE 集
- 出入为 universe 差异（Q515=1434 vs D01=1445）的自然结果，非错误

---

## C. cameraPR / ORA / fgsea 各 family tested/sig

### cameraPR（主分支：GO-BP + Reactome, FDR_pooled = BH across both）

| Family | Tested | Sig (FDR_pooled < 0.05) | FDR 列 | 角色 |
|--------|--------|------------------------|--------|------|
| GO BP | 272 | 29 | FDR_pooled | Primary |
| Reactome | 486 | 176 | FDR_pooled | Primary |
| **合计 primary** | **758** | **205** | FDR_pooled | PATH-R |
| GO MF | 107 | 16 | FDR (per-family) | Secondary (M12B) |
| GO CC | 151 | 16 | FDR (per-family) | Secondary (M12B) |
| KEGG | 0 | 0 | — | NOT_RUN |

### ORA（主分支：GO-BP + Reactome, FDR_pooled = BH across both）

| Family | Tested (foreground>=1) | Sig (FDR_pooled < 0.05) | FDR 列 | 角色 |
|--------|----------------------|------------------------|--------|------|
| GO BP | — | 3 | FDR_pooled | Primary |
| Reactome | — | 20 | FDR_pooled | Primary |
| **合计 primary** | — | **23** | FDR_pooled | PATH-O |
| GO MF | — | 7 (per-family) | FDR | Secondary (M12B) |
| GO CC | — | 4 (per-family) | FDR | Secondary (M12B) |
| KEGG | 0 | 0 | — | NOT_RUN |

### fgsea（四族，双列 FDR）

| Family | Tested | padj_family < 0.05 (per-family BH) | padj_pooled < 0.05 (cross-family BH) |
|--------|--------|-----------------------------------|-------------------------------------|
| GO BP | 272 | 3 | 6 |
| GO MF | 107 | 8 | 7 |
| GO CC | 151 | 11 | 10 |
| Reactome | 486 | 22 | 18 |
| **合计** | **1016** | **44** | **41** |

**fgsea Canonical FDR 结论**：**UNRESOLVED**（保持合同 §12 状态）。两套 FDR 计数均不标 FINAL_FROZEN，待团队裁定 canonical FDR family。

---

## D. 旧 195/23/39 新值对比

| 指标 | Old (pre-repair) | New (repaired) | 变化原因 |
|------|-----------------|----------------|----------|
| cameraPR total sig (pooled) | 195 (25+170) | 205 (29+176) | +10 |
| ORA total sig (pooled) | 23 (3+20) | 23 (3+20) | 一致 |
| fgsea total sig (per-family) | 39 (3+8+11+17) | 44 (3+8+11+22) | +5 (Reactome: 17→22) |
| fgsea total sig (pooled) | 39 (5+6+11+17) | 41 (6+7+10+18) | +2 |

**变化原因说明**：
- cameraPR +10：ranking statistic 从 self-fit ~group（无 environment 调整 + 中位数插补）改为 D02 environment-adjusted moderated t，统计量分布变化导致 FDR 计数微调
- fgsea Reactome 显著增加：同样因 ranking 统计量从 D02 moderated t 重算
- ORA 不变：foreground=85 D03 locked，background 变化不大，Fisher exact 结果稳定

---

## E. M12B 输入来源确认

| 输入文件 | 是否 repaired 输出 |
|----------|-------------------|
| mapping/M12_gene_mapping_contract.csv | YES (repaired M12_01) |
| ranked/M12_ranked_combined_FDR.csv | YES (repaired M12_02) |
| ranked/M12_pathway_core_genes.csv | YES (repaired M12_03) |
| D03_locked_candidates.csv | NO (frozen, 只读引用) |
| D08_replication_summary.csv | NO (frozen, 只读引用) |
| integrated_table_85.csv (ML) | NO (repaired ML, 只读引用) |
| strict_nested_feature_stability.csv | NO (strict nested REPAIR_PENDING, 只读引用) |

**结论**：M12B 通路相关输入全部为 repaired M12/M12_02/M12_03 输出；冻结模块（D03/D08/ML/strict nested）为只读引用。

---

## F. 违规动作声明

- KEGG 执行：**无**（KEGG = NOT_RUN，占位 CSV only）
- 联网下载：**无**（所有 gene sets 来自本地 Bioconductor 包：org.Hs.eg.db / GO.db / reactome.db）
- 修改冻结模块（D01/D02/D03/D08/ML/M09/M11）：**无**（全部只读引用）
- git commit/push/tag：**无**
- 中位数插补：**无**（主 ranking 来自 D02，NO imputation；仅 M12B Spearman 相关性使用表达矩阵，描述性）

---

## G. 产出文件清单（绝对路径）

### M12 主链
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\mapping\M12_gene_mapping_contract.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\mapping\M12_gene_mapping_summary.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_ranked_GO_BP.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_ranked_Reactome.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_ranked_combined_FDR.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_ranked_GO_MF.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_ranked_GO_CC.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_ranked_KEGG.csv` (空, NOT_RUN)
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked\M12_pathway_core_genes.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ora\M12_ORA_GO_BP.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ora\M12_ORA_Reactome.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ora\M12_ORA_combined_FDR.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ora\M12_ORA_GO_MF.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ora\M12_ORA_GO_CC.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ora\M12_ORA_KEGG.csv` (空, NOT_RUN)
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_GO_BP.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_GO_MF.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_GO_CC.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_Reactome.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_combined.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_fgsea_leading_edge.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\ranked_gsea\M12_cameraPR_fgsea_concordance.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\integration\M12_ML_candidate_pathway_membership.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\integration\M12_pathway_redundancy_clusters.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\environment\M12_env_ranked_HumidHot.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\environment\M12_env_ranked_HighAltitude.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\environment\M12_env_pathway_concordance.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\diagnostics\M12_run_manifest.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\diagnostics\M12_database_versions.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\diagnostics\M12_mapping_diagnostics.csv`

### M12B
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\network\M12B_pathway_protein_edges.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\network\M12B_pathway_protein_nodes.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\environment\M12B_environment_pathway_concordance.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\environment\M12B_environment_pathway_summary.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\annotation\M12B_protein_annotation.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\correlation\M12B_DEP85_spearman_correlation.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\correlation\M12B_DEP85_correlation_pairs.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\correlation\M12B_DEP85_collinearity_summary.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\integration\M12B_integrated_candidate_context.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\diagnostics\M12B_run_manifest.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\diagnostics\M12B_annotation_sources.csv`

### 报告文档（本批新增）
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\M12_REPAIR_REPORT.md`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\M12_REPAIR_COMPARISON.csv`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\M12_SOFTWARE_PROVENANCE.md`
- `F:\env\descriptive\analysis_v2.0\M12_pathway_v2.1\PATHWAY_METHOD_OVERLAP.csv`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\M12B_REPAIR_REPORT.md`
- `F:\env\descriptive\analysis_v2.0\M12B_biological_context_v2.1\M12B_INPUT_PROVENANCE.md`
