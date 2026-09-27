# Plasma proteomics — Analysis Plan v2.0

Specification date: 2026-09-26, America/Los_Angeles. Repository: `F:/env`. Status: **PROTOCOL FROZEN AS DOCUMENTATION, NOT EXECUTED. Technical release prerequisites remain open.** This document specifies future work; it does not authorize running it. No new biological results, model fitting, figures or candidate selection were generated for this task.

## 1. Authority, scope and evidence history

The author's task instructions supersede inconsistent legacy terminology. `STUDY_DESIGN_AUDIT.md` retains the corrected audit, evidence anchors R1–R12, site composition and historical reconciliation. Historical v1 and the frozen prospective branch remain separate reproducible evidence layers. This is a new unified analysis specification written after historical data access, not a retrospective claim of preregistration.

The question is whether target exposure is associated with the plasma proteome, how abundance and detection relate to ordered exposure levels, how associations differ by Environment and recruitment Site, and whether an interpretable, experimentally translatable panel can identify exposure status. Success is not assumed. Exposure assignment has not been established as randomized; associations must not be written as causal effects or mechanisms.

### Author-confirmed definitions

| Item | Frozen scientific definition |
|---|---|
| Material / unit | Plasma, not EV-enriched; 515 samples from 515 independent participants, no known repeats |
| Control | No target exposure; same general recruitment framework; represented at multiple Sites and in both Environments; same intended collection, transport, storage and MS workflow |
| Low exposure | Lower target exposure under environmental control/protection |
| High exposure | Higher target exposure without that environmental control/protection |
| Ordering | Control < Low < High in target exposure level; no equal physical spacing assumed |
| Duration | Separate optional participant metadata; a Low participant may have longer exposure duration than a High participant |
| Environment | Humid-hot or High-altitude; recruitment/collection context; Low/High definitions are consistent across both |
| Site | Recruitment location, nested within Environment; no Site spans both; documented real names may be used |
| Preanalytics | Same intended SOPs; broad contemporaneous recruitment can include different collection months. Exact processing delay, centrifugation, transport and freeze-thaw metadata are unavailable |
| Instrument / software | Orbitrap Astral Zoom; DIA acquisition; Spectronaut; downstream field `PG.Quantity`; preparation details and software processing settings must not be invented |
| Clinical metadata | Incomplete; some participants may have other diseases. No reliable disease-free cohort definition is available |

Legacy mapping, used only to read frozen files: `control`/`Control` → Control; `low`/`Short` → Low exposure; `high`/`Long` → High exposure; `high_temperature`/湿热 → Humid-hot; `high_stress`/高海拔 → High-altitude. Legacy `dose`, `Long_vs_Short`, `Short_peak`, `D04_dose_trajectory.R` and similar tokens are computational history, not duration, measured dose or a longitudinal trajectory. Legacy high-pressure wording is corrected to High-altitude; no separate physical high-pressure exposure has been established. Unique protein means group-enriched/group-specific detection protein, not unique peptide; peptide evidence is identification QC only.

### Fixed populations and chronology

| Environment | Group | Full cohort | Discovery | Reused hold-out |
|---|---|---:|---:|---:|
| Humid-hot | Control | 95 | 71 | 24 |
| Humid-hot | Low exposure | 83 | 62 | 21 |
| Humid-hot | High exposure | 101 | 76 | 25 |
| High-altitude | Control | 58 | 44 | 14 |
| High-altitude | Low exposure | 103 | 77 | 26 |
| High-altitude | High exposure | 75 | 56 | 19 |
| Total | | 515 | 386 | 129 |

The original export contains 519 samples and 3,817 protein groups; the existing group-defined analytical cohort contains 515. Preserve existing inclusion identities and reasons for the four outside the analytical cohort; do not invent new clinical exclusions. Core full-cohort group counts are 153/186/176; Discovery counts are 115/139/132 and hold-out counts 38/47/44.

Historical N=515 analysis preceded the split. The fixed 386/129 assignment was then used for Discovery eligibility and the locked 85-protein family before D08–D10 evaluation. The term Validation set remains valid within that frozen prospective protocol. New ML must call the 129 **reused within-cohort hold-out evaluation（重复使用的队列内留出评估）**, disclose prior analytical use and never call it untouched or external validation. True external validation requires new participants. Do not rerandomize or alter any frozen assignment.

## 2. Common contracts inherited by every module

Each module below provides all 18 required fields. Referenced contracts are normative parts of those fields, not optional recommendations. Numerical conventions introduced here are protocol decisions, not universal proteomics cutoffs. They cannot be adjusted to increase discoveries or improve hold-out results.

### Identity, inputs and universes

Use `PG.ProteinGroups` as the stable row key and the existing `UniqueSampleID` positional mapping. `Gene_symbol` and `Display_label` are annotations, not join keys. Duplicate gene symbols do not remove protein groups. Exact inputs are `rawdata/processed.xlsx`, `rawdata/rawdata.xlsx`, `rawdata/sample_mapping_FINAL.xlsx`, `descriptive/dose_defined_metadata.csv`, `descriptive/canonical_protein_annotation.csv`, and `descriptive/discovery_validation_split/discovery_validation_assignment.csv`. Existing derived matrices may be reused only after matching the source and version; never insert v2 exclusions into frozen files.

| Universe | Deterministic rule for future execution |
|---|---|
| U0 | All exported protein-group identities, before technical exclusions; descriptive denominator only |
| Utech | U0 minus definite Category A technical/search contaminants under Freeze 3; unresolved mixed groups retained with flags, not silently classified as clean |
| Q515 | Utech with finite positive quantity in ≥70% separately in Control, Low and High among the fixed 515; integer ceiling thresholds 108/131/124. NA retained after log2. Membership generated only after Freeze 3 |
| D515 | Utech with ≥10 detected and ≥10 non-detected observations overall among 515, independent of Group labels. All Utech remain in descriptive detection tables, including all-detected/all-missing rows |
| Qenv | Q515 plus ≥10 observed values in every one of the six Group × Environment cells, full-rank observed design and ≥5 residual degrees of freedom. This same list supports both Environment strata and direct interactions |
| Denv | D515; all six participant cells ≥10, full-rank design, ≥10 total detections and non-detections within each Environment. Complete separation is handled by the prespecified estimator, not by excluding interesting proteins |
| Qsite / Dsite | Parent Q515 / D515 with the module-specific supported Site cells defined in Module 11; never selected on Site P values |
| Mfold | Utech intersected with training-fold eligibility only. Quantitative features require ≥70% detection in each relevant original Group in that fold; all-missing/zero-variance features excluded. Recompute within every training split, never subset Q515 |

Finite positive export quantity defines detected=1; otherwise detected=0 for detection summaries, but non-positive quantities are separately counted and investigated. Quantitative non-positive entries are missing, never zero on the log2 scale. Unexpected infinities, duplicate identities or broken mappings stop input acceptance; they do not trigger silent repair. No extra participant exclusion for optional metadata, abundance outliers or PCA position is permitted. A proven technical sample failure would require a documented prospective amendment before v2 fitting; no such failure is asserted here.

The ≥70% common abundance rule intentionally targets reliably quantified proteins; it does not cover the complete biological response. Q515 defines only the common quantitative-abundance universe and MUST NOT restrict D515, detection, enriched-detection or observed group-specific analyses. D515 preserves the separate detection question. For quantitative-eligibility sensitivity summaries, additionally report the corresponding common-abundance universes at ≥50%, ≥60%, ≥70% and ≥80% detection separately in Control, Low and High. The ≥70% rule remains primary; the other thresholds are prespecified sensitivity summaries and must not be selected according to discovery count, effect size, significance or hold-out performance. Common quantification eligibility does not remove bias from informative missingness. Non-estimable proteins remain listed with reason and NA inference. For each prespecified family, keep its original eligible denominator in BH by assigning non-estimable tests P=1 for adjustment only; retain NA in the reported raw-P field. No significance from failed fits.

### A: Quantitative model, effects and confidence intervals

Primary model: categorical `~ 0 + Group + Environment`, fitted on observed log2 quantities using limma `lmFit`, `eBayes(trend=TRUE, robust=TRUE)`. Require observed full rank, ≥10 observed values per Group and ≥5 residual degrees of freedom. Freeze positive signs as Low−Control (LC), High−Control (HC), High−Low (HL). Use exact per-protein contrast covariance with missing data: in a v2 implementation reparameterize a scalar contrast as a coefficient using limma `contrastAsCoef` and refit, rather than rely on approximate non-orthogonal `contrasts.fit` standard errors. The two-coefficient Group omnibus uses an appropriate full-rank reference design and moderated F test. This new precision safeguard is explicit; it does not imply historical results have been numerically recomputed or shown invalid.

For coefficient/contrast estimate b, use `SE = stdev.unscaled * sqrt(s2.post)` and `95% CI = b ± qt(0.975, df.total) * SE`, equivalently supported `topTable(confint=0.95)` for a correctly fitted scalar coefficient. Report model-specific moderated total df and observed N. Do not reconstruct SE by b/t. Intervals are pointwise, not simultaneous or post-selection intervals; FDR significance and CI crossing answer different questions. The omnibus has no single signed effect or scalar CI: report its component effects/CIs and F/df/P. limma's official implementation uses this posterior-variance t interval. [limma source](https://raw.githubusercontent.com/bioc/limma/master/R/toptable.R)

Historical `dv_shared.R` uses `abs(logFC/t)` plus `qnorm(.975)`; Stage 07 primary tables do not themselves carry CI fields. The historical defect concerns interval reporting/zero-effect SE reconstruction. Historical candidate selection and replication counts use moderated P values/BH; there is no demonstrated change to those counts. Preserve old outputs and label their CI method. The new exact-contrast implementation could change numerical SE/P in v2 with non-orthogonal missing-data designs; do not claim v2 must reproduce every historical statistic. [limma manual, contrasts.fit and contrastAsCoef](https://bioconductor.org/packages/release/bioc/manuals/limma/man/limma.pdf)

### E: Estimands and standardization

Primary overall exposure contrast is `E = (186/362)*mu_L + (176/362)*mu_H - mu_C`. It targets this cohort's exposed mixture on the adjusted log2 scale, not the arithmetic mean of raw concentrations. Use the same weights in both Environments, interactions and leave-one-site-out (LOO, 逐站点剔除) fits. Equal 0.5/0.5 weighting is one declared sensitivity. Do not collapse Low/High into one model group. Group-profile fitted means are standardized to fixed Humid-hot/High-altitude weights 279/515 and 236/515; display their contrasts and CIs. No adjustment distribution is chosen after examining effects.

### S: Sensitivities and optional clinical metadata

Sensitivity branches retain the primary universe, contrasts and effect signs and cannot replace the primary based on significance counts: sample-median normalization; Module 09 missingness handling; Site-adjusted `Group + Site` without redundant Environment intercept; and Module 11 LOO. Category C signature adjustment is an explicitly potentially overadjusted sensitivity, never assumed confounder control. Do not create a full factorial combination of all sensitivities.

If age, sex, BMI, smoking, alcohol or baseline disease metadata later become validly linked, freeze a dated addendum before adjusted fitting: include a prespecified baseline variable only if observed in ≥90% overall and ≥80% in each Group and coding is credible; fit a joint complete-case sensitivity only if ≥80% of every Group remains and full rank/residual df criteria hold. Otherwise report availability and defer that adjustment rather than exclude participants from the primary. These are feasibility conventions. Report included/missing N and compare the original model on that same complete-case subset to separate selection from adjustment. No univariate P-value covariate screening. Disease-free exclusions are not permitted with current information. Exposure duration is not a universal baseline confounder: it is undefined for many controls and may be part of exposure; if usable, examine it only among exposed participants in a separately specified sensitivity, without redefining Group or primary hierarchy. No automatic adjustment for consequences of exposure.

### F: Multiplicity architecture

All inferential abundance/detection P values are two-sided unless the explicitly bidirectional ordered test below constructs them from directional component tests. BH threshold is q<0.05; no primary hard log2FC threshold. These families control separate questions, not manuscript-wide FDR.

| Family ID | Included tests | Scientific scope |
|---|---|---|
| A-E | One E test per Q515 protein | Overall exposure abundance |
| A-G | One 2-df Group omnibus per Q515 protein | Any categorical Group abundance difference |
| A-O | One bidirectional ordered P per Q515 protein | Strict increase or strict decrease across adjacent exposure levels |
| A-LC / A-HC / A-HL | Separate BH across Q515 for each named pairwise contrast | Three distinct secondary biological questions |
| D-E / D-G / D-O / D-LC / D-HC / D-HL | D515 proteins, separate family per named detection question | Detection axis is a different endpoint, not another opportunity to call abundance significant |
| I-E / I-G | Qenv proteins, separate exposure-interaction and 2-df Group-interaction families | Averaged modification versus any Group modification |
| I-pair | All Qenv proteins × three pairwise interaction contrasts, pooled BH | Secondary interaction localization; avoids selecting the best interaction |
| DI-E / DI-G / DI-pair | Same architecture on Denv | Detection interaction, separately labeled |
| ENV-A / ENV-D | One adjusted Environment main-effect test per Q515 / D515 | Context association, not an identifiable causal environmental effect |
| ENV-stratum | One BH family for each prespecified Environment × abundance/detection contrast | Stratum-specific secondary reporting; not proof of interaction |
| SITE-A / SITE-D | One omnibus nested-Site association per eligible protein | Any within-Environment Site association |
| SITE-H | Protein × E/LC/HC/HL heterogeneity tests pooled, separately for abundance and detection | Exploratory site modification across supported cells |
| PATH-R / PATH-O | All tested terms across GO BP, Reactome and eligible KEGG, pooled within each endpoint/contrast and analysis type; ORA pools up/down sets for that contrast | Pathway-resource redundancy cannot create three chances for significance |
| SENS-* | Corresponding parent family in each named sensitivity, separately labeled | Robustness only, never a union of sensitivity discoveries |
| HIST-85 | Existing frozen BH across 85 in Validation | Unchanged historical rule |

No FDR tests for descriptive strict-specific labels, threshold gradients, SMDs, LOO influence, model stability or figures. If reporting a union of pairwise discoveries, also show BH pooled over Q515 × three contrasts as a sensitivity and label which counts use which scope. Do not assert union-wide FDR from per-contrast q values. All eligible proteins, failed fits and tested denominators must be visible. No significance gate from A-E to A-G/A-O/pairwise. Standard BH assumptions remain; no study-wide guarantee is asserted.

## 3. Executable module specifications

### Module 01 — Metadata and cohort description

| Field | Specification |
|---|---|
| Scientific question | Who contributed to the cohort and how are Group, Environment and Site distributed? |
| Population | Fixed 515; original 519 only for source-to-cohort flow; frozen 386/129 for subset description |
| Input dataset | Canonical participant metadata, final mapping and frozen assignment named in Section 2 |
| Protein universe | Not applicable; participant-level module |
| Outcome | Counts, variable availability, baseline distributions and subset balance |
| Predictor/design | Overall/Control/Low/High; Discovery/reused hold-out; Environment/Site strata |
| Model/test | Descriptive summaries only; continuous mean/SD and median/IQR, categorical n/N; SMD for split balance |
| Contrast | Discovery minus reused hold-out; no baseline significance screening |
| Effect size | Continuous SMD uses pooled within-subset SD; binary SMD uses pooled Bernoulli variance; multicategory variables reported as level-specific indicator SMDs |
| Confidence interval | Not required for census counts or descriptive SMDs; report denominators and missing N |
| Multiplicity family | None |
| Missingness policy | Explicit unavailable/missing rows; no participant deletion for optional covariates |
| Sensitivity analysis | Later metadata sensitivity follows S only; never retroactively changes primary |
| Environment/Site handling | Fixed strata; calendar collection versus MS acquisition dates distinguished |
| Output tables | Table 1 overall/C/L/H; Table 2 Discovery/reused hold-out; supplementary by Environment and Site; availability table |
| Output figures | Cohort flow and Group × Environment/Site composition |
| Interpretation boundary | Intended shared SOP is not verified identical handling; no disease-free claim |
| Dependency/freeze prerequisite | Freeze 1 complete; identity consistency check; optional clinical fields do not block completion |

### Module 02 — Normalization audit and matrix provenance

| Field | Specification |
|---|---|
| Scientific question | What processing produced the quantitative input and can transformations be reproduced? |
| Population | Source export, historical 515, Discovery 386 and reused 129 branches |
| Input dataset | P1–P3; Stage 05/helper; Stage 07 manifest/code; D01 and dv_shared; missingness README/code; available export schema/config |
| Protein universe | U0 to branch-specific historical universes; prospective v2 Utech/Q515 |
| Outcome | Verified transformation chain and unresolved settings |
| Predictor/design | Processing stage and branch; not biological outcomes |
| Model/test | Read-only provenance audit; no fitting |
| Contrast | Primary versus sensitivity implementations |
| Effect size | Not applicable; record transformation formula, not a biological effect |
| Confidence interval | Not applicable |
| Multiplicity family | None |
| Missingness policy | Record NA/non-positive handling; do not impute during audit |
| Sensitivity analysis | Freeze one sample-median normalization sensitivity for future Q515, NA mask unchanged |
| Environment/Site handling | No outcome-based choice of normalization by separation; acquisition/date confounding recorded |
| Output tables | Processing-chain and branch-difference table, settings-availability fields |
| Output figures | Future matrix flow schematic; no biological plots in this task |
| Interpretation boundary | `PG.Quantity` alone does not reveal this experiment's normalization; shared processing is not proof of supervised leakage |
| Dependency/freeze prerequisite | Freeze 2: actual config recovered or explicit acceptance of unrecoverable upstream settings before dependent execution |

Verified chain: RAW MS (not supplied) → Spectronaut DIA processing (author-confirmed; version/database/quantification settings unavailable) → upstream normalization **not fully recoverable** → exported `PG.Quantity` → identity/column mapping in P1–P3 → positive quantities with NA retained → eligibility → log2 → branch-specific matrix. P1–P3 `normalize_id`/`Sheet1_normalized` refer to sample strings, not abundance normalization.

| Branch | Verified downstream action |
|---|---|
| Stage 05 primary / Stage 07 | Stage 05 exports quantities; helper log2-transforms; no additional primary normalization or imputation; historical 1,434 × 515 |
| Stage 07 median sensitivity | `log2_x - sample_median + median(all sample_medians)`; same NA pattern |
| Stage 07 coverage/complete-case sensitivities | Changed eligibility; log2-only input; not evidence of another upstream normalization |
| Missingness D0–D3 | Same historical log2 input; D0 retains NA; D1 zero stress; D2 downshift Gaussian; D3 KNN; no added normalization |
| Discovery D01→D02; D08 | D01 exports untransformed Discovery-eligible quantities; dv_shared applies log2 to raw quantities; no added primary normalization |
| Archived trend branch | Reads existing primary log2 matrix; not an independent normalization source or active v2 implementation |

Repository inventory contained workbooks but no identified Spectronaut project, exported search/normalization configuration or FASTA. Recover exact Spectronaut version, local/global/cross-run normalization state, normalization/reference runs, protein aggregation, upstream imputation, identification q-value settings and search/library scope. Public Spectronaut manuals were located but full PDFs were not retrievable through the browsing tool; no experiment-specific default is inferred. If settings remain unavailable, Freeze 2 requires a dated explicit release decision retaining uncertainty and the specified log2-only primary/median sensitivity. For ML, unresolved cohort-wide upstream reference learning limits prospective deployability; a downstream fold-safe pipeline does not erase it.

### Module 03 — Technical contaminants and preanalytical annotations

| Field | Specification |
|---|---|
| Scientific question | Which entries are definite technical/search contaminants and which are retained biological or preanalytical signals? |
| Population | All protein entries; all 515 participants for future signature summaries |
| Input dataset | Export annotation, source FASTA/decoy/contaminant flags if recovered; canonical annotations; externally documented contaminant and plasma-QC references |
| Protein universe | U0 → Utech; independent of Group effects or Validation outcomes |
| Outcome | Category A exclusion, B retention, C flag, unresolved flag and reason/source |
| Predictor/design | Identity-level annotation; future Category C signatures versus Group/Environment/Site |
| Model/test | Deterministic registry classification; signature summaries are descriptive initially |
| Contrast | Counts before/after technical filtering; signature distributions across contexts |
| Effect size | Excluded/retained n; published signature scores if reconstructable, otherwise individual marker summaries |
| Confidence interval | Not applicable to registry counts; inferential signature effects require a separately declared method before fitting |
| Multiplicity family | None for annotation/summary; no significance labels on score associations in this version |
| Missingness policy | Missing annotation is unresolved, not contaminant-free; no score if published coverage requirement cannot be met |
| Sensitivity analysis | Retain B in primary; one exclusion-of-B influence summary only if justified before execution. Category C adjustment under S; ambiguous-contaminant exclusion sensitivity separately labeled |
| Environment/Site handling | Summarize signatures by Group, Environment and Site; do not identify geographic biology from preanalytical signatures |
| Output tables | Registry with exact IDs/category/evidence/action; exclusion flow; marker availability and signature-context summaries |
| Output figures | Filtering flow; future signature distributions by Group/Environment/Site |
| Interpretation boundary | Human keratin, ALB or a platelet marker is not automatically laboratory contamination |
| Dependency/freeze prerequisite | Freeze 3 requires source annotation or a dated, curated reference mapping before Utech is generated; Freeze 4 depends on it |

Category A: explicit decoy/reverse or contaminant database entries, confirmed exogenous trypsin/BSA, documented laboratory contaminants and technical keratins. Exclude from all new biological, Unique, pathway and ML universes. Category B: endogenous ALB, immunoglobulins, apolipoproteins, complement and fibrinogen stay. Category C: erythrocyte/hemolysis, platelet and coagulation/processing markers stay with annotations; they may reflect biology or handling. Plasma-QC marker work supports treating these as sample-related context requiring interpretation. [Geyer et al., plasma sample-related biases](https://pmc.ncbi.nlm.nih.gov/articles/PMC6835559/)

If explicit flags cannot be recovered, use a fixed release of a documented contaminant reference such as the common Repository of Adventitious Proteins (cRAP), mapping exact accessions/species and checking the underlying entry before exclusion. Record reference release and exact matches; do not treat every human entry in a generic contaminant database as definitively exogenous. Technical keratin evidence must be explicit; a `KRT*` prefix alone is insufficient. All-technical multi-accession groups are excluded; mixed human/technical groups remain unresolved and enter the declared ambiguous-group sensitivity. No arbitrary splitting of their measured quantity. Reference accession mapping is a Freeze 3 prerequisite, not a task performed on biological outcomes here.

### Module 04 — Proteome landscape and QC

| Field | Specification |
|---|---|
| Scientific question | What proteome is measured and how do completeness and global structure vary? |
| Population | 519 export samples for raw flow; fixed 515 for scientific description |
| Input dataset | U0/Utech quantities, metadata, future Q515/D515 lists; available run-QC fields only |
| Protein universe | Show U0, Utech, Q515 and D515 separately with denominators |
| Outcome | Proteins/sample, missingness/sample/protein, abundance and detection distributions, depth |
| Predictor/design | Group, Environment, Site and acquisition context |
| Model/test | Descriptive summaries; PCA（主成分分析）on complete-observation Q515 proteins, centered and unit-scaled; no inference from separation |
| Contrast | ≥50/60/70/80% detection gradients overall and by Group/Environment/Site |
| Effect size | Counts, proportions, medians/IQR and PCA explained variance |
| Confidence interval | Descriptive count denominators; Wilson intervals for detection proportions where displayed |
| Multiplicity family | None |
| Missingness policy | No quantitative zero filling; PCA complete-protein subset and its size explicitly reported |
| Sensitivity analysis | PCA on median-imputed Q515 solely as a labeled visualization sensitivity; UMAP optional exploratory only, seed 20260926, n_neighbors=15, min_dist=0.1 on same visualization matrix |
| Environment/Site handling | Annotate rather than erase context; no automatic batch correction |
| Output tables | Full data flow, retained/excluded protein counts; sample/protein QC; detection gradients; availability of precursor/peptide/q-value/run QC |
| Output figures | Figure 1 flow, depth, missingness, distributions and annotated PCA; optional UMAP supplementary |
| Interpretation boundary | Depth is not biological richness; no absolute protein concentrations from cross-protein intensity comparisons |
| Dependency/freeze prerequisite | Freezes 2–4 for revised counts; no unavailable CV, retention-time or raw-MS variables invented |

### Module 05 — Overall Control versus Exposure abundance

| Field | Specification |
|---|---|
| Scientific question | Is target exposure associated with plasma-protein abundance? |
| Population | Full fixed 515 |
| Input dataset | Versioned Q515 log2 matrix and canonical metadata |
| Protein universe | Q515, not historical 256 or 85 |
| Outcome | Observed log2 protein-group abundance |
| Predictor/design | Categorical Group + Environment, contract A |
| Model/test | limma moderated t using exact scalar contrast fit |
| Contrast | E from contract E; exposed minus Control |
| Effect size | Weighted adjusted log2 difference; 2^E as ratio of weighted geometric means |
| Confidence interval | Contract A moderated-t 95%; transform bounds for ratio |
| Multiplicity family | A-E |
| Missingness policy | Observed-value primary; Q515 eligibility; no imputation |
| Sensitivity analysis | Equal weights; S and Module 09; fixed universe |
| Environment/Site handling | Environment main adjustment; Site adjustment/LOO secondary |
| Output tables | Every protein, observed N, effect/SE/CI/t/df/P/q, estimability, direction and significant count |
| Output figures | Figure 2 effect forests, MA, compact volcano and transparently selected examples |
| Interpretation boundary | Conditional association; averaging can cancel opposing Low/High effects; Level 2 not gated |
| Dependency/freeze prerequisite | Freezes 1–5 and 7; execution authorization |

### Module 06 — Ordered exposure levels, omnibus and response architecture

| Field | Specification |
|---|---|
| Scientific question | Do adjacent exposure levels support a consistent direction, any Group difference, and which descriptive shapes occur? |
| Population | Full 515 |
| Input dataset | Q515 log2 matrix, Group/Environment metadata |
| Protein universe | All Q515; no Low-vs-High significance preselection |
| Outcome | Abundance; standardized group means and adjacent effects |
| Predictor/design | Contract A categorical design; no 0/1/2 physical dose regression |
| Model/test | Formal directional intersection–union test（交并检验）specified below; 2-df moderated Group F; descriptive shape rules |
| Contrast | a=Low−Control, b=High−Low, c=High−Control; omnibus LC=HC=0 |
| Effect size | a, b, c and standardized fitted means; no invented continuous slope |
| Confidence interval | Contract A for each effect/mean; pointwise bounds do not jointly establish shape |
| Multiplicity family | A-O and A-G separately; no inferential q for descriptive patterns |
| Missingness policy | Non-imputed A; means are model predictions, not mislabeled observed means |
| Sensitivity analysis | Module 09; shape tolerance 0 and 0.10 versus primary descriptive 0.05 log2 |
| Environment/Site handling | Fixed Environment standardization in E; context patterns secondary under Modules 10–11 |
| Output tables | Complete Q515 omnibus/ordered results, a/b/c/CIs, primary pattern and uncertainty flag |
| Output figures | Figure 3 adjusted response plots, heatmap and whole-universe pattern proportions, with Group-associated subset labeled separately |
| Interpretation boundary | Cross-sectional exposure order, not duration, adaptation, recovery or within-person progression |
| Dependency/freeze prerequisite | Freezes 2–5 and 7; coefficient/P extraction must match fitted model |

**Formal order without spacing assumptions.** For moderated t statistics for a and b, let p_a+ and p_b+ be upper-tail P values for positive differences, and p_a−/p_b− their lower-tail counterparts, using the corresponding fitted moderated df. Set `p_inc=max(p_a+,p_b+)`, `p_dec=max(p_a−,p_b−)`, and `p_order=min(1,2*min(p_inc,p_dec))`. Apply BH once across Q515 to p_order. This is a conservative derived intersection–union construction for **both adjacent differences strictly positive or both strictly negative**, with a two-direction Bonferroni adjustment. It does not require independence of the two component tests. It intentionally has limited sensitivity to plateaus; it is not a test of all possible nondecreasing alternatives. Report direction only with the corresponding supported adjacent signs. Weakly monotone/plateau appearances remain descriptive; no equal-spacing linear trend is substituted.

**Descriptive patterns**, assigned in this precedence order using a,b,c and epsilon=0.05 log2 solely as a display convention: (1) High-selective increase/decrease if |a|≤epsilon and b>epsilon / b<−epsilon; (2) Low-selective elevation/suppression if a>epsilon and b<−epsilon / a<−epsilon and b>epsilon, and |c|≤epsilon; (3) remaining opposite-sign adjacent effects exceeding epsilon → non-monotonic/reversal, with Low-peak or Low-trough subtype; (4) a,b both ≥−epsilon and c>epsilon → monotonic increase; (5) a,b both ≤epsilon and c<−epsilon → monotonic decrease; (6) otherwise uncertain/other. Missing or non-estimable effects → uncertain/other. Zero-crossing adjacent CIs generate a separate uncertainty flag even when a descriptive label is assigned. Near-zero effects do not demonstrate equivalence. Standardized row z-scores may aid heatmap display but do not determine formal inference.

### Module 07 — Three pairwise abundance contrasts

| Field | Specification |
|---|---|
| Scientific question | How do Low and High each differ from Control, and from one another? |
| Population | Full 515 in common three-group model |
| Input dataset | Same matrix/design as Module 05 |
| Protein universe | Q515 |
| Outcome | Observed log2 abundance |
| Predictor/design | Contract A |
| Model/test | Moderated t for each scalar contrast |
| Contrast | LC, HC, HL; always higher listed exposure minus lower |
| Effect size | log2FC and ratio 2^log2FC |
| Confidence interval | Contract A |
| Multiplicity family | A-LC, A-HC, A-HL; pooled sensitivity for union claims under F |
| Missingness policy | No imputation; parent estimability contract |
| Sensitivity analysis | S and Module 09 |
| Environment/Site handling | Main Environment adjustment; formal modification handled separately |
| Output tables | Full effects/CIs/P/q/direction/N; significant counts; overlaps and contrast-specific membership |
| Output figures | Pairwise effect matrix, forests, annotated heatmaps, MA/volcano and UpSet |
| Interpretation boundary | Significant only in one contrast is descriptive membership, not proof of unique biology |
| Dependency/freeze prerequisite | Freezes 2–5 and 7 |

### Module 08 — Detection and Unique proteins

| Field | Specification |
|---|---|
| Scientific question | Does detection probability differ by exposure, and which proteins show strict observed specificity? |
| Population | Full 515; Module 10/11 strata separately |
| Input dataset | Utech binary finite-positive detection matrix before quantitative eligibility |
| Protein universe | D515 formal; all Utech descriptive, including ineligible extremes |
| Outcome | Binary detection, never zero-filled abundance |
| Predictor/design | Categorical Group + Environment |
| Model/test | Firth penalized logistic regression（Firth偏倚校正逻辑回归）, uniform across proteins; penalized likelihood-ratio tests for linear coefficient constraints; avoids switching estimators on separation |
| Contrast | LC/HC/HL conditional log odds; E weighted log-odds contrast; 2-df Group omnibus; adjacent ordered detection test |
| Effect size | Group detected n/N; unadjusted and standardized absolute detection-proportion difference; conditional odds ratios, clearly distinguished from marginal probability differences |
| Confidence interval | Wilson group rates; profile penalized-likelihood 95% for scalar log-odds contrasts/ORs; delta-method marginal risk-difference CI using full covariance, clipped to [−1,1] with sparse-case warning |
| Multiplicity family | D-E/D-G/D-O/D-LC/D-HC/D-HL; no P values for strict labels |
| Missingness policy | Non-detection is the outcome; participant denominator remains fixed; data-corruption missingness must be resolved before binary coding |
| Sensitivity analysis | Unadjusted Fisher exact pairwise tests, separately labeled; descriptive target/comparator grids below |
| Environment/Site handling | Standardize probabilities to E weights; use Modules 10–11 for context tests, not separate significance comparisons |
| Output tables | All rates, differences, OR/CI/P/q, model status, testability and strict-specific flags |
| Output figures | Detection landscape, probability forests, Group/Environment/Site detection heatmaps |
| Interpretation boundary | Non-detection is not biological absence; technical depth may affect results; zero cells do not imply infinite biological effect |
| Dependency/freeze prerequisite | Freezes 2–4, 6 and 7; verify logistic constraint implementation before execution |

Use a profile penalized-likelihood implementation supporting reparameterized contrasts and joint tests; do not compare penalized likelihoods with inconsistent penalty definitions. Official `logistf` documentation supplies profile inference and penalized likelihood-ratio procedures. [logistf manual](https://cran.r-project.org/web/packages/logistf/logistf.pdf)

For E, report `exp(w*beta_L+(1-w)*beta_H)` as a weighted conditional-odds contrast, **not** the odds ratio of a collapsed Exposure group. Also report standardized `w*p_L+(1-w)*p_H-p_C`, averaging over fixed Environment weights. Ordered detection uses the same max-component/two-direction construction as Module 06, using signed-root penalized likelihood-ratio directional P values (asymptotic); retain the separate Group omnibus.

Level A, **Group-enriched detection proteins**, is the formal inferential level: use the prespecified differential-detection model, multiplicity correction and effect direction, with no arbitrary detection-frequency cutoff required for inferential significance. Level B, **Observed group-specific proteins**, is a strict descriptive level: require exactly zero observed detections in each specified comparator Group and report the target detection series ≥50%, ≥60%, ≥70% and ≥80% in parallel. Do not designate any one target-frequency threshold as the sole or primary definition. The combination target ≥80% plus comparator 0% may additionally be labeled **high-stringency observed group-specific**. Also show the complementary low-comparator grid ≤1% and ≤5% crossed with target ≥50/60/70/80%, but keep those enriched descriptive categories distinct from the zero-comparator observed group-specific category. All thresholds are pragmatic descriptive conventions, not biologically validated cutoffs. For Exposure versus Control, target proportion is the observed combined Low+High proportion; also show each subgroup separately so pooled coverage cannot hide one absent subgroup. Report both “specific relative to named comparator” and “specific relative to both other groups” explicitly. A minimum target and each comparator N≥10 is required for a strict label; otherwise counts only. Always report exact group denominators and show the exact binomial upper bound for zero-detection comparators (one-sided 95% `1-0.05^(1/n)`). The historical `<20% comparator` rule remains historical and is not inherited. Apply the same zero-comparator/gradient display to Environment and supported Site comparisons with their explicit denominators.

### Module 09 — Missingness and imputation sensitivity

| Field | Specification |
|---|---|
| Scientific question | Are abundance conclusions sensitive to alternative missing-value assumptions? |
| Population | Full 515; ML uses its separate fold-specific imputer |
| Input dataset | Q515 observed log2 matrix; existing missingness README/code as method reference only |
| Protein universe | Fixed Q515 across primary and sensitivities; no imputation-created eligibility |
| Outcome | Effects, directions, CIs, rankings and discovery membership under each branch |
| Predictor/design | Same Group + Environment and contrasts as primary |
| Model/test | Contract A after each prespecified sensitivity transformation |
| Contrast | E, omnibus, ordered and LC/HC/HL; compare each with non-imputed primary |
| Effect size | Effect shift, direction concordance, rank correlation and set overlap; every protein retained in comparison |
| Confidence interval | Model-conditional A intervals; single-imputation intervals omit imputation uncertainty and are labeled accordingly |
| Multiplicity family | SENS-* matching the parent question; no union across methods |
| Missingness policy | Primary observed values; two prespecified sensitivity branches below; no zero replacement in v2 inference |
| Sensitivity analysis | Downshift Gaussian and KNN, neither chosen by DEP count; Gaussian seed variation assessed as descriptive range only |
| Environment/Site handling | Same model/context as primary; no class-specific filling |
| Output tables | Missingness diagnostics and all-protein method comparison, N imputed, failures and effect/CI differences |
| Output figures | Missingness-versus-abundance summaries and effect concordance; not a best-method leaderboard |
| Interpretation boundary | Observed-value modeling can be biased by nonignorable missingness; imputation does not prove its mechanism or repair identification failure |
| Dependency/freeze prerequisite | Freezes 2–5; adaptation must remove hard-coded historical 1,434/256 assertions from a new derivative, preserving original code |

Reuse historical D2: for each sample draw missing log2 entries from `Normal(mu_j−1.8*sd_j, (0.3*sd_j)^2)`, based on observed Q515 values, primary seed 20260925; seeds 20260926–20260934 provide a fixed descriptive variability range. Reuse D3: `impute.knn(k=10,rowmax=0.5,colmax=0.8,maxp=1500,rng.seed=20260925)`. Observed entries must remain unchanged. If preconditions fail, report the branch unavailable; do not loosen constraints to complete it. The Gaussian branch represents a left-censoring scenario; KNN represents similarity-based reconstruction. Neither assumption is established by correlation of missingness and abundance. Do not average single-imputation P values or treat seed repeats as independent samples. Historical D1 log2-zero replacement remains an extreme historical stress test, superseded for v2 imputation. Methodological evidence shows nonignorable missingness can distort abundance inference; sensitivity agreement is robustness, not proof of unbiasedness. [O'Brien et al., nonignorable proteomics missingness](https://pmc.ncbi.nlm.nih.gov/articles/PMC6249692/)

### Module 10 — Environment estimates and interaction

| Field | Specification |
|---|---|
| Scientific question | How do exposure associations differ between Humid-hot and High-altitude? |
| Population | Full 515 first, then 279 Humid-hot and 236 High-altitude |
| Input dataset | Quantitative and binary matrices with six Group × Environment cells |
| Protein universe | Qenv / Denv for paired stratum and interaction reporting; Q515/D515 for adjusted Environment main association |
| Outcome | Abundance and detection, analyzed separately |
| Predictor/design | Six-cell means or full-rank Group*Environment; no redundant Site+Environment intercept model |
| Model/test | Contract A moderated t/F; Module 08 logistic counterpart |
| Contrast | E_Humid−E_Altitude; joint LC/HC modification; pairwise difference-in-differences; High-altitude−Humid-hot main association conditional on Group |
| Effect size | Stratum E/LC/HC/HL and their differences; detection OR/risk-difference modification distinguished |
| Confidence interval | A for abundance; profile logistic intervals for coefficient contrasts and delta-method marginal summaries |
| Multiplicity family | I-E/I-G/I-pair, DI counterparts, ENV-A/ENV-D and declared ENV-stratum families |
| Missingness policy | Same six-cell eligible list; no imputation primary; non-estimability reported, not silently dropped |
| Sensitivity analysis | Site intercepts plus Group and Group×Environment slopes omitting Environment main intercept; fixed E weights; missingness sensitivity secondary |
| Environment/Site handling | Sites nested in Environment; site/acquisition factors limit interpretation even with estimable interaction |
| Output tables | Six-cell N/observed N; all stratum/interaction effects/CIs/P/q; failed-fit reasons |
| Output figures | Figure 4 forests, direct interaction plots and detection heatmaps; explicit null findings |
| Interpretation boundary | Significant in one Environment only is not interaction; Environment association is not causal environmental physiology |
| Dependency/freeze prerequisite | Freezes 2–7; require six cells ≥10 participants, per-protein Qenv/Denv support and full rank |

Define `I_E = [w*mu_L,Hh+(1-w)*mu_H,Hh−mu_C,Hh] − [w*mu_L,Ha+(1-w)*mu_H,Ha−mu_C,Ha]`, w=186/362. Hh/Ha denote Environment, not High exposure. Joint interaction tests LC and HC modification together (2 df); pairwise interaction localization uses all three prespecified contrasts pooled across proteins. Formal ordered inference inside each Environment is secondary with its own family, not required for declaring interaction. All stratum effects are shown regardless of interaction significance.

### Module 11 — Site context, association, heterogeneity and LOO

| Field | Specification |
|---|---|
| Scientific question | Which signals are Site-associated, do Group effects differ across supported Sites, and are pooled effects sensitive to removal of a Site? |
| Population | Fixed 515 across nine Sites; restricted supported cells only for heterogeneity |
| Input dataset | Metadata, acquisition date proxy, Q515/D515 and Category C annotations |
| Protein universe | Parent universes with per-protein Site support; fixed parents for LOO without reselection |
| Outcome | Composition/depth/missingness/global structure; abundance/detection; Group-effect differences |
| Predictor/design | Site nested in Environment; compare `Group+Environment` with `Group+Site`; supported Group×Site terms for heterogeneity |
| Model/test | Moderated partial F / corresponding penalized logistic joint tests; LOO refits are influence summaries |
| Contrast | Nested Site terms jointly; within-site E/LC/HC/HL heterogeneity where supported; omitted-site minus full effect |
| Effect size | Within-Environment Site deviations; supported site-specific Group effects; LOO delta/sign/CI |
| Confidence interval | A/logistic contract for estimable effects; no CI on arbitrary count changes |
| Multiplicity family | SITE-A/SITE-D; SITE-H pooled four questions per endpoint; no new LOO significance family |
| Missingness policy | Site-association models require ≥10 observed values per modeled Site for abundance; detection requires ≥10 participants/site and parent event rule. Otherwise mark protein unavailable for the all-Site omnibus |
| Sensitivity analysis | LOO all nine Sites; preserve E weights and parent universe; acquisition proxy adjustment only if full rank; no automatic random slopes |
| Environment/Site handling | Remove redundant Environment intercept when Site included; within-Environment interpretation only |
| Output tables | Site N/Group/Environment/depth/missingness; Site/date map; omnibus results; supported heterogeneity and LOO separately |
| Output figures | Composition, depth and detection heatmaps; Site-effect and LOO forests; existing PCA annotated by Site |
| Interpretation boundary | Site association, heterogeneity and deletion robustness are different questions; no causal geographic claim |
| Dependency/freeze prerequisite | Freezes 2–7; supported cells and rank checks before fitting; no forced empty-cell estimates |

| Site | Environment | Control | Low | High |
|---|---|---:|---:|---:|
| FJ_FQ | Humid-hot | 13 | 24 | 32 |
| FJ_PT | Humid-hot | 4 | 10 | 12 |
| FJ_QZ | Humid-hot | 32 | 18 | 11 |
| GZ_TH | Humid-hot | 46 | 31 | 46 |
| XZ_GG | High-altitude | 30 | 66 | 46 |
| XZ_YA | High-altitude | 2 | 19 | 1 |
| XZ_YB | High-altitude | 10 | 0 | 0 |
| XZ_YC | High-altitude | 6 | 7 | 21 |
| XZ_YD | High-altitude | 10 | 11 | 7 |

For pairwise heterogeneity require ≥10 participants in both contrasted cells at a Site, ≥10 observed values per cell for abundance, at least three supported Sites, ≥5 residual df and full rank. For E require all three cells ≥10; only FJ_FQ, FJ_QZ, GZ_TH and XZ_GG meet the participant rule. Pairwise LC supports those four plus XZ_YD; HC supports the four; HL supports the four plus FJ_PT. Detection heterogeneity uses those participant-supported Sites and ≥10 pooled detections/non-detections in the restricted data, with Firth handling separation. Per-protein observed support may reduce these sets further. Test equality of supported within-site effects using an estimable cell-means/contrast system, never an empty XZ_YB exposed cell. Fewer than three supported Sites means descriptive effects only. These thresholds are precision conventions, not universal significance rules.

Within-Environment Site deviations use participant-count weighted centering among Sites in that Environment. A full all-Site omnibus compares the additive nested models and tests 7 extra Site parameters when full rank. If sparse observed data invalidate it, report unavailable rather than changing the primary Site family to a favorable subset. GZ_TH aligns with acquisition date 20260717 and XZ_GG with 20260527 in verified metadata; Site and acquisition contributions cannot be separated where aligned. LOO direction stability does not prove no heterogeneity; loss of P<0.05 after deletion is not by itself evidence of instability.

### Module 12 — Functional and pathway interpretation

| Field | Specification |
|---|---|
| Scientific question | Which measured-proteome processes align with exposure, ordered effects, pairwise responses and context modification? |
| Population | Full-cohort biology; no pathway-derived full-cohort features passed to ML |
| Input dataset | Complete v2 effect/statistic tables and fixed human identifier/resource mappings |
| Protein universe | Successfully mapped eligible/tested proteins for the exact endpoint, not whole human genome/proteome |
| Outcome | Ranked pathway association and selected-set over-representation |
| Predictor/design | GO Biological Process, Reactome, KEGG when mapping adequate; releases fixed before enrichment |
| Model/test | `cameraPR` signed-statistic competitive analysis, primary inter-gene correlation=0.01; ORA hypergeometric upper-tail secondary |
| Contrast | E; LC/HC/HL; ordered-support up/down sets; pattern ORA; Environment stratum and signed interaction statistics |
| Effect size | Ranked direction/statistic and pathway P/q; ORA fold enrichment and odds ratio, hits/background sizes |
| Confidence interval | No invented CI for ranked enrichment; ORA odds-ratio exact conditional CI from its 2×2 table when estimable |
| Multiplicity family | PATH-R/PATH-O pooled resources per contrast; response-pattern ORA pools all displayed pattern sets × terms |
| Missingness policy | Use observed-model statistics; no matrix imputation merely to satisfy enrichment software |
| Sensitivity analysis | cameraPR correlation 0.05 fixed sensitivity; mapping losses and resource coverage reported; not choosing whichever produces more terms |
| Environment/Site handling | Shared directions descriptive; pathway significance differences alone do not establish interaction; use interaction ranks for modification |
| Output tables | Mapping/unmapped/duplicate decisions, resource releases, universe/set size, term/hits/direction/P/q |
| Output figures | Ranked pathway direction/effect summaries and ORA dot plots with denominators, integrated into Figures 2–4 |
| Interpretation boundary | Enrichment is functional association, not mechanism or independent validation; assumed pathway correlation is a limitation |
| Dependency/freeze prerequisite | Freezes 3–7 and resource/mapping snapshot before execution; D10 historical pathway status remains unchanged |

Mapping rule: retain a protein group for gene-based analysis only when all mapped human accessions resolve unambiguously to one gene; otherwise flag unmapped/ambiguous. If multiple measured groups map to the same gene, retain the group with highest overall detection among the exact eligible universe, then lowest lexical `PG.ProteinGroups` as tie-breaker, without inspecting P values or effects. The same representative defines the tested background and selected sets. GO BP/Reactome are required; KEGG runs only when ≥80% of the unambiguously gene-mapped universe is resolvable to KEGG gene identifiers (not necessarily annotated to a pathway) and source access is adequate. Report failure rather than invent mapping.

Test pathways containing 10–500 measured mapped genes. A selected set must have ≥5 mapped genes and a tested term ≥3 hits for ORA; apply these count-only rules consistently and report skipped sets. Rank E/pairwise/interaction by signed moderated t (detection by signed model statistic), without significance truncation. For ordered response, rank endpoint HC effects as a secondary ordered-context view and label that statistic honestly; increasing/decreasing ordered-supported sets use ORA. A signed HC rank is not itself a formal order test. Nonlinear response families use descriptive ORA; do not attach direction to an unsigned omnibus F. CAMERA accounts for correlation through its specified procedure, but cameraPR's fixed correlation is an assumption here, not estimated from this proteome. [Wu and Smyth, CAMERA](https://pmc.ncbi.nlm.nih.gov/articles/PMC3458527/)

### Module 13 — Historical 256 reconciliation

| Field | Specification |
|---|---|
| Scientific question | Why are historical full-cohort and Discovery selection counts different, within verified evidence? |
| Population | Historical 515 versus frozen Discovery 386 |
| Input dataset | Audit Section J; Stage 07 manifest/High_vs_Low table; D01 eligibility and D02 legacy Long_vs_Short table |
| Protein universe | Historical 1,434 and Discovery 1,445; shared 1,426, historical-only 8, Discovery-only 19 |
| Outcome | Eligibility overlap and historical significance membership |
| Predictor/design | Existing analysis branch; no new fitted model |
| Model/test | Read-only reconciliation of established evidence |
| Contrast | Same historical HL estimand, Environment adjustment, log2/no-imputation procedure |
| Effect size | Existing effect/variance/P/rank changes only; no causal attribution percentage |
| Confidence interval | Historical CI availability/method labeled; no recomputation |
| Multiplicity family | Original per-contrast BH 1,434 versus 1,445, unchanged |
| Missingness policy | Historical NA retained in both; no new manipulation |
| Sensitivity analysis | None executed; counterfactual refits not authorized |
| Environment/Site handling | Environment-only models in both; sample composition differs; no invented covariate change |
| Output tables | Documentation reconciliation table, clearly historical; no new biological result table in this task |
| Output figures | Optional future evidence-history schematic, not a new inference plot |
| Interpretation boundary | 256→85 is not 171 filtered proteins and not independent replication |
| Dependency/freeze prerequisite | No refit needed; keep frozen historical outputs intact |

Verified: all 256 historical significant proteins satisfy Discovery eligibility; 84/85 overlap the historical 256. Thus 172 historical significant proteins are not Discovery-significant, and one Discovery-significant protein was not historical-significant. Different sample information, fitted coefficients/variance, empirical-Bayes estimates, P-value ranks and BH families can change significance. Their separate contributions are not identifiable from table comparison; do not claim all change is power or filtering. The historical primary choices were the same; no changed primary normalization, imputation or covariates explain the count. Future v2 counts must be separately labeled and never merged with the historical 256 as one inferential family.

### Module 14 — Frozen 85→129 prospective evidence

| Field | Specification |
|---|---|
| Scientific question | What support did the locked Discovery family receive under its original Validation protocol? |
| Population | Frozen Discovery 386 and Validation 129 |
| Input dataset | D03 lock, D08 replication summary/results, existing D09–D10 evidence only |
| Protein universe | Exactly historical 85, unchanged |
| Outcome | Estimability, direction, nominal and family-BH replication |
| Predictor/design | Existing model and original rules; not a new v2 rerun |
| Model/test | Report original moderated inference as executed |
| Contrast | HL, legacy Long_vs_Short; no priority reversal based on success |
| Effect size | Existing Discovery/Validation log2 effects and attenuation, when already reported |
| Confidence interval | Existing normal-approximation CI clearly labeled; not silently substituted with v2 intervals |
| Multiplicity family | Existing Validation BH within all 85 |
| Missingness policy | Original protocol retained; no re-eligibility or candidate deletion |
| Sensitivity analysis | None used to redefine success; v2 contaminant overlap annotated only |
| Environment/Site handling | D05–D07 are selected-family context/influence, not independent confirmation |
| Output tables | All 85 with original outcomes and CI labels, failures visible; original source tables retained |
| Output figures | Figure 5 all-family effect comparison and 85/83/29/1 evidence summary |
| Interpretation boundary | Not 85 validated biomarkers, not external validation; prior full-cohort access disclosed |
| Dependency/freeze prerequisite | Preserve existing lock/assignment/results; no further outcome inspection for tuning |

Established outcomes: 85/85 estimable; 83/85 same direction; 29/85 same direction and nominal P<0.05; 1/85 same direction and BH<0.05 within 85. These are distinct evidence levels. If definite contaminants occur among the 85, preserve all historical results, exclude those entries from Utech and report the relationship. No candidate family revision or rescored replication definition is permitted.

### Module 15 — Discovery-only biomarker development

| Field | Specification |
|---|---|
| Scientific question | Can a reproducible, assay-feasible, biologically interpretable small protein panel identify exposure status? |
| Population | Discovery 386 only; pairwise tasks use their corresponding subsets |
| Input dataset | Discovery columns from source quantities, fixed Utech registry and fold-local transforms; no Q515/256/full-cohort result screens |
| Protein universe | Mfold primary Strategy B; fold-local Strategy A secondary; historical 85 conditional comparator only |
| Outcome | Primary binary Exposure; secondary Low/Control, High/Control, High/Low; exploratory three-class |
| Predictor/design | Protein-only Elastic Net logistic regression（弹性网逻辑回归）; multinomial counterpart exploratory; Environment-only benchmark |
| Model/test | 5 outer × 5 inner nested CV, 3 outer repeats; exact selection procedure below |
| Contrast | Primary Control vs Exposure; secondary contrasts never replace it based on performance |
| Effect size | AUROC primary discrimination; all required probability/threshold metrics; coefficient and selection stability |
| Confidence interval | Participant bootstrap of grouped out-of-fold prediction records, 2,000 replicates, labeled conditional approximation; repeat range also shown, not a formal training-uncertainty CI |
| Multiplicity family | No biological BH for model coefficients; no model-superiority claims. All prespecified task/comparator results reported |
| Missingness policy | Eligibility, medians, scaling and any data-derived normalization fitted inside every inner training fold and refitted on outer training only |
| Sensitivity analysis | Strategy A, Environment-only benchmark and Discovery LOO predictive robustness; no nonlinear comparator in this version |
| Environment/Site handling | Stratify folds by Environment × original Group; Site LOO secondary, not used to tune on omitted Site |
| Output tables | Fold definitions, hyperparameters, all out-of-fold metrics, feature/coefficients/panel-size stability and final model specification |
| Output figures | CV flow, stability/coefficient plots and internal ROC/PR/calibration; Figure 6 if model developed |
| Interpretation boundary | Prior analytical access persists; coefficients are predictive conditional weights, not mechanisms; unsupported small panel is an acceptable result |
| Dependency/freeze prerequisite | Freezes 2–4 and 8; actual assay-reference mapping if used; model lock before Freeze 9 |

**Tasks and counts.** Primary Control/Exposure: 115/271. Secondary Control/Low 115/139, Control/High 115/132, Low/High 139/132; positive classes Exposure, Low, High, High respectively. Three-class 115/139/132 exploratory. No class weighting, SMOTE or undersampling. Core primary remains Strategy B + Elastic Net; A is a prespecified comparison, not an opportunity to replace B after reading outer CV or hold-out results. No Random Forest or gradient boosting is needed in this minimum protocol; adding one requires an amendment before development, maximum one nonlinear family.

**Nested resampling.** Use five outer folds × five inner folds with three outer repeats, seeds 20260926/20260927/20260928; inner seed derives deterministically from repeat and outer fold. The smallest Environment × Group Discovery stratum is 44, leaving about 8–9 in an outer assessment fold and 7–8 in an inner assessment fold, so five folds are feasible for all tasks. This is not a power guarantee. Assign participant IDs once per repeat within strata; no seed search. Paired task procedures share relevant fold rules where feasible. Every supervised screen excludes all assessment participants, including any auxiliary three-group screen. Fit protein medians and mean/SD scaling on training data only; apply unchanged. Zero variance/all-missing features are removed based only on training. Fixed log2 is not learned. No combined Discovery/hold-out ComBat, quantile normalization or reference fitting. This nesting applies to unsupervised data-derived preprocessing too. [scikit-learn leakage guidance](https://scikit-learn.org/stable/common_pitfalls.html)

**Features.** Strategy B uses quantitative Mfold with no DE preselection. Strategy A uses the same Mfold and a fold-local limma primary-target contrast screen at BH<0.10, a deliberately frozen predictive screening convention rather than a discovery claim. For primary task use a three-group model and fold-training Low/High proportions for the weighted E contrast; for secondary tasks screen their pairwise effect. No union of many alternative screens, no full-cohort biological rescue and no threshold relaxation for an empty screen; an empty screen yields intercept-only prediction. A separate detection-feature extension is not part of the primary panel; it would require its own training-only universe and amendment. External biological/assay annotations may inform deterministic tie-breaking only if frozen before fitting and independent of this cohort's outcomes. Historical 85 fixed-list CV is conditional on prior full-Discovery selection and optimistically assesses the discovery procedure; report it only as such, outside primary selection. Regenerating the original screen inside folds is required to assess that screening algorithm honestly. The Validation-supported subset and historical 256 cannot be candidate screens.

**Tuning and compact panels.** Freeze alpha={0.1,0.5,0.9,1}; for each alpha use 50 log-spaced lambda/lambda_max fractions from 1 to 0.001, lambda_max calculated separately in the current training set. Inner mean log loss is the selection criterion. Panel options are the untruncated Elastic Net and caps k={3,5,10,20}. For a cap, rank nonzero training coefficients by absolute standardized magnitude, retain up to k, and refit on those features at the candidate alpha/lambda fraction; rerun this entire operation within each training fold. No k is forced if fewer features are supported. Include intercept-only baseline. Among candidates within one standard error of the minimum inner mean loss, select smallest median fitted panel size; tie-break by strongest regularization, then larger alpha, then lexical parameter order. Within tied protein magnitudes prefer a documented assay-feasibility tier if frozen and available, otherwise lexical ID. No manual post-CV substitutions.

The preferred 3–10 size is achieved only if supported by this rule; >10 or no supported panel is reported honestly. Keep current evidence on targeted-assay availability, peptide specificity, abundance/detectability and external biological interpretability as feasibility annotations, without inventing kit readiness. Additional wet-lab and external-cohort verification remains necessary. Selection frequency, sign consistency conditional on selection, coefficient distribution and panel-size distribution across 15 outer fits are descriptive stability measures, not independent replicate estimates or formal stability-selection error control.

**Threshold and uncertainty.** Primary model evaluation emphasizes AUROC, AUPRC, calibration and Brier score rather than a mandatory classification cutoff. If an operational binary threshold is required, its selection rule must be prespecified and executed entirely within Discovery/model-development data, including the necessary nesting when performance is estimated; the resulting threshold is locked before the reused 129-person hold-out is evaluated. The hold-out must never be used to select, revise or optimize the threshold. A probability threshold of 0.5 may be reported only as a supplementary/reference operating point. Future targeted-assay studies may define application-specific thresholds according to their intended use. Use native probabilities without post-hoc hold-out recalibration; evaluate calibration but do not update it. For each repeat calculate metrics from one outer-held-out prediction per participant, then average repeat-level metrics. For internal bootstrap resample participant IDs within original Group, carrying all that person's repeat predictions together and recomputing mean repeat metrics. This describes conditional out-of-fold sampling variability and omits full algorithm-training uncertainty; overlapping fits/repeats are not independent. Do not use fold SD/sqrt(15) as CI or call averaged probabilities an evaluated deployed ensemble.

**Final fit and lock.** Use all 386 (or relevant secondary-task subset), run the same five-fold inner selection with seed 20260929, fit the selected full pipeline, and lock exact protein IDs/order, imputer/scaler, coefficients/intercept, software versions, assay expectations, any prespecified operational threshold rule and resulting locked threshold if applicable, panel size and failure policy. No post-lock feature substitution. No arbitrary panel-level missingness abstention threshold is frozen in this discovery-stage protocol. Fold-specific missing-data preprocessing remains part of the locked ML pipeline. Assay failure, LLOQ, panel completeness, invalid-result, repeat-testing and abstention rules belong to future targeted-assay analytical validation and must not be inferred from the current DIA discovery dataset. Missing required assay columns signal an incompatible export and stop evaluation, rather than being silently filled. Only this final locked pipeline proceeds to the primary hold-out evaluation.

### Module 16 — Once-only reused 129 hold-out evaluation

| Field | Specification |
|---|---|
| Scientific question | How does the locked model perform in the reused within-cohort hold-out? |
| Population | Fixed 129; primary C/E=38/91, secondary C/L=38/47, C/H=38/44, L/H=47/44 |
| Input dataset | Original hold-out quantities mapped to locked features; final Discovery pipeline; no refitting |
| Protein universe | Exact locked model list per task, not new hold-out eligibility |
| Outcome | Frozen class predictions/probabilities and failure/abstention status |
| Predictor/design | Apply locked Discovery transforms and coefficients unchanged; if an operational threshold was prespecified and selected entirely within Discovery, apply that locked threshold unchanged. A 0.5 threshold may be shown only as a supplementary/reference operating point |
| Model/test | One evaluation event for all prespecified tasks; no ranking models to select a winner |
| Contrast | Observed versus predicted labels; all tasks retain frozen priorities |
| Effect size | Binary AUROC, AUPRC, sensitivity, specificity, balanced accuracy, PPV, NPV, F1, confusion counts, calibration intercept/slope and Brier score |
| Confidence interval | 2,000 participant bootstrap replicates stratified by original Group, seed 20260930; Wilson threshold-proportion intervals; label fixed-composition conditioning and failed calibration replicates |
| Multiplicity family | No superiority hypothesis tests; prespecified descriptive performance endpoints, pointwise intervals |
| Missingness policy | Locked imputation/abstention; no evaluation-derived medians, scaling or filtering |
| Sensitivity analysis | Environment/Site metrics descriptive; no adjustment of threshold/model after seeing them |
| Environment/Site handling | Report cells and uncertainty; single-class Site AUROC unavailable, not zero; context transportability unresolved |
| Output tables | Every metric/CI, prevalence baseline, confusion matrix, prediction coverage and subgroup counts; no hidden poor outcomes |
| Output figures | ROC, precision–recall, calibration, confusion matrix; clear reused-hold-out caption |
| Interpretation boundary | Not untouched, independent external or clinical validation; prior use and upstream processing uncertainty disclosed |
| Dependency/freeze prerequisite | Freeze 9 after complete model lock; execution explicitly authorized; any revision requires new evaluation data |

AUROC/AUPRC are threshold-free; sensitivity, specificity, balanced accuracy, PPV, NPV and F1 depend on the locked threshold. Brier/calibration assess probabilities. AUPRC prevalence baseline is 91/129 for the primary task; PPV/NPV/calibration apply to this sampling mix. Three-class reporting includes macro and per-class one-vs-rest AUROC, macro-F1, balanced accuracy, class sensitivity, confusion matrix, multiclass Brier/log loss and classwise calibration where estimable. Estimate binary calibration intercept with logit prediction offset and slope with a free intercept, solely for evaluation; infinite/separated estimates are reported unavailable, not repaired by recalibrating the model. Show a calibration curve using five bins whose cutpoints were fixed from Discovery cross-fitted probabilities before lock; report sparse bins. Bootstrap undefined metrics remain NA with valid replicate count; never silently discard failed evaluation cases.

### Module 17 — Manuscript tables, figures and claims

| Field | Specification |
|---|---|
| Scientific question | Does the manuscript faithfully present all prespecified evidence layers and limitations? |
| Population | Full cohort, frozen prospective branch and new prediction populations explicitly separated |
| Input dataset | Completed versioned module outputs plus untouched historical source tables |
| Protein universe | Every panel/table declares its own source universe and denominator |
| Outcome | Coherent evidence presentation, not new hypothesis testing |
| Predictor/design | Overall exposure → ordered/omnibus → pairwise → context → historical replication → prediction |
| Model/test | No extra inferential model for presentation |
| Contrast | Exact source-module contrasts and signs |
| Effect size | Carry source effects unchanged; no rescaling selected to exaggerate biology |
| Confidence interval | Source method labeled, including historical approximate versus v2 moderated intervals |
| Multiplicity family | Carry exact family IDs/q labels; no figure-specific BH |
| Missingness policy | Include missing metadata, non-estimable proteins, skipped modules and failed predictions |
| Sensitivity analysis | Present planned robustness with primary findings, including disagreement |
| Environment/Site handling | Explicit nesting, sparse cells, preanalytics and acquisition confounding |
| Output tables | Table 1 participant characteristics; Table 2 split balance; complete abundance/detection, interaction/Site, pathways, all-85 and ML supplements |
| Output figures | Six-figure system below with complementary supplementary QC and sensitivity displays |
| Interpretation boundary | No success claim before execution; no causal exposure/site biology or external-validation overclaim |
| Dependency/freeze prerequisite | All used modules completed under their own freezes; terminology/count/CI/family consistency review |

Figure 1: cohort/protein filtering, depth/missingness/detection gradients, abundance distributions and annotated PCA. Figure 2: overall E effects with forests/MA, limited volcano, detection and ranked pathways. Figure 3: all-universe ordered architecture and omnibus, adjusted profiles, annotated heatmap and pairwise UpSet. Figure 4: stratum and direct interaction forests, Site composition/preanalytical context and LOO. Figure 5: complete frozen 85-family replication with 83/29/1 support and prior-use chronology. Figure 6: locked biomarker development, feature/coefficient stability, ROC/PR/calibration/confusion, only if executed. UMAP is supplementary exploratory. No biological figures are created in this documentation task.

Choose displayed protein examples deterministically from the relevant v2 table: top 10 by q, then absolute effect, then protein ID, showing all if fewer; display selection is not a new inferential universe. Figure source tables include every eligible protein, not only highlighted examples. No figures should imply a temporal progression. Table 1 reserves age/sex/BMI/duration/smoking/alcohol/disease fields with available N; Table 2 uses SMD and missingness, not baseline P-value screening.

## 4. Existing-code reuse map — no changes authorized here

All modifications below mean a future versioned derivative, not editing frozen code in this task. Paths are relative to the repository root.

| Existing component | Classification | Exact v2 role / required change |
|---|---|---|
| `code/P1.py`, `P2.py`, `P3.py`, final sample mapping | REUSE AS-IS | Identity/positional mapping; their string normalization is not quantitative normalization |
| Split script, protocol/specification and assignment | KEEP AS HISTORICAL/FROZEN | Never rerun/rebalance the 386/129 assignment |
| `descriptive/01_describe_proteomics.py`–`04_complete_four_layers.py` | REUSE WITH MODIFICATION | Keep denominators/landscape logic; new labels, technical-filter flow and v2 output paths |
| `05_dose_quantitative_filtering.py` | REUSE WITH MODIFICATION | Technical registry before new universes; preserve old 1,434 outputs; distinct detection and fold rules |
| `stage05_normalization_helper.py` | REUSE WITH MODIFICATION | Same log2/median formulas, but v2 universe/paths/settings disclosure; ML reference fitting must be fold-local |
| `06_covariate_QC.R`, `covariate_QC/` | REUSE WITH MODIFICATION | Reuse metadata availability and QC logic; source-specific semantics; optional clinical metadata not an exclusion |
| `07_limma_dose_analysis.R`, canonical historical results | KEEP AS HISTORICAL/FROZEN | Preserve 256 branch; reuse model concepts in a v2 derivative, add E/omnibus/order/exact contrasts/CIs/families |
| `08a_limma_core_figures.R`, `10a_DEP_characterization.R`, `10b_DEP_effect_size_summary.R` | REUSE WITH MODIFICATION | New v2 sources, corrected labels and explicit CI/family; no old selected universe as whole-proteome evidence |
| `08b_limma_robustness.R`, `08c_run_replication.R`, `08d_integrated_results.R` | REUSE WITH MODIFICATION | Keep valid robustness logic; label acquisition-stratified work as internal context, not independent replication |
| `stage05_detection_helper.py`, `09_detection_pattern_analysis.R` | REUSE WITH MODIFICATION | Reuse binary matrix construction; replace group-max ≥60% universe and <20% comparator in v2; new formal model and hierarchy |
| `11a_dose_pattern_classification.R`, `11b_protein_clustering.R`, `12_pattern_protein_annotation.R` | SUPERSEDED FOR v2 | Historical selected-256 descriptions remain; all-Q515 profiles and adjusted means require new logic, no required new clustering |
| `13a_canonical_256_DEP_master.R` / canonical master | KEEP AS HISTORICAL/FROZEN | Evidence history only; prohibited as new ML screening source |
| `missingness_robustness/code/missingness_robustness.R` and outputs | REUSE WITH MODIFICATION | Keep D0–D3 originals; reuse D2/D3 formulas in v2, new universe/assertions/contrasts/CIs; D1 not v2 imputation |
| `discovery_validation/D01_discovery_eligibility.py`, D02/D03 | KEEP AS HISTORICAL/FROZEN | Preserve 1,445→85 eligibility/selection/lock; not a rerun for v2 |
| `discovery_validation/code/dv_shared.R` | KEEP AS HISTORICAL/FROZEN | Do not patch existing CIs here; v2 shared implementation needs posterior-variance t intervals and exact contrast SE |
| D04 | KEEP AS HISTORICAL/FROZEN | Selected-85 patterns; legacy `Modeled_mean` is raw observed group mean, not adjusted prediction |
| D05/D06 | KEEP AS HISTORICAL/FROZEN | Selected-family Environment evidence remains exploratory; new whole-universe interaction requires new module |
| D07 | KEEP AS HISTORICAL/FROZEN | Original Discovery selected-85/five-Site influence remains; new all-nine-Site LOO and formal heterogeneity separate |
| D08 | KEEP AS HISTORICAL/FROZEN | Original 85/83/29/1 evidence unchanged |
| D09/D10 | KEEP AS HISTORICAL/FROZEN | Peptide-QC unavailable; pathways `NOT_RUN_NO_APPROVED_MAPPING`; do not imply completed enrichment |
| `discovery_validation/code/figures_prospective.R`, figure plan | REUSE WITH MODIFICATION | Preserve scientific evidence, improve labels/CI captions/layout; smoke outputs not publication-final |
| `nature_plotting.py`, `v21_common.R` | REUSE WITH MODIFICATION | Reuse style/identity helpers only where compatible; legacy label constants need v2 override without modifying frozen sources |
| `descriptive/archive/` | SUPERSEDED FOR v2 | Historical reference only; not an execution route |
| Registry, ordered inference, whole-universe context/detection, pathway mapping and ML | NEW CODE REQUIRED | Implement only in separately authorized v2 modules using above contracts |

## 5. Freeze ledger and execution dependencies

Freezing a rule here does not assert that its input artifacts already exist or that execution is authorized. A remaining source/configuration gap blocks only its dependent module. Optional clinical metadata, exact preanalytical records and future external validation do not block delivery of this protocol or automatically halt core descriptive work.

| Freeze | Decision fixed in this document | Current status / release requirement |
|---|---|---|
| 1 Scientific definitions | Plasma, independent participants, Control/Low/High, Environment, Site, biological hierarchy | **COMPLETE by author confirmation**; exact legacy mapping fixed |
| 2 Normalization | Log2-only primary; median-normalized sensitivity; never infer upstream state from field name | **OPEN technical fact**: actual Spectronaut configuration or explicit documented acceptance of unrecoverable settings; ML deployment limitation retained |
| 3 Contaminants | Categories A/B/C, supported keratin rule, mixed-group policy, source-independent exclusions | **OPEN input**: source flags/FASTA or curated fixed contaminant-reference mapping; do not generate final v2 universe first |
| 4 Canonical registry/universes | Identity and Utech/Q515/D515/Qenv/Denv/Mfold algorithms specified | **RULES FIXED, lists not generated**; depends on 2–3 and later authorized execution; fold lists materialize only inside permitted training folds |
| 5 Missingness | Non-imputed primary; fixed Gaussian/KNN sensitivities; no zero abundance filling | **RULES FIXED**; future checks of branch preconditions, no result-based choice |
| 6 Detection | Formal Firth framework; target ≥80%, comparator zero strict descriptive label and fixed grid | **RULES FIXED**; source detection semantics and contrast implementation to verify before execution |
| 7 Contrasts/FDR/CI | Weights, hierarchy, order construction, families, estimability and moderated CIs fixed | **RULES FIXED**; implementation verification required, no outcome-based amendments |
| 8 ML | Task order, primary B Elastic Net, A secondary, folds/seeds/grid/panel rule/threshold/metrics fixed | **PROTOCOL FIXED**; upstream measurement review and actual input/assay mapping remain; no full-cohort feature screen |
| 9 Reused 129 evaluation | Once after exact final model/pipeline lock; no tuning or revision | **NOT YET RELEASABLE**: Discovery development and model lock have not occurred; evaluation not authorized |

Recommended later order: resolve technical provenance/registry and implement identity-only QC; freeze/implement ML workflow before additional full-cohort protein interpretation can influence choices; develop/lock Discovery models, then evaluate the reused hold-out once if authorized; execute the versioned full-cohort hierarchy and focused sensitivities/pathways; integrate untouched historical evidence. Manuscript order remains biology first. This chronology prevents additional information leakage but cannot undo prior use. No need to wait for optional demographics to execute authorized core proteomics once its actual technical prerequisites are met.

Future output naming: `descriptive/analysis_v2.0/{metadata,qc,abundance,detection,environment,site,pathway,ml,tables,figures}/`; use module/contrast/family identifiers in filenames. This is a recommendation only; no directories or biological outputs are created now. Do not overwrite `limma_dose_analysis/`, `missingness_robustness/`, `discovery_validation/` or assignment files. Later substantive changes require a dated amendment documenting reason and prior data access, not silent movement of cutoffs or endpoints.

## 6. Documentation consistency and remaining facts

Correct scientific terms: plasma; Control, Low exposure, High exposure; Humid-hot, High-altitude; Site as recruitment location; ordered exposure-level relationship; Unique protein. Short/Long/dose/trajectory strings are retained only as explicitly legacy code/output identifiers or to reject unsupported temporal interpretation. Duration and processing time are separate variables. Training refers to Discovery or its folds; the new hold-out is reused, and no external validation exists. Independence refers to the author-confirmed participant unit, not to historical versus v2 analyses of overlapping participants.

Unresolved facts: actual Spectronaut processing version/settings/normalization/reference scope; database and contaminant/decoy metadata; upstream identification/export filtering or imputation; detailed preparation and run-level QC availability; actual contaminant-reference accession mapping; assay availability for eventual selected proteins. Optional clinical and preanalytical information is incomplete by author confirmation and must be transparently reported. None may be guessed from protein patterns or Validation performance. No new rule in this plan is optimized on Validation outcomes.

Documentation QA must inspect all occurrences of Short, Long, Low, High, dose, duration, trajectory, time, high-pressure, high-altitude, EV, plasma, training, test, Validation, independent, external validation, unique peptide and unique protein in both deliverables. Confirm module fields, fixed counts/signs, historical/v2 distinction and explicit technical blockers. Only `STUDY_DESIGN_AUDIT.md` and this file are authorized changes; no analysis code, raw data, assignment or biological result changes are permitted.
