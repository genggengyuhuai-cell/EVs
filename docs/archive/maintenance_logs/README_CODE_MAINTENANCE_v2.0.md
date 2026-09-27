# 活跃代码维护与复现说明 v2.0

版本：2.0  
适用目录：`F:/env`  
状态：本次仅编辑代码、归档两个指定脚本及新增说明；未执行 Python/R 分析、测试、绘图或依赖安装。运行正确性尚未验证，没有生成新版分析结果。

本文是本轮代码维护的入口说明。旧 README 全部保留；如旧文档仍把 Low/High 解释为剂量、把 06c 称为独立 replication，或继续推荐旧 plotting/trend 脚本，以本文的维护状态为准。既有 `v2.0_FINAL*` 文档未被覆盖。

## 1. 当前目录与修改范围

```text
F:/env/
├── code/                         P1.py、P2.py、P3.py：冻结
├── rawdata/                      原始工作簿及最终映射：不修改
├── descriptive/                  实际分析脚本所在位置
│   ├── archive/
│   │   ├── 06_limma_result_plots.R
│   │   └── 07_dose_trend_analysis.R
│   ├── run_all.py                唯一上游流程实现
│   ├── run_all_with_dose_filtering.py  兼容转发入口
│   ├── DEP_effect_size_summary.R      原 07_DEP_threshold_summary.R
│   ├── 10_dose_pattern_classification.R  原位置重写
│   └── limma_dose_analysis/      既有结果均保留
└── reademe/                      本项目实际文档目录名称
    └── README_CODE_MAINTENANCE_v2.0.md
```

只有 `06_limma_result_plots.R` 和 `07_dose_trend_analysis.R` 被移到 archive，未物理删除。DEP 汇总脚本只改名，功能仍保留。其他脚本、回归测试、requirements 文件、旧 README 和结果目录均未被删除或归档。

## 2. 文件状态

| 文件 | v2.0 状态 |
| --- | --- |
| P1.py / P2.py / P3.py | 保留冻结；不自动运行，不修改最终映射历史链 |
| describe_proteomics.py | 保留冻结；原始数据描述及 integrity audit |
| detection_gradient.py | 保留冻结；完整 detection gradient |
| design_composition.py | 保留冻结；研究设计与队列组成 QC |
| complete_four_layers.py | 保留冻结；不继续扩张 |
| dose_quantitative_filtering.py | 正式上游主线；逻辑未改 |
| normalization_design_diagnostics.py | 保留未改；独立的后续诊断步骤 |
| 05_limma_dose_analysis.R | 主分析与敏感性分析全部保留未改，包括历史 trend 代码 |
| 06_limma_result_plots.R | 归档至 descriptive/archive；不再使用 |
| 06a_limma_core_figures.R | 主图；更新暴露时长术语，增加 UMAP 与 PCA/UMAP 总览 |
| 06b_limma_robustness.R | 保留未改；稳健性统计逻辑冻结 |
| 06c_run_replication.R | 保留文件名与统计逻辑；更新为 acquisition-date-stratified robustness 表述 |
| DEP_effect_size_summary.R | 原 07_DEP_threshold_summary.R；只汇总既有结果，不重新拟合 |
| 07_dose_trend_analysis.R | 归档至 descriptive/archive；不再使用 |
| 09_DEP_characterization.R | 保留未改；Long vs Short 的 DEP 母表，兼容旧键 High_vs_Low |
| 10_protein_clustering.R | 保留未改；探索性聚类，不升级为统计推断 |
| 10_dose_pattern_classification.R | 原位置实质重写；新规则及输出 schema 2.0 |
| 11_pattern_protein_annotation.R | 保留未改、暂停；不能直接消费新版分类 schema |
| run_all.py | 正式统一入口：descriptive QC + filtering |
| run_all_with_dose_filtering.py | 保留；调用 run_all.main，不再维护第二份流程 |
| test_run_all.py | 保留原位置；本次未运行，也未移动 |
| requirements.txt | 保留未改 |

## 3. 术语与锁定统计边界

显示层使用 Control、Short exposure、Long exposure。数据字段及既有结果键仍保留 `control/low/high`、`TREAT1_clean`、`dose` 和 `High_vs_Low`，避免破坏既有统计结果的读取。

| 旧数据键 | 当前解释 |
| --- | --- |
| control | Control |
| low / Low | Short exposure |
| high / High | Long exposure |
| Low_vs_Control | Short exposure vs Control |
| High_vs_Control | Long exposure vs Control |
| High_vs_Low | Long vs Short exposure |

这里是类别名称映射，不推定具体暴露时长，也不把 0/1/2 当作连续线性剂量。本轮没有全面改写冻结脚本中的历史术语。

定量分支的规则保持不变：去除 unknown；每个暴露组至少 70% detection 为 primary core；50/60/80% 集合继续保留。519→515、primary 1434 proteins 是原项目记录，不是本轮重跑核验结果。主分析继续使用原 log2 abundance、保留 NA；原 primary 与 sensitivity limma 模型均未调整。

`05` 内的 `07_SECONDARY_dose_trend` 为保留的历史计算分支，未删除。因此将来完整执行 `05` 仍可能生成该历史输出；它不再进入当前解释主线。

## 4. 主图 06a

保留读取既有 primary limma 结果的方式，不重新拟合 limma。原 PCA 图继续读取 `complete_case_PCA_scores.csv`；去掉写死的“481 proteins”副标题。

新增代码会在用户将来运行时产生：

- `Figure_A2b_complete_case_UMAP.pdf/png`：按暴露时长、环境和采集日期着色的三个面板。
- `Figure_A2c_PCA_UMAP_overview.pdf/png`：PCA 与 UMAP 的两行总览。
- `Figure_A2b_UMAP_source_data.csv`：样本坐标及分组。
- `Figure_A2b_UMAP_parameters.csv`：参数、样本/蛋白数、uwot 版本、输入 MD5。
- `Figure_A2b_UMAP_proteins.csv`：实际进入 UMAP 的完整观测蛋白列表。

UMAP 基于既有 primary log2 矩阵中所有样本均有限值的蛋白，按蛋白中心化、不做方差缩放、不填补；不用 DEP 筛选结果来选择 UMAP 特征。参数为 seed=20260922、Euclidean、min_dist=0.1、最多 15 个邻居（不超过样本数减一）、random initialization、单线程。现有 PCA 与表达矩阵的样本集合不一致时会停止。

新增 R 依赖 `uwot`，代码仅检查依赖，不自动安装。其余 06a 依赖仍为 ggplot2、dplyr、tidyr、readr、patchwork、ggrepel、pheatmap。UMAP 是探索性展示，不提供差异显著性或独立验证证据。现有 PCA 文件是否与当前矩阵同步仍需后续正式运行前确认。

## 5. 06c 与 DEP 汇总

06c 仍分析 20260527、20260717 两个 acquisition-date strata 内的 exposure comparison，原拟合、contrast 和缺失值规则不变。面板及控制台改用 exposure duration、concordance、stratified robustness，不称为独立生物学重复。

为兼容历史结果，本轮保留文件名 `06c_run_replication.R`、输出目录 `run_replication/`、`figures_final/06c_run_replication/` 及既有输出文件名。这些路径中的 replication 只是历史命名，不代表独立重复验证。

`07_DEP_threshold_summary.R` 已重命名为 `DEP_effect_size_summary.R`。仍汇总 BH FDR <0.05、FDR 加 |log2FC|≥0.5、FDR 加 |log2FC|≥1；输出仍在 `results/09_DEP_threshold_summary/`，不修改既有表字段及计算逻辑。注意阈值针对 **log2FC**，不是原始倍数 FC。

## 6. 模式分类 v2.0

输入仍为 `09_DEP_characterization/High_vs_Low_DEP_all.csv`、primary log2 矩阵及 dose-defined metadata。脚本校验必需列、唯一 ID、样本集合、DEP 蛋白覆盖、组别和 BH FDR <0.05；不再静默丢弃矩阵中不存在的 DEP。

定义 `d1 = Short − Control`、`d2 = Long − Short`，沿用原描述性容差 `tol=0.05 log2`。每个差值只有三个状态：大于 tol 为 +；小于 −tol 为 −；其余为 0，包含等于边界的值。

| d1 | d2 | 新 Pattern |
| --- | --- | --- |
| + | + | Ordered_increase |
| − | − | Ordered_decrease |
| + | − | Short_peak |
| − | + | Short_trough |
| 0 | + | Long_elevation |
| 0 | − | Long_suppression |
| + | 0 | Short_elevation_plateau |
| − | 0 | Short_suppression_plateau |
| 0 | 0 | Adjacent_changes_within_tolerance |

九格互斥且覆盖全部有限组均值组合，修复原先 suppression 抢先吞掉 decrease 的问题。任一组均值缺失则为 `Insufficient_data`；相邻变化均在容差内，不等价于三组总极差也在容差内。

分类均值只用真实观测 log2 数据，不填 0，同时导出各组有效观测数及总样本数。均值是未调整的描述量，容差不是显著性检验；原 limma logFC/FDR 作为单独字段保留。Ordered 名称只表示三个类别均值的顺序，不代表线性时长响应。

热图单独复制矩阵，按现有 clustering 脚本约定在 log2 矩阵中先 NA→0，再做 protein-wise z-score；这一处理只用于探索性热图，不反馈到组均值、分类或 limma。零方差行不进入热图，但仍保留分类表记录，并导出 heatmap inclusion 表。分类图修复旧版 ggplot 重复拼接；profile 图展示逐蛋白中心化组均值及类别平均线，不计算跨蛋白的推断性置信区间。

未来新版输出写到：

```text
descriptive/limma_dose_analysis/results/10_dose_pattern_classification_v2/
descriptive/limma_dose_analysis/figures_final/10_dose_pattern_classification_v2/
```

主表仍叫 `DEP_three_group_pattern.csv`，新列为 `Control/Short/Long`、对应观测数、相邻及总差值、Pattern、logFC、adj.P.Val、Pattern_version、Tolerance_log2。另有 summary、profile source、heatmap inclusion、输入 MD5 和方法说明。

本轮没有运行，所以上述新版输出尚未生成。现有 `10_dose_pattern_classification/` 及其图、依赖旧分类的 `11_pattern_protein_annotation/` 都保留原位，但视为 **OLD / invalid-dependent-on-old-pattern**，不可作为最终解释依据。没有执行结果目录重命名。

脚本 11 仍筛选 `Low_peak` 并读取 `Low/High` 列，因此**即使以后生成 v2 结果，也不能直接恢复运行 11**。后续须明确迁移输入目录和 schema、复核新分类后再恢复；本轮不修改该暂停脚本。

## 7. 统一入口及将来的复现顺序

`run_all.py` 现在按以下固定顺序调用：

1. describe_proteomics.py
2. detection_gradient.py
3. design_composition.py
4. complete_four_layers.py
5. dose_quantitative_filtering.py

沿用含过滤版本的日志、源文件 SHA256、包版本、子进程错误输出和产物检查机制。`run_all_with_dose_filtering.py` 仅调用同一个 main，两个命令都会执行同一套上游步骤，不需要先后各跑一次。

以下只是供将来使用的命令，本次没有执行：

```powershell
python F:/env/descriptive/run_all.py
```

该入口不自动调用 P1/P2/P3、normalization diagnostics、任何 R 分析、模式注释或 GO/KEGG。

需要将来重建下游时，顺序为：上游入口 → normalization_design_diagnostics.py → 05 → 06a/06b/06c；DEP 汇总读取 05；09 读取 05；聚类及模式 v2 读取 09。脚本 11 与两套 enrichment 目录维持暂停。既有部分 R 脚本依赖工作目录，单独调用时以 `F:/env/descriptive` 为工作目录；本轮没有批量改写冻结脚本的路径逻辑。

## 8. 保留的历史结果与验证状态

primary、各 sensitivity、interaction、diagnostics、figures_final、robustness、run_replication 及 DEP/clustering 结果均保留。`07_SECONDARY_dose_trend` 降级为历史输出。`10_functional_enrichment` 与 `10_functional_enrichment_v2` 尚未判定替代关系，均保留且暂停，不继续产出结果。

本轮检查仅限阅读代码与核对文件内容/目录。未执行分析脚本、Python/R 语法检查、测试、模型拟合、绘图、网络注释或依赖安装；不宣称任何运行检查已经通过。
