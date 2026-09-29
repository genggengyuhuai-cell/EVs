# Whole-Project Scientific Review — v2.1 (EV / plasma proteomics)

This review is reconstructed from the frozen analysis outputs, not from historical README narrative. No new analysis was run; no frozen number was changed.

## Part 1 — What the project actually studies

### 1.1 Scientific questions, ranked by what the data can answer

**Primary question (the one the data actually supports):**
Within a Discovery subset of an exposure-defined plasma proteomics cohort, which proteins (a) show a High-vs-Low exposure-associated abundance signal under prespecified BH-FDR, and (b) retain their direction in a reused within-cohort hold-out? The answer is the frozen 85-protein family and its replication hierarchy (85 / 83 direction-concordant / 29 nominal / 1 candidate-family-FDR).

**Secondary questions the data supports:**
- How consistent are these signals across pairwise contrasts (Low–Control, High–Control, High–Low), overall exposure, detection, and missingness sensitivity?
- How do the 85 candidates behave under repeated outer cross-validation, conditional on the locked panel (fixed-85) and under a leakage-controlled nested rescreen (strict nested)?
- What pathway themes are over-represented among the 85 candidates (cameraPR primary; ORA and fgsea complementary)?
- How sensitive are estimates to site omission and to environment stratification?

**Exploratory questions:**
- Environment-stratified concordance between High land and Hot-humid.
- Candidate-level method convergence (LASSO / EN / Boruta-style / XGBoost).
- Biological-context annotation, pairwise Spearman structure, and pathway–candidate mapping.

**Questions the current study cannot answer:**
- Whether any protein is an externally validatable biomarker.
- Whether exposure causes the observed abundance changes (no longitudinal, no intervention, no functional assay).
- Whether the observed proteins are genuinely EV-derived (no EV purification validation).
- Whether environment modifies the exposure effect (interaction test is null and underpowered).
- Whether the findings generalize to populations outside the enrolled sites.
- Whether any protein has causal / mechanistic role.

### 1.2 Study identity

- **PRIMARY identity**: environmental exposure plasma proteomics study (discovery-oriented, single-cohort, reused within-cohort hold-out).
- **SECONDARY identity**: methodological / robustness proteomics study (multi-site, multi-method sensitivity, nested-CV comparator).
- **NOT SUPPORTED as primary identity**:
  - EV-pure proteomics study — enrichment is not validated as EV purification.
  - Biomarker discovery-and-validation study — only 1/85 survives candidate-family FDR in the reused hold-out.
  - Predictive modeling study — ML is conditional on the 85 lock; performance is descriptive, not a deployed model.
  - Multi-site replication study — sites are confounded with environment/exposure, not independent replication arms.
  - Biological mechanism study — no functional data.

## Part 2 — Evidence domains, graded

| Domain | Grade | Rationale |
|---|---|---|
| Cohort design | Moderate | 515 analytical, balanced groups (153/186/176), pre-specified split, but reused hold-out and site–environment coupling. |
| Discovery statistics | Moderate | Prespecified FDR families, 85 locked before hold-out use; but overall-exposure family is null (0/1430 at BH-FDR<0.05), so the discovery contrast is High-vs-Low, not a monotone dose response. |
| Replication | Limited | 83/83 direction-concordant is reassuring; 29 nominal and **1/85 FDR-supported** is weak. Reused within-cohort hold-out is not independent validation. |
| Environment robustness | Limited | Stratified concordance is descriptive; interaction test null (0/1430). |
| Site robustness | Moderate (as sensitivity) | LOO direction stability is a sensitivity check, not replication. |
| Missingness / detection robustness | Moderate | Firth + KNN sensitivity on the locked 85; 2/3054 detection FDR hits. |
| ML | Exploratory / Sensitivity | Fixed-85 conditional is descriptive; strict nested shows 8–618 fold-local DEP instability. |
| Pathway inference | Moderate | cameraPR 195 is large and Reactome-redundant; ORA 23 and fgsea 39 are complementary; no KEGG. |
| Biological interpretation | Exploratory | M12B is annotation/context, not mechanism. |
| EV-specific interpretation | Not supported beyond enrichment label | No EV purity / marker / proteolipid / co-isolation controls. |
| Generalizability | Limited | Single enrolled population; no external cohort. |
| Mechanistic inference | Not supported | No functional, perturbation, or cell-of-origin data. |
| Reproducibility | Strong (computational) | Frozen tables, seeds, relative paths, manifests, audit CSVs. |

## Part 3 — What the 85 DEPs actually are

The 85 are the **central empirical finding**, but their scientific weight is modest:
- They are the output of a High-vs-Low contrast in the Discovery subset under prespecified BH-FDR.
- They are **not** a validated panel: only 1/85 survives candidate-family FDR in the reused hold-out.
- They are a **discovery candidate family**, not a signature.
- The paper's claim must be: "we identify a discovery set of 85 exposure-associated proteins whose direction is broadly preserved in a reused hold-out; only one survives formal replication-level multiple-testing correction."

## Part 4 — Reviewer-style critique (summary; see risk register)

- **EV / proteomics reviewer**: will push back hard on "EV-enriched" vs "EV-pure", co-isolation of abundant plasma proteins, preanalytical control.
- **Statistics / ML reviewer**: will push back on reused hold-out, 29 nominal vs 1 FDR, fixed-85 selection conditioning, 8–618 nested instability, 195 pathway redundancy, interaction power.
- **Environmental / biological reviewer**: will push back on exposure-as-dose language, site–environment–exposure coupling, lack of mechanism.

No fatal flaw if wording is kept conservative. Fatal only if the paper overclaims external validation, EV purity, mechanism, or predictive performance.

## Part 5 — Recommended scientific narrative architecture (summary; see PROJECT_RECONSTRUCTION_PLAN)

The honest spine is:
1. Design + QC + cohort / universe.
2. Discovery landscape: overall-exposure null + High-vs-Low 85-candidate lock.
3. Reused hold-out hierarchy: direction concordance + the 1/85 FDR-supported result (presented honestly).
4. Robustness layer: detection, missingness, site LOO, environment-stratified (descriptive), interaction (null).
5. Prioritization layer: fixed-85 conditional ML + strict nested sensitivity (as sensitivity, not performance claim).
6. Pathway + biological context: cameraPR primary, ORA/fgsea complementary, M12B as interpretation.

ML and pathway are **supporting / prioritization**, not the headline. The headline is the discovery–concordance–limited-replication result.
