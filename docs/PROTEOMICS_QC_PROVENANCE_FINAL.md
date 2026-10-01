# Proteomics QC Provenance 定稿（P8/P9，Phase 7）

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。
> 方式：纯静态只读检索；不用互联网、不运行分析、不改任何数据、不 commit。
> 承接：Round 2 `PROTEOMICS_IDENTIFICATION_QC_AUDIT.md`、Phase 6 `WORDING_AND_QC_AUDIT.md`。
> **PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP 维持 ACTIVE。**

## 1. P8 检索范围与命中摘要

### 1.1 检索对象
全仓库（含 `rawdata/`、归档文档、methods 笔记、metadata、列名）静态搜：`contaminant / cRAP / CON__ / decoy / reverse / REV__ / target-decoy / q-value / protein FDR / precursor FDR / peptide FDR / PSM FDR / library FDR / DIA-NN / Spectronaut / MaxQuant`。排除 `pre_repair_snapshot/`。

### 1.2 本轮新发现（raw 文件列名）
- `rawdata/rawdata.xlsx`（46 MB）表头逐字：`PG.ProteinGroups, PG.Genes, PG.ProteinDescriptions, PG.ProteinNames, PG.CV, PG.Qvalue, PG.MolecularWeight, [1] 20250913_astral_zoom_60spd_23min_200ngQWJ_ZWJ_Q3_R1.raw.PG.Quantity, …`。
  - 由此可静态确认：**仪器 = Orbitrap Astral Zoom**；LC 方法 ≈ 23 min、60 spd；上样 200 ng；操作人首字母 QWJ/ZWJ；原始文件 `.raw`（Thermo）；**导出字段 = Spectronaut `.PG.Quantity`**（protein-group 级）。
  - 文件名带 `_R1` → 存在 technical-replicate 编号约定，但仓库内只见 R1 列，无 R2 复核列进入分析。
- `rawdata/processed.xlsx`（14 MB）两 sheet（Sheet1/Sheet3）：7 注释字段 + 清洗后样本列（`20250913_Q3` 等）。
- `rawdata/` 另有 `G1.xlsx/G2.xlsx/G3.xlsx/G4.xlsx`（各 14–17 KB，小映射表，非搜库导出）与三份 sample_mapping。

### 1.3 关键否定命中
- **FASTA / 搜库工程文件**：全仓库递归搜 `*.fasta/*.fa/*.faa/*.diann/*.report/*.mqpar.xml/*report*.tsv/*.speclib` → **0 文件**。无 DIA-NN / MaxQuant / Spectronaut 工程配置。
- **鉴定 FDR 阈值**：全库 `.md` 中所有 "FDR" 命中均为**差异表达 BH-FDR**（85/1,445、0/1,430、复制族 BH），**无任何 PSM/peptide/protein identification FDR 阈值（如 1%）或 q-value 过滤记录**。
- `docs/protocol/ANALYSIS_PLAN_v2.0.md:169`：明示 "no identified Spectronaut project, exported search/normalization configuration or FASTA… Recover exact Spectronaut version, local/global/cross-run normalization state… identification q-value settings and search/library scope."
- `docs/archive/legacy_framework_v2.0/README_*.md:205/249/315`："The original Spectronaut cross-run normalization setting cannot [be recovered]."

## 2. P9 五类最终状态表

| # | 类别 | 状态 | 层级 | 关键证据指针 |
|---|---|---|---|---|
| 1 | Contaminant exclusion | **PARTIALLY_VERIFIED（仅 policy-only，执行=NO）** | policy-only | cRAP 2012.01.01 政策纸面冻结，投影排除 8 角蛋白组（KRT1/2/9/10/31/36/38/84）；但 `registry/FREEZE3_CANDIDATE_REVIEW.md:122-125` "No protein was actually excluded"；frozen 1,434 宇宙直接来自 U0=3,817 检出阈值（`dose_quantitative_filtering_report.md:55`） |
| 2 | Decoy exclusion | **UNRESOLVED** | search-engine/export 层未知 | 导出 7 字段无 `PG.Decoy/Reverse/Contaminant`（`DATA_SOURCE_AUDIT:31-38`）；仓库无 FASTA；cRAP 只管物理污染物、不管反库；无 target-decoy 策略记录 |
| 3 | Protein FDR（鉴定） | **UNRESOLVED** | export 层字段在但口径未建 | 有 `PG.Qvalue` 列（Spectronaut 蛋白组 q 值），但定义/聚合方式未建立、未据此设阈值过滤（`STUDY_DESIGN_AUDIT.md:249`）；无 identification FDR 过滤证据 |
| 4 | Peptide FDR | **NOT_AVAILABLE** | export 层无 peptide 表 | 导出不提供 peptide counts / precursor counts / unique-peptide（`STUDY_DESIGN_AUDIT.md:249`）；Unique-peptide 轴已从 v2.1 scope 移除（`ANALYSIS_PLAN_v2.1.md:§4`） |
| 5 | PSM/precursor FDR | **NOT_AVAILABLE** | export 层无 PSM 表 | 无 PSM/PEP/precursor 级导出；无 1% PSM FDR 记录 |

### 层级分解
- **search-engine 层**：Spectronaut 由 `.PG.Quantity` 命名约定静态确认；但版本、搜库数据库/物种、decoy 策略、鉴定 FDR 阈值、cross-run 归一化状态**均不可恢复** → unknown。
- **export 层**：仅 protein-group PG 级（Quantity/MS1Quantity/MS2Quantity/IBAQ），7 注释字段，无 contaminant/decoy/reverse 标记。
- **project preprocessing 层**：3,817 → 1,434（每剂量组 ≥70% 检出），**无任何技术排除步骤**。
- **policy-only 层**：cRAP 2012.01.01（8 角蛋白），定义但未执行。

## 3. PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP（定稿表述，扩展版）

> **PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP = ACTIVE.**
>
> The matrix is a **protein-group-level Spectronaut DIA export** (Orbitrap Astral Zoom; 23-min gradient; 200 ng load; Thermo `.raw`; field `PG.Quantity`), comprising 3,817 protein groups with only seven annotation columns (`PG.ProteinGroups, PG.Genes, PG.ProteinDescriptions, PG.ProteinNames, PG.CV, PG.Qvalue, PG.MolecularWeight`). The repository retains **no search-engine project, no source FASTA, no decoy/reverse or contaminant flag, and no PSM- or peptide-level table**; consequently the search database, species, target-decoy strategy, and PSM/peptide/protein identification-FDR thresholds cannot be verified. A `PG.Qvalue` column exists but its definition, aggregation, and any filtering threshold are not established. A cRAP 2012.01.01 contaminant policy was drafted and paper-frozen (projecting exclusion of 8 skin/hair keratin groups) but **no protein was actually excluded**; the frozen 1,434-protein quantitative universe derives directly from the 3,817 export by a per-group detection threshold. Therefore the protein-group identification FDR, the residual technical-contaminant load, and the upstream Spectronaut normalization state in the 1,434 / 1,445 / 85 universes **cannot be confirmed from the recorded materials**. This must be reported as a Methods provenance gap / Limitation; it must not be inferred from software defaults, and it is not closed by the downstream differential-abundance BH-FDR.

## 4. 转 manuscript limitation / Methods 的固定表述

Methods（建议，不写正文）：
- 搜库：DIA on Orbitrap Astral Zoom, processed with Spectronaut (`PG.Quantity`); **search database, decoy strategy, and identification-FDR thresholds are not recoverable from the retained export and are reported as an open provenance gap.**
- Contaminant：a fixed cRAP 2012.01.01 list was used to annotate 8 skin/hair keratin groups; **no contaminant was removed from the analyzed universe**; endogenous high-abundance plasma (Category B) and preanalytical/cellular (Category C) proteins were retained per protocol.

Limitations（固定句）：
> "Identification-level QC records (PSM/peptide FDR, target-decoy settings, contaminant registry execution, and upstream Spectronaut normalization) are incomplete in the retained export; the protein-group identification FDR and residual technical-contaminant load could not be verified. We treat this as a provenance limitation rather than as evidence of absence of contamination."
