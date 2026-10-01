# FINAL Methods & Statistics Checklist（终稿方法学核对清单）

> 日期：2026-10-01。性质：**checklist only**——供稿件 Methods 写作逐项勾选，不写稿件正文。
> 数字逐字引自 repaired / frozen 产物；出处列指向权威文件。

## 1. 样本与队列
- [x] 初始队列 n = 519（`PROJECT_CONTEXT.md §2`）。
- [x] 最终分析队列 n = 515，153 Control / 186 Low / 176 High exposure（同上）。
- [x] 515 样本来自 515 名独立受试者，无已知重复（`docs/protocol/STUDY_DESIGN_AUDIT.md` Material 行）。
- [x] Discovery 子集 n = 386（确定性切分，seed 20260925）；reused hold-out n = 129（同一队列，**非**外部/独立验证）。
- [ ] power / MDE 声明：当前**未做正式功效计算**；稿件须如实写 "no a priori power calculation; sample size fixed by recruitment"（待写作管线确认措辞）。

## 2. Protein universes（三层，勿混用）
- [x] Discovery inferential universe = 1,445（D01 eligible；85 DEPs 的 BH 族）。
- [x] 丰度模型 universe（M05–M10）= 1,430（Q515 tested）。
- [x] Pathway mapping universe = 1,434；unambiguous mapped = 1,414；ambiguous = 15；unmapped = 5。
- [x] Rankable gene-set universe = 1,406（cameraPR/ORA/fgsea 实际背景）。
- [x] 三层语义已登记：`docs/PATHWAY_UNIVERSE_RECONCILIATION.md`。

## 3. Multiple-testing families（不可相加）
- [x] Discovery 蛋白族 = 1,445（BH-FDR<0.05 → 85 DEPs）。
- [x] 交互族 = 1,430（0/1,430 Group×Environment survive BH-FDR<0.05）。
- [x] Pathway primary family = GO-BP + Reactome 跨族合并 BH（FDR_pooled）；cameraPR 205、ORA 23。
- [x] fgsea = sensitivity，双列 padj(家族) / padj_pooled(跨族)；family 44 / pooled 41；**Canonical_FDR=UNRESOLVED**。
- [x] KEGG = NOT_RUN。
- [ ] 稿件不得写 205+23+44 为单一通路计数。

## 4. Effect sizes / CIs
- [x] Discovery：85 DEPs（log2FC 来自 D02 moderated t，High-vs-Low = dosehigh−doselow，Environment 调整）。
- [x] Replication hierarchy：85 → 83 direction-concordant → 29 nominal（raw P<0.05）→ 1 FDR-supported。
- [ ] CI where available：稿件 Methods 须说明 limma eBayes trend/robust 的 log2FC/SE/CI 来源（`D02_Long_vs_Short_all_tested.csv`）；效应量表在 supplement。
- [ ] 候选 ROC / ML AUROC 为 exploratory，不得作为主效应量。

## 5. Software / package versions（冻结口径）
- [x] R 4.3.1 (2023-06-16 ucrt)。
- [x] limma 3.58.1；fgsea 1.28.0；org.Hs.eg.db 3.18.0；GO.db 3.18.0；reactome.db 1.86.2；
      clusterProfiler 4.10.1（辅助）；AnnotationDbi 1.64.1；data.table 1.18.4；statmod 1.5.0。
- [x] 出处：`M12_pathway_v2.1/M12_SOFTWARE_PROVENANCE.md`。
- [ ] tag 前补全 sessionInfo / renv.lock（P2-d，OPEN）。

## 6. Randomization / blinding
- [x] 样本切分 = 确定性（deterministic）seed 20260925，**非**随机切分；稿件须写 "deterministic split, seed-documented"。
- [x] fgsea random seed = 20260928 (Mersenne-Twister)；fgsea eps=0（精确，非 permutation 近似）。
- [x] strict nested outer seeds = 20260928/29/30。
- [ ] blinding：当前**无**盲法声明（样本处理/采集 metadata 不全）；稿件须如实写 "no formal blinding; preanalytical metadata incomplete"。

## 7. Missingness / imputation strategy
- [x] Discovery / D02 / M12 ranking：**无插补**，limma available observations（M12 已删行中位数插补）。
- [x] M09 KNN sensitivity：impute::impute.knn k=10, rowmax=0.5, colmax=0.8, maxp=1500, seed 20260925（repaired）。
- [x] strict nested：discovery 无插补；ML 预处理 outer-train median imputation + 标准化，原样应用到 outer test。
- [x] M11：observed log2 abundance，无插补。

## 8. Site / environment adjustment
- [x] D02 主模型 = `~0 + dose + environment`（Environment 主效应调整）。
- [x] M11 LOO：Environment retained，no unadjusted fallback；fixed cohort-weighted contrast。
- [x] 交互 = 0/1,430（M10 corrected_pure_interaction）；环境分层 concordance 为描述性，非交互检验。

## 9. Hold-out limitation
- [x] reused hold-out n=129 = 同一队列，**非**外部/独立验证；稿件须写 "reused internal hold-out"。
- [x] 85 不得称 validated；29 不得称 FDR-replicated；1 为唯一多重校正单蛋白复制。

## 10. ML（supplementary / supporting）
- [x] fixed-85：outer 5-fold × 3 repeat = 15 folds；LASSO / Elastic Net / XGBoost；
      mean outer AUROC LASSO 0.6651 / EN 0.6687 / XGB 0.6488。
- [x] strict nested：15 outer folds；7 zero-feature（MODEL_NOT_FIT_NO_FEATURES）；8 evaluable；
      evaluable mean LASSO 0.5967 / EN 0.5937；模型 = LASSO + EN only。
- [x] ML 性能 conditional on frozen 85-panel；非无偏泛化估计。
- [x] Boruta-style = hand-rolled ranger importance；XGBoost importance = post-selection descriptive。

## 11. Zero-feature fold handling
- [x] strict nested 7/15 fold 无 BH 显著特征 → `MODEL_NOT_FIT_NO_FEATURES`，不 rescue、不 top-N、不 fallback；
      这些 fold 不计入 evaluable AUROC（8/15）。
- [x] fold-local DEP 范围 8–618（历史）反映 feature-selection instability，不得解释为生物学异质性。

## 12. 待写作管线闭合项
- [ ] power/MDE 措辞；blinding 措辞；sessionInfo/renv.lock；fgsea canonical FDR 列裁定后回填 Methods 通路段。
