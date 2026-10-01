# 前分析限制冻结（P10，Phase 7）

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。
> 方式：纯静态只读；承接 Round 2 `PREANALYTICAL_METADATA_AUDIT.md`、`SITE_ACQUISITION_CONFOUNDING_AUDIT.md`、Phase 6 `WORDING_AND_QC_AUDIT.md`。
> 用途：固定投稿时前分析/技术变量的表述边界。**禁止** "batch fully controlled / processing effects excluded" 类表述。

## 1. 逐项冻结状态

| Item | 冻结状态 | 证据指针 |
|---|---|---|
| processing time（处理时长） | **NOT_RECORDED** | `dose_defined_metadata.csv` 表头无字段；`STUDY_DESIGN_AUDIT.md:20` |
| time to centrifugation（离心前时间） | **NOT_RECORDED** | 同上 `:20`；`STUDY_DESIGN_AUDIT.md:241` |
| freeze-thaw cycles（冻融次数） | **NOT_RECORDED** | 表头无字段 |
| storage duration（储存时长） | **NOT_RECORDED** | 表头无字段 |
| storage temperature（储存温度） | **NOT_RECORDED** | 表头无字段 |
| injection order（进样顺序） | **NOT_RECORDED** | `进样时间` 仅日期级，无日内 run order |
| run order（运行顺序） | **NOT_RECORDED** | 无孔板/位置信息 |
| acquisition date（采集日期） | RECORDED（=批次代理） | `进样时间` 列 |
| MS batch（MS 批次） | **RECORDED_BUT_NOT_MODELED（主模型）** | `MS_batch_proxy` 列存在；主模型 `07_limma_dose_analysis.R:603` = `~0+dose+environment` 未含批次；仅敏感性 `:623,894 SENS_add_MS_batch_proxy` |
| sample prep batch（前处理批） | **NOT_RECORDED** | 无独立 prep-batch 字段 |
| Tube_Mixing / WoleBlood_oldTime / Plasma_HoldTime_h | RECORDED_BUT_NOT_MODELED | `exposure_covariate_balance.csv`；约 80% Unknown；Tube_Mixing=Insufficient 随暴露 4.6%→7.5%→13.1% 单调上升 |

## 2. 固定结论

- **site / acquisition-era 强耦合，无法完全分离**：8 个采集日中 6 个为单一环境纯批；最大两站点 GZ_TH(123)=单一采集日 20260717、XZ_GG(142/143)=单一采集日 20260527（`design_confounding_tables.xlsx` group_by_batch）。
- **主模型未纳入批次**，批次仅敏感性纳入；环境轴只能作描述性/稳健性，不得作干净环境主效应。
- 前分析变量约 80% Unknown，无法作协变量调整；Tube_Mixing 随暴露单调上升。

## 3. 投稿表述边界（固定）

**允许写**：
> "Under the recorded design, site/environment and acquisition-era effects cannot be fully separated; the two largest sites each align with a single acquisition date. Processing time, time-to-centrifugation, freeze-thaw cycles, storage duration/temperature, injection order, and sample-prep batch were not recorded; the MS batch proxy was retained as a sensitivity covariate rather than in the primary model. We report exposure-associated protein signatures and treat site/acquisition and preanalytical variation as acknowledged confounders."

**禁止写**：
- "batch fully controlled / batch-adjusted completely"
- "processing effects excluded / preanalytical confounders ruled out"
- "environment-only effect" / "site-independent"
- "balanced across batch" / "randomized across batches"（本研究为观察性，无随机化）
- 把 LOO/M11 表述为 confounding control 或消除采集时代效应

## 4. 状态
FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED。本冻结文档仅固定表述边界，不解除上述 GAP。
