# PHASE 7 主报告 — Provenance Closure + Git Freeze Preparation

- 日期：2026-10-01
- 范围：`F:\env`（Windows / PowerShell 5.1 / R 4.3.1）
- 性质：纯静态审计 + 确定性 provenance guard 修复 + 一次 Fig6b 仅标签重导出；**未运行任何分析管线、未重跑 D01–D03/D08/ML/strict nested/M09/M11/M12/M12B、未 commit/push/tag、未联网**
- 上游：Phase 6（PHASE6_DOWNSTREAM_REBUILD_PASS）→ 本轮 Phase 7

---

## 1. 总判定

| 判定 | 值 |
|---|---|
| **SAFE_TO_TAG** | **YES（qualified）→ `TAG_WITH_PROVENANCE_LIMITATION`** |
| SUBMISSION_READINESS | BLOCKED → `SUBMISSION_METHODS_GAP`（Methods 补全 + 表格重建 + R03 决策 + Commit1–5 未执行） |
| OPEN_ANALYSIS | **0** |
| fgsea 报告状态 | **FROZEN_AS_DUAL_REPORTED_SENSITIVITY** |
| M12 状态 | REPAIRED_RERUN_COMPLETE（fgsea FDR hold 与 Fig6 caption hold 均已解除；**不标 FINAL_FROZEN**，剩余 R03 团队裁定已登记延期） |
| 本轮是否 commit | **否**（P24，即使 SAFE_TO_TAG=YES 也只输出 commit plan） |

核心逻辑：科学核心（fixed-85 ML / strict nested / M09 / M11 / M12 / M12B）全部 RERUN_VERIFIED、OPEN_ANALYSIS=0、输入身份与 split 已冻结、canonical 输出 29/29 存在、Fig1–6 与 supplement 终审通过、claim map 干净、历史输出已隔离。残留项（QC provenance gap、ML Python 环境未定位、93 个根目录垃圾文件、R03 延期、M14/D10 待重建）均为**已如实记录的 limitation / reporting / git 清理项**，不阻断代码与数据 tag，但阻断投稿提交。

---

## 2. 模块权威状态（Phase 7 终态）

| 模块 | 状态 | 依据 |
|---|---|---|
| fixed-85 ML | REPAIRED_AND_VERIFIED | Phase 1–2 修复 + Phase 6/7 复核 |
| strict nested | REPAIRED_AND_VERIFIED | 同上（15 折，7/15 zero-feature 为有效统计结果） |
| M09 | REPAIRED_AND_VERIFIED | Pearson 0.9740605 / Spearman 0.9644384 / 1343-1430 / 双侧 FDR=0 |
| M11 | REPAIRED_AND_VERIFIED | 9-site LOO，公式一致含 Environment 调整 |
| M12 | **REPAIRED_RERUN_COMPLETE**（原 WITH_FGSEA_FDR_HOLD 前缀移除） | fgsea 双列已正式冻结为 sensitivity-only；Fig6 caption 终审 P18 PASS；仅剩 R03 universe 团队裁定（已登记延期，不造假 1445） |
| M12B | REPAIRED_RERUN_COMPLETE | Phase 5 重跑 + 三重一致 |
| D03 | 85 candidates retained | FROZEN_INPUT |
| D08 | 85→83→29→1 retained | FROZEN_INPUT |
| P1/P2/P3 | **PROVENANCE_CLOSED**（本轮） | hash bound + fail-closed 全部 YES |

---

## 3. P26 逐条回答

### 3.1 FGSEA
- **正式冻结**：`FGSEA_REPORTING_STATUS = FROZEN_AS_DUAL_REPORTED_SENSITIVITY`（docs/FGSEA_REPORTING_FREEZE.md 终态）。
- 层级固定：cameraPR=PRIMARY（205 = GO-BP 29 + Reactome 176）、ORA=COMPLEMENTARY（23 = 3 + 20）、fgsea=SENSITIVITY/SUPPORTING ONLY。
- 双列并报：padj_family=44（BP3/MF8/CC11/Reactome22）、padj_pooled=41（6/7/10/18）；主文不以 44 或 41 作 primary discovery claim；不再开放"二选一"裁定（PRIMARY_INFERENCE=NONE 为终态）。
- **M12 reporting hold**：fgsea FDR hold 通过本冻结解除；Fig6 caption hold 通过 P18 终审解除；剩余仅 R03 延期决策（团队裁定项）。

### 3.2 FIG6
- **Fig6b Reactome 可读标签已补齐**：8/8 R-HSA ID 经 reactome.db 1.86.2（PATHID→PATHNAME，AnnotationDbi::select，loadNamespace 隔离避免 select 遮蔽 dplyr）解析，**零 UNRESOLVED**，全部为人工可读通路名（如 ECM proteoglycans、Extracellular matrix organization、Heparan sulfate/heparin (HS-GAG) metabolism、Cellular response to chemical stress 等）。
- **仅标签更新**：FIG6B_LABEL_ONLY_UPDATE=YES；selection rule / FDR / effect / statistic / panel 结构 / 选定通路全部未动；脚本备份 V2_M17_phase6_rebuild.R.phase7.bak。
- 重导出：Fig6_pathway_integration.pdf（51,360 B）/ .svg / _preview.png（300 dpi）+ source_data（新增 readable_name/annotation_source 列）。TIFF 不导出（main figure bundle 为矢量 PDF/SVG + PNG preview，按旗舰 Nature 主图约定）。
- 复核：本报告撰写人独立目检新 PDF + SVG 文本层逐元素核对，8 条标签均两行折行完整渲染、无截断、无裁切（OCR 两处误读已排除）；a/c/d 面板与重导出前一致。

### 3.3 INPUT PROVENANCE
- **processed.xlsx** SHA256 前缀 42ECDA9F52E45B33（14,144,395 B）。
- **P1.py / P2.py**：本轮补 fail-closed SHA256 provenance guard（RuntimeError before write，备份 .phase7.bak）；**P3.py**：Round 2（P18）已有 hash+validation gate。三脚本 **Hash bound=YES / Fail-closed=YES / Canonical output write protected=YES**（docs/P1_P2_P3_PROVENANCE_CLOSURE.md）。
- **split 冻结**：REUSED_FROZEN_SPLIT；SHA256 完整 `062E51026B7420DCA2077D5807BFDAA760AC08AC5F19A9AF98CF89DA2B7B6791`；N=386 Discovery / 129 Validation / 515 total；seed 20260925；六层分层；完整性 26 PASS；hash+membership 锁定后不再改（docs/SPLIT_PROVENANCE_FREEZE.md）。
- PRIMARY_dose_log2_expression.csv.gz SHA256 前缀 65A6CAE19F94A18F（5,931,307 B，1434×515）。完整清单见 docs/INPUT_IDENTITY_MANIFEST.csv。

### 3.4 ENVIRONMENT
- OS：Windows x64；**R 4.3.1**（2023-06-16 ucrt）。
- R 包（已录版本）：limma 3.58.1、fgsea 1.28.0、org.Hs.eg.db 3.18.0、GO.db 3.18.0、reactome.db 1.86.2、clusterProfiler 4.10.1、data.table 1.18.4（及 statmod/glmnet/ranger/xgboost/logistf 等，见 docs/SOFTWARE_ENVIRONMENT_LOCK.md）。
- **Python 3.14.7**（default interpreter，本报告撰写人只读确认 2026-10-01）；**pandas/numpy/openpyxl/xgboost 在默认 python 中不可导入，F:\env 内未发现 venv/python.exe** → ML 运行环境 = **NOT_LOCATED_IN_PROJECT_OR_DEFAULT_PYTHON（TO_CONFIRM）**，已如实标注 UNKNOWN 不猜，列入 commit 前团队确认项。

### 3.5 PROTEOMICS QC（docs/PROTEOMICS_QC_PROVENANCE_FINAL.md）
| 类别 | 终态 | 层级 |
|---|---|---|
| Contaminant exclusion | PARTIALLY_VERIFIED | policy-only（cRAP 2012.01.01 纸面冻结 8 角蛋白，但 "No protein was actually excluded"，frozen 1,434 直接来自 U0=3,817） |
| Decoy exclusion | UNRESOLVED | 无 decoy 标记、无 FASTA |
| Protein FDR（鉴定） | UNRESOLVED | PG.Qvalue 列在但口径/阈值未建、未过滤 |
| Peptide FDR | NOT_AVAILABLE | 无 peptide 级导出 |
| PSM/precursor FDR | NOT_AVAILABLE | 无 PSM/PEP/precursor 导出 |

- 新静态证据：rawdata.xlsx 列名逐字 `*_R1.raw.PG.Quantity` = Spectronaut 蛋白组级导出（Orbitrap Astral Zoom / 60spd / 23min / 200ng / `_R1` 技术重复约定）；全库 **0 个** FASTA / .diann / .report / .mqpar / .speclib。
- **PROTEOMICS_IDENTIFICATION_QC_PROVENANCE_GAP = ACTIVE**，已转 manuscript limitation / Methods provenance gap 固定表述（不得从软件默认推断；下游差异 BH-FDR 不关闭此 GAP）。前分析限制按 docs/PREANALYTICAL_LIMITATIONS_FREEZE.md 冻结（processing time/freeze-thaw/storage/injection/run order=NOT_RECORDED；MS_batch_proxy=RECORDED_BUT_NOT_MODELED；site×acquisition era strongly coupled；禁止 batch fully controlled 类表述）。

### 3.6 GIT
- **最终只读计数（2026-10-01 集成时点）**：`git status --short` 共 **1105 项**（M=844 / ??=224 / D=30 / MM=3 / AM=3 / A=1）；`git diff --check` trailing whitespace **194 行**。
- 工作树分类（docs/GIT_WORKTREE_CLASSIFICATION.csv，基线 1085 项逐条分类，A–H）：A_CANONICAL_CODE=36、B_CANONICAL_RESULTS=97、C_CANONICAL_FIGURES=402、D_CANONICAL_DOCS=58、E_HISTORICAL_SNAPSHOT=354（含 limma_dose_analysis 冻结 v1.0 320）、F_ARCHIVE_DELETE=123、G_EXPLORATORY_POSTFREEZE=2、H_PREEXISTING_UNRELATED=13。
- **重大发现**：仓库根目录存在 **93 个垃圾文件**（文件名形如 `@{pathway=R-HSA-...}`，各 16 B，系某次 PowerShell 将 fgsea 数据行当文件名重定向的意外产物）；另有 30 个已删除的 qa_preview PNG（D 状态）。合计 **123 个文件确认 safe-to-remove**（STALE_ARTIFACT_ACTIONS.csv；仅清单，未执行）。
- **SVG whitespace 策略 = HISTORICAL_EXCLUDE**（docs/GIT_WHITESPACE_POLICY.md）：194 行全部位于 `descriptive/figures_nature_v2.2/*.svg` + `detection_pattern` 同包（历史上游 descriptive/QC 图包），**canonical 冻结批次（figures_final_v2 / supplement_figures）0 白空格**；不修、登记为 known-historical 排除项。
- **历史隔离 = PASS**（docs/HISTORICAL_ISOLATION_AUDIT.md）：claim map / CANONICAL_RERUN_COMMANDS / figure 重建脚本 / source_data 对历史目录 **0 数据依赖**，manifest 中历史包仅 HISTORICAL 声明行。
- 未 commit / push / tag（P24）。

### 3.7 INTEGRITY
- 三 manifest 终态化（ACTIVE_MAINLINE / FINAL_REPRODUCIBILITY / SUPPLEMENTARY，docs 下）：状态词统一 RERUN_VERIFIED / REPORTING_FROZEN / HISTORICAL / SUPPLEMENTARY / PROVENANCE_GAP / BLOCKED；**无 READY_TO_TAG**；ACTIVE_MAINLINE：RERUN_VERIFIED=14、SUPPLEMENTARY=7、HISTORICAL=6、PROVENANCE_GAP=3、BLOCKED=3。
- canonical 输出存在性：**29/29 存在且非零**（D03=85 行、D10=85×67、M09/M11=1430、ML=15 折，docs/CANONICAL_OUTPUT_EXISTENCE_AUDIT.csv）。
- Figure 终审：**6/6 PASS**（docs/FINAL_FIGURE_INTEGRITY_AUDIT.md），含 Fig6b readable names 8/8、KEGG absent、fgsea 不进主图、无旧值（0.931147 / 0.634 / 0.629 / 8–618 / 195 / 39）。
- Supplement 终审：**10/10 PASS**（docs/SUPPLEMENT_FINAL_INTEGRITY.md），SVG 文本层零 stale 统计值。
- Claim map 终审：**30 行 × 17 列零错位**；SAFE=12 / SAFE_WITH_LIMITATION=17 / SUPPLEMENT_ONLY=1；**BLOCKED_BY_REPAIR=0**；C05=1445、C09=1430、C20=205、C22=44/41 dual。
- 权威结果冻结：docs/CURRENT_AUTHORITATIVE_RESULTS.md 标 **FROZEN_20261001**，全文仅 repaired 值。

### 3.8 BLOCKERS（docs/FINAL_BLOCKER_STATUS.md，经集成修正）
- **CLOSED_ANALYSIS**：4 P0 + 5 P1 + fgsea 裁定 = 全部闭合；**OPEN_ANALYSIS=0**。
- **OPEN_REPORTING**：M14 demo 重建（P1-6）、D10 表重建（P1-8）、R03 团队裁定、manuscript 旧数同步（注：Fig3-5/Fig6 重建项已由 P18 终审闭合，从 OPEN_REPORTING 移除）。
- **OPEN_PROVENANCE**：proteomics QC gap（转 Methods limitation）、ML Python 环境定位（TO_CONFIRM）、split generator 再生成可用性（已如实登记 REUSED_FROZEN_SPLIT；P1/P2/P3 身份绑定已关闭，从 OPEN_PROVENANCE 移除）。
- **OPEN_GIT**：1105 项待分批提交（FINAL_COMMIT_PLAN 已建）、tag 执行（本轮禁止）。
- **OPEN_MANUSCRIPT_ONLY**：captions/tables/methods prose、fgsea 与 QC Limitation 措辞落地。

### 3.9 TAG
- **TAG_READINESS_GATE：SAFE_TO_TAG = YES（qualified）→ `TAG_WITH_PROVENANCE_LIMITATION`**；14 项 PASS / 1 项 PARTIAL（software environment：ML Python TO_CONFIRM）/ 4 项 OPEN（93 垃圾文件待 Commit5、M14、D10、R03 决策——均不阻断代码 tag，阻断投稿）。
- 建议 tag：`analysis-v2.1`（Commit4 后，annotated，附 provenance-limitation 注记；备选 `analysis-v2.1.0-repaired`）。
- 建议 commit 顺序（docs/FINAL_COMMIT_PLAN.md，**不执行**）：Commit1 canonical code repairs（A~36）→ Commit2 canonical repaired results（B~97）→ Commit3 main+supplement figures（C~402）→ Commit4 audit/reproducibility/manifests（D~58）→ Commit5 historical+archive cleanup（E+F+G+H~492，含删 93 根目录垃圾文件 + 30 已删预览）。
- `git diff --check` = 194（全部 known-historical，策略 HISTORICAL_EXCLUDE）；`git status --short` = 1105。

---

## 4. 本轮新建/更新产物清单（docs/ 全部落盘，见 §3 各节）

新创建：INPUT_IDENTITY_MANIFEST.csv、P1_P2_P3_PROVENANCE_CLOSURE.md、SPLIT_PROVENANCE_FREEZE.md、SOFTWARE_ENVIRONMENT_LOCK.md、CANONICAL_RERUN_COMMANDS.md（M12_02b_kegg_fix.R=DO_NOT_RUN/HISTORICAL）、PROTEOMICS_QC_PROVENANCE_FINAL.md、PREANALYTICAL_LIMITATIONS_FREEZE.md、FGSEA_REPORTING_FREEZE.md（终态化）、SUPPLEMENT_FINAL_INTEGRITY.md、FINAL_FIGURE_INTEGRITY_AUDIT.md、GIT_WORKTREE_CLASSIFICATION.csv、HISTORICAL_ISOLATION_AUDIT.md、STALE_ARTIFACT_ACTIONS.csv、GIT_WHITESPACE_POLICY.md、CANONICAL_OUTPUT_EXISTENCE_AUDIT.csv、TAG_READINESS_GATE.md、FINAL_COMMIT_PLAN.md。

更新（均 .phase7.bak 备份）：ACTIVE_MAINLINE_MANIFEST.csv、FINAL_REPRODUCIBILITY_MANIFEST.csv、SUPPLEMENTARY_ANALYSIS_MANIFEST.csv、CURRENT_AUTHORITATIVE_RESULTS.md（FROZEN_20261001）、FINAL_BLOCKER_STATUS.md、FINAL_REPRODUCIBILITY_AUDIT.md、STATISTICAL_CLAIM_MAP.csv（终审 0 修改）、code/P1.py、code/P2.py（fail-closed guard）、code/V2_M17_phase6_rebuild.R（Fig6b label-only）、figures_final_v2/{Fig6_pathway_integration.{pdf,svg,preview.png}, Fig6_pathway_integration_source_data.csv, FIGURE_MANIFEST.md, VISUAL_QC.md, SOURCE_DATA_README.md}。

## 5. 纪律声明

本轮未运行任何分析（P1/P2/P3 仅静态核查 + guard 修复，未执行数据流）；未运行 --verify-only 之外的任何管线；未联网；未 commit/push/tag；未删除任何文件（123 个 safe-to-remove 仅登记入清单）；未改任何 repaired 数值；历史 snapshot 原样保留并确认隔离。
