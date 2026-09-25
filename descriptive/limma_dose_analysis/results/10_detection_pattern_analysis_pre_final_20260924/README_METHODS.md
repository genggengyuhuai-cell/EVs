# Detection models v2.1 — NOT limma and NOT quantitative abundance
Phenotype: finite raw quantity >0 =>1, otherwise 0. The upstream mother table retains all proteins.
Model universe: max(Control, Short, Long detection rate) >=60%; lower-rate proteins are not modelled.
Primary: detected ~ exposure + environment; standard maximum likelihood binomial logit.
Separation is checked before estimation using detectseparation; no penalized fallback.
Constant outcomes, separation, aliased designs, warnings/failures produce NA and explicit status.
Contrasts use coefficient covariance; Wald normal P and 95% OR intervals. No pseudo-counts.
BH: each model and contrast separately, n=the complete >=60% detection-analysis universe; failures keep NA.
The <20% rule is used only for restricted-pattern classification and never for universe retention.
Acquisition model uses eligible complete metadata; rank-deficient designs are reported, not altered.
Age/sex model runs only when both fields exist and at least 90% have usable joint metadata.
Literal Unknown/NA/missing values are recorded, excluded for model eligibility; numeric zero is not missing.
Acquisition_sensitive: sign reversal OR crossing BH 0.05 vs primary on the SAME acquisition-eligible cohort.
This is a diagnostic flag, not proof of technical confounding. Full-cohort direction concordance is separate.
Observational association, not biological absence or causal exposure effect.
Method reference: https://github.com/ikosmidis/detectseparation
