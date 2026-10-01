# 站点 × 进样/批次混杂静态审计（P15）

> 视角：site/environment 与 acquisition-era/batch 的可分离性静态审计。
> 方式：只读 metadata / 结果表 / 代码；未运行脚本。
> 权威总状态：FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED；ANALYSIS_REOPEN_REQUIRED=YES。
> 允许结论："site/environment and acquisition-era effects cannot be fully separated."
> 禁止结论："the 85 DEPs are caused by batch."

## 1. Observed metadata fact（逐条，文件 + 位置）

### 1.1 站点 → 采集日（MS_batch_proxy）一对一

| 站点 group | 采集日 MS_batch_proxy（占比） | 样本数 | 证据指针 |
|---|---|---:|---|
| FJ_FQ | 20250914(45) + 20251001(23) + 20251104(2) | 70 | `descriptive/group_by_MS_batch_proxy_counts.csv` |
| FJ_PT | 20250914(25) + 20251026(1) | 26 | 同上 |
| FJ_QZ | 20250913(50) + 20251026(11) | 61 | 同上 |
| **GZ_TH** | **20260717(123) — 单一采集日** | **123** | 同上；M11 剂量拆分 46/31/46=`descriptive/analysis_v2.0/M11_site_robustness/M11_site_composition.csv` |
| **XZ_GG** | **20260527(143) — 单一采集日** | **143**（其中 dose 已知 142） | 同上；M11 剂量拆分 30/66/46 |
| XZ_YA | 20251001(22) | 22 | 同上 |
| XZ_YB | 20251001(12) | 12 | 同上 |
| XZ_YC | 20251001(34) | 34 | 同上 |
| XZ_YD | 20251001(27) + 20251107(1) | 28 | 同上 |

- **XZ_GG ≈ 20260527**：由 `group_by_MS_batch_proxy_counts.csv`（XZ_GG 行：20260527=143，其余列=0）与 `design_confounding_tables.xlsx` 工作表 `group_by_batch`（XZ_GG 列仅 20260527=142）直接支持。✅ metadata 直接支持。
- **GZ_TH ≈ 20260717**：由 `group_by_MS_batch_proxy_counts.csv`（GZ_TH 行：20260717=123，其余=0）与 `design_confounding_tables.xlsx` `group_by_batch`（GZ_TH 列仅 20260717=123）直接支持。✅ metadata 直接支持。
- **样本数口径说明**：M11_site_composition.csv 实测 GZ_TH = Control 46 / Low 31 / High 46 = **123**；XZ_GG = 30/66/46 = **142**（另 1 例 unknown dose，故按样本计 143）。上一轮审稿报告 `audit_output/02_reviewer/reviewer_R2.md:25` 概述写"GZ_TH 129 人"为**指针精度小出入**，实际表内合计 123；XZ_GG=142 与该报告一致。

### 1.2 采集日 × 环境（湿热 / 高海拔）近乎别名

| MS_batch_proxy | 高海拔 | 湿热 | 证据指针 |
|---|---:|---:|---|
| 20250913 | 0 | 50 | `design_confounding_tables.xlsx` `batch_by_condition` |
| 20250914 | 0 | 69 | 同上 |
| 20251001 | 93 | 23 | 同上（唯一跨环境批：FJ_FQ 23 + 4 个西藏小站 70） |
| 20251026 | 0 | 12 | 同上 |
| 20251104 | 0 | 2 | 同上 |
| 20251107 | 1 | 0 | 同上 |
| 20260527 | 142 | 0 | 同上（= XZ_GG） |
| 20260717 | 0 | 123 | 同上（= GZ_TH） |

- **8 个采集日中 6 个为单一环境纯批**；唯二跨环境批为 20251001（93 高海拔 / 23 湿热）与 20251107（1/0）。
- 环境分层：湿热=280、高海拔=239（`进样时间_summary.csv`；condition 总 279/236 与该 280/239 的差为 unknown dose 样本）。

### 1.3 采集日 × 检出深度/缺失率（时代梯度）

| 采集日 | 样本 | 检出蛋白中位数 | missing_pct | 证据指针 |
|---|---:|---:|---:|---|
| 20250913 | 50 | 2136.5 | 43.4% | `descriptive/进样时间_summary.csv` |
| 20250914 | 70 | 2229.0 | 40.7% | 同上 |
| 20251001 | 118 | 2258.0 | 39.2% | 同上 |
| 20251026 | 12 | 2125.0 | 45.6% | 同上 |
| 20251104 | 2 | 2757.5 | 27.8% | 同上 |
| 20251107 | 1 | 3463.0 | 9.3% | 同上 |
| 20260527 | 143 | 1890.0 | 48.3% | 同上 |
| 20260717 | 123 | 1836.0 | 50.3% | 同上 |

- 2025 批检出中位 ~2100–2250、缺失 ~39%–46%；2026 两批（XZ_GG + GZ_TH）检出中位 ~1836–1890、缺失 ~48%–50%。**采集时代与检出深度/缺失率系统相关**。

### 1.4 主分析模型是否纳入批次

- 主模型公式：`descriptive/07_limma_dose_analysis.R:603` = `~ 0 + dose + environment`（**未含批次**）。
- 批次调整模型：同文件 `:623` = `~ 0 + dose + environment + MS_batch_proxy`，输出命名 `SENS_add_MS_batch_proxy`、目录 `03_SENS_MS_batch_proxy`（`:894-895`）——**仅敏感性分析**。
- `STUDY_DESIGN_AUDIT.md:413`：Covariates = Environment only。
- 即：MS_batch_proxy **已记录但主模型未纳入**，仅作敏感性。

## 2. Design implication（设计含义）

1. 站点嵌套于环境（湿热=4 个福建/广东站，高海拔=5 个西藏站）；两个最大站点 GZ_TH（123）与 XZ_GG（143/142）**各自等于单一采集日**，站点主效应与采集日效应在这两个站上**完全对齐**，无法分解。
2. 环境（湿热 vs 高海拔）与采集时代（2025 Fujian 批 vs 2026 Tibet/Guangzhou 批）近乎别名（6/8 纯批）；"High land vs Hot-humid" 的对比同时携带地理/人群与技术时代两层差异。
3. 剂量对比（Long vs Short）在大批次内有重叠（20250914=10/24/35、20251001=34/45/37、20260527=30/66/46、20260717=46/31/46），故剂量效应在含批次协变量时可估；但剂量估计仍部分落在 2026 两批（低检出、高缺失）上。
4. 既有文档已自陈：`STUDY_DESIGN_AUDIT.md:39` "Two large sites align with individual acquisition dates… neither a rich model nor leave-one-site-out analysis can identify geographic biology separately from perfectly aligned processing factors."；`:324` 点名 GZ_TH-20260717 / XZ_GG-20260527。

## 3. Statistical limitation（统计局限）

- **可成立结论**：site/environment 与 acquisition-era 效应在现有 metadata 下**无法完全分离**；环境轴只能作描述性/稳健性，不得作干净环境主效应；主模型未纳入批次，批次仅敏感性。
- **不可成立结论（禁止）**：不得写"the 85 DEPs are caused by batch"——批调整仅为敏感性、且两大门站点与环境对齐使批与环境不可分割；现有证据只支持"测量有效性受站点-采集耦合限制"，不支持把 85 个 DEP 归因为批次伪影。
- LOO 站点剔除（D07）为 influence/robustness，不能证明站点间效应同质，也不能把站点/采集日效应与生物学分离。
