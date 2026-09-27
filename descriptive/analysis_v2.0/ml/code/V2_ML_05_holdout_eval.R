# V2_ML_05_holdout_eval.R — One-time hold-out evaluation guard (NOT executed)
# This file implements hard guards. No evaluation runs in V2-04.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")
source("descriptive/analysis_v2.0/ml/code/V2_ML_01_prepare.R")

HOLDOUT_LOCK_MARKER <- V2_ML_HOLDOUT_LOCK_PATH

#' Guard: check that hold-out evaluation can run
assert_holdout_eval_authorized <- function() {
  # 1. Hold-out must not have been evaluated before
  if (file.exists(HOLDOUT_LOCK_MARKER)) {
    stop("HOLD-OUT EVALUATION ALREADY COMPLETED. ",
         "Marker exists: ", HOLDOUT_LOCK_MARKER,
         "\nAny re-evaluation requires explicit investigator override.")
  }

  # 2. Active model, manifest and lock marker must exist and agree by SHA.
  assert_valid_primary_lock()

  invisible(TRUE)
}

#' Run hold-out evaluation (NOT executed in V2-04)
#'
#' Will:
#' - Load locked model
#' - Load 129 hold-out abundance (mapped to locked features)
#' - Predict probabilities (no refitting)
#' - Compute AUROC, AUPRC, calibration, Brier
#' - Bootstrap 2000 replicates, seed 20260930
#' - Write results
#' - Write HOLDOUT_EVALUATION_LOCK marker
run_holdout_evaluation <- function() {
  assert_holdout_eval_authorized()
  stop("HOLD-OUT EVALUATION REQUIRES SEPARATE INVESTIGATOR AUTHORIZATION.",
       call.=FALSE)
}

#' Write the immutable hold-out evaluation lock marker
#' Called ONLY after successful first hold-out evaluation
write_holdout_lock_marker <- function(results_hash) {
  if (file.exists(HOLDOUT_LOCK_MARKER)) {
    stop("Hold-out lock marker already exists. Do not overwrite.")
  }
  marker_text <- paste0(
    "HOLD-OUT EVALUATION COMPLETED\n",
    "Timestamp: ", format(Sys.time(), "%Y-%m-%d %H:%M:%S %Z"), "\n",
    "Results SHA-256: ", results_hash, "\n",
    "Re-evaluation requires explicit investigator override.\n"
  )
  dir.create(dirname(HOLDOUT_LOCK_MARKER), showWarnings=FALSE, recursive=TRUE)
  writeLines(marker_text, HOLDOUT_LOCK_MARKER)
  invisible(TRUE)
}
