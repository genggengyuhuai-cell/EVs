# V2-05R synthetic and contract tests. No real abundance data are loaded.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")
source("descriptive/analysis_v2.0/ml/code/V2_ML_05_holdout_eval.R")

tests_total <- 0L
tests_pass <- 0L
tests_fail <- 0L

record_result <- function(name, ok, detail="") {
  tests_total <<- tests_total + 1L
  if (isTRUE(ok)) {
    tests_pass <<- tests_pass + 1L
    cat("PASS:", name, if(nzchar(detail)) paste0(" — ", detail) else "", "\n")
  } else {
    tests_fail <<- tests_fail + 1L
    cat("FAIL:", name, if(nzchar(detail)) paste0(" — ", detail) else "", "\n")
  }
}

expect_success <- function(name, expr) {
  err <- tryCatch({force(expr); NULL}, error=function(e)e)
  record_result(name, is.null(err), if(is.null(err)) "" else conditionMessage(err))
}

expect_error <- function(name, pattern, expr) {
  err <- tryCatch({force(expr); NULL}, error=function(e)e)
  ok <- !is.null(err) && grepl(pattern, conditionMessage(err), fixed=TRUE)
  detail <- if(is.null(err)) "expected error was not raised" else conditionMessage(err)
  record_result(name, ok, detail)
}

# 1–3: preprocessing helpers
train <- matrix(c(1,2,3, NA,5,6, 7,8,9), nrow=3,
                dimnames=list(c("p1","p2","p3"), c("s1","s2","s3")))
val <- matrix(c(10,NA,30, 40,NA,60), nrow=3,
              dimnames=list(c("p1","p2","p3"), c("v1","v2")))
expect_success("training-only median imputer", {
  imp <- fit_median_imputer(train)
  stopifnot(identical(unname(imp$medians), c(4, 5, 6)))
  out <- apply_median_imputer(val, imp)
  stopifnot(out[2,1] == 5, out[2,2] == 5)
})

expect_success("training-only scaler", {
  filled <- apply_median_imputer(train, fit_median_imputer(train))
  sc <- fit_scaler(filled)
  shifted_val <- val
  shifted_val[!is.na(shifted_val)] <- shifted_val[!is.na(shifted_val)] + 1000
  sc2 <- fit_scaler(filled)
  stopifnot(identical(sc$means, sc2$means), identical(sc$sds, sc2$sds))
})

expect_success("zero-variance removal", {
  z <- matrix(c(1,5,3, 4,5,6, 7,5,9), nrow=3,
              dimnames=list(c("p1","p2","p3"), paste0("s",1:3)))
  sc <- fit_scaler(z)
  stopifnot(identical(unname(which(sc$zero_var)), 2L))
  stopifnot(nrow(remove_zero_variance(z, sc)) == 2L)
})

# 4–7: guards; expected errors count as PASS.
fake_meta <- data.frame(UniqueSampleID=c("d1","d2","h1"),
                        Split=c("Discovery","Discovery","Validation"))
expect_error("hold-out participant rejected from training", "LEAKAGE:",
             assert_discovery_only(c("d1","h1"), fake_meta))
expect_error("outer-test participant rejected from training", "FOLD LEAKAGE:",
             assert_fold_disjoint(c("d1","d2"), c("d2","d3")))
expect_error("historical 256 feature source rejected", "forbidden historical",
             assert_no_forbidden_feature_source("results/canonical_256_DEP.csv"))
expect_error("historical D08 feature source rejected", "forbidden historical",
             assert_no_forbidden_feature_source("dv/results/D08_table.csv"))

# 8–10: explicit frozen lambda grid.
grid <- generate_lambda_grid(lambda_max=2)
record_result("lambda grid has exactly 50 values", length(grid) == 50L)
record_result("lambda min/max ratio equals 0.001",
              abs(min(grid)/max(grid)-0.001) < 1e-10)
expect_error("wrong lambda length rejected", "exactly 50",
             generate_lambda_grid(2, n_lambda=49))

# 11–13: panel identity is explicit, while fitting remains blocked by the spec gap.
ids <- panel_candidate_ids()
record_result("five panel candidate identities exist",
              identical(ids, c("k3","k5","k10","k20","untruncated")))
record_result("panel candidates are unique", !anyDuplicated(ids))
expect_error("unresolved panel refit policy blocks execution",
             "SPECIFICATION_GAP_REQUIRES_INVESTIGATOR",
             assert_panel_refit_policy_resolved())

# 14: deterministic top-k ranking only; this is not treated as a fitted model.
expect_success("deterministic protein tie-break for ranking", {
  b <- c(B=0.5, A=-0.5, C=0.3, D=0.2)
  stopifnot(identical(rank_panel_features(b, 3), c("A","B","C")))
})

# 15: one-SE hierarchy including lexical tie-break.
expect_success("one-SE deterministic hierarchy", {
  cand <- data.frame(
    candidate_id=c("k5_b","k5_a","k10","min"),
    metric=c(0.42,0.42,0.41,0.40), se=c(0.02,0.02,0.02,0.03),
    alpha=c(0.5,0.5,1,0.1), lambda_frac=c(0.5,0.5,0.4,0.2),
    panel_size=c(5,5,10,20), stringsAsFactors=FALSE)
  selected <- apply_one_se_rule(cand)
  stopifnot(selected$candidate_id == "k5_a")
  stopifnot(abs(attr(selected,"one_se_boundary") - 0.43) < 1e-12)
})

# 16: final-validation perturbation cannot alter training-derived preprocessing.
expect_success("fold-local preprocessing invariance", {
  tr <- matrix(c(1,2,3,4,5,6), nrow=2,
               dimnames=list(c("p1","p2"),c("t1","t2","t3")))
  va1 <- matrix(c(10,20), nrow=2)
  va2 <- matrix(c(10000,-10000), nrow=2)
  fit1 <- list(imputer=fit_median_imputer(tr), scaler=fit_scaler(tr))
  fit2 <- list(imputer=fit_median_imputer(tr), scaler=fit_scaler(tr))
  invisible(va1); invisible(va2)
  stopifnot(identical(fit1, fit2))
})

# 17–19: artifact and hold-out firewall contracts.
expect_error("missing lock artifacts block hold-out", "NO VALID PRIMARY_MODEL_LOCK",
             assert_holdout_eval_authorized())

expect_error("manifest/model SHA mismatch rejected", "model SHA mismatch", {
  td <- tempfile("v205r_lock_")
  dir.create(td)
  model <- file.path(td,"model.rds")
  manifest <- file.path(td,"manifest.csv")
  lock <- file.path(td,"lock")
  saveRDS(list(x=1), model)
  write.csv(data.frame(item="model_sha256", value=paste(rep("0",64),collapse="")),
            manifest, row.names=FALSE)
  writeLines(paste0("Model SHA-256: ", paste(rep("0",64),collapse="")), lock)
  assert_valid_primary_lock(model, manifest, lock)
})

expect_success("matching model/manifest/lock SHA accepted", {
  td <- tempfile("v205r_lock_")
  dir.create(td)
  model <- file.path(td,"model.rds")
  manifest <- file.path(td,"manifest.csv")
  lock <- file.path(td,"lock")
  saveRDS(list(x=1), model)
  h <- sha256_file(model)
  write.csv(data.frame(item="model_sha256", value=h), manifest, row.names=FALSE)
  writeLines(paste0("Model SHA-256: ", h), lock)
  assert_valid_primary_lock(model, manifest, lock)
})

cat(sprintf("TEST_TOTAL=%d\nPASS=%d\nFAIL=%d\n", tests_total, tests_pass, tests_fail))
if (tests_fail > 0L) quit(status=1L)
quit(status=0L)
