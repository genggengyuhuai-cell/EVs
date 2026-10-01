# P2+P18+P19+P20+P21 确定性代码修复日志

**执行日期**：2026-10-01
**执行模式**：静态分析 + 确定性代码修复（不运行任何脚本）
**边界遵守**：未运行任何 R/Python 脚本、未重算统计、未修改数值类 CSV（除 P21 状态字段行）、未执行任何 git 写操作。

---

## 修复文件清单与关键变更

---

### P2: M12_01_mapping.R nrows=0 修复

**文件路径**：`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R`
**备份位置**：`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R.orig.bak`

**静态确认结果**：
- 原第 15-16 行：`read.csv(..., nrows=0)` 仅读取表头，`tested_prots` 为空向量
- Root cause：调试残留 `nrows=0` 参数，导致 PRIMARY 矩阵行数读取为 0

**关键变更**：

| 位置 | Old | New | 理由 |
|------|-----|-----|------|
| 第 15-16 行附近 | `read.csv(..., nrows=0)` | `read.csv(...)`（移除 nrows=0） | 修复 bug：完整读取矩阵以获取全部 1434 个蛋白行名 |
| 第 27-30 行附近 | 无断言 | `stopifnot(length(tested_prots) == 1434)` | 文档化预期：重跑后核验 universe 总数 |
| 第 128-133 行附近 | 无断言 | 4 条 stopifnot：1434 / 1414 / 15 / 5 | 文档化预期：重跑后核验 mapping universe 分布 |

**预期值**：tested=1434 / mapped(unambiguous)=1414 / multi-gene ambiguous=15 / unmapped=5
**说明**：所有 assertions 为重跑后预期核验值，脚本本轮未运行。

**修复笔记**：`descriptive/analysis_v2.0/M12_pathway_v2.1/M12_MAPPING_REPAIR_NOTE.md`

---

### P18: P3.py 安全修复

**文件路径**：`code/P3.py`
**备份位置**：`code/P3.py.orig.bak`

**静态一致性确认**：
- P1.py：`INPUT_FILE = ../rawdata/processed.xlsx` → `OUTPUT_FILE = ../rawdata/sample_mapping_audit.xlsx`
- P3.py：`INPUT_FILE = ../rawdata/processed.xlsx` + `AUDIT_FILE = ../rawdata/sample_mapping_audit.xlsx` → `OUTPUT_FILE = ../rawdata/sample_mapping_FINAL.xlsx`
- 结论：引用链一致，processed.xlsx ↔ P1 audit 静态一致。

**关键变更**：

| 位置 | Old | New | 理由 |
|------|-----|-----|------|
| 第 1-6 行 | 无 hashlib import | 新增 `import hashlib` | 支持 SHA256 provenance 计算 |
| 第 15 行后 | 仅 OUTPUT_FILE | 新增 PROVENANCE_FILE 路径 + sha256_file() + check_and_record_provenance() 函数 | [P18 FIX] Source identity contract：运行期计算 processed.xlsx 与 audit 的 SHA256，写入 provenance 文件；已存在则校验一致性，不一致则 fatal error |
| 第 16 节后 | 无 provenance 校验 | 执行 `check_and_record_provenance()` | 在任何处理前执行 provenance gate |
| 第 652-686 行后 | mapping_pass 仅打印结果，仍写 FINAL | 新增 `if not mapping_pass: raise RuntimeError(...)` | [P18 FIX] Validation gate：所有映射门校验失败则 fatal error 且不写 FINAL；全部 PASS 才写 |

**Hash contract 说明**：
- 旧 provenance 无历史 hash，未伪造历史 hash
- 新 contract 为"未来可执行"：首次运行计算并记录 SHA256 到 `../rawdata/sample_mapping_provenance.txt`
- 后续运行自动校验，不一致则 fatal 拒绝写入

---

### P19: v21_common.R 删除安全

**文件路径**：`descriptive/v21_common.R`
**备份位置**：`descriptive/v21_common.R.orig.bak`

**静态确认结果**：存在 recursive delete helper — `v21_output()` 函数（原第 37-50 行），第 43 行 `unlink(path, recursive = TRUE, force = TRUE)` 可递归删除任意传入目录。

**关键变更**：

| 位置 | Old | New | 理由 |
|------|-----|-----|------|
| v21_output() 函数开头 | 直接检查文件类型后 unlink | 新增 5 层安全 guard：①resolve absolute path ②reject drive root ③reject project root ④reject outside project root ⑤reject parent traversal (..) | [P19 FIX] 防止递归删除误删项目根目录、驱动器根或外部路径 |

**Guard 逐条说明**：
1. `normalizePath(path, mustWork=FALSE)` — 解析为绝对路径
2. `grepl("^[A-Za-z]:/$", abs_path)` — 拒绝驱动器根（如 `F:/`）
3. `tolower(abs_path) == tolower(project_root)` — 拒绝项目根目录本身
4. `!startsWith(tolower(abs_path), tolower(paste0(project_root, "/")))` — 拒绝项目根外部路径
5. `grepl("\\.\\./", abs_path) || grepl("/\\.\\.", abs_path)` — 拒绝父目录遍历

**说明**：未对真实项目目录运行 destructive test。

---

### P20: D10 unique-peptide 传播移除

**文件路径**：`descriptive/discovery_validation/code/D10_integrated_biology.R`
**备份位置**：`descriptive/discovery_validation/code/D10_integrated_biology.R.orig.bak`

**静态确认结果**：发现 unique-peptide 传播至 canonical outputs：
- 第 17 行：files 列表包含 D09_peptide = unique_peptide_support.csv
- 第 163-169 行：读取 D09 peptide 文件，提取 Unique_peptide_count / Single_unique_peptide / Peptide_support_status
- 第 179 行：`add_locked_summary(master, d09_peptide_summary, "D09 peptide")` merge 到 master
- 第 205 行：master 写入 `D10_integrated_candidate_evidence.csv`（新 canonical 输出）

**关键变更**：

| 位置 | Old | New | 理由 |
|------|-----|-----|------|
| files 向量（第 9-18 行） | 包含 D09_peptide 条目 | 注释掉 D09_peptide 条目，加 v2.1 protocol 说明 | [P20 FIX] unique-peptide 不进入新 canonical outputs |
| 第 163-169 行 | d09_peptide 读取与 summary 创建 | 整段注释掉，加 HISTORICAL_ONLY 说明 | 移除传播：不再读取 unique-peptide 字段 |
| 第 179 行 | `master <- add_locked_summary(master, d09_peptide_summary, "D09 peptide")` | 注释掉该行 | 移除传播：不再 merge 到 canonical master 表 |

**说明**：历史输出文件保留在磁盘上（HISTORICAL_ONLY），仅从新 canonical 输出传播链中移除。

---

### P21: M14 reconciliation 动态化 + stale 清理

**文件 1**：`descriptive/analysis_v2.0/code/V2_M13_M14_reconciliation.R`
**备份位置**：`descriptive/analysis_v2.0/code/V2_M13_M14_reconciliation.R.orig.bak`

**静态确认结果**：第 32 行 hard-code `n = c(85, 85, 83, 29, 1)`。

**关键变更（R 脚本）**：

| 位置 | Old | New | 理由 |
|------|-----|-----|------|
| M14 data.frame n 值 | `n = c(85, 85, 83, 29, 1)` hard-code | 从 D08_validation_results.csv 动态读取计数：n_locked_d03 = nrow(d08), n_estimable = sum(Model_status=="ESTIMABLE"), n_same_dir = sum(Direction_concordant==TRUE), n_nominal = sum(Nominal_replication==TRUE), n_fdr = sum(FDR_supported_replication==TRUE) | [P21 FIX] 改为动态派生，派生源：discovery_validation/D08_validation/D08_validation_results.csv；数字本身不变（预期仍为 85/85/83/29/1） |
| aux data.frame Pathway 状态 | `"NOT_RUN_NO_APPROVED_MAPPING"` | `"BLOCKED_PENDING_RERUN"` | [P21 FIX] 反映实际 M12 状态：M12 v2.1 已产出 195/23/39 但 M12=BLOCKED，KEGG=NOT_RUN |
| aux data.frame ML M15 状态 | `"NOT_STARTED"` | `"fixed-85 ML=P0_REPAIRED / strict nested=REPAIR_PENDING"` | [P21 FIX] 按模块级权威状态更新 |

**文件 2**：`descriptive/analysis_v2.0/M14_frozen_replication/M14_frozen_status.csv`
**备份位置**：`descriptive/analysis_v2.0/M14_frozen_replication/M14_frozen_status.csv.orig.bak`

**关键变更（CSV 状态字段）**：

| 行号 | 字段 | Old | New |
|------|------|-----|-----|
| 第 3 行 | Pathway (frozen D10).status | NOT_RUN_NO_APPROVED_MAPPING | BLOCKED_PENDING_RERUN |
| 第 4 行 | ML M15.status | NOT_STARTED | fixed-85 ML=P0_REPAIRED / strict nested=REPAIR_PENDING |

**说明**：仅修改这两个状态字段行，其余行（Peptide evidence、ML M16）未触碰。

---

## 备份文件汇总

| 原文件 | 备份路径 |
|--------|----------|
| M12_01_mapping.R | `descriptive/analysis_v2.0/M12_pathway_v2.1/M12_01_mapping.R.orig.bak` |
| P3.py | `code/P3.py.orig.bak` |
| v21_common.R | `descriptive/v21_common.R.orig.bak` |
| D10_integrated_biology.R | `descriptive/discovery_validation/code/D10_integrated_biology.R.orig.bak` |
| V2_M13_M14_reconciliation.R | `descriptive/analysis_v2.0/code/V2_M13_M14_reconciliation.R.orig.bak` |
| M14_frozen_status.csv | `descriptive/analysis_v2.0/M14_frozen_replication/M14_frozen_status.csv.orig.bak` |

---

## 未运行说明

本轮所有修复均为静态代码修复与注释，未执行任何 R/Python 脚本。所有 assertions、动态计数、provenance hash 计算均为"重跑后预期"，未经实际运行核验。
