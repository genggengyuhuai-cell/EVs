# Wording & 鉴定 QC 审计（P19 / P20 / P21，Phase 6）

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。
> 方式：只读分析 + 措辞层确定性核对；**未运行任何分析/R 脚本，未 commit/tag，未改图**。
> 权威总状态：FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED；ANALYSIS_REOPEN_REQUIRED=YES；SAFE_TO_TAG_ANALYSIS_V2_1=NO。
> 检索排除：`pre_repair_snapshot/`、`archive/`、`audit_output/` 历史产物（仅作对照）。

---

## 第一节 P19 — EV 措辞审计

### 1.1 审计范围
全项目活文档（`PROJECT_CONTEXT.md`、`docs/`、`manuscript_v2_1/audit/`）搜 `EV-enriched / pure EV / EV-specific / EV proteome / extracellular vesicle / exosome / EV cargo / EV biology / EV-derived / magnetic-bead / co-isolation`。正确主表述 = **EV-enriched plasma proteomics**；limitation 必须保留 no EV-purity validation + possible co-isolation of abundant plasma/platelet/RBC/coagulation proteins。

### 1.2 命中清单与分类

| 文件:行 | 内容摘要 | 分类 |
|---|---|---|
| `PROJECT_CONTEXT.md:30-31` | "environmental-exposure **EV-enriched** plasma proteomics study… (NOT pure EV proteome; co-isolated plasma proteins… acknowledged limitations)" | **正确表述（权威）** |
| `manuscript_v2_1/audit/EXPERIMENTAL_DESIGN_REVIEW.md:55-91` | "**EV-enriched** plasma proteome — magnetic-bead (Mag-Net) enriched… not demonstrably pure EV proteome"；禁用 pure EV proteome / endosomal EV cargo / EV-specific biology；要求承认 abundant plasma/platelet/RBC/coagulation 共分离 | **正确表述（安全措辞金标准）** |
| `manuscript_v2_1/audit/WHOLE_PROJECT_SCIENTIFIC_REVIEW.md:26,55,70` | "genuinely EV-derived (no EV purification validation)"；"EV-specific interpretation not supported beyond enrichment label"；reviewer 会 push back on EV-enriched vs EV-pure | **正确表述** |
| `manuscript_v2_1/audit/PROJECT_RECONSTRUCTION_PLAN.md:7,11,122` | Framing "Exposure-associated **EV-enriched** plasma proteomic architecture"；禁用 "EV proteins / EV biology / EV-specific" | **正确表述** |
| `docs/CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md:79-81` | 确认 "pure EV proteome" 为 banned phrase，已从当前 control doc 移除 | **正确表述** |
| `docs/protocol/STUDY_DESIGN_AUDIT.md:18` | "Material and unit… Plasma, **not EV-enriched plasma**… Other preparation details are unavailable" | **STALE（相对 v2.1 身份）**；但该文件自标 "DOCUMENTATION UPDATE ONLY"（frozen documentation） |
| `docs/protocol/ANALYSIS_PLAN_v2.0.md:15` | "Material / unit | **Plasma, not EV-enriched**; 515 samples…" | **STALE（相对 v2.1 身份）**；但该文件自标 "PROTOCOL FROZEN AS DOCUMENTATION" |

### 1.3 修复记录
- **本轮未对任何活文档做改写**。两处 STALE 命中（STUDY_DESIGN_AUDIT:18、ANALYSIS_PLAN_v2.0:15）均位于**自标 FROZEN 的协议文档**内，按全局"禁止修改任何 frozen 文件"边界，**不直接改写、保留历史作者确认记录**；其与 PROJECT_CONTEXT v2.1（EV-enriched）的口径冲突登记为**状态管线交叉项**（见第 4 节），由状态管线统一裁定是加注"superseded by PROJECT_CONTEXT v2.1"还是勘误。
- `PROJECT_CONTEXT.md` 本身无需改（口径正确），按任务要求只登记不改。
- 无备份产生（零改写）。

### 1.4 给稿件 Methods 的 TODO（EV 节）
1. 材料句统一为："**EV-enriched** plasma proteomic profiling of plasma, obtained by magnetic-bead enrichment."（沿用 EXPERIMENTAL_DESIGN_REVIEW:57 金标准）。
2. Limitation 必写：no EV-purity validation；no EV-marker / proteolipid / NTA / cryoEM；possible co-isolation of abundant plasma / platelet / RBC / coagulation proteins。
3. 禁用：pure EV proteome / endosomal-EV cargo / EV-specific biology / cell-of-origin release / "these are EV proteins" / "EV biology explains the signal"。

---

## 第二节 P20 — site/acquisition confounding 措辞审计

### 2.1 审计范围
搜 `batch-adjusted completely / site-independent / environment-only effect / confounding removed / deconfounded / after batch correction / batch effect removed / independently of site / balanced across batch`，并核对 M11/LOO 是否被用来声称消除混杂。

### 2.2 命中清单与分类
- 过度主张检索：**0 命中**。仓库中无 "batch-adjusted completely / site-independent / deconfounded / confounding removed" 类表述。
- 安全措辞**已存在且维持**：
  - `docs/protocol/ANALYSIS_PLAN_v2.0.md:410`："GZ_TH aligns with acquisition date 20260717 and XZ_GG with 20260527 in verified metadata; **Site and acquisition contributions cannot be separated where aligned. LOO direction stability does not prove no heterogeneity**; loss of P<0.05 after deletion is not by itself evidence of instability."
  - `docs/SITE_ACQUISITION_CONFOUNDING_AUDIT.md:76`："site/environment 与 acquisition-era 效应在现有 metadata 下**无法完全分离**"。
- M11 角色：M11 = leave-one-site-out sensitivity/influence（`STUDY_DESIGN_AUDIT.md:324`；P15 报告），全库无"M11 消除混杂"或"LOO proves no site effect"表述。✅ M11 未被误用为 confounding 消除证据。

### 2.3 修复记录
- 无需修复（0 过度主张；安全措辞已在位）。零改写。

### 2.4 给稿件 Methods 的 TODO（混杂节）
1. 保留句："Under the recorded design, site/environment and acquisition-era effects cannot be fully separated; two largest sites (GZ_TH, XZ_GG) each align with a single acquisition date."
2. 主模型写明 `~ dose + environment`，未含采集批次；批次仅敏感性（SENS_add_MS_batch_proxy）。
3. LOO 仅作 influence/robustness，不得表述为 confounding control 或 site-independent replication。

---

## 第三节 P21 — proteomics QC provenance

### 3.1 审计范围
复核 contaminant / decoy / PSM-peptide FDR 的执行证据（承接 Round 2 `PROTEOMICS_IDENTIFICATION_QC_AUDIT.md`），无新证据不猜、不捏造。

### 3.2 判定（与 Round 2 一致，无新证据改判）
| 项 | 判定 | 关键证据指针 |
|---|---|---|
| Contaminant exclusion（执行证据） | **NO** | cRAP 2012.01.01 政策纸面冻结（8 角蛋白组），但 `registry/FREEZE3_CANDIDATE_REVIEW.md:122-125` "No protein was actually excluded"；frozen 1,434 宇宙直接来自 U0=3,817 检出阈值（`dose_quantitative_filtering_report.md:55`） |
| Decoy exclusion | **UNRESOLVED** | 导出 7 注释字段无 decoy/reverse 列（`DATA_SOURCE_AUDIT:31-38`）；仓库无 FASTA；`PG.Qvalue` 定义/阈值未建立、未据此过滤 |
| PSM / peptide FDR export | **UNAVAILABLE** | `STUDY_DESIGN_AUDIT.md:249`：导出不提供 peptide/precursor 计数、unique-peptide 证据；Unique-peptide 已从 v2.1 scope 移除 |

### 3.3 PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP（定稿表述）

> **PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP = ACTIVE.**
> The exported proteomic matrix provides 3,817 protein groups with seven annotation fields (`PG.ProteinGroups, PG.Genes, PG.ProteinDescriptions, PG.ProteinNames, PG.CV, PG.Qvalue, PG.MolecularWeight`) and **no explicit contaminant, decoy, or reverse-search flag**; no source FASTA or search configuration is retained in the repository. A cRAP 2012.01.01 contaminant policy was drafted and paper-frozen (projecting exclusion of 8 skin/hair keratin groups), but **no protein was actually excluded** and the frozen 1,434-protein quantitative universe derives directly from the 3,817 export by a per-group detection threshold. `PG.Qvalue`'s definition and aggregation are not established, no identification-FDR threshold was applied, and PSM- or peptide-level exports (peptide/precursor counts, unique-peptide evidence) are absent. Consequently the protein-group identification FDR and residual technical-contaminant load in the 1,434 / 1,445 / 85 universes cannot be verified from the recorded materials. This gap must be closed by a Methods report, not inferred from software defaults.

### 3.4 修复记录
- 无新执行证据；不猜、不捏造。零改写 frozen 结果。

### 3.5 给稿件 Methods 的 TODO（鉴定 QC 节；不写稿件正文，仅建议清单）
1. 搜库引擎/版本、数据库与物种、decoy/target-decoy 策略、PSM/peptide/protein 鉴定 FDR 阈值。
2. `PG.Qvalue` 与 `PG.CV` 的计算口径（计算总体、聚合方式、是否据此设过滤）。
3. Contaminant 注册表：cRAP 版本、精确 accession 匹配数、移除数（8 角蛋白组是否真正落入宇宙）、保留数；Category B/C 共分离蛋白按协议保留并标注。
4. 若上述搜库配置确不可得 → Limitations 明示"identification-QC records incomplete"，**不得**在图注/正文暗示已完成标准 contaminant/decoy 去除。
5. 声明 Unique-peptide / PSM 证据不在本数据集（v2.1 已移除该轴）。

---

## 第 4 节 — 交叉项清单（需状态管线或主图管线处理）

| # | 交叉项 | 归属管线 | 说明 |
|---|---|---|---|
| X1 | 两处 FROZEN 协议文档 EV 口径冲突（`STUDY_DESIGN_AUDIT.md:18`、`ANALYSIS_PLAN_v2.0.md:15` 作 "Plasma, not EV-enriched" vs PROJECT_CONTEXT v2.1 "EV-enriched"） | **状态管线** | 文件 frozen，本轮不改；需统一裁定加注 "superseded by PROJECT_CONTEXT v2.1" 或勘误 |
| X2 | PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP = ACTIVE | **状态管线 + 稿件 Methods** | 需在 Methods 报告或 Limitations 显式披露；不解除则 SUBMISSION_READINESS 维持 BLOCKED |
| X3 | fgsea canonical FDR 家族裁定（padj vs padj_pooled） | 状态管线（Phase 5 遗留） | 解除 HOLD 后更新 Fig6b |
| X4 | R03 inferential universe 切 1,445（已声明延期） | 状态管线 | M12 不标 FINAL_FROZEN 直至决定 |
| X5 | Fig6 重建（a/c/d 可先，b 挂起） | **主图管线** | Phase 5 遗留；本轮未改图 |
| X6 | M09 / M11 REPAIR_PENDING、strict nested REPAIR_PENDING | 各修复管线 | 全局 BLOCKED 解除条件之一 |
