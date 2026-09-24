# 蛋白组代码维护与扩展 v2.1

状态：**implemented in code but not executed（已写入代码，未执行分析）**。

本轮只修改代码与文档。静态检查使用 R `parse()`、Python `ast.parse()` 和 Nature figure 源码检查器；没有 `source()`、导入或执行分析脚本，没有重新拟合模型、生成图片、安装依赖或改写任何科学结果。

## 1. 文档阅读顺序与当前流程

1. `README_REPRODUCIBILITY_v1.0.md`、`README_QC_DESCRIPTIVE_REPORT_v1.0.md`：原始数据、mapping 与基础描述性工作。
2. `README_CODE_MAINTENANCE_v2.0.md`：冻结范围、两项归档、统一上游入口、互斥 abundance pattern 分类。
3. **本文 v2.1**：新增 QC、检测分支、扩展结果图及整合图。本文仅补充本轮变化，不替代前两层说明。

旧 `README_PLASMA_PROTEOMICS_PROJECT_v2.0_FINAL*` 保留作历史参考；其中 dose/Low/High 的显示含义以维护文档为准。`control/low/high` 是 Control/Short exposure/Long exposure 的内部兼容键，不是连续浓度剂量。

```text
P1/P2/P3 与最终 mapping（冻结）
        ↓
run_all.py：描述性 QC → 定量过滤（既有入口不扩张）
        ├── core abundance 分支（原 70% 规则）
        │     normalization diagnostics → 原 05 limma（已存在，保持冻结）
        │     ├── 06a：PCA + UMAP 与既有主图
        │     ├── 06b / 06c：原稳健性分析
        │     └── DEP 汇总 / 09 / clustering / abundance pattern v2
        └── dose_restricted_detection.py：全部蛋白的二元检测分支
              ↓
            08_detection_pattern_analysis.R
              ↓
原 limma 结果 ──→ 06d_integrated_results.R：扩展 abundance 图 + 双分支整合

04_covariate_QC.R：读取 metadata、已有 QC/PCA 及可用 UMAP；不改 primary 模型
```

当前已有 primary 结果时，**无需为 v2.1 重跑 run_all、normalization diagnostics 或 05**。将来获准运行后的推荐顺序为：06a → 04；检测分类 → 08；两条输入均准备好后运行 06d。04 可以先运行，但尚无 UMAP 时会明确跳过 UMAP 关联图。目录中的数字不是严格运行顺序。

以下命令仅供将来获准运行时使用，本轮没有执行：

```powershell
Rscript F:/env/descriptive/06a_limma_core_figures.R
Rscript F:/env/descriptive/04_covariate_QC.R
python F:/env/descriptive/dose_restricted_detection.py
Rscript F:/env/descriptive/08_detection_pattern_analysis.R
Rscript F:/env/descriptive/06d_integrated_results.R
```

## 2. 本轮文件清单

| 文件 | 变更 | 状态 |
| --- | --- | --- |
| `descriptive/06a_limma_core_figures.R` | 完成 PCA/UMAP 输入与参数记录、Nature 样式、新版输出位置 | implemented in code but not executed |
| `descriptive/04_covariate_QC.R` | 新增协变量及前分析因素 QC | implemented in code but not executed |
| `descriptive/dose_restricted_detection.py` | 新增 exposure-restricted detection（暴露组限制性检出）分类 | implemented in code but not executed |
| `descriptive/08_detection_pattern_analysis.R` | 新增二元检出 logistic regression（逻辑回归）和敏感性模型 | implemented in code but not executed |
| `descriptive/06d_integrated_results.R` | 新增 MA、效应排序、forest、描述性 profile 与 abundance×detection 图 | implemented in code but not executed |
| `descriptive/v21_common.R` | 上述脚本共用的输入检查、Nature 样式和图形导出；不是分析入口 | implemented in code but not executed |
| `descriptive/06b_limma_robustness.R` | 仅三个 contrast 的显示名称更新 | implemented in code but not executed |
| `descriptive/06c_run_replication.R` | 仅日期分层表述与中文字段的字符串索引兼容修正 | implemented in code but not executed |
| `descriptive/10_protein_clustering.R` | 仅热图分组显示与标题更新；聚类计算、填补和输出路径不变 | implemented in code but not executed |

本轮没有新增归档。以下两个文件仍在原 archive，未恢复活跃使用：

- `descriptive/archive/06_limma_result_plots.R`
- `descriptive/archive/07_dose_trend_analysis.R`

P1/P2/P3、describe_proteomics、detection_gradient、design_composition、complete_four_layers、dose_quantitative_filtering、normalization_design_diagnostics、05、09、DEP_effect_size_summary、run_all 两个入口、requirements、测试文件、10_dose_pattern_classification 和 11 均未在本轮修改。06b、06c、clustering 的统计逻辑未改。所有原始数据、历史结果、旧 README 保留。

## 3. PCA + UMAP

PCA 保持为全局结构 QC 的主要图，UMAP 为补充展示。原 PCA 分数仍从 `complete_case_PCA_scores.csv` 读取。为使导出的 PCA 蛋白集合有依据，代码在未来运行时按当前矩阵中心化、不缩放重建 PCA，仅核对分数（允许轴符号翻转）和方差解释率；不覆盖旧 PCA、不拟合 limma。若不一致，明确停止，要求核对旧 diagnostics。

UMAP 使用 `PRIMARY_dose_log2_expression.csv.gz` 中在所有纳入样本上均为有限值的蛋白；不填补、不按 DEP 筛选、按蛋白中心化但不做方差缩放。保留约定参数：seed=20260922，Euclidean，min_dist=0.1，n_neighbors=min(15,n−1)，init=random，n_threads=1，n_sgd_threads=1。使用同一套坐标绘制暴露时长、环境、采集日期三个面板。

输出包含要求的 `Figure_A2b_complete_case_UMAP`、`Figure_A2c_PCA_UMAP_overview` PDF/PNG，UMAP source/parameters/proteins CSV，以及核对后的 `Figure_A2_PCA_proteins.csv`。参数表包括 `seed/metric/min_dist/n_neighbors/init/n_threads/n_samples/n_proteins/uwot_version/input_file/input_MD5`。蛋白数由输入确定，不再固定写 481。

**新的 06a 输出位置为 `descriptive/limma_dose_analysis/figures_final/06a_core_v2.1/`**，避免覆盖旧 `06a_core/`。旧 volcano 和其他主图继续保留在代码中。UMAP 聚集形状不作为组间差异显著性的证据。

## 4. 协变量 QC

输入为完整 `sample_statistics.csv`、`dose_defined_metadata.csv`，以及可用的 normalization diagnostics、PCA、v2.1 UMAP 坐标。完整性表覆盖全部 audited samples；暴露平衡和 QC 关联只使用 exposure-defined samples。所有匹配按 UniqueSampleID 明确进行，集合不一致会停止。

检查 Age、Sex、采样时间、采集日期、environment、region、Tube_Mixing、WoleBlood_oldTime、Plasma_HoldTime_h。字段不存在则在 `input_availability.csv` 标记 `absent_skipped`，不补造。`group` 单列为 Cohort_group，不自动当作 region。WoleBlood_oldTime 的单位不作推断。

当前已读取的元数据表头有采集日期、环境和三项前分析字段，没有 Age/Sex、独立 region 或采样时间字段；这是对表头的检查，不是数据分析结果。

缺失处理约定：

- `N_missing` 仅统计空白/真正 absent；`Unknown`、字面值 `NA`、`missing`、`0` 分开保留。
- 数值图只显示能解析为有限数值的观测，零仍是数值；表中另列有效数值和非数值 token 的数量。
- 年龄/留样数值按暴露组展示样本与 median/IQR（中位数及四分位距）；Sex 展示比例，日期等分类字段展示计数热图。高基数字段分页，不删除类别。
- QC 指标使用可用的 detected_protein_groups、missing_pct、log2_median、PC1/PC2、UMAP1/UMAP2。数值关联只报告描述性 Spearman correlation（秩相关）及配对样本数；不批量生成未校正 P 值。

输出目录为 `descriptive/covariate_QC/`，包含要求的：

```text
metadata_completeness.csv
exposure_covariate_balance.csv
QC_metric_covariate_summary.csv
```

图的源数据、原始 token 计数和被排除的 unknown-exposure 样本也会保存，用来解释缺失处理和图中样本数。QC 不自动改 primary 模型。

## 5. 与 abundance 平行的检测分类

`dose_restricted_detection.py` 读取原始工作簿全蛋白矩阵与已审核样本顺序，排除 unknown exposure；不调用或更改原 quantitative filter。**母表保留全部蛋白**，不局限于 1434 core proteins。

二元检出定义为 `finite quantitative value > 0`。其他值只在二元检测矩阵里记为 0，不生成 abundance=0 的表达矩阵。输出 `binary_detection_matrix.csv.gz` 和 `detection_metadata.csv` 是 08 的直接输入。

顶部参数 `TARGET_THRESHOLDS=(0.70,0.60)`、`OTHER_MAX_EXCLUSIVE=0.20` 集中定义规则：

| 类别 | 定义 |
| --- | --- |
| Control/Short/Long_specific | 目标一组 ≥target，另外两组都 <0.20 |
| Control_Short / Control_Long / Short_Long_enriched | 指定两组都 ≥target，剩下一组 <0.20 |
| Broad_detection | 三组都 ≥target |
| Sparse | 三组都 <0.20 |
| Other_unbalanced | 其余组合，包括中等检出比例 |

specific 是操作性“限制性检出”，不等于严格独有或生物学不存在。70% 为主定义，60% 为敏感性定义；本轮没有新增其他阈值。

输出目录 `descriptive/detection_pattern/` 包含要求的 rates、70pct/60pct restricted lists、summary、membership、parameters。每个阈值的 membership 覆盖全部蛋白。规则、源输入记录和包版本放在参数文件，不额外建立输出 checksum 清单。

## 6. 检测模型及技术因素敏感性

`08_detection_pattern_analysis.R` 主模型为 `detected ~ exposure + environment`，对全部蛋白拟合标准二项 logistic MLE（最大似然估计）。不重复加入 exposure duration 连续变量。

输出三个兼容 contrast：Low_vs_Control、High_vs_Control、High_vs_Low。返回 logOR（对数优势比）、OR（优势比）、logOR 的 SE、Wald P、BH FDR、OR 的 95% 区间和 Model_status。Long vs Short 的 SE 使用两个系数的完整协方差计算。

`detectseparation` 在拟合前检查 separation（完全或准完全分离）。常量检出、分离、设计不满秩、不收敛、不可估计、数值溢出或模型警告均保留记录，估计记为 NA。**没有自动 Firth/惩罚回归 fallback，也没有加伪计数**。零单元格被显式记录；只有无分离且估计正常时才报告结果。这一策略可能让某些高度 specific 蛋白没有可报告 OR，是模型限制，不是蛋白被删除。[方法接口说明](https://github.com/ikosmidis/detectseparation)

明确采用的可调整实现约定：

1. **BH family** 为每个 model×contrast 的全部母表蛋白。不可估计行仍为 NA，调整时保留完整蛋白数作为分母，避免仅对成功拟合或候选子集缩小检验范围。
2. **敏感性候选** 为 70% 或 60% 定义下六种 restricted 类别的并集。非候选行标记 `not_candidate`。
3. 采集日期敏感性为 `exposure + environment + acquisition_date`。只用有可用协变量的样本，并另拟合同一批样本上的 primary model，区分样本减少与协变量调整的影响。若日期与环境造成秩亏，输出 `rank_deficient_design`，不自动删除环境或日期。
4. **可选 Age/Sex 默认要求联合有效率 ≥90%**，由脚本顶部 `AGE_SEX_MIN_COMPLETE` 修改。这是本代码的可见实现假设，不是通用统计标准。字段缺失或未达门槛时跳过。零不自动视为缺失；未定义 token 保留原值并记录模型纳入情况。
5. `Direction_concordant` 比较全队列 primary 与 acquisition-adjusted 的符号。`Acquisition_sensitive` 则在相同样本集上标记符号反转，或 BH 0.05 判定发生改变。它是描述性提醒，不证明技术混杂；估计不完整时为 NA。

输出位置：`descriptive/limma_dose_analysis/results/10_detection_pattern_analysis/`。虽然放在主结果树下，**这些不是 limma 结果**。目录内方法 README 会在将来执行时写入。

主要文件为 `detection_primary_results.csv`、`detection_sensitivity_results.csv`、`detection_robustness.csv`。robustness 表每个蛋白×contrast 一行，包含要求的检测率、primary/adjusted effect、P/FDR、方向一致性、敏感性标记与状态。样本纳入表保留原始协变量值；失败汇总不隐藏失败蛋白。

## 7. 扩展 differential abundance 图及整合图

`06d_integrated_results.R` 接收已有 primary CSV、已保存 `PRIMARY_log2_dose_environment__fit.rds`、表达矩阵、metadata 和新 detection 结果；**不会调用 lmFit、eBayes 或改变原结果**。

每个 contrast 增加：

- **MA plot（平均表达量与差异效应图）**：x=AveExpr，y=logFC，显著性只按 BH FDR<0.05。
- **Effect rank plot（效应排序图）**：全部有限 logFC 排序，最多标注 6 个显著蛋白，按绝对效应选择标签；不限制绘制的蛋白数量。
- **Forest plot（效应及置信区间图）**：按 primary FDR 选择最多 12 个有有效区间的蛋白。`SE = stdev.unscaled × sqrt(s2.post)`，95% CI 使用保存 fit 的 `df.total` 和 t 分位数。核对 fit 与结果表的 protein/contrast/effect，不从 P 值推算区间。
- **Exposure profile（暴露组描述性表达图）**：按 FDR 选择最多 6 个代表蛋白，观测均值±SE，输出 n_observed/n_total。NA 不填零，类别连线不表示纵向跟踪或线性时长响应。这些均值不是调整后的 limma 效应。
- **Abundance×detection**：x 为调整后的 abundance log2FC，y 为原始检出率差；evidence 颜色来自各分支独立 BH FDR<0.05。

四类证据仅用于两个模型都可评估的蛋白：Abundance-only、Detection-only、Both、Neither。某一分支未测/不可估计时增加 `Not jointly evaluable`，不能把 NA 当成“不显著”。两套 FDR 不构成一个新的联合显著性检验。

全部蛋白保留在整合源数据。非 core 蛋白没有 abundance 横坐标，不强行赋为 0，也不悄悄删除；另绘 outside-core 检测差异图并导出计数。图中不显示的原因和代表蛋白选择数量有明确记录。

输出目录为 `descriptive/limma_dose_analysis/figures_final/06d_integrated_v2.1/`，含 PDF/PNG/SVG、源数据、证据类型计数及简短方法说明。

## 8. Nature 绘图约定与依赖

本轮绘图代码依据 **nature-figure skill**，使用 **R**。后续本项目新增/修改科研图继续沿用该 skill；不要在没有明确需求时改换绘图后端。Python 新脚本仅处理检测矩阵，不绘图。

共用样式采用白底、Arial/sans 字体、6 pt 起的主体文字、约 183 mm 宽度、克制的类别配色、可编辑 PDF/SVG 和 600 dpi PNG。样本散点、boxplot（中位数/IQR）、forest CI、profile SE 各有明确统计含义。UMAP/PCA 散点不是重复种子均值，不添加虚构误差条。未生成 TIFF，因为本次要求 PDF/PNG；SVG 用于可编辑版本。

新增或此次明确需要的 R 包：`uwot`（v2.0 已引入）、`detectseparation`、`ragg`、`svglite`。其余复用 ggplot2、dplyr、tidyr、patchwork、ggrepel、pheatmap、readr、limma。新 Python 脚本只复用 numpy、pandas、openpyxl。所有脚本检查依赖但不自动安装；本轮没有检查包能否实际加载。

`v21_common.R` 只集中重复使用的样式、图导出和 ID/列检查，避免在三个绘图文件中分别维护同一套设置。保留任务要求的输入 MD5/方法参数记录，没有增加环境冻结或独立发布审核流程。

## 9. 新输出位置与历史保护

| 将来生成的位置 | 用途 |
| --- | --- |
| `descriptive/covariate_QC/` | 协变量 QC |
| `descriptive/detection_pattern/` | 全蛋白检测率、二元矩阵与分类 |
| `descriptive/limma_dose_analysis/results/10_detection_pattern_analysis/` | 检测模型，不是 limma |
| `descriptive/limma_dose_analysis/figures_final/06a_core_v2.1/` | 新版 PCA/UMAP 和主图 |
| `descriptive/limma_dose_analysis/figures_final/06d_integrated_v2.1/` | 扩展及整合图 |

这些目录由脚本将来运行时创建，本次未创建科学输出。新脚本遇到已有非空目标目录会提示选择新的输出位置，以符合“不覆盖历史输出”；不会自动重命名或删除旧目录。06b/06c/clustering 的历史输出路径没有改，因此本轮也没有安排重跑这些脚本。

## 10. 静态检查、未执行项与暂停项

已完成：

- 8 个新增/修改 R 文件通过 R `parse(file=..., encoding="UTF-8")`，包含 `[[ ]]`、`[ ]`、`( )`、`{ }` 的解析检查。未执行解析得到的表达式。
- `dose_restricted_detection.py` 通过 Python `ast.parse()`；没有导入或调用 main。
- Nature 静态检查器检查共用样式及 04/06a/06d（包括共用样式源码），没有 FAIL。
- 阅读检查 ID 对齐、全蛋白保留、分组阈值、模型失败状态、CI 来源和输出路径。

静态检查提示及边界：

- R 启动时提示本机 `C.UTF-8` locale 设置失败；显式 UTF-8 解析及中文字段 `[["进样时间"]]` 通过。未改系统 locale。
- 源码检查器提示仍需 R 解析，已完成；提示缺 TIFF，本次依需求只保留 PNG 与矢量图。
- 检查器将 QC jitter/UMAP 的 seed 识别为可能需要误差带；这里不是多种子聚合统计，样本散点无需人为加误差带。06d 的真实 CI/SE 已在代码中明确。
- 没有 runtime tests（运行测试）、实际拟合、图形导出、PDF 字号审核或最终尺寸视觉检查。静态通过不等于统计结果或图形效果已验证。

所有新增分析的状态仍为 **implemented in code but not executed**，没有任何一项标为 executed and validated。

仍暂停：旧 pattern 所依赖的 `11_pattern_protein_annotation.R`，两套 GO/KEGG enrichment；旧 pattern/annotation 结果维持 v2.0 中的 OLD/invalid 解释。`10_dose_pattern_classification.R` 继续使用 v2.0 互斥 schema，分类均值仍不填零。05 中线性 trend 及两个 archive 脚本为 historical，不进入当前解释流程。

planned only：正式获准运行后的数值验证、图形排版检查、旧 annotation schema 的迁移；本轮不预先宣称这些工作已完成。
