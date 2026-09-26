# DISCOVERY_VALIDATION_HANDOFF_2026-09-26_PAUSE

## 当前状态

项目根目录：`F:\env`

模块：`descriptive/discovery_validation`

当前 Discovery--Validation 主分析已经完成至 D10，并已完成 D08--D10
审计。当前阶段已经从统计分析转入 manuscript figure planning / figure
generation。

本窗口暂停点：**Figure scientific-content plan
已冻结；下一窗口不要重新设计 D01--D10，不要新增统计 endpoint。应从统一
manuscript figure module 开发开始。**

------------------------------------------------------------------------

## 已确认的 Git 分析 checkpoint

最近确认的分析提交：

``` text
d46aee3 analysis: integrate and audit D10 candidate evidence
44847df analysis: execute and audit D09 evidence layers
4135364 analysis: execute and audit D08 locked-candidate validation
eb3de2f protocol: authorize locked-candidate validation
59599da analysis: execute and audit D07 site robustness
db72e65 analysis: execute and audit D06 environment interaction
bbd4504 analysis: execute and audit D05 environment-specific analysis
0ce12b1 fix: correct D05 environment dose count bookkeeping
2542104 analysis: execute and audit D04 dose trajectories
9b5b9cf analysis: lock D03 discovery candidate family
1076453 analysis: execute and audit D02 discovery primary
681983b fix: correct frozen split count assertion
db17202 analysis: execute and audit D01 discovery eligibility
```

另外，本窗口之前已经同步过以下控制文档到真实 D01--D10 状态：

-   `PROJECT_CONTEXT.md`
-   `descriptive/discovery_validation/DATA_CONTRACTS.md`
-   `descriptive/discovery_validation/PIPELINE_STATUS.md`
-   `descriptive/discovery_validation/README.md`
-   `descriptive/discovery_validation/WORKFLOW.md`

如果下一窗口发现这些文档仍为 modified，请先检查是否尚未完成
documentation commit；不要直接覆盖。

------------------------------------------------------------------------

## 冻结的 Discovery--Validation 核心结果

### Split

-   Total prospective cohort: 515
-   Discovery: 386
-   Validation: 129
-   Frozen assignment SHA256:
    `062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791`

### D01

-   Discovery n = 386
-   Eligible proteins entering D02 = 1445
-   Imputation = NONE

### D02

Primary model:

`abundance ~ dose + environment`

Primary contrast:

`Long_vs_Short`

Results:

-   1445 proteins tested
-   1445 estimable
-   raw P \< 0.05: 365
-   BH-FDR \< 0.05: 85
-   transformation: log2(PG.Quantity)
-   normalization: NONE
-   imputation: NONE

### D03

-   Locked candidates: 85
-   Locking rule: Discovery Long vs Short BH-FDR \< 0.05
-   85/85 were `Higher_in_Short`
-   Candidate SHA256:
    `14759ed673be0291df2d6d5aa54f6bdb2e3264f9f5bb550dbbd316829aeb5fe2`

Candidate membership must never be changed using Validation results.

### D04

Trajectory classes:

-   Reversal_after_short_increase: 75
-   Transient_short_peak: 6
-   Delayed_decrease: 4

### D05

Environment-specific Discovery characterization.

Humid-hot:

-   Short_vs_Control FDR \< 0.05: 2/85
-   Long_vs_Control FDR \< 0.05: 0/85
-   Long_vs_Short FDR \< 0.05: 78/85

High-pressure/high-altitude:

-   Short_vs_Control FDR \< 0.05: 1/85
-   Long_vs_Control FDR \< 0.05: 25/85
-   Long_vs_Short FDR \< 0.05: 44/85

### D06

Formal Dose × Environment interaction:

-   Interaction_Long_vs_Short: raw P \< .05 = 2; secondary FDR \< .05 =
    0
-   Interaction_Short_vs_Control: raw P \< .05 = 19; secondary FDR \<
    .05 = 0
-   Interaction_Long_vs_Control: raw P \< .05 = 5; secondary FDR \< .05
    = 0

Do not interpret D05 differences as formal interaction evidence.

### D07

Major Discovery sites:

-   XZ_GG 110
-   GZ_TH 92
-   FJ_FQ 54
-   FJ_QZ 44
-   XZ_YC 22

LOO:

-   5 × 85 = 425 estimates
-   all 85 candidates direction-stable across all five LOO scenarios
-   no scenario showed \>50% relative effect change

Interpretation: site robustness / influence stability.\
Do **not** write "no site heterogeneity."

### D08

Prespecified locked-candidate Validation:

-   locked denominator = 85
-   estimable = 85/85
-   direction concordant = 83/85
-   nominal replication = 29/85
-   FDR-supported replication = 1/85

Only FDR-supported candidate:

-   Q08378 / GOLGA3
-   Discovery log2FC ≈ -0.36060
-   Validation log2FC ≈ -0.68421
-   Validation P ≈ 0.000318
-   candidate-family BH-FDR ≈ 0.02703

Direction-discordant candidates:

-   Q92752 / TNR: Discovery ≈ -0.40372 → Validation ≈ +0.04467
-   Q9Y624 / F11R: Discovery ≈ -0.34873 → Validation ≈ +0.06912

Both Validation effects are near zero; describe as attenuation through
zero rather than strong opposite effects.

Effect-size behavior:

-   Discovery mean \|log2FC\| ≈ 0.34435
-   Validation mean \|log2FC\| ≈ 0.26224
-   median absolute Validation/Discovery ratio = 0.78357
-   ratio ≥ 0.50: 70/85
-   ratio ≥ 0.75: 48/85
-   ratio ≥ 1.00: 21/85
-   Validation − Discovery median = +0.06630
-   mean = +0.08478
-   Pearson r = 0.1114157
-   Spearman rho = 0.05411374

Required interpretation:

**Strong group-level directional concordance, but weak protein-specific
effect-size/rank concordance and limited multiplicity-controlled
single-protein replication.**

Do not write:

-   "85 proteins were validated"
-   "effect sizes replicated well"

Environment-specific Validation is secondary characterization only.

Humid-hot:

-   85 estimable
-   83 negative / 2 positive
-   raw P \< .05 = 14
-   BH-FDR \< .05 = 0
-   mean log2FC ≈ -0.3117

High-pressure/high-altitude:

-   85 estimable
-   78 negative / 7 positive
-   raw P \< .05 = 11
-   BH-FDR \< .05 = 0
-   mean log2FC ≈ -0.2125

### D09

Evidence table:

-   85 candidates
-   Discovery + Validation
-   stratifiers: Dose / Environment / Site
-   detection thresholds: 0.50 / 0.60 / 0.70 / 0.80
-   imputation = NONE

Dose-stratum detection:

-   all 85 meet ≥50%
-   all 85 meet ≥60%
-   all 85 meet ≥70%
-   81/85 meet ≥80% across all Dose strata

Unique peptide support:

-   `SOURCE_NOT_AVAILABLE`: 85/85

Do not invent peptide support.

### D10

Integrated candidate evidence:

-   rows = 85
-   unique proteins = 85
-   columns = 67
-   candidate universe preserved

Key integrated checks:

-   D07 all direction stable = 85/85
-   D08 direction concordant = 83/85
-   D08 nominal replication = 29/85
-   D08 FDR-supported = 1/85
-   D09 all Dose ≥80% = 81/85
-   peptide source unavailable = 85/85

Pathway:

-   `NOT_RUN_NO_APPROVED_MAPPING`: 85/85

Do not run pathway enrichment without an approved mapping/universe.

------------------------------------------------------------------------

## Figure work completed in this window

### `figures_prospective.R`

The old prospective figure script was statically audited and revised.

Current revised design:

-   result-table-only
-   no model refitting
-   no FDR recalculation
-   no candidate redefinition
-   no evidence scoring/ranking
-   exact 85-candidate guards where appropriate
-   D08 hierarchy guards
-   D06/D07/D08/D09 audit-contract guards for integrated evidence
-   no-overwrite protection for SVG/PDF/TIFF

The revised script successfully generated FIG2--FIG6 in all three
formats.

Smoke-test output directory:

`descriptive/discovery_validation/figures_prospective_v1/`

Generated successfully:

-   FIG2_discovery_primary.{svg,pdf,tiff}
-   FIG3_dose_trajectories.{svg,pdf,tiff}
-   FIG4_environment_specific.{svg,pdf,tiff}
-   FIG5_discovery_validation.{svg,pdf,tiff}
-   FIG6_integrated_evidence.{svg,pdf,tiff}

These 15 files are **smoke-test outputs, not frozen manuscript
figures**.

Do not treat them as final figures.

### Figure scientific-content plan

A new file has been prepared:

`descriptive/discovery_validation/FIGURE_PLAN.md`

It freezes the scientific-content architecture for:

-   Main Figures 1--6
-   Supplementary Figures S1--S11

Visual styling remains editable.

------------------------------------------------------------------------

## Frozen Main Figure architecture

### Figure 1

Study design, frozen split, eligibility, candidate locking, workflow,
Dose/Environment composition.

### Figure 2

Discovery signal and locked candidate family.

### Figure 3

Dose-response architecture and D04 trajectory classes.

### Figure 4

Environment-specific Discovery + formal interaction + site robustness.

### Figure 5

Independent locked-candidate Validation:

-   Discovery vs Validation
-   replication hierarchy
-   attenuation
-   effect ratio
-   weak protein-specific correlation
-   secondary environment-specific Validation

### Figure 6

Integrated evidence landscape:

-   D04 trajectory
-   D06 formal interaction
-   D07 site robustness
-   D08 Validation class
-   D09 detection robustness

No evidence score and no candidate ranking.

------------------------------------------------------------------------

## Frozen Supplementary Figure architecture

-   S1: Discovery/Validation cohort composition
-   S2: D01 eligibility and detection diagnostics
-   S3: D02 model diagnostics
-   S4: full D04 trajectory heatmap
-   S5: full D05 environment-specific contrasts
-   S6: full D06 interaction contrasts
-   S7: complete D07 LOO analysis
-   S8: detailed Validation attenuation/effect ratio
-   S9: detailed environment-specific Validation
-   S10: D09 50/60/70/80% detection gradient
-   S11: candidate missingness/detection by Dose/Environment/Site

------------------------------------------------------------------------

## Figure freeze boundary

### Scientific content is frozen

Do not change merely for visualization:

-   split
-   1445-protein Discovery universe
-   85-candidate family
-   candidate-lock rule
-   D04 classifications
-   D05/D06 multiplicity interpretation
-   D07 robustness definition
-   D08 Validation criteria or denominator
-   D09 detection thresholds
-   peptide-source status
-   pathway gate

Do not add:

-   post-hoc effect cutoff
-   Validation-driven "top proteins"
-   evidence score
-   composite ranking
-   arbitrary responder definition
-   new statistical endpoint

### Visual implementation remains editable

May change later:

-   font
-   color
-   point/line size
-   legend
-   dimensions
-   panel arrangement
-   panel lettering
-   non-substantive axis wording
-   movement of supporting panels between main and supplementary figures

------------------------------------------------------------------------

## Commit/pause procedure

Before pausing, inspect:

``` powershell
cd F:\env
git status --short
```

The figure code and frozen figure plan are appropriate source/provenance
files to commit.

The `figures_prospective_v1/` directory is a smoke-test output directory
and should not be treated as final manuscript output. Prefer leaving it
untracked or removing it after confirming it is reproducible.

Any temporary `figures_diff.txt` should not be committed.

Recommended staging:

``` powershell
git add descriptive/discovery_validation/code/figures_prospective.R
git add descriptive/discovery_validation/FIGURE_PLAN.md
git diff --cached --stat
git status --short
```

Then commit:

``` powershell
git commit -m "figures: freeze manuscript figure plan and audited generator"
```

After commit:

``` powershell
git log -7 --oneline
git status --short
```

If the only remaining untracked path is:

`descriptive/discovery_validation/figures_prospective_v1/`

that directory is the reproducible smoke-test output and may remain
untracked during the pause.

If `figures_diff.txt` still exists:

``` powershell
Remove-Item figures_diff.txt
```

Do not delete or modify D01--D10 outputs.

------------------------------------------------------------------------

## Next-window first action

Start with:

``` powershell
cd F:\env
git status --short
git log -8 --oneline
Get-Content descriptive\discovery_validation\FIGURE_PLAN.md -TotalCount 80
```

Then verify that the figure-plan/generator commit exists.

### Next analytical action

Do **not** return to D01--D10.

Do **not** redesign the statistical analysis.

Proceed to a unified manuscript-figure implementation following
`FIGURE_PLAN.md`:

1.  Main Figure 1
2.  Main Figure 2
3.  Main Figure 3
4.  Main Figure 4
5.  Main Figure 5
6.  Main Figure 6
7.  visual/scientific QA
8.  Supplementary Figures S1--S11
9.  cross-figure QA
10. freeze final manuscript figure outputs

No additional inferential analysis is authorized merely to improve
figure appearance.

------------------------------------------------------------------------

## Current evidence chain

``` text
Frozen prospective cohort n=515
        |
        +--> Discovery n=386
        |      |
        |      +--> D01: 1445 eligible
        |      +--> D02: 85 Long-vs-Short BH-FDR<.05
        |      +--> D03: lock 85
        |      +--> D04: trajectories 75 / 6 / 4
        |      +--> D05: environment-specific characterization
        |      +--> D06: no FDR-supported formal interaction
        |      +--> D07: site influence stability
        |
        +--> protocol unlock
        |
        +--> Validation n=129
               |
               +--> D08:
               |      85/85 estimable
               |      83/85 direction concordant
               |      29/85 nominal
               |      1/85 FDR-supported
               |
               +--> D09:
               |      detection robustness characterized
               |      peptide source unavailable
               |
               +--> D10:
                      85-candidate integrated supportive evidence
                      pathway not run without approved mapping
```

**PAUSE POINT:** D01--D10 complete and audited; figure
scientific-content plan frozen; next window starts manuscript figure
implementation, not new analysis.
