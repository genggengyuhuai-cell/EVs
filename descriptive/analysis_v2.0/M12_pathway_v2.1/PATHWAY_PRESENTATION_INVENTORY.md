# 通路展示清点（PATHWAY_PRESENTATION_INVENTORY）

> 性质：纯静态只读清点。未重画、未 rerun、未修改任何图形/脚本。
> 权威总状态：**FREEZE_READINESS=BLOCKED；SUBMISSION_READINESS=BLOCKED；ANALYSIS_REOPEN_REQUIRED=YES；M12=BLOCKED；M12B=BLOCKED_BY_M12；Fig6=NOT_FINAL；195/23/39=PRE_REPAIR_EXISTING_OUTPUT；FGSEA_FROZEN_FAMILY=HOLD_UNTIL_M12_REPAIR_AND_RERUN；KEGG=NOT_RUN。**
> 分类口径：MAIN（主图 curated 面板）/ SUPPLEMENT（补充图）/ RESULT_TABLE_ONLY（仅 CSV 结果表，无图）/ NOT_DISPLAYED（既无图也无对应可读表，或 NOT_RUN）。

---

## 1. 搜索范围（已核证无遗漏）

- `descriptive\figures_nature_v2.2\`（193 文件）：按文件名匹配 pathway/network/correlat/reactome/enrich/cluster/GO/ora/fgsea → **0 命中**。无任何通路图。
- `descriptive\discovery_validation\figures_prospective_v2.7\`（FIG1–15）：同样关键词 → **0 命中**；FIG6_integrated_evidence 为 85×5 证据矩阵（D-side），非通路富集图。
- `M12_pathway_v2.1\`：仅 4 R + 34 CSV + 2 md，**0 个 pdf/png/svg/tiff**。
- `M12B_biological_context_v2.1\`：仅 R + CSV + md，**0 个图文件**。
- `figures_final_v2\`：通路图仅 `Fig6_pathway_integration.*`；`SuppFig_ML_prioritization.*` 为 ML，非通路。
- 结论：**全仓库唯一的通路图就是主图 Fig6**；其余通路输出全部停留在 CSV 结果表。

---

## 2. family × method 展示清点（逐行）

| family | method | 全输出规模（结果表实测） | 是否有 curated 图展示 | 分类 | 文件证据 |
|---|---|---|---|---|---|
| GO-BP | cameraPR | 25 sig / 274 tested | Fig6 a_ranked curated 8/25 | **MAIN(partial)** + RESULT_TABLE_ONLY | `Fig6...source.csv` a_ranked 8 行；`ranked/M12_ranked_GO_BP.csv` |
| Reactome | cameraPR | 170 sig / 487 tested | 仅 Fig6 b 散点中的点（364 行），无 curated 面板 | **RESULT_TABLE_ONLY** | `ranked/M12_ranked_Reactome.csv`；`ranked/M12_ranked_combined_FDR.csv` |
| GO-MF | cameraPR | 未运行（combined 表无 MF 行） | 无 | **NOT_RUN_THIS_METHOD** | `ranked/M12_ranked_combined_FDR.csv` 仅 GO_BP+Reactome |
| GO-CC | cameraPR | 未运行 | 无 | **NOT_RUN_THIS_METHOD** | 同上 |
| GO-BP | ORA | 3 sig / 154 tested | Fig6 c_ora curated 3/3（全部） | **MAIN(complete)** | `ora/M12_ORA_GO_BP.csv`；Fig6 c_ora 3 行 |
| Reactome | ORA | 20 sig / 178 tested | 无 curated 图 | **RESULT_TABLE_ONLY** | `ora/M12_ORA_Reactome.csv`；`ora/M12_ORA_combined_FDR.csv` |
| GO-MF | ORA | 结果表存在，未进合并显著 | 无图 | **RESULT_TABLE_ONLY** | `ora/M12_ORA_GO_MF.csv`（6,492 B） |
| GO-CC | ORA | 结果表存在，未进合并显著 | 无图 | **RESULT_TABLE_ONLY** | `ora/M12_ORA_GO_CC.csv`（9,764 B） |
| GO-BP | fgsea | 3 sig / 274 tested | 仅 Fig6 b 散点 y 轴（padj），无 curated 面板 | **RESULT_TABLE_ONLY** | `ranked_gsea/M12_fgsea_GO_BP.csv`；Fig6 b_sensitivity |
| GO-MF | fgsea | 8 sig / 108 tested | 仅 Fig6 b 散点 | **RESULT_TABLE_ONLY** | `ranked_gsea/M12_fgsea_GO_MF.csv` |
| GO-CC | fgsea | 11 sig / 151 tested | 仅 Fig6 b 散点 | **RESULT_TABLE_ONLY** | `ranked_gsea/M12_fgsea_GO_CC.csv` |
| Reactome | fgsea | 17 sig / 487 tested | 仅 Fig6 b 散点 | **RESULT_TABLE_ONLY** | `ranked_gsea/M12_fgsea_Reactome.csv` |
| M12B 候选-通路网络 | M12B | edges 911 KB / nodes 43 KB | Fig6 d_network curated GO-BP top-4（11 边） | **MAIN(partial)** + RESULT_TABLE_ONLY | `M12B...\network\*.csv`；Fig6 d_network 11 行 |
| M12B Spearman 相关 | M12B | 3 CSV（pairs 203 KB / spearman 130 KB / collinearity） | 无图 | **NOT_DISPLAYED**（结果表 only） | `M12B...\correlation\*.csv` |
| M12B 环境一致性 | M12B | 2 CSV（concordance 177 KB / summary） | 无图 | **NOT_DISPLAYED**（结果表 only） | `M12B...\environment\*.csv` |
| KEGG | cameraPR/ORA/fgsea | NOT_RUN（占位 CSV） | 无 | **NOT_RUN** | `ranked/M12_ranked_KEGG.csv`（284 B）；`ora/M12_ORA_KEGG.csv`（163 B） |

---

## 3. fgsea 各家族 FDR 列使用记录

| 出现位置 | fgsea FDR 列 | 证据 |
|---|---|---|
| Fig6 b_sensitivity（主图） | **`padj`**（per-database） | R 行 258 `fgsea_score=safe_log10(padj)`；行 289 `fgsea_fdr=padj`；concordance 表无 `padj_pooled` 列 |
| `M12_fgsea_combined.csv`（结果表） | 同时含 `padj` 与 `padj_pooled` | 表头实测：…,database,direction,**padj_pooled**（以及 padj） |
| Supplement 通路图 | **不存在** | 无任何补充通路图，故无列使用问题 |

家族拆分核对（实测）：
- `padj`：BP 3 / MF 8 / CC 11 / Reactome 17 = 39（与冻结拆分一致）。
- `padj_pooled`：BP 5 / MF 6 / CC 11 / Reactome 17 = 39（总数同，BP/MF 拆分不同）。
- **风险提示**：当前 Fig6 用 `padj`，与冻结一致；但因 FGSEA_FROZEN_FAMILY=HOLD_UNTIL_M12_REPAIR_AND_RERUN，M12 修复重跑后两列计数都可能变化，Supplement 通路图一旦新增，必须在图注写明用的是 `padj` 还是 `padj_pooled`，避免 BP/MF 拆分漂移。

---

## 4. 结论

1. **MAIN curated 通路展示仅 Fig6 四张面板，且 a/c/d 全部锁 GO-BP**；Reactome（cameraPR 170 + ORA 20 + fgsea 17）、GO-MF（fgsea 8）、GO-CC（fgsea 11）在主图中均无 curated 面板，只作为 b_sensitivity 散点的点存在。
2. **SUPPLEMENT 层当前没有任何通路图**：figures_nature_v2.2 与 prospective_v2.7 均无 pathway/network/correlation 图；M12/M12B 无任何图文件。
3. **绝大多数 family×method 为 RESULT_TABLE_ONLY**：完整通路清单只在 `M12_pathway_v2.1\{ranked,ora,ranked_gsea}\*.csv` 与 `M12B*\*\*.csv` 中，未可视化。
4. 因 M12=BLOCKED、Fig6=NOT_FINAL、195/23/39=PRE_REPAIR_EXISTING_OUTPUT，本清点不代表最终投稿形态；M12 修复重跑后需重新清点 full output 计数与 FDR 列。
