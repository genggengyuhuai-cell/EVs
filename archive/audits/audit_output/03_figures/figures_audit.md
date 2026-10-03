# 图表审计（nature-figure）

> 审计性质：**纯静态只读审计**。不新出图、不运行任何绘图/分析脚本、不修改 `F:\env` 既有文件。
> 审计基准：nature-figure 技能 `static/core/contract.md`、`static/core/stance.md`、`references/qa-contract.md`、`references/nature-article-requirements.md`（旗舰 Nature 规范）。
> 术语：稿件措辞用 **High land / Hot-humid**；内部键 `High-pressure/high-altitude / Humid-hot` 与 `Short/Long dose` 仅出现在冻结结果表。
> 所有数字逐字引自 `F:\env` 内文件原文，并标注出处。

---

## 1. 审计范围与材料

### 1.1 实际读取的文件清单与读取方式

| 类别 | 文件 | 读取方式 |
|---|---|---|
| 技能基准 | `C:\Users\caoxu\.agents\skills\nature-figure\SKILL.md`、`manifest.yaml`、`static\core\contract.md`、`static\core\stance.md`、`references\qa-contract.md`、`references\nature-article-requirements.md` | Read 全文 |
| 项目权威 | `F:\env\PROJECT_CONTEXT.md` | Read 全文（冻结数字与仓库分层） |
| 既有对照 | `docs\FIGURES_NATURE_V2_2_PROVENANCE_AUDIT.md`、`docs\PATHWAY_FIGURE_INVENTORY_AUDIT.md`、`manuscript_v2_1\audit\FIGURE_TEXT_AUDIT.csv`、`FIGURE_TEXT_STANDARDIZATION_REPORT.md`、`F:\env\.nature-figure.json` | Read 全文 |
| M17 主图层 | `figures_final_v2\FIGURE_MANIFEST.md`、`VISUAL_QC.md`；`Fig1/Fig5/Fig6` 等 `*_source_data.csv`；`V2_M17_figures_v2.R`、`V2_M17_figures_v3_ml_supplement.R` | Read + PowerShell 只读统计行数/Grep |
| prospective 层 | `figures_prospective_v2.7\` 全目录清单、`SKILL_AUDIT.md`、`VISUAL_QC.md`、`FIGURE_MANIFEST.md`、`FIG1/FIG4/FIG5` 等 `*_source_data.csv` | PowerShell 递归清单 + Read |
| 渲染文本核验 | 两 bundle 全部 `.svg`（文本型矢量） | Grep 禁用词/正向词/数值标注 |
| 顶层描述层 | `descriptive\figures_nature_v2.2\`（193 文件）扩展名与文件名清单 | PowerShell 递归统计 |

### 1.2 三个被审图目录的实际构成（核对后）

- **`descriptive\figures_nature_v2.2\`**（SUPPLEMENTARY 层，扁平目录）：57 PDF + 57 PNG + 57 SVG + 22 CSV = **193 文件**。其中仅 22 个 `*_source.csv`（`Figure_01..04_*` + `Quantitative_filter_*`）；`Figure6_*`–`Figure15_*` 共约 35 个图干无配对 source CSV。
- **`descriptive\analysis_v2.0\figures_final_v2\`**（ACTIVE_MAINLINE M17）：Fig1–Fig6 各 4 件（pdf/svg/`_preview.png`/`_source_data.csv`）+ `SuppFig_ML_prioritization` 4 件 + `FIGURE_MANIFEST.md` + `VISUAL_QC.md` = **30 文件**。无 TIFF。
- **`descriptive\discovery_validation\figures_prospective_v2.7\`**：FIG1–FIG15 各 5 件（pdf/svg/tiff/`_source_data.csv`/png）+ 4 个 md + `qa_preview\` 内 15 张 PNG。TIFF 为 600 dpi LZW。

### 1.3 未读/未触达及理由

- `docs\FIGURES_NATURE_V2_2_FILE_MAP.csv`：既有 PROVENANCE_AUDIT 已给出权威目录与文件数，本审计以其为对照、独立复算了顶层 193 文件构成，未逐行重读 CSV。
- `figures_nature_v2.2` 其余 **10 个嵌套 `figures_nature_v2.2\` 目录**（covariate_QC、limma_dose_analysis、detection_pattern 等，合计约 456 文件）：任务审计对象 #2 仅点名顶层 193 文件 bundle；嵌套层由既有 PROVENANCE_AUDIT 在生产者层级覆盖，本审计不展开逐图核对。
- 未运行 `validate_figure.py` / `audit_pdf_text.py` / 任何 R/Python 绘图脚本（任务明令禁止）；Cairo 1-pt Tf 警告沿既有 VISUAL_QC 记录，不重复判定。
- 未做栅格像素级目视（色值、色盲模拟、打印尺寸下标签碰撞）——纯文本/SVG 静态审计无法替代最终物理尺寸逐面板目视，见第 5 节边界。

---

## 2. 独立判定（本管线结论）

### 2.1 本审计独立确认为"安全"的核心项

| 核对点 | 冻结基准（PROJECT_CONTEXT） | 本审计实测 | 出处 | 结论 |
|---|---|---|---|---|
| 队列 | 515（153/186/176）；Discovery 386；复用 hold-out 129 | Fig1 source：Raw 519→515；Control 153/Low 186/High 176；Discovery 386；Reused hold-out 129；9 站点 n 合计 515 | `Fig1_cohort_design_source_data.csv` 行 2–45；`FIG1_cohort_scope_source_data.csv` 行 2–13 | 一致 |
| DEP 与复现层级 | 85（1,445 蛋白 BH-FDR<0.05）；83 同向；29 名义；1 FDR | Fig5：Locked 85→Estimable 85→Same direction 83→Nominal P<0.05 29→Candidate-family BH-FDR<0.05 1；GOLGA3（index 39）为唯一 replication=FDR | `Fig5_replication_ml_source_data.csv` 行 2–6、219–222 | 一致 |
| 交互 | 0 / 1,430（Group×Environment，BH-FDR<0.05） | M17 Fig4 `b_interaction` 4 箱 = 140+399+427+464 = 1,430，无 [0,0.05] 箱即 FDR<0.05 = 0 | `Fig4_environment_site_source_data.csv` b_interaction 行 | 一致 |
| 通路三法 | cameraPR 195（BP25+Reactome170）；ORA 23（3+20）；fgsea 39（3+8+11+17）；KEGG NOT_RUN | Fig6：a_ranked=8（GO_BP）、c_ora=3（GO_BP）、b_sensitivity=887 行扫描、d_network=11 边；未见 195+23+39 求和 | `Fig6_pathway_integration_source_data.csv` 面板统计 | 一致（无求和） |
| 术语（渲染层） | 禁 "external validation / validated proteins / FDR-replicated"；用 High land/Hot-humid/Reused hold-out | Grep 两 bundle 全部 SVG：无 `Validation/Humid-hot/High-altitude/High-pressure/external/validated/FDR-replicat`；正向命中 `Reused hold-out / High land / Hot-humid`；Fig5 明确 "reused within-cohort hold-out; NOT external validation" | SVG grep 结果；`Fig5...csv` 行 2 注释 | 一致 |
| 后端 | `.nature-figure.json` = r | M17 与 prospective 出图均为 R/ggplot2（svglite+cairo_pdf+ragg）；`save_figure()` 183mm | `.nature-figure.json`；`V2_M17_figures_v2.R` 行 63–69 | 一致 |

### 2.2 与既有审计的差异对比表

| 维度 | 既有 PROVENANCE_AUDIT / FIGURE_TEXT_AUDIT / PATHWAY_INVENTORY 结论 | 本管线独立判定 | 差异/新增 |
|---|---|---|---|
| 层分类 | figures_nature_v2.2 = SUPPLEMENTARY；figures_final_v2 = M17 主图；两者不互相引用 | 同意，并复算顶层 193 = 57×3 + 22 CSV | 无差异 |
| 术语修复 | 称"重新生成后 PDF 文本无旧词" | 直接 Grep **SVG 渲染文本**复核，确认渲染层无禁用词、正向词在位 | 独立交叉验证（既有依据 PDF 文本抽取，本审计依据 SVG 文本节点），结论一致 |
| 复现层级 | FIGURE_TEXT_AUDIT 列出 R 源码待改点 | 实测渲染 SVG 与 Fig5 source 注释均已用 "Reused hold-out"，且 Fig5 主动写 "NOT external validation" | 确认修复已落到产物；另发现 SuppFig_ML 含否定式 "not a validated biomarker panel" |
| Fig1 universe 漏斗 | **未提及** | 发现 `Quantitative universe 1430 → Discovery eligible 1445` 在漏斗中**非单调递增** | **新增发现**（图注清晰度） |
| 交互分母 | M17 Fig4 = 0/1,430；prospective FIG4 = 0/85（各自文档） | 实测 prospective FIG4 SVG 标注 "0 / 85 interaction FDR < 0.05"，与 M17 Fig4 的 0/1,430 **分母不同** | **新增**：两 bundle 需图注区分受测蛋白集合 |
| Fig6 通路再精炼 | PATHWAY_INVENTORY 已判 "TOO_REDUCTIVE on Reactome"（170/195 未 curated 呈现） | 独立复核 source：a_ranked 仅 8 条 GO_BP，零 curated Reactome 面板；b_sensitivity 887 行为全测试扫描而非 39 条显著集 | 同意并补强证据：主图证据链缺口仍在 |
| source.csv 覆盖 | PROVENANCE_AUDIT 称"22 CSV 为 companion" | 复算：57 图干中仅 22 个有 source.csv，**约 35 个（Figure6–15 R 系列）无配对 CSV** | 新增为 source-data 可追溯性提示 |
| TIFF/导出 | VISUAL_QC 称 600 dpi TIFF"glyphs sharp"；M17"no TIFF requested" | prospective TIFF 600 dpi 超 Nature Extended Data ≤300 dpi 指引；M17 无 TIFF 对主图（矢量）正确 | 新增层级/分辨率合规提示 |

---

## 3. 分级发现清单

### 3.1 阻断（Blocker）

**无。** 冻结核心数字（515/153/186/176、386/129、85/83/29/1、0/1,430、195/23/39）在被审主图 source 与渲染标注中均未被写错；未发现把 129 称为 external/independent validation、把 29 称为 FDR-replicated、把三法通路数相加、或把 85 称为 validated proteins 的渲染文本。

### 3.2 重大（Major）

- **[重大] M1-1：主图 Fig6 "通路整合"证据链缺失 Reactome 主臂**
  - 证据指针：`figures_final_v2\Fig6_pathway_integration_source_data.csv` 面板统计——`a_ranked` 8 行全部 `database=GO_BP`；`c_ora` 3 行全部 `GO_BP`；`b_sensitivity` 887 行（GO_BP 271 / GO_CC 147 / GO_MF 105 / Reactome 364）。冻结 cameraPR 主分析 195 条中 Reactome 占 170（`PROJECT_CONTEXT.md` 第 6 节）。
  - 影响：主图标题为"Pathway and integrated biological interpretation"，但占主分析 170/195（≈87%）的 Reactome 通路没有任何 curated 面板呈现，仅隐没在 887 行全测试扫描散点里。审稿人可质疑主图未能承载 R6"representative pathway themes"核心信息；与 PATHWAY_INVENTORY 已判 "TOO_REDUCTIVE on Reactome" 一致，本审计独立复核确认该缺口仍在。
  - 建议：从冻结 `M12_pathway_v2.1\ranked/` 与 `integration/` 取数，在主图补一个 curated Reactome theme 面板（纯绘图任务，不重算统计）；或将 887 行 fgsea 扫描压缩为 concordance 散点、把完整通路图下沉补充材料。图注须写明 a_ranked 为"representative 8 of 25 GO-BP cameraPR"，并交代 Reactome 170 的去向。

### 3.3 次要（Minor）

- **[次要] m-1：Fig1 universe 漏斗出现非单调递增（1430 → 1445）而图注未解释**
  - 证据指针：`Fig1_cohort_design_source_data.csv` d_universe 行——Quantitative universe = 1430，下一行 Discovery eligible = 1445，Locked candidates = 85。
  - 影响：漏斗从 1,430 升到 1,445 是"变多"，审稿人可能误读为筛选口径错误或算术不一致。实际二者是不同合格规则（全定量宇宙 vs Discovery 子集合格），数字本身与冻结口径一致。
  - 建议：图注明确区分"Quantitative universe（全 515 样本定量合格）=1,430"与"Discovery-eligible（仅 Discovery 386 样本合格）=1,445"，说明二者为不同规则而非嵌套子集；避免在视觉上画成严格收窄漏斗。

- **[次要] m-2：交互显著性分母在两 bundle 间不一致（0/85 vs 0/1,430），图注须分别写明受测集合**
  - 证据指针：prospective `FIG4_environment_interaction.svg` 行 278 渲染标注 "0 / 85 interaction FDR < 0.05"；M17 `Fig4_environment_site_source_data.csv` b_interaction 4 箱合计 1,430（冻结 headline 0/1,430）。
  - 影响：两处均为"0"，方向不矛盾；但 prospective FIG4 在 85 候选子集上做环境交互，M17 Fig4 在全 1,430 定量宇宙做 Group×Environment 交互。若图注只写"0 interaction"而不写分母，审稿人会误以为口径冲突或遗漏。
  - 建议：prospective FIG4 图注写明"on the locked 85-candidate set"；M17 Fig4 沿用"0 / 1,430 proteins at BH-FDR<0.05"。遵守 PROJECT_CONTEXT：只写"No interaction survived the prespecified BH-FDR threshold"，不写"there was no interaction"。

- **[次要] m-3：figures_nature_v2.2 约 35/57 描述图干无配对 source-data CSV**
  - 证据指针：顶层 193 文件中仅 22 个 `*_source.csv`（`Figure_01..04_*` + `Quantitative_filter_*`）；`Figure6_*`–`Figure15_*`（covariate/批次代理/归一化/PCA/检测梯度等）无配对 CSV。
  - 影响：Nature source-data 政策与 qa-contract 要求定量面板可追溯到干净 CSV；这些 R 生产者（06–11）图只追溯到上游脚本/结果表，投稿补充材料时缺一份逐图可下载的 source CSV。
  - 建议：补充材料交付时为该系列补配对 CSV，或在补充说明里写明对应上游结果表路径；当前 SUPPLEMENTARY/QC 阶段可接受。

- **[次要] m-4：prospective v2.7 TIFF 为 600 dpi，若归入 Extended Data 将超分辨率指引**
  - 证据指针：`figures_prospective_v2.7\FIGURE_MANIFEST.md`（600-dpi LZW TIFF）；`VISUAL_QC.md`（"600-dpi TIFF render"）。Nature Extended Data 要求 RGB、≤300 dpi、单文件 ≤10 MB（`nature-article-requirements.md` 第 6 节）。实测最大 TIFF ≈ 0.82 MB（FIG7），体积合规。
  - 影响： prospective bundle 尚未定稿主/补充层级；若其中某图按 Extended Data 提交，600 dpi 超 300 dpi 上限（体积仍合规）。
  - 建议：层级定案后，Extended Data 图降采样到 300 dpi；主图维持矢量 PDF/SVG，不提交扁平化 TIFF。

### 3.4 提示（Hint / Boundary）

- **[提示] h-1：补充层后端非同质（.nature-figure.json = r，但 nature_plotting.py 为 Python）**
  - 证据指针：`.nature-figure.json` `{"backend":"r"}`；PROVENANCE_AUDIT 生产者 #2 为 `descriptive\nature_plotting.py`（Python）产出 Figure_01–04 + Quantitative_filter，其余 R 生产者产出 Figure6–15。
  - 影响：M17 主图与 prospective 全部 R/ggplot2，后端排他性成立；未发现用 Python 为 R 图做预览的跨后端渲染。仅补充层是多生产者混合，不影响主图契约。
  - 建议：无需改动；若未来把这些描述图纳入同一投稿 figure bundle，按最终目标图统一后端并在 QA 笔记说明。

- **[提示] h-2：prospective 的 VISUAL_QC.md / FIGURE_MANIFEST.md 内部笔记仍用旧术语**
  - 证据指针：`figures_prospective_v2.7\VISUAL_QC.md` 行 10/18/21/27/39 仍写 "Validation #C49A3D / Humid-hot / High-altitude"；渲染 SVG 已无这些词。
  - 影响：文档漂移，不是图缺陷；但后续图注撰写者若照抄 QC 笔记措辞会重新引入禁用词。
  - 建议：把内部 QC 笔记的 palette/说明同步为 "Reused hold-out / Hot-humid / High land"，保留色值不变。

- **[提示] h-3：SuppFig_ML 面板含否定式 "validated" 措辞**
  - 证据指针：`SuppFig_ML_prioritization.svg` 行 477 "…not a validated biomarker panel."
  - 影响：该句为否定式免责，方向正确（明确不是 validated panel），与 PROJECT_CONTEXT"不得把 85 称 validated proteins"不冲突。风险仅在于图注扩写时把 "validated" 误改成肯定句。
  - 建议：图注保持否定语境；沿用 Fig5 "conditional on the locked 85-protein panel; not an unbiased generalisation estimate" 的保守写法。

- **[提示] h-4：M17 主图无 TIFF——对主图正确，但需与"剩余任务 TIFF export"对齐**
  - 证据指针：`V2_M17_figures_v2.R` 行 63–69 仅 svglite+cairo_pdf+agg_png；`VISUAL_QC.md`（no TIFF requested；PNG 为 300 dpi QA 预览）。Nature 主图要求矢量 .ai/.eps/editable PDF，不收扁平化 tiff/png（`nature-article-requirements.md` 第 5 节）。
  - 影响：当前 M17 主图 editable PDF+SVG 已满足 accepted-in-principle 主图矢量契约；PROJECT_CONTEXT 第 9 节把"TIFF export"列为剩余任务，需澄清 TIFF 仅服务未来 Extended Data，主图不必补 TIFF。
  - 建议：在交付清单里区分"主图矢量（已合规）"与"Extended Data TIFF（待层级定案后 300 dpi）"。

- **[提示] h-5：Cairo 1-pt Tf 操作符为已知工具兼容警告**
  - 证据指针：两 bundle VISUAL_QC 均记录 Cairo PDF 的 nominal 1-pt `Tf` 为转换编码 artifact；源码校验最小 5.9 pt、最终尺寸目视可读。
  - 影响：非真实字号违规；本审计未重跑 `audit_pdf_text.py`（禁跑脚本）。
  - 建议：交付前在 accepted-in-principle 阶段对最终 PDF 重跑一次 glyph 扫描以闭环。

---

## 4. 可进入稿件的安全措辞要点

以下写法已在现有 source/注释/渲染文本中见到，建议图注沿用：

- 复现集合：用 "**reused within-cohort hold-out; NOT external validation**"（`Fig5...csv` 行 2 原文）。避免 "validation cohort / external / independent validation"。
- 复现层级：**"83 of 85 direction-concordant; 29 of 85 nominally replicated (raw P<0.05); 1 of 85 candidate-family BH-FDR-supported"**。不要把 29 写成 "FDR-replicated"。
- 交互：**"No Group×Environment interaction survived the prespecified BH-FDR threshold (0/1,430)"**；不要写 "there was no interaction"。prospective 候选子集图另注 "(0/85 on the locked candidate set)"。
- 通路：三法分别陈述——cameraPR 195（primary, competitive）/ ORA 23（complementary）/ fgsea 39（sensitivity）；**不要相加为单一通路数**；KEGG 标注 NOT_RUN。
- ML：**"conditional on the locked 85-protein Discovery panel; not an unbiased generalisation estimate; not a validated biomarker panel"**。
- 环境标签：**High land / Hot-humid**（稿件显示层）；内部键 `High-pressure/high-altitude`、`Humid-hot`、`Short/Long dose` 只留在冻结结果表，不进入图注。
- 队列：519→515（153 Control / 186 Low / 176 High）；Discovery 386；reused hold-out 129（同一队列，非外部验证）。
- 误差/统计：按 qa-contract 在图注给出 n、中心统计量、离散度定义、检验、多重比较校正、P 值显示方式；外折 AUROC 注明 outer folds、固定 85 条件。

---

## 5. 未覆盖 / 无法判定的边界

1. **未做最终物理尺寸逐面板目视**：纯静态审计读的是 SVG 文本节点与 source CSV，未在 183 mm 打印尺寸下核对标签碰撞、图例间距、色阶层级与色盲模拟数值。qa-contract 要求"automated checks 不替代逐面板目视"——该步须在出图/预览阶段完成，本审计不能替代。
2. **未审计 10 个嵌套 figures_nature_v2.2 目录**（covariate_QC、limma_dose_analysis、detection_pattern 等，约 456 文件）：任务审计对象仅点名顶层 193 文件 bundle；嵌套层由既有 PROVENANCE_AUDIT 在生产者层级覆盖，本审计未逐图核对其数值与图注。
3. **未运行脚本**：`validate_figure.py`、`audit_pdf_text.py`、R/Python 出图/统计脚本一律未执行；Cairo 1-pt Tf、5.9 pt 最小字号等结论沿用既有 VISUAL_QC 记录，本审计未独立复跑。
4. **大表未逐行通读**：FIG2 discovery primary（853 KB）、FIG9 historical reconciliation（585 KB）、Fig2 source（887 KB）等仅按面板行数与声明核对，未逐蛋白逐行比对 D02/D08 冻结结果表。
5. **栅格色值未数值核验**：prospective 调色板（#6E6E6E/#4C9BB8/#C4573B/#A64D6A/#3D8B7A/#2E6FA8/#C49A3D）未做 ΔE/色盲模拟计算，"不依赖红/绿单一编码、灰度可分"的结论来自 VISUAL_QC 自述与 SVG 色值，未独立测量。
6. **图注正文未写就**：当前仓库仅有 FIGURE_MANIFEST / VISUAL_QC 等内部说明，尚无可投稿的正式 Figure legend（PROJECT_CONTEXT 第 9 节"manuscript assembly: captions"为未开始任务）；本审计的"图注一致性"核对基于 source CSV 注释与 SVG 渲染标注，而非最终 legend 文本。
