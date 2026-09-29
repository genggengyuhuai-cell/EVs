# V2_ML_03_nested_cv.R — Nested CV function architecture (NOT executed on real data)
# All functions are implemented but no real glmnet call happens here.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")
source("descriptive/analysis_v2.0/ml/code/V2_ML_01_prepare.R")

#' Run inner CV for one outer training fold
#' @param train_mat proteins x samples
#' @param train_y factor/labels
#' @param train_groups named vector
#' @param inner_folds data.frame with Inner_fold assignments
#' @param strategy "B" or "A"
#' @return data.frame of hyperparameter candidates with metric and SE
run_inner_cv <- function(train_mat, train_y, train_groups, inner_folds,
                         strategy="B") {
  # Placeholder: when executed, this will:
  # 1. For each inner fold:
  #    a. Compute fold-local eligibility on inner-train
  #    b. Fit imputer/scaler on inner-train
  #    c. Apply to inner-val
  #    d. If Strategy A: run limma screen on inner-train
  #    e. For each alpha x lambda_fraction: fit glmnet, predict, compute log loss
  # 2. Aggregate mean log loss and SE across inner folds
  # 3. Return candidate table
  #
  # NOT IMPLEMENTED FOR REAL in this stage.
  stop("run_inner_cv: not yet executed. This is architecture only.")
}

#' Evaluate a single hyperparameter on inner validation
evaluate_hyperparameter <- function(x_train, y_train, x_val, y_val,
                                     alpha, lambda) {
  # Placeholder
  stop("evaluate_hyperparameter: not yet executed.")
}

#' Apply one-SE rule to select best hyperparameter
#' @param candidates data.frame(metric, se, alpha, lambda_frac, panel_size)
select_hyperparameter <- function(candidates) {
  apply_one_se_rule(candidates)
}

#' Run one outer fold: train on outer-train, predict outer-test
run_outer_fold <- function(outer_train_mat, outer_train_y, outer_test_mat,
                           outer_test_y, inner_fold_assignments,
                           strategy="B") {
  # Placeholder: when executed:
  # 1. Run inner CV on outer_train
  # 2. Select best hyperparameter via one-SE rule
  # 3. Refit on full outer_train with selected params
  # 4. Predict outer_test
  # 5. Return out-of-fold predictions
  stop("run_outer_fold: not yet executed.")
}

#' Aggregate outer-fold results across repeats
aggregate_outer_results <- function(outer_results_list) {
  # Placeholder: average repeat-level metrics
  stop("aggregate_outer_results: not yet executed.")
}

#' Full nested CV runner (entrypoint, NOT called in this stage)
run_nested_cv <- function(abundance_mat, sample_groups, fold_outer, fold_inner,
                          strategy="B") {
  # Guards
  discovery_ids <- colnames(abundance_mat)
  assert_no_holdout_samples(discovery_ids, load_split_assignment())

  # This will loop over repeats and outer folds
  # NOT EXECUTED in V2-04
  stop("run_nested_cv: not yet executed. V2-04 only implements architecture.")
}
