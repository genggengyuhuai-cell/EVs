# 前分析元数据审计（P16，静态）

> 视角：preanalytical / technical metadata 的记录与建模状态静态审计。
> 方式：只读元数据表 / 映射 / 协议 / 协变量矩阵；未运行脚本。
> 权威总状态：FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED。
> 数字逐字引自文件并标注出处。

## 1. 元数据可用列（权威来源）

- `descriptive/dose_defined_metadata.csv` 表头（逐字）：
  `Sheet1_position, Sheet1_raw_header, Resolution_method, metadata_index, metadata_excel_row, UniqueSampleID, 进样时间, sample, condition, group, TREAT1, TREAT1_clean, TREAT2, Tube_Mixing, WoleBlood_oldTime, Plasma_HoldTime_h, Note, detected_protein_groups, missing_pct, MS_batch_proxy`
- `descriptive/covariate_QC/input_availability.csv`：`Age / Sex / Collection_time / Region` 状态 = `absent_skipped`；`Acquisition_date=进样时间 / condition / group / Tube_Mixing / WoleBlood_oldTime / Plasma_HoldTime_h` = available。
- `descriptive/06_covariate_QC.R:25,30`：Acquisition_date 别名 = `c("进样时间","MS_batch_proxy","acquisition_date","run_date")`；numeric_covariates = `c("Age","WoleBlood_oldTime","Plasma_HoldTime_h")`。

## 2. 逐项状态表

| Item | Status | Evidence pointer | Note |
|---|---|---|---|
| processing time（处理时长） | **NOT_RECORDED** | `dose_defined_metadata.csv` 表头无此字段；`STUDY_DESIGN_AUDIT.md:20` "Exact processing delay, centrifugation, freeze-thaw and transport metadata are unavailable" | 无任何处理时长记录 |
| time to centrifugation（离心前时间） | **NOT_RECORDED** | 同上 `:20`；表头无字段 | `STUDY_DESIGN_AUDIT.md:241` 列为"draw-to-spin delay… requires records beyond current matrices" |
| freeze-thaw cycles（冻融次数） | **NOT_RECORDED** | 表头无字段；既有 review §3.3 "Freeze-thaw: not reported as controlled" | 无记录 |
| storage duration（储存时长） | **NOT_RECORDED** | 表头无字段；既有 review §3.3 "Storage time/temperature: not reported" | `WoleBlood_oldTime` 仅"全血放置"（见下），非储存时长 |
| storage temperature（储存温度） | **NOT_RECORDED** | 表头无字段 | 无记录 |
| MS batch（MS 批次） | **RECORDED_BUT_NOT_MODELED（主模型）** | `MS_batch_proxy` 列存在（`dose_defined_metadata.csv`）；主模型 `07_limma_dose_analysis.R:603` = `~0+dose+environment` **未含批次**；批次仅敏感性 `:623,894` `SENS_add_MS_batch_proxy` | 已记录但主分析未调整；仅敏感性纳入 |
| injection order（进样顺序） | **NOT_RECORDED** | `进样时间` 仅到日期级（=批次代理），无日内 run order | 全库 grep 无 run/injection order 记录 |
| run order（运行顺序） | **NOT_RECORDED** | 同上；`进样时间_summary.csv` 按日期聚合，无顺序号 | 无孔板/位置信息 |
| acquisition date（采集日期） | **RECORDED（=MS_batch_proxy）** | `进样时间` 列（如 `20250913`）；`MS_batch_proxy` 与之同源 | 日期级，等同批次；进敏感性模型 |
| sample prep batch（样本前处理批） | **NOT_RECORDED** | 表头无独立 prep-batch 字段；唯一批次变量即 MS_batch_proxy | 前处理批与采集批未区分 |

## 3. 已记录的前分析协变量（Tube_Mixing / WoleBlood_oldTime / Plasma_HoldTime_h）

来源：`descriptive/covariate_QC/exposure_covariate_balance.csv`。三者均 **RECORDED_BUT_NOT_MODELED**（主模型不含；`06_covariate_QC.R:1` 明示"Does not select limma covariates"）。

| 变量 | Control | Short(Low) | Long(High) | 备注 |
|---|---|---|---|---|
| Tube_Mixing=Insufficient | 7/153 = 4.6% | 14/186 = 7.5% | 23/176 = 13.1% | **随暴露级单调上升**（L59-67） |
| Tube_Mixing=Unknown | ~49.7% | ~52.2% | ~52.3% | 约半数缺失 |
| WoleBlood_oldTime=Unknown | 104/153 = 68.0% | 134/186 = 72.0% | 121/176 = 68.8% | 约 7 成未知（L74-82） |
| Plasma_HoldTime_h=Unknown | 125/153 = 81.7% | 149/186 = 80.1% | 147/176 = 83.5% | 约 8 成未知；仅 4h vs Unknown（L83-88） |

## 4. 汇总

- **已建模（主分析）**：仅 `Environment(condition)`（主模型 `~dose+environment`）。Age/Sex/Collection_time/Region = absent。
- **记录但未建模（主模型）**：`MS_batch_proxy / 进样时间`（仅敏感性纳入）、`Tube_Mixing`、`WoleBlood_oldTime`、`Plasma_HoldTime_h`。
- **未记录**：processing time、time to centrifugation、freeze-thaw cycles、storage duration、storage temperature、injection order、run order、sample prep batch。
- **风险提示**：Tube_Mixing=Insufficient 随暴露级 4.6%→7.5%→13.1% 单调上升，是与暴露同向的前分析梯度；前分析变量约 80% 未知，无法作协变量调整。对应"批效应/前分析被误读为生物效应"风险。
