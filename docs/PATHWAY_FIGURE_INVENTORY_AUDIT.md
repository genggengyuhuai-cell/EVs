# Pathway / Biological Figure Inventory Audit — 2026-09-29

Scope: M12_pathway_v2.1, M12B_biological_context_v2.1, figures_final_v2,
figures_nature_v2.2, manuscript_v2_1/. No analysis rerun; no figure regeneration.

## 1. What actually exists

### 1.1 Figure files

Across the whole active repository, the only pathway / biology figure files are:

| Path | Producer | What it is |
|---|---|---|
| `descriptive/analysis_v2.0/figures_final_v2/Fig3_candidate_biology.pdf/.svg/.png` | V2_M17_figures_v2.R | Candidate-level biology (85 DEPs, ML branch, D08 replication) — not a pathway figure |
| `descriptive/analysis_v2.0/figures_final_v2/Fig6_pathway_integration.pdf/.svg/.png` | V2_M17_figures_v2.R | The only pathway figure in the manuscript bundle |

**Zero** standalone GO / Reactome / fgsea / ORA / M12B-network / M12B-correlation
figure files exist anywhere in `descriptive/`, `manuscript_v2_1/`, or `archive/`.

### 1.2 M12/M12B directory content

`M12_pathway_v2.1/` (40 files) and `M12B_biological_context_v2.1/` (15 files)
contain **only result tables (`.csv`) and scripts / reports / README**. There are
no `.pdf` / `.png` / `.svg` / `.tiff` outputs in either directory.

Subdirectories are all table-only:
- M12: `mapping/`, `ora/` (7 CSVs), `ranked/` (9 CSVs), `ranked_gsea/` (7 CSVs),
  `integration/`, `environment/`, `diagnostics/`.
- M12B: `annotation/` (1 CSV), `correlation/` (3 CSVs), `network/` (2 CSVs),
  `environment/` (2 CSVs), `integration/` (1 CSV), `diagnostics/` (2 CSVs),
  `ranked_gsea/` (0).

## 2. Fig6 panel breakdown (from source_data CSV, 909 rows)

| Panel | Rows | Database(s) | What it shows |
|---|---|---|---|
| `a_ranked` | 8 | GO_BP only | Representative cameraPR GO BP themes (the primary competitive analysis, but only 8 of 25 shown) |
| `b_sensitivity` | 887 | GO_BP 271 / GO_CC 147 / GO_MF 105 / Reactome 364 | fgsea sensitivity sweep across all four databases (ranked enrichment) |
| `c_ora` | 3 | GO_BP only | ORA GO BP top hits (3 of 23 total; Reactome ORA absent) |
| `d_network` | 11 | (multi) | Small 85-DEP ↔ pathway network edges (M12B network) |

## 3. Frozen numbers vs current figure coverage

| Method | Frozen count | GO BP | GO MF | GO CC | Reactome | KEGG |
|---|---|---|---|---|---|---|
| cameraPR (primary) | 195 | 25 | 0 | 0 | 170 | NOT_RUN |
| ORA (complementary) | 23 | 3 | 0 | 0 | 20 | NOT_RUN |
| fgsea (sensitivity) | 39 | 3 | 8 | 11 | 17 | NOT_RUN |

**Coverage in Fig6**:
- cameraPR: 8 GO_BP shown (out of 25) — Reactome 170 **not represented as a panel**.
- ORA: 3 GO_BP shown (out of 3) — Reactome 20 **not represented**.
- fgsea: 887-row sweep panel (over-rows vs the 39 FDR-significant fgsea set;
  likely a sensitivity scatter rather than a curated leading-edge plot).
- M12B network: 11 edges (small).
- M12B correlation (3 CSVs) and environment concordance (2 CSVs): **not in Fig6**.

No figure uses the superseded v1 numbers.

## 4. "Previous integrated figure" search

- The user remembers an "integrated pathway / biology" figure. The only such
  figure that exists in the current repository is **Fig6_pathway_integration**
  (already a main-text figure).
- The historical `M12_pathway_enrichment/` v1 bundle (archived) contains only 1
  file and **no figure**.
- `figures_nature_v2.2/` has no pathway / network / Spearman figures at all.
- `figures_prospective_v2.7/` FIG1–FIG15 are discovery/reused-hold-out figures;
  none is a dedicated pathway figure (FIG6_integrated_evidence is the D-side
  integrated figure, not a pathway-enrichment figure).

**Conclusion**: no previously-existing integrated pathway figure has been lost
to archive. The "integrated figure" the user recalls is Fig6.

## 5. Fig6 gap analysis

| Available information in M12/M12B tables | In Fig6? |
|---|---|
| cameraPR GO BP 25 themes | Partial (8 of 25) |
| cameraPR Reactome 170 themes | **No** |
| ORA GO BP 3 | Yes (3/3) |
| ORA Reactome 20 | **No** |
| fgsea GO BP 3 | Sweep panel (not curated) |
| fgsea GO MF 8 | Sweep panel (not curated) |
| fgsea GO CC 11 | Sweep panel (not curated) |
| fgsea Reactome 17 | Sweep panel (not curated) |
| M12B 85-DEPs ↔ pathway network | Partial (11 edges) |
| M12B pairwise Spearman correlation (3 CSVs) | **No** |
| M12B environment concordance (2 CSVs) | **No** |
| M12B annotation provenance | **No** |

**Verdict: Fig6 is TOO_REDUCTIVE on the primary cameraPR Reactome arm** (170 of
195 primary pathways are Reactome, and Fig6 shows zero Reactome content in a
curated panel; they are only inside the 887-row sweep panel). It is also missing
the M12B pairwise-correlation and environment-concordance layer.

## 6. Recommended pathway figure architecture (no new plotting this round)

### Main text (keep / refine Fig6, no new figure required)
- **Fig6A** — representative cameraPR GO BP themes (current a_ranked; 8 themes
  is adequate for main text).
- **Fig6B** — representative cameraPR **Reactome** theme clusters (NEW curated
  panel needed; data already exist in `M12_pathway_v2.1/ranked/` and
  `integration/`; this is a plotting task, not a reanalysis).
- **Fig6C** — 85-DEP × pathway biological context (current d_network expanded or
  replaced by a compact M12B context strip).
- Drop or compress the 887-row fgsea sweep panel into a single concordance
  scatter or move it fully to supplement.

### Supplementary (restore from current frozen tables; no reanalysis)
- **Supp Fig S-P1** — full cameraPR GO BP 25 table/bar (from
  `M12_pathway_v2.1/ranked/`).
- **Supp Fig S-P2** — full cameraPR Reactome 170 themes / cluster summary.
- **Supp Fig S-P3** — ORA GO BP + Reactome 23 (from `ora/`).
- **Supp Fig S-P4** — fgsea curated leading-edge: GO BP 3 / GO MF 8 / GO CC 11 /
  Reactome 17 (from `ranked_gsea/`).
- **Supp Fig S-P5** — M12B pairwise Spearman correlation heatmap
  (`M12B_biological_context_v2.1/correlation/`).
- **Supp Fig S-P6** — M12B network edges (`network/`).
- **Supp Fig S-P7** — M12B environment concordance (`environment/`).

All of these can be produced from the existing frozen CSVs; **no statistical
reanalysis is required**.

## 7. Missing / do-not-use list

- No figure uses wrong (v1) numbers.
- No figure depends on archive.
- No figure requires rerunning cameraPR / ORA / fgsea / M12B.
- **MISSING_MANUSCRIPT_VISUAL** (data exists, figure never made):
  - cameraPR Reactome curated panel (main-text upgrade).
  - M12B pairwise Spearman heatmap (supplement).
  - M12B environment concordance strip (supplement).
  - Curated fgsea leading-edge (supplement).

These are plotting tasks on frozen tables, not new analyses.
