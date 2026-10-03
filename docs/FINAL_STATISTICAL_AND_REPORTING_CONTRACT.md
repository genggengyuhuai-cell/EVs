# FINAL STATISTICAL AND REPORTING CONTRACT

**Project**: EV-enriched plasma proteomics — Exposure-associated protein and pathway analysis
**Status**: AUTHORITATIVE · Consolidated from already-approved frozen sources (Phase 2, 2026-10-03)
**Current scientific HEAD**: `8695ae640a324a3bd0541aa96792d5ec2c2d244b`
**Scope**: This is the SINGLE authoritative statistical/reporting contract. All manuscript Methods,
Results, final figures, source data, supplementary materials, and final statistical claims must
conform to this file. It supersedes (for authority) all prior separate contract/freeze documents,
which remain recoverable under `archive/audits/`.

> **Do NOT invent new statistical decisions.** This is documentation consolidation of already
> frozen, author-accepted decisions. Any genuine unresolved conflict between this file and a
> current executable output must be recorded in
> `archive/audits/repository_consolidation_2026-10-02/PHASE2_EXCEPTION_REPORT.md` as
> `SCIENTIFIC_CONFLICT_FOUND` and not silently resolved.

---

## 1. Cohort and Analysis Units

| Term | Value |
|---|---|
| Initial cohort | 519 |
| Analytical cohort | 515 independent participants |
| Control / Low / High | 153 / 186 / 176 |
| Statistical unit | participant / plasma sample |
| Study material | EV-enriched plasma proteomics (NOT a pure EV proteome; never "EV-specific proteins") |

Discovery / reused within-cohort hold-out split (frozen, seed-locked):

| Subset | n |
|---|---|
| Discovery | 386 |
| Reused within-cohort hold-out | 129 |
| Discovery High+Low (ML/ROC) | 271 = 132 High + 139 Low |
| Hold-out High+Low (ML/ROC) | 91 = 44 High + 47 Low |

## 2. Discovery / Validation Boundary

- A prespecified Discovery subset and a **reused within-cohort hold-out** subset.
- The hold-out is **NOT external validation** and must never be called "independent / external /
  prospective validation cohort".
- Standard term: **reused within-cohort hold-out**.

## 3. Candidate Lock

- **85** locked discovery candidates (High vs Low, Discovery n=386).
- Never relock, expand, or alter the candidate set.

## 4. Primary Contrasts

- Primary contrast: **High − Low** (two exposure groups), NOT exposed vs control.
- Secondary/supplementary (post-v2.1): Low vs Control, High vs Control, Exposure (Low+High) vs Control.
- Overall Discovery (n=386 / 1,445 estimable): LVC 0 BH-FDR (114 raw P<0.05); HVC 0 (145 raw);
  EC 0 (65 raw); HvL frozen 85 (365 raw).
- Frozen-85 trajectory (descriptive): 66/85 bidirectional, 18/85 High-only, 1/85 unclear.
- Environment-stratified (supplementary): HH (n=209, Q_HH=1,373) LVC=0/HVC=1/HvL=0/EC=0;
  HA (n=177, Q_HA=1,394) LVC=0/**HVC=75**/HvL=0/**EC=7**. HA EC 7: TPST2, C1R, SPARC, FSTL1,
  MENT, XYLT2, ST3GAL6 (all negative; all within HA HvC 75; 1/7 in frozen 85). NOT environment-specific.

## 5. M08 Detection Model Contract

- Firth penalized logistic regression is primary where applicable (group-LR on 3,054 proteins).
- Result: 2/3,054 at FDR<0.05; robustness, not headline. Non-Firth detection is superseded.

## 6. M09 Missingness / Imputation Contract

- Primary discovery: **no expression-matrix imputation** in the differential analysis.
- M09 KNN imputation (`impute::impute.knn`, k=10, rowmax=0.5, colmax=0.8, maxp=1500) is a
  **sensitivity** analysis only (n=515, 1,430 Q515 universe), M05 estimator retained.
- Result: Pearson r=0.9740605, Spearman rho=0.9644384, direction concordance 1,343/1,430
  (93.9161%), primary FDR<0.05 = 0/1,430, KNN FDR<0.05 = 0/1,430. Do NOT use r=0.974 as evidence
  of a significant overall-exposure signal.

## 7. M10 Interaction Contract

- Corrected **pure 2-df** Group × Environment interaction on 1,430 mapped proteins.
- Result: **0/1,430** BH-FDR significant; 0/85 frozen-85.
- Cross-environment significance differences are power/precision, not interaction.

## 8. M11 Contract

- Leave-one-site-out sensitivity: 9 site exclusions, 9/9 estimable, fixed primary M05 estimator,
  environment adjustment retained in all fits.
- Ranges (frozen): Pearson 0.790055–0.982702; Spearman 0.756893–0.979087; direction concordance
  70.77–93.50%. Influence diagnostic, NOT validation; do not conclude "site robust".

## 9. ML Contract

- **Fixed-85 ML**: models condition on the already locked 85 candidates (conditional
  discrimination, NOT unbiased pipeline / clinical prediction / diagnostic validation). n=271.
  Repaired procedure: repeated outer CV (5-fold × 3 repeats = 15 folds), nested tuning, no
  outer-test early-stopping leakage. Elastic Net mean AUROC 0.668688 / median 0.662088; XGBoost
  mean 0.648769 / median 0.657967 / range 0.508598–0.786325. Tier1 (selection stability, not
  "validated panel"): GAL, TSPAN14, DMP1, IGF1, GOLGA3. Framing: **modest**.
- **Strict nested (diagnostic)**: raw 3,817 → fold-local eligibility → D02-compatible limma →
  environment-adjusted HvL → BH FDR<0.05 → model → untouched outer test. No top-N fallback / no
  threshold relaxation. Outer folds=15; zero-feature folds 7/15; evaluable 8/15; feature count
  0/0/3/59/536. Never report "nested AUROC across 15 folds"; report conditioning on 8 evaluable
  folds and the 7/15 zero-feature fact. Stable feature appearance ≥0.70: NONE.
- **Reused hold-out**: 85 → 83 direction / 29 nominal / 1 candidate-family BH-FDR. No external
  validation claim, ever.

## 10. Pathway Contract

Fixed hierarchy (never reorder, never overclaim):

| Method | Role |
|---|---|
| **cameraPR** | **PRIMARY PATHWAY INFERENCE** |
| **ORA** | **COMPLEMENTARY** |
| **fgsea** | **SENSITIVITY / SUPPORTING** |
| **KEGG** | **NOT_RUN** |

- cameraPR: ranking = D02 environment-adjusted moderated t (no imputation), inter.gene.cor=0.01,
  set size 10–500, FDR family = pooled GO-BP + Reactome.
  - Frozen HvL: GO-BP 29 + Reactome 176 = **205** (Reactome ≈86% → justifies Reactome in main figure).
  - Exploratory control-referenced: LVC 258 (21 GO-BP + 237 Reactome); HVC 38 (10 + 28).
- ORA (complementary): foreground = 85 locked candidates; background = 1,414 mapped proteins.
  GO-BP 3 + Reactome 20 = **23**. Never write 85/1,414 as a discovery statistical denominator.
- fgsea (sensitivity only, dual-reported): family-wise **44** (GO-BP 3, GO-MF 8, GO-CC 11,
  Reactome 22); pooled **41** (GO-BP 6, GO-MF 7, GO-CC 10, Reactome 18). Report both
  `padj_family` and `padj_pooled`; never "44 significant" without multiplicity definition.
- KEGG: **NOT_RUN**. Do not write KEGG in Methods; do not place an empty KEGG table implying it
  was run; do not write "KEGG pathway analysis showed…".
- M12B network-like figures = "contextual association structure", never "regulatory network".
- **Do NOT sum pathway counts across methods.**

## 11. Pathway Universes (R03 closed — author decision, do not reopen)

Three distinct layers (never conflate; do not manufacture a 1,445-row pathway result):

| Universe | Value | Use |
|---|---|---|
| Discovery inferential universe | **1445** | D01 discovery-eligible; statistical family for 85 candidates |
| Mapping registry | **1434** | Pathway mapping input (full-cohort quantitative mapping registry) |
| Rankable tested | **1406** | Ranked pathway testing (cameraPR/fgsea) among mapped+estimable |
| Unambiguously mapped (ORA background) | **1414** | ORA background |

Related: full-cohort Q515 abundance-model universe = **1,430** (M05/M09/M11/interaction).

## 12. FDR Families

| Analysis | Multiplicity family |
|---|---|
| D02 primary discovery | 1,445 Discovery-eligible proteins |
| D08 replication | 85 locked candidates |
| M05/M09 overall-exposure | 1,430 Q515 proteins |
| cameraPR | Prespecified GO-BP + Reactome primary family (pooled) |
| ORA | Prespecified enrichment family (per canonical output) |
| fgsea | Both family-wise and pooled BH shown; sensitivity only |
| ML | No feature-wise FDR used to define predictive performance |

## 13. Accepted Reporting Counts (only these)

- 85 / 1,445 discovery candidates (HvL).
- Hold-out 85 / 83 / 29 / 1 (reused within-cohort).
- M10 interaction 0 / 1,430.
- cameraPR 205 (29 GO-BP + 176 Reactome) PRIMARY; ORA 23 (3 + 20) COMPLEMENTARY;
  fgsea 44 family / 41 pooled SENSITIVITY ONLY; KEGG NOT_RUN.
- Universes 1445 / 1434 / 1406 (plus 1414 ORA background; 1430 Q515).
- Overall pairwise: LVC 0, HVC 0, EC 0 BH-FDR.
- Environment-stratified: HH LVC/HVC/HvL/EC = 0/1/0/0; HA = 0/75/0/7 (supplementary, not specific).

## 14. Prohibited Claims

- Call reused within-cohort hold-out "external validation".
- Treat fgsea as primary pathway discovery.
- Report KEGG analysis (NOT_RUN).
- Sum pathway counts across methods.
- Reactivate deprecated peptide-derived evidence (D10 deprecated columns: D09_Unique_peptide_count,
  D09_Single_unique_peptide, D09_Peptide_support_status).
- Use historical Phase results / archived audits as current manuscript evidence.
- "85 DEPs are exposed-vs-control"; "85 show monotonic dose response"; "258 independent pathways";
  "HA 7 are high-altitude-specific biomarkers"; "HA significant + HH non-significant proves
  interaction"; "High activates proteasome/cytoskeleton/redox" (HVC non-significant);
  "pathway enrichment proves mechanism"; "two-phase dose-response is proven";
  "there was no effect" for a "0 significant" result (not reaching threshold ≠ proving absence).

## 15. Source-of-Truth Outputs

Authoritative current result files (active directories, current HEAD):
- `docs/CURRENT_AUTHORITATIVE_RESULTS.md`
- `docs/post_v2_1_extended_analysis/POST_V2_1_CLAIM_MAP.csv` (sole claim map)
- `docs/post_v2_1_extended_analysis/POST_V2_1_EXTENDED_ANALYSIS_FREEZE.md`
- `descriptive/discovery_validation/D02_discovery_primary/`
- `descriptive/discovery_validation/D02_pairwise_completion/`
- `descriptive/discovery_validation/D08_validation/`
- `descriptive/analysis_v2.0/M12_pathway_v2.1/` (canonical pathway)
- `descriptive/analysis_v2.0/M10_environment_interaction/corrected_pure_interaction/`
- `descriptive/analysis_v2.0/ml_v2.1/`
- `audit_output/FINAL_ANALYSIS_FREEZE_HANDOFF.md`

Full file-level registry: `docs/FINAL_MAINLINE_MANIFEST.csv` (Status `ACTIVE_PRIMARY`/`ACTIVE_SUPPORTING`).
