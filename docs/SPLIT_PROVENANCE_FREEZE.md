# Discovery / Validation Split Provenance Freeze

> 日期：2026-10-01 (Phase 7)
> 结论：REUSED_FROZEN_SPLIT

---

## Split 文件身份

| 项目 | 值 |
|------|-----|
| 主文件 | `descriptive/discovery_validation_split/discovery_validation_assignment.csv` |
| SHA256 | `062E51026B7420DCA2077D5807BFDAA760AC08AC5F19A9AF98CF89DA2B7B6791` |
| 大小 | 74,462 bytes |
| 样本总数 | 515 |
| Discovery n | 386 |
| Validation (holdout) n | 129 |

## 生成参数（来自 split_manifest.txt）

| 项目 | 值 |
|------|-----|
| Protocol_version | DiscoveryValidationProtocol_v1.0 |
| Seed | 20260925 |
| RNG_kind | Mersenne-Twister |
| R_version | 4.3.1 (2023-06-16 ucrt) |
| Assignment_algorithm | canonical ASCII/UTF-8-byte ID sort; one global RNG stream; six strata in frozen order |
| Permutation_calls | 6 |
| Creation_timestamp | 2026-09-26 01:09:30 PDT |

## 六层分层计数（Discovery / Validation）

| Stratum | Discovery | Validation |
|---------|-----------|------------|
| Humid-hot / Control | 71 | 24 |
| Humid-hot / Short | 62 | 21 |
| Humid-hot / Long | 76 | 25 |
| High-altitude / Control | 44 | 14 |
| High-altitude / Short | 77 | 26 |
| High-altitude / Long | 56 | 19 |
| **合计** | **386** | **129** |

## Regeneration status

**REUSED_FROZEN_SPLIT**

- Split 由独立生成器（seed=20260925, R 4.3.1）生成于 2026-09-26
- 生成器脚本存在于项目中，理论上可重跑复现
- 但本轮（Phase 7）不重新生成 split
- Hash + sample membership 已锁定，后续所有分析必须使用此冻结 split
- 任何修改 split 的尝试都会导致 SHA256 不匹配，破坏下游所有结果的可复现性

## 相关文件

| 文件 | SHA256 | 说明 |
|------|--------|------|
| discovery_validation_assignment.csv | 062E5102...B6791 | 主 split 分配表 |
| split_manifest.txt | D48C6FD7...FCB64 | 生成参数 manifest |
| split_integrity_assertions.csv | E335528A...26FA70 | 完整性断言（26 PASS, 0 FAIL） |
