# Software Environment Report — analysis-v2.1 freeze

Captured 2026-09-29 on the audit host. No packages were installed; this is a
static record of what the repository depends on.

## OS / shell

- OS: Windows (desktop).
- Shell: PowerShell 5.1 (user shell); R scripts invoked via `Rscript`.
- Repo root: `F:\env` (absolute path exists on this machine but no active script
  uses it — all active code uses repo-relative paths; see hard-coded path audit).

## R

- `Rscript --version`: **R 4.3.1 (2023-06-16)**.
- Major R packages referenced by active scripts (from `library(...)` / `pkg::fn`
  static grep):

| Package | References | Notes |
|---|---|---|
| limma | 10 | M05–M07, D02; eBayes lmFit |
| glmnet | 2 | M15 fixed-85 Elastic Net |
| logistf | 1 | M08 Firth |
| ranger | 1 | M15 Boruta-style + CV |
| xgboost | 1 | M15 nonlinear robustness |
| fgsea | 2 | M12 ranked enrichment (fgseaMultilevel) |
| org.Hs.eg.db | 5 | M12 gene ID mapping |
| data.table | 1 |  |
| dplyr | 1 |  |
| tidyr | 1 |  |
| ggplot2 | 1 | M17 figures |

Package version pinning: **PARTIALLY_DOCUMENTED**. The repo does not ship a
`DESCRIPTION`, `renv.lock`, or `sessionInfo.txt` that fixes every transitive
dependency. Active scripts do not depend on bleeding-edge version-specific
behaviors; reproducibility is acceptable but not bit-exact across minor versions.

## Python

- `python --version`: **Python 3.14.7**.
- Active Python scripts: `code/P1.py`, `code/P2.py`, `code/P3.py`,
  `descriptive/nature_plotting.py`.
- Imports (from P1/P2/P3 reads): `pandas`, `openpyxl`, `pathlib`, `re`,
  `collections`.
- Version pinning: **NOT_DOCUMENTED** (no requirements.txt / environment.yml).
  Pure-Python with stable libraries; risk is low.

## Seed strategy

| Module | Random component | Seed |
|---|---|---|
| D01–D10 | Deterministic (limma) | N/A |
| M05–M11 | Deterministic (limma / logistf / LOO enumeration) | N/A |
| M12 fgsea | fgseaMultilevel permutations | Deterministic; no explicit seed visible in static scan (fgsea default internal seed) |
| M15 fixed-85 | 5 outer × 5 inner × repeats CV; ranger; XGBoost; Boruta-style | `set.seed(20260928, kind="Mersenne-Twister", normal.kind="Inversion")` + fold seeds 1000+fi, 2000L+fi*100+a*10, 3000+fi (Boruta), 4000+fi, 5001/5002+a*100, 5003 |
| M15 strict nested | Fold-local limma + outer CV | `set.seed(20260928, kind="Mersenne-Twister", normal.kind="Inversion")` + OUTER_SEEDS[r] |
| M17 | Deterministic plotting | N/A |

Seeds are explicit and Mersenne-Twister/Inversion; reproducibility is high for
ML given identical R / package versions.

## Known environment limitations

- No `renv.lock` or `sessionInfo.txt` is checked in; exact package minor versions
  are not pinned. Mitigation: active code does not rely on version-specific
  behavior; results are audited at the statistical level.
- Python 3.14.7 on the audit host may differ from the host that produced P1/P2/P3
  outputs; P1/P2/P3 are deterministic Excel readers/writers, so bit-exact
  reproduction is expected but not guaranteed across pandas/openpyxl minor versions.
- `msigdbr` / `msigdbdf` references: 0 in active scripts (M12 uses a local
  MSigDB/Gene Ontology + Reactome annotation bundle already in the repo; the
  one-off installers are in `archive/installers/`).
