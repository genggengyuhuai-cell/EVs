# M12B Phase 5 修复重跑报告

> 日期：2026-10-01
> 模块：M12B = secondary biological context / contextual integration layer
> 修复内容：ranking statistic 从 self-fit+imputation 改为 D02 moderated t

---

## 修复点

| 修复项 | Old | New | 理由 |
|--------|-----|-----|------|
| Ranking statistic | 自行 lmFit(~group) + 行中位数插补 | D02 primary model moderated t (log2FC/SE) | 合同 §6: canonical ranking 必须来自 D02 environment-adjusted 主模型 |
| strict_nested 列名 | dep_appearance_freq / lasso_selection_freq / en_selection_freq | appearance_frequency / lasso_selection_frequency / en_selection_frequency | 实际 CSV 列名与脚本引用不匹配，修复 |
| KEGG | 无 | NOT_RUN（占位） | 合同 §16 |

---

## M12B 各输出计数

### cameraPR (secondary: GO MF + GO CC, per-family FDR)
- GO MF: 107 tested, 16 sig (FDR<0.05)
- GO CC: 151 tested, 16 sig (FDR<0.05)

### ORA (secondary: GO MF + GO CC, per-family FDR)
- GO MF: 7 sig (FDR<0.05)
- GO CC: 4 sig (FDR<0.05)

### fgsea multilevel (四族 sensitivity)
| Family | Tested | padj_family sig | padj_pooled sig |
|--------|--------|-----------------|-----------------|
| GO BP | 272 | 3 | 6 |
| GO MF | 107 | 8 | 7 |
| GO CC | 151 | 11 | 10 |
| Reactome | 486 | 22 | 18 |
| 合计 | 1016 | 44 | 41 |

### Network (pathway-protein bipartite)
- Edges: 8134
- Pathways: 205 (cameraPR pooled significant)
- Proteins: 1006
- Proteins in >=2 pathway families: 307

### Environment concordance
| Classification | Count |
|----------------|-------|
| BOTH_NONSIGNIFICANT_SAME_DIRECTION | 343 |
| ONE_ENV_SIGNIFICANT_SAME_DIRECTION | 188 |
| OPPOSITE_DIRECTION | 216 |
| SHARED_SAME_DIRECTION | 14 |

### Correlation (85 DEPs, Spearman)
- Median |rho|: 0.607
- Pairs |rho| >= 0.5: 2657
- Pairs |rho| >= 0.7: 942
- Pairs |rho| >= 0.8: 221

### Integrated candidate context
- 85 rows (matches D03 locked)

---

## M12B 定位声明

M12B 是 **secondary biological context / contextual integration layer**。
- Spearman correlation 仅为 pairwise association context，**不称 co-expression / regulatory network / WGCNA**
- Network 输出称 contextual correlation structure / pairwise association context
- GO MF/CC cameraPR 与 ORA 为次要分支，不计入主 PATH-R/PATH-O 计数
- fgsea 为 sensitivity 分析，Canonical_FDR = UNRESOLVED
