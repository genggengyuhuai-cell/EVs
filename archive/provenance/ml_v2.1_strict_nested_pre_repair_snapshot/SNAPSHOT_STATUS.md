# HISTORICAL_INVALIDATED_BY_METHOD_MISMATCH

These files are the pre-Phase-2 strict-nested outputs.

- Fold-local discovery used Welch t-tests rather than the D02-compatible Environment-adjusted limma estimator.
- The manifest claimed stratified five-fold inner CV, but `cv.glmnet` did not receive an explicit stratified `foldid`.
- The historical fold-local DEP range of 8–618 is `PRE_REPAIR_NOT_INTERPRETABLE_AS_PURE_RESAMPLING_INSTABILITY`.
- These files are retained only for the requested old-versus-new comparison and must not be used as current strict-nested results.
