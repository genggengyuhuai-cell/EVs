# ML Dependency Audit

**Date:** 2026-09-27
**R version:** 4.3.x (Windows)

## Available packages

| Package | Required for | Status |
|---|---|---|
| glmnet | Elastic Net logistic regression | AVAILABLE |
| pROC | AUROC calculation | AVAILABLE |
| limma | Strategy A fold-local screening | AVAILABLE |
| readxl | Reading processed.xlsx | AVAILABLE |
| dplyr | Data manipulation | AVAILABLE |
| tidyr | Data reshaping | AVAILABLE |
| ggplot2 | Figure generation | AVAILABLE |
| boot | Bootstrap CIs | AVAILABLE |
| digest | SHA-256 provenance | AVAILABLE |

## Missing packages

| Package | Required for | Status | Action |
|---|---|---|---|
| PRROC | AUPRC calculation | NOT INSTALLED | Install before ML execution, OR use pROC::auc(direction=...) / custom AUPRC |

## Notes

- pROC can compute AUC; AUPRC (area under precision-recall) can be computed manually
  or via the `PRROC` package. Recommend installing PRROC before ML execution.
- No other dependencies identified for the locked ML spec.
- No package installation performed at this stage (per instruction).