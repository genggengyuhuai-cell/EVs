# R03 Final Author Decision

> Date: 2026-10-02
> Decision: **R03 = CLOSED_ACCEPT_CURRENT_UNIVERSE_STRUCTURE**
> Action: No rerun of M12. No frozen numerical output changed.

---

## 1. Decision

**R03_AUTHOR_DECISION = ACCEPT_CURRENT_THREE_LAYER_UNIVERSE_NO_RERUN**

The project accepts the current three-layer universe structure as the final
state for M12 pathway analysis. The mapping starting universe remains the
existing full-cohort quantitative mapping registry (1,434). No rerun of
M12 mapping, cameraPR, ORA, fgsea, Figure 6, or M12B is authorized.

---

## 2. The three universe layers (must not be collapsed)

| Layer | N | Definition | Population | Statistic source |
|---|---|---|---|---|
| A. Discovery inferential universe | **1,445** | D01 Discovery-eligible proteins; ≥70% group-specific detection within frozen Discovery | Frozen Discovery n=386 | D02 moderated t (High vs Low) |
| B. M12 mapping registry | **1,434** | Historical/full-cohort eligible proteins; ≥70% group-specific detection across the full cohort | Full cohort n=515 | Mapping input to M12_01 |
| B→C mapped representative | **1,414** | B after removing 5 unmapped + 15 multi-gene ambiguous (representative retained) | — | M12_01 output |
| C. Rankable tested universe | **1,406** | Mapped representatives ∩ D02 ESTIMABLE (has valid moderated t) | Discovery n=386 | D02 moderated t |

---

## 3. Reconciliation of 1,434 vs 1,445

The two numbers are not competing versions of one universe. They are
generated from different populations using the same ≥70% per-group
coverage logic:

| Quantity | N | Definition |
|---|---|---|
| Discovery eligible (D01) | 1,445 | 386 Discovery participants |
| Full-cohort eligible (historical/Q515) | 1,434 | 515 participants |
| Shared (in both) | 1,426 | Per M13 reconciliation |
| Full-cohort-only | 8 | High-group detection 0.68–0.70, below D01 threshold; present in Q515 matrix |
| Discovery-only | 19 | Pass Discovery ≥70% filter; absent from Q515 tested rows |

This overlap was prospectively documented in
`M13_historical_reconciliation/M13_universe_reconciliation.csv` and in
`docs/CLAIM_C05_RECONCILIATION.md`.

---

## 4. Historical decision chain

- 2026-09-24~26: v1.0 full-cohort pipeline frozen; historical eligible = 1,434.
- 2026-09-26: D01 independently produced Discovery-eligible = 1,445 from the
  frozen 386 Discovery cohort. D02/D03 locked 85 DEPs on the 1,445 universe.
- 2026-09-28: M12 first implemented using the full-cohort Q515 framework and
  1,434 mapping input; ranking statistic was self-fit lmFit. Estimand at
  that time was full-cohort Q515 biology.
- 2026-10-01 (Phase 5 repair): ranking statistic correctly changed to the
  frozen D02 moderated t. The contract statement that mapping should also
  start from D01=1,445 was introduced during repair, after pre-repair
  pathway results were already known. It was never prospectively executed.
  It was explicitly deferred as R03.
- 2026-10-01: analysis-v2.1 tag applied to commit 6d0e004 with R03 still
  marked deferred.
- 2026-10-02: author closes R03 without rerun.

---

## 5. Why no rerun

- The current 1,406 rankable tested universe is a clean
  mapped ∩ D02-estimable set.
- The 8 full-cohort-only proteins do not enter the actual D02-ranked
  testing universe (they lack D02 ESTIMABLE status).
- The 19 Discovery-only proteins absent from mapping are a known, documented
  universe difference, not a hidden implementation error.
- There is no demonstrated reproducibility defect.
- The contract statement "mapping should start from 1,445" was a repair-era
  forward-looking note, not a prospective preregistered requirement. M12 was
  originally built as a full-cohort pathway module; the ranking statistic
  was later aligned to D02, but the mapping registry was never prospectively
  specified as 1,445.
- Re-running mapping + cameraPR + ORA + fgsea + Figure 6 solely to make the
  mapping start count numerically equal 1,445 would reopen frozen analyses
  after seeing results, with no scientific defect being corrected.

---

## 6. Frozen pathway results (unchanged)

| Analysis | Family | Tested | Significant (pooled BH-FDR) |
|---|---|---|---|
| cameraPR (primary) | GO-BP | 272 | 29 |
| cameraPR (primary) | Reactome | 486 | 176 |
| cameraPR total primary | — | 758 | **205** |
| ORA total primary | GO-BP + Reactome | — | **23** (3 + 20) |
| fgsea | 4 families | 1,016 | **44** (per-family) / **41** (pooled) |
| KEGG | — | 0 | NOT_RUN |

These numbers remain the final frozen counts. No frozen numerical output
was modified by this decision.

---

## 7. Methods wording contract (mandatory)

Do **not** write "mapping started from the complete 1,445 Discovery universe"
— that is factually false for the frozen M12 implementation.

Use the following distinction in manuscript Methods:

- Discovery differential inference (85 DEPs) used the **1,445-protein
  Discovery-eligible universe** (D01, frozen Discovery n=386).
- Pathway mapping used the **existing full-cohort quantitative mapping
  registry** (1,434 proteins, derived from the full 515 cohort).
- Ranked pathway testing (cameraPR, fgsea) used **D02 moderated statistics
  among mapped and estimable proteins**, yielding **1,406 rankable proteins**.
- ORA used the 85 locked candidates as foreground against the 1,406
  mapped/estimable background.

---

## 8. Status

R03 = **CLOSED_ACCEPT_CURRENT_UNIVERSE_STRUCTURE**.

No frozen numerical result changed. No analysis-v2.1 tag movement.
No rerun authorized.
