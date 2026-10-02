# GIT WHITESPACE POLICY（git 白空格策略）

> 日期：2026-10-01。Phase 7 P14。
> 实测基线：`git diff --check` = **194** 行 trailing whitespace 错误。

## 1. 最终决策

**POLICY = HISTORICAL_EXCLUDE（不修复；计入 known-historical 排除项）。**

- 对这 194 处 trailing whitespace **不做任何清理**（本轮不修改任何 SVG 文件）。
- 将 `descriptive/figures_nature_v2.2/` 与 `descriptive/detection_pattern/figures_nature_v2.2/` 下的 SVG trailing whitespace 登记为 **known-historical exclusion**，在最终报告口径中作为"既有历史/上游产物白空格"单列，不计入本轮 canonical 冻结批次的 must-fix 门禁。

## 2. 依据

1. **错误来源单一且非 canonical 冻结批次**：194 行全部命中
   - `descriptive/figures_nature_v2.2/*.svg`（约 190 行），
   - `descriptive/detection_pattern/figures_nature_v2.2/*.svg`（2 个文件、4 行）。
   无一位于 `descriptive/analysis_v2.0/figures_final_v2/`（Phase 6 重建主图 Fig3–6）或 `*/supplement_figures/`（Phase 6 重建补充图 S-ML/S-M09/S-M11/S-PATH）。
2. **本轮 canonical 产物 0 白空格**：Phase 6 重建的 `figures_final_v2/`、`supplement_figures/`、`docs/`、`manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` 均干净——`git diff --check` 对这些路径 0 命中。
3. **文件性质**：上述 SVG 属上游 descriptive/QC 补充图包（`ACTIVE_MAINLINE_MANIFEST` = "Upstream descriptive / SUPP_ACTIVE"；`SUPPLEMENTARY_ANALYSIS_MANIFEST` "Upstream_QC_descriptive"，provenance 2026-09-29 审计，M17 不消费），是早于本轮的既有产物，非本阶段重画。
4. **任务分支裁决**：按 P14 规则，"属 historical/descriptive/supplementary 而非 canonical 冻结批次" → 走 HISTORICAL_EXCLUDE；"仅当存在 canonical figure（figures_final_v2 或 supplement_figures 内）才允许纯 trailing-whitespace cleanup"。本批不满足后者，故不修复。
5. **边界遵守**：即便属历史，清理 SVG 仍有渲染/差异风险；本任务明确要求除非 100% 确认只改 trailing whitespace 且渲染不变否则只记录。本策略选择"只记录、不动文件"，零风险。

## 3. 口径（最终报告引用）

- `git diff --check` 194 行 = 既有上游 descriptive/QC SVG 的 trailing whitespace，**HISTORICAL_EXCLUDE**。
- 本轮（Phase 6/7）canonical 新产物白空格 = **0**。
- 未来若重跑上游 descriptive 管线（06–11 / nature_plotting.py）重新生成这些 SVG，新文件应不带 trailing whitespace，届时排除项自然消除；在此之前不单独做一次性格式化提交（避免对冻结/历史图包产生无科学意义的 diff）。

## 4. 备注

- `git` 输出中的 "LF will be replaced by CRLF" 提示为 Windows 行尾归一化警告，**非** whitespace error，不计入 194。
- 本策略不改任何文件；`figures_nature_v2.2` 的 trailing whitespace 维持现状。
