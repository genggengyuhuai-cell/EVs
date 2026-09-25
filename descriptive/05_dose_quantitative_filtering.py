"""Dose-wise quantitative protein filtering.

Primary scientific question:
    control vs low vs high dose response

Primary quantitative set:
    protein detected in >=70% of samples in EACH of control, low, and high.

Sensitivity sets:
    >=50%, >=60%, >=80% in EACH dose group.

IMPORTANT:
- Unknown TREAT1 samples are excluded from dose-defined downstream matrices.
- Missing values are RETAINED as NA/NaN.
- No imputation.
- No NA -> 0 conversion.
- No normalization.
- No batch correction.
- No differential analysis.
"""

from pathlib import Path
import hashlib
import json
import math
import runpy

import numpy as np
import pandas as pd
from openpyxl import load_workbook


# ============================================================
# 1. Paths
# ============================================================

OUT = Path(__file__).resolve().parent
ROOT = OUT.parent

SOURCE = ROOT / "rawdata" / "processed.xlsx"
MAP = ROOT / "rawdata" / "sample_mapping_FINAL.xlsx"

AUDIT = OUT / "audit.json"
SAMPLE_STATS = OUT / "sample_statistics.csv"
CANONICAL_ANNOTATION = OUT / "canonical_protein_annotation.csv"


# ============================================================
# 2. Analysis settings
# ============================================================

DOSE_LEVELS = [
    "control",
    "low",
    "high"
]

THRESHOLDS = [
    50,
    60,
    70,
    80
]

PRIMARY_THRESHOLD = 70


# ============================================================
# 3. Verify source files have not changed
# ============================================================

if not AUDIT.is_file():
    raise FileNotFoundError(
        f"Missing audit file: {AUDIT}\n"
        "Run 01_describe_proteomics.py first."
    )

audit = json.loads(
    AUDIT.read_text(
        encoding="utf-8"
    )
)

for path in [
    SOURCE,
    MAP
]:
    if not path.is_file():
        raise FileNotFoundError(
            f"Missing source file: {path}"
        )

    observed_hash = hashlib.sha256(
        path.read_bytes()
    ).hexdigest()

    expected_hash = audit.get(
        path.name + "_sha256"
    )

    if expected_hash is None:
        raise KeyError(
            f"{path.name}_sha256 is missing from audit.json"
        )

    if observed_hash != expected_hash:
        raise ValueError(
            f"Source changed: {path.name}\n"
            "Rerun 01_describe_proteomics.py first."
        )


# ============================================================
# 4. Read sample metadata in exact matrix-column order
# ============================================================

if not SAMPLE_STATS.is_file():
    raise FileNotFoundError(
        f"Missing file: {SAMPLE_STATS}\n"
        "Run 01_describe_proteomics.py first."
    )

if not CANONICAL_ANNOTATION.is_file():
    raise FileNotFoundError(
        f"Required Stage 01 output is missing: {CANONICAL_ANNOTATION.name}\n"
        "Run 01_describe_proteomics.py first."
    )

sample = pd.read_csv(
    SAMPLE_STATS,
    keep_default_na=False
)

sample = (
    sample
    .sort_values(
        "Sheet1_position"
    )
    .reset_index(
        drop=True
    )
)

required_sample_columns = [
    "Sheet1_position",
    "Sheet1_raw_header",
    "UniqueSampleID",
    "TREAT1_clean",
    "condition",
    "group",
    "进样时间"
]

missing_sample_columns = [
    col
    for col in required_sample_columns
    if col not in sample.columns
]

if missing_sample_columns:
    raise ValueError(
        "sample_statistics.csv is missing required columns: "
        f"{missing_sample_columns}"
    )

if not sample["UniqueSampleID"].is_unique:
    raise ValueError(
        "UniqueSampleID is not unique."
    )

expected_positions = list(
    range(
        1,
        len(sample) + 1
    )
)

if sample["Sheet1_position"].tolist() != expected_positions:
    raise ValueError(
        "Sheet1_position is not a complete 1..N sequence."
    )


# ============================================================
# 5. Read quantitative matrix
# ============================================================

wb = load_workbook(
    SOURCE,
    read_only=True,
    data_only=True
)

ws = wb.worksheets[0]

rows = ws.iter_rows(
    values_only=True
)

header = next(
    rows
)

data = pd.DataFrame(
    list(
        rows
    )
)

wb.close()


def clean_header(value):
    text = str(value).strip()

    if text.endswith(".0"):
        text = text[:-2]

    return text


annotation = data.iloc[
    :,
    :7
].copy()

annotation.columns = header[:7]

raw = data.iloc[
    :,
    7:
].copy()

raw_headers = [
    clean_header(v)
    for v in header[7:]
]

expected_headers = (
    sample["Sheet1_raw_header"]
    .map(
        clean_header
    )
    .tolist()
)

if raw_headers != expected_headers:
    raise ValueError(
        "Matrix sample headers do not match sample_statistics.csv."
    )

values = (
    raw
    .apply(
        pd.to_numeric,
        errors="raise"
    )
    .to_numpy(
        dtype=float
    )
)

n_proteins, n_samples = values.shape

if n_proteins != audit["protein_group_rows"]:
    raise ValueError(
        f"Protein rows = {n_proteins}, "
        f"expected {audit['protein_group_rows']}."
    )

if n_samples != audit["samples"]:
    raise ValueError(
        f"Sample columns = {n_samples}, "
        f"expected {audit['samples']}."
    )

if len(sample) != n_samples:
    raise ValueError(
        "sample_statistics.csv sample count does not match matrix."
    )


# ============================================================
# 6. Define observed / missing values
#
# Same detection rule as 01_describe_proteomics.py:
# finite and > 0 = detected
# everything else = missing
# ============================================================

detected = (
    np.isfinite(
        values
    )
    &
    (
        values > 0
    )
)

quant = np.where(
    detected,
    values,
    np.nan
)

if int((~detected).sum()) != int(audit["missing_cells"]):
    raise ValueError(
        "Missing-cell count does not reproduce audit.json."
    )


# ============================================================
# 7. Validate TREAT1 labels
# ============================================================

observed_labels = set(
    sample["TREAT1_clean"]
)

allowed_labels = {
    "control",
    "low",
    "high",
    "unknown",
    "missing"
}

unexpected_labels = (
    observed_labels
    -
    allowed_labels
)

if unexpected_labels:
    raise ValueError(
        "Unexpected TREAT1_clean labels: "
        f"{sorted(unexpected_labels)}"
    )

dose_defined_mask = (
    sample["TREAT1_clean"]
    .isin(
        DOSE_LEVELS
    )
    .to_numpy()
)

dose_sample = (
    sample.loc[
        dose_defined_mask
    ]
    .copy()
    .reset_index(
        drop=True
    )
)

if len(dose_sample) == 0:
    raise ValueError(
        "No control/low/high samples were found."
    )


# ============================================================
# 8. Dose sample counts
# ============================================================

dose_counts = (
    dose_sample["TREAT1_clean"]
    .value_counts()
    .reindex(
        DOSE_LEVELS,
        fill_value=0
    )
)

if (
    dose_counts == 0
).any():
    raise ValueError(
        "At least one primary dose group has zero samples:\n"
        f"{dose_counts.to_string()}"
    )

dose_count_table = pd.DataFrame({
    "dose": DOSE_LEVELS,
    "samples": [
        int(
            dose_counts[dose]
        )
        for dose in DOSE_LEVELS
    ]
})

dose_count_table.to_csv(
    OUT / "dose_sample_counts.csv",
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# 9. Calculate per-protein detection counts/rates by dose
# ============================================================

protein_id_col = annotation.columns[0]

protein_ids = (
    annotation.iloc[
        :,
        0
    ]
    .astype(
        str
    )
)

canonical_annotation = pd.read_csv(CANONICAL_ANNOTATION, keep_default_na=False)
required_annotation_columns = {"PG.ProteinGroups", "Gene_symbol", "Display_label"}
missing_annotation_columns = required_annotation_columns.difference(canonical_annotation.columns)
if missing_annotation_columns:
    raise ValueError(
        "canonical_protein_annotation.csv is missing columns: "
        f"{sorted(missing_annotation_columns)}"
    )
if canonical_annotation["PG.ProteinGroups"].duplicated().any():
    raise ValueError("Canonical annotation contains duplicated PG.ProteinGroups.")
canonical_annotation = canonical_annotation.set_index("PG.ProteinGroups").reindex(protein_ids)
if (canonical_annotation["Display_label"].isna().any()
        or canonical_annotation["Display_label"].eq("").any()):
    raise ValueError("Canonical annotation does not cover every protein group.")
canonical_annotation = canonical_annotation.reset_index()

if protein_ids.isna().any():
    raise ValueError(
        "Protein ID column contains missing values."
    )

if protein_ids.duplicated().any():
    raise ValueError(
        "Protein ID column contains duplicates."
    )

dose_detection = pd.DataFrame({
    "PG.ProteinGroups": protein_ids
})

dose_detected_counts = {}
dose_detection_rates = {}

for dose in DOSE_LEVELS:
    indices = sample.index[
        sample["TREAT1_clean"]
        ==
        dose
    ].to_numpy()

    n = len(
        indices
    )

    counts = (
        detected[
            :,
            indices
        ]
        .sum(
            axis=1
        )
        .astype(
            int
        )
    )

    rates = (
        counts
        /
        n
    )

    dose_detected_counts[dose] = counts
    dose_detection_rates[dose] = rates

    dose_detection[
        f"{dose}_detected_samples"
    ] = counts

    dose_detection[
        f"{dose}_samples"
    ] = n

    dose_detection[
        f"{dose}_detection_rate"
    ] = rates


# ============================================================
# 10. Build exact threshold memberships
#
# Integer comparison:
# detected_count * 100 >= threshold * n
#
# Avoid floating-point boundary ambiguity.
# ============================================================

membership = pd.DataFrame({
    "PG.ProteinGroups": protein_ids
})

threshold_summary_records = []
threshold_requirement_records = []

for threshold in THRESHOLDS:
    per_dose_masks = []

    for dose in DOSE_LEVELS:
        n = int(
            dose_counts[dose]
        )

        counts = dose_detected_counts[
            dose
        ]

        minimum_detected = math.ceil(
            threshold
            *
            n
            /
            100
        )

        mask = (
            counts
            *
            100
            >=
            threshold
            *
            n
        )

        per_dose_masks.append(
            mask
        )

        membership[
            f"{dose}_ge{threshold}pct"
        ] = mask

        threshold_requirement_records.append({
            "threshold_pct":
                threshold,
            "dose":
                dose,
            "samples":
                n,
            "minimum_detected_samples":
                minimum_detected,
            "effective_minimum_pct":
                minimum_detected
                /
                n
                *
                100
        })

    all_doses_mask = np.logical_and.reduce(
        per_dose_masks
    )

    membership[
        f"all_doses_ge{threshold}pct"
    ] = all_doses_mask

    selected_indices = np.where(
        all_doses_mask
    )[0]

    selected_detected = detected[
        selected_indices
    ][
        :,
        dose_defined_mask
    ]

    total_cells = int(
        selected_detected.size
    )

    missing_cells = int(
        (
            ~selected_detected
        )
        .sum()
    )

    overall_missing_pct = (
        missing_cells
        /
        total_cells
        *
        100
        if total_cells
        else np.nan
    )

    record = {
        "threshold_pct":
            threshold,
        "protein_groups":
            int(
                all_doses_mask.sum()
            ),
        "dose_defined_samples":
            int(
                dose_defined_mask.sum()
            ),
        "total_cells":
            total_cells,
        "missing_cells":
            missing_cells,
        "missing_pct":
            overall_missing_pct,
        "is_primary":
            threshold
            ==
            PRIMARY_THRESHOLD
    }

    for dose in DOSE_LEVELS:
        indices = sample.index[
            sample["TREAT1_clean"]
            ==
            dose
        ].to_numpy()

        d = detected[
            selected_indices
        ][
            :,
            indices
        ]

        record[
            f"{dose}_samples"
        ] = len(
            indices
        )

        record[
            f"{dose}_missing_pct"
        ] = (
            float(
                (
                    ~d
                )
                .mean()
                *
                100
            )
            if d.size
            else np.nan
        )

        record[
            f"{dose}_median_detection_pct"
        ] = (
            float(
                np.median(
                    d.mean(
                        axis=1
                    )
                    *
                    100
                )
            )
            if d.size
            else np.nan
        )

    threshold_summary_records.append(
        record
    )


dose_detection.to_csv(
    OUT / "dose_protein_detection_rates.csv",
    index=False,
    encoding="utf-8-sig"
)

membership.to_csv(
    OUT / "dose_filter_membership.csv",
    index=False,
    encoding="utf-8-sig"
)

threshold_requirements = pd.DataFrame(
    threshold_requirement_records
)

threshold_requirements.to_csv(
    OUT / "dose_filter_threshold_requirements.csv",
    index=False,
    encoding="utf-8-sig"
)

threshold_summary = pd.DataFrame(
    threshold_summary_records
)

threshold_summary.to_csv(
    OUT / "dose_filter_summary.csv",
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# 11. Save dose-defined metadata
#
# Unknown/missing TREAT1 samples are NOT included here.
# No sample is otherwise excluded at this step.
# ============================================================

dose_sample = dose_sample.copy()

dose_sample[
    "MS_batch_proxy"
] = (
    dose_sample[
        "进样时间"
    ]
    .astype(
        str
    )
)

dose_sample.to_csv(
    OUT / "dose_defined_metadata.csv",
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# 12. Save protein lists and quantitative matrices
#
# IMPORTANT:
# - NA values remain NA.
# - Columns are renamed to UniqueSampleID for downstream safety.
# - Only control/low/high samples are exported in dose matrices.
# - No log transform / normalization is done here.
# ============================================================

dose_original_indices = np.where(
    dose_defined_mask
)[0]

dose_unique_ids = (
    sample.loc[
        dose_defined_mask,
        "UniqueSampleID"
    ]
    .tolist()
)

for threshold in THRESHOLDS:
    keep = (
        membership[
            f"all_doses_ge{threshold}pct"
        ]
        .to_numpy(
            dtype=bool
        )
    )

    protein_list = canonical_annotation.loc[keep].copy()

    for dose in DOSE_LEVELS:
        protein_list[
            f"{dose}_detected_samples"
        ] = (
            dose_detected_counts[
                dose
            ][
                keep
            ]
        )

        protein_list[
            f"{dose}_detection_rate"
        ] = (
            dose_detection_rates[
                dose
            ][
                keep
            ]
        )

    protein_list.to_csv(
        OUT
        /
        f"proteins_all_doses_ge{threshold}pct.csv",
        index=False,
        encoding="utf-8-sig"
    )

    matrix_values = quant[
        keep
    ][
        :,
        dose_original_indices
    ]

    expression = pd.DataFrame(
        matrix_values,
        columns=dose_unique_ids
    )

    expression.insert(
        0,
        "PG.ProteinGroups",
        protein_ids[
            keep
        ].to_numpy()
    )

    expression.to_csv(
        OUT
        /
        f"dose_expression_all_doses_ge{threshold}pct.csv.gz",
        index=False,
        compression="gzip",
        encoding="utf-8"
    )


# ============================================================
# 13. Explicit primary-set aliases
#
# These duplicate the >=70% outputs with obvious PRIMARY names
# to avoid accidentally using a sensitivity set downstream.
# ============================================================

primary_keep = (
    membership[
        f"all_doses_ge{PRIMARY_THRESHOLD}pct"
    ]
    .to_numpy(
        dtype=bool
    )
)

primary_proteins = pd.read_csv(
    OUT
    /
    f"proteins_all_doses_ge{PRIMARY_THRESHOLD}pct.csv"
)

primary_proteins.to_csv(
    OUT / "PRIMARY_dose_quantitative_proteins.csv",
    index=False,
    encoding="utf-8-sig"
)

primary_expression = pd.read_csv(
    OUT
    /
    f"dose_expression_all_doses_ge{PRIMARY_THRESHOLD}pct.csv.gz"
)

primary_expression.to_csv(
    OUT / "PRIMARY_dose_quantitative_expression.csv.gz",
    index=False,
    compression="gzip",
    encoding="utf-8"
)


# ============================================================
# 14. Internal validation
# ============================================================

# Threshold sets must be nested:
# >=80% subset of >=70% subset of >=60% subset of >=50%.
previous_mask = None
previous_threshold = None

for threshold in THRESHOLDS:
    mask = (
        membership[
            f"all_doses_ge{threshold}pct"
        ]
        .to_numpy(
            dtype=bool
        )
    )

    if previous_mask is not None:
        if np.any(
            mask
            &
            ~previous_mask
        ):
            raise AssertionError(
                f">={threshold}% set is not a subset of "
                f">={previous_threshold}% set."
            )

    previous_mask = mask
    previous_threshold = threshold


# Every retained protein must satisfy the criterion in every dose.
for threshold in THRESHOLDS:
    keep = (
        membership[
            f"all_doses_ge{threshold}pct"
        ]
        .to_numpy(
            dtype=bool
        )
    )

    for dose in DOSE_LEVELS:
        n = int(
            dose_counts[
                dose
            ]
        )

        counts = dose_detected_counts[
            dose
        ][
            keep
        ]

        if not np.all(
            counts
            *
            100
            >=
            threshold
            *
            n
        ):
            raise AssertionError(
                f"Threshold validation failed: "
                f"{dose}, >= {threshold}%."
            )


# NA must remain NA in primary matrix.
primary_original = quant[
    primary_keep
][
    :,
    dose_original_indices
]

primary_saved = (
    primary_expression.iloc[
        :,
        1:
    ]
    .to_numpy(
        dtype=float
    )
)

if not np.array_equal(
    np.isnan(
        primary_original
    ),
    np.isnan(
        primary_saved
    )
):
    raise AssertionError(
        "Missing-value pattern changed during export."
    )

observed_mask = np.isfinite(
    primary_original
)

if not np.allclose(
    primary_original[
        observed_mask
    ],
    primary_saved[
        observed_mask
    ],
    rtol=0,
    atol=0
):
    raise AssertionError(
        "Observed quantitative values changed during export."
    )


# ============================================================
# 15. Human-readable report
# ============================================================

dose_counts_text = "\n".join([
    (
        f"- {dose}: "
        f"{int(dose_counts[dose])} samples"
    )
    for dose in DOSE_LEVELS
])

summary_text = threshold_summary[
    [
        "threshold_pct",
        "protein_groups",
        "missing_pct",
        "control_missing_pct",
        "low_missing_pct",
        "high_missing_pct",
        "is_primary"
    ]
].copy()

for col in [
    "missing_pct",
    "control_missing_pct",
    "low_missing_pct",
    "high_missing_pct"
]:
    summary_text[col] = (
        summary_text[col]
        .map(
            lambda x:
                f"{x:.2f}"
        )
    )


def markdown_table(frame):
    return (
        "| "
        +
        " | ".join(
            map(
                str,
                frame.columns
            )
        )
        +
        " |\n| "
        +
        " | ".join(
            [
                "---"
            ]
            *
            len(
                frame.columns
            )
        )
        +
        " |\n"
        +
        "\n".join(
            "| "
            +
            " | ".join(
                map(
                    str,
                    row
                )
            )
            +
            " |"
            for row in frame.itertuples(
                index=False,
                name=None
            )
        )
    )


report = f"""# Dose-wise quantitative filtering

## Fixed analysis rule

Primary scientific grouping:
control / low / high.

Primary quantitative protein set:
a protein must be detected in at least {PRIMARY_THRESHOLD}% of samples
within EACH of control, low, and high.

Sensitivity thresholds:
{", ".join(str(x) + "%" for x in THRESHOLDS if x != PRIMARY_THRESHOLD)}.

Missing values are retained as NA.
No imputation, no NA-to-zero conversion, no normalization,
no batch correction, and no differential analysis are performed here.

## Dose sample counts

{dose_counts_text}

Dose-defined samples:
{int(dose_defined_mask.sum())}

Samples excluded from dose-defined matrices because TREAT1 is not
control/low/high:
{int((~dose_defined_mask).sum())}

## Exact minimum detected samples

{markdown_table(threshold_requirements)}

## Protein sets and residual missingness

{markdown_table(summary_text)}

## Primary outputs

- PRIMARY_dose_quantitative_proteins.csv
- PRIMARY_dose_quantitative_expression.csv.gz
- dose_defined_metadata.csv

The primary expression matrix contains only real observed quantitative
values plus the original NA pattern. No missing values were created,
replaced, or imputed.

## Sensitivity outputs

For each threshold in {THRESHOLDS}:
- proteins_all_doses_geXXpct.csv
- dose_expression_all_doses_geXXpct.csv.gz

## Validation

- Input SHA256 hashes match the existing QC audit.
- Matrix headers match the locked sample mapping.
- Protein IDs are unique.
- Threshold sets are nested.
- Every retained protein meets the threshold in every dose group.
- Saved primary NA positions exactly reproduce the original NA pattern.
- Saved observed quantitative values exactly reproduce the original values.
"""

(
    OUT
    /
    "dose_quantitative_filtering_report.md"
).write_text(
    report,
    encoding="utf-8"
)


# ============================================================
# 16. Console output
# ============================================================

print(
    "\n============================================================"
)

print(
    "DOSE-WISE QUANTITATIVE FILTERING"
)

print(
    "============================================================"
)

print(
    "\nDose sample counts:"
)

print(
    dose_count_table.to_string(
        index=False
    )
)

print(
    "\nExact threshold requirements:"
)

print(
    threshold_requirements.to_string(
        index=False
    )
)

print(
    "\nProtein-set summary:"
)

print(
    threshold_summary.to_string(
        index=False
    )
)

primary_n = int(
    primary_keep.sum()
)

print(
    "\n============================================================"
)

print(
    "PRIMARY SET"
)

print(
    "============================================================"
)

print(
    f"Rule: control / low / high EACH >= "
    f"{PRIMARY_THRESHOLD}% detection"
)

print(
    f"Primary proteins: {primary_n}"
)

print(
    "Missing values: RETAINED AS NA"
)

print(
    "Imputation: NONE"
)

print(
    "NA -> 0: NO"
)

print(
    "\nPASS: dose-wise filtering completed and validated."
)

# v2.2 standalone displays of the existing filtering summaries.
import matplotlib
matplotlib.use("Agg")
from nature_plotting import new_figure, save as save_nature, EXPOSURE_LABELS, EXPOSURE_COLORS
fig, ax = new_figure()
ax.bar([EXPOSURE_LABELS[d] for d in dose_count_table.dose], dose_count_table.samples,
       color=[EXPOSURE_COLORS[d] for d in dose_count_table.dose], width=0.65)
ax.set(ylabel="Samples", title="Exposure-defined sample counts")
save_nature(fig, OUT, "Quantitative_filter_sample_counts", dose_count_table)
for column, ylabel, name in [("protein_groups", "Retained protein groups", "proteins"),
                              ("missing_pct", "Missing matrix entries (%)", "missingness")]:
    fig, ax = new_figure()
    ax.plot(threshold_summary.threshold_pct, threshold_summary[column], "o-", color="#3178A5", linewidth=1)
    ax.axvline(PRIMARY_THRESHOLD, color="#595959", linestyle="--", linewidth=0.7, label="Primary threshold")
    ax.set(xlabel="Required detection in every exposure group (%)", ylabel=ylabel,
           title="Quantitative filter sensitivity")
    ax.set_xticks(threshold_summary.threshold_pct)
    ax.set_ylim(bottom=0)
    ax.legend()
    save_nature(fig, OUT, f"Quantitative_filter_{name}", threshold_summary)

# Complete the two Stage 05 mother-data branches. These helpers are source
# modules owned by this stage, not independently numbered pipeline stages.
runpy.run_path(str(OUT / "stage05_normalization_helper.py"), run_name="__main__")
from stage05_detection_helper import main as build_detection_mother_data
build_detection_mother_data()
