# Claim C05 分母对账（1,445 vs 1,430）— 2026-10-01

> 目的：消除 `STATISTICAL_CLAIM_MAP.csv` C05 把"85 Discovery DEP 锁定"的分母误标为 1,430 的口径错误。
> 两个数字都是真实 frozen 值，但属于**不同分析宇宙**，不可互换。本文逐字引用结果/manifest 原文。

## 字段表

| 字段 | 内容 |
|---|---|
| **Claim** | C05 — Discovery High-vs-Low DEP 锁定（85 DEPs, BH-FDR<0.05） |
| **Current_denominator（claim map 现状）** | N = **1,430**，Multiplicity_family = "A–E"，Evidence_source = "M03/M05 D03" |
| **Correct_denominator** | N = **1,445**（Discovery-eligible protein universe）；BH 族 = Discovery Long-vs-Short（High vs Low）across 1,445 |
| **Meaning** | 85 是在 **D01 资格化后的 Discovery 蛋白宇宙（1,445）** 上做 Long(High)-vs-Short(Low) limma、BH-FDR<0.05 锁定的。1,445 是 Discovery-only、70% 检出阈值过滤后的可入蛋白数。**1,430 是 Q515 全分析队列（515 人）丰度模型所用的 tested universe**，用于 M05–M11/M10 全队列对比，与"85 的 BH 族"无关。把 C05 写成 1,430 = 用错了宇宙。 |
| **Evidence_source（正确出处）** | D01 eligibility manifest（1,445）；D03 candidate-lock manifest（85 锁定、其宇宙指针指向 D01 eligible）；M07/M10 manifest（1,430 的真实归属） |
| **Evidence_pointer** | ① `descriptive/discovery_validation/D01_discovery_eligibility/D01_manifest.txt` L22 `raw_protein_count=3817`、L23 `eligible_protein_count=1445`、L13 `script_path=…/D01_discovery_eligibility.py`；同目录 `D01_integrity_assertions.csv` A23。<br>② `descriptive/discovery_validation/D03_candidate_lock/D03_candidate_lock_manifest.csv`：`candidate_count=85`，`rule="Discovery Long vs Short BH-FDR<0.05"`，`D01_universe_sha256` 指向 `D01_discovery_eligible_proteins.csv`（即 1,445 宇宙）。<br>③ `descriptive/analysis_v2.0/M07_pairwise_contrasts/M07_manifest.csv`：`universe="Q515"`、`n_proteins="1430"`、`n_samples="515"`；`M10_environment_interaction/corrected_pure_interaction/M10_corrected_manifest.csv` 同 n_proteins=1,430。 |

## 三宇宙不可混（备忘）

| 宇宙数字 | 含义 | 出处 |
|---|---|---|
| **1,445** | Discovery-eligible（D01 资格宇宙；85 的 BH 族） | D01_manifest L23 |
| **1,430** | Q515 全队列丰度模型 tested universe（M05–M10） | M07_manifest n_proteins |
| 1,434 | 通路 tested protein groups（M12 mapping） | M12_gene_mapping_summary |
| 1,414 | 通路单基因无歧义背景 | M12_gene_mapping_summary |

## 动作

- `STATISTICAL_CLAIM_MAP.csv` C05：N 由 1430 改为 **1445**；Multiplicity_family 由 "A–E" 改为 **Discovery Long-vs-Short (BH across 1,445 eligible)**；Evidence_source 由 "M03/M05 D03" 改为 **D01 eligibility + D03 lock**；Evidence 指针指向上述 ①②。
- C05 允许措辞（"85 discovery DEPs locked in D03"）**不变**。
- 1,430 仍正确归属 M07/M10 全队列丰度对比（Main R2/R5 null），不得删除，仅不得用于 C05。
