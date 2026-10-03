# M12 Mapping P0 修复笔记 (P2)

## old behavior
- 文件：`M12_01_mapping.R` 第 15-16 行（原行号）
- 原代码使用 `read.csv(..., nrows=0)` 读取 PRIMARY 矩阵 `descriptive/PRIMARY_dose_log2_expression.csv.gz`
- `nrows=0` 表示仅读取表头行，不读取任何数据行
- 结果：`rownames(expr)` 返回空字符向量，`tested_prots` 长度为 0
- 下游影响：`ann_test` 匹配全空、contract 表 0 行、所有 mapping 统计失效

## root cause
- 调试残留或误操作：`nrows=0` 被意外留在生产代码中
- 意图应为读取完整矩阵以获取所有测试蛋白的行名（1434 个）

## code repair
- 文件：`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R`
- 修改点 1：第 15-16 行附近 — 移除 `nrows=0` 参数，完整读取 PRIMARY 矩阵
- 修改点 2：第 27-30 行附近 — 添加 `stopifnot` 断言 `length(tested_prots) == 1434`
- 修改点 3：第 128-133 行附近 — 添加 summary 区 4 条 assertions（1434/1414/15/5）

## expected universe
| 指标 | 预期值 | 说明 |
|------|--------|------|
| tested_prots（总测试蛋白） | 1434 | PRIMARY 矩阵行数 |
| unambiguous_one_gene（已映射） | 1414 | 单基因唯一映射 |
| multi_gene_ambiguous | 15 | 多基因歧义映射 |
| unmapped | 5 | 无基因映射 |

数值来源：PROJECT_CONTEXT 第 6 节 universe 定义。

## requires_rerun
YES — 脚本本轮未运行，所有 assertions 为重跑后预期核验值。

## outputs not revalidated
- M12 下游输出（195 条通路富集结果 / 23 条显著通路 / 39 条差异蛋白通路关联）与 universe 数值均未经重跑核验。
- 修复仅为静态代码修复，待重跑后方可确认输出正确性。

## 备份位置
- 原文件备份：`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R.orig.bak`
