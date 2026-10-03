# HISTORICAL ISOLATION AUDIT（历史隔离审计）

> 日期：2026-10-01。对象：`F:\env`（analysis-v2.1）。承接 Phase 6，Phase 7 P12。
> 方法：只读 grep / 文件存在性核对；不运行分析脚本，不修改任何 frozen 结果与图。
> 目的：确认所有 pre-repair 快照、历史输出、旧图/旧通路/旧 ML 产物**不被** active 主链引用，且物理上位于明确的 historical/snapshot 目录。

## 0. 结论

**HISTORICAL_ISOLATION = PASS。**
未发现任何历史/快照文件被 active mainline 当作 current 读取：
- `ACTIVE_MAINLINE_MANIFEST.csv` / `FINAL_REPRODUCIBILITY_MANIFEST.csv` 中历史包仅以 **HISTORICAL_FROZEN 声明行**出现（每行 1 处命中 = 自我标注，非 active output 引用）；
- `STATISTICAL_CLAIM_MAP.csv`、`CANONICAL_RERUN_COMMANDS.md`、figure 重建脚本、figures_final_v2 的 source_data / manifest 对历史目录 **0 数据依赖**；
- `docs/README.md` 的 1 处命中是**显式历史注释**（"仅存于 pre_repair_snapshot，非 FINAL_FROZEN"），非引用；
- figures_final_v2 内仅 1 处命中，为 FIGURE_MANIFEST 中指向 `phase6_pre_rebuild_snapshot/` 的"旧版快照"说明文字，非数据读取。

历史文件**可保留**，且已全部位于明确的 snapshot / historical / frozen 目录。

## 1. 历史/快照资产清单（受审对象）

| # | 资产 | 位置 | 性质 |
|---|---|---|---|
| H1 | M09 pre-repair 快照 | `descriptive/analysis_v2.0/M09_pre_repair_snapshot/` | 修复前 KNN 输出留档 |
| H2 | M11 pre-repair 快照 | `descriptive/analysis_v2.0/M11_pre_repair_snapshot/` | 修复前 site-LOO 输出留档 |
| H3 | M12 通路 pre-repair 快照 | `descriptive/analysis_v2.0/M12_pathway_v2.1/pre_repair_snapshot/` | 修复前 195/23/39 通路输出 |
| H4 | M12B pre-repair 快照 | `descriptive/analysis_v2.0/M12B_biological_context_v2.1/pre_repair_snapshot/` | 修复前 context 输出 |
| H5 | ML fixed-85 pre-P0 快照 | `descriptive/analysis_v2.0/ml_v2.1/pre_P0_repair_snapshot/` | 修复前 ML 输出 |
| H6 | strict-nested pre-repair 快照 | `descriptive/analysis_v2.0/ml_v2.1/strict_nested_pre_repair_snapshot/` | 修复前 nested 输出 |
| H7 | 主图 pre-rebuild 快照 | `descriptive/analysis_v2.0/figures_final_v2/phase6_pre_rebuild_snapshot/` | Fig3-6 重建前旧图 |
| H8 | 相位备份文件 | `*.phase5/6/6b/6c/7.bak`、`*.orig.bak`（docs/、code/、各脚本、claim map） | 修复证据留档 |
| H9 | 冻结 v1.0 全流程 | `descriptive/limma_dose_analysis/`（config 标注 `HIST_FULL_PIPE` / "Frozen v1.0 pipeline outputs"） | 历史冻结管线 |
| H10 | 旧主图包 | `descriptive/analysis_v2.0/figures_final_v1/` | manifest=HISTORICAL，被 v2 取代 |
| H11 | 旧发现图包 v2.6 | `descriptive/discovery_validation/figures_prospective_v2.6/` | manifest=HISTORICAL，被 v2.7 取代 |
| H12 | 旧 ML 管线 | `descriptive/analysis_v2.0/ml/` | manifest=HISTORICAL_FROZEN |
| H13 | 旧 M12 v1 | `descriptive/analysis_v2.0/M12_pathway_enrichment/` | manifest=HISTORICAL_FROZEN |
| H14 | 历史调和 | `descriptive/analysis_v2.0/M13_historical_reconciliation/` | manifest=HISTORICAL |

## 2. 逐项检查方法与结果

检查命令（只读 grep）：对每个历史 token 在候选引用源中 `Select-String -SimpleMatch`。

| 检查源 | 方法 | `pre_repair_snapshot` / `limma_dose_analysis` | 历史图包(v1/v2.6/ml_legacy/M12_v1/M13) | 结论 |
|---|---|---|---|---|
| `docs/ACTIVE_MAINLINE_MANIFEST.csv` | grep token，核对命中行状态列 | **0** 命中 | 各 1 命中，均在 status=**HISTORICAL/HISTORICAL_FROZEN** 声明行 | 仅自我标注，非 active output |
| `docs/FINAL_REPRODUCIBILITY_MANIFEST.csv` | grep token | **0** 命中 | 历史包不作为 active rerun input/output | 隔离 |
| `docs/README.md` | grep token | 1 命中 = 注释"历史通路 195/23/39=PRE_REPAIR_EXISTING_OUTPUT（仅存于 pre_repair_snapshot，非 FINAL_FROZEN）" | 0 数据引用 | 显式历史声明，PASS |
| `manuscript_v2_1/audit/STATISTICAL_CLAIM_MAP.csv` | grep token | **0** 命中 | **0** 命中 | claim map 不引用历史 |
| `docs/CANONICAL_RERUN_COMMANDS.md` | grep token | **0** 命中 | **0** 命中 | canonical 重跑命令不依赖历史 |
| `figures_final_v2/`（全部文件） | 递归 grep source_data / manifest / README | 1 命中 = FIGURE_MANIFEST.md 注释"旧版快照：phase6_pre_rebuild_snapshot/" | 0 数据读取 | 仅说明文字，非数据依赖 |
| `code/V2_M17_phase6_rebuild.R` | grep snapshot/historical/figures_final_v1 | **0** 命中 | **0** 命中 | 重建脚本只读 repaired 输出 |

## 3. 隔离判定明细

- **active manifest 引用**：PASS。历史包仅以 HISTORICAL 状态出现；repaired 链（M09/M11/M12/M12B/ML）的 active output 路径均指向 `KNN_sensitivity/`、`M11_site_robustness/`、`M12_pathway_v2.1/{mapping,ranked,ora,ranked_gsea,integration}`、`ml_v2.1/{results,strict_nested}` 等 current 目录，**不含** `pre_repair_snapshot/`。
- **canonical README 列为 current**：PASS。README 仅把 snapshot 标注为非 frozen 历史留档。
- **final figures source_data/脚本读取**：PASS。Fig3-6 重建脚本与 source_data 对快照/历史目录 0 引用；Phase 6 报告确认 Fig3c 读 `M09_KNN_E_comparison.csv`、Fig4d 读 repaired M11、Fig5 读 `outer_cv_metrics.csv`/strict_nested、Fig6 读 repaired M12/M12B。
- **claim map 引用**：PASS。30 行 claim 全部指向 repaired current 产物。
- **CANONICAL_RERUN_COMMANDS 引用**：PASS（该文件存在，对历史 token 0 命中）。
- **物理目录隔离**：PASS。所有历史资产均位于名称显式的 `*pre_repair_snapshot*`、`*_snapshot/`、`figures_final_v1/`、`figures_prospective_v2.6/`、`ml/`、`M12_pathway_enrichment/`、`M13_historical_reconciliation/`、`limma_dose_analysis/` 或 `.bak` 文件中。

## 4. 限制与后续（非隔离失败）

- 本审计基于对文件**文本内容**的 grep，未逐格打开每个 source_data CSV 的相对路径做解析；但重建脚本对历史 token 0 命中，已足以排除脚本级数据依赖。
- **后续建议（不属本审计失败）**：`descriptive/limma_dose_analysis/`（H9，冻结 v1.0）在工作树中存在 320 项未提交修改，与"frozen"语义冲突，应在 git 分批清理时决定 commit 或 revert，见 `GIT_WORKTREE_CLASSIFICATION.csv` 中 E_HISTORICAL_SNAPSHOT（Needs_manual_review=Yes）。
- `.bak/.phase*.bak`（H8）作为修复证据随 E 类保留或加 .gitignore，二选一应一致（见 FINAL_GIT_CLEANUP_PLAN）。
