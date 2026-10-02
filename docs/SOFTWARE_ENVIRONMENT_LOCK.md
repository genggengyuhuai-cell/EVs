# Software Environment Lock

> 日期：2026-10-02 (U3 closure update)
> 说明：repaired pipeline 实际依赖版本。不升级不 install；查不到则 NOT_RECOVERABLE_FROM_PROJECT_PROVENANCE。
> R 包版本于 2026-10-02 通过 `packageVersion()` 在同一 R 4.3.1 安装中实测确认；
> Python 包版本引自仓库内 `descriptive/requirements.txt`（pinned）。

---

## 系统

| Component | Version | Used_by | Required_for_rerun | Source | Status |
|-----------|---------|---------|-------------------|--------|--------|
| OS | Windows x64 | All | Yes | System info | LOCKED |
| Shell | PowerShell 5.1 | All | Yes | System info | LOCKED |

## R 环境

| Component | Version | Used_by | Required_for_rerun | Source | Status |
|-----------|---------|---------|-------------------|--------|--------|
| R | 4.3.1 (2023-06-16 ucrt) | All R scripts | Yes | R.version.string | LOCKED |
| limma | 3.58.1 | cameraPR, eBayes | Yes | packageVersion 2026-10-02 | LOCKED |
| fgsea | 1.28.0 | fgseaMultilevel | Yes | packageVersion 2026-10-02 | LOCKED |
| org.Hs.eg.db | 3.18.0 | GO gene sets, mapping | Yes | packageVersion 2026-10-02 | LOCKED |
| GO.db | 3.18.0 | GO term names | Yes | packageVersion 2026-10-02 | LOCKED |
| reactome.db | 1.86.2 | Reactome gene sets | Yes | packageVersion 2026-10-02 | LOCKED |
| clusterProfiler | 4.10.1 | (辅助) | No | packageVersion 2026-10-02 | LOCKED |
| AnnotationDbi | 1.64.1 | GO/Reactome queries | Yes | packageVersion 2026-10-02 | LOCKED |
| data.table | 1.18.6.1 | Data processing | Yes | packageVersion 2026-10-02 | LOCKED |
| statmod | 1.5.0 | limma dependency | Yes | packageVersion 2026-10-02 | LOCKED |
| ggplot2 | 4.0.2 | Figure generation | For figures only | packageVersion 2026-10-02 | LOCKED |
| dplyr | 1.1.4 | Data manipulation | For figures only | packageVersion 2026-10-02 | LOCKED |
| impute | 1.76.0 | M09 KNN imputation | For M09 rerun only | packageVersion 2026-10-02 | LOCKED |
| glmnet | 5.0 | LASSO / Elastic Net ML | For ML rerun only | packageVersion 2026-10-02 | LOCKED |
| xgboost (R package) | 3.2.1.1 | XGBoost ML | For ML rerun only | packageVersion 2026-10-02 | LOCKED |
| logistf | 1.26.1 | Firth detection (M08) | For M08 rerun only | packageVersion 2026-10-02 | LOCKED |
| ranger | 0.18.0 | Random forest / Boruta-style | For ML rerun only | packageVersion 2026-10-02 | LOCKED |
| pROC | 1.19.0.1 | AUROC computation | For ML rerun only | packageVersion 2026-10-02 | LOCKED |

## Python 环境

| Component | Version | Used_by | Required_for_rerun | Source | Status |
|-----------|---------|---------|-------------------|--------|--------|
| Python | 3.14.7 (default interpreter) | P1.py, P2.py, P3.py | Yes (for P1-P3 only) | Orchestrator confirm 2026-10-01 | CONFIRMED |
| numpy | 2.4.6 | P1/P2/P3 | Yes (for P1-P3) | `descriptive/requirements.txt` | EVIDENCE_PINNED |
| pandas | 3.0.3 | P1/P2/P3 | Yes (for P1-P3) | `descriptive/requirements.txt` | EVIDENCE_PINNED |
| openpyxl | 3.1.5 | P1.py (xlsx reading) | Yes (for P1-P3) | `descriptive/requirements.txt` | EVIDENCE_PINNED |
| matplotlib | 3.11.1 | nature_plotting.py (upstream figures) | For upstream figures only | `descriptive/requirements.txt` | EVIDENCE_PINNED |
| scikit-learn | NOT_USED | ML is implemented in R | N/A | run_v2_1_ml.R uses R packages only | NOT_USED_IN_FROZEN_PIPELINE |
| xgboost (Python) | NOT_USED | XGBoost ML uses R package 3.2.1.1 | N/A | run_v2_1_ml.R `library(xgboost)` | NOT_USED_IN_FROZEN_PIPELINE |

> **U3 closure note (2026-10-02):** The frozen ML pipeline (fixed-85 and strict-nested) is implemented entirely in R (`library(glmnet)`, `library(xgboost)`, `library(ranger)`, `library(pROC)`). Python is required only for upstream raw-data processing (P1/P2/P3) and upstream descriptive figure generation. No separate venv/conda environment is referenced in the repository. Package versions above are either measured live via `packageVersion()` (R) or pinned in `descriptive/requirements.txt` (Python).

---

## Annotation 源版本说明

- **org.Hs.eg.db 3.18.0**: GO 注释来源。Annotation 源随 Bioconductor 版本变化。
- **GO.db 3.18.0**: GO term 名称定义。
- **reactome.db 1.86.2**: Reactome 通路基因集。

注意：当前所有 pathway 计数与上述 annotation 包版本绑定。若未来升级 Bioconductor 并重新运行，计数可能变化。

## RNG 种子

- M12 mapping / pathway: `set.seed(20260928, kind="Mersenne-Twister")`
- Discovery/validation split: `seed=20260925`
- fgsea: `eps=0`（精确计算，非 permutation 近似）
