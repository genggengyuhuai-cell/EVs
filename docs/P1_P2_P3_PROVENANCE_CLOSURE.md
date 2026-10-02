# P1/P2/P3 Provenance Closure Report

> 日期：2026-10-01 (Phase 7)
> 范围：sample mapping 三脚本的 hash 合同与 fail-closed 状态

---

## 状态总览

| Script | Hash bound | Fail-closed on mismatch | Canonical output write protected | Guard repair done | Backup |
|--------|-----------|------------------------|----------------------------------|-------------------|--------|
| P1.py | YES (Phase7 added) | YES (raise RuntimeError before write) | YES (exception before OUTPUT write) | YES (this phase) | P1.py.phase7.bak |
| P2.py | YES (Phase7 added) | YES (raise RuntimeError before write) | YES (exception before OUTPUT write) | YES (this phase) | P2.py.phase7.bak |
| P3.py | YES (P18 already done) | YES (raise RuntimeError + validation gates) | YES (provenance + validation gates both fail-closed) | NO (already done in P18) | P3.py.orig.bak |

---

## P1.py 详细

**修复内容**:
- 新增 `import hashlib`
- 新增 `PROVENANCE_FILE = Path("../rawdata/sample_mapping_provenance.txt")`
- 新增 `sha256_file()` 函数
- 新增 `check_and_record_provenance_p1()` 函数：
  - 计算 processed.xlsx 的 SHA256
  - 若 provenance 文件已存在 → 校验 hash 一致性，不一致则 raise RuntimeError（fail closed）
  - 若不存在 → 首次运行记录 hash 到 provenance 文件（forward-looking contract）
- 在所有处理前执行 `check_and_record_provenance_p1()`

**边界说明**:
- 旧 provenance 无历史 hash，未伪造历史 hash
- contract 为"未来可执行"：首次运行记录，后续运行校验
- 备份: `code/P1.py.phase7.bak`

---

## P2.py 详细

**修复内容**:
- 新增 `import hashlib`
- 新增 `PROVENANCE_FILE = Path("../rawdata/sample_mapping_provenance.txt")`
- 新增 `sha256_file()` 函数
- 新增 `check_provenance_p2()` 函数：
  - 计算 sample_mapping_audit.xlsx 的 SHA256
  - 若 provenance 文件已存在 → 校验 audit.xlsx hash 与记录值一致，不一致则 raise RuntimeError
  - 若不存在 → 打印 warning（不阻断，因 P1 可能尚未运行）
- 在读取 audit 文件前执行 `check_provenance_p2()`

**备份**: `code/P2.py.phase7.bak`

---

## P3.py 详细（P18 已完成，本轮核实现状）

**现有状态**:
- 已有 `import hashlib`（P18 添加）
- 已有 `PROVENANCE_FILE` + `sha256_file()` + `check_and_record_provenance()`
- 已在任何处理前执行 provenance gate
- 已有 validation gates（mapping_pass 失败则 raise RuntimeError，不写 FINAL）
- Hash bound: YES (processed.xlsx + audit.xlsx)
- Fail-closed: YES (provenance mismatch → RuntimeError; validation fail → RuntimeError)
- Canonical output protected: YES (both gates fail before writing FINAL)

**备份**: `code/P3.py.orig.bak`（P18 轮次备份）

---

## 引用链一致性确认

```
processed.xlsx → [P1.py] → sample_mapping_audit.xlsx → [P2.py] → sample_mapping_ambiguous_context.xlsx
                           ↘ [P3.py] ↗                          ↓
                               ↓
                    sample_mapping_FINAL.xlsx
```

- P1.py INPUT: processed.xlsx → OUTPUT: sample_mapping_audit.xlsx ✅
- P2.py INPUT: sample_mapping_audit.xlsx → OUTPUT: sample_mapping_ambiguous_context.xlsx ✅
- P3.py INPUT: processed.xlsx + sample_mapping_audit.xlsx → OUTPUT: sample_mapping_FINAL.xlsx ✅

引用链完整，无断链。
