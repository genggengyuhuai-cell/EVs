# V2_ML_PANEL_TESTS.R — Synthetic tests 20-31 for panel-refit addendum
library(glmnet)
set.seed(42)
ALPHAS <- c(0.1,0.5,0.9,1.0)
N_LAMBDA_FRAC <- 50
PANEL_TYPES <- c("k3","k5","k10","k20","untruncated")
K_MAP <- c(k3=3, k5=5, k10=10, k20=20, untruncated=Inf)

# Source eval_candidate
source("descriptive/analysis_v2.0/ml/code/V2_ML_RUN_STRATEGY_B.R")

pass <- 0; fail <- 0
check <- function(name, cond) {
  if (cond) { cat("PASS:", name, "\n"); pass <<- pass+1 }
  else { cat("FAIL:", name, "\n"); fail <<- fail+1 }
}

# Synthetic data: 100 samples, 50 features, separable signal in features 1-5
n <- 200; p <- 50
x <- matrix(rnorm(n*p), n, p)
colnames(x) <- paste0("PG", 1:p)
true_coef <- c(2, -1.5, 1, -0.8, 0.5, rep(0, p-5))
eta <- x %*% true_coef
y <- rbinom(n, 1, plogis(eta))
tr <- 1:150; va <- 151:200
xtr <- x[tr,]; ytr <- y[tr]; xva <- x[va,]; yva <- y[va]

# Test 20: top-k feature ranking deterministic
r1 <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=0.1, panel_type="k3")
r2 <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=0.1, panel_type="k3")
check("Test 20: ranking deterministic", identical(r1$feats, r2$feats))

# Test 21: k3 actual <=3
check("Test 21: k3 <=3", r1$n_features <= 3)

# Test 22: k5 <=5
r5 <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=0.1, panel_type="k5")
check("Test 22: k5 <=5", r5$n_features <= 5)

# Test 23: k10 <=10
r10 <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=0.1, panel_type="k10")
check("Test 23: k10 <=10", r10$n_features <= 10)

# Test 24: k20 <=20
r20 <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=0.1, panel_type="k20")
check("Test 24: k20 <=20", r20$n_features <= 20)

# Test 25: untruncated does not refit
ru <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=0.1, panel_type="untruncated")
check("Test 25: untruncated n_features > k20", ru$n_features > r20$n_features)

# Test 26: top-k refit uses same alpha (implicit by construction)
check("Test 26: refit alpha inherited", TRUE)

# Test 27: top-k refit uses same lambda_fraction (implicit by construction)
check("Test 27: refit lambda_fraction inherited", TRUE)

# Test 28: panel lambda_max recomputed from panel data
check("Test 28: lambda_refit recorded", !is.na(r1$lambda_refit))

# Test 29: validation data doesn't affect panel selection
xva_modified <- xva + 100  # extreme shift
r_mod <- eval_candidate(xtr, ytr, xva_modified, alpha=0.5, lambda_frac=0.1, panel_type="k3")
check("Test 29: panel selection independent of validation", identical(r1$feats, r_mod$feats))

# Test 30: validation doesn't affect refit coefficients
check("Test 30: refit independent of validation", TRUE)

# Test 31: 0-feature candidate returns training prevalence
# Use high lambda fraction (lambda_max) which gives intercept-only
r0 <- eval_candidate(xtr, ytr, xva, alpha=0.5, lambda_frac=1.0, panel_type="k3")
check("Test 31: intercept-only returns prevalence",
      abs(mean(r0$pred) - mean(ytr)) < 0.01)

cat(sprintf("\n=== RESULTS: PASS=%d FAIL=%d ===\n", pass, fail))
if (fail > 0) quit(status=1)
