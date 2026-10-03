# Plasma Proteomics Study — Statistical Analysis and Biomarker Study Design Audit

Status: **DOCUMENTATION UPDATE ONLY. Author-confirmed definitions corrected; see ANALYSIS_PLAN_v2.0.md for the new specification. Execution is not authorized; technical prerequisites remain open.**

Review date: 2026-09-26, America/Los_Angeles. Repository: `F:/env`. Inspected Git HEAD: `4d197e2`. The original audit was the only deliverable of its earlier task; this amendment accompanies the new v2 protocol. No analytical script, assignment, protocol, raw data, model or result was changed. No pipeline, statistical model, prediction model or enrichment analysis was run. Read-only checks counted existing metadata and compared existing protein-ID lists; these are audit reconciliations, not new biological results.

Review approach follows the evidence and statistical-reporting principles of nature-reviewer and nature-statistics. The user's A–K format takes precedence over the review skill's default multi-reviewer format. This is one design review, not three independent referee reports. Recommendations below are reviewer judgments tailored to this repository; they are not claims of journal acceptance or a completed prospective registration.


## Amendment record — author-confirmed design, 2026-09-26

This amendment preserves the A–K audit structure and historical evidence while correcting superseded interpretations. The original audit was already untracked at task entry; Git HEAD is not a stored copy of it. The companion `ANALYSIS_PLAN_v2.0.md` controls new methods where it refines earlier recommendations, including ordered inference, strict detection, exact ML choices and multiplicity. Neither document authorizes execution.

| Previous concern | Authoritative resolution / continuing limitation |
|---|---|
| Low/High interpreted as duration | **RESOLVED; previous inference withdrawn.** Low = lower target exposure under environmental control/protection; High = higher exposure without that protection. Control < Low < High is established, without numerical spacing. Duration is separate; a Low participant can have longer duration than a High participant. This is not a longitudinal trajectory. |
| Environment terminology | **RESOLVED.** Humid-hot and High-altitude. Legacy high-pressure wording does not establish another physical exposure. |
| Material and unit | **RESOLVED.** Plasma, not EV-enriched plasma; 515 samples from 515 independent participants, no known repeats. Orbitrap Astral Zoom, DIA, Spectronaut, `PG.Quantity`. Other preparation details are unavailable. |
| Controls | **RESOLVED as intended design.** No target exposure; same general recruitment framework; present across Sites and both Environments; same intended collection, transport, storage and MS workflow. Realized processing equivalence is not proven. |
| Site | **CLARIFIED.** Recruitment location; real names may be used if documented. Sites are nested within Environment; intended SOPs shared. Collection calendar periods can differ. Exact processing delay, centrifugation, freeze-thaw and transport metadata are unavailable. Sparse cells and acquisition confounding remain. |
| Clinical metadata | **CLARIFIED.** Incomplete, including disease history. Do not assert a disease-free cohort. Optional missing metadata must not exclude participants or delay core proteomics; later adjustment remains sensitivity only. |

Legacy mapping: `control`/`Control` → Control; `low`/`Short` → Low exposure; `high`/`Long` → High exposure; `high_temperature`/湿热 → Humid-hot; `high_stress`/高海拔 → High-altitude. Exact legacy `dose`, Short/Long filenames and frozen output tokens are retained only for traceability.

Normalization re-audit: `code/P1.py`–`P3.py` normalize identity strings, not protein intensities. Stage 05 exports untransformed quantities; `stage05_normalization_helper.py` creates log2 values with NA retained and separately `x_ij - median_j + median(sample medians)` for the median-normalized sensitivity. Stage 07 primary and D02/D08 use log2 only with no additional normalization; Stage 07 has a separate median sensitivity. Missingness D0–D3 share the log2 input and add no normalization. The archived trend branch reads the primary log2 matrix. No Spectronaut project/search configuration or FASTA was located in the repository inventory. **Upstream normalization is not fully recoverable**; `PG.Quantity` alone cannot establish whether normalization was enabled. Public manual defaults cannot establish this experiment's settings. Obtain the actual configuration or retain this explicit limitation before Freeze 2 release.

For v2, use moderated-t intervals from limma's posterior variance and total degrees of freedom. Existing helper CIs use normal quantiles, whereas candidate/replication tests use moderated P values; this is a reporting limitation, not evidence that the historical 85 or 1/85 count changes. See the companion protocol's exact CI formula and verified limma source.

## A. Executive assessment

**The architecture is scientifically coherent and conditionally statistically defensible, but it is not ready to execute or describe as a wholly prospective, independently validated biomarker study.** It can support a strong observational plasma-proteomics manuscript after correcting the evidence labels, specifying the new analysis families, auditing technical exclusions, and developing a genuinely contained prediction workflow. Clinical utility and external reproducibility remain future questions.

The strongest existing elements are participant-level identities, a frozen 386/129 assignment, Discovery-only eligibility regeneration, an explicit 85-protein lock, preserved missing values in abundance inference, and an honest three-level replication definition. The broader hierarchy is a useful improvement: exposure-associated abundance, ordered group profiles and pairwise comparisons should coexist with a separate detection axis. The historical work should be retained, not replaced silently.

Five qualifications determine the plan:

1. **Validation is already used data.** Historical full-cohort analysis preceded the split, and D08–D10 have since examined Validation. A computationally separated Discovery analysis is useful, but the 129 participants are no longer an untouched test resource. New prediction work can reserve them from model fitting and further tuning; it cannot restore blindness or become external validation by renaming the split.
2. **Exposure-level ordering is author-confirmed.** Low/High identify protected lower versus unprotected higher target exposure. Legacy Short/Long tokens do not define duration. Control → Low → High supports ordered cross-sectional exposure-level analysis without equal physical spacing or longitudinal claims.
3. **Site and Environment are nested and processing is partly confounded.** Nine sites have very unequal composition. One site has only controls, another has only one High participant. Two large sites align with individual acquisition dates. Neither a rich model nor leave-one-site-out analysis can identify geographic biology separately from perfectly aligned processing factors.
4. **The historical 256 and prospective 85 are different analyses of overlapping people, not contradictory replications.** Their models and primary handling are the same, but sample sizes, eligibility membership, fitted information and BH families differ. Exact reconciliation appears in J.
5. **A small predictive panel is a possibility, not a required outcome.** Separation of exposure labels does not establish a diagnostic indication, mechanism, prognostic value, or useful intervention threshold. A stable small panel may not exist even if differential abundance is reproducible.

### Evidence anchors and inspection boundary

Paths below are relative to `F:/env`. They are intended as exact, inspectable repository anchors.

| Anchor | Inspected sources | What they establish |
|---|---|---|
| R1 | `PROJECT_CONTEXT.md`, `archive/audits/docs_task/TASK_CURRENT.md`, `archive/audits/docs_workflow/FILE_STATUS.md`, `docs/archive/early_plans/README_LIMMA_ANALYSIS_PLAN_v1.0.md` | Frozen historical architecture, handling and terminology; historical outputs precede the split |
| R2 | `docs/protocol/DISCOVERY_VALIDATION_PROTOCOL.md`, `docs/protocol/DISCOVERY_VALIDATION_SPLIT_SPEC.md`, `descriptive/discovery_validation_split/discovery_validation_assignment.csv` | 515 independent participants as documented; fixed assignment and strata |
| R3 | `descriptive/05_dose_quantitative_filtering.py`, `descriptive/07_limma_dose_analysis.R`, `archive/sensitivity/limma_dose_analysis/analysis_manifest.csv`, `archive/sensitivity/limma_dose_analysis/PRIMARY_summary.csv` | Historical eligibility, abundance model, contrasts and counts |
| R4 | `descriptive/discovery_validation/D01_discovery_eligibility.py`, `code/D02_discovery_primary.R`, `code/dv_shared.R` within that branch; D01 and D02 outputs | Discovery-only eligibility; 1,445 tests and model implementation |
| R5 | `descriptive/discovery_validation/code/D03_candidate_lock.R`, `D03_candidate_lock/D03_locked_candidates.csv`, `VALIDATION_UNLOCKED.txt`, `code/D08_validation.R`, `D08_validation/D08_replication_summary.csv` | Lock, authorization, actual Validation rules and outcomes |
| R6 | `descriptive/11a_dose_pattern_classification.R`, `11b_protein_clustering.R`, `descriptive/discovery_validation/code/D04_dose_trajectory.R` | Selected-universe descriptive profiles, tolerance and means |
| R7 | `descriptive/discovery_validation/code/D05_environment_specific.R`, `D06_environment_interaction.R`, `D07_site_robustness.R` and corresponding output folders | Candidate-restricted secondary analysis and influence checks |
| R8 | `descriptive/stage05_detection_helper.py`, `descriptive/09_detection_pattern_analysis.R`, `descriptive/detection_pattern/` | Binary detection branch, group-dependent eligibility and fixed comparator threshold |
| R9 | `descriptive/covariate_QC/input_availability.csv`, `metadata_completeness.csv`, `descriptive/dose_defined_metadata.csv`, `descriptive/QC前描述_样本构成与分析路线.md` | Available covariates, actual site composition and acquisition overlap |
| R10 | `rawdata/processed.xlsx`, `rawdata/rawdata.xlsx`, `rawdata/sample_mapping_FINAL.xlsx`; `descriptive/canonical_protein_annotation.csv` | Workbook schemas, raw annotation fields and positional mapping |
| R11 | `descriptive/missingness_robustness/README_METHODS.md`, `results/robustness_summary.csv` in that folder; `descriptive/normalization_design_diagnostics_report.md` | Existing sensitivity work and diagnostic scope |
| R12 | `descriptive/discovery_validation/DATA_CONTRACTS.md`, `DISCOVERY_VALIDATION_HANDOFF_2026-09-26_PAUSE.md`, `FIGURE_PLAN.md`, D09/D10 output status | D01–D10 completion, unavailable peptide evidence, pathways not run, figures not final |

The raw workbook schemas were read, but original instrument files, search settings, FASTA/database contaminant annotations, recruitment records and clinical metadata were not available in this inspection. No assertion is made that absent export flags mean contaminants were absent from the experiment. Some earlier documents retain future-tense or pending text; executed code, output tables and the final handoff take precedence for factual status, without rewriting those documents.

## B. Critical issues

Severity reflects consequence for the proposed claim, not the amount of work needed.

| ID | Severity | Verified issue and evidence | Required resolution before the affected new analysis |
|---|---|---|---|
| B1 | **CRITICAL** | The 129 participants entered historical full-cohort exploration, then D08–D10. R1/R5/R12 contradict an untouched-holdout description. | Disclose chronology. Freeze ML before any further outcome inspection; prohibit full-cohort-derived candidate lists and Validation-based choices. Call subsequent testing reused within-cohort hold-out evaluation. Truly independent confirmation requires new participants. |
| B2 | **RESOLVED BY AUTHOR** | Legacy Short/Long and high-pressure wording caused incorrect scientific interpretation. | Use Low/High exposure level and High-altitude. Duration is separate optional metadata, not a Group definition. Preserve computational tokens only through the explicit mapping above. |
| B3 | **MAJOR** | No explicit contaminant/decoy flag in inspected seven annotation fields; selected scripts implement coverage but no verified technical-contaminant removal. R3/R4/R10. | Obtain search/export settings and database annotations; freeze evidence-based exclusions before revised universes. Record unavailable information rather than claiming zero contaminants. |
| B4 | **MAJOR** | Site nested in Environment; XZ_YB lacks exposed people; severe sparse cells and site/date alignment. R9 and site table below. | Freeze estimable contrasts and covariate strategy. Separate site, environment and processing interpretations; do not use a rank-deficient saturated model. |
| B5 | **MAJOR** | Stage 11a uses only 256 High-vs-Low DEPs; D04 uses only the locked 85. R6. | Retain these as selected-set descriptions. New profiles must start from the full eligible quantitative universe, with an omnibus Group test or all-protein descriptive profiles. |
| B6 | **MAJOR** | Age/Sex are explicitly `absent_skipped` in existing QC; inspected participant schema lacks BMI, smoking and routine clinical covariates. R9/R10. | Seek existing linked metadata and define availability/missingness before modeling. If unavailable, retain environmental adjustment and acknowledge residual confounding; do not claim comprehensive adjustment. |
| B7 | **MAJOR** | A single “canonical universe” would wrongly conflate common quantitative proteins, differential detection and fold-specific ML eligibility. | Freeze one technical identity/exclusion registry with separate, explicit analysis-universe rules. Never subset the full-cohort eligible list to obtain an ML training universe. |
| B8 | **MAJOR** | Historical detection helper sets `OTHER_MAX_EXCLUSIVE = 0.20`; inferential universe is max group detection ≥60%. R8. | Preserve historical definitions. New inference should use a label-independent testability rule, and specificity requires a separately justified comparator definition. No cutoff optimization for desired proteins. |
| B9 | **MAJOR** | New primary contrast, interaction families, pathways and ML strategies are not yet frozen. | Define estimands（目标估计量）, weights, analysis populations, test families, missingness and selection rules in v2 before execution. “Primary in v2” does not mean prospectively primary before historical data access. |
| B10 | **MODERATE** | `dv_shared.R:78–88` reconstructs SE as `abs(log2FC/t)` and uses `qnorm(.975)` for CI, while P values use moderated t. Exact zero effects can give 0/0. | Document existing CIs as normal approximations. In an authorized versioned correction use `stdev.unscaled × sqrt(s2.post)` and moderated total degrees of freedom, or limma's supported CI output. Do not overwrite D08 or silently recalculate its replication count. |
| B11 | **MODERATE** | D04 calls raw within-dose observed means `Modeled_mean`; they are not environment-adjusted predictions. | Relabel historical displays accurately. v2 uses standardized adjusted means for inferential profile figures. |
| B12 | **MODERATE** | “No additional normalization” is verified downstream; Spectronaut upstream normalization/joint-search dependencies are not documented here. | Establish export processing and deployment compatibility before asserting leakage-safe prospective measurement. Shared search alone is not proof of supervised leakage, but pooled normalization/reference learning needs review. |
| B13 | **MODERATE** | D04/D05/D06 use the Discovery-selected 85 again, including BH within that selected set; R7. | Describe these as conditional exploratory characterization, not an independent confirmatory test family. Selection followed by ordinary BH does not automatically control all selective claims. |
| B14 | **MINOR** | D09 unique-peptide source is unavailable; D10 pathways are not run. R12. | Keep identification-QC availability in supplement. Remove peptide evidence as a prerequisite for the detection/Unique-protein scientific axis. Do not imply pathway analysis has already occurred. |

The CI issue is an implementation limitation, not evidence that the reported 1/85 replication count is wrong: that count uses existing P values and BH, not CI crossing. Official limma documentation supports t-based intervals; no numerical repair was performed here. [Bioconductor limma release note](https://bioconductor.org/news/bioc_2_14_release/).

## C. Discovery/Validation assessment

### Keep the assignment frozen

The participant-level 75/25 split stratified by Environment × Group is defensible for same-source replication and prediction evaluation. Site stratification is not obligatory, and lack of it is not grounds for rerandomization. This is random allocation to analysis subsets, **not randomized exposure assignment**. The author confirms 515 independent participants; the split does not establish randomized exposure assignment.

| Environment | Group | Total | Discovery | Validation |
|---|---|---:|---:|---:|
| Humid-hot | Control | 95 | 71 | 24 |
| Humid-hot | Low exposure | 83 | 62 | 21 |
| Humid-hot | High exposure | 101 | 76 | 25 |
| High-altitude | Control | 58 | 44 | 14 |
| High-altitude | Low exposure | 103 | 77 | 26 |
| High-altitude | High exposure | 75 | 56 | 19 |
| Total | | **515** | **386** | **129** |

Both subsets share recruitment context, sites and measurement workflow. This is not external validation（外部验证）or a new-environment test. Small environment cells restrict precision; they do not automatically invalidate overall evaluation. No assurance of adequate power follows simply from N=129. For prediction, sensitivity in 44–47 cases and specificity in 38 controls can be imprecise, especially at extreme thresholds.

### Association replication and historical access

D01 rederived eligibility from Discovery columns; D03 locked 85 before the D08 authorization. This establishes procedural separation for that branch. However, the same people's proteins had already been used in the 515-person historical analysis. Therefore, use **“prespecified split-sample replication within a previously explored cohort”**, accompanied by the chronology. “Prospective” can describe locking relative to D08, not a newly recruited prospective cohort or a data-naive research programme. Code inspection does not reconstruct everything investigators knew when selecting the protocol.

Preserve the original High-vs-Low result (legacy Long-vs-Short) as the **primary result within the frozen replication module**, even though the revised manuscript's biological lead is Control vs Exposure. Present its principal outcomes visibly in the main paper; detailed protein tables and environment analyses belong in supplement. Do not demote an unfavorable primary replication outcome to an invisible supplement or promote another contrast on the basis of Validation success.

The existing outcomes are 85/85 estimable, 83/85 same direction, 29/85 same direction plus nominal P<0.05, and 1/85 same direction plus BH<0.05 across the 85 family. GOLGA3 / Q08378 is the single FDR-supported candidate in the existing output. These support widespread **directional consistency** with limited multiplicity-controlled single-protein support. They do not support “85 validated biomarkers,” a clinically useful panel, reproducible rankings, or an absence of effects among nonreplicating proteins. The final handoff reports weak effect/rank correlations despite high sign concordance; correlations within an already selected narrow effect range are themselves selection-dependent descriptions. Correlated proteins must not be treated as 85 independent trials in a naive sign/binomial test. Winner's curse（发现集效应高估）and limited validation precision are plausible explanations for attenuation, not proven explanations for each protein.

New association candidates selected after examining all 515 cannot be independently replicated using the 129 subset. Even if new candidates are generated computationally from Discovery alone, follow-up using these previously inspected 129 must be labeled secondary, within-cohort and subject to prior access. An external cohort is needed for an unambiguous new replication claim.

### ML terminology and use

Discovery is the **model-development dataset（模型开发集）**. Inner CV folds are tuning folds, not the repository's capital-V Validation. Outer folds evaluate the development procedure. Validation is the fixed **evaluation subset（留出评估子集）**, not a tuning set. Its reuse limitations must accompany every later performance claim.

No ML performance is generated in this audit. The recommended primary task is chosen from the biological aim, not from the known D08 results. For new ML, freeze the entire development algorithm now, use Discovery only, and evaluate once on the 129 with all historical access disclosed. This avoids additional computational leakage but does not erase historical information reuse. Re-splitting the 515 would not create new independent evidence.

## D. Full-cohort vs Discovery-only analysis

| Scientific purpose | Appropriate population | Permitted interpretation |
|---|---|---|
| Participant/proteome description, design overlap, overall biological associations | All 515 group-defined participants; include the original 519 only in raw/QC flow | Full-cohort observational description/inference, explicitly informed by prior work |
| Exposure, ordered profiles, pairwise abundance/detection, environment and site sensitivity in v2 | All 515, with per-protein observed N and estimability | Most precise characterization of this cohort; no independent replication claim from a subset |
| Original Discovery selection and original Validation evidence | Existing 386 and 129, respectively | Preserve frozen results and chronological qualifications |
| Any new model eligibility, candidate screening, preprocessing learning, panel and model decisions | Discovery only; repeat within every training fold | Internal development; do not import outcome-informed full-cohort tables |
| Locked model performance | Fixed 129, used once after lock | Reused within-cohort hold-out evaluation, not pristine/external validation |
| Independent confirmation and clinical transportability | New participants with a locked assay/model | Future external study, not performed here |

### Minimal abundance model and exposure estimand

Retain the frozen biological starting point: log2(PG.Quantity), no additional primary normalization, missing abundance remains NA, and limma with `trend=TRUE, robust=TRUE`. For v2, apply confirmed technical exclusions first and recompute the coverage rule within the appropriate population. Keeping NA does not remove missing-not-at-random bias; detection and existing sensitivity work remain necessary. Do not replace the primary method because an imputation method yields more discoveries.

Fit categorical Group + Environment on the quantitative universe. Define the positive sign consistently as exposed minus Control, Low minus Control, High minus Control, and High minus Low. “Control vs Exposure” is a scientific label, not an instruction to reverse signs across files.

Recommended exposure contrast from the three-group model:

`ΔExposure = (186/362) × μLow + (176/362) × μHigh − μControl`.

These fixed metadata-derived weights target the observed cohort's exposed mixture and retain separate Low/High coefficients. Do not change them between environments when comparing effects. Equal 1/2 weights may be a single labeled sensitivity if a balanced-exposure-level estimand matters. In a future Discovery-only association procedure, use weights fixed in its own protocol rather than adapting them to Validation. A binary collapse model estimates a different, restricted pooled effect; it should not be silently substituted. The average exposure contrast can cancel opposing Low/High responses, so Level 2 is not gated on Level 1 significance.

The minimally adjusted model estimates association conditional on Environment, not a causal exposure effect. If reliable baseline clinical covariates become available, specify a small causal rationale before adding them and define missing-covariate handling. Do not select adjustment variables by univariate P values, adjust automatically for downstream clinical consequences, or use site/date adjustment to claim confounding has been eliminated.

### Ordered profiles without contrast-based circular selection

1. Begin with **all** v2 quantitative-eligible proteins, not the 256 or 85 and not just exposure-significant proteins.
2. Use a two-degree-of-freedom moderated omnibus Group test for `Low−Control` and `High−Control`. Correct its protein family by BH. This asks whether any categorical group difference is present, including a Low peak or a cancellation in the pooled contrast.
3. Obtain environment-standardized fitted means and adjacent contrasts `a=Low−Control`, `b=High−Low`, and endpoint `a+b`. Use a common, frozen environment distribution for displayed means. Show effect intervals and observed sample counts.
4. Assign **descriptive** monotone, Low-peak, Low-suppression, delayed, plateau-like, reversal-like or uncertain profiles from these effects. Existing 0.05-log2 tolerance can be displayed for historical compatibility, but is not a validated biological-equivalence margin. “Near zero” or P≥0.05 does not prove a plateau or return to baseline.
5. The companion v2 Module 06 adds a formal adjacent-direction intersection–union test without equal exposure spacing. Omnibus FDR supports “Group-associated,” not the exact shape. Formal monotonicity would require supported adjacent directional constraints; formal plateau/equivalence needs an externally justified margin and appropriate joint/equivalence testing. The smallest plan avoids declaring these many shape-specific hypotheses confirmatory. Report uncertain membership and Discovery resampling stability only if used for feature selection or central profile claims.

Three cross-sectional groups cannot reconstruct a continuous time course or establish adaptation/recovery. Do not fit a 0/1/2 linear slope as measured dose response, or a flexible spline with only three ordered exposure categories. Stage 11a's historical 249 legacy Short-peak / 7 legacy Long-suppression and D04's 75/6/4 classes are selected-family characterizations under different rules, not estimates of the whole proteome's response distribution.

### Multiplicity architecture

The hierarchy is biological, not automatic statistical gatekeeping. Recommended v2 families are: exposure abundance BH across its eligible proteins; Group omnibus BH across its eligible proteins; and a separate BH family for each pairwise contrast. This amendment adopts per-contrast families because each contrast answers a distinct prespecified question; the previous pooled-primary recommendation is superseded. A pooled protein × three-contrast BH is additional sensitivity for a union claim, not a replacement for per-contrast reporting. Define separate detection and interaction families below. These are module-specific error controls, **not a study-wide 5% FDR guarantee**. If a pooled “associated by any module” claim is required, specify an additional pooled/hierarchical procedure before execution.

Contrast-specific significance does not prove contrast-specific biology: significance in one comparison and not another is not a test of their difference. UpSet membership is descriptive; inspect effect estimates and direct contrasts. No effect-size cutoff is added to the historical definitions.

## E. Biomarker ML plan

### Prediction targets and primary model

| Priority | Task | Discovery class counts | Evaluation class counts | Role |
|---|---|---|---|---|
| 1 | Control vs Exposure | 115 / 271 | 38 / 91 | Primary, Exposure positive |
| 2 | Control vs Low | 115 / 139 | 38 / 47 | Secondary, Low positive |
| 3 | Control vs High | 115 / 132 | 38 / 44 | Secondary, High positive |
| 4 | Low vs High | 139 / 132 | 47 / 44 | Secondary, High positive |
| 5 | Control / Low / High | 115 / 139 / 132 | 38 / 47 / 44 | Exploratory only |

These counts follow the frozen assignment, not new outcome analyses. Pairwise tasks use only relevant groups, never all 386 by relabeling excluded groups. Control vs Exposure is justified as the primary target before ML results. Low vs High classification should not inherit priority merely because it was the original association contrast.

Use **Elastic Net logistic regression（弹性网逻辑回归）** as the primary family. It permits shrinkage and correlated predictors, yields explicit coefficients, and can support a small panel. It does not guarantee stable protein identities or causally interpretable coefficients. Multinomial Elastic Net is sufficient if the exploratory three-class task proceeds.

Random Forest（随机森林）is a reasonable single nonlinear comparator but does not automatically produce a small panel; impurity importance can be misleading. Gradient boosting / XGBoost（梯度提升树）adds tuning and overfitting opportunities at this N. Consider it only as a prespecified replacement comparator for a justified nonlinear question, not a third opportunity to pick a favorable hold-out score. The smallest plan uses Elastic Net, a prevalence/intercept baseline and a metadata-only benchmark. One tree comparator is optional. There is no need for deep learning or a broad model tournament.

### Candidate-universe decision

**Primary Strategy B:** begin with all technically valid protein groups and apply a prespecified training-only testability/coverage rule. A simple primary quantitative panel can retain the familiar ≥70% detection in each relevant training class; for the Control/Exposure task, keeping separate Control/Low/High coverage during filtering is a conservative way to ensure both exposed subgroups are represented. Freeze this choice rather than toggling it based on performance. “Proteome-wide” means no supervised DE preselection within the resulting assay-eligible universe, not every raw entry regardless of quality.

**Strategy A as a secondary procedure:** a small, frozen Discovery-derived biological screen is permissible, but regenerate eligibility and the screen using each inner-training sample set. The minimal screen is the primary-target association or the categorical Group omnibus test. A union of all contrasts, profiles and detection sets greatly expands adaptive choices; use it only if its complete deterministic rule, thresholds and empty-set fallback are frozen. FDR is not a necessary predictive filter and an empty screen is a legitimate outcome, not a reason to relax thresholds after inspection. For a binary task using three-group biology, outer-held-out participants must be excluded from every auxiliary three-group screen as well.

**Existing 85:** retain as a historical candidate-source comparator; do not privilege it because one member replicated. It was selected using all 386 outcomes. Therefore, cross-validation within those same 386 using the fixed 85 is **not unbiased evaluation of the feature-discovery procedure**. Either regenerate the original selection algorithm within each training fold, or explicitly report fixed-list CV as conditional/optimistic exploratory evidence and keep it outside primary strategy selection. The 256 list and the Validation-supported subset are prohibited new ML feature screens.

Unique/detection predictors can be a predefined secondary extension from a separate training-only detection universe. Do not force them through a ≥70%-in-every-group rule, which excludes the very group-specific detection patterns of interest. They can encode assay depth or processing, so robustness and transferability require special scrutiny.

### Leakage-safe resampling and preprocessing

The following is a proposed workflow, not permission to execute:

1. Freeze the target population, intended use, positive class, technical exclusion registry, candidate rules, performance metric, model family, tuning grid, panel-size rule, threshold rule and seeds. Check that target labels are not inferred from proteins. Use the frozen participant IDs, not ambiguous raw column headers.
2. In Discovery, use a fixed **5-fold outer × 5-fold inner nested cross-validation（嵌套交叉验证）**, stratified by Environment × original Group where feasible. A pragmatic prespecified option is three outer repeats to assess split sensitivity; repeats are not independent datasets. For binary tasks create splits within the relevant participants. No post-hoc search for a favorable seed.
3. Every inner-training fold independently performs eligibility filtering, any biology screen, imputation fitting, normalization-reference fitting if used, scaling, feature selection and model fitting. Apply those fitted transformations unchanged to the inner test fold. After selecting settings, redo the full procedure on the outer-training data and apply it once to the outer-held-out data. This principle applies even to unsupervised data-derived filtering. [scikit-learn leakage guidance](https://scikit-learn.org/stable/common_pitfalls.html).
4. Preserve fixed log2 transformation. For the primary ML baseline use training-protein medians for residual missing-value imputation and training means/SDs for scaling. Do not use class-specific imputation, because true Group is unknown at prediction. Remove training-all-missing/zero-variance predictors by a frozen rule. Prespecify how missing required features or unacceptable sample quality yield a failure/abstention; report its frequency rather than deleting unfavorable evaluation cases.
5. Keep no additional normalization as the starting workflow, conditional on upstream processing audit. If sample-wise normalization or a reference correction is needed, it must be computable for one future patient and use a fixed training reference. No combined Discovery/Validation quantile normalization, jointly fitted ComBat, PCA or imputation. A fixed within-sample transform is different from learning a reference from the evaluation cohort.
6. Tune a small Elastic Net mixing/penalty grid using one criterion, recommended mean inner-CV log loss（对数损失）for probabilistic predictions. Choose the more regularized candidate within one standard error as a practical parsimony rule, not a formal inferential guarantee. Primary reported discrimination can still be AUROC. If a small-panel cap is imposed, freeze a short grid such as 5/10/20 proteins and evaluate the entire ranking, truncation and refitting procedure within the nested workflow. A post-CV hand-picked panel is a different unvalidated model.
7. Report protein selection frequencies and coefficient-sign stability across outer training fits as descriptive stability. Correlated substitutes can make identities unstable even with stable predictions. Bootstrap stability selection（自助重采样稳定性选择）is optional if panel membership is central; it supplements rather than replaces nested CV and does not imply formal false-selection control unless its assumptions are met.
8. If comparing A and B or a nonlinear model to Elastic Net to choose the final algorithm, that choice belongs in the inner selection procedure. Comparing many outer estimates and reporting only the best as unbiased introduces selection optimism. The simpler alternative is to fix B + Elastic Net as primary and report all prespecified comparators secondarily. [Cawley and Talbot, model-selection bias](https://www.jmlr.org/beta/papers/v11/cawley10a.html).
9. Lock the final model using all Discovery data only, applying the same inner-selection rule. Save exact protein IDs/order, transformations, coefficients/intercept, assay requirements, threshold, missingness/failure policy and any calibration mapping. Feature instability or poor performance may legitimately end with “no supported small panel.” Do not inspect Validation to resolve a tie.
10. Evaluate once on the fixed 129, acknowledging historical reuse. No feature substitution, recentering on Validation, threshold revision, calibration refit or model ranking from these results. Any changed model is a new development exercise and requires new evaluation data.

A globally fitted imputer or Discovery-wide supervised screen before CV is leakage within Discovery even if Validation is untouched. Fitting an adjusted residual model using all samples or requiring the true class to residualize a new sample is also invalid. Biological pathway labels derived from full-cohort findings must not be used to manually rescue panel members.

### Metrics, calibration and uncertainty

For the primary binary task, **AUROC（ROC曲线下面积）with 95% CI is the primary discrimination endpoint**. Required companions are AUPRC（精确率–召回率曲线下面积）, Brier score（概率预测均方误差）, calibration intercept/slope（校准截距与斜率）, and a calibration plot. Exposure prevalence is 91/129 in the evaluation subset; show this prevalence baseline for AUPRC. AUROC alone can hide poor probabilities and operating characteristics.

Primary model evaluation emphasizes AUROC, AUPRC, Brier score and calibration rather than a mandatory classification cutoff. If an operational threshold is required, prespecify its selection rule and determine it entirely within Discovery/model-development data, including that step inside outer evaluation when estimating threshold-dependent performance; lock it before the reused hold-out is evaluated. At that locked threshold report sensitivity, specificity, PPV, NPV, balanced accuracy, confusion counts and F1. A probability threshold of 0.5 may be reported only as a supplementary/reference operating point. Do not select, revise or optimize any cutoff on the reused hold-out, including by Youden index. Future targeted-assay studies may define application-specific operating thresholds according to intended use.

For three classes, use prespecified macro one-vs-rest AUROC and report each class's AUROC, macro-F1, balanced accuracy, confusion matrix and class-specific recall. Report multiclass Brier/log loss and classwise calibration only with adequate support; avoid unstable fine-bin curves.

The primary imbalance is moderate, not a reason for automatic SMOTE or undersampling. Start with unweighted likelihood, stratified CV and prevalence-aware reporting. Class weighting changes the fitted probability target and can harm calibration; if tested, treat it as a predefined training-only variant. No resampling before fold assignment.

Use participant-resampling CIs for final frozen predictions, with a declared stratification scheme; paired resampling can compare a protein model and metadata benchmark. A stratified bootstrap is conditional on observed class composition. Use appropriate binomial intervals for threshold-specific proportions. Do not treat repeated CV predictions of one participant as additional independent observations or use fold SD/√number-of-folds as a valid general performance CI. Internal resampling uncertainty and held-out participant uncertainty answer different questions. With only nine sites, a cluster bootstrap is fragile; site-specific reporting is a useful transportability diagnostic, not a guarantee of between-site precision.

Estimate calibration intercept/slope in the hold-out solely as evaluation statistics, with broad intervals if needed. Applying those estimates to recalibrate predictions would consume the evaluation set for model updating. If recalibration is part of the intended pipeline, fit it from Discovery cross-fitted predictions and nest its training. PPV/NPV and calibration apply to the sampled exposure prevalence; they cannot be generalized to a clinical population with unknown exposure prevalence. No clinical decision-curve claim is justified until an actual decision and plausible thresholds are specified. Report model details using the principles of [TRIPOD+AI](https://www.bmj.com/content/385/bmj-2023-078378).

### Environment and site robustness for ML

The primary protein-only classifier should be compared with a small metadata-only model, initially Environment and any genuinely available baseline covariates. A site/date-only classifier is a confounding diagnostic, not a proposed deployable biomarker. A prespecified protein-plus-clinical model can test added prediction once clinical metadata exist. Never include fields that directly define Group as predictors.

Assess environment-specific errors/calibration descriptively. Perform Discovery-only leave-one-site-out predictive evaluation as a secondary transportability check, rerunning all preprocessing and tuning without the held-out site. This is distinct from D07, which refits association models after deleting a site. Single-class sites cannot yield a binary site AUROC; report their available sensitivity/specificity or error counts without inventing missing classes. Two-environment holdout is at most a harsh exploratory stress test. Do not use a disappointing holdout site to retune and then call the same evaluation independent.

## F. Contaminant/QC plan

### Technical exclusions, retained biology and flags

| Category | Proposed handling | Evidence and reporting requirement |
|---|---|---|
| Decoy/reverse entries, explicit search-database contaminants, confirmed exogenous trypsin/BSA or other laboratory material | Remove before revised abundance, detection, pathway and ML eligibility | Use validated ID/database flags, not gene-symbol guesses. Distinguish false-identification controls from physical contamination. Save removed IDs, reasons, counts and retained count. |
| Keratins | Remove only when supported as technical contamination | Human keratin identity alone is insufficient; preserve ambiguous entries with annotation until evidence resolves them. |
| ALB, immunoglobulins, apolipoproteins, complement, fibrinogen | Retain in primary plasma biology | Their high abundance is not proof of contamination. Optional influence/normalization sensitivity addresses domination of global structure. |
| Erythrocyte/hemolysis, platelet, coagulation/processing signatures | Flag, quantify and evaluate, not automatic deletion | Use externally defined panels and compatible identifiers. Examine association with Group, Environment, Site and recorded handling variables. |
| Uncertain mixed-species/multi-accession protein groups | Flag and resolve under a frozen identity rule | No silent group-to-gene collapsing or deletion because of biological undesirability. |

Published plasma QC work supports erythrocyte, platelet and coagulation-related panels as sample-quality diagnostics. Use those published definitions where measurable; do not invent a universal “contamination score” or threshold. For example, hemoglobin-associated or platelet-associated markers can reflect biology as well as processing. [Geyer et al., Plasma Proteome Profiling to detect and avoid sample-related biases in biomarker studies](https://pmc.ncbi.nlm.nih.gov/articles/PMC6835559/).

Additional useful checks are leukocyte/cellular carryover where an appropriate reference exists, draw-to-spin delay, plasma holding time, tube mixing, anticoagulant/tube type, freeze–thaw/storage, collection-to-acquisition interval, carryover in blanks, pooled-QC drift and digestion efficiency. Most require records beyond the current matrices; do not infer them from abundance alone. Fasting/lipemia and inflammatory status are contextual covariates when recorded, not automatic technical exclusions. Do not infer an EV study from cellular or vesicle-associated proteins in plasma.

Recommended sensitivities are: retain versus externally flagged handling-compromised samples under a prespecified rule; adjustment for interpretable processing variables/signatures; exclusion of flagged protein signatures from a secondary panel; median-normalization and complete-case abundance comparisons already established historically. Signature adjustment may remove genuine exposure-associated biology, so it should be labeled a sensitivity rather than automatically the primary model. Do not rerun the entire imputation suite unnecessarily; the existing D0–D3 evidence is useful for its historical universe and does not certify every new contrast.

### What the available files actually support

The primary export contains 3,817 protein groups and 519 abundance columns. Four participants with unknown Group were excluded from group-defined analysis, leaving 515; this is group eligibility, not evidence that four samples failed proteomic QC. The seven annotation fields are `PG.ProteinGroups`, `PG.Genes`, `PG.ProteinDescriptions`, `PG.ProteinNames`, `PG.CV`, `PG.Qvalue`, `PG.MolecularWeight`. No explicit contaminant/decoy field appears there.

`rawdata.xlsx` has 519 columns for each of PG.Quantity, PG.MS1Quantity, PG.MS2Quantity and PG.IBAQ plus those seven annotation fields. These are measurements of the same samples, not 2,076 independent participants. The inspected schema does **not** supply peptide counts, precursor counts, peptide lengths, retention times or unique-peptide evidence. `PG.CV` must not be labeled technical reproducibility CV until its calculation population is known; a between-person CV includes biology. Likewise establish the definition and aggregation of `PG.Qvalue` before setting an identification filter. Protein-identification q-values and differential-abundance BH-FDR answer different questions.

Source search/export settings should establish database, species, decoy handling, identification FDR, normalization, shared-library/joint-search processing and what a missing quantity means. If peptide/precursor outputs later become available, use them for identification QC and assay specificity, not as a gate for the concept of group-specific protein detection. Retain `PG.ProteinGroups` as the analytical identity, gene symbol as annotation, and report unresolved multi-protein groups before proposing targeted clinical assays.

### Detection / Unique-protein analysis

Use binary detection defined as finite positive raw abundance, consistent with the frozen project, conditional on confirming that export semantics support it. Abundance NA is not zero abundance; binary 0 means not detected under this assay. Detection can depend on concentration, interference, identification confidence and handling.

Maintain the complete technically valid mother list. For inferential testing, prefer a pooled, label-independent variability/count rule, such as at least 10 detected and 10 nondetected participants in the relevant analysis population, declared as a pragmatic testability criterion rather than a biological threshold. Retain all remaining proteins descriptively, including universally detected or rare ones. This proposed rule is not frozen until v2 approval; it avoids carrying the old group-max ≥60% outcome-dependent filter into a new confirmatory claim. For sparse subsets, report non-estimability rather than loosening thresholds to obtain a result.

Fit adjusted binary logistic models for detection with Group and Environment, parallel to abundance. A prespecified bias-reduced/Firth approach（偏倚校正逻辑回归）is appropriate for sparse/separated tables; choose the estimator and compatible likelihood-based intervals/tests before running all proteins. Existing ordinary-logistic outputs that record separation as non-estimable remain historical evidence, not zero effects. Fisher's exact test can be an unadjusted sparse-table companion, not a substitute for the adjusted primary question. For pooled exposure use standardized predicted detection probabilities from the categorical model and the fixed Low/High weights; mixing probabilities is not equivalent to averaging log odds.

Report detection counts/denominators, rates with intervals, adjusted odds ratios and preferably standardized risk differences. Test the exposure contrast, Group omnibus, and three pairwise contrasts with the same family structure as abundance, separately labeled as detection families. Include Environment interactions and site detection analyses only in their declared secondary/exploratory families. Correct formal tests across all eligible proteins, not just threshold-selected “specific” examples.

**Group-enriched detection** means a higher detection probability, supported by effect magnitude/uncertainty and, when inferential, adjusted testing. **Group-specific detection** additionally requires a high target rate and demonstrably low rates in each comparator. A protein can be enriched without being specific.

Display the requested 50/60/70/80% target-rate grid as descriptive sensitivity with exact denominators. Do not treat each threshold as another chance for significance. Inspect Discovery-only detection distributions to assess assay feasibility before defining any new specificity criterion that might inform ML; do not use Validation distributions to pick it. Prefer an externally motivated comparator upper bound and uncertainty requirement. If no defensible bound exists, freeze enriched-detection analysis as primary and leave “specific” as descriptive graded evidence rather than manufacture a <20% rule. If a data-explored cutoff is eventually chosen, label it exploratory and fix it for future independent evaluation. Zero observed detections never establishes biological absence.

Environment/site-specific detection needs the same caution about group composition, sparse denominators and processing. Existing historical <20% classifications stay intact but cannot be promoted as a new validated specificity definition.

## G. Statistical analysis matrix

Universe notation: **T** = technically valid protein-group registry; **Q515** = T meeting frozen v2 quantitative coverage in all three full-cohort groups; **QD** = corresponding Discovery-only rule; **D515** = T passing the declared pooled detection-testability rule; **Mfold** = training-fold-only ML eligible universe. All counts after technical filtering remain unknown until authorized execution. Historical 1,434/1,445 are not overwritten.

| Scientific question | Population | Protein universe | Model/test | Contrast | Multiplicity | Validation strategy | Primary outputs |
|---|---|---|---|---|---|---|---|
| Control vs Exposure abundance | 515 | Q515 | limma Group + Environment | Weighted Low/High minus Control | BH over exposure protein tests | Full-cohort association; future external confirmation | log2FC, moderated CI, P/q, observed N, MA/effect plots |
| Control→Low→High architecture | 515 | Q515, not selected by a pairwise test | 2-df moderated Group F; standardized means | Low−C and High−C jointly; adjacent effects | BH over omnibus protein tests; shapes descriptive | Discovery-only stability if needed; external shape confirmation | Mean/CI profiles, heatmap, uncertain shapes |
| Control vs Low | 515 | Q515 | Same categorical model | Low−Control | Pooled 3×protein pairwise BH; per-contrast BH companion | Full-cohort association | Effect/CI/P/q and counts |
| Control vs High | 515 | Q515 | Same categorical model | High−Control | Same pairwise family | Full-cohort association | Effect/CI/P/q and counts |
| Low vs High | 515 | Q515 | Same categorical model | High−Low | Same pairwise family | Historical frozen branch separately | Effects, overlap and sign plots |
| Unique / differential detection | 515; Discovery only if ML screen | D515; descriptive T | Adjusted binary regression, prespecified sparse-data estimator | Exposure, omnibus Group, three pairwise | Separate exposure/omnibus families; pooled pairwise detection family | No abundance-subset replication claim | Rates/CI, OR/risk difference, q, specificity evidence |
| Environment-specific effects | 279 / 236 | Q515 with per-stratum estimability; parallel D515 | Group model within Environment | Exposure and pairwise | One declared secondary family across proteins × environments × four contrasts | Descriptive/secondary, not new independence | Forest plots, counts, effect intervals |
| Environment interaction | 515 | Q515; parallel detection universe | Group × Environment | Exposure difference-in-differences; 2-df Group interaction; pairwise interactions | BH across proteins for designated exposure interaction; separate omnibus family; pooled pairwise interaction family | v2 secondary; historical D06 retained | Interaction effect/CI/P/q, adjusted plots |
| Site-associated abundance/detection | 515 | Q515 / D515 | Group + Site; within-environment adjusted comparisons | Within-environment site deviations | Omnibus site family, then prespecified pooled follow-up family | Exploratory processing/context associations | Site/group count map, adjusted deviations, detection heatmap |
| Group-effect heterogeneity by Site | Estimable sites only | Same fixed registry, per-protein testability | Compare additive Group+Site vs estimable site-specific group effects | Exposure and three pairwise heterogeneity questions | BH across proteins per declared omnibus question; follow-up pooled | Exploratory with sparse-site limitations | Site effects/CI, heterogeneity estimates; missing cells explicit |
| LOO site influence | 515, each site removed; original D07 remains Discovery-only | Fixed corresponding universe, no re-selection | Refit same specified model | Exposure and three pairwise | Primarily descriptive stability, not repeated significance hunting | Influence robustness only | Δeffect, sign, interval, estimability by omitted site |
| Frozen association replication | Existing 386→129 | Existing D01 1,445→D03 85 | Existing limma implementations | High−Low (legacy Long−Short) | Discovery BH 1,445; Validation BH 85 | Preserve chronology and all 85 denominator | 83 directional, 29 nominal, 1 FDR-supported |
| Biomarker development/evaluation | 386 development; task-specific subsets; fixed 129 evaluation | Mfold; frozen final list | Nested CV Elastic Net; optional one comparator | Primary C vs Exposure; three secondary binary; exploratory multiclass | One fixed primary performance endpoint; label all secondary comparisons, adjust formal multiple superiority tests if made | Reused within-cohort holdout; new external cohort required | AUROC/CI, AUPRC, calibration/Brier, threshold metrics, stability |
| Pathway/function | 515 biology; Discovery if predictor development | Tested/mapped universe for the exact analysis | Direction-aware ranked set analysis; ORA secondary | Exposure, signed pairwise; profile-specific descriptive sets | Across pathways in declared database/contrast families | Hypothesis-generating biology; no independent validation by enrichment | Direction, enrichment statistic, q, mapped set sizes |

### Environment implementation and interpretation

Use six Group × Environment cell means or an equivalent full-rank interaction parameterization. For fixed `w=186/362`, the exposure interaction is:

`[w μLow,H + (1−w) μHigh,H − μC,H] − [w μLow,A + (1−w) μHigh,A − μC,A]`.

H/A refer to the two environments, not High exposure. Pairwise interactions are the corresponding difference-in-differences. A 2-df omnibus asks whether the two Group contrasts jointly vary by Environment. The exposure interaction is not interchangeable with this omnibus: opposite subgroup modifications can cancel in the pooled contrast. Distinguish these families in reporting and do not combine their smallest P values.

Show overall estimates first, then standardized/stratum estimates and formal interaction intervals. Exposure×Environment is a secondary v2 analysis, not retrospectively confirmatory merely because its formula is frozen now. Existing D06 has 0/85 BH-supported interactions for each contrast; this does not establish homogeneity or rule out moderate effects. Differences between pathway significance lists likewise do not test pathway-level interaction.

### Actual site structure and recommended site model

Read-only counts from canonical metadata and the frozen assignment:

| Site | Environment | Control | Low | High | Discovery | Validation |
|---|---|---:|---:|---:|---:|---:|
| FJ_FQ | Humid-hot | 13 | 24 | 32 | 54 | 15 |
| FJ_PT | Humid-hot | 4 | 10 | 12 | 19 | 7 |
| FJ_QZ | Humid-hot | 32 | 18 | 11 | 44 | 17 |
| GZ_TH | Humid-hot | 46 | 31 | 46 | 92 | 31 |
| XZ_GG | High-altitude | 30 | 66 | 46 | 110 | 32 |
| XZ_YA | High-altitude | 2 | 19 | 1 | 17 | 5 |
| XZ_YB | High-altitude | 10 | 0 | 0 | 9 | 1 |
| XZ_YC | High-altitude | 6 | 7 | 21 | 22 | 12 |
| XZ_YD | High-altitude | 10 | 11 | 7 | 19 | 9 |

For adjusted site descriptions and Group robustness, prefer fixed site intercepts（站点固定效应）given nine observed, nonrandomly sampled sites. `Group + Site` absorbs Environment's main effect; adding a redundant Environment main-effect column is not valid. Compare site deviations within Environment to avoid describing nested geography as independent evidence of an environmental main effect. A site-adjusted Group×Environment sensitivity can use site intercepts plus estimable Group slopes and Group×Environment slope terms, omitting the redundant Environment intercept and checking rank explicitly.

A random site intercept（站点随机截距）can provide partial pooling in a secondary mixed model, but nine sites and four/five per environment provide limited support for variance estimation and broad population generalization. Random slopes or a large saturated interaction model are not the minimum defensible approach. Ordinary cluster-robust SEs based on nine clusters also do not automatically solve inference.

Site heterogeneity needs **direct differences of Group effects across sites**, using supported cells. For each contrast, construct an estimable within-site model and test the equality of supported site effects; do not include a phantom exposed XZ_YB cell. XZ_YA's 2/19/1 composition makes its extreme-looking estimates unreliable. A transparent exploratory restriction could require ≥10 participants in each contrasted cell (and sufficient observed values per protein), frozen as a stability convention, not a universal threshold. Display smaller cells descriptively. If all-site tests are retained, show intervals and dependence on sparse sites.

Meta-analytic Q/I² or random-effects summaries are optional descriptive complements, not substitutes for confounding control; few eligible sites and imprecise site effects make heterogeneity estimates uncertain. Failure to detect heterogeneity is not evidence of equivalence.

D07 already removes five Discovery sites with N≥20 and reports 85×5 estimates. Preserve it as influence analysis. Its stable directions cannot establish homogeneous site effects. New full-cohort LOO uses a fixed universe, reports non-estimability after removal, and does not redefine candidates or call every reduced-data P-value loss a failure of robustness. Site/date alignment, notably GZ_TH with 20260717 and XZ_GG with 20260527, prevents separating those site intercepts from their acquisition-date effects.

### Pathway and functional analysis

Use one primary curated resource, preferably Reactome, plus GO Biological Process as a secondary view; include KEGG where identifier mapping and access are adequate, recording a reason if unavailable. Record database release and species mapping. Freeze a deterministic protein-group→gene mapping policy, handling ambiguous and duplicate gene mappings without selecting the accession or duplicate with the smallest P. Retain the number excluded/unmapped and do not silently multiply one protein group's evidence across genes.

For exposure and signed pairwise contrasts, prefer a direction-aware ranked analysis over all tested mapped proteins using an appropriate signed statistic, not a list of significant proteins alone. Account for correlation between proteins where the method permits; CAMERA is a relevant correlation-aware competitive option. Its applicability to missing values and the chosen protein model must be checked before implementation. Do not zero-fill to satisfy a pathway tool. [Wu and Smyth, CAMERA](https://pmc.ncbi.nlm.nih.gov/articles/PMC3458527/).

Over-representation analysis（过度代表分析, ORA）is secondary and uses **the mapped proteins eligible and tested for that exact contrast**, not the whole human genome, all 3,817 irrespective of eligibility, or only DEPs. Detection enrichment uses the detection-test universe. Profile-family ORA uses the quantitative universe from which Group-associated profiles were selected and is descriptive/selection-conditioned; a direct profile-versus-other-associated comparison has the different background of Group-associated proteins and must be labeled separately. Very small families, such as seven proteins, may yield unstable or no enrichment.

Do not combine up/down DEPs indiscriminately. A three-group omnibus F statistic has no signed direction; use increasing/decreasing and nonlinear profile descriptions separately rather than calling a signed GSEA on that F statistic. For Low peaks, use the two relevant contrasts or a declared peak contrast with the caveat that a peak contrast alone does not establish both inequalities. For Environment, show shared effect/enrichment patterns; “significant in one environment only” is not an interaction test.

Define BH families across pathways for the primary database/contrast; if claiming significance from any resource or pairwise contrast, use a pooled declared family or explicitly state database/contrast-specific control. Report tested pathway counts, mapped universe sizes, directional effects, set size limits and redundant-term handling. D10's `NOT_RUN_NO_APPROVED_MAPPING` remains historical status. Pathways do not rescue a failed replication or establish mechanism.

## H. Figure and table plan

The current repository already contains substantial cohort/QC material, complete-case PCA and UMAP source availability, abundance figures and a frozen prospective figure-content plan. Improve reporting and integration before commissioning duplicate plots. The v2 manuscript layout below is a proposed versioned architecture; the existing prospective scientific content and unfavorable replication outcomes remain visible.

| Main figure | Scientific content | Key safeguards |
|---|---|---|
| 1. Cohort and proteome landscape | Study chronology, 519→515 group eligibility, technical-filter/coverage flow, Group/Environment composition; depth/missingness and PCA panels | Distinguish historical full cohort from later split; label protein groups, not peptides; do not invent post-contaminant counts |
| 2. Overall exposure biology | Weighted Exposure−Control effect/CI summary, MA plus concise volcano, selected transparent examples, differential detection and direction-aware pathways | Shared eligibility, selection rule for displayed examples, effect sizes not significance alone |
| 3. Ordered profiles and pairwise context | Omnibus-associated adjusted profiles with uncertainty; annotated heatmap; pairwise effect matrix and UpSet | No Low-vs-High-only starting set; no inferential trajectory claims from shapes alone |
| 4. Environment and site robustness | Stratum forest plots, formal interaction effects, site/date composition or processing signatures, LOO effect shifts | Show intervals and missing cells; no comparison of significance as heterogeneity evidence |
| 5. Frozen split-sample replication | Discovery/Validation effects, all-85 evidence counts, uncertainty/attenuation, chronology | 83 directional / 29 nominal / 1 FDR-supported; distinguish existing approximate CIs; not “85 validated” |
| 6. Biomarker evaluation, only if developed | Nested-development flow, final frozen panel, primary ROC/PR, calibration, threshold confusion table and stability | Reused hold-out label, all predefined model/task outcomes; no performance placeholders presented as results |

Recommended supplements: participant/site/date composition; pre/post-eligibility abundance and missingness distributions; ≥50/60/70/80% detection coverage; detection-rate heatmaps; complete pairwise volcano/MA/effect tables; full profile heatmaps; normalization and missingness sensitivities; environment and site detail; frozen D04–D10 support; secondary prediction tasks, feature frequencies and site-held-out performance. UMAP（均匀流形近似与投影）is optional exploratory visualization with fixed seeds/parameters; neither UMAP nor PCA separation tests exposure effects. Color the **same coordinates** separately by Group, Environment and Site, rather than choosing a different attractive embedding for each. State complete-case selection or display-only imputation explicitly and keep it outside inferential/ML inputs.

For all protein figures use gene symbols where available, retaining protein-group IDs in source tables and disambiguating repeated symbols. Give panel-specific N, error-bar definition, test, multiplicity family and selection rule. Heatmap row z-scores are display transforms; they must not be mistaken for modeled abundance. Avoid selecting top proteins by their Validation P values.

| Table | Required content |
|---|---|
| Main Table 1 | Overall/Control/Low/High counts; Environment, Site and available handling covariates. Age/sex/BMI/smoking/alcohol/BP/clinical variables only when actually supplied, with missingness. No fabricated demographics. |
| Discovery/Validation characteristics | Overall and Environment×Group composition, site counts and available baseline covariates; standardized mean differences（标准化均差）with definitions rather than baseline P-value screening. Zero/near-zero stratification differences are expected by construction. |
| Proteomics QC | Raw/eligible sample and protein counts, exclusion reasons, contaminant registry counts when available, depth, missingness, coverage thresholds, identification/export-field availability and definitions. |
| Differential abundance | Every tested protein, contrast, observed N, effect/SE/CI/P, explicitly scoped q-values, direction and estimability; compact main summary counts. |
| Detection / Unique proteins | Numerators/denominators, rate intervals, risk differences/ORs, corrected tests, threshold-grid annotations, specificity definition and sparse-model status. |
| Environment | Overall/stratum effects, interaction estimates, CIs, scoped q-values and cell sizes, including null findings. |
| Site | Group/site/date composition, depth, missingness, flagged processing signatures, estimable site effects, heterogeneity and LOO influence as separate columns/tables. |
| Frozen replication | All 85, Discovery and Validation effects/P/q/CI type, concordance, nominal and FDR support, including failures; no rescored evidence ranking. |
| Biomarker performance | Task/class counts, exact model/panel, nested-development estimates, reused hold-out metrics/CI, calibration, failures, subgroup precision and comparator results. |
| Pathway supplement | Resource/version, mapping, background, set sizes, analysis direction/statistic, raw P/q, multiplicity family and unmapped counts. |

## I. Existing-code reuse map

These classifications authorize **no edits**. “Needs modification” means a future versioned derivative or specifically authorized correction; frozen outputs remain available. “Superseded” describes a role or claim, not permission to delete.

| Script/result | Classification | Recommended reuse or boundary |
|---|---|---|
| `code/P1.py`, `P2.py`, `P3.py`; final sample mapping | KEEP AS-IS | Preserve identity resolution and positional contracts; do not rematch by ambiguous short sample names. |
| `execute_discovery_validation_split.R`, protocol/specification, assignment | KEEP AS-IS | Do not rerun, rebalance or add site stratification retrospectively. |
| `descriptive/01_describe_proteomics.py` through `04_complete_four_layers.py`; existing coverage/composition CSVs | REUSE WITH NEW REPORTING | Existing raw landscape and denominators can support Figure 1; add explicit pre/post technical-filter accounting only in v2. |
| `descriptive/05_dose_quantitative_filtering.py`, `stage05_normalization_helper.py` | KEEP AS-IS historical; NEEDS MODIFICATION for v2 derivative | Preserve old 1,434; new registry exclusions and separate universe rules cannot be silently inserted into old outputs. |
| `descriptive/06_covariate_QC.R`, `covariate_QC/` | REUSE WITH NEW REPORTING | Available handling metadata/PCA sources useful; distinguish token completeness from semantic validity; clinical gaps remain. |
| `descriptive/07_limma_dose_analysis.R`, `limma_dose_analysis/results/01_PRIMARY/` | KEEP AS-IS historical; NEW ANALYSIS REQUIRED for expanded hierarchy | Reuse model logic; add exposure contrast, omnibus, adjusted profiles and v2 multiplicity in a separately authorized implementation. |
| `08a_limma_core_figures.R`, `10a_DEP_characterization.R`, `10b_DEP_effect_size_summary.R` | REUSE WITH NEW REPORTING | Plotting/table conventions reusable, but do not substitute old selected universes or effect-size tiers for v2 inference. |
| `08b_limma_robustness.R`, `08c_run_replication.R`, `08d_integrated_results.R` | REUSE WITH NEW REPORTING | Historical sensitivities remain useful. Acquisition/run-stratified analysis is not independent participant replication merely because it says “replication.” |
| `stage05_detection_helper.py`, `09_detection_pattern_analysis.R`, detection outputs | KEEP historical; NEEDS MODIFICATION in v2 | Binary mother-data logic reusable. Reconsider old <20% specificity, group-max ≥60% universe, estimator/separation handling and expanded hierarchy. |
| `11a_dose_pattern_classification.R`, `11b_protein_clustering.R`, `12_pattern_protein_annotation.R` | REUSE WITH NEW REPORTING; SUPERSEDED as whole-proteome profile evidence | Preserve selected-256 descriptions; do not generalize their shape counts to all proteins. No new clustering required merely for manuscript completeness. |
| `13a_canonical_256_DEP_master.R` and Stage13A table | KEEP AS-IS | Canonical historical master; not a new predictor screen or new Discovery universe. |
| `missingness_robustness/` | KEEP AS-IS / REUSE WITH NEW REPORTING | Existing D0–D3 comparisons demonstrate assumption sensitivity for the historical branch; do not promote highest-DEP method. |
| `discovery_validation/D01_discovery_eligibility.py`, code D02/D03 and their outputs | KEEP AS-IS | Correctly bounded frozen selection branch; review CI implementation separately, without redefining candidates. |
| `discovery_validation/code/dv_shared.R` | NEEDS MODIFICATION only through authorized versioned correction | Normal-CI approximation and 0/0 SE edge case; distinguish correction from protocol redesign. |
| Prospective D04 | REUSE WITH NEW REPORTING | Selected-85 descriptive shape logic; `Modeled_mean` actually raw observed mean. Not general proteome architecture. |
| Prospective D05/D06/D07 and outputs | KEEP AS-IS / REUSE WITH NEW REPORTING | Selected-family secondary environment characterization and site influence, not fully independent confirmation or site heterogeneity tests. |
| Prospective D08 and output tables | KEEP AS-IS | Report original primary replication without selecting a more favorable success definition. |
| Prospective D09/D10 | REUSE WITH NEW REPORTING | Detection support useful; unique-peptide unavailable and pathway not run. Peptide dependence SUPERSEDED as biological main-line requirement. |
| `discovery_validation/code/figures_prospective.R`, `FIGURE_PLAN.md`, smoke-test figures | REUSE WITH NEW REPORTING | Existing frozen scientific content must survive integration into v2. Smoke-test graphics are not already publication-final. |
| `descriptive/archive/` | SUPERSEDED for current execution | Historical archive remains read-only reference; not a competing current pipeline. |
| Exposure/omnibus v2, technical annotation audit, justified specificity, site heterogeneity, functional analysis and ML | NEW ANALYSIS REQUIRED | Only after v2 choices and outstanding source facts are resolved and execution separately authorized. |

## J. Historical 256 vs prospective 85 reconciliation

### Verified comparison, not a conjecture about thresholds

| Component | Historical full cohort | Frozen Discovery | Reconciliation |
|---|---|---|---|
| Participants | 515; C/L/H=153/186/176 | 386; C/L/H=115/139/132 | Different estimation sample; Discovery is a subset, not independent of the historical analysis |
| Starting proteins | 3,817 raw groups | Same 3,817 raw groups | Same source protein identities |
| Detection | Finite positive quantity | Finite positive quantity | Same rule |
| Coverage | ≥70% separately in each full-cohort group | Same algorithm separately in each Discovery group | Different realized membership, not different scientific threshold |
| Minimum detected counts | 108 / 131 / 124 | 81 / 98 / 93 | Integer requirements follow group N |
| Eligible universe | 1,434 | 1,445 | Shared 1,426; historical-only 8; Discovery-only 19 |
| Transform/normalization | log2(PG.Quantity); no additional primary normalization | Same | Not a changed downstream normalization method; upstream search normalization remains to document |
| Missingness | NA retained; no imputation; 46,443 missing cells / 6.2887% | NA retained; no imputation; 35,180 missing cells, approximately 6.31% | Same handling, different cells/sample mix |
| Model | `~0 + dose + environment` | Same model family | Environment alias/reference names differ, not the adjusted High−Low estimand |
| Estimation | lmFit → contrasts.fit → eBayes trend=TRUE, robust=TRUE | Same | Fits and empirical-Bayes hyperparameters re-estimated on respective data/universes |
| Primary selected contrast | High_vs_Low | legacy `Long_vs_Short` = `dosehigh−doselow` | Same biological comparison and sign |
| Covariates | Environment only | Environment only | No age/sex/site change explaining the count difference |
| BH family | 1,434 for that contrast | 1,445 for that contrast | Different family membership and P-value distribution; not a pooled three-contrast historical selection |
| Candidate threshold | BH<0.05, no hard logFC cutoff | Same | Same selection threshold |
| Significant candidates | 256, all negative | 85, all legacy `Higher_in_Short` (higher in Low exposure) | Different results under the same procedure applied to different estimation samples |
| CI output | Stage07 primary CSV has no CI fields | Shared helper emits normal-approximation CI | Reporting difference does not cause candidate-count difference |

Read-only exact-ID intersections of `PRIMARY_dose_quantitative_proteins.csv`, D01 eligible list, historical primary High_vs_Low CSV and D02 Long_vs_Short CSV establish:

- All **256 historical DEPs remain eligible in Discovery**. None disappeared because it failed Discovery eligibility.
- All **85 Discovery candidates also belong to the historical eligible universe**.
- **84** candidates overlap; **172** historical DEPs are not Discovery-significant; **1** Discovery-significant protein was not historical-significant.
- Consequently, all 173 changed significance classifications occur among proteins eligible in both analyses. The modest membership change can still affect BH and empirical-Bayes estimation, but direct removal of the 256 is not the explanation.

The supported explanation is changed sample information and realized effect/variance estimates, with separately estimated moderation and BH over different eligible families. A smaller development sample ordinarily reduces precision, but the exact share of the 256→85 difference attributable to sample size, composition, moderation or BH **cannot be causally apportioned from table inspection**. That would require counterfactual refits explicitly prohibited in this audit. Do not say “the entire difference is power,” or blame different imputation, normalization, contrast or covariate adjustment, since those primary choices are verified as the same.

The historical table remains useful full-cohort evidence. Its existing counts also include 14 Low-vs-Control BH discoveries and 0 High-vs-Control discoveries under historical per-contrast BH. These facts do not prove absence of a High-vs-Control response and must not determine a favorable new primary endpoint. After a justified contaminant audit and expanded hierarchy, revised outputs may supersede historical tables **for v2 primary reporting**, while the old results and exact changes remain traceable. No v2 count is predicted here.

## K. Proposed execution order

### Dependencies and freeze points

1. **Resolve factual definitions first.** Apply the author-confirmed exposure-level, Environment, Site, plasma and participant definitions. Resolve remaining search/export settings and intended assay deployment details; optional clinical metadata do not block core analysis. Inventory prior access honestly. Do not rerandomize.
2. **Freeze technical-contaminant and identification rules.** Use external/search evidence, not a protein's desirable association or Validation performance. This must precede every revised universe. Unknown contaminant status is a source limitation, not a zero-removal conclusion.
3. **Freeze the registry and universe algorithms.** One stable protein identity/exclusion registry; distinct full-cohort abundance, detection, Discovery and fold-specific ML rules. Freeze algorithms now, materialize cohort/fold lists at their permitted stage. A fixed full-cohort eligible list must never serve as a fold-trained filter.
4. **Freeze biological contrasts and inferential families.** Specify exposure weights, Group omnibus, pairwise signs and pooled/per-contrast q-value scopes, covariates, normalization/missingness, per-protein estimability, site restrictions, and prospective-vs-exploratory labels. Define CI implementation for new outputs and a separate proposal for correcting existing approximate reporting.
5. **Freeze detection definitions.** Determine primary testability/estimator and enriched-detection claims. Retain 50/60/70/80% as descriptive thresholds. Freeze a justified specificity bound only if supplied; otherwise do not make a binary specific-protein primary claim. Do this before testing for attractive biological results or forming ML screens.
6. **Freeze and develop ML before any further full-cohort feature interpretation.** Lock tasks, algorithm, preprocessing, folds, grids, strategy comparison, panel/threshold/calibration selection and evaluation metrics. Carry out development within Discovery, then lock the final pipeline. The previous access limitation persists; procedural restraint now prevents additional contamination.
7. **Perform the once-only reused hold-out evaluation after lock.** Save all prespecified outcomes, including failures. Never use it to revise the panel and retest as if independent. Plan new-cohort/targeted-assay confirmation separately if claims warrant it.
8. **Execute the authorized v2 full-cohort biology and QC modules.** Quantitative and detection analyses follow the same Group hierarchy; estimate overall effects before secondary environment/site interpretation. Existing frozen D01–D10 results are reported, not regenerated. The recommended chronological separation protects ML choices even though figures will start with full-cohort biology.
9. **Run focused sensitivities and functional interpretation.** Fixed mapping/background is required before pathways. Use site/processing, normalization and missingness sensitivity only for identified assumptions; preserve null interaction and replication findings. Do not add model shopping to obtain consistency.
10. **Integrate figures/tables and claim audit.** Verify counts, denominators, CI types, multiplicity scopes, unavailable fields, selected-universe limitations and model-lock history. Preserve the eight scientific modules but avoid eight redundant main figures. No further inference merely to beautify figures.

All five requested items need freezing before their downstream use: contaminant rules, canonical identity/universe rules, contrasts, detection definitions and ML protocol. They do **not** all imply one universal protein list, and freezing today does not retroactively make historical exploration prospective. The companion ANALYSIS_PLAN_v2.0.md now freezes method choices, with unresolved technical dependencies explicitly separated from execution authorization.

### AUTHOR_INPUT_NEEDED before v2 can be finalized

- Exposure ordering is resolved. Quantitative exposure measurements and duration, if later available, are supplementary metadata and do not redefine primary Group.
- Environment naming is resolved as High-altitude and Humid-hot; no separate high-pressure exposure is established.
- Recruitment-location meaning and intended common SOP are resolved. Detailed preanalytical records remain unavailable; intended deployment population and assay use require later translational specification.
- Search database/contaminant flags, identification settings, Spectronaut normalization and pooled-search/library details; relevant sample-processing and instrument QC records.
- Whether age, sex, BMI, smoking and other baseline variables can be linked to existing participant IDs; interpretation of handling tokens, zero values and units.
- The v2 strict observed-specific category is descriptive with zero comparator detections and a declared target-threshold grid; it is not a claim of biological absence or a universal assay cutoff.
- Availability of genuinely new participants and a targeted measurement assay for future independent panel confirmation.

These gaps do not prevent a complete protocol document. Unresolved technical prerequisites block only dependent execution; optional participant metadata do not block core proteomics. No clinical validation is claimed.

### Final answer — smallest scientifically complete plan

Use one coherent categorical Group model on all 515 participants for a prespecified weighted Exposure−Control contrast, a proteome-wide Group omnibus/profile description and the three pairwise comparisons. Add one parallel adjusted detection analysis, one direction-aware pathway analysis, and focused Environment interaction plus Site/processing sensitivity. Retain the complete historical 256 and frozen 85-protein replication evidence with their actual denominators and chronology. Develop only the primary exposure classifier using Discovery-only nested Elastic Net initially, permitting a small panel only if its performance and membership are stable; keep the other tasks secondary/exploratory. Evaluate the locked model once on the reused 129 and state the limitation prominently.

**No analysis plan using only these already explored 515 people can supply a newly untouched independent replication or external biomarker validation.** The smallest plan that also supports that stronger claim adds a genuinely new cohort measured with a locked assay/model. Otherwise the scientifically rigorous endpoint is full-cohort association, historically prespecified split-sample support, and carefully bounded within-cohort prediction evaluation. A negative or unstable panel result is a valid completion of the study.

### Earlier outline, reconciled with the companion v2.0 specification — not executed

1. **Identity, scope and chronology.** Plasma proteomics; independent participant unit; ordered exposure-level terminology; unchanged 386/129 assignment; prior full-cohort and Validation access disclosed.
2. **Technical QC and identity registry.** Confirmed exclusions, flagged processing signatures, stable protein-group keys, available identification evidence and sample failure rules.
3. **Analysis universes.** Separate Q515, detection and training-fold rules; ≥70% common quantitative coverage unless explicitly revised with justification; no zero-filled abundance inference.
4. **Biological endpoints.** Weighted Exposure−Control primary v2 association; independent-of-primary-significance Group omnibus/profile module; three secondary pairwise contrasts with frozen sign and multiplicity rules.
5. **Models and uncertainty.** Existing limma primary handling retained; properly defined moderated intervals in new outputs; covariate availability, estimability, missingness and sensitivity boundaries specified.
6. **Detection module.** Adjusted differential detection, declared sparse-data estimator, descriptive 50/60/70/80% grid; specificity only with a justified frozen comparator definition.
7. **Context and robustness.** Overall then Environment estimates, direct interactions, nested-site and acquisition limitations, targeted site heterogeneity and separate LOO influence checks.
8. **Function and reporting.** Frozen mapping/database/background, direction-aware pathways, nonredundant figure plan and complete effect-level source tables.
9. **Historical replication module.** Original High-vs-Low family of 85 (legacy Long-vs-Short); original 83/29/1 evidence hierarchy, all-candidate denominator, complete null/failure reporting; no retrospective redesign.
10. **Prediction module.** Primary Control/Exposure Elastic Net; Discovery-only nested preprocessing/selection; Strategy B primary, A secondary if prespecified; at most one nonlinear comparator; complete pipeline/panel/threshold lock.
11. **Evaluation and claim limits.** AUROC primary with calibration/AUPRC/Brier and locked-threshold metrics; CIs and site/environment diagnostics; reused 129 explicitly identified; external cohort required for new independent/clinical claims.
12. **Authorization boundary.** Resolve the factual gaps, approve exact v2 specifications, then authorize implementation separately. This audit changes no frozen protocol and stops before implementation.

## ACTIVE V2.1 AMENDMENT — 2026-09-28
Forward-looking analysis and manuscript work are now governed by `docs/protocol/ANALYSIS_PLAN_v2.1.md`.
Key changes:
- Unique-peptide evidence is removed from active project scope. Historical frozen D09/D10 fields may remain physically present but are ignored downstream.
- The main biomarker-development target is High exposure vs Low exposure.
- The main biomarker candidate space is the 85 Discovery-only locked High-vs-Low DEPs.
- The 29 same-direction + nominal-P replicated proteins are replication evidence only and are not ML inputs.
- DEP-driven ML uses Elastic Net as the primary sparse model, Boruta as feature-relevance robustness, and XGBoost as nonlinear robustness.
- A strict fold-local differential-screening + ML nested sensitivity is required to assess the complete discovery-to-model pipeline.
- Existing completed all-proteome M15/M16 results remain frozen historical/supplementary evidence and must not be retuned or re-evaluated on the same 129 as though it were a new independent test.
- Site/heterogeneity/LOO remain required robustness analyses.
- Pathway/enrichment remains required and blocked pending an approved reproducible mapping/resource contract.
- Manuscript integrated reporting combines abundance, detection, missingness robustness, Environment/Site robustness, replication, ML and pathway evidence; no Unique-peptide axis and no composite evidence score.

