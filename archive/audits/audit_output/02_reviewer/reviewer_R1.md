# Reviewer R1 Report, Pre-submission review of analysis-v2.1

Reviewer role  R1, emphasis on statistical rigor and experimental design.
I am one of three mutually blind reviewers. I received only the immutable source packet and this emphasis brief. I do not know the views of the other reviewers and I make no assumption about them.

## Review setup

- **Input scope**
  Author-side frozen audit documents and frozen result tables under F:\\env. No assembled manuscript text was provided. The claims I review are the claims recorded by the authors themselves in PROJECT_CONTEXT.md, the audit CSVs, the frozen result manifests and summaries, and the protocol documents.

- **Assessment boundary**
  The manuscript body, abstract, figure panels and tables have not yet been assembled. PROJECT_CONTEXT.md section 9 lists manuscript assembly as not started. I therefore cannot judge prose logic, abstract-body consistency, figure encoding, caption accuracy against rendered figures, or nonspecialist readability. Those axes are marked not assessable from the provided material. All technical judgments below concern the statistical design, multiplicity structure, replication hierarchy and claim wording as recorded in the frozen evidence. I did not rerun any analysis. Every number I cite is quoted verbatim from a named source file.

- **Shared manuscript claim summary**
  The study is an environmental-exposure EV-enriched plasma proteomics study. It enrolls 519 screened participants, uses a 515-analytical cohort split by a prospectively locked seed (20260925) into a 386 Discovery subset and a 129 reused hold-out subset. In the Discovery subset, a High-vs-Low exposure contrast yields 85 differentially abundant proteins under BH-FDR below 0.05. On the reused hold-out, the locked 85 give 83 direction-concordant estimates, 29 nominally significant (raw P below 0.05), and 1 surviving candidate-family BH-FDR below 0.05. The overall-exposure family is null at 0 of 1,430. The pure environment interaction family is null at 0 of 1,430. Fixed-85 conditional machine learning and a strict nested rescreen are presented as supporting sensitivity, and pathway analysis uses cameraPR as primary with ORA and fgsea as complementary and sensitivity layers.

- **Visible evidence base**
  PROJECT_CONTEXT.md, MANUSCRIPT_MODULE_MAP.csv, STATISTICAL_CLAIM_MAP.csv, FIGURE_TEXT_AUDIT.csv, WHOLE_PROJECT_SCIENTIFIC_REVIEW.md, REVIEWER_RISK_REGISTER.csv, STATISTICAL_REPORTING_AUDIT.md, EXPERIMENTAL_DESIGN_REVIEW.md, DISCOVERY_VALIDATION_PROTOCOL.md, ANALYSIS_PLAN_v2.1.md, plus frozen result manifests and summaries (D01_manifest.txt, D02_diagnostics.csv, D03_candidate_lock_manifest.csv, D08_manifest.csv, D08_replication_summary.csv, M07_manifest.csv, M10_corrected_manifest.csv, M14_replication_hierarchy.csv, M14_frozen_status.csv, outer_cv_metrics.csv, strict_nested_manifest.csv, strict_nested_outer_metrics.csv, and the header rows of D08_validation_results.csv, D03_locked_candidates.csv, M07_High_vs_Low.csv, M10_pure_interaction.csv).

- **Missing materials affecting confidence**
  Assembled manuscript text and rendered figures, participant-level covariate tables, batch and run-order records, and any power or minimum-detectable-effect calculation. These are noted as not assessable rather than treated as defects.

## Reviewer 1

### Overall assessment

This is a carefully frozen, procedibly honest discovery analysis. The authors prospectively locked the split, locked the 85 candidates before touching the hold-out, separated multiplicity families, and have already downgraded their own language in a direction that matches the evidence. The central empirical result is real as a within-cohort discovery.

At the same time, the inferential weight of the study is modest by construction. The reused hold-out (n=129) shares enrollment, sites, platform and processing batches with the Discovery subset. Only 1 of 85 candidates survives formal family-level replication correction. The interaction null rests on an environment variable that is entirely between-site. The machine learning performance hovers near chance on test folds of roughly 53 to 55 subjects. None of these is fatal given the cautious wording the authors have already adopted, but each must be visible in the final manuscript rather than buried.

My judgment is that the present frozen evidence supports a well-conducted, honestly bounded discovery report. It does not support a strong broad-readership claim at this stage. The main risks are not hidden analyses, they are wording risks once the manuscript is assembled.

### Who would be interested in the results, and why

Environmental exposome and plasma proteomics readers will care about a prespecified, FDR-controlled discovery pipeline with a fully documented discovery-to-hold-out hierarchy. Methodological readers interested in discovery-to-replication statistics in proteomics will care about the 85/83/29/1 hierarchy as a case study in how weak formal replication remains after nominal direction concordance. Readers of multi-site cohort proteomics will care about the site LOO and environment-stratified layers. I see little reason for a nonspecialist broad readership to engage until the external-validation and generalizability gap is closed by genuinely new participants.

### Major strengths

- The split was executed once with a prospectively locked seed (20260925), and the protocol records 26 integrity assertions passed (DISCOVERY_VALIDATION_PROTOCOL.md, execution provenance). Candidate locking (D03) preceded any access to the hold-out outcomes, as verified by the D08 manifest input chain.
- Multiplicity families are explicitly separated (STATISTICAL_REPORTING_AUDIT.md section 3) and not merged into a single unqualified FDR claim.
- Effect estimates carry confidence intervals at the protein level (D03_locked_candidates.csv and D08_validation_results.csv both report CI_low and CI_high).
- The authors' own risk register and claim map already prohibit the most dangerous overclaims (85 called validated, 29 called FDR-replicated, 129 called external validation, interaction written as absence, fixed-85 ML written as generalization).
- The strict nested sensitivity analysis forbids injection of the locked 85, the hold-out, pathway results or prior importance objects (strict_nested_manifest.csv forbidden list), which is the correct leakage control.

### Major Concerns

#### R1-M1

- **Severity** Major
- **Blocking** No
- **Axis** statistical-rigor
- **Claim pointer**
  STATISTICAL_CLAIM_MAP.csv rows C06, C07, C08 and M14_replication_hierarchy.csv present the reused hold-out hierarchy (85 estimable, 83 same direction, 29 nominal P below 0.05, 1 candidate-family BH-FDR below 0.05) as the replication evidence tier of the paper.
- **Evidence pointer**
  DISCOVERY_VALIDATION_PROTOCOL.md section 4 fixes hold-out cell sizes at Control 38, Short 47, Long 44. STUDY_DESIGN_AUDIT.md line 103 states verbatim "No assurance of adequate power follows simply from N=129. For prediction, sensitivity in 44–47 cases and specificity in 38 controls can be imprecise, especially at extreme thresholds." No power or minimum-detectable-effect calculation appears anywhere in the protocol. D08_replication_summary.csv reports FDR_rate_all = 0.01176 and Nominal_rate_all = 0.34118.
- **Concern**
  The 75/25 split was chosen for allocation, not justified by any stated detectable effect. With roughly 44 versus 47 subjects per exposure group in the hold-out, only large effects can achieve significance, which mechanically explains why direction concordance is high (83/85) while formal replication is 1/85. The hierarchy is interpretable, but the manuscript must state explicitly that the hold-out was not power-calculated and that the nominal 29/85 count is expected to mix true signal with small-sample noise.
- **Why it matters**
  Readers will otherwise read "29 nominally replicated" as a stronger signal than the design supports, and "1 FDR-supported" as a failure of the biology rather than a consequence of the hold-out being too small for family-level correction.
- **Resolution test**
  Methods or Discussion must report the hold-out group sizes (44/47/38), state that no prospective power calculation was performed, and present 1/85 as the upper bound of multiplicity-controlled replication rather than as a success or failure threshold.

#### R1-M2

- **Severity** Major
- **Blocking** No
- **Axis** experimental-design
- **Claim pointer**
  STATISTICAL_CLAIM_MAP.csv row C13, "No exposure x environment interaction survived the prespecified BH-FDR threshold (0/1430)", with M10_corrected_manifest.csv recording n_sig = 0 and dir_concordance_pct = 35.2 percent.
- **Evidence pointer**
  DISCOVERY_VALIDATION_PROTOCOL.md section 2 defines environment as site blocks (Humid-hot = FJ_FQ, FJ_PT, FJ_QZ, GZ_TH; High-pressure/high-altitude = XZ_GG, XZ_YA, XZ_YB, XZ_YC, XZ_YD) and states "Site is nested within Environment". EXPERIMENTAL_DESIGN_REVIEW.md section 2.3 states sites are not independent replication arms and are coupled to environment and possibly to processing batches. M10_pure_interaction.csv estimates E_Humid and E_HighAlt as two environment-level contrasts with no within-site environment replication.
- **Concern**
  The interaction estimand compares two environment blocks that contain entirely disjoint sites. The 2-degree-of-freedom Wald test therefore confounds site-level variation with environment-level effect modification. Under this structure, "no interaction survived threshold" cannot support even the careful hedged null, because the test has no ability to distinguish a true modification effect from site heterogeneity. The authors already label the test underpowered; the deeper issue is identifiability, not only power.
- **Why it matters**
  A null interaction result is one of the few inferential claims the paper makes about environment. If readers infer that environment does not modify exposure effects, they will be inferring more than the design can support.
- **Resolution test**
  The manuscript must state that environment contrasts are entirely between-site and that the M10 result is a descriptive null on a confounded estimand. The required wording should also note that within-site environment replication does not exist in this dataset.

#### R1-M3

- **Severity** Major
- **Blocking** No
- **Axis** statistical-rigor
- **Claim pointer**
  The discovery BH family that produced the headline 85 candidates is described inconsistently. STATISTICAL_CLAIM_MAP.csv row C05 gives N = 1430, and STATISTICAL_REPORTING_AUDIT.md section 2 says the primary inference is on "the 1,430 protein groups". PROJECT_CONTEXT.md section 2 says the 85 come from "BH-FDR < 0.05 on 1,445 Discovery-eligible proteins".
- **Evidence pointer**
  D01_manifest.txt records raw_protein_count = 3817 and eligible_protein_count = 1445 on the Discovery-only rebuild. D03_candidate_lock_manifest.csv confirms the candidate rule is Discovery Long vs Short BH-FDR below 0.05 applied to that D01 universe. M07_manifest.csv records n_proteins = 1430 for the full-cohort pairwise family. strict_nested_manifest.csv records n_universe = 1434. STATISTICAL_REPORTING_AUDIT.md section 17 lists Fig1d as 3817/3054/1430/1445/85, which is the only place all four numbers coexist.
- **Concern**
  Three different denominators (1445, 1430, 1434) float in the author-side documentation. The protocol (section 7) explicitly required rebuilding eligibility on the 386 Discovery participants rather than reusing the historical full-cohort list, which is how 1445 arose. The headline 85 candidates were locked from the 1445 family. If the assembled manuscript states the discovery family as 1430, it misstates the BH denominator that produced the central result.
- **Why it matters**
  The discovery family size is the denominator of the headline FDR claim. Reproducibility and any reanalysis depend on using the same universe.
- **Resolution test**
  Methods must state that the 85 were selected by BH-FDR below 0.05 across the 1,445 Discovery-only eligible proteins, and must separately name 1,430 as the full-cohort descriptive abundance universe and 1,434 as the pathway mapping universe.

#### R1-M4

- **Severity** Major
- **Blocking** No
- **Axis** claim-moderation
- **Claim pointer**
  STATISTICAL_CLAIM_MAP.csv row C16, fixed-85 conditional ML, and MANUSCRIPT_MODULE_MAP.csv row M15_fixed85, which places Fig5b/c/d in the main text plus supplement.
- **Evidence pointer**
  outer_cv_metrics.csv contains 15 outer splits with test n of 53 to 55. Verified ranges from that file are LASSO AUROC 0.499 to 0.775, Elastic Net 0.505 to 0.772, XGBoost 0.509 to 0.786. strict_nested_outer_metrics.csv shows fold-local DEP counts from 8 to 618 and LASSO AUROC 0.534 to 0.749.
- **Concern**
  The fixed-85 conditional performance is close to chance across all branches, and the strict nested rescreen shows that the selected feature set itself swings from 8 to 618 proteins depending on the resampling split. This is correctly framed as conditional and sensitivity work, but the figure placement (main text summary) and the near-chance numbers require explicit uncertainty language rather than a point-estimate impression.
- **Why it matters**
  Readers can easily read a boxplot of AUROC around 0.65 as evidence of predictive utility. The authors already prohibit that interpretation in C16, but the assembled figure and legend must carry the same prohibition visually.
- **Resolution test**
  Fig5 caption must state the test-fold size range (53 to 55), report the fold-level distribution rather than a single mean, and repeat the conditional-on-frozen-85 sentence. No clinical, deployment or prospective predictive wording may appear.

#### R1-M5

- **Severity** Major
- **Blocking** No
- **Axis** data-resource-quality
- **Claim pointer**
  STATISTICAL_CLAIM_MAP.csv row C04, reused hold-out n = 129, and the direction-concordance result C06 (83/85, rate 0.97647).
- **Evidence pointer**
  EXPERIMENTAL_DESIGN_REVIEW.md section 2.1 states the 129 subjects come from the same enrollment, sites, platform and processing batches, and that direction concordance is inflated relative to true external replication. Section 3.3 records processing batch as not explicitly modeled, freeze-thaw and storage as not reported, and MS run order as not reported as randomized. REVIEWER_RISK_REGISTER.csv rows R03 and R30 record preanalytical variables and run order as not controlled. D02_diagnostics.csv records normalization = NONE and imputation = NONE with 35,180 remaining missing cells.
- **Concern**
  Shared batches and unrecorded preanalytical structure are the most plausible mechanical explanation for high direction concordance between Discovery and hold-out. The manuscript must disclose what is known and unknown about batch, and must not let the 97.6 percent direction concordance be read as a validity indicator.
- **Why it matters**
  Direction concordance is the most intuitively convincing number in the replication hierarchy. If it is inflated by shared preanalytical structure and the paper does not say so, readers will over-weight it.
- **Resolution test**
  Methods state the available batch and run-order facts (including that they are not recorded), and Discussion lists shared preanalytical context as a reason direction concordance overstates external reproducibility.

### Minor Comments

#### R1-m1

- **Severity** Minor
- **Axis** statistical-rigor
- **Affected element** Fig2b pairwise contrasts
- **Evidence pointer** MANUSCRIPT_MODULE_MAP.csv row M07 lists per-contrast counts 13/0/257; M07_manifest.csv lists families A-LC, A-HC, A-HL; STATISTICAL_CLAIM_MAP.csv row C10 prohibits merging pairwise families into one FDR.
- **Issue**
  The three pairwise families (Low-Control, High-Control, High-Low) each carry their own BH adjustment. If the assembled figure or table presents a combined count, it silently merges families.
- **Required correction**
  Caption and table must name each family and its count separately (13, 0, 257 per the module map) and state BH was applied per family.

#### R1-m2

- **Severity** Minor
- **Axis** reproducibility
- **Affected element** Provenance of replication status
- **Evidence pointer** M14_frozen_status.csv rows state "ML M15 NOT_STARTED", "ML M16 NOT_AUTHORIZED" and "Pathway (frozen D10) NOT_RUN_NO_APPROVED_MAPPING", while ml_v2.1/results and M12 pathway outputs exist and are cited elsewhere.
- **Issue**
  This status file is stale relative to the current freeze. If cited in methods or supplement, it will contradict the actual ML and pathway results.
- **Required correction**
  Do not cite M14_frozen_status.csv as current provenance. Use the module manifests in ml_v2.1 and M12_pathway_v2.1 instead, or annotate the file as superseded.

#### R1-m3

- **Severity** Minor
- **Axis** figures-and-tables
- **Affected element** Fig4b interaction panel
- **Evidence pointer** M10_pure_interaction.csv columns include interaction_F, interaction_P, interaction_BH but no interaction effect-size CI; M10_corrected_manifest.csv records dir_concordance_pct = 35.2 percent.
- **Issue**
  A null result is more credible when readers see the distribution of estimated effects, not only the count surviving threshold.
- **Required correction**
  Show the distribution of interaction effect estimates in Fig4b and report the 35.2 percent stratified direction concordance as descriptive, alongside the 0/1430 threshold statement.

#### R1-m4

- **Severity** Minor
- **Axis** reproducibility
- **Affected element** Methods, abundance preprocessing
- **Evidence pointer** D02_diagnostics.csv records transformation log2(PG.Quantity), normalization = NONE, imputation = NONE.
- **Issue**
  Whether any upstream normalization was applied in rawdata processing is not visible in the frozen evidence I received.
- **Required correction**
  Methods must state explicitly whether normalization or reference adjustment was applied upstream of D02, or confirm that log2 PG.Quantity without normalization is the model input.

#### R1-m5

- **Severity** Minor
- **Axis** statistical-rigor
- **Affected element** Table 3 replication denominators
- **Evidence pointer** D08_replication_summary.csv records N_locked = 85 and N_estimable = 85, so the non-estimable count is zero. DISCOVERY_VALIDATION_PROTOCOL.md section 14 requires explicit non-estimable reporting.
- **Issue**
  The equality of locked and estimable counts should be stated, not inferred.
- **Required correction**
  Table 3 should explicitly show 0 non-estimable candidates so readers know all 85 were estimable in the hold-out.

#### R1-m6

- **Severity** Minor
- **Axis** reproducibility
- **Affected element** Methods, Boruta-style procedure
- **Evidence pointer** STATISTICAL_CLAIM_MAP.csv row C18 and STATISTICAL_REPORTING_AUDIT.md section 11 describe a hand-rolled ranger procedure with shadow features and a pooled binomial confirmation test, distinct from the CRAN Boruta package.
- **Issue**
  The implementation differs from the canonical package, and its exact confirmation rule is not visible in the result tables.
- **Required correction**
  Methods should describe the shadow-variable construction and the pooled binomial confirmation test in enough detail to reproduce the procedure.

### Technical failings that need to be addressed before the case is established

None that invalidate the central discovery result. The five Major Concerns above require wording, denominator clarification and limitation disclosure, not reanalysis. If the assembled manuscript violates any of the prohibited wordings already listed in the claim map (85 as validated, 29 as FDR-replicated, 129 as external validation, "no interaction" as absence, fixed-85 ML as generalization), those become blocking at assembly time.

### Assessment against Nature-style criteria

- **Originality**
  A prespecified discovery-to-hold-out proteomics pipeline on exposure categories is incremental rather than conceptually new. The honest hierarchy is a useful contribution, not a paradigm shift.
- **Scientific importance**
  Modest at present. The result is a discovery candidate family, not a validated panel, not a mechanism, and not an external generalization.
- **Interdisciplinary readership**
  Mostly of interest to exposome proteomics and proteomics methods readers. Broad significance is not established by this material.
- **Technical soundness**
  Good procedure (prospective split, locked candidates, separated families, CI reporting) combined with structural limitations (reused hold-out, confounded environment, unrecorded preanalytical, near-chance ML). Both sides must be visible.
- **Readability for nonspecialists**
  Not assessable, because the manuscript text has not been assembled.

### Recommendation posture

The frozen evidence is sufficient to support a carefully framed resubmission after major revision on wording and denominator transparency. I do not assess fit to a specific journal, and I make no editorial decision. From the statistical-design standpoint, the project can move to manuscript assembly if the five Major Concerns are closed in the text and the claim-map prohibitions are honored verbatim.

### Risk and unsupported claims visible to R1

- The claim that the reused hold-out provides any external validity is unsupported and already prohibited by the authors.
- Any use of "no interaction" as an absence statement would exceed the confounded estimand.
- Any performance implication from the fixed-85 ML boxplot would exceed the near-chance fold-level results.
- The 195 cameraPR pathways include 170 Reactome entries and are reported per method; they must not be summed with 23 ORA and 39 fgsea.
- EV-derived identity is not established; the material is EV-enriched plasma proteomics by the authors' own definition.
