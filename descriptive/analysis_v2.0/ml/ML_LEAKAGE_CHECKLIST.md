# ML Data Leakage Checklist

**Must PASS before any ML model execution.**

## 129 hold-out exclusion

- [ ] Hold-out sample IDs do NOT appear in any training fold
- [ ] Hold-out not used for preprocessing (median, scaling)
- [ ] Hold-out not used for feature eligibility (Mfold)
- [ ] Hold-out not used for feature selection
- [ ] Hold-out not used for hyperparameter tuning
- [ ] Hold-out not used for threshold selection
- [ ] No hold-out performance inspected before model lock

## Fold-local preprocessing

- [ ] Imputation median computed on training fold only
- [ ] Scaling mean/SD computed on training fold only
- [ ] Zero-variance removal based on training fold only
- [ ] Strategy A limma screen runs on outer-training fold only
- [ ] Inner test fold excluded from screening
- [ ] Outer test fold excluded from screening

## No full-cohort preselection

- [ ] No full Discovery 386 preprocessing before CV split
- [ ] Historical 256 DEP list NOT used as ML feature screen
- [ ] Historical 85-candidate list NOT used as primary feature screen
- [ ] D08/D09/D10 results NOT used to alter model
- [ ] Full-cohort v2 E/LC/HC/HL results NOT used to alter Strategy B
- [ ] No combined Discovery+hold-out normalization (ComBat, quantile)

## CV structure

- [ ] Outer test fold never participates in inner hyperparameter tuning
- [ ] Inner fold assignment derived deterministically from repeat+outer fold
- [ ] Class stratification within Environment × Group
- [ ] Fold assignments saved to `folds/fold_assignments.csv`

## Model selection integrity

- [ ] Inner metric is mean log loss (not AUROC)
- [ ] Panel-size rule (one-SE + smallest median) applied automatically
- [ ] No manual panel substitution after CV
- [ ] No choosing Strategy A over B based on CV/hold-out results
- [ ] No seed search

## Final lock integrity

- [ ] Final model fit on all 386 with seed 20260929
- [ ] Locked coefficients saved
- [ ] Locked feature list saved
- [ ] Locked preprocessing parameters saved
- [ ] No post-lock feature substitution

## Hold-out evaluation integrity

- [ ] Evaluation runs once, after lock
- [ ] No refitting on hold-out
- [ ] No recalibration of predictions
- [ ] Bootstrap seed = 20260930, 2000 replicates
- [ ] Results not used to revise Discovery model