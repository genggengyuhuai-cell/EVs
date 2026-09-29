# Project Reconstruction Plan — v2.1

This plan reorganizes the existing frozen modules into the evidence chain that best answers the primary question. It does not move files now; it is a repository plan for after submission preparation.

## Part 8 — Possible framings

### Framing A: "Exposure-associated EV-enriched plasma proteomic architecture"
- **Emphasizes**: descriptive landscape — overall-exposure null, pairwise contrasts, architecture class, pathway themes.
- **Evidence supports**: Fig2, Fig6.
- **Main weakness**: the central 85 DEP result and its weak replication get diluted; reads as exploratory atlas.
- **Reviewer risk**: "what is the point?"; "EV-enriched" under-validated.
- **De-emphasize**: biomarker / prediction / mechanism.

### Framing B: "Discovery and internal (reused hold-out) replication of exposure-associated proteins"
- **Emphasizes**: 85 DEPs, 83 direction-concordant, 29 nominal, 1 FDR-supported; fixed-85 vs strict-nested as sensitivity.
- **Evidence supports**: Fig1, Fig3, Fig5; M14 hierarchy.
- **Main weakness**: 1/85 FDR-supported is modest; reviewers will ask for external validation.
- **Reviewer risk**: reused hold-out = weak replication; ML conditional on same-cohort lock.
- **De-emphasize**: prediction performance; mechanism; EV-purity claims.

### Framing C: "Multi-layer robustness and biological-context characterization"
- **Emphasizes**: detection, missingness, site LOO, environment-stratified, interaction null, pathway concordance, M12B context.
- **Evidence supports**: Fig4, Fig6; M08/M09/M10/M11; M12/M12B.
- **Main weakness**: reads as methods-heavy; weakens the discovery story; many nulls.
- **Reviewer risk**: "so what did you actually find?"

### RECOMMENDED SCIENTIFIC STRUCTURE (a blend of B as spine, A as context, C as robustness)

The spine is B (discovery + honest internal replication), with A as the opening landscape and C as the robustness/limitation layer. Do not lead with ML or pathway; they are supporting.

## Part 12 — Module allocation

### PRIMARY (main text)
- Cohort / QC / universe (M01–M04; Fig1).
- Overall-exposure + pairwise abundance landscape (M05, M06, M07; Fig2).
- Discovery High-vs-Low lock of 85 DEPs (D03; Fig3a–b).
- Reused hold-out hierarchy 85/83/29/1 (M14; Fig5a).
- Formal interaction null (M10; Fig4b).

### SECONDARY (main text, one panel each)
- Missingness / KNN sensitivity on the 85 (M09; Fig3c).
- Candidate architecture class (M06_arch; Fig2d, Fig3d).
- Pathway primary themes — top GO-BP cameraPR + representative Reactome clusters (Fig6a,c,d).

### SENSITIVITY / ROBUSTNESS (main text as a short section, or Supplement)
- Firth detection (M08).
- Site composition and LOO (M11; Fig4c,d).
- Environment-stratified estimates (M10 stratified; Fig4a).

### SUPPLEMENTARY
- Fixed-85 conditional ML (Fig5b–d; outer_cv_metrics).
- Strict nested sensitivity (strict_nested outputs; fold-local DEP range 8–618).
- Boruta-style / XGBoost importance.
- ORA (23) and fgsea (39) full tables + concordance.
- M12B annotation / network / pairwise Spearman / integrated context.
- All pairwise / environment / site supplementary tables.

### ARCHIVE / HISTORICAL ONLY
- debug / probe / install / log files across ml_v2.1, M12, M12B, M17 (already identified in prior audits).
- Invalidated historical ML runners (already under `ml/code/archive_invalidated/`).
- KEGG placeholder files (KEGG = NOT_RUN; keep only as a one-line provenance record).

## Part 13 — Manuscript scope reconstruction (no prose)

**Result 1 — Cohort, QC, and proteome universe.**
Question: who was measured and what was tested?
Figures: Fig1.
Claims: 519→515; 386 Discovery / 129 reused hold-out; 1,430 quantitative universe; 85 locked.

**Result 2 — Proteome-wide exposure landscape.**
Question: what does the overall and pairwise exposure signal look like?
Figures: Fig2.
Claims: 0/1,430 overall at BH-FDR<0.05; pairwise FDR counts per contrast; architecture is descriptive.

**Result 3 — The 85 locked discovery candidates.**
Question: what is the High-vs-Low discovery set?
Figures: Fig3.
Claims: 85 DEPs; effect landscape; adjusted profiles; missingness sensitivity.

**Result 4 — Reused hold-out hierarchy.**
Question: how stable is the 85 in the reused hold-out?
Figures: Fig5a.
Claims: 83 direction-concordant; 29 nominal; 1 candidate-family FDR-supported.

**Result 5 — Robustness to detection, site, environment, interaction.**
Question: do the signals survive sensitivity checks?
Figures: Fig4.
Claims: 2/3054 detection FDR; LOO direction stability; environment-stratified descriptive; interaction 0/1,430.

**Result 6 — Pathway and biological context.**
Question: what themes are enriched?
Figures: Fig6.
Claims: cameraPR primary 195 (representative themes shown); ORA complementary; fgsea sensitivity; KEGG not run.

**Result 7 (Supplement, not main) — ML prioritization.**
Question: do methods agree on the 85?
Figures: Fig5b–d (move to Supplement).
Claims: fixed-85 conditional ML; strict nested sensitivity 8–618 fold-local DEP; no winner chosen.

**Main tables:**
- Table 1: cohort / QC / universe.
- Table 2: pairwise abundance summary.
- Table 3: 85 locked candidates with Discovery effect + hold-out concordance.
- Table 4: pathway representative themes (top cameraPR GO-BP + core Reactome clusters).

**Supplementary:**
- detection, missingness, LOO, environment-stratified tables;
- fixed-85 and strict-nested CV metrics;
- ORA / fgsea full tables;
- M12B annotation and network;
- mapping contract (1,434 / 1,414 / 15 / 5).

**Claims allowed:**
- discovery set of 85 High-vs-Low exposure-associated proteins;
- direction concordance in reused hold-out;
- 1 candidate-family FDR-supported protein;
- descriptive pathway themes;
- robustness / sensitivity statements.

**Claims to avoid:**
- "validated", "external validation", "independent cohort", "prospective";
- "EV proteins", "EV biology", "EV-specific";
- "biomarker panel", "signature", "predictive model";
- "no interaction", "no effect";
- "causal", "mechanistic", "pathway activation";
- summing pathway counts across methods.

## Part 14 — Repository implications (plan only; no moves this round)

- KEEP ACTIVE: M01–M11 main results, D03 lock, M14 hierarchy, M12 ranked + ORA + fgsea combined, M12B integrated context, ml_v2.1 integrated_table_85 + outer_cv_metrics + strict_nested_outer_metrics, M17 Fig1–6 + source data.
- MOVE TO SUPPLEMENTARY: detection Firth full table, KNN sensitivity, LOO per-protein, environment-stratified per-protein, Boruta full-data, XGBoost importance, ORA/fgsea full per-database tables, M12B pairwise Spearman and network edges/nodes.
- SUPPORT: manifests, README_METHODS, audit CSVs, FIGURE_MANIFEST, VISUAL_QC, mapping contract.
- ARCHIVE / HISTORICAL ONLY: already-identified debug / probe / install / log files; invalidated historical ML runners; KEGG placeholder.
- DO NOT delete, move, or rewrite frozen result tables in this round.
