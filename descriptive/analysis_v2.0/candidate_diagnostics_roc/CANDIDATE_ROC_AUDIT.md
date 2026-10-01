# Candidate ROC/AUC diagnostics — Audit

## Sample sizes
- Discovery (training): n=271 (High=132, Low=139).
- Validation (reused hold-out): n=91 (High=44, Low=47).

## Part A — Univariate AUCs

| Gene | Disc AUC (95% CI) | Val AUC (95% CI) | Direction | Concordant? |
|---|---|---|---|---|
| GOLGA3 | 0.693 (0.625–0.761) | **0.703** (0.582–0.824) | DOWN_IN_HIGH | YES |
| TSPAN14 | 0.681 (0.609–0.753) | 0.617 (0.481–0.754) | DOWN_IN_HIGH | YES |
| GAL | 0.653 (0.583–0.723) | 0.660 (0.537–0.782) | DOWN_IN_HIGH | YES |
| DMP1 | 0.662 (0.596–0.729) | 0.595 (0.474–0.715) | DOWN_IN_HIGH | YES |
| IGF1 | 0.622 (0.555–0.689) | 0.539 (0.416–0.662) | DOWN_IN_HIGH | YES |
| CSF1 | 0.639 (0.573–0.705) | 0.631 (0.513–0.749) | DOWN_IN_HIGH | YES |

### Observations (descriptive only)
- **All 6 direction-concordant** (DOWN_IN_HIGH in both Discovery and Validation) — no sign flip.
- **GOLGA3** is the strongest univariate signal: Disc=0.693, Val=0.703 (validation AUC actually slightly higher; best single-gene separation).
- **GAL** is stable: Disc=0.653 → Val=0.660 (no drop).
- **IGF1** drops the most: Disc=0.622 → Val=0.539 (near chance in validation).
- **DMP1** also drops: 0.662 → 0.595.
- **TSPAN14** moderate drop: 0.681 → 0.617.
- **CSF1** (SVM-specific): Disc=0.639 → Val=0.631, essentially flat — the SVM-RFE signal is directionally consistent but weak as a univariate discriminator.
- None of the validation 95% CIs excludes 0.5; these are diagnostic separations, not confirmed biomarkers.

## Part B — Multigene logistic AUCs

| Model | Genes | N | Disc AUC | Val AUC | AUC drop | Val acc @ disc cutoff |
|---|---|---|---|---|---|---|
| M1 | GOLGA3+TSPAN14 | 2 | 0.733 | 0.651 | 0.082 | 0.586 |
| M2 | +GAL | 3 | 0.741 | **0.685** | **0.056** | **0.654** |
| M3 | +DMP1+IGF1 (Tier1) | 5 | 0.769 | 0.633 | 0.136 | 0.583 |
| M4 | CSF1+GOLGA3+TSPAN14 | 3 | 0.733 | 0.652 | 0.081 | 0.569 |
| M5 | all 6 | 6 | 0.778 | 0.614 | **0.164** | 0.521 |

### Observations
- **Best validation AUC: M2 (3-gene, GOLGA3+TSPAN14+GAL) = 0.685**, with the smallest AUC drop (0.056) and best validation accuracy at the discovery cutoff (0.654).
- **Adding DMP1+IGF1 (M3, full Tier1) raises training AUC to 0.769 but validation drops to 0.633** — overfitting pattern; the 2-gene/3-gene core generalizes better than the 5-gene Tier1.
- **Adding CSF1 (M4 vs M1): essentially no change** (0.651 → 0.652). Adding CSF1 to the full set (M5) makes the drop worse (0.164, validation AUC 0.614) — adding more genes increases overfit.
- The 4-way consensus pair (GOLGA3+TSPAN14) alone gives validation AUC 0.651; adding GAL is the sweet spot.
- No multigene model reaches AUC > 0.70 in validation; all remain in the "weak-to-moderate diagnostic separation" range.

## Process checks
- Frozen `ml_v2.1/` outputs modified: **NO**.
- New discovery / ML rerun: **NO** (standard glm on Discovery only, reporting-only).
- Post-hoc threshold tuning: **NO** (Youden on Discovery, frozen model sets M1–M5).
- `git diff --cached --check`: exit 0.

## Overlay redraw (style change only)
Overlay-style figures were added; underlying AUCs are unchanged.

### Files added
- `Candidate_ROC_Overlay_Train_Validation.pdf` / `.png` / `.svg` — univariate overlay
- `Multigene_ROC_Overlay_Train_Validation.pdf` / `.png` / `.svg` — multigene overlay
- `run_candidate_roc_overlay.R`

### Layout
- Two panels side by side: Panel C = Discovery / training (n=271, High=132, Low=139); Panel D = Validation / reused hold-out (n=91, High=44, Low=47).
- Each panel overlays the 6 ROC curves, gray dashed chance diagonal, square 0–1 axes, `x = 1 - Specificity`, `y = Sensitivity`, right-side legend titled **Gene name (AUC)** with line colors matching the curves.
- Same gene → same color across both panels (GOLGA3, TSPAN14, GAL, DMP1, IGF1, CSF1). Legend sorted by Validation AUC descending.
- Multigene overlay legend format: **Model (AUC)** for M1–M5.
- ROC curves plotted in the favorable discrimination direction (pROC `direction="auto"`), so higher AUC consistently reflects better High-vs-Low separation.

### AUC verification
AUCs were recomputed from the identical frozen abundance data and compared to the previously reported summary; all matched (tolerance 0.002 for univariate, 0.005 for multigene), so no value was silently changed:

| Set | Verified match? |
|---|---|
| Univariate Discovery (0.693/0.681/0.653/0.662/0.622/0.639) | YES |
| Univariate Validation (0.703/0.617/0.660/0.595/0.539/0.631) | YES |
| Multigene Discovery (0.733/0.741/0.769/0.733/0.778) | YES |
| Multigene Validation (0.651/0.685/0.633/0.652/0.614) | YES |

All original figures and summary outputs were preserved; no existing file was overwritten. This was a pure figure-presentation change: no discovery, no ML, no candidate redefinition, no frozen output modification.
