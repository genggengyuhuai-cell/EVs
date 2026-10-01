# Source Data README — Phase 6 rebuilt figures

每图 source_data CSV 均由 R 脚本直接从 repaired canonical 输出读取，无手工输入数值。逐 panel 记录：Source_file / Filter / Sort_order / Displayed_rows / Statistical_family / Notes。

## Fig3_candidate_biology_source_data.csv
- a_effect_landscape：`ml_v2.1/results/integrated_table_85.csv`；全部 85；按字母；85 行；Discovery High-vs-Low。
- b_profiles：`M06.../M06_adjusted_means_architecture_table.csv` join ml85；85×3=255。
- **c_missingness（rebuilt）**：`M09_missingness_sensitivity/KNN_sensitivity/M09_KNN_E_comparison.csv`（repaired impute.knn）；join ml85；85；primary E vs KNN E。family=overall-exposure sensitivity（非 validation）。
- d_architecture：ml85 architecture class 计数。

## Fig4_environment_site_source_data.csv
- a_environment：M10 pure interaction；1,430。
- b_interaction：M10 interaction_BH 分箱；0/1,430 FDR<0.05。
- c_site：M11_site_composition（未变）。
- **d_loo（rebuilt）**：`M11_site_robustness/M11_site_LOO_stability.csv`（repaired primary-contract adjusted LOO）；E_loo_max_shift 分布。

## Fig5_replication_ml_source_data.csv
- a_replication：M14 hierarchy；85/85/83/29/1。
- b_cv：`ml_v2.1/results/outer_cv_metrics.csv`（fixed-85, 15 folds）+ `strict_nested/strict_nested_outer_metrics.csv`（仅 8 fit folds）。
- **b_strict_nested_meta（新增列组）**：15 folds 全记录 n_features_ml/failure；7 折 n_features_ml=0（zero-feature），8 折 fit。family=strict nested discovery-redo。
- c_convergence：ml85 × 4 method。
- d_support_counts：ml85 criterion 计数。

## Fig6_pathway_integration_source_data.csv（结构重做）
- a_go_bp_rep：`M12.../ranked/M12_ranked_combined_FDR.csv`；filter database=GO_BP & FDR_pooled<0.05；arrange FDR_pooled；8 行。family=cameraPR primary（pooled BH BP+Reactome）。
- b_reactome_rep：同表；filter database=Reactome & FDR_pooled<0.05 & pathway_id ∈ redundancy_clusters REPRESENTATIVE；arrange FDR_pooled；8 行。selection rule 写入 selection_rule 列。
- c_ora：`M12.../ora/M12_ORA_combined_FDR.csv`；GO-BP FDR_pooled<0.05 全部（3）+ Reactome 代表 top5；8 行。family=ORA primary。
- d_network：`M12.../integration/M12_ML_candidate_pathway_membership.csv`；top4 pathway by ranked_pathway_FDR；通路-候选边。family=M12B contextual。
- KEGG 不出现（NOT_RUN）；fgsea 不进 main。

## Phase 7 label-only update（2026-10-01）
- Fig6b（b_reactome_rep）source_data 新增 `readable_name` 与 `annotation_source` 列。
- readable_name 来自 **reactome.db 1.86.2 PATHID→PATHNAME**（AnnotationDbi::select，loadNamespace 隔离，非手工输入）；8/8 解析，无 UNRESOLVED。
- 仅标签更新；b_reactome_rep 的 pathway_id / FDR / signed_score / selection_rule 与 Phase6 完全一致。
