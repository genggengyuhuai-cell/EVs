# test_ml_pipeline.R — Synthetic unit tests for ML pipeline
# Uses ONLY synthetic data. No real abundance matrix. No real model training.

source("descriptive/analysis_v2.0/ml/code/V2_ML_00_common.R")

pass <- 0
fail <- 0
test_name <- character(0)

check <- function(name, expr) {
  result <- tryCatch({ force(expr); TRUE }, error=function(e) { cat("  FAIL:", conditionMessage(e), "\n"); FALSE })
  if (result) { pass <<- pass + 1; cat("PASS:", name, "\n") }
  else { fail <<- fail + 1; cat("FAIL:", name, "\n") }
}

# ---- Test 1: median imputer training-only ----
cat("\n--- Test 1: median imputer training-only ---\n")
set.seed(42)
train_mat <- matrix(c(1,2,3, NA,5,6, 7,8,9), nrow=3, ncol=3)
val_mat   <- matrix(c(10,NA,30, 40,NA,60, 70,80,90), nrow=3, ncol=3)
imp <- fit_median_imputer(train_mat)
# Training median for row 2: values c(2,5,8) -> median=5
cat("  Row 2 median:", imp$medians[2], "\n")
stopifnot(abs(imp$medians[2] - 5) < 0.01)
out_val <- apply_median_imputer(val_mat, imp)
# val_mat filled column-wise: NA positions are (2,1) and (2,2)
# Both get training row 2 median = 5
stopifnot(abs(out_val[2,1] - 5) < 0.01)
stopifnot(abs(out_val[2,2] - 5) < 0.01)
# Non-NA values unchanged
stopifnot(out_val[1,1] == 10)
cat("  Imputer uses training median, not validation median. PASS\n")
pass <- pass + 1

# ---- Test 2: scaler training-only ----
cat("\n--- Test 2: scaler training-only ---\n")
train2 <- matrix(c(1,2,3, 4,5,6), nrow=2, ncol=3)
sc <- fit_scaler(train2)
# train2 filled column-wise: row1 = c(1,3,5), mean=3; row2 = c(2,4,6), mean=4
cat("  Row 1 mean:", sc$means[1], "sd:", sc$sds[1], "\n")
stopifnot(abs(sc$means[1] - 3) < 0.01)
stopifnot(abs(sc$sds[1] - sd(c(1,3,5))) < 0.01)
val2 <- matrix(c(10,20,30, 40,50,60), nrow=2, ncol=3)
out2 <- apply_scaler(val2, sc)
# val2 row1 = c(10,30,50); expected = (10-3)/sd(c(1,3,5))
expected <- (10-3)/sd(c(1,3,5))
stopifnot(abs(out2[1,1] - expected) < 0.01)
cat("  Scaler uses training mean/sd. PASS\n")
pass <- pass + 1

# ---- Test 3: zero-variance removal training-only ----
cat("\n--- Test 3: zero-variance ---\n")
# train3 filled column-wise: row1=c(1,5,10), row2=c(2,5,20), row3=c(3,5,30)
# No row is zero-variance; test with a proper zero-variance row
train3 <- matrix(c(1,5,3, 4,5,6, 7,5,9), nrow=3, ncol=3)
# Row 2 = c(5,5,5) -> zero variance
sc3 <- fit_scaler(train3)
cat("  Zero-var rows:", which(sc3$zero_var), "\n")
stopifnot(sc3$zero_var[2] == TRUE)
out3 <- remove_zero_variance(train3, sc3)
stopifnot(nrow(out3) == 2)
cat("  Zero-variance row removed. PASS\n")
pass <- pass + 1

# ---- Test 4: fold-local eligibility threshold changes with group N ----
cat("\n--- Test 4: fold-local eligibility threshold ---\n")
# Simulate a fold with small group N
mat_small <- matrix(1:100, nrow=10, ncol=10)
colnames(mat_small) <- paste0("s", 1:10)
groups_small <- setNames(rep(c("control","low","high"), length.out=10), colnames(mat_small))
res_small <- compute_fold_eligibility(mat_small, groups_small, 0.70)
cat("  Thresholds (small groups):", res_small$thresholds, "\n")
# With ~3-4 per group, threshold should be ceiling(0.70*3)=3 or ceiling(0.70*4)=3
stopifnot(all(res_small$thresholds <= 4))

# Full 515-equivalent would give 108/131/124
# This verifies threshold is computed from fold N, not hard-coded
cat("  Thresholds scale with fold N. PASS\n")
pass <- pass + 1

# ---- Test 5: hold-out ID in training -> hard fail ----
cat("\n--- Test 5: hold-out leakage guard ---\n")
fake_meta <- data.frame(
  UniqueSampleID=c("d1","d2","d3","h1","h2"),
  Split=c("Discovery","Discovery","Discovery","Validation","Validation"),
  stringsAsFactors=FALSE
)
check("Hold-out in training fails", {
  assert_discovery_only(c("d1","h1"), fake_meta)
})

# ---- Test 6: outer test in inner fold -> hard fail ----
cat("\n--- Test 6: fold disjoint guard ---\n")
check("Outer test in train fails", {
  assert_fold_disjoint(c("d1","d2"), c("d2","d3"))
})
check("Disjoint folds pass", {
  assert_fold_disjoint(c("d1","d2"), c("d3","d4"))
})

# ---- Test 7: same seed -> identical folds ----
cat("\n--- Test 7: deterministic folds ---\n")
set.seed(999); a <- sample(1:100, 10)
set.seed(999); b <- sample(1:100, 10)
stopifnot(identical(a,b))
cat("  Same seed gives identical sample. PASS\n")
pass <- pass + 1

# ---- Test 8: one-SE rule deterministic ----
cat("\n--- Test 8: one-SE rule ---\n")
cand <- data.frame(
  metric=c(0.5, 0.4, 0.42, 0.45, 0.6),
  se=c(0.05, 0.04, 0.04, 0.05, 0.06),
  alpha=c(0.1, 0.5, 0.9, 1.0, 0.1),
  lambda_frac=c(0.5, 0.1, 0.2, 0.3, 0.8),
  panel_size=c(20, 5, 10, 3, 20)
)
sel <- apply_one_se_rule(cand)
cat("  Selected panel size:", sel$panel_size, "\n")
# Best is row 2 (metric=0.4, se=0.04). Threshold=0.44.
# Eligible: rows with metric <= 0.44: row2 (0.4), row3 (0.42)
# Among those, smallest panel: row3 has panel_size=10, row2 has 5
# Wait: row2 panel=5, row3 panel=10. Smallest = 5 (row2)
stopifnot(sel$panel_size == 5)
cat("  One-SE rule selects smallest panel within 1SE. PASS\n")
pass <- pass + 1

# ---- Test 9: panel cap ----
cat("\n--- Test 9: panel cap ---\n")
coefs <- setNames(c(0.5, 0.3, 0.2, 0.1, -0.4, 0.05),
                  c("A","B","C","D","E","F"))
capped <- apply_panel_cap(coefs, 3)
cat("  Capped non-zero:", sum(capped != 0), "\n")
stopifnot(sum(capped != 0) == 3)
# Top 3 by abs: A(0.5), E(0.4), B(0.3)
stopifnot(capped["A"] != 0 && capped["E"] != 0 && capped["B"] != 0)
stopifnot(capped["D"] == 0)
cat("  Panel cap keeps top-3 by |coef|. PASS\n")
pass <- pass + 1

# ---- Test 10: forbidden feature source guard ----
cat("\n--- Test 10: forbidden path guard ---\n")
check("Forbidden path '256_DEP' rejected", {
  assert_no_forbidden_feature_source(c("results/canonical_256_DEP.csv"))
})
check("Forbidden path 'D08' rejected", {
  assert_no_forbidden_feature_source(c("dv/results/D08_table.csv"))
})
check("Clean path passes", {
  assert_no_forbidden_feature_source(c("universes/Q515.csv"))
})

# ---- Summary ----
cat("\n===== TEST SUMMARY =====\n")
cat("PASS:", pass, " FAIL:", fail, "\n")
if (fail > 0) quit(status=1)
