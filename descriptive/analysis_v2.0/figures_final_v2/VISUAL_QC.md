# M17 figure Visual QC — Phase 6（2026-10-01）

范围：重建后的 Fig3/Fig4/Fig5/Fig6（Fig1/Fig2 未动，沿用旧 QC）。检查对象为各 `_preview.png`（300 dpi），并对照同源 PDF/SVG。

## 逐图静态 QC
| 检查项 | Fig3 | Fig4 | Fig5 | Fig6 |
|---|---|---|---|---|
| 面板字母 a/b/c/d | pass | pass | pass | pass |
| 轴标题可读、无裁切 | pass | pass | pass（副标题已缩短） | pass（标题已缩短、无碰撞） |
| 图例不压数据点 | pass | pass | pass | pass |
| 样本量/分母标注 | n=85 索引 | interaction 0/1,430 | 85 分母；strict 8/15 fit | FDR_pooled 标注 |
| FDR / 显著性标注 | — | — | 0.5 chance line | -log10(pooled FDR) |
| 基因/通路标签 | pass | — | pass | pass（Reactome 为 R-HSA ID，见下注） |
| 无残留旧数字 | pass | pass | pass（无旧 8–618 / 旧 AUROC 0.634/0.629） | pass（GO-BP 29 / Reactome 176 口径） |

## 关键 QC 发现与修复
1. **Fig6b 标题裁切 + Fig6c/d 标题横向碰撞**（首版）：已缩短 b 标题为 “Representative Reactome (cameraPR)”、c 为 “Candidate-family ORA”，重渲染后无碰撞。
2. **Fig5b 副标题过长右缘裁切 + strict 标注落在右缘**（首版）：副标题缩短为 “Fixed-85: locked 85 universe; strict nested: discovery redone in folds”；strict 标注移至该 facet 左侧（LASSO 列上方），文字 “7/15 outer folds: no features at threshold (points = 8 fit folds)”。
3. **Reactome 通路名为 R-HSA ID**（如 R-3560782）：repaired `M12_ranked_combined_FDR.csv` 中 Reactome `pathway_name` 即 R-HSA ID，无人类可读名；main 用短 ID 展示，完整 ID/归属见 source_data。GO-BP 仍为可读术语名。
4. **Fig6b Direction 图例仅显示 Down**：8 个 Reactome 代表中 1 个 Up；颜色编码 red=Up/blue=Down 与 panel a 一致，图注统一说明。

## 一致性与导出
- PDF/SVG/PNG 由同一 `save_figure()` 一次生成，内容一致。
- SVG 文本可编辑（svglite）；PDF Arial；PNG 300 dpi 仅 QA preview（main figure 不收扁平化 TIFF，符合 flagship Nature 主图矢量要求）。
- 色盲安全：方向用 red/blue 双编码 + 点位置/符号，不依赖红绿单色；灰阶下符号与位置仍可辨。

## 未决/提示
- fgsea 未进 Fig6（Canonical_FDR=UNRESOLVED），待团队裁定 padj_family(44) vs padj_pooled(41) 后补 supplement 可视化。
- Reactome 人可读名映射缺失，建议后续补 Reactome name annotation（不阻断本轮重建）。

---

## Phase 7（2026-10-01）FIG6B_LABEL_ONLY_UPDATE=YES
- 仅 Fig6b y 轴标签更新为人类可读 pathway name（reactome.db 1.86.2）；其余三 panel（a/c/d）与重导出前一致（除格式外）。
- 目检新 PNG：b 面板 8 条标签人类可读、多行折行、无裁切；a/c/d 结构与数值未变。
- 8 个 ID 全部解析成功，**无 UNRESOLVED**。
- 已知小项（不阻断）：b 面板顶部 “Genes” 图例与 a 面板 “Direction” 图例在 gutter 处轻微贴近，不影响读数。
