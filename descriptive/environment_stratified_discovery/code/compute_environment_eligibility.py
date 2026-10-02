"""Environment-stratified quantitative eligibility (Phase 1).

Parent universe = frozen D01 Discovery-eligible 1,445 proteins.
Detection rule mirrors D01 exactly: detected = finite raw abundance AND raw > 0.
Integer rule: detected_count * 100 >= 70 * group_n.

Outputs (Discovery data only; Validation never touched):
  results/sample_counts.csv
  results/input_universe_manifest.csv
  results/environment_eligibility_all_1445.csv
  diagnostics/eligibility_summary.csv
"""
from __future__ import annotations

import hashlib
import sys
from pathlib import Path

import numpy as np
import pandas as pd

HERE = Path(__file__).resolve()
BRANCH = HERE.parent.parent          # descriptive/environment_stratified_discovery
DV = BRANCH.parent / "discovery_validation"
ROOT = BRANCH.parent.parent         # F:\env
ASSIGN = ROOT / "descriptive" / "discovery_validation_split" / "discovery_validation_assignment.csv"
EXPRESSION = DV / "D01_discovery_eligibility" / "D01_discovery_eligible_expression.csv.gz"
ELIGIBLE_PROTEINS = DV / "D01_discovery_eligibility" / "D01_discovery_eligible_proteins.csv"

ASSIGN_SHA = "062e51026b7420dca2077d5807bfdaa760ac08ac5f19a9af98cf89da2b7b6791"
EXPECTED_PARENT = 1445
THRESHOLD_PCT = 70
SITE_ENV = {
    "FJ_FQ": "Humid-hot", "FJ_PT": "Humid-hot", "FJ_QZ": "Humid-hot", "GZ_TH": "Humid-hot",
    "XZ_GG": "High-pressure/high-altitude", "XZ_YA": "High-pressure/high-altitude",
    "XZ_YB": "High-pressure/high-altitude", "XZ_YC": "High-pressure/high-altitude",
    "XZ_YD": "High-pressure/high-altitude",
}
DOSE_ORDER = ["control", "low", "high"]
ENV_ORDER = ["Humid-hot", "High-pressure/high-altitude"]


def sha256(p: Path) -> str:
    h = hashlib.sha256()
    with p.open("rb") as fh:
        for chunk in iter(lambda: fh.read(1 << 20), b""):
            h.update(chunk)
    return h.hexdigest()


def fail(msg: str) -> "None":
    print(f"GATE_FAIL: {msg}", file=sys.stderr)
    sys.exit(1)


def main() -> None:
    # ---- gate: assignment hash ----
    obs = sha256(ASSIGN)
    if obs != ASSIGN_SHA:
        fail(f"assignment sha256 mismatch: {obs}")

    assign = pd.read_csv(ASSIGN, dtype={"UniqueSampleID": str})
    disc = assign[assign["Split"] == "Discovery"].copy()
    hold = assign[assign["Split"] == "Validation"].copy()
    if len(disc) != 386 or len(hold) != 129 or len(assign) != 515:
        fail(f"split counts wrong: disc={len(disc)} hold={len(hold)}")
    if disc["UniqueSampleID"].duplicated().any() or hold["UniqueSampleID"].duplicated().any():
        fail("duplicate sample IDs")

    disc["Environment"] = disc["group"].map(SITE_ENV)
    if disc["Environment"].isna().any():
        fail("unmapped site in discovery")

    # ---- sample counts table ----
    counts = (
        disc.groupby(["Environment", "TREAT1_clean"])["UniqueSampleID"]
        .count().unstack("TREAT1_clean").reindex(ENV_ORDER)[DOSE_ORDER]
    )
    expected = pd.DataFrame(
        [[71, 62, 76], [44, 77, 56]], index=ENV_ORDER, columns=DOSE_ORDER
    )
    if not counts.astype(int).equals(expected.astype(int)):
        fail(f"sample counts mismatch:\n{counts}\nvs\n{expected}")

    sample_counts_rows = []
    for env in ENV_ORDER:
        for dose in DOSE_ORDER:
            sample_counts_rows.append({
                "Split": "Discovery", "Environment": env, "Dose": dose,
                "n": int(counts.loc[env, dose]),
            })
    hold["Environment"] = hold["group"].map(SITE_ENV)
    for env in ENV_ORDER:
        for dose in DOSE_ORDER:
            n = int(((hold["Environment"] == env) & (hold["TREAT1_clean"] == dose)).sum())
            sample_counts_rows.append({
                "Split": "Validation", "Environment": env, "Dose": dose, "n": n,
            })
    sample_counts = pd.DataFrame(sample_counts_rows)
    (BRANCH / "results").mkdir(exist_ok=True)
    sample_counts.to_csv(BRANCH / "results" / "sample_counts.csv", index=False)

    # ---- parent universe ----
    parent = pd.read_csv(ELIGIBLE_PROTEINS, dtype={"PG.ProteinGroups": str})
    parent_ids = parent["PG.ProteinGroups"].astype(str).tolist()
    if len(parent_ids) != EXPECTED_PARENT or len(set(parent_ids)) != EXPECTED_PARENT:
        fail(f"parent universe size wrong: {len(parent_ids)}")

    # ---- read D01 eligible expression (raw abundance, non-detected = NA) ----
    expr = pd.read_csv(EXPRESSION, dtype={"PG.ProteinGroups": str})
    expr = expr.set_index("PG.ProteinGroups")
    if not set(parent_ids).issubset(set(expr.index)):
        fail("parent proteins missing from expression matrix")
    expr = expr.loc[parent_ids]

    # gate: expression columns are exactly the 386 discovery IDs
    expr_ids = list(expr.columns)
    if set(expr_ids) != set(disc["UniqueSampleID"]):
        fail(f"expression cols != discovery IDs: diff={set(expr_ids)^set(disc['UniqueSampleID'])}")

    # ---- compute detection counts per Environment x Group ----
    # detected = finite AND raw > 0 (mirror D01 L348)
    arr = expr.to_numpy(dtype=float)  # shape (1445, 386); NA where non-detected
    detected = np.isfinite(arr) & (arr > 0)

    disc = disc.set_index("UniqueSampleID").loc[expr_ids].reset_index()
    rows = {"PG.ProteinGroups": parent_ids}

    elig_masks = {}
    for env in ENV_ORDER:
        env_disc = disc[disc["Environment"] == env]
        for dose in DOSE_ORDER:
            mask = (env_disc["TREAT1_clean"] == dose).to_numpy()
            n = int(mask.sum())
            col_counts = detected[:, [list(expr_ids).index(sid) for sid in env_disc.loc[mask, "UniqueSampleID"]]].sum(axis=1).astype(int)
            # integer rule: counts * 100 >= 70 * n
            passes = col_counts * 100 >= THRESHOLD_PCT * n
            tag = "HH" if env == "Humid-hot" else "HA"
            rows[f"{tag}_{dose.capitalize()}_detected_n"] = col_counts
            rows[f"{tag}_{dose.capitalize()}_total_n"] = np.full(len(parent_ids), n, dtype=int)
            rows[f"{tag}_{dose.capitalize()}_detection_rate"] = col_counts / n
            rows[f"{tag}_{dose.capitalize()}_pass70"] = passes
        # eligible = pass all three doses
        hh_col = "HH" if env == "Humid-hot" else "HA"
        elig = (
            rows[f"{hh_col}_Control_pass70"]
            & rows[f"{hh_col}_Low_pass70"]
            & rows[f"{hh_col}_High_pass70"]
        )
        elig_masks[env] = elig
        rows[f"{hh_col.lower()}_eligible"] = elig

    out = pd.DataFrame(rows)
    out_path = BRANCH / "results" / "environment_eligibility_all_1445.csv"
    out.to_csv(out_path, index=False)

    # ---- summary ----
    q_hh = elig_masks["Humid-hot"]
    q_ha = elig_masks["High-pressure/high-altitude"]
    n_parent = len(parent_ids)
    n_q_hh = int(q_hh.sum())
    n_q_ha = int(q_ha.sum())
    n_shared = int((q_hh & q_ha).sum())
    n_hh_only = int((q_hh & ~q_ha).sum())
    n_ha_only = int((~q_hh & q_ha).sum())
    n_neither = int((~q_hh & ~q_ha).sum())

    # subset assertions
    if not q_hh.all() | (~q_hh.all()) or n_q_hh > n_parent:
        fail("Q_HH not subset of parent")
    if n_q_ha > n_parent:
        fail("Q_HA not subset of parent")

    summary = pd.DataFrame([
        {"metric": "N_D01_parent", "value": n_parent},
        {"metric": "N_Q_HH", "value": n_q_hh},
        {"metric": "N_Q_HA", "value": n_q_ha},
        {"metric": "N_Q_shared", "value": n_shared},
        {"metric": "N_Q_HH_only", "value": n_hh_only},
        {"metric": "N_Q_HA_only", "value": n_ha_only},
        {"metric": "N_Q_neither", "value": n_neither},
    ])
    (BRANCH / "diagnostics").mkdir(exist_ok=True)
    summary.to_csv(BRANCH / "diagnostics" / "eligibility_summary.csv", index=False)

    # ---- input universe manifest ----
    manifest_rows = [
        {"kind": "input", "path": str(ASSIGN), "sha256": sha256(ASSIGN)},
        {"kind": "input", "path": str(EXPRESSION), "sha256": sha256(EXPRESSION)},
        {"kind": "input", "path": str(ELIGIBLE_PROTEINS), "sha256": sha256(ELIGIBLE_PROTEINS)},
        {"kind": "parameter", "path": "threshold_percent", "sha256": str(THRESHOLD_PCT)},
        {"kind": "parameter", "path": "detection_rule", "sha256": "finite_raw_gt_0"},
        {"kind": "output", "path": str(BRANCH / "results" / "environment_eligibility_all_1445.csv"),
         "sha256": sha256(BRANCH / "results" / "environment_eligibility_all_1445.csv")},
    ]
    pd.DataFrame(manifest_rows).to_csv(
        BRANCH / "results" / "input_universe_manifest.csv", index=False
    )

    print("ELIGIBILITY PASS")
    print(summary.to_string(index=False))
    print("\nSample counts (Discovery):")
    print(counts)


if __name__ == "__main__":
    main()
