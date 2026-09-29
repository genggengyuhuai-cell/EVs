# V2_ML_04_lock_model.R — Final Discovery model lock contract (NOT executed)

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")
source("descriptive/analysis_v2.0/ml/code/V2_ML_01_prepare.R")

#' Guard: check that all prerequisites for final lock are met
#' @param fold_manifest_path path to V2_ML_FOLD_MANIFEST.csv
#' @param nested_cv_manifest_path path to nested CV results manifest
#' @param split_meta loaded split assignment
assert_lock_prerequisites <- function(fold_manifest_path, nested_cv_manifest_path,
                                       split_meta) {
  # 1. Fold manifest exists and is FROZEN
  if (!file.exists(fold_manifest_path)) stop("Fold manifest not found: ", fold_manifest_path)

  # 2. Nested CV manifest exists
  if (!file.exists(nested_cv_manifest_path)) stop("Nested CV manifest not found: ",
                                                  nested_cv_manifest_path)

  # 3. Discovery IDs = 386
  disc_ids <- split_meta$UniqueSampleID[split_meta$Split == "Discovery"]
  if (length(disc_ids) != 386) stop("Discovery N != 386: ", length(disc_ids))

  # 4. No hold-out in Discovery
  hold_ids <- split_meta$UniqueSampleID[split_meta$Split == "Validation"]
  if (length(intersect(disc_ids, hold_ids)) != 0) stop("Hold-out leakage into Discovery")

  # 5. Hold-out evaluation lock marker must NOT exist yet
  lock_marker <- "descriptive/analysis_v2.0/ml/models/HOLDOUT_EVALUATION_LOCK"
  if (file.exists(lock_marker)) {
    stop("Hold-out evaluation already completed. Cannot re-lock.")
  }

  invisible(TRUE)
}

#' Final model lock (NOT executed)
#'
#' Will:
#' - Fit selected pipeline on all 386 Discovery samples
#' - Seed: 20260929
#' - Save: feature IDs, coefficients, intercept, alpha, lambda,
#'         panel size, imputer parameters, scaler parameters
#' - Write immutable model SHA-256
final_lock_model <- function() {
  assert_panel_refit_policy_resolved()
  stop("Final lock is not implemented or authorized in V2-05R.", call.=FALSE)
}

#' Save locked model artifact
save_locked_model <- function(model_obj, path) {
  if (!identical(path, V2_ML_MODEL_PATH)) {
    stop("Model path violates active artifact contract: ", path)
  }
  # Guard: don't overwrite
  if (file.exists(path)) stop("Locked model already exists: ", path)
  saveRDS(model_obj, path)
  # Write hash
  h <- digest::digest(file=path, algo="sha256")
  writeLines(h, paste0(path, ".sha256"))
  invisible(TRUE)
}
