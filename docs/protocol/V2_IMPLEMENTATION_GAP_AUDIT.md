# V2 Implementation Gap Audit

## 1. Audit scope

This audit is a **static code review only**. No R or Python script was executed, no result was regenerated, no frozen file was modified, and no commit/tag/push was made.

Baseline protocol: `docs/protocol/ANALYSIS_PLAN_v2.0.md` (frozen as documentation, not yet executed).

Objective: for every module defined in the v2 plan, determine whether the existing repository already has an implementation, what it actually does, and what classification (KEEP / REUSE / MODIFY / NEW / HISTORICAL_ONLY / SUPERSEDED / DATA_GAP) applies.

---

## 2. V2 plan coverage crosswalk

This crosswalk maps every original v2 concept to its M-module. No concept is left unmapped.

| # | Original v2 concept | M-module | Classification | Notes |
|---|---|---|---|---|
| 1 | Data provenance / sample architecture | M02 | REUSE | P1–P3 + identity mapping; Freeze 2 OPEN |
| 2 | QC / descriptive overview | M01, M04 | REUSE | 01–04 descriptive scripts + 06 covariate QC |
| 3 | Contaminant / exclusion registry | M03 | **NEW** | No registry exists; Freeze 3 blocker |
| 4 | Quantitative universe Q515 | M02→M04 | MODIFY | Eligibility logic exists; needs Utech input + new registry |
| 5 | Detection universe D515 | M08 | MODIFY | Binary matrix exists; universe rule must change to ≥10/≥10 |
| 6 | Control vs Exposure (E contrast) | M05 | MODIFY | Framework exists; no E weighted contrast; needs contrastAsCoef |
| 7 | Three-group global / omnibus | M06 | MODIFY | No omnibus F; pattern rules on wrong universe |
| 8 | Ordered architecture | M06 | MODIFY | No IUT ordered test; patterns on 256 DEP only |
| 9 | Three pairwise abundance contrasts | M07 | MODIFY | Framework exists; same gaps as M05 (universe, SE, CI, families) |
| 10 | Detection analysis | M08 | MODIFY | glm → Firth; D515 universe; new FDR families |
| 11 | Unique / exposure-associated detection proteins | M08 | MODIFY | Replace <20% comparator with zero-comparator + gradient grid |
| 12 | Environment-specific analysis | M10 | MODIFY | D05 on 85 candidates; needs Qenv full proteome |
| 13 | Dose × Environment interaction | M10 | MODIFY | D06 on 85 candidates; needs I_E + pooled interaction BH |
| 14 | Site robustness | M11 | MODIFY | D07 on 5 sites/85 proteins; needs all 9 sites + full Q515 |
| 15 | Missingness robustness | M09 | REUSE | D2/D3 formulas validated; new v2 wrapper required |
| 16 | Peptide / unique peptide evidence | M08-pep | **DATA_GAP** | Source data absent; not an analytical code failure |
| 17 | Functional / pathway analysis | M12 | **NEW** | No code exists; D10 = NOT_RUN_NO_APPROVED_MAPPING |
| 18 | Integrated biological interpretation | M12b | MODIFY | No synthesis module exists; depends on all upstream evidence |
| 19 | Machine learning / predictive | M15 | **NEW** | No ML code; largest new module |
| 20 | Figures | M17a | REUSE | Style + skeleton exist; rebuild from v2 outputs |
| 21 | Tables | M17b | REUSE | Table structure follows from module outputs |
| 22 | Manuscript-facing outputs | M17c | REUSE | 6-figure system defined; rendering layer needs v2 data |
| 23 | Reproducibility / run orchestration | M18 | MODIFY | run_all + manifest + no-overwrite exist; missing session/pkg recording |

---

## 3. Repository state

| Component | Location | Status |
|---|---|---|
| Raw data | `rawdata/processed.xlsx`, `rawdata/rawdata.xlsx`, `rawdata/sample_mapping_FINAL.xlsx` | Present; Spectronaut processing config not recovered |
| Sample mapping | `code/P1.py`, `code/P2.py`, `code/P3.py` | Early audit scripts; produce `sample_mapping_FINAL.xlsx` |
| Full-cohort pipeline v1.0 | `descriptive/01–13a` (17 stages) | FROZEN, 17/17 validated |
| Discovery-Validation branch | `descriptive/discovery_validation/` (D01–D10) | FROZEN, Git checkpoint `d46aee3` |
| Missingness robustness | `descriptive/missingness_robustness/` | Post-freeze, D0–D3 complete |
| Figure infrastructure | `nature_plotting.py`, `v21_common.R`, `figures_prospective.R` | Style helpers exist; prospective figures not yet run |
| Contaminant registry | — | **Does not exist** |
| Pathway/enrichment code | — | **Does not exist** (D10 records `NOT_RUN_NO_APPROVED_MAPPING`) |
| ML / predictive code | — | **Does not exist** |
| Firth logistic regression | — | **Does not exist** (current detection uses standard glm/logistic) |
| Peptide-level data | `descriptive/unique_peptide_support.csv` | **Does not exist** (D09 records `SOURCE_NOT_AVAILABLE`) |

## 4. Frozen / protected components

Frozen source and historical outputs must not be modified or overwritten. Any future reproducibility rerun requires explicit investigator authorization and must write to a separate verification output location.

The following components are frozen:

1. `descriptive/run_all.py` and all Stage 01–13a scripts — v1.0 FROZEN pipeline
2. `descriptive/limma_dose_analysis/results/` — all frozen historical outputs
3. `descriptive/discovery_validation_split/discovery_validation_assignment.csv` and its SHA-256
4. `descriptive/discovery_validation/D01_discovery_eligibility.py` through `D10_integrated_biology.R`
5. `descriptive/discovery_validation/code/dv_shared.R`
6. `descriptive/missingness_robustness/` outputs
7. `rawdata/` source files
8. `docs/protocol/ANALYSIS_PLAN_v2.0.md` and `STUDY_DESIGN_AUDIT.md`

---

## 5. V2 module implementation matrix

| ID | V2 module | Existing implementation | Status | Required action | Risk |
|----|-----------|-------------------------|--------|-----------------|------|
| M01 | Metadata & cohort description | `01_describe_proteomics.py`, `03_design_composition.py`, `04_complete_four_layers.py` | REUSE | Add v2 labels, SMD split-balance, Table 1/2 structure | Low |
| M02 | Normalization audit & provenance | `stage05_normalization_helper.py`, `P1–P3.py`, `07_limma_dose_analysis.R` sensitivity branches | REUSE | Read-only provenance table; document Freeze 2 status | Low |
| M03 | Technical contaminants registry | None | **NEW** | Build Category A/B/C registry; requires cRAP or source flags | Medium — blocker for Utech |
| M04 | Proteome landscape & QC | `01–04` descriptive scripts, `06_covariate_QC.R` PCA/UMAP | REUSE | Integrate Utech filter; add ≥50/60/70/80% gradient table | Low |
| M05 | Overall E contrast abundance | `07_limma_dose_analysis.R` (has HL/LC/HC) | **MODIFY** | Add E weighted contrast; switch `contrasts.fit` → `contrastAsCoef`; add exact moderated-t CI | Medium |
| M06 | Ordered / omnibus / architecture | `11a_dose_pattern_classification.R`, `11b_protein_clustering.R` (256 DEP only) | **MODIFY** | Apply pattern rules to all Q515 adjusted means; add IUT ordered test + 2-df omnibus F | Medium |
| M07 | Three pairwise contrasts | `07_limma_dose_analysis.R` (already has LC/HC/HL) | **MODIFY** | Same gaps as M05: Utech/Q515 universe, contrastAsCoef, exact SE, moderated-t CI, separate BH families | Medium |
| M08 | Detection & Unique proteins | `09_detection_pattern_analysis.R` (standard glm), D09 detection gradients | **MODIFY** | Replace standard glm with Firth (`logistf`); new D515 universe independent of Q515; replace <20% comparator rule with zero-comparator + gradient grid | High — new statistical framework |
| M08-pep | Peptide / unique peptide evidence | None (D09 = `SOURCE_NOT_AVAILABLE`) | **DATA_GAP** | Source peptide-level data absent; not an analytical code failure | Data blocker |
| M09 | Missingness sensitivity | `missingness_robustness/code/missingness_robustness.R` (D0–D3) | REUSE | Reuse D2/D3 validated formulas in a new v2 wrapper; historical scripts and outputs remain untouched | Low |
| M10 | Environment & interaction | D05/D06 (85 candidates only) | **MODIFY** | Extend to Qenv/Denv full proteome; add I_E contrast, 2-df joint interaction, pairwise interaction BH | Medium |
| M11 | Site context & LOO | D07 (5 major sites, 85 candidates) | **MODIFY** | Extend to all 9 sites; add nested-Site omnibus SITE-A; add SITE-H heterogeneity; full Q515 LOO | Medium |
| M12 | Pathway / enrichment | None (D10 = `NOT_RUN_NO_APPROVED_MAPPING`) | **NEW** | cameraPR + ORA; GO BP / Reactome / KEGG mapping; requires gene-mapping resolution | Medium |
| M12b | Integrated biology interpretation | None (no synthesis module exists) | **MODIFY** | Synthesize upstream abundance+detection+environment+site+pathway evidence into integrated summary | Medium |
| M13 | Historical 256 reconciliation | Stage 07 + D01–D03 frozen outputs | HISTORICAL_ONLY | Read-only reconciliation table; no refit | None |
| M14 | Frozen 85→129 evidence | D03/D08/D09/D10 frozen outputs | HISTORICAL_ONLY | Report as-is with proper historical labels; no rerun | None |
| M15 | ML biomarker development | None | **NEW** | Elastic Net glmnet; 5×5 nested CV ×3 repeats; Strategy A/B; fold-local preprocessing | High — largest new module |
| M16 | Reused 129 hold-out eval | None (depends on M15) | **NEW** | Apply locked model to 129; AUROC/AUPRC/calibration; bootstrap CI | Depends on M15 lock |
| M17a | Figures | `figures_prospective.R`, `nature_plotting.py`, `v21_common.R` | REUSE | Rebuild 6-figure system from v2 outputs; update labels, CI captions, family IDs | Low |
| M17b | Tables | Module output schemas | REUSE | Tables follow from module outputs; standardize v2 naming | Low |
| M17c | Manuscript-facing outputs | `figures_prospective.R` + table schemas | REUSE | Render layer only; no new inference | Low |
| M18 | Reproducibility / orchestration | `run_all.py`, `dv_manifest()`, `dv_no_overwrite()`, SHA-256 checks | **MODIFY** | Reuse manifest/no-overwrite/seed patterns; add sessionInfo, package versions, v2 pipeline orchestrator | Low |

---

## 6. Detailed module audit

### M01 — Metadata and cohort description

**V2 requirement:** Table 1 (overall Control/Low/High counts, baseline distributions), Table 2 (Discovery vs reused 129 SMD balance), Environment/Site stratification, acquisition-date vs collection-date distinction.

**Existing code:**
- `descriptive/01_describe_proteomics.py` — reads `processed.xlsx`, builds `sample_statistics.csv`, `protein_statistics.csv`, canonical annotation
- `descriptive/03_design_composition.py` — design composition tables (dose × condition × MS_batch)
- `descriptive/04_complete_four_layers.py` — four-layer complete description with SHA-256 source verification
- `descriptive/sample_statistics.csv`, `dose_defined_metadata.csv` — existing metadata

**Gap:** No SMD calculation for split balance; no Table 1/2 manuscript format; v2 terminology (Control/Low/High vs legacy control/low/high) needs display mapping.

**Classification: REUSE** — Core metadata pipeline exists; add SMD and v2 output formatting.

---

### M02 — Normalization audit and matrix provenance

**V2 requirement:** Document the complete transformation chain from raw MS → Spectronaut → PG.Quantity → log2 → branch-specific matrix. Freeze 2 status: Spectronaut config unrecoverable.

**Existing code:**
- `descriptive/stage05_normalization_helper.py` — log2 transform + sample-median normalization sensitivity
- `code/P1.py`, `P2.py`, `P3.py` — sample string mapping/audit (not abundance normalization)
- `descriptive/07_limma_dose_analysis.R` — documents its own normalization branches in header comments

**Gap:** No formal provenance table; Freeze 2 remains OPEN (actual Spectronaut settings unknown).

**Classification: REUSE** — This is a read-only documentation task; existing code headers already document the chain.

---

### M03 — Technical contaminants and preanalytical annotations

**V2 requirement:** Category A (definite contaminants: decoy/reverse, BSA, trypsin, lab keratins) → exclude. Category B (endogenous ALB/Ig/apolipoprotein/complement/fibrinogen) → retain. Category C (erythrocyte/hemolysis/platelet/coagulation) → retain with annotation. Produce Utech universe.

**Existing code:** **None.** No contaminant registry, no cRAP mapping, no keratin filtering. The 3,817 protein groups enter analysis without any technical-exclusion step.

**Gap:** Complete missing. Requires either source FASTA/decoy flags or a curated cRAP accession mapping (Freeze 3 blocker).

**Classification: NEW**

---

### M04 — Proteome landscape and QC

**V2 requirement:** Show U0 (3817) → Utech → Q515 → D515 flow; detection gradients at ≥50/60/70/80% by Group/Environment/Site; PCA on complete-observation Q515; optional UMAP.

**Existing code:**
- `descriptive/01_describe_proteomics.py` — raw data audit, 3817 × 519 landscape
- `descriptive/02_detection_gradient.py` — detection gradient analysis (≥50/60/70/80%)
- `descriptive/06_covariate_QC.R` — PCA scores, UMAP, covariate balance
- `descriptive/protein_detection_landscape.csv` — existing detection landscape table

**Gap:** Existing gradients are computed on historical 3817 (not Utech); PCA uses historical 1434 Q515. Need to regenerate after Utech filter.

**Classification: REUSE** — Gradient and PCA logic exists; re-run with Utech-filtered universe.

---

### M05 — Overall Control versus Exposure (E contrast)

**V2 requirement:** Single E contrast = (186/362)·μ_L + (176/362)·μ_H − μ_C, fitted as `~0 + Group + Environment` with limma. Must use `contrastAsCoef` for exact SE with non-orthogonal missing-data design (not `contrasts.fit` approximate). BH-FDR across Q515 (family A-E). Moderated-t 95% CI.

**Existing code:**
- `descriptive/07_limma_dose_analysis.R` — fits `abundance ~ dose + environment`, computes Low_vs_Control, High_vs_Control, High_vs_Low via `contrasts.fit`. No E weighted contrast exists.
- `descriptive/discovery_validation/code/dv_shared.R::dv_fit()` — also uses `contrasts.fit` + `eBayes(trend=TRUE, robust=TRUE)`. CI uses `abs(logFC/t) * qnorm(0.975)` (normal approximation, flagged as historical defect in v2 plan Section 2A).

**Gap:**
1. No E weighted contrast implementation.
2. Historical code uses `contrasts.fit` (approximate SE for non-orthogonal designs with missing data).
3. No moderated-t CI; historical CI uses normal approximation.

**Classification: MODIFY** — limma framework and model formula are correct; need new E contrast coefficient, `contrastAsCoef` reparameterization, and proper moderated-t CI.

---

### M06 — Ordered exposure, omnibus and response architecture

**V2 requirement:**
- Formal bidirectional ordered IUT test: `p_order = min(1, 2·min(max(p_a+,p_b+), max(p_a−,p_b−)))` where a=Low−Control, b=High−Low. BH across Q515 (family A-O).
- 2-df Group omnibus moderated F test (family A-G).
- Descriptive pattern classification on **all Q515** adjusted means (not 256 DEP only), with epsilon=0.05 log2.

**Existing code:**
- `descriptive/11a_dose_pattern_classification.R` — rule-based pattern classification but **only on the 256 historical DEP**, not all Q515. Uses raw observed group means, not adjusted model predictions.
- `descriptive/11b_protein_clustering.R` — hierarchical clustering (C1–C4) on 256×3 z-scored matrix.

**Gap:** No IUT ordered test. No omnibus F test. Pattern rules exist but applied to wrong universe (256 vs Q515) and wrong means (observed vs adjusted).

**Classification: MODIFY** — Pattern precedence rules can be reused but must apply to all Q515 with adjusted means. IUT and omnibus F are new.

---

### M07 — Three pairwise abundance contrasts

**V2 requirement:** LC = Low−Control, HC = High−Control, HL = High−Low. Separate BH families A-LC / A-HC / A-HL. Same model as M05. **Exact contrast SE via `contrastAsCoef`. Moderated-t CI. Utech/Q515 universe.**

**Existing code:**
- `descriptive/07_limma_dose_analysis.R` already computes all three contrasts (named Low_vs_Control, High_vs_Control, High_vs_Low) on historical 1434 × 515 matrix using `contrasts.fit`.

**Why this is MODIFY and not REUSE:**
Although the three contrast labels exist, the v2 requirements that apply to M05 also apply to M07 identically:
1. **Universe:** Historical code uses 1434 (pre-Utech). v2 requires Q515 (post-Utech).
2. **SE method:** Historical uses `contrasts.fit` approximate SE. v2 requires `contrastAsCoef` exact SE.
3. **CI:** Historical has no moderated-t CI fields. v2 requires pointwise moderated-t 95% CI.
4. **BH families:** Historical computes a single pooled BH. v2 requires three separate BH families (A-LC, A-HC, A-HL).
5. **Sign convention:** Historical uses legacy labels (Low_vs_Control etc.). v2 requires standardized LC/HC/HL IDs with v2 display mapping.

These are the same five gaps that make M05 a MODIFY. M07 cannot be classified as REUSE because the contrast computation method itself must change (not just the input universe).

**Classification: MODIFY**

---

### M08 — Detection and Unique proteins

**V2 requirement:**
- Binary detection model: **Firth penalized logistic regression** (`logistf`), uniform across proteins. Penalized likelihood-ratio tests.
- Protein universe: **D515** (≥10 detected and ≥10 non-detected among 515), independent of Q515.
- Contrasts: LC/HC/HL log-odds; E weighted log-odds; 2-df Group omnibus; ordered detection IUT.
- Level A (enriched): formal differential detection with BH (D-E/D-G/D-O/D-LC/D-HC/D-HL).
- Level B (observed group-specific): zero detections in comparator + target ≥50/60/70/80% gradient. No <20% comparator rule.

**Existing code:**
- `descriptive/09_detection_pattern_analysis.R` — uses **standard glm logistic regression** (not Firth), on a universe defined by group-max ≥60% detection (not D515).
- `descriptive/discovery_validation/code/D09_evidence_layers.R` — detection rate gradients at ≥50/60/70/80% on 85 candidates only.
- `descriptive/detection_pattern/` — binary detection results directory.

**Gap:** No Firth implementation. Detection universe is wrong (group-max ≥60% vs D515 ≥10/10 rule). No formal D-family FDR. No weighted E log-odds contrast. No ordered detection IUT. Historical "<20% comparator" rule must be replaced with zero-comparator + gradient grid.

**Classification: MODIFY**

---

### M08-pep — Peptide / unique peptide evidence

**V2 requirement:** Unique protein means group-enriched/group-specific detection protein, not unique peptide. Peptide evidence is identification QC only.

**Existing code:**
- `descriptive/discovery_validation/code/D09_evidence_layers.R` line 13: checks for `descriptive/unique_peptide_support.csv`; if absent, writes `Peptide_support_status = "SOURCE_NOT_AVAILABLE"`.
- No peptide-level data file exists anywhere in the repository.
- The raw export (`processed.xlsx`) contains only PG.Quantity (protein-group level); no PEP.Quantity or unique peptide count columns were identified.

**Gap:** Source data does not exist. This is not an analytical code failure — it is a data availability gap. v2 must report peptide evidence as DATA_GAP and not fabricate any peptide-level support.

**Classification: DATA_GAP / BLOCKED**

---

### M09 — Missingness and imputation sensitivity

**V2 requirement:** Primary = observed values (no imputation). Sensitivity D2 = Gaussian left-censoring downshift (μ−1.8σ, 0.3σ), seed 20260925 + 9 seed repeats. Sensitivity D3 = KNN (k=10, rowmax=0.5, colmax=0.8, maxp=1500, seed 20260925). D1 zero replacement superseded.

**Existing code:**
- `descriptive/missingness_robustness/code/missingness_robustness.R` — implements D0 (no imputation), D1 (zero replacement), D2 (Gaussian downshift), D3 (KNN with `impute.knn`). All on historical 1434 × 515 matrix.

**How to reuse:** Reuse the D2 and D3 validated formulas in a new v2 wrapper/helper. The historical scripts and outputs remain untouched. The v2 wrapper must:
1. Operate on the new Q515 universe (post-Utech).
2. Use v2 contrasts (E, omnibus, ordered, pairwise).
3. Remove hardcoded 1434/256 assertions.
4. Exclude D1 from v2 inference (keep as historical stress test only).

**Classification: REUSE** (formulas reused; implementation via new v2 wrapper; frozen source untouched)

---

### M10 — Environment estimates and interaction

**V2 requirement:**
- Qenv/Denv universe (≥10 in all 6 Group×Environment cells).
- I_E = E_Humid−E_Altitude weighted contrast (w=186/362).
- Joint 2-df interaction test (LC + HC modification).
- Pairwise interaction localization pooled BH (I-pair).
- Environment main effect (ENV-A) adjusted for Group.
- Stratum-specific effects for each Environment.

**Canonical terminology:** Environment values are **Humid-hot** and **High-altitude**. Legacy tokens `high_temperature`/湿热 → Humid-hot; `high_stress`/高海拔 → High-altitude. Legacy "high-pressure" wording is corrected to High-altitude; no separate physical high-pressure exposure exists.

**Existing code:**
- `descriptive/discovery_validation/code/D05_environment_specific.R` — environment-stratified results but **on 85 locked candidates only**.
- `descriptive/discovery_validation/code/D06_environment_interaction.R` — interaction test on **85 candidates only**, 0/85 FDR-significant.
- `descriptive/07_limma_dose_analysis.R` — has interaction sensitivity (six group means + DiD contrasts) on historical 1434.

**Gap:** Historical D05/D06 are candidate-only (85). v2 needs full Qenv proteome. The 07 sensitivity has the right structure but uses historical 1434 universe and approximate SE.

**Classification: MODIFY**

---

### M11 — Site context, association, heterogeneity and LOO

**V2 requirement:**
- Nested Site in Environment. Compare Group+Environment vs Group+Site (7 extra parameters).
- SITE-A omnibus: any within-Environment Site association.
- SITE-H: Group×Site heterogeneity where ≥10 participants per cell, ≥3 supported sites.
- LOO all 9 sites (not just 5 major).
- Supported sites for E: FJ_FQ, FJ_QZ, GZ_TH, XZ_GG.

**Existing code:**
- `descriptive/discovery_validation/code/D07_site_robustness.R` — LOO on **5 major sites**, **85 candidates only**.
- `descriptive/07_limma_dose_analysis.R` — MS_batch_proxy sensitivity (acquisition date as proxy).

**Gap:** D07 covers 5 sites × 85 proteins. v2 needs all 9 sites × Q515. No formal SITE-A omnibus. No SITE-H heterogeneity test. No nested Site model comparison.

**Classification: MODIFY**

---

### M12 — Functional and pathway interpretation

**V2 requirement:**
- `cameraPR` signed-statistic competitive analysis (primary inter-gene correlation = 0.01, sensitivity 0.05).
- ORA hypergeometric secondary.
- GO BP + Reactome required; KEGG if ≥80% mapping resolvable.
- Test pathways 10–500 genes; selected set ≥5 mapped genes.
- Ranking by signed moderated t; no significance truncation.

**Existing code:** **None.** D10 explicitly records `Pathway = NA, Status = "NOT_RUN_NO_APPROVED_MAPPING"`. No clusterProfiler, fgsea, gProfiler, or camera code exists anywhere.

**Gap:** Complete missing. Requires gene-mapping resolution (multiple accessions → one gene), pathway database resource acquisition, and new implementation.

**Classification: NEW**

---

### M12b — Integrated biology interpretation

**V2 requirement:** Synthesize all upstream v2 evidence layers (abundance E/pairwise, detection, environment interaction, site robustness, pathway) into a coherent integrated biological summary. This is distinct from M17c (manuscript rendering) — M12b is the scientific synthesis; M17c is the visual/textual presentation.

**Existing code:** **None.** No integrated synthesis module exists. The historical D10 only integrates 85-candidate supportive evidence; it does not synthesize full-proteome biology.

**Dependencies:** M05 (E), M06 (ordered/omnibus), M07 (pairwise), M08 (detection), M10 (environment), M11 (site), M12 (pathway).

**Classification: MODIFY** — New synthesis module required; depends on all upstream evidence modules.

---

### M13 — Historical 256 reconciliation

**V2 requirement:** Read-only comparison of historical 1434→256 vs Discovery 1445→85. Document eligibility overlap (shared 1426, historical-only 8, Discovery-only 19). No refit.

**Existing code:** All inputs already exist (Stage 07 manifest, D01 eligibility, D02 results).

**Classification: HISTORICAL_ONLY** — No new code needed; produce reconciliation table from existing frozen outputs.

---

### M14 — Frozen 85→129 prospective evidence

**V2 requirement:** Report D03 lock (85), D08 replication (83/29/1), D09–D10 evidence as-is. No rerun. Label CI method. Do not revise candidate family. The 129 is a **reused within-cohort hold-out**, never untouched/external validation.

**Existing code:** All outputs frozen at `descriptive/discovery_validation/D03–D10/`.

**Classification: HISTORICAL_ONLY** — Read and present existing results; no new analysis.

---

### M15 — Discovery-only biomarker development (ML)

**V2 requirement:**
- Elastic Net logistic regression (glmnet), primary Strategy B (no DE preselection).
- Secondary Strategy A (fold-local limma screen at BH<0.10).
- 5 outer × 5 inner nested CV × 3 repeats (seeds 20260926/27/28).
- Fold-local eligibility, median imputation, scaling.
- Alpha grid {0.1, 0.5, 0.9, 1}; 50 lambda fractions.
- Panel caps k={3,5,10,20}; one-SE rule; smallest median panel size.
- AUROC primary; bootstrap CI (2000 replicates).
- Final lock on all 386 (seed 20260929).

**Existing code:** **None.** No glmnet, no nested CV, no ML pipeline anywhere. No data leakage protection (fold-local preprocessing) exists.

**Gap:** Complete missing. This is the largest new module.

**Classification: NEW**

---

### M16 — Reused 129 hold-out evaluation

**V2 requirement:** Apply locked Discovery model to 129 hold-out. One evaluation only. AUROC/AUPRC/calibration/Brier. Bootstrap CI (seed 20260930). No threshold tuning on hold-out.

**Existing code:** **None** (depends entirely on M15 lock).

**Classification: NEW** — Cannot start until M15 model is locked.

---

### M17a — Figures

**V2 requirement:** 6-figure system (Fig 1–6) + supplementary. Figure 1: flow/depth/PCA. Figure 2: E effects/MA/volcano. Figure 3: ordered architecture/heatmap/UpSet. Figure 4: interaction/site/LOO. Figure 5: 85-family replication. Figure 6: ML ROC/PR/calibration.

**Existing code:**
- `descriptive/discovery_validation/code/figures_prospective.R` — R-only, result-table-only manuscript figures. Accepts `FIGURE_ID OUTPUT_STEM` args. Currently smoke-test quality.
- `descriptive/nature_plotting.py` — Nature-style matplotlib helpers (font, size, colors).
- `descriptive/v21_common.R` — Nature-style ggplot2 theme, I/O helpers, annotation join.

**Classification: REUSE** — Style helpers and figure skeleton exist; rebuild data sources and labels for v2.

---

### M17b — Tables

**V2 requirement:** Table 1 participant characteristics; Table 2 split balance; complete abundance/detection/interaction/site/pathway/ML supplements.

**Existing code:** Table schemas follow from each module's output CSV. No separate table-generation framework.

**Classification: REUSE** — Tables are direct projections of module output tables; standardize v2 naming.

---

### M17c — Manuscript-facing outputs

**V2 requirement:** Coherent evidence presentation, not new hypothesis testing. Carry source effects unchanged. Label CI method and FDR family per figure/table. This is the rendering layer that reads M12b (integrated biology) and all upstream module outputs.

**Existing code:** `figures_prospective.R` is the closest existing rendering layer; it reads D01–D10 result tables.

**Classification: REUSE** — Rendering layer only; no new inference. Must carry v2 family IDs and CI method labels. Distinct from M12b (synthesis) — M17c only renders what M12b and upstream modules produce.

---

### M18 — Reproducibility / run orchestration

**V2 requirement:** Versioned module outputs, input/output SHA-256 manifest, no-overwrite guard, seed recording, session/package version recording, dependency-order control.

**Existing infrastructure:**

| Capability | Existing implementation | Reusable? |
|---|---|---|
| Sequential pipeline orchestration | `descriptive/run_all.py` — 17-step PIPELINE tuple, subprocess dispatch | **REUSE pattern**; v2 needs new orchestrator for analysis_v2.0/ |
| Input/output SHA-256 manifest | `dv_shared.R::dv_manifest()` — hashes all inputs and outputs per stage | **REUSE**; directly applicable to v2 |
| No-overwrite guard | `dv_shared.R::dv_no_overwrite()` — refuses to overwrite existing files | **REUSE** |
| Frozen assignment hash check | `dv_shared.R::dv_assignment()` — verifies SHA-256 of split CSV | **REUSE pattern**; v2 needs Utech registry hash check |
| Seed recording | `missingness_robustness.R` uses seed 20260925; D01 uses seed 20260925 | **REUSE pattern**; v2 plan specifies seeds 20260926–20260930 |
| Session / package version recording | **None** — no `sessionInfo()` / `packageVersion()` recording | **GAP** |
| Dependency / order control | `run_all.py` hardcodes PIPELINE order; no automatic dependency graph resolution | **GAP** — v2 needs explicit dependency declaration |
| Provenance chain | `dv_manifest()` per stage; no cross-stage provenance DAG | **GAP** — v2 needs stage-level dependency manifest |

**Gap:** Manifest, no-overwrite, and hash patterns are directly reusable. Missing: session/package version recording, dependency graph, and cross-stage provenance.

**Classification: MODIFY** — Reuse existing guard/manifest patterns; add session recording and dependency control.

---

## 7. Historical analyses that must not be reused as prospective evidence

1. **Stage 07 256 DEP** — Historical full-cohort result; must not be used as v2 discovery set or ML feature screen.
2. **Stage 11a 249 Short_peak + 7 Long_suppression** — Classification on 256 DEP only; must not be presented as v2 all-Q515 pattern architecture.
3. **Stage 11b C1–C4 clustering** — Unsupervised on 256 DEP; v2 says no required clustering.
4. **D03 locked 85 candidates** — Discovery-only selection; must not be treated as v2 Q515 discovery or ML screening source.
5. **D08 replication results (83/29/1)** — Historical prospective evidence on prior-access cohort; the 129 is a **reused within-cohort hold-out**, not untouched external validation.
6. **D10 pathway status `NOT_RUN`** — Must not be cited as pathway analysis completed.
7. **D09 peptide `SOURCE_NOT_AVAILABLE`** — Must not be cited as peptide evidence.

## 8. Reusable validated infrastructure

| Component | Location | Reusable as |
|---|---|---|
| Identity mapping / sample position | `code/P1–P3.py`, `rawdata/sample_mapping_FINAL.xlsx` | Direct reuse |
| log2 transform + no imputation | `stage05_normalization_helper.py` | Same formula, v2 universe |
| limma + eBayes(trend, robust) wrapper | `dv_shared.R::dv_fit()` | Model framework; v2 needs contrastAsCoef variant |
| SHA-256 manifest / provenance | `dv_shared.R::dv_manifest()` | v2 helper pattern |
| No-overwrite guard | `dv_shared.R::dv_no_overwrite()` | v2 pattern |
| Frozen assignment hash check | `dv_shared.R::dv_assignment()` | Pattern; v2 needs Utech registry hash |
| Missingness D2 Gaussian / D3 KNN | `missingness_robustness/code/missingness_robustness.R` | Formula reuse in new v2 wrapper |
| Nature figure style (Python) | `nature_plotting.py` | Style constants only |
| Nature figure style (R) | `v21_common.R` | Theme + I/O helpers |
| Detection rate gradient computation | `D09_evidence_layers.R` | Gradient grid loop pattern |
| Annotation join | `v21_common.R::v21_annotate()` | Gene display mapping |

## 9. Modules requiring modification

| Module | What changes | Why |
|---|---|---|
| M05 E contrast | Add E weighted coefficient; `contrasts.fit` → `contrastAsCoef`; add moderated-t CI | Historical code lacks E and uses approximate SE |
| M06 Ordered/omnibus | Add IUT ordered test; add 2-df omnibus F; apply patterns to all Q515 adjusted means | Historical 11a is 256-DEP-only with observed means |
| M07 Pairwise contrasts | Same as M05: Utech/Q515 universe, contrastAsCoef, exact SE, moderated-t CI, separate BH families | Same five gaps as M05 |
| M08 Detection | Replace glm with Firth `logistf`; new D515 universe; new specificity hierarchy | Historical uses standard glm + group-max ≥60% universe |
| M10 Environment | Extend from 85 candidates to Qenv full proteome; add I_E weighted interaction | D05/D06 are candidate-only |
| M11 Site | Extend from 5 sites to 9; add SITE-A omnibus + SITE-H heterogeneity; full Q515 | D07 is 5-site/85-protein LOO only |
| M12b Integrated biology | New synthesis module across all upstream evidence layers | No existing synthesis module |
| M18 Reproducibility | Add session/package recording; add dependency graph; new v2 orchestrator | Existing manifest/no-overwrite reusable; missing session recording |

## 10. Truly new modules

| Module | Why new |
|---|---|
| M03 Contaminant registry | No contaminant/cRAP/keratin filtering exists anywhere |
| M12 Pathway enrichment | No cameraPR/ORA/GO/Reactome/KEGG code exists; D10 confirms NOT_RUN |
| M15 ML biomarker | No glmnet/nested CV/Elastic Net code exists; no fold-local preprocessing |
| M16 Hold-out evaluation | Depends on M15 lock; no evaluation code exists |

## 11. Data gaps

| Gap | Impact | Blocker for |
|---|---|---|
| Spectronaut processing version/settings/normalization | Cannot confirm upstream normalization; ML deployability uncertain | M02 Freeze 2, M15 |
| Source FASTA / decoy / contaminant flags | Cannot build Utech; no cRAP mapping available | M03 Freeze 3, M04, M05–M12 |
| Peptide-level data (unique peptide counts) | Cannot report peptide evidence; D09 = SOURCE_NOT_AVAILABLE | M08-pep (DATA_GAP) |
| Pathway database resource (GO/Reactome/KEGG releases) | Cannot run cameraPR/ORA | M12 |
| Clinical metadata (age/sex/BMI/etc.) | No covariate adjustment possible | S-sensitivity only; does not block primary |
| Assay-reference mapping for selected proteins | Cannot confirm assay feasibility | M15 panel feasibility annotation |

## 12. Terminology migration plan

| Historical token | v2 canonical | Where it appears | Migration approach |
|---|---|---|---|
| `control` / `Short` / `Long` | Control / Low exposure / High exposure | All frozen code, CSV column names, output files | Keep frozen files as-is; v2 wrappers add display mapping via `v21_common.R` EXPOSURE_LABELS |
| `high_temperature` / 湿热 | **Humid-hot** | Metadata, D05/D06 | Same display mapping |
| `high_stress` / 高海拔 | **High-altitude** | Metadata, D05/D06 | Same; legacy "high-pressure" corrected to High-altitude |
| `dose` / `TREAT1_clean` | Exposure level (Control/Low/High) | All code | Internal key preserved; display label overridden in v2 outputs |
| `High_vs_Low` / `Long_vs_Short` | HL (High − Low) | All limma outputs | v2 uses new contrast IDs; historical tables keep original labels |
| `Short_peak` / `Long_suppression` | Historical pattern labels only | Stage 11a | Do not propagate to v2 outputs |
| `Validation` (129) | Reused within-cohort hold-out | D08–D10 | v2 manuscript must disclose prior use; never call "external validation" |

**Rule:** Never modify frozen code's internal string tokens. v2 modules read frozen outputs, apply display mapping at the output/figure layer, and label historical tables with original terminology.

## 13. Cross-code redundancy / reuse opportunities

1. **Eligibility logic** (≥70% per-group detection): implemented in both `05_dose_quantitative_filtering.py` and `D01_discovery_eligibility.py`. v2 should call a single shared eligibility function with Utech input.
2. **limma wrapper**: `dv_shared.R::dv_fit()` and `07_limma_dose_analysis.R` both fit `lmFit + contrasts.fit + eBayes(trend=TRUE, robust=TRUE)`. v2 needs a new shared fit function with `contrastAsCoef`.
3. **Detection rate computation**: `09_detection_pattern_analysis.R` and D09 both compute per-stratum detection rates. v2 can reuse the gradient loop pattern.
4. **Annotation join**: `v21_common.R::v21_annotate()` and `01_describe_proteomics.py` both merge `canonical_protein_annotation.csv`. v2 reuses this pattern.
5. **LOO loop**: D07 implements leave-one-site-out refitting. v2 extends this pattern to all 9 sites.
6. **Figure style**: `nature_plotting.py` and `v21_common.R` both define the same Nature-style color/size/label constants. v2 overrides legacy labels without modifying frozen style files.
7. **Manifest/no-overwrite**: `dv_manifest()` and `dv_no_overwrite()` are directly reusable in v2.

**No refactoring of frozen source is recommended.** v2 should create a new `descriptive/analysis_v2.0/` directory with its own helper module that imports from existing patterns.

## 14. Proposed V2 implementation dependency graph

```
V2-00  Provenance / identity / config
  │  (M02 normalization audit + M18 orchestration scaffold)
  ▼
V2-01  Contaminant registry (M03)
  │  ← requires cRAP or source flags (Freeze 3)
  ▼
V2-02  Utech → Q515 + D515 canonical universes (M04)
  │
  ├──────────────────────────┐
  ▼                          ▼
V2-03  Descriptive / QC     V2-04  Missingness scaffold (M09)
  (M01 + M04)                 │
  │                           │
  ▼                           │
V2-05  E contrast abundance  │
  (M05)                       │
  │                           │
  ▼                           │
V2-06  Ordered / omnibus     │
  (M06)                       │
  │                           │
  ▼                           │
V2-07  Pairwise contrasts    │
  (M07)                       │
  │                           │
  ├──────────────────────────┤
  ▼                          ▼
V2-08  Detection (M08)      V2-09  Environment interaction (M10)
  + M08-pep (DATA_GAP)        │
  │                           ▼
  │                         V2-10  Site / LOO (M11)
  │                           │
  ▼                           ▼
V2-11  Pathway (M12)  ←──────┘
  │
  ▼
V2-12  Integrated biology interpretation (M12b)
  │  synthesizes: M05+M07 (abundance), M08 (detection), M10 (environment),
  │               M11 (site), M12 (pathway)
  │  This is SCIENTIFIC SYNTHESIS, not manuscript rendering.
  │  Distinct from M17c which is the visual/textual presentation layer.
  │
  ├──────────────────────────┐
  ▼                          ▼
V2-13  Historical reconciliation (M13+M14, read-only)
  │
  ▼
V2-14  ML development (M15)  ←── v2 plan: implement ML before further protein interpretation
  │
  ▼
V2-15  Hold-out evaluation (M16)
  │
  ▼
V2-16  Manuscript figures / tables / outputs (M17a/b/c)
  │  RENDERING layer: reads M12b (integrated biology) + all upstream v2 outputs
  │  + historical evidence (M13/M14). No new inference.
  │
  ▼
V2-17  Reproducibility finalization (M18)
     Session/pkg recording, dependency manifest, orchestrator freeze
```

## 15. Proposed implementation order

Based on the dependency graph and freeze ledger:

1. **V2-00** — Provenance audit + identity config + orchestration scaffold (M02 + M18). Document Freeze 2 status.
2. **V2-01** — Contaminant registry (M03). Blocker for all downstream universes.
3. **V2-02** — Generate Utech → Q515 + D515 canonical universes (M04).
4. **V2-03** — Descriptive proteome landscape / QC (M01 + M04).
5. **V2-04** — Missingness sensitivity scaffold (M09). Can run in parallel with abundance.
6. **V2-05** — E contrast abundance analysis (M05). First inferential v2 result.
7. **V2-06** — Ordered exposure + omnibus (M06).
8. **V2-07** — Three pairwise contrasts (M07).
9. **V2-08** — Detection / Unique proteins (M08). Peptide layer remains DATA_GAP.
10. **V2-09** — Environment interaction (M10).
11. **V2-10** — Site context + LOO (M11).
12. **V2-11** — Pathway / enrichment (M12).
13. **V2-12** — Integrated biology interpretation (M12b). Synthesizes all upstream abundance/detection/environment/site/pathway evidence.
14. **V2-13** — Historical reconciliation (M13+M14, read-only).
15. **V2-14** — ML biomarker development (M15). v2 plan recommends this before further full-cohort protein interpretation.
16. **V2-15** — Reused 129 hold-out evaluation (M16). One-time, after model lock.
17. **V2-16** — Final figures / tables / manuscript outputs (M17a/b/c).
18. **V2-17** — Reproducibility finalization (M18): session/pkg recording, dependency manifest, orchestrator freeze.

**Note on ML timing — two separate orderings:**

*Analysis execution order (preventing information leakage):* The v2 plan (Section 5, Freeze ledger) explicitly recommends: "freeze/implement ML workflow before additional full-cohort protein interpretation can influence choices". This means the ML workflow (M15/M16) should be implemented and locked before the full-cohort abundance/detection/environment/site/pathway modules are used to guide further interpretation. This is an execution-order requirement, not a scientific-argument requirement.

*Manuscript presentation order (scientific narrative):* The manuscript presents biology first (Figure 1–5), with ML/Figure 6 as the final evidence layer. This presentation order does not change the execution order.

The exact sequencing between V2-05 through V2-12 and V2-14 (ML) requires investigator decision, but the v2 plan's stated preference is earlier ML execution to prevent additional information leakage.

## 16. Files that should remain untouched

Frozen source and historical outputs must not be modified or overwritten. Any future reproducibility rerun requires explicit investigator authorization and must write to a separate verification output location.

- All files under `descriptive/limma_dose_analysis/results/`
- All files under `descriptive/discovery_validation/D01*` through `D10*/`
- `descriptive/discovery_validation_split/`
- `descriptive/missingness_robustness/results/`
- `descriptive/13a_canonical_256_DEP_master.R` and its output
- `descriptive/07_limma_dose_analysis.R` and its historical outputs
- `rawdata/`
- `docs/protocol/ANALYSIS_PLAN_v2.0.md` and `STUDY_DESIGN_AUDIT.md`
- All frozen CSV result files in `descriptive/` root

## 17. Open issues requiring investigator decision

1. **Freeze 2 (Normalization):** Spectronaut processing settings remain unrecoverable. Do we issue a dated release decision accepting log2-only primary + median sensitivity?
2. **Freeze 3 (Contaminants):** Do we have access to source FASTA/decoy flags? If not, do we adopt a fixed cRAP release mapping?
3. **ML timing:** Should ML development (M15) be implemented before or after the full-cohort abundance/detection/environment modules? The v2 plan recommends ML before further protein interpretation to prevent leakage.
4. **Pathway resource:** Which pathway database release(s) to fix? GO BP + Reactome required; KEGG conditional on mapping coverage.
5. **Peptide data:** Is there any upstream Spectronaut export with PEP.Quantity or unique peptide counts that we have not yet loaded?
6. **Output directory:** Confirm `descriptive/analysis_v2.0/{metadata,qc,abundance,detection,environment,site,pathway,ml,tables,figures}/` as the v2 output root.
7. **Session recording:** Adopt which R/Python session capture method (e.g., `sessionInfo()`, `sessioninfo::session_info()`)?
