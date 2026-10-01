# M12B Input Provenance

> 日期：2026-10-01
> 说明：M12B 每个输入文件路径及其是否为 repaired 输出

---

| 输入文件 | 路径 | 是否 repaired 输出 | 说明 |
|----------|------|-------------------|------|
| Mapping contract | descriptive/analysis_v2.0/M12_pathway_v2.1/mapping/M12_gene_mapping_contract.csv | YES | Repaired M12_01_mapping.R 输出 |
| CameraPR combined FDR | descriptive/analysis_v2.0/M12_pathway_v2.1/ranked/M12_ranked_combined_FDR.csv | YES | Repaired M12_02_ranked_ora.R 输出 |
| CameraPR GO BP | descriptive/analysis_v2.0/M12_pathway_v2.1/ranked/M12_ranked_GO_BP.csv | YES | Repaired M12_02 输出 |
| CameraPR Reactome | descriptive/analysis_v2.0/M12_pathway_v2.1/ranked/M12_ranked_Reactome.csv | YES | Repaired M12_02 输出 |
| Core genes | descriptive/analysis_v2.0/M12_pathway_v2.1/ranked/M12_pathway_core_genes.csv | YES | Repaired M12_03_integration.R 输出 |
| ORA combined | descriptive/analysis_v2.0/M12_pathway_v2.1/ora/M12_ORA_combined_FDR.csv | YES | Repaired M12_02 输出 |
| D03 locked candidates | descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv | NO (frozen, 只读引用) | 85 DEPs，frozen Discovery 主链 |
| D08 replication summary | descriptive/discovery_validation/D08_validation/D08_replication_summary.csv | NO (frozen, 只读引用) | 冻结 D08 复制结果 |
| ML integrated table (85) | descriptive/analysis_v2.0/ml_v2.1/results/integrated_table_85.csv | NO (repaired ML, 只读引用) | fixed-85 ML = P0_REPAIRED |
| Strict nested feature stability | descriptive/analysis_v2.0/ml_v2.1/strict_nested/strict_nested_feature_stability.csv | NO (REPAIR_PENDING, 只读引用) | strict nested = REPAIR_PENDING |
| Primary expression matrix | descriptive/PRIMARY_dose_log2_expression.csv.gz | NO (frozen 输入) | 用于 M12B Spearman correlation（描述性） |
| Discovery validation assignment | descriptive/discovery_validation_split/discovery_validation_assignment.csv | NO (frozen 输入) | Sample split assignment |
| D02 primary model output | descriptive/discovery_validation/D02_discovery_primary/D02_Long_vs_Short_all_tested.csv | NO (frozen, 只读引用) | Canonical ranking statistic 来源 |
| Canonical protein annotation | descriptive/canonical_protein_annotation.csv | NO (frozen 输入) | 蛋白注释 |

---

## 总结

- **通路相关输入**（mapping / cameraPR / ORA / core genes）：全部为 Phase 5 repaired 输出
- **冻结模块输入**（D03 / D08 / ML / strict nested / D02 / 表达矩阵）：全部为只读引用，未修改
- **Ranking statistic**：来自 D02 frozen 主模型输出（moderated t = log2FC/SE），非自行拟合
