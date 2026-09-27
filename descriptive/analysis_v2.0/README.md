# analysis_v2.0 — V2 Analysis Workspace

This directory contains all v2.0 analysis outputs and infrastructure.
It does **not** modify or copy frozen v1.0 / Discovery-Validation / missingness code.

## Directory layout

```
analysis_v2.0/
├── config/              # Canonical configuration, provenance, no-overwrite helpers
├── registry/            # Contaminant registry, universe registries
├── contracts/           # Data contracts (U0/Utech/Q515/D515, input/output schemas)
├── metadata/            # V2-01 output: participant description (future)
├── qc/                  # V2-03 output: proteome landscape, PCA (future)
├── abundance/           # V2-05–07 output: E/omnibus/ordered/pairwise (future)
├── detection/            # V2-08 output: Firth detection, unique proteins (future)
├── environment/         # V2-09 output: environment-specific + interaction (future)
├── site/                # V2-10 output: site robustness, LOO (future)
├── pathway/             # V2-11 output: cameraPR/ORA (future)
├── ml/                  # V2-14 output: nested CV, locked model (future)
├── tables/              # V2-16 output: manuscript tables (future)
└── figures/             # V2-16 output: manuscript figures (future)
```

## What exists now (Phase 1: V2-00 + V2-01 design only)

- `config/v2_config.R` — canonical project configuration (R helper spec)
- `config/v2_provenance.R` — provenance manifest helper specification
- `config/v2_no_overwrite.R` — no-overwrite / frozen-output protection spec
- `registry/contaminant_registry_spec.md` — Category A/B/C registry schema
- `registry/DATA_SOURCE_AUDIT.md` — static audit of contaminant data sources
- `contracts/universe_contract.md` — U0/Utech/Q515/D515 data contract

## What does NOT exist yet

No abundance, detection, environment, site, pathway, ML, figure, or table results have been generated.
No Q515 or D515 protein lists have been computed.
No inferential model has been fitted.

## Authority

- **Protocol**: `docs/protocol/ANALYSIS_PLAN_v2.0.md` (frozen)
- **Design audit**: `docs/protocol/STUDY_DESIGN_AUDIT.md`
- **Implementation gap audit**: `docs/protocol/V2_IMPLEMENTATION_GAP_AUDIT.md`
- **This workspace**: infrastructure design only; no biological results yet.
