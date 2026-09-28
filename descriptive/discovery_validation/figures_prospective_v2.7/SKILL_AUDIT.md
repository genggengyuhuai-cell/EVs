# Skill audit — figures_prospective v2.7

Date: 2026-09-28.
Scope: enumerate every skill available in this Codex/Doubao work session and decide which are actually applied to the v2.6 → v2.7 visual redesign.

The installed skills were enumerated from the agent-mode skill list (skill roots:
`.skills/`, `.user_skills/`, `~/Doubao/skills`, `~/.agents/skills`). Each entry below
records name, path, short description, relevance, and whether it was applied.

## A. Skills actually applied to this task

### 1. `doubao-visualization` — APPLIED (design guidance, not code generation)
- Path: `.../.skills/doubao-visualization/SKILL.md`
- What it does: ECharts / HTML / SVG guidance for charts, diagrams, and visual hierarchy; defines when a visual deliverable is expected and how to render deterministic data graphics.
- Relevance: HIGH. The task demands a unified publication visual system, color hierarchy, and panel-by-panel visual QA.
- How it is applied:
  - Adopted its core principle that every figure must carry the scientific message in one glance and that visual encodings must be deterministic (no decorative gradients).
  - Used it to decide that the unified design system is enforced in the R/ggplot2 layer itself (theme + semantic palette + shared axis limits), not by post-processing.
  - It was **not** used to emit ECharts/HTML because the frozen deliverable contract for this bundle is R/ggplot2 → PDF/SVG/TIFF/CSV, and rewriting figures as web charts would break the source-data contract.

### 2. `artifact-preview` — APPLIED (rendered QC)
- Path: `.../.skills/artifact-preview/SKILL.md`
- What it does: render workspace artifacts (pdf/pptx/docx/xlsx/png/jpg/txt) to text + page screenshots + thumbnails for inspection.
- Relevance: HIGH. Step 8 of the task explicitly requires panel-by-panel visual inspection of rendered SVG/TIFF, not PDF operators.
- How it is applied: after R renders each figure to SVG/TIFF, the TIFFs are inspected directly (Read tool) at final aspect ratio for clipping, label overlap, legend collision, and semantic color consistency. The existing v2.6 `qa_preview/` PNG contact sheet was the model for this step.

### 3. `verifier-hub` — APPLIED (deterministic source-data comparison)
- Path: `.../.skills/verifier-hub/SKILL.md`
- What it does: deterministic artifact verifier (file/xlsx/docx/pdf/pptx/text/archive/rubric) for pre-delivery checks.
- Relevance: HIGH for Step 9 (programmatic v2.6 vs v2.7 invariance).
- How it is applied: the invariance check is implemented as a small R comparison script (not a rubric YAML) because the contract is "same protein IDs, same rows, same contrasts, same estimates/CIs/P/FDR/Model_status/display-selection". This is a deterministic row/column comparison that the verifier-hub philosophy (deterministic, machine-checkable, no hand-waving) directly informed.

## B. Skills reviewed and explicitly NOT applied (with reason)

| Skill | Why not applied |
|---|---|
| `doubao-creative-design` / `seedream-50` | These are generative image / poster tools. This task is a frozen scientific-content redesign of ggplot2 figures; generating raster "art" would fabricate statistics and violate Step 2. Not used. |
| `doubao-creative-video`, `seedance-25`, `doubao-creative-drama` | Video/animation toolchain. Not relevant to static publication figures. |
| `doubao-academic-researcher`, `doubao-academic-evaluator`, `doubao-academic-polish` | Literature / manuscript writing. The scientific content is frozen; no new literature search or writing is permitted. |
| `doubao-public-company-analysis`, `multi-stock-comparison`, `seed_finance_lookup`, `doubao-earnings-analysis`, `doubao-market-hotspot`, `doubao-stock-screening`, `doubao-daily-stock` | Finance. Out of scope. |
| `doubao-medical-*` (report, literature, decision support, answer-with-evidence) | Clinical/medical Q&A. This is a pre-existing proteomics figure bundle; no new clinical question. |
| `doubao-contract-*`, `doubao-dpa-drafter`, `doubao-compliance-assessment-public` | Legal/compliance drafting. Out of scope. |
| `doubao-marketing-*`, `doubao-newmedia-writing`, `doubao-multiplatform-rewrite`, `doubao-ecommerce-*` | Marketing / social / e-commerce. Out of scope. |
| `doubao-product-*`, `doubao-game-designer`, `doubao-novel-writing`, `doubao-book-writer`, `doubao-patent-drafting`, `doubao-paper-close-reading`, `doubao-research-proposal` | Product / writing / patents. Out of scope. |
| `doubao-sentiment-tracker`, `browser-*`, `computer-use-automation` | Browser/RPA. The figures are produced by a local Rscript; no GUI automation is needed. |
| `lark-*` (doc, sheet, base, calendar, im, mail, drive, wiki, etc.) | Feishu/Lark platform. The deliverables are local files under `F:/env/...`; no Feishu write is requested. |
| `ppt`, `word`, `pdf`, `sheet`, `html` (document-generation skills) | The task explicitly demands R/ggplot2 outputs (PDF/SVG/TIFF/CSV), not a Word/PDF/HTML deliverable. The `html` skill is not used because the frozen figure contract is vector + raster, not a web page. |
| `byted-mediakit-*` (audio/video/image) | Media processing. Not used; the figures are not media files requiring re-encoding. |
| `doubao-app-builder`, `doubao-oceanengine-adops-agent` | App building / ads. Out of scope. |
| `doubao-pc-optimizer`, `student-discount-application`, `gift-card-redemption`, `consensus`, `tencent-meeting-cli`, `doubao-identity`, `doubao-record`, `doubao-announcement-analysis`, `doubao-critical-reading-companion`, `doubao-data-analysis`, `doubao-finance-model-builder`, `doubao-human-signal`, `doubao-industry-analysis`, `doubao-journal-format`, `doubao-listing-localization`, `doubao-marketing-material-review`, `doubao-marketing-plan`, `doubao-medical-literature-*`, `doubao-personal-info-audit`, `doubao-private-company`, `doubao-product-*`, `doubao-questionnaire-designer`, `doubao-reference-audit`, `doubao-ultimate-guide`, `doubao-video-extract`, `doubao-wealth-planning`, `skill-creator-for-work`, `doubao-cross-border-growth-content`, `doubao-ecommerce-compliance-tax-logistics`, `doubao-ecommerce-proposal`, `doubao-customer-service`, `doubao-dpa-drafter`, `doubao-contract-amendment` | Reviewed; none is a scientific-figure-design or statistical-figure-QC skill in this list. No equivalent of `visualize-data`, `validate-data`, `analyze-data-quality`, `scientific/publication figure review`, or `design feedback / visual hierarchy` is present as a standalone installed skill. |

## C. Skills specifically searched for and NOT found

The task asked to look for skills equivalent to:
- `visualize-data` → not installed. `doubao-visualization` is the closest and was applied.
- `validate-data` / `analyze-data-quality` → not installed as standalone skills. `doubao-data-analysis` is about structured business-data analysis (funnels/retention/AB), not figure QA; not applied.
- `scientific/publication figure review` → not installed.
- `design feedback / visual hierarchy` → not installed as a separate skill; visual-hierarchy guidance was taken from `doubao-visualization` and from the task's own explicit Step 4 checklist.
- Nature / biomedical journal figure preparation → not installed as a dedicated skill.
- R / ggplot2 figure engineering → no dedicated skill; the existing v2.6 R script itself is the engineering reference and was preserved structurally.

## D. Skills applied summary

Three skills were actually used:
1. `doubao-visualization` — design-system principles (deterministic encoding, visual hierarchy, no decorative gradients, one-message-per-panel).
2. `artifact-preview` — rendered inspection of TIFFs at final size.
3. `verifier-hub` — deterministic comparison mindset for the v2.6↔v2.7 source-data invariance check.

No skill was installed on the fly; no skill was used to fabricate scientific results. All scientific values continue to come from the frozen D01–D10 result CSVs.
