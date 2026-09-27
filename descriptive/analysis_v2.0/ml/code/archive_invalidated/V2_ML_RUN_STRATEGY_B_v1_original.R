# V2_ML_RUN_STRATEGY_B.R — sole future primary Strategy B runner
#
# Recovery state: fail closed. No real-data model may run until the investigator
# freezes the coefficient-estimation rule for top-k panel candidates.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")
source("descriptive/analysis_v2.0/ml/code/V2_ML_01_prepare.R")

run_primary_strategy_b <- function(execution_authorized=FALSE) {
  if (!isTRUE(execution_authorized)) {
    stop("REAL STRATEGY B EXECUTION NOT AUTHORIZED IN V2-05R.", call.=FALSE)
  }
  assert_panel_refit_policy_resolved()
  stop("Strategy B execution remains unavailable until recovery QA is complete.",
       call.=FALSE)
}

if (sys.nframe() == 0L) {
  run_primary_strategy_b(execution_authorized=FALSE)
}
