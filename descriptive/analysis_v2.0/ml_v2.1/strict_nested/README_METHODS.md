# Repaired strict nested sensitivity — methods

Status: POST_PHASE2_REPAIR_CURRENT.

Each unchanged outer split starts from 3,817 raw protein groups. Within outer train only, finite positive detection is recomputed separately in High and Low and both must reach 70%. Eligible raw quantities are log2-transformed without imputation and fitted with an Environment-adjusted limma model, High-minus-Low contrast, and eBayes(trend=TRUE, robust=TRUE). BH correction is within the fold-local eligible family and candidates require BH-FDR<0.05. No rescue rule is used.

After selection, outer-train medians, centers and scales are fitted for ML and applied unchanged to outer test. A deterministic outcome-stratified five-fold foldid is explicitly passed to all LASSO and Elastic Net cv.glmnet calls.
