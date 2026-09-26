# Prospective Discovery–Validation EV proteomics pipeline

## Current authority and objective

This is the canonical technical README for the prospective branch. The primary question is whether Discovery Long vs Short (`high` vs `low`) quantitative protein effects replicate in an independent frozen Validation set. The historical full-cohort analysis is a benchmark, not a source of prospective eligibility, candidates or thresholds.

Already completed and frozen: analysis-v1.0 on 515 participants; the historical 1,434-protein / 256-DEP branch; Stage 13A; the 75/25 assignment; protocol and split specification. The frozen split contains 386 Discovery and 129 Validation participants. The assignment must never be regenerated or modified.

## Stage architecture

- D01 rebuilds eligibility from all 3,817 raw protein groups using Discovery only. Detection is finite abundance >0 and each of control/low/high must independently reach 70%. No transformation, normalization or imputation occurs.
- D02 uses log2(PG.Quantity), no additional normalization and no imputation; limma fits `abundance ~ dose + environment`, with `eBayes(trend=TRUE, robust=TRUE)`. It reports every D01 protein for Long vs Short.
- D03 alone locks candidates at Discovery Long-vs-Short BH-FDR <0.05. No effect cutoff, Control result, subgroup result, site result or historical membership changes this rule.
- D04 characterizes Control → Short → Long trajectories without changing membership.
- D05 estimates the three contrasts within each Environment. D06 tests formal difference-in-differences, primarily `(Long−Short)_Humid-hot − (Long−Short)_High-pressure/high-altitude`. D07 summarizes sites and performs leave-one-major-site-out sensitivity. These are secondary/supportive.
- D08 is restricted to the exact D03 family. It reports estimability, Validation effect/CI/P/candidate-family BH-FDR, direction, signed and absolute Discovery–Validation differences, and the locked evidence hierarchy. Rates use `N_locked` primarily and `N_estimable` secondarily.
- D09 keeps quantitative missingness, binary detection and peptide support as distinct evidence. It does not impute the primary analysis. Threshold attainment at 50/60/70/80% is group-wise and does not impose arbitrary low detection elsewhere.
- D10 joins finalized evidence without redefining candidates. Pathway work requires an investigator-approved mapping/universe; absent that source it remains not run.

## Validation firewall

Before D08, no module reads, summarizes, ranks or plots Validation protein outcomes. D08 requires both a hash-verified frozen D03 list and an investigator-created `VALIDATION_UNLOCKED.txt`. The repository does not create this marker and provides no bypass. Validation cannot discover or promote proteins.

## Figure architecture

The R-only figure module consumes finalized CSVs and never refits a model or recalculates FDR. Planned main figures are: Fig. 1 cohort/split/QC schematic; Fig. 2 Discovery primary signal; Fig. 3 candidate trajectories; Fig. 4 Environment effects and interaction; Fig. 5 Discovery–Validation agreement; Fig. 6 integrated abundance/detection/peptide evidence. Supplementary figures cover full QC, ranks/volcano, site robustness, leave-one-site-out, subgroup forests, missingness, detection gradients and peptide diagnostics. Functions fail gracefully when required estimates are absent. Final exports are planned at 183 mm with editable SVG/PDF and 600-dpi TIFF; no analytical figure has been generated.

## Dependency diagram

See [WORKFLOW.md](WORKFLOW.md) for the full diagram and eight mandatory review gates. Execution is deliberately one stage at a time:

```text
python run_discovery_validation_pipeline.py --stage D01
```

The next permitted action is investigator-authorized D01 only, followed by Gate 1 review.

## Output and reproducibility rules

Generated results belong under `D01_discovery_eligibility/` … `D10_integrated_biology/`. Code refuses silent overwrite and records SHA-256 provenance manifests. Keys and terminology are fixed by [DATA_CONTRACTS.md](DATA_CONTRACTS.md). Missing estimates are `NA` with explicit `NON_ESTIMABLE` status, never zero. Raw data and frozen outputs are read-only.

Prohibited shortcuts include using historical 1,434 for D01, historical 256 for D03, inspecting Validation before unlock, discovering in Validation, changing candidates through Environment/interaction/site results, replacing the primary analysis with imputation, rerandomizing the split, or selecting display proteins from visual appearance.

## Documentation reading order

1. `F:/env/PROJECT_CONTEXT.md`
2. `F:/env/descriptive/discovery_validation/README.md`
3. `F:/env/descriptive/discovery_validation/PIPELINE_STATUS.md`
4. `F:/env/descriptive/discovery_validation/DATA_CONTRACTS.md`
5. `F:/env/descriptive/discovery_validation/WORKFLOW.md`
6. `F:/env/DISCOVERY_VALIDATION_PROTOCOL.md`
7. `F:/env/DISCOVERY_VALIDATION_SPLIT_SPEC.md`

## CURRENT STATE

```text
Historical analysis-v1.0: FROZEN
Stage 13A: COMPLETED AND FROZEN
Discovery–Validation participant split: EXECUTED AND FROZEN (386 / 129)
Prospective D01–D10 code: IMPLEMENTED
Static cross-stage review: COMPLETED
Nature-style figure architecture: PLANNED / STATICALLY REVIEWED
Prospective analytical execution: NOT EXECUTED
Validation outcomes: NOT ACCESSED
NEXT ACTION: Investigator-authorized staged execution beginning with D01.
```
