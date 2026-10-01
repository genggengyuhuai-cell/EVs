# AI 味诊断（doubao-human-signal，诊断模式）

> 诊断日期：2026-10-01。诊断视角：doubao-human-signal「诊断质检」工作流。
> 本次只诊断、只给修改清单；**未改写任何文档、未改动任何事实与数字**。
> 体裁判定：本批为科研内部审计 / 控制文档（英文为主，6 份中文描述报告），「客观、工整、保守、边界声明密集」是体裁优点，**不计入 AI 味**；本次只抓模板重复、空泛套话、强行升华与机械结构。

## 1. 诊断范围与材料（文档清单 + 读取方式）

读取方式：全部 22 份文档逐份完整 Read（非抽样、非摘要），以正文 + 行号为证据。

| # | 文件 | 语言 | 体量 |
|---|---|---|---|
| 1 | `F:\env\PROJECT_CONTEXT.md` | EN | 151 行 |
| 2 | `manuscript_v2_1\audit\WHOLE_PROJECT_SCIENTIFIC_REVIEW.md` | EN | 87 行 |
| 3 | `manuscript_v2_1\audit\STATISTICAL_REPORTING_AUDIT.md` | EN | 200 行 |
| 4 | `manuscript_v2_1\audit\EXPERIMENTAL_DESIGN_REVIEW.md` | EN | 126 行 |
| 5 | `manuscript_v2_1\audit\PROJECT_RECONSTRUCTION_PLAN.md` | EN | 135 行 |
| 6 | `manuscript_v2_1\audit\FIGURE_TEXT_STANDARDIZATION_REPORT.md` | EN | 63 行 |
| 7 | `docs\README.md` | 中英混 | 56 行 |
| 8 | `docs\FINAL_REPRODUCIBILITY_AUDIT.md` | EN | 186 行 |
| 9 | `docs\FINAL_ML_RESULT_AUDIT.md` | EN | 375 行 |
| 10 | `docs\ML_ALGORITHM_INTERSECTION_AUDIT.md` | EN | 295 行 |
| 11 | `docs\FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md` | EN | 98 行 |
| 12 | `docs\PATHWAY_FIGURE_INVENTORY_AUDIT.md` | EN | 137 行 |
| 13 | `docs\P0_P1_REPAIR_PLAN.md` | EN | 258 行 |
| 14 | `docs\CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md` | EN | 143 行 |
| 15 | `docs\SOFTWARE_ENVIRONMENT_REPORT.md` | EN | 73 行 |
| 16 | `docs\PIPELINE_STATUS.md` | EN | 56 行 |
| 17 | `descriptive\QC前描述_样本构成与分析路线.md` | 中文 | 60 行 |
| 18 | `descriptive\QC前描述_检出率梯度.md` | 中文 | 55 行 |
| 19 | `descriptive\QC前数据描述_完整报告.md` | 中文 | 92 行 |
| 20 | `descriptive\数据描述报告.md` | 中文 | 50 行 |
| 21 | `descriptive\normalization_design_diagnostics_report.md` | EN | 79 行 |
| 22 | `descriptive\dose_quantitative_filtering_report.md` | EN | 83 行 |

CSV、脚本、图片不在本维度。

## 2. 各文档 AI 味指数与成因层定位

评分口径：0–100，越高越像模板化生成；0–20 = 「AI 味很低，不建议大改」（依 evaluation.md 量表）。

| 文档 | AI 味指数 | 主要成因层 | 优先级 |
|---|---|---|---|
| PROJECT_CONTEXT.md | 12 | 结构层（纯索引/权威表，无叙述） | 不改 |
| WHOLE_PROJECT_SCIENTIFIC_REVIEW.md | 15 | 表达层（个别模板化开场句） | 不改/微改 |
| STATISTICAL_REPORTING_AUDIT.md | 18 | 结构层（开场免责模板重复） | 次要 |
| EXPERIMENTAL_DESIGN_REVIEW.md | 14 | —（表格+边界声明，体裁成立） | 不改 |
| PROJECT_RECONSTRUCTION_PLAN.md | 16 | —（Framing A/B/C 有作者判断，声音自然） | 不改 |
| FIGURE_TEXT_STANDARDIZATION_REPORT.md | 15 | 表达层（结尾长串否定句模板） | 次要 |
| docs/README.md | 12 | —（权威层级图，体裁成立） | 不改 |
| FINAL_REPRODUCIBILITY_AUDIT.md | 20 | 结构层（开场/结尾免责模板） | 次要 |
| FINAL_ML_RESULT_AUDIT.md | 25 | 结构层（免责开场 + Git 尾节 + “Bottom line / Final one-line answer” 收束模板） | 重大（相对） |
| ML_ALGORITHM_INTERSECTION_AUDIT.md | 20 | 结构层（与上者共享尾节模板） | 次要 |
| FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md | 16 | 结构层（免责开场） | 次要 |
| PATHWAY_FIGURE_INVENTORY_AUDIT.md | 15 | — | 不改 |
| P0_P1_REPAIR_PLAN.md | 18 | 表达层（模板化 code-block 状态标签） | 次要 |
| CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md | 16 | 结构层（免责开场） | 次要 |
| SOFTWARE_ENVIRONMENT_REPORT.md | 10 | —（纯记录） | 不改 |
| PIPELINE_STATUS.md | 8 | —（纯状态表） | 不改 |
| QC前描述_样本构成与分析路线.md | 12 | 表达层（一处标点瑕疵，见 3.4） | 提示 |
| QC前描述_检出率梯度.md | 10 | — | 不改 |
| QC前数据描述_完整报告.md | 12 | — | 不改 |
| 数据描述报告.md | 10 | — | 不改 |
| normalization_design_diagnostics_report.md | 8 | — | 不改 |
| dose_quantitative_filtering_report.md | 8 | — | 不改 |

**总体判断：整批 AI 味很低（中位数约 14/100，全部落在 0–25 区间）。**
没有发现空泛升华、口号式结尾、排比抒情、大词堆叠或正确废话；几乎所有「不是 A 而是 B / X is descriptive, not causal」句式都服务于「claim 边界」这一体裁本职，属优点，不改。唯一真实的模板痕迹是**跨文档逐字重复的免责开场段**，见 3.2。

## 3. 分级发现清单

### 3.1 阻断

无。整批无虚构事实、无拔高意义、无删改数字来源；未触发任何一票否决。

### 3.2 重大

- **[重大] M-01：跨审计文档逐字复用同一「无新分析 / 无冻结值改动」免责开场模板**
  - 证据指针：
    - `manuscript_v2_1\audit\STATISTICAL_REPORTING_AUDIT.md:4-5` — "No new analysis, model, feature selection, threshold tuning, or result optimization was performed. Numbers below are read directly from the frozen result CSVs."
    - `docs\FINAL_REPRODUCIBILITY_AUDIT.md:3-4` — "No analysis was rerun; no frozen result was modified; no files were moved."
    - `docs\FINAL_ML_RESULT_AUDIT.md:8-10` — "No model was re-trained, no hyperparameter was re-tuned, no feature was re-selected, no frozen CSV was modified."
    - `docs\ML_ALGORITHM_INTERSECTION_AUDIT.md:6-9` — "No model was re-trained, no CV re-run, no Boruta recomputed, no XGBoost refit, no threshold invented."
    - `docs\FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md:5` — "No analysis was rerun, no paths changed, no outputs modified."
    - `docs\PATHWAY_FIGURE_INVENTORY_AUDIT.md:3-4` — "No analysis rerun; no figure regeneration."
    - `docs\CONTROL_DOCUMENT_CONSOLIDATION_REPORT.md:3-4` — "No analysis was rerun; no frozen result was modified; no scientific file was moved."
    - `manuscript_v2_1\audit\WHOLE_PROJECT_SCIENTIFIC_REVIEW.md:3` — "No new analysis was run; no frozen number was changed."
  - 成因层：结构层（模板感）。同一句型在 8 份文档里以同一语序（No X rerun; no Y modified）复用，是典型的「同一次生成批量产出」指纹。声明本身**有功能、必须保留**，问题在于逐字重复。
  - 修改方向（只给方向，不改文档本体）：保留「本轮做了什么、没做什么」这一免责信息，但收口为一句、不再每篇展开四连否定。例如把「rerun / modified / moved / re-trained」压成每篇一行，差异部分（如 ML 审计特有的 "no Boruta recomputed, no XGBoost refit"）单独留一句即可；不必把同一句式换八个写法各写一遍。
- **[重大] M-02：两份 ML 兄弟审计共享同一「Git / process check」尾节模板**
  - 证据指针：
    - `docs\FINAL_ML_RESULT_AUDIT.md:353-361`（§11 "Git status (read-only check)"）— "No commit, no push, no modified frozen CSV."
    - `docs\ML_ALGORITHM_INTERSECTION_AUDIT.md:283-295`（§13 "Git / process check"）— "No commit, no push."；两条均含 "No model re-run, no CV re-run…" 近似表述。
  - 成因层：结构层（模板感）。兄弟文档共用同一收尾节，读者两篇连读会立刻感到复制粘贴。
  - 修改方向：保留 git 事实本身，但第二篇不再重复完整尾节；改成一句指向（如 "Git/process check identical to FINAL_ML_RESULT_AUDIT §11"），避免同一状态描述在两份文档里各写一遍。

### 3.3 次要

- **[次要] m-01：收束段标题模板化（"Bottom line" / "Final one-line answer"）**
  - 证据指针：
    - `docs\FINAL_ML_RESULT_AUDIT.md:32` — "**Bottom line:** fixed-85 uses all 85 as model inputs…"
    - `docs\FINAL_ML_RESULT_AUDIT.md:364` — "## 12. Final one-line answer"
    - `docs\ML_ALGORITHM_INTERSECTION_AUDIT.md:105` — "**No frozen-evidence conflict.**"
  - 成因层：表达层（强行概括式收束）。内容本身是事实复述，无拔高；但 "Bottom line / Final one-line answer" 是生成式文档的高频收束模板。
  - 修改方向：信息保留，可把标题改成更中性的结论句（如直接用结论作小标题），去掉 "Bottom line / one-line answer" 这类元话术。
- **[次要] m-02：结尾四连平行否定句（ borderline，倾向保留）**
  - 证据指针：`docs\ML_ALGORITHM_INTERSECTION_AUDIT.md:274-279` — "They are **not** final biomarkers, **not** validated biomarkers, **not** causal proteins, and **not** independent predictors."
  - 成因层：表达层（句式整齐）。
  - 修改方向：**倾向保留**——这是 claim 边界声明，删任一否定都会弱化风险提示（违反保真/行业边界）。仅在它出现第 2 次以上时合并；全文出现 1 次可不动。
- **[次要] m-03：状态码 code-block 堆叠（P0/P1 修复计划）**
  - 证据指针：`docs\P0_P1_REPAIR_PLAN.md:16-23, 61-65, 124-127, 151-155, 187-191` — 多处用 ```text 代码块包 "STATUS: PROVENANCE_MISMATCH" / "INPUT_DRIFT_RISK" / "EXPLORATORY_DIAGNOSTIC" 等状态标签。
  - 成因层：结构层。状态标签本身是机器可读、有意为之；问题是同一文档内 code-block 状态块出现 5+ 次，节奏偏均匀。
  - 修改方向：状态标签功能保留；可考虑把同类状态合并到一张小表，减少 code-block 重复出现频次。不改事实。

### 3.4 提示

- **[提示] t-01：中文文档一处标点瑕疵（非 AI 味，但属编辑遗留）**
  - 证据指针：`descriptive\QC前描述_样本构成与分析路线.md:4` — "control/low/high/unknown全部保留，。样本列数不等同已确认独立受试者数。"
  - 说明："保留，。" 连用逗号+句号是输入时的笔误；与 AI 味无关，仅作编辑提示列出。
- **[提示] t-02：docs/README.md 的「一句话规则」blockquote**
  - 证据指针：`docs\README.md:55` — 长 blockquote 总结权威层级。
  - 说明：这是有意设计的速查规则，属体裁优点，**不改**；仅登记为「已评估、判定为正常」。
- **[提示] t-03：中英混排（英文审计 + 中文描述报告）**
  - 说明：`descriptive\` 下 4 份中文报告与其余英文报告语体一致（均短句、表格、边界声明），未见翻译腔或机器翻译痕迹。登记为「已评估、判定为正常」。

## 4. 写作规范建议（该批文档可直接采纳的去 AI 味规则清单）

1. **免责声明收口为一行**：每篇审计保留一句"本轮未重跑分析 / 未改冻结值"，差异部分（ML、mapping、figures 各自特有的 no-X）单列；不再每篇展开四连 "No X; no Y; no Z"。
2. **兄弟审计共享尾节时互相引用**：git / process check、provenance 标签这类状态描述只在一份文档里写全，其余文档一行指回。
3. **收束段不使用元话术标题**：避免 "Bottom line / Final one-line answer / 一句话结论"；直接把结论句作标题或直接成段。
4. **claim 边界否定句全文限量**："not A, not B, not C, not D" 式平行否定每篇最多出现 1 次；这是风险提示，不删，但不复制。
5. **不做任何升华**：本批已无强行升华，保持即可——结尾停在状态/数字/下一步动作，不要加 "意义 / 价值 / 展望" 句。
6. **客观工整是优点，不要为了"人感"打碎表格**：本批表格密集、短句、边界声明准确，是技术文档的正确形态；上述建议只针对跨文档模板重复，不动单篇内部结构。

## 5. 未覆盖 / 无法判定的边界

- 本诊断只覆盖清单内 22 份 `.md`；`manuscript_v2_1/` 下其余文件、`docs/protocol/`、`descriptive/` 下其他报告未在本次清单，未读、未评。
- CSV、脚本、Figure 文件本身的语体不在本维度。
- 中文描述报告的"检测曲线/图注"部分基于正文判断；图内文字（PDF/SVG 内）未逐字核对。
- AI 味指数为诊断者按 evaluation.md 量表的相对打分（0–100），反映「模板生成感」而非文档质量；本批全部低分主要因体裁克制、事实密集，**不代表需要改写**。
- 本次为只读静态审计：未修改 F:\env 任何既有文件；本报告自身为新增产物，路径见下。
