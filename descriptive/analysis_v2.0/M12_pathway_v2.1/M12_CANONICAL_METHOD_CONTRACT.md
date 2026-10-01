# M12 Canonical Method Contract

> 日期：2026-10-01。Phase 5 方法合同。
> 状态：CONTRACT_DRAFTED_PENDING_EXECUTION. 本合同不执行任何分析；它规定重跑时必须遵守的 canonical 方法。
> 权威总状态：FREEZE_READINESS=BLOCKED; SUBMISSION_READINESS=BLOCKED; ANALYSIS_REOPEN_REQUIRED=YES; SAFE_TO_TAG_ANALYSIS_V2_1=NO.
> M12=BLOCKED_PENDING_RERUN; M12B=BLOCKED_BY_M12; 历史 195/23/39=PRE_REPAIR_EXISTING_OUTPUT.

---

## 1. Purpose

本合同是 M12 通路富集分析的唯一 canonical 方法合同。它规定重跑 M12/M12B 时必须使用的样本宇宙、蛋白宇宙、映射宇宙、排序统计量、插补策略、协变量调整、对比、三种通路方法（cameraPR/ORA/fgsea）的 FDR 族、M12B 的角色定位、GO/Reactome/KEGG 的角色、集成逻辑与图形依赖。

本合同不重算任何通路统计量；所有数字为历史 PRE_REPAIR_EXISTING_OUTPUT，重跑后须重新核定。

---

## 2. Primary reference analysis

**Primary reference**: D02 discovery primary model (`descriptive/discovery_validation/code/D02_discovery_primary.R`).

D02 是 frozen Discovery 的正式主模型：
- Design: `~0 + dose + environment`（`dv_shared.R` L99）
  - dose: factor(control, low, high) — 3 水平
  - environment: factor(Humid-hot, High-pressure/high-altitude) — 2 水平
  - **无交互项**；environment 作为主效应调整
- Primary contrast: `Long_vs_Short = dosehigh - doselow`（`dv_shared.R` L103）即 High-vs-Low
- Model: `limma::lmFit` → `contrasts.fit` → `eBayes(trend=TRUE, robust=TRUE)`（`dv_shared.R` L80）
- 输出：log2FC, SE, CI_low, CI_high, P_value, BH_FDR, AveExpr, residual_df, Model_status
- BH family: 1,445 Discovery-eligible proteins
- Diagnostics: `D02_diagnostics.csv` 记录 remaining_missing_cells、normalization=NONE、transformation=log2、imputation=NONE

---

## 3. Sample universe

- **Sample universe for M12 ranking**: Discovery subset, High exposure + Low exposure only（n=271; High=132, Low=139）。
- Control 排除（与 D02 primary contrast 一致）。
- 来源：`discovery_validation_split/discovery_validation_assignment.csv`（SHA-256 冻结）。
- 环境分层分析（M12 environment/）：Humid-hot n=138 与 High-pressure/high-altitude n=133 分别拟合，仅作描述性方向一致性，不作交互检验。

---

## 4. Protein universe

- **Canonical protein universe**: D01 Discovery-eligible proteins = **1,445**（`D01_discovery_eligibility/D01_discovery_eligible_proteins.csv`）。
- 历史 M12_02 使用 `PRIMARY_dose_log2_expression.csv.gz`（Q515 全队列丰度宇宙 = 1,434 proteins）。
- **冲突裁决**: canonical 宇宙应为 D01 eligible = 1,445。M12_02 历史实现使用 1,434 为 PRE_REPAIR 偏差；重跑时 ranking statistic 必须取自 D02 输出（1,445 蛋白），而非自行从 Q515 矩阵重拟合。
- 映射后：1,414 个 one-gene 映射（见 §5）。

---

## 5. Mapping universe

| 项目 | 数值 | 来源 |
|---|---|---|
| Tested protein groups（D01 eligible） | 1,445 | D01_discovery_eligible_proteins.csv |
| Gene-mapped representative genes | 1,414 | M12_gene_mapping_summary.csv |
| Multi-gene ambiguous | 15 | 映射时排除 |
| Unmapped | 5 | 映射时排除 |
| Duplicate-gene groups | 0 | 无 |
| Gene ID 类型 | gene symbol | M12_01_mapping.R |
| ORA background | 1,414 mapped genes | 非 1,445、非 1,434 |

> 注意：历史 M12_01_mapping.R 以 Q515=1,434 为起点。重跑时应改为从 D01 eligible=1,445 出发映射；预期映射数可能微调（历史 1,414 为 PRE_REPAIR）。

---

## 6. Ranking statistic

- **Canonical ranking statistic**: signed moderated t from D02 primary model（即 `log2FC / SE` from `D02_Long_vs_Short_all_tested.csv`，等价于 `topTable` 的 t 统计量）。
- **禁止**: M12_02_ranked_ora.R 历史实现中自行重拟合的 `~group`（无 environment 调整）+ 行中位数插补模型。
- **P5 冲突记录**:
  - D02 model: `~0+dose+environment`（adjusted for environment），no imputation，1,445 proteins。
  - M12_02 historical: `~group`（unadjusted），row-wise median imputation，1,434 proteins。
  - **裁决**: canonical ranking 必须取自 D02-compatible model。M12_02 须 repair：删除自行 lmFit/eBayes 重拟合与中位数插补代码，改为读取 D02 输出并构造 signed moderated t（= log2FC/SE）作为 cameraPR/cameraPR/fgsea 的输入。
  - 这不是 METHOD_CONTRACT_CONFLICT（权威合同可裁定）：D02 是 frozen Discovery 主模型，v2.1 §10 要求 pathway 使用同一 High-vs-Low contrast；M12_02 的 deviation 是实现偏差，须 repair。

---

## 7. Imputation policy

- **Canonical: NO imputation.**
- D02 不做任何插补（diagnostics: imputation=NONE）。
- M12_02 历史实现（L61–64）做行中位数插补。
- **裁决**: 重跑时不得插补。ranking statistic 直接取自 D02 输出；D02 标记为 NON_ESTIMABLE 的蛋白不进入 cameraPR/ORA/fgsea 输入（或明确标记为非估计）。
- 技术上若 cameraPR 需要完整排名向量：仅使用 D02 Model_status == "ESTIMABLE" 的蛋白；NON_ESTIMABLE 蛋白排除并记录数。

---

## 8. Environment adjustment

- **Canonical: environment adjusted.**
- D02 design 含 environment 主效应（`~0+dose+environment`）。
- M12_02 历史 design 仅 `~group`（无 environment）。
- **裁决**: 重跑时 ranking statistic 必须来自 environment-adjusted model（即 D02）。M12_02 不得自行拟合 unadjusted model。

---

## 9. Contrast

- **Contrast**: High exposure vs Low exposure（High-vs-Low）。
- 与 D02 primary contrast（`dosehigh - doselow`）一致。
- Control 排除。
- 符号约定：负 log2FC = High exposure 中更低。与 D03 lock 一致。

---

## 10. cameraPR contract

| 项目 | Canonical 值 |
|---|---|
| 方法 | `limma::cameraPR` |
| use.ranks | FALSE |
| inter.gene.cor | 0.01（primary）；0.05（sensitivity） |
| 排序统计量 | signed moderated t from D02（§6） |
| Gene set size filter | 10–500（与背景交集后） |
| **Primary families** | GO BP + Reactome（仅这两族进入主 PATH-R FDR_pooled） |
| FDR column（primary） | `FDR_pooled` = BH across GO BP + Reactome（KEGG absent） |
| FDR threshold | 0.05 |
| **Secondary families**（M12B） | GO MF + GO CC；per-family `FDR`（不与 BP/Reactome 合并） |
| 输出文件 | `ranked/M12_ranked_GO_BP.csv`, `M12_ranked_Reactome.csv`, `M12_ranked_combined_FDR.csv`（primary）；`M12_ranked_GO_MF.csv`, `M12_ranked_GO_CC.csv`（secondary, M12B） |

- **P9 FDR family 裁决**: 历史实现为跨 GO-BP + Reactome 合并 BH（`FDR_pooled`）。协议未明确指定；接受历史实现为 de facto contract。MF/CC 为 M12B 次要分支，per-family BH，不计入主 PATH-R 的显著计数。
- 历史数字（PRE_REPAIR）：GO BP=274 tested / 25 sig；Reactome=487 tested / 170 sig；合计 195。重跑后须重新核定。

---

## 11. ORA contract

| 项目 | Canonical 值 |
|---|---|
| 方法 | Fisher exact test, one-sided (`alternative="greater"`) |
| Foreground | 85 locked D03 DEPs（gene-symbol mapped） |
| Background | 1,414 mapped tested-universe genes（**非 1,445、非 1,434**） |
| **Primary families** | GO BP + Reactome |
| FDR column（primary） | `FDR_pooled` = BH across GO BP + Reactome |
| FDR threshold | 0.05 |
| **Secondary families**（M12B） | GO MF + GO CC；per-family `FDR` |
| 输出文件 | `ora/M12_ORA_GO_BP.csv`, `M12_ORA_Reactome.csv`, `M12_ORA_combined_FDR.csv`（primary）；`M12_ORA_GO_MF.csv`, `M12_ORA_GO_CC.csv`（secondary） |

- 历史数字（PRE_REPAIR）：GO BP=154 tested / 3 sig；Reactome=178 tested / 20 sig；合计 23。重跑后须重新核定。

---

## 12. fgsea contract

| 项目 | Canonical 值 |
|---|---|
| 方法 | `fgsea::fgseaMultilevel` |
| minSize / maxSize | 10 / 500 |
| scoreType | "std" |
| 排序统计量 | 与 cameraPR 相同的 signed moderated t from D02 |
| Families | GO BP + GO MF + GO CC + Reactome（四族全跑，由 M12B_all.R） |
| KEGG | NOT_RUN |
| 输出文件 | `ranked_gsea/M12_fgsea_{GO_BP,GO_MF,GO_CC,Reactome}.csv` + `M12_fgsea_combined.csv` |

### P13/P15 FDR family 裁决

fgsea combined CSV 中存在两列 FDR：
- `padj` = fgseaMultilevel 默认的家族内 BH（每族独立校正）
- `padj_pooled` = M12B_all.R L204 跨 4 族合并 BH

**协议状态**: v2.1 §10 未明确指定 fgsea FDR family。

**裁决**:
- **Canonical_FDR = UNRESOLVED**（FGSEA_FDR_FAMILY_UNRESOLVED）。
- 重跑时**必须同时输出两列**（`padj_family` = per-family；`padj_pooled` = cross-family），不得只保留一列。
- 两套计数均不标 FINAL_FROZEN；待执行管线重跑后由团队明确选择 canonical FDR family。
- 历史数字（PRE_REPAIR）：
  - padj (per-family): GO BP=3, GO MF=8, GO CC=11, Reactome=17（合计 39）
  - padj_pooled (cross-family): GO BP=5, GO MF=6, GO CC=11, Reactome=17（合计 39）
- **推荐（非强制）**: 若须默认取最保守透明方案，取 `padj_pooled`（跨族合并 BH，校正族更大、更严格）。但此推荐不构成 canonical 决定；须团队确认。
- 相关 reconciliation 文档：见 `FGSEA_FDR_RECONCILIATION.md`（框架另起）。

---

## 13. M12B role

- **M12B = secondary biological context / contextual integration layer**。
- M12B **不是**: mechanism validation、regulatory network proof、independent pathway confirmation、WGCNA co-expression analysis。
- M12B 包含什么（由 `M12B_all.R` 静态判定）：
  1. **GO MF cameraPR**（次要，per-family FDR）— 108 tested, 15 sig（PRE_REPAIR）
  2. **GO CC cameraPR**（次要，per-family FDR）— 151 tested, 19 sig（PRE_REPAIR）
  3. **GO MF ORA**（次要，per-family FDR）— 53 tested, 7 sig（PRE_REPAIR）
  4. **GO CC ORA**（次要，per-family FDR）— 81 tested, 4 sig（PRE_REPAIR）
  5. **fgsea multilevel**（四族全跑，sensitivity）— 由 M12B 实现
  6. **Pairwise Spearman correlation** among 85 locked candidates（描述性，非 co-expression network）
  7. **Bipartite pathway–gene network**（描述性，top pathways × core genes）
  8. **Environment-stratified ranked pathway analysis**（Humid-hot vs High-altitude，描述性方向一致性）
  9. **ML candidate pathway membership table**
  10. **Pathway redundancy clusters**（greedy Jaccard > 0.5，去冗余视图）
- M12B 产出的 GO MF/CC cameraPR 与 ORA 均不计入主 PATH-R/PATH-O 的 canonical 计数。

---

## 14. GO-BP / MF / CC 角色

| Ontology | cameraPR 角色 | ORA 角色 | fgsea 角色 |
|---|---|---|---|
| GO BP | **Primary**（PATH-R 主族之一） | **Primary**（PATH-O 主族之一） | Sensitivity |
| GO MF | Secondary（M12B，per-family FDR） | Secondary（M12B，per-family FDR） | Sensitivity |
| GO CC | Secondary（M12B，per-family FDR） | Secondary（M12B，per-family FDR） | Sensitivity |

- 不得将 "GO" 缩减为 GO-BP 来指代全部 GO。
- GO MF/CC 存在于仓库中，但属次要分析；主结果引用 GO 时须明确是 BP。

---

## 15. Reactome role

- **Primary**（PATH-R 与 PATH-O 的主族之一）。
- Reactome 高度冗余；`integration/M12_pathway_redundancy_clusters.csv`（Jaccard > 0.5）为去冗余视图。
- 稿件应引用代表性 theme，而非 raw 170 Reactome hits。

---

## 16. KEGG role

- **NOT_RUN**。
- 原因：KEGG REST API 返回不完整通路列表；`clusterProfiler::download_KEGG("hsa")` 失败。
- 占位 CSV（`M12_ranked_KEGG.csv`, `M12_ORA_KEGG.csv`）记录 provenance。
- `M12_02b_kegg_fix.R` 已移出 canonical 链（HISTORICAL_NON_CANONICAL）。
- 稿件不得暗示 KEGG 已运行；pathway database 列表仅列 GO BP/MF/CC + Reactome。

---

## 17. FDR families 汇总

| Family | Method | Tested universe | 校正列 | 校正范围 | Threshold | 角色 |
|---|---|---|---|---|---|---|
| PATH-R primary | cameraPR | GO BP + Reactome gene sets | FDR_pooled | BH across BP+Reactome | 0.05 | Primary ranked |
| PATH-R secondary MF | cameraPR | GO MF gene sets | FDR | BH within GO MF | 0.05 | Secondary (M12B) |
| PATH-R secondary CC | cameraPR | GO CC gene sets | FDR | BH within GO CC | 0.05 | Secondary (M12B) |
| PATH-O primary | ORA | GO BP + Reactome | FDR_pooled | BH across BP+Reactome | 0.05 | Complementary |
| PATH-O secondary MF | ORA | GO MF | FDR | BH within GO MF | 0.05 | Secondary (M12B) |
| PATH-O secondary CC | ORA | GO CC | FDR | BH within GO CC | 0.05 | Secondary (M12B) |
| fgsea family | fgseaMultilevel | 4 families | padj / padj_pooled | per-family / cross-family | 0.05 | Sensitivity |

- 这些 FDR 列**不可互换**。每个结果必须标注其 family。

---

## 18. Integration logic

- M12_03_integration.R 负责：core genes、environment-stratified 结果、ML candidate membership、redundancy clusters。
- 不做 weighted evidence score、不做 composite p-value、不做 post-hoc ranking。
- Pathway 结果不得反向选择 ML features（v2.1 §10）。
- 三方法（cameraPR/ORA/fgsea）回答不同问题；**不得将 195+23+39 相加**为单一通路数。

---

## 19. Figure dependency

- Fig6a: cameraPR GO BP top 8（FDR_pooled 排序）
- Fig6b: cameraPR × fgsea 一致性散点（x=cameraPR FDR, y=fgsea padj per historical M17 script L289）
- Fig6c: ORA GO BP top 10
- Fig6d: bipartite network（GO BP top-4 pathways × core genes）
- **Fig6 = NOT_FINAL**：主分析 195 条中 170 条 Reactome 无 curated 面板；重跑后须扩充呈现方可代表完整通路证据。
- 通路 Supplement 目前为零图；若稿件需展示 MF/CC/Reactome/fgsea 全输出，须新建。

---

## 20. Software provenance（P31 计划）

已收集版本（本机 R 4.3.1）：

| Package | Version |
|---|---|
| R | 4.3.1 (2023-06-16 ucrt) |
| limma | 3.58.1 |
| fgsea | 1.28.0 |
| org.Hs.eg.db | 3.18.0 |
| GO.db | 3.18.0 |
| reactome.db | 1.86.2 |
| clusterProfiler | 4.10.1 |
| AnnotationDbi | 1.64.1 |
| data.table | 1.18.4 |
| statmod | 1.5.0 |
| glmnet | 5.0 |
| ranger | 0.18.0 |
| xgboost | 3.2.1.1 |
| logistf | 1.26.1 |

- Annotation 源（org.Hs.eg.db / reactome.db）会随 Bioconductor 版本变化；重跑时须重新记录并冻结。
- 正式 `M12_SOFTWARE_PROVENANCE.md` 由执行管线重跑时写；本合同仅提供已收集版本基线。

---

## 21. 重跑时需 repair 的脚本（本合同不替执行管线改代码）

| 脚本 | 需 repair 的理由 |
|---|---|
| `M12_01_mapping.R` | 已修复 nrows=0 读取问题 + 加 stopifnot 断言（见 M12_MAPPING_REPAIR_NOTE.md）；重跑后核验 universe 数 |
| `M12_02_ranked_ora.R` | **重大 repair**：(1) 删除自行 lmFit/eBayes 重拟合；(2) 删除行中位数插补；(3) 改为读取 D02 输出（`D02_Long_vs_Short_all_tested.csv`）并构造 signed moderated t（log2FC/SE）作为 ranking statistic；(4) protein universe 从 D01 eligible=1,445 出发（非 Q515=1,434）；(5) 保持 cameraPR GO BP+Reactome primary + pooled BH |
| `M12_02b_kegg_fix.R` | 已移出 canonical 链（HISTORICAL_NON_CANONICAL）；重跑不得依赖 |
| `M12_03_integration.R` | 需适配新 ranking statistic 与 universe；environment-stratified 分析须用 environment-adjusted model |
| `M12B_all.R` | (1) fgsea ranking statistic 改为 D02 moderated t；(2) fgsea combined CSV 须同时输出 padj_family 与 padj_pooled 两列；(3) GO MF/CC cameraPR 与 ORA 保持 secondary 定位 |

---

## 22. Canonical 重跑顺序（建议，供执行管线参考）

1. 确认 D01/D02/D03 frozen 产物不变（只读引用）。
2. Repair M12_01_mapping.R（已做，待核验）。
3. Repair M12_02_ranked_ora.R：切换到 D02-derived ranking statistic + no imputation + environment-adjusted。
4. 重跑 M12_01 → M12_02 → M12_03。
5. Repair M12B_all.R：切换 ranking statistic + 双列 FDR 输出。
6. 重跑 M12B_all.R。
7. 核定新 universe（预期接近 1,445 → ~1,414 mapped）。
8. 核定新 cameraPR/ORA/fgsea 计数。
9. 团队裁定 fgsea canonical FDR family（padj vs padj_pooled）。
10. 重建 Fig6（含 Reactome 呈现）与通路 Supplement。

---

**合同状态**: CONTRACT_DRAFTED. 待执行管线按此合同重跑后转为 FINAL_CONTRACT.
