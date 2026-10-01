# PHASE 6 总报告 — Downstream rebuild + final reconciliation

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。承接 Phase 1–5。
> 本轮性质：收尾。**不新增任何统计**（P30 no-new-science 全程遵守），仅基于已 repaired/verified canonical outputs 完成 reporting-rule freeze、figure/supplement/source_data 重建、claim map 对账、复现性审计重建与 git 清理计划。全程不 commit/push/tag。
> **判定：PHASE6_DOWNSTREAM_REBUILD_PASS**（P31 全部条件成立；详见 §9）。全局权威状态维持 FREEZE_READINESS=BLOCKED / SUBMISSION_READINESS=BLOCKED / SAFE_TO_TAG_ANALYSIS_V2_1=NO（剩余阻断均为 reporting / provenance / git 层，非分析缺陷）。

## 1. P32 逐条结论

### STATUS
- fixed-85 ML=**REPAIRED_AND_VERIFIED**；strict nested=**REPAIRED_AND_VERIFIED**；M09=**REPAIRED_AND_VERIFIED**；M11=**REPAIRED_AND_VERIFIED**；M12=**REPAIRED_RERUN_COMPLETE_WITH_FGSEA_FDR_HOLD**；M12B=**REPAIRED_RERUN_COMPLETE**；D03 85 candidates retained；D08 85→83→29→1 retained。
- 陈旧状态已全部清除：PROJECT_CONTEXT（顶部状态节/§4/§6/§9）、docs/README、ACTIVE_MAINLINE_MANIFEST.csv（M09/M11/strict nested 行）、AUDIT_BLOCKER_CLOSURE_STATUS.md（追更节）、FINAL_REPRODUCIBILITY_MANIFEST.csv（M12 行去 kegg_fix、通读数 205/23/44&41）、SUPPLEMENTARY_ANALYSIS_MANIFEST.csv（fgsea 39→44/41 dual）逐处更新；无残留 REPAIR_PENDING/NOT_STARTED/ML_NOT_STARTED/PATHWAY NOT_RUN。基线见 docs/PHASE6_STATUS_BASELINE.md。

### FGSEA
- **FGSEA_CANONICAL_FDR = DUAL_REPORTED_SENSITIVITY；PRIMARY_INFERENCE = NONE**（docs/FGSEA_REPORTING_FREEZE.md）。v2.1 §10 与 frozen protocol 均未指定 canonical family，无更高优先级 protocol 可裁决；按"禁止按数字好看选择"原则双列透明展示。
- family-wise BH=3/8/11/22/**44**；pooled BH=6/7/10/18/**41**（repaired，自 M12_fgsea_combined.csv）。
- 角色：cameraPR=primary pathway inference；ORA=complementary；**fgsea=sensitivity，不作 primary discovery family**；Supplement 双套并报，主文若提只叫 sensitivity。

### PATHWAY UNIVERSE（docs/PATHWAY_UNIVERSE_RECONCILIATION.md）
- A=**1445** Discovery inferential universe（85 的 BH 族，C05 分母）；B=**1434** pathway mapping tested universe（Q515 PRIMARY 矩阵；R03 切 1,445 未执行，如实登记为已声明延期，不造假）；C=**1406** rankable universe（mapped 1414 ∩ D02 ESTIMABLE）。
- 逐层：1445→1434（Q515 vs Discovery 差异 11）；1434→1414（unmapped=5 + multi-gene/ambiguous=15）；1414→1406（N_missing ranking=8；另有 39 个 D02 蛋白不在 mapped set）。
- 规定措辞已固定："Pathway mapping started from the complete primary inferential universe; gene-set analyses used the transparently derived mapped/rankable subset." 1445/1414/1406 不混作同一 denominator。

### FIG3（PARTIALLY_REBUILT，仅 c）
- Fig3c 用 repaired M09 重建：Pearson=**0.9740605**、Spearman=**0.9644384**、direction concordance=1343/1430=93.92%、Primary FDR<0.05=0、KNN FDR<0.05=0（自 M09_KNN_E_comparison.csv 读取，非手工输入）。旧 Pearson 0.931147 已废弃（旧 M09 数不再出现于任何 active 图/文档）。
- Caption：prespecified impute::impute.knn sensitivity、full 515 cohort、Q515 universe、overall-exposure effect E、**sensitivity not validation**。a/b/d 面板不依赖旧 M09，未改。

### FIG4（PARTIALLY_REBUILT，仅 d）
- Fig4d 从 repaired M11 重建：9-site LOO，Pearson 0.79–0.98 / Spearman 0.76–0.98 / direction concordance 70.8–93.5%，all LOO fits 保留 Environment 调整（same M05 estimator、fixed primary contract）。
- 措辞限定 "robustness, not proof of no site heterogeneity"；禁止 site-independent / batch-independent / validated / replicated across sites。M11 不用于证明消除 site×acquisition confounding（与 docs/SITE_ACQUISITION_CONFOUNDING_AUDIT.md 一致）。a/b/c 未变。

### FIG5（REBUILT）
- fixed-85 与 strict nested 分面分开：fixed-85=conditional performance given locked 85 universe（XGB mean=0.648769、EN mean=0.668688，自 repaired outer_cv_metrics.csv）；strict nested=stability when discovery redone in folds（15 折、**7/15 zero-feature、8/15 fit**；AUROC 仅画 8 fit 折并标注 "7/15 outer folds: no features at threshold (points = 8 fit folds)"）。
- 旧 8–618、旧 AUROC 0.634/0.629、旧 stable nested features 已不展示；无 validated classifier/clinical model/diagnostic panel 措辞；不合并成单一"模型性能"。

### FIG6（REBUILT，结构重做）
- a=**GO-BP**（cameraPR representative，FDR_pooled<0.05 29 条取 top8）；b=**Reactome**（cameraPR representative，176 条经 redundancy_clusters 取 41 个非冗余代表再 top8——**Reactome 已进 main**，176/205≈86%）；c=ORA（GO-BP 3 条全部 + Reactome 非冗余代表 top5）；d=M12B contextual network（top4 通路×9 基因）。
- **GO-MF/GO-CC → supplement**（M12B secondary/context branch，家族内 FDR）；**fgsea → supplement-only**（主图无 fgsea 面板，不依赖 fgsea FDR 裁定）；**KEGG 不出现**。
- 代表 pathway 选择规则（FDR、statistic、nonredundancy、theme coverage）写入各图 source_data 的 selection_rule 列；无 cherry-pick。
- 目检（本总报告撰写者 PDF 渲染复核）：四 panel 结构正确、无裁切、无旧数字。

### SUPPLEMENT（docs/SUPPLEMENT_REBUILD_MANIFEST.csv，全部 Needs_rebuild=NO）
- S-ML1（fixed-85 performance）、S-ML2（strict nested metrics）、S-ML3（feature stability/zero-feature folds）、S-M09（KNN sensitivity）、S-M11（site LOO）、S-PATH3（fgsea 四族 dotplot + FDR summary barplot，双列 padj/padj_pooled 明确标注）、S-PATH4（method overlap）、S-PATH1/2/5（full cameraPR/ORA/M12B 表）。
- **fgsea 显式可视化已就位**（不只有 CSV）：`SuppFig_S-PATH3_fgsea_4families`（dotplot，shape=family-wise FDR、size=-log10(padj_pooled)）+ `SuppFig_S-PATH3_fgsea_FDR_summary`（双列计数 barplot）。
- 所有图数据从 repaired canonical outputs 读取，无手工输入值；source_data README 逐 panel 记录 Panel/Source_file/Filter/Sort_order/Displayed_rows/Statistical_family/Notes。

### CLAIMS（STATISTICAL_CLAIM_MAP.csv，30 行×17 字段，零错位）
- **SAFE_WITH_LIMITATION**：C12（M09）、C15（M11）、C16（fixed-85 ML）、C17（strict nested）、C18（Boruta-style）、C19（XGBoost）、C20（cameraPR 205）、C21（ORA 23）、C25/C26/C27（M12B）、C28（Fig5，本轮重建后）、C29（Fig6，本轮重建后）。
- **SUPPLEMENT_ONLY**：C22（fgsea，DUAL_REPORTED_SENSITIVITY）。
- **SAFE**：C01–C11 主行、C13/C14、C23（KEGG NOT_RUN）、C24（mapping contract，SAFE_WITH_LIMITATION）、C30。
- 无任何 BLOCKED_BY_REPAIR 残留；C20 行曾出现 CSV 18 字段错位（stray "BLOCKED_BY_REPAIR"），已修复归位（修复前 1 行错位，修复后 0 行；本总报告撰写者以 python csv 独立复核 30 行×17 字段全部对齐）。
- C05：1445=Discovery-eligible universe、1430=full-515 abundance-model tested universe 不混用；指针 D01+D03（无 M03）。

### PROVENANCE / QC
- Contaminant exclusion 执行证据=**NO**（cRAP 2012.01.01 纸面冻结、8 角蛋白组但实际零排除）；Decoy exclusion=**UNRESOLVED**；PSM/peptide FDR export=**UNAVAILABLE**。**PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP = ACTIVE**（docs/WORDING_AND_QC_AUDIT.md；无新证据，未捏造）。
- 前分析元数据：processing time / time-to-centrifugation / freeze-thaw / storage / injection order / run order = NOT_RECORDED；MS_batch_proxy 记录但仅敏感性纳入；主模型含 Environment 调整。
- 措辞：EV 表述活文档全部正确（EV-enriched plasma proteomics + limitation）；两份 FROZEN 协议（docs/protocol/STUDY_DESIGN_AUDIT.md:18、ANALYSIS_PLAN_v2.0.md:15）含 "Plasma, not EV-enriched" 冲突口径——按不改 frozen 文件规则，在 PHASE6_STATUS_BASELINE §3 登记 superseded 注释项，未改正文；validation 措辞（external/independent/validated）全库 36 处命中均属禁止列表/免责/历史文档，**零 STALE_ACTIVE**。

### REPRODUCIBILITY（docs/FINAL_REPRODUCIBILITY_AUDIT.md 重建版）
- 旧版 "D01–M17 all RERUN_READY / PASS_WITH_LIMITATIONS" 已由重建版取代（旧版备份 .phase6.bak）：逐模块 Input provenance/Code status/Canonical script/Canonical output/Rerun status/Known limitation/Downstream dependencies/Ready_for_freeze。
- fixed-85 ML / strict nested / M09 / M11 / M12B = RERUN_VERIFIED；M12 = RERUN_VERIFIED_WITH_REPORTING_HOLD；D01/D02/D03/D08 = FROZEN_INPUT（未重跑）；M14 = REBUILD_FROM_D08；P1/P2/P3 = OPEN_PROVENANCE；D10 = 待重建（P1-8）。
- Blockers（docs/FINAL_BLOCKER_STATUS.md）：**CLOSED**=4 P0 + 5 P1；**OPEN_ANALYSIS=0**（R03 为已声明延期，非缺陷）；**OPEN_REPORTING**=fgsea canonical 裁定（或接受 DUAL_REPORTED_SENSITIVITY 为最终）、Fig3–6 已重建（图侧闭合）、Fig6b 概念已解决（fgsea 全进 supplement）；**OPEN_PROVENANCE**=P1/P2/P3 身份绑定、QC gap、环境锁定；**OPEN_GIT**=1079 项待分批。
- 数值一致性（CURRENT_AUTHORITATIVE_RESULTS.md）：85/83/29/1、M09 0.9740605/0.9644384、fixed-85 EN 0.668688/XGB 0.648769、strict nested 7/15+8 evaluable（LASSO 0.596663/EN 0.593731）、M11 LOO range、M12 cameraPR 205/ORA 23/fgsea 44&41/KEGG NOT_RUN——全部逐字引自 repaired 产物，无 pre-repair 值。

### GIT
- `git diff --check`：194 行白空格错误，**全部为既有历史 SVG**（figures_nature_v2.2 等，早于本轮），**本轮新产物 0 处**（docs/、figures_final_v2/、supplement_figures/、claim map 均干净）。
- `git status --short`：**1079 项**（M 842 / ?? 200 / D 30 / MM 3 / AM 3 / A 1）。
- docs/FINAL_GIT_CLEANUP_PLAN.md 已建（分类 A 代码修复 / B 结果重建 / C 图重建 / D 审计文档 / E 历史快照 / F 归档删除 / G 探索性 / H 无关既有；建议按 F→A→B→D→E→G/H→C 分批 commit，本轮不执行）。
- **safe to tag now = NO**（仍 BLOCKED；解除路径：fgsea 裁定/接受双列 → P1/P2/P3 身份绑定 → 环境锁定 → git 分批清理 → 终态复现性审计）。

## 2. 新数字引用源（repaired outputs，非任务文本）
M09_KNN_E_comparison.csv、M11_SITE_SUMMARY.csv / M11_EFFECT_COMPARISON.csv、ml_v2.1/results/outer_cv_metrics.csv、ml_v2.1/strict_nested/*.csv、M12_pathway_v2.1/ranked/M12_ranked_combined_FDR.csv、ora/M12_ORA_combined_FDR.csv、ranked_gsea/M12_fgsea_combined.csv、PATHWAY_METHOD_OVERLAP.csv、M12B outputs。

## 3. 边界遵守声明
未新增任何统计模型/阈值/pathway family/ROC 模型/candidate 规则/sensitivity；未重跑 D01–D08/fixed-85 ML/strict nested/M09/M11/M12/M12B；未改任何 frozen 结果值（D03/D08 时间戳 9/26 未动）；KEGG 未运行；未 commit/push/tag；figures 重建均为"从已修复输出重画"（P4–P14 允许范围），全部数字从 repaired 输出文件读取。

## 4. 本轮产物索引
- 主图：figures_final_v2/Fig3/4/5/6（PDF/SVG/PNG + _source_data.csv + SOURCE_DATA_README.md + FIGURE_MANIFEST.md + VISUAL_QC.md；旧图已快照 phase6_pre_rebuild_snapshot/）；重建脚本 code/V2_M17_phase6_rebuild.R；candidate_diagnostics_roc/ROC_POST_REPAIR_RECONCILIATION.md
- 补充图：analysis_v2.0/supplement_figures/（S-ML1/2/3、S-M09、S-M11）+ M12_pathway_v2.1/supplement_figures/（S-PATH3×2、S-PATH4）+ VISUAL_QC_REPORT.md
- docs/：PHASE6_STATUS_BASELINE、FGSEA_REPORTING_FREEZE、PATHWAY_UNIVERSE_RECONCILIATION、FINAL_METHODS_STATISTICS_CHECKLIST、P25_STALE_OUTPUT_AUDIT、CURRENT_AUTHORITATIVE_RESULTS、FINAL_REPRODUCIBILITY_AUDIT（重建）、FINAL_BLOCKER_STATUS、FINAL_GIT_CLEANUP_PLAN、WORDING_AND_QC_AUDIT、SUPPLEMENT_REBUILD_MANIFEST.csv
- 更新：PROJECT_CONTEXT.md、docs/README.md、ACTIVE_MAINLINE_MANIFEST.csv、FINAL_REPRODUCIBILITY_MANIFEST.csv、SUPPLEMENTARY_ANALYSIS_MANIFEST.csv、AUDIT_BLOCKER_CLOSURE_STATUS.md、STATISTICAL_CLAIM_MAP.csv（含 .phase6.bak/.phase6b.bak/.phase6c.bak）
