# MANUSCRIPT LIMITATIONS CONTRACT — EV-enriched Plasma Proteomics v2.1

> **Status**: FROZEN · nature-statistics / manuscript preparation
> **Date**: 2026-10-01
> **Analysis version**: analysis-v2.1 (FINAL) · **Frozen commit**: `6d0e004e5025bcf7d564dadaead133809a743a14` · **Tag**: `analysis-v2.1`
>
> **Purpose**: fixed limitation language for the manuscript Discussion / Limitations and Methods /
> provenance statements. nature-writing must draw every limitation, provenance caveat, and
> wording choice from this file and the Methods / Numeric contracts.
>
> **Evidence base**: `docs/PREANALYTICAL_LIMITATIONS_FREEZE.md`,
> `docs/SITE_ACQUISITION_CONFOUNDING_AUDIT.md`, `docs/PROTEOMICS_QC_PROVENANCE_FINAL.md`,
> `docs/SOFTWARE_ENVIRONMENT_LOCK.md`, `docs/FINAL_REPRODUCIBILITY_AUDIT.md`,
> `audit_output/FINAL_ANALYSIS_FREEZE_HANDOFF.md`.

---

## 1. Core limitation statements (10, required in manuscript)

**A. Validation**
- The hold-out is **reused within-cohort**, not independent / external validation.
- Of 85 locked candidates: **83** direction concordant, **29** nominal (P < 0.05),
  **1** candidate-family BH-FDR-supported. Biomarker claims must remain conservative.

**B. Discovery stability**
- Strict nested: **7 / 15** zero-feature folds; **no** feature appearance ≥ 0.70.
- Discovery is **highly sensitive to training-sample composition** (feature-selection
  instability). This is NOT evidence of biological heterogeneity.

**C. Design / confounding**
- Site / Environment / acquisition-era effects are **strongly coupled** under the recorded design.
- **Environment-associated effects cannot be fully separated from acquisition-era / site-associated
  effects under the recorded design.**
- M11 leave-one-site-out does **not** remove or prove the absence of this confounding.

**D. Preanalytics (not recorded)**
- Processing time, freeze-thaw cycles, storage duration, injection order (intra-day run order),
  and sample-prep batch: **NOT_RECORDED**.
- MS batch: **RECORDED_BUT_NOT_MODELED** (primary model excludes batch; batch enters only as a
  sensitivity covariate).

**E. EV interpretation**
- Study material = **EV-enriched plasma proteomics**.
- No direct EV-purity validation.
- Possible co-isolation of abundant plasma, platelet, erythrocyte, and coagulation-associated
  proteins. Do NOT call the 85 proteins "EV-specific proteins" or claim a "pure EV proteome."

**F. Proteomics identification provenance**
- Contaminant exclusion execution: **PARTIALLY_VERIFIED / policy-level** (cRAP 2012.01.01 drafted
  and paper-frozen for 8 keratin groups; **no protein actually excluded** from the analyzed universe).
- Decoy exclusion: **UNRESOLVED** (no FASTA / search-engine project retained).
- Protein FDR provenance: **UNRESOLVED** (`PG.Qvalue` column exists; definition / aggregation /
  threshold not established).
- Peptide / PSM-level FDR export: **NOT_AVAILABLE** (no peptide / precursor / PSM tables retained).
- This is a Methods / provenance limitation; it is NOT closed by downstream differential-abundance
  BH-FDR.

**G. Computational reproducibility**
- ML is implemented in R (glmnet 5.0 / xgboost 3.2.1.1 / ranger 0.18.0 / pROC 1.19.0.1) under R 4.3.1;
  Python 3.14.7 is used only for P1/P2/P3 upstream processing (pandas 3.0.3 / numpy 2.4.6 / openpyxl 3.1.5,
  pinned in `descriptive/requirements.txt`). See `docs/SOFTWARE_ENVIRONMENT_LOCK.md` (U3 closure 2026-10-02).

**H. Pathway methods**
- cameraPR (205) = primary pathway inference; ORA (23) = complementary.
- **fgsea is sensitivity-only** (dual-reported: 44 family-wise BH / 41 pooled BH) and must never be
  presented as a primary discovery family.
- **KEGG was not run**; do not mention KEGG results.
- Fixed-85 ML performance (mean outer AUROC ~0.65–0.67) is **conditional on the frozen 85-protein
  discovery panel**; it is not an unbiased generalization estimate.

---

## 2. Frozen limitation registry (18, authoritative)

1. **Hold-out is reused within-cohort**, not independent / external validation.
2. Only **1 of 85** locked candidates retained candidate-family BH-FDR support in the hold-out.
3. **Strict nested discovery instability**: 7 / 15 zero-feature folds; no feature appearance ≥ 0.70.
4. Site / environment / acquisition-era effects **cannot be fully separated** under the recorded design.
5. M11 LOO **does not remove or prove absence** of that confounding.
6. Processing time = **NOT_RECORDED**.
7. Freeze-thaw cycles = **NOT_RECORDED**.
8. Storage duration = **NOT_RECORDED**.
9. Injection order (intra-day run order) = **NOT_RECORDED**.
10. MS batch = **RECORDED_BUT_NOT_MODELED** (primary model; sensitivity only).
11. Study material = **EV-enriched plasma proteomics**; no direct EV-purity validation; possible
    co-isolation of abundant plasma, platelet, erythrocyte, and coagulation-associated proteins.
12. Contaminant exclusion execution evidence = **PARTIALLY_VERIFIED / policy-level**.
13. Decoy exclusion = **UNRESOLVED**.
14. Protein FDR provenance = **UNRESOLVED**.
15. Peptide / PSM-level FDR export = **NOT_AVAILABLE**.
16. Computational environment locked 2026-10-02 (R 4.3.1 + packages measured; Python pinned in requirements.txt); no venv/conda referenced.
17. Pathway analyses establish **enrichment / biological context**, not causal mechanism.
18. Zero FDR-significant results do **not** demonstrate absence of an effect.
19. **fgsea is sensitivity-only** (dual BH: 44 family-wise / 41 pooled); not a primary discovery family.
20. **KEGG was not run** (placeholder CSVs only; no KEGG claim permitted).
21. Fixed-85 ML performance is **conditional on the frozen 85-protein discovery panel**; not an unbiased generalization estimate.
22. Environment-stratified de novo discovery (separate Humid-hot / High-land DEP lists within 386) was **not performed**; D05/D08 evaluate the frozen 85 within environments, and M10 tests interaction — neither is de novo environment-specific discovery.

---

## 3. Fixed Methods / Limitations statements (ready-to-use)

**Confounding (fixed wording, from PREANALYTICAL_LIMITATIONS_FREEZE):**
> Under the recorded design, site/environment and acquisition-era effects cannot be fully separated;
> the two largest sites each align with a single acquisition date. Processing time,
> time-to-centrifugation, freeze-thaw cycles, storage duration/temperature, injection order, and
> sample-prep batch were not recorded; the MS batch proxy was retained as a sensitivity covariate
> rather than in the primary model. We report exposure-associated protein signatures and treat
> site/acquisition and preanalytical variation as acknowledged confounders.

**Identification QC (fixed wording, from PROTEOMICS_QC_PROVENANCE_FINAL):**
> Identification-level QC records (PSM/peptide FDR, target-decoy settings, contaminant registry
> execution, and upstream Spectronaut normalization) are incomplete in the retained export; the
> protein-group identification FDR and residual technical-contaminant load could not be verified.
> We treat this as a provenance limitation rather than as evidence of absence of contamination.

**Site LOO (fixed wording):**
> Leave-one-site-out analyses showed site-specific sensitivity of the estimated overall-exposure
> effects. They do not establish site independence, and they cannot separate site/acquisition-era
> effects from biology.

---

## 4. Wording whitelist / blacklist

### PREFERRED
- discovery candidate
- differentially abundant protein
- within-cohort hold-out
- direction concordance
- nominal support
- candidate-family FDR support
- sensitivity analysis
- modest discrimination
- feature-selection instability
- pathway enrichment
- biological context
- contextual association structure
- EV-enriched plasma proteomics

### AVOID / PROHIBITED
- validated biomarker
- externally validated
- independently validated
- site independent
- batch independent
- robust across sites
- diagnostic classifier
- clinical prediction model
- mechanism validated
- causal pathway
- pure EV proteome
- EV-specific protein
- no interaction
- no site effect
- "corrected P" (without specifying correction)
- "replicated after multiple testing" (for nominal P < 0.05)
- "strong / accurate / robust classifier" (for fixed-85 AUROC)
- "nested AUROC across 15 folds" (7 / 15 folds had no fit)
- "44 pathways significantly enriched" (without specifying family-wise vs pooled)
- KEGG "performed / showed" (KEGG = NOT_RUN)

### Replacement map (use right column)
| Prohibited | Preferred |
|---|---|
| validated biomarker | discovery candidate; within-cohort hold-out support |
| independently validated | direction concordance; nominal replication |
| external validation | within-cohort hold-out |
| robust across sites | site-specific sensitivity |
| site independent / batch independent | site-specific sensitivity of estimated effects |
| diagnostic classifier / clinical prediction model | modest discrimination |
| mechanistically validated | pathway enrichment; biological context |
| EV-specific / pure EV proteome | EV-enriched plasma proteomics |
| no interaction / no site effect | "No proteins met the prespecified FDR threshold" |

---

## 5. Zero-significant results convention

For any "0 significant" result (M09 0 / 1,430; interaction 0 / 1,430):
- **Allowed**: "No proteins met the prespecified FDR threshold."
- **Prohibited**: "there was no effect"; "exposure did not interact with environment."
- Not reaching a threshold ≠ proving absence of an effect.
