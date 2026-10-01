# M12 Software Provenance

> 日期：2026-10-01 (Phase 5 重跑后记录)
> 环境：Windows, R 4.3.1 (2023-06-16 ucrt)

## R 版本

| 项目 | 值 |
|------|-----|
| R version | 4.3.1 (2023-06-16 ucrt) |
| Platform | Windows x64 |

## 关键包版本

| Package | Version | 用途 |
|---------|---------|------|
| limma | 3.58.1 | cameraPR, eBayes (D02 输出读取) |
| fgsea | 1.28.0 | fgseaMultilevel |
| org.Hs.eg.db | 3.18.0 | GO gene sets, gene symbol mapping |
| GO.db | 3.18.0 | GO term names |
| reactome.db | 1.86.2 | Reactome gene sets |
| clusterProfiler | 4.10.1 | (辅助，主链未直接使用) |
| AnnotationDbi | 1.64.1 | GO/Reactome 查询 |
| data.table | 1.18.4 | 数据处理 |
| statmod | 1.5.0 | limma 依赖 |

## Annotation 源版本说明

- **org.Hs.eg.db 3.18.0**：GO 注释来源。Annotation 源随 Bioconductor 版本变化；不同 Bioconductor 版本会导致 GO gene sets 数量与成员差异。
- **GO.db 3.18.0**：GO term 名称定义。
- **reactome.db 1.86.2**：Reactome 通路基因集。Reactome 版本随 Bioconductor 更新。

**注意**：本次重跑的 pathway 计数（tested / significant）与 annotation 包版本绑定。若未来升级 Bioconductor 并重新运行，计数可能变化。当前计数须与上述包版本一起冻结。

## 数据来源文件

| 文件 | 角色 |
|------|------|
| descriptive/PRIMARY_dose_log2_expression.csv.gz | Mapping universe (1434 proteins) |
| descriptive/canonical_protein_annotation.csv | Gene annotation |
| descriptive/discovery_validation/D02_discovery_primary/D02_Long_vs_Short_all_tested.csv | Canonical ranking statistic (1445 proteins) |
| descriptive/discovery_validation/D03_candidate_lock/D03_locked_candidates.csv | ORA foreground (85 DEPs) |
| descriptive/discovery_validation_split/discovery_validation_assignment.csv | Sample split assignment |

## 随机种子

- set.seed(20260928, kind="Mersenne-Twister")
- fgsea eps=0（精确计算，非 permutation 近似）
