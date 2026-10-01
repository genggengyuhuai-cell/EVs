# FGSEA FDR Family Reconciliation

> 日期：2026-10-01. 状态：FRAMEWORK_DRAFTED. Counts 留待执行管线重跑后填写.

## 1. 问题

fgsea combined CSV (`ranked_gsea/M12_fgsea_combined.csv`) 存在两列 BH-FDR：

| 列名 | 计算方式 | 校正族大小 | 来源 |
|---|---|---|---|
| `padj` | fgseaMultilevel 内部默认 BH，每族独立校正 | 族内（BP=274, MF=108, CC=151, Reactome=487） | fgsea 包默认输出 |
| `padj_pooled` | `p.adjust(all_pval, method="BH")` 跨 4 族合并后校正 | 全部 1,020 tests | M12B_all.R L204 手动追加 |

## 2. 计数对比（PRE_REPAIR vs REPAIRED）

| Family | Tested (old) | padj<0.05 old | padj_pooled<0.05 old | Tested (new) | padj<0.05 new (family) | padj_pooled<0.05 new |
|---|---|---|---|---|---|---|
| GO BP | 274 | 3 | 5 | 272 | 3 | 6 |
| GO MF | 108 | 8 | 6 | 107 | 8 | 7 |
| GO CC | 151 | 11 | 11 | 151 | 11 | 10 |
| Reactome | 487 | 17 | 17 | 486 | 22 | 18 |
| **合计** | **1,020** | **39** | **39** | **1,016** | **44** | **41** |

Repaired 计数来源：`ranked_gsea/M12_fgsea_combined.csv`（Phase 5 重跑后）。
差异：ranking statistic 从 self-fit+imputation 改为 D02 environment-adjusted moderated t，导致 Reactome family 显著性增加（17→22 family / 17→18 pooled）。

## 3. 历史各文档用了哪列

| 文档/产物 | 使用列 | 数字 | 位置 |
|---|---|---|---|
| `PROJECT_CONTEXT.md` §6 | padj（per-family） | 3/8/11/17 | 第六节通路数字块 |
| `STATISTICAL_CLAIM_MAP.csv` C22 | padj（per-family；其声明"pooled"与实际不符） | 3/8/11/17 | C22 行 Allowed_wording |
| `STATISTICAL_REPORTING_AUDIT.md` L119 | padj（per-family） | 3/8/11/17 | §13 pathway table |
| Fig6b 散点图 | padj（per-family） | 图上 y 轴 | V2_M17_figures_v2.R L289 `fgsea_fdr = padj` |
| `M12_FINALIZATION_REPORT.md` §6 | padj_pooled（cross-family） | 5/6/11/17 | 第 6 节 fgsea 段落 |
| `M12_FILE_AUDIT.csv` L35-39 | 文字写"padj"但数字实为 padj_pooled | 5/6/11/17 | fgsea per-family 文件描述 |

## 4. 执行管线已完成项

- [x] 重跑 fgsea 后，重新计数两列（见 §2 repaired 列）
- [ ] 团队裁定 canonical FDR family（per-family vs cross-family）
- [ ] 统一所有文档与 Fig6 使用 canonical 列
- [ ] 更新 PROJECT_CONTEXT / CLAIM_MAP / STATISTICAL_REPORTING_AUDIT
- [ ] 删除或标注非 canonical 列
- [x] Canonical_FDR = **UNRESOLVED**（保持合同 §12 状态；两套计数均不标 FINAL_FROZEN）

## 5. 备注

- 本框架不决定哪列为 canonical；仅记录历史双轨状态。
- 最保守透明默认（非强制）：padj_pooled（跨族合并 BH，校正族更大、更严格）。
- 两列均须输出至重跑后的 combined CSV，不得只保留一列。
