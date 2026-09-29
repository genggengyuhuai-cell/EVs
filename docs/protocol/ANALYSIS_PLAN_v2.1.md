# Plasma proteomics — Analysis Plan v2.1 amendment
Specification date: 2026-09-28, America/Los_Angeles. Repository: `F:/env`.
Status: **CURRENT FORWARD ANALYSIS AUTHORITY.** This amendment supersedes the forward-looking parts of `ANALYSIS_PLAN_v2.0.md` while preserving all already-frozen historical analyses and outputs. It does not retroactively relabel completed analyses as preregistered.

## 1. Scope of this amendment
This amendment makes four coordinated changes:
1. Remove Unique-peptide evidence from the active project scope. No peptide-level source exists and no peptide-based evidence layer, panel, gate, figure or manuscript claim is required.
2. Align the main biomarker-development question with the established Discovery contrast: **High exposure vs Low exposure**.
3. Make the manuscript biomarker route **DEP-driven**, using the 85 locked Discovery High-vs-Low candidate proteins as the fixed biological candidate space for the main prioritization analysis.
4. Preserve already-completed all-proteome ML / reused-hold-out work as historical or sensitivity evidence; do not rerun or retune the fixed 129 on the basis of newly designed models.

Everything not explicitly amended here remains governed by v2.0 and the frozen historical contracts.

## 2. Current scientific architecture
```text
Plasma proteome
    |
    +--> full-cohort / v2 descriptive and abundance architecture
    |
    +--> Discovery n=386
            |
            +--> High vs Low differential abundance
            |       |
            |       +--> 85 locked Discovery candidates
            |               |
            |               +--> D08 reused hold-out replication evidence
            |               |       83/85 same direction
            |               |       29/85 same direction + nominal P<0.05
            |               |       1/85 BH-FDR<0.05
            |               |
            |               +--> DEP-driven multi-ML prioritization in Discovery
            |                       Elastic Net primary
            |                       Boruta feature-relevance robustness
            |                       XGBoost nonlinear robustness
            |
            +--> strict nested sensitivity:
                    repeat High-vs-Low differential screening
                    inside each outer-training split before ML
```

The two evidence branches are combined only at the **integrated interpretation** stage. Replication results from the 129 may not be used to choose, rescue or replace ML features.

## 3. Identity and terminology
- Analytical key: `PG.ProteinGroups`.
- Biological display annotation: `Gene_symbol`.
- ML features are **protein-abundance features**, not gene-expression measurements.
- A protein group may be displayed by gene symbol when the mapping is valid, but model joins, coefficients and locks remain keyed by `PG.ProteinGroups`.
- Use **DEP (differentially abundant protein)**, not DEG, for the proteomics discovery result.

## 4. Unique-peptide evidence is removed from active scope
Effective immediately:
- No Unique-peptide analysis is required.
- No Unique-peptide data gap is considered a blocker.
- No Unique-peptide field is required in integrated evidence tables.
- No Unique-peptide panel is allowed in manuscript figures.
- No ML tie-break, feasibility gate or biological ranking may depend on peptide specificity from unavailable project data.
- Frozen legacy D09/D10 artifacts may physically retain historical peptide-status columns. Those columns are ignored by all active v2.1 downstream work and should not be propagated into new outputs.

D09 is henceforth interpreted for active reporting as **missingness and detection evidence** only.

## 5. Main biomarker candidate space

### 5.1 Fixed candidate pool
The main biomarker-development candidate pool is the **85 proteins locked by D03 from the Discovery-only High-vs-Low differential-abundance analysis**.

### 5.2 Role of the 29 replicated proteins
The 29 proteins satisfying same direction plus nominal hold-out P<0.05 are **nominally replicated candidate proteins**.
They are **not** the ML input space because their definition used the reused 129 hold-out.

They may be used only for:
- replication summaries;
- integrated evidence tables;
- overlap/convergence reporting after ML is complete;
- biological discussion.

They may not be used to train, tune, select, rescue or replace features in the new DEP-driven ML analysis.

## 6. DEP-driven multi-ML module

### 6.1 Primary prediction task
Primary task: **High exposure vs Low exposure** within Discovery.
Discovery counts: Low = 139, High = 132.
Positive class: High exposure.

Control-vs-Exposure and other prediction tasks are not part of the main biomarker route. Existing completed results for those tasks are retained as historical/sensitivity analyses.

### 6.2 Fixed-85 prioritization analysis
The fixed-85 analysis asks which proteins within the Discovery-defined High-vs-Low candidate family provide stable multivariable discriminatory information.
This analysis is conditional on prior full-Discovery identification of the 85 candidates. Its internal CV performance must be described as **conditional / exploratory predictive performance**, not an unbiased estimate of the complete discovery-to-model pipeline.

### 6.3 Elastic Net — primary sparse model
Elastic Net logistic regression is the primary multivariable prioritization model.
Requirements:
- training-only median imputation;
- training-only centering/scaling;
- stratified resampling;
- no preprocessing fitted on assessment folds;
- report nonzero coefficients, selection frequency and sign consistency;
- prefer compact panels only when supported by prespecified tuning, never manual substitution;
- retain exact `PG.ProteinGroups` IDs and coefficients.

LASSO (`alpha=1`) is a member of the Elastic Net family and is not a separate evidence layer merely to increase model count.

### 6.4 Boruta — feature-relevance robustness
Boruta is a **feature-selection / relevance robustness method**, not the primary classifier.
Requirements:
- run inside training resamples only;
- report Confirmed/Tentative/Rejected status by training fit;
- summarize confirmation frequency across resamples;
- do not run Boruta once on all 386 and then claim subsequent CV is leakage-free.

### 6.5 XGBoost — nonlinear robustness
XGBoost is a secondary nonlinear model.
Requirements:
- tune only inside training data;
- use the same outer-assessment partitions where feasible;
- report AUROC/AUPRC and feature-importance stability;
- SHAP or equivalent importance is descriptive model interpretation;
- do not replace the primary model after examining the reused 129.

### 6.6 Cross-model convergence table
At minimum:
- `PG.ProteinGroups`
- `Gene_symbol`
- Discovery High-vs-Low log2FC
- Discovery BH-FDR
- Elastic Net selection frequency / coefficient summary
- Boruta confirmation frequency
- XGBoost importance stability
- D08 direction concordance
- D08 nominal replication
- D08 FDR-supported replication
- missingness robustness
- Environment interaction evidence
- Site / LOO robustness
- pathway membership after M12

Do **not** create a weighted evidence score or choose a winner by counting checkmarks.

## 7. Strict whole-pipeline nested sensitivity
For each outer training split:
1. derive training-fold quantitative eligibility;
2. fit High-vs-Low differential abundance using training participants only;
3. apply the prespecified fold-local differential screen;
4. pass only training-derived candidates into Elastic Net;
5. optionally repeat Boruta/XGBoost as secondary robustness analyses;
6. predict only the untouched outer assessment fold.

No full-Discovery 85 list is injected into this strict sensitivity.

## 8. Status of already-completed M15/M16
Existing completed M15/M16 outputs are preserved and must not be deleted or overwritten.
Forward role:
- Existing all-proteome / Strategy-B ML: **historical or supplementary predictive benchmark**.
- Existing M16 reused-129 once-only evaluation: **frozen completed evaluation attached to that already-locked model only**.
- Do not retune that model.
- Do not evaluate a newly revised DEP-driven model on the same 129 and call it a new unbiased hold-out validation.
- Any future definitive classifier validation requires genuinely new participants.

The reused 129 may still contribute already-frozen D08 replication evidence.

## 9. Site, heterogeneity and LOO
Site analyses remain required and unchanged in scientific role:
- Site is nested within Environment.
- Site association/heterogeneity is robustness/context evidence, not candidate generation.
- LOO remains descriptive robustness.
- Sparse/structurally absent Site × Group cells remain explicit limitations.
- ML features may not be manually altered because of favorable/unfavorable Site results.

## 10. Pathway / enrichment
Pathway analysis remains required but blocked until a reproducible mapping/resource contract is approved.
Requirements:
- deterministic gene-based mapping independent of P values/effects;
- GO Biological Process and Reactome required;
- KEGG optional only if mapping/resource access meets the threshold;
- ranked competitive analysis primary;
- ORA secondary;
- pathway results cannot retroactively choose ML features.

Unique-peptide availability is not a pathway prerequisite.

## 11. Manuscript figures, tables and integrated reporting

### Main figures
**Figure 1 — Cohort, workflow and proteome landscape**
- 519→515 cohort flow;
- 386/129 chronology;
- Group × Environment × Site composition;
- quantitative/detection coverage and QC.

**Figure 2 — Proteome-wide exposure associations**
- overall and pairwise abundance;
- detection;
- ordered/omnibus architecture;
- no ML content.

**Figure 3 — Discovery High-vs-Low candidate biology**
- 85 locked Discovery DEPs;
- effect-size display;
- Control/Low/High profiles;
- missingness robustness;
- candidate architecture.

**Figure 4 — Environment, Site heterogeneity and LOO**
- Environment-stratified estimates;
- formal interaction;
- Site context;
- LOO robustness/limitations.

**Figure 5 — Replication and DEP-driven ML prioritization**
- 83/85 directional;
- 29/85 nominal;
- 1/85 FDR-supported;
- Elastic Net stability;
- Boruta confirmation stability;
- XGBoost importance stability;
- overlap/convergence between replication and ML evidence;
- no composite evidence score.

**Figure 6 — Pathway and integrated biological interpretation**
- ranked pathway results after M12;
- ORA secondary;
- final integrated evidence landscape.

### Main tables
**Table 1:** cohort characteristics and metadata availability.  
**Table 2:** Discovery vs reused hold-out composition/balance and chronology.  
**Table 3:** 85-candidate integrated evidence table, without Unique-peptide columns.  
**Table 4:** prioritized ML feature/panel table with protein IDs, gene annotations, coefficients/stability and actually available assay annotations.

## 12. Active integrated evidence dimensions
```text
abundance association
+ detection evidence
+ missingness robustness
+ Environment interaction/context
+ Site / LOO robustness
+ reused-hold-out replication
+ DEP-driven ML prioritization
+ pathway/enrichment
```
Unique-peptide evidence is absent by design.
No evidence-count score, composite P value or post-hoc ranking is allowed.

## 13. Freeze boundary
Frozen and unchanged:
- historical v1 outputs;
- frozen 386/129 participant assignment;
- D03 85-protein family;
- D08 83/29/1 hierarchy;
- completed historical M15/M16 outputs and their already-used evaluation.

Amended prospectively:
- active ML target;
- active ML candidate architecture;
- Boruta and XGBoost robustness layers;
- strict nested whole-pipeline sensitivity;
- integrated reporting;
- removal of Unique-peptide evidence from active scope.
