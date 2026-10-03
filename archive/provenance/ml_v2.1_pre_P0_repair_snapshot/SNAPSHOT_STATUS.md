# HISTORICAL_INVALIDATED_BY_P0_REPAIR

These files are the pre-repair fixed-85 ML outputs and reporting metadata.

- The Elastic Net results are invalidated because AUC-based alpha selection used the wrong direction.
- The XGBoost outer-CV results are invalidated because the outer test set was used for early stopping.
- The LASSO and Boruta implementations were not implicated, but their copied values are retained here only as historical context for the same run.
- These files must not be used as current results.
- `outer_cv_en_metrics_reconstructed.csv` was reconstructed with the historical
  erroneous EN selection logic and the unchanged outer splits solely to provide
  the requested old-versus-new EN AUROC comparison; it was not an original output.
