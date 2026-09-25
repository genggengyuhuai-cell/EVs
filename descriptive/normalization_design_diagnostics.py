"""Normalization and design-matrix diagnostics for the PRIMARY dose proteomics set.

Inputs:
    PRIMARY_dose_quantitative_expression.csv.gz
    dose_defined_metadata.csv

Primary candidate:
    PG.Quantity -> log2(PG.Quantity), no extra normalization.

Sensitivity:
    log2(PG.Quantity) -> sample-wise median normalization.

This script does NOT impute, convert NA to zero, remove batch effects,
run ComBat, remove samples/proteins, or run limma.
"""

from pathlib import Path
import numpy as np
import pandas as pd
import matplotlib
matplotlib.use("Agg")
import matplotlib.pyplot as plt
from nature_plotting import new_figure, save as save_nature, save_series, EXPOSURE_LABELS

OUT = Path(__file__).resolve().parent

EXPR_FILE = OUT / "PRIMARY_dose_quantitative_expression.csv.gz"
META_FILE = OUT / "dose_defined_metadata.csv"

LOG2_FILE = OUT / "PRIMARY_dose_log2_expression.csv.gz"
MEDIAN_NORM_FILE = OUT / "SENSITIVITY_dose_log2_median_normalized_expression.csv.gz"

DOSE_LEVELS = ["control", "low", "high"]
CONDITION_LEVELS = ["high_stress", "high_temperature"]
CONDITION_DISPLAY_LABELS = {
    "high_stress": "高海拔",
    "high_temperature": "湿热"
}


def safe_median(x):
    x = np.asarray(x, dtype=float)
    x = x[np.isfinite(x)]
    return np.nan if len(x) == 0 else float(np.median(x))


def safe_quantile(x, q):
    x = np.asarray(x, dtype=float)
    x = x[np.isfinite(x)]
    return np.nan if len(x) == 0 else float(np.quantile(x, q))


def save_figure(fig, name):
    save_nature(fig, OUT, name)


def panel(ax, letter, title):
    ax.set_title(title, loc="left", pad=8)


def markdown_table(df):
    out = df.copy()
    for col in out.select_dtypes(include=["float"]).columns:
        out[col] = out[col].map(lambda v: "" if pd.isna(v) else f"{v:.4f}")
    lines = [
        "| " + " | ".join(map(str, out.columns)) + " |",
        "| " + " | ".join(["---"] * len(out.columns)) + " |"
    ]
    lines += [
        "| " + " | ".join(map(str, row)) + " |"
        for row in out.itertuples(index=False, name=None)
    ]
    return "\n".join(lines)


# ============================================================
# 1. Read inputs and validate alignment
# ============================================================

for path in [EXPR_FILE, META_FILE]:
    if not path.is_file():
        raise FileNotFoundError(f"Missing required input: {path}")

expr = pd.read_csv(EXPR_FILE)
meta = pd.read_csv(META_FILE, keep_default_na=False)

if "PG.ProteinGroups" not in expr.columns:
    raise ValueError("Expression matrix lacks PG.ProteinGroups.")

required_meta = ["UniqueSampleID", "TREAT1_clean", "condition", "group", "进样时间"]
missing_meta = [c for c in required_meta if c not in meta.columns]
if missing_meta:
    raise ValueError(f"Metadata missing columns: {missing_meta}")

if not meta["UniqueSampleID"].is_unique:
    raise ValueError("UniqueSampleID is not unique.")

if expr["PG.ProteinGroups"].duplicated().any():
    raise ValueError("PG.ProteinGroups is not unique.")

sample_columns = expr.columns[1:].tolist()
if sample_columns != meta["UniqueSampleID"].tolist():
    raise ValueError("Expression columns and metadata UniqueSampleID are not aligned.")

if set(meta["TREAT1_clean"]) != set(DOSE_LEVELS):
    raise ValueError("Metadata must contain exactly control/low/high.")

condition_aliases = {"高海拔": "high_stress", "湿热": "high_temperature"}
meta = meta.copy()
meta["condition"] = meta["condition"].replace(condition_aliases)

if not set(meta["condition"]).issubset(set(CONDITION_LEVELS)):
    raise ValueError("Unexpected condition labels.")

meta["MS_batch_proxy"] = meta["进样时间"].astype(str)


# ============================================================
# 2. Numeric matrix and log2 transform
# ============================================================

x = expr.iloc[:, 1:].apply(pd.to_numeric, errors="raise").to_numpy(dtype=float)

bad = np.isfinite(x) & (x <= 0)
if bad.any():
    raise ValueError(f"Found {int(bad.sum())} finite non-positive values.")

observed = np.isfinite(x)
log2_x = np.full_like(x, np.nan, dtype=float)
log2_x[observed] = np.log2(x[observed])

log2_expr = pd.DataFrame(log2_x, columns=sample_columns)
log2_expr.insert(0, "PG.ProteinGroups", expr["PG.ProteinGroups"].to_numpy())
log2_expr.to_csv(LOG2_FILE, index=False, compression="gzip", encoding="utf-8")


# ============================================================
# 3. Median-normalized sensitivity matrix
# ============================================================

sample_medians = np.array(
    [safe_median(log2_x[:, j]) for j in range(log2_x.shape[1])],
    dtype=float
)

if np.isnan(sample_medians).any():
    raise ValueError("At least one sample has no observed values.")

global_median = float(np.median(sample_medians))
median_norm_x = log2_x - sample_medians[None, :] + global_median

if not np.array_equal(np.isnan(median_norm_x), np.isnan(log2_x)):
    raise AssertionError("Median normalization changed the NA pattern.")

median_norm_expr = pd.DataFrame(median_norm_x, columns=sample_columns)
median_norm_expr.insert(0, "PG.ProteinGroups", expr["PG.ProteinGroups"].to_numpy())
median_norm_expr.to_csv(
    MEDIAN_NORM_FILE, index=False, compression="gzip", encoding="utf-8"
)


# ============================================================
# 4. Sample diagnostics
# ============================================================

sample_diag = meta[
    ["UniqueSampleID", "TREAT1_clean", "condition", "group", "MS_batch_proxy"]
].copy()

sample_diag["observed_proteins"] = observed.sum(axis=0)
sample_diag["missing_pct"] = (~observed).mean(axis=0) * 100
sample_diag["log2_median"] = sample_medians
sample_diag["log2_q25"] = [safe_quantile(log2_x[:, j], 0.25) for j in range(log2_x.shape[1])]
sample_diag["log2_q75"] = [safe_quantile(log2_x[:, j], 0.75) for j in range(log2_x.shape[1])]
sample_diag["log2_iqr"] = sample_diag["log2_q75"] - sample_diag["log2_q25"]
sample_diag["median_norm_median"] = [
    safe_median(median_norm_x[:, j]) for j in range(median_norm_x.shape[1])
]
sample_diag["median_shift_applied"] = global_median - sample_medians

sample_diag_output = sample_diag.copy()
sample_diag_output["condition"] = sample_diag_output["condition"].map(
    CONDITION_DISPLAY_LABELS
)
sample_diag_output.to_csv(
    OUT / "normalization_sample_diagnostics.csv",
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# 5. Group summaries
# ============================================================

records = []
for field in ["TREAT1_clean", "condition", "group", "MS_batch_proxy"]:
    for category, sub in sample_diag.groupby(field, sort=True, dropna=False):
        for metric in [
            "observed_proteins",
            "missing_pct",
            "log2_median",
            "log2_iqr",
            "median_shift_applied"
        ]:
            v = sub[metric].to_numpy(dtype=float)
            records.append({
                "level": field,
                "category": str(category),
                "samples": len(sub),
                "metric": metric,
                "median": safe_median(v),
                "q25": safe_quantile(v, 0.25),
                "q75": safe_quantile(v, 0.75),
                "min": float(np.nanmin(v)),
                "max": float(np.nanmax(v)),
                "mean": float(np.nanmean(v))
            })

group_summary = pd.DataFrame(records)
group_summary_output = group_summary.copy()
condition_rows = group_summary_output["level"].eq("condition")
group_summary_output.loc[condition_rows, "category"] = (
    group_summary_output.loc[condition_rows, "category"].map(
        CONDITION_DISPLAY_LABELS
    )
)
group_summary_output.to_csv(
    OUT / "normalization_group_summaries.csv",
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# 6. Plots
# ============================================================

plt.rcParams.update({
    "font.family": "sans-serif",
    "font.sans-serif": ["Microsoft YaHei", "SimHei", "Arial", "DejaVu Sans"],
    "font.size": 7,
    "axes.titlesize": 8,
    "axes.labelsize": 7,
    "xtick.labelsize": 6,
    "ytick.labelsize": 6,
    "legend.fontsize": 6,
    "svg.fonttype": "none",
    "pdf.fonttype": 42,
    "axes.spines.top": False,
    "axes.spines.right": False
})


def horizontal_boxplot(
    ax, frame, field, metric, xlabel, title, order=None, display_labels=None
):
    if order is None:
        groups = list(frame.groupby(field, sort=True))
    else:
        groups = [(name, frame.loc[frame[field] == name]) for name in order if (frame[field] == name).any()]

    vals = [sub[metric].to_numpy(dtype=float) for _, sub in groups]
    bp = ax.boxplot(
        vals,
        orientation="horizontal",
        patch_artist=True,
        widths=0.55,
        showfliers=True,
        flierprops={"marker": ".", "markersize": 2},
        medianprops={"linewidth": 0.8}
    )

    for box in bp["boxes"]:
        box.set_facecolor("#B7C9D6")

    ax.set_yticks(
        np.arange(1, len(groups) + 1),
        [
            f"{(display_labels or {}).get(name, name)} (n={len(sub)})"
            for name, sub in groups
        ]
    )
    ax.invert_yaxis()
    ax.set_xlabel(xlabel)
    ax.set_title(title, loc="left", pad=8)


order_df = sample_diag.copy()
order_df["_dose_order"] = pd.Categorical(
    order_df["TREAT1_clean"],
    categories=DOSE_LEVELS,
    ordered=True
)
order_df = order_df.sort_values(
    ["MS_batch_proxy", "condition", "_dose_order", "UniqueSampleID"]
)
ordered_indices = order_df.index.to_numpy()

normalization_figures, normalization_axes = zip(*(new_figure(183, 125) for _ in range(4)))
axs = np.array(normalization_axes, dtype=object).reshape(2, 2)

ax = axs[0, 0]
box_data = [
    log2_x[np.isfinite(log2_x[:, idx]), idx]
    for idx in ordered_indices
]
bp = ax.boxplot(
    box_data,
    positions=np.arange(1, len(box_data) + 1),
    widths=0.45,
    showfliers=False,
    patch_artist=True,
    medianprops={"linewidth": 0.6}
)
for box in bp["boxes"]:
    box.set_facecolor("#B7C9D6")
ax.set_xticks([])
ax.set_xlabel("Dose-defined samples ordered by MS batch proxy")
ax.set_ylabel("Observed PG.Quantity (log2)")
panel(ax, "a", "Per-sample observed log2 distributions")

ax = axs[0, 1]
horizontal_boxplot(
    ax, sample_diag, "MS_batch_proxy", "log2_median",
    "Sample median observed abundance (log2)",
    "Sample medians by MS batch proxy"
)

ax = axs[1, 0]
horizontal_boxplot(
    ax, sample_diag, "TREAT1_clean", "log2_median",
    "Sample median observed abundance (log2)",
    "Sample medians by dose",
    order=DOSE_LEVELS
)

ax = axs[1, 1]
horizontal_boxplot(
    ax, sample_diag, "condition", "log2_median",
    "Sample median observed abundance (log2)",
    "Sample medians by environment",
    order=CONDITION_LEVELS,
    display_labels=CONDITION_DISPLAY_LABELS
)

save_series(normalization_figures, OUT, ['Figure12_normalization_diagnostics', 'Figure12_median_by_date',
    'Figure12_median_by_exposure', 'Figure12_median_by_environment'])


normalization_sensitivity_figures, axs = zip(*(new_figure() for _ in range(2)))

ax = axs[0]
ax.scatter(
    sample_diag["log2_median"],
    sample_diag["median_shift_applied"],
    s=8,
    alpha=0.65,
    edgecolors="none"
)
ax.axhline(0, linewidth=0.7)
ax.set_xlabel("Original sample median (log2)")
ax.set_ylabel("Median-normalization shift applied")
panel(ax, "a", "Potential correction magnitude")

ax = axs[1]
ax.boxplot(
    [
        sample_diag["log2_median"].to_numpy(dtype=float),
        sample_diag["median_norm_median"].to_numpy(dtype=float)
    ],
    tick_labels=["Log2 only", "Median normalized"],
    widths=0.55,
    showfliers=True,
    flierprops={"marker": ".", "markersize": 2}
)
ax.set_ylabel("Sample median abundance (log2)")
panel(ax, "b", "Sample medians before and after sensitivity normalization")

save_series(normalization_sensitivity_figures, OUT,
    ['Figure13_median_normalization_sensitivity', 'Figure13_before_after_medians'])


# ============================================================
# 7. Complete-case PCA only; no imputation
# ============================================================

complete_case_mask = observed.all(axis=1)
complete_case_n = int(complete_case_mask.sum())
pca_variance = None

if complete_case_n >= 2:
    pca_matrix = log2_x[complete_case_mask].T
    pca_centered = pca_matrix - pca_matrix.mean(axis=0, keepdims=True)

    u, singular_values, vt = np.linalg.svd(pca_centered, full_matrices=False)

    if len(singular_values) >= 2:
        scores = u * singular_values[None, :]
        variances = singular_values ** 2
        explained = variances / variances.sum() * 100
        pca_variance = explained

        pca_scores = pd.DataFrame({
            "UniqueSampleID": sample_columns,
            "PC1": scores[:, 0],
            "PC2": scores[:, 1],
            "PC1_variance_pct": explained[0],
            "PC2_variance_pct": explained[1]
        })

        pca_scores = pca_scores.merge(
            meta[
                ["UniqueSampleID", "TREAT1_clean", "condition", "group", "MS_batch_proxy"]
            ],
            on="UniqueSampleID",
            how="left",
            validate="one_to_one"
        )

        pca_scores_output = pca_scores.copy()
        pca_scores_output["condition"] = pca_scores_output["condition"].map(
            CONDITION_DISPLAY_LABELS
        )
        pca_scores_output.to_csv(
            OUT / "complete_case_PCA_scores.csv",
            index=False,
            encoding="utf-8-sig"
        )

        pca_figures, axs = zip(*(new_figure() for _ in range(2)))

        ax = axs[0]
        markers = {"control": "o", "low": "s", "high": "^"}
        for dose in DOSE_LEVELS:
            sub = pca_scores.loc[pca_scores["TREAT1_clean"] == dose]
            ax.scatter(
                sub["PC1"], sub["PC2"],
                s=12,
                marker=markers[dose],
                alpha=0.65,
                label=EXPOSURE_LABELS[dose],
                edgecolors="none"
            )
        ax.set_xlabel(f"PC1 ({explained[0]:.2f}%)")
        ax.set_ylabel(f"PC2 ({explained[1]:.2f}%)")
        ax.legend(frameon=False)
        panel(ax, "a", f"Complete-case PCA by dose (n={complete_case_n} proteins)")

        ax = axs[1]
        for batch in sorted(pca_scores["MS_batch_proxy"].unique()):
            sub = pca_scores.loc[pca_scores["MS_batch_proxy"] == batch]
            ax.scatter(
                sub["PC1"], sub["PC2"],
                s=10,
                alpha=0.55,
                label=batch,
                edgecolors="none"
            )
        ax.set_xlabel(f"PC1 ({explained[0]:.2f}%)")
        ax.set_ylabel(f"PC2 ({explained[1]:.2f}%)")
        ax.legend(frameon=False, fontsize=5, ncol=2)
        panel(ax, "b", "Complete-case PCA by MS batch proxy")

        save_series(pca_figures, OUT, ['Figure14_complete_case_PCA', 'Figure14_PCA_acquisition_date'])


# ============================================================
# 8. Design matrices
# ============================================================

def treatment_dummies(series, levels, reference, prefix):
    categorical = pd.Categorical(series, categories=levels, ordered=True)
    dummy = pd.get_dummies(categorical, prefix=prefix, dtype=float)
    reference_column = f"{prefix}_{reference}"

    if reference_column not in dummy.columns:
        raise ValueError(f"Reference column missing: {reference_column}")

    return dummy.drop(columns=[reference_column])


def build_design(model_name):
    pieces = [
        pd.DataFrame({"Intercept": np.ones(len(meta), dtype=float)})
    ]

    dose_dummy = treatment_dummies(
        meta["TREAT1_clean"],
        DOSE_LEVELS,
        "control",
        "dose"
    )

    condition_dummy = treatment_dummies(
        meta["condition"],
        CONDITION_LEVELS,
        "high_stress",
        "condition"
    )

    if model_name == "A_dose_condition":
        pieces += [dose_dummy, condition_dummy]

    elif model_name == "B_dose_condition_batch":
        batch_levels = sorted(meta["MS_batch_proxy"].unique())
        batch_dummy = treatment_dummies(
            meta["MS_batch_proxy"],
            batch_levels,
            batch_levels[0],
            "batch"
        )
        pieces += [dose_dummy, condition_dummy, batch_dummy]

    elif model_name == "C_dose_condition_interaction":
        pieces += [dose_dummy, condition_dummy]

        interactions = {}
        for dose_col in dose_dummy.columns:
            for condition_col in condition_dummy.columns:
                name = f"{dose_col}_X_{condition_col}"
                interactions[name] = (
                    dose_dummy[dose_col].to_numpy()
                    *
                    condition_dummy[condition_col].to_numpy()
                )

        if interactions:
            pieces.append(pd.DataFrame(interactions))

    else:
        raise ValueError(f"Unknown model: {model_name}")

    return pd.concat(pieces, axis=1)


design_summary_records = []
design_column_records = []

for model_name in [
    "A_dose_condition",
    "B_dose_condition_batch",
    "C_dose_condition_interaction"
]:
    design = build_design(model_name)
    matrix = design.to_numpy(dtype=float)

    rank = int(np.linalg.matrix_rank(matrix))
    singular_values = np.linalg.svd(matrix, compute_uv=False)

    min_singular = float(singular_values[-1])
    max_singular = float(singular_values[0])
    condition_number = np.inf if min_singular == 0 else max_singular / min_singular

    design_summary_records.append({
        "model": model_name,
        "samples": design.shape[0],
        "columns": design.shape[1],
        "rank": rank,
        "full_rank": rank == design.shape[1],
        "condition_number": condition_number,
        "minimum_singular_value": min_singular
    })

    for column in design.columns:
        v = design[column].to_numpy(dtype=float)
        design_column_records.append({
            "model": model_name,
            "column": column,
            "mean": float(v.mean()),
            "sd": float(v.std(ddof=0)),
            "nonzero_samples": int((v != 0).sum())
        })

    design.to_csv(
        OUT / f"design_{model_name}.csv",
        index=False,
        encoding="utf-8-sig"
    )

design_summary = pd.DataFrame(design_summary_records)
design_summary.to_csv(
    OUT / "design_matrix_diagnostics.csv",
    index=False,
    encoding="utf-8-sig"
)

pd.DataFrame(design_column_records).to_csv(
    OUT / "design_matrix_columns.csv",
    index=False,
    encoding="utf-8-sig"
)


# ============================================================
# 9. Confounding tables
# ============================================================

dose_by_condition = pd.crosstab(
    meta["condition"],
    meta["TREAT1_clean"]
).reindex(columns=DOSE_LEVELS, fill_value=0)

dose_by_batch = pd.crosstab(
    meta["MS_batch_proxy"],
    meta["TREAT1_clean"]
).reindex(columns=DOSE_LEVELS, fill_value=0)

condition_by_batch = pd.crosstab(
    meta["MS_batch_proxy"],
    meta["condition"]
).reindex(columns=CONDITION_LEVELS, fill_value=0)

group_by_batch = pd.crosstab(
    meta["group"],
    meta["MS_batch_proxy"]
)

group_by_dose = pd.crosstab(
    meta["group"],
    meta["TREAT1_clean"]
).reindex(columns=DOSE_LEVELS, fill_value=0)

with pd.ExcelWriter(
    OUT / "design_confounding_tables.xlsx",
    engine="openpyxl"
) as writer:
    dose_by_condition.rename(index=CONDITION_DISPLAY_LABELS).to_excel(
        writer, sheet_name="condition_by_dose"
    )
    dose_by_batch.to_excel(writer, sheet_name="batch_by_dose")
    condition_by_batch.rename(columns=CONDITION_DISPLAY_LABELS).to_excel(
        writer, sheet_name="batch_by_condition"
    )
    group_by_batch.to_excel(writer, sheet_name="group_by_batch")
    group_by_dose.to_excel(writer, sheet_name="group_by_dose")


design_figures, axs = zip(*(new_figure(183, 125) for _ in range(2)))

ax = axs[0]
arr = dose_by_batch.to_numpy(dtype=int)
im = ax.imshow(arr, aspect="auto", cmap="Blues", vmin=0, vmax=max(1, arr.max()))
ax.set_xticks(range(len(dose_by_batch.columns)), dose_by_batch.columns)
ax.set_yticks(range(len(dose_by_batch.index)), dose_by_batch.index)
for i in range(arr.shape[0]):
    for j in range(arr.shape[1]):
        ax.text(j, i, str(arr[i, j]), ha="center", va="center", fontsize=7)
ax.set_xlabel("Dose")
ax.set_ylabel("MS batch proxy")
panel(ax, "a", "MS batch proxy × dose")
ax.figure.colorbar(im, ax=ax, shrink=0.8, pad=0.02, label="Samples")

ax = axs[1]
arr = condition_by_batch.to_numpy(dtype=int)
im = ax.imshow(arr, aspect="auto", cmap="Blues", vmin=0, vmax=max(1, arr.max()))
ax.set_xticks(
    range(len(condition_by_batch.columns)),
    [CONDITION_DISPLAY_LABELS[x] for x in condition_by_batch.columns],
    rotation=20,
    ha="right"
)
ax.set_yticks(range(len(condition_by_batch.index)), condition_by_batch.index)
for i in range(arr.shape[0]):
    for j in range(arr.shape[1]):
        ax.text(j, i, str(arr[i, j]), ha="center", va="center", fontsize=7)
ax.set_xlabel("Environment")
ax.set_ylabel("MS batch proxy")
panel(ax, "b", "MS batch proxy × environment")
ax.figure.colorbar(im, ax=ax, shrink=0.8, pad=0.02, label="Samples")

save_series(design_figures, OUT, ['Figure15_design_overlap', 'Figure15_date_environment_overlap'])


# ============================================================
# 10. Report
# ============================================================

primary_missing_pct = float((~observed).mean() * 100)
median_range = (
    float(sample_diag["log2_median"].min()),
    float(sample_diag["log2_median"].max())
)
shift_abs_median = float(np.median(np.abs(sample_diag["median_shift_applied"])))
shift_abs_max = float(np.max(np.abs(sample_diag["median_shift_applied"])))

report = f"""# Normalization and design diagnostics

## Input
- {EXPR_FILE.name}
- {META_FILE.name}

Primary set:
- proteins: {log2_x.shape[0]}
- dose-defined samples: {log2_x.shape[1]}
- residual missingness: {primary_missing_pct:.2f}%

## Primary normalization candidate
PG.Quantity -> log2(PG.Quantity)

No additional normalization is applied to the primary candidate matrix.

## Sensitivity normalization candidate
log2(PG.Quantity) -> sample-wise median normalization

Per-sample original log2 median range:
{median_range[0]:.4f} to {median_range[1]:.4f}

Median absolute sensitivity shift:
{shift_abs_median:.4f}

Maximum absolute sensitivity shift:
{shift_abs_max:.4f}

NA pattern is preserved exactly.

## Complete-case PCA
Complete-case proteins across all dose-defined samples:
{complete_case_n}

PCA is diagnostic only and uses no imputation.

## Candidate design matrices
{markdown_table(design_summary)}

Models:
- A: dose + environment
- B: dose + environment + MS_batch_proxy
- C: dose * environment

Notes:
- MS_batch_proxy is the run-date proxy, not a confirmed technical batch ID.
- Region is deliberately not included with environment because region is nested within environment.
- full_rank=True means algebraically estimable.
- A high condition number can still indicate near-collinearity.

## Outputs
- {LOG2_FILE.name}
- {MEDIAN_NORM_FILE.name}
- normalization_sample_diagnostics.csv
- normalization_group_summaries.csv
- design_matrix_diagnostics.csv
- design_matrix_columns.csv
- design_confounding_tables.xlsx
- Figure12_normalization_diagnostics
- Figure13_median_normalization_sensitivity
- Figure14_complete_case_PCA, if complete-case PCA is possible
- Figure15_design_overlap

## Boundaries
No imputation.
No NA-to-zero conversion.
No batch correction.
No ComBat.
No removeBatchEffect.
No limma.
No sample/protein exclusion.

The next step is to choose the final normalization and limma design only after
reviewing sample-level global shifts, PCA, design rank, and batch overlap.
"""

(OUT / "normalization_design_diagnostics_report.md").write_text(
    report,
    encoding="utf-8"
)


# ============================================================
# 11. Console
# ============================================================

print("\n============================================================")
print("NORMALIZATION + DESIGN DIAGNOSTICS")
print("============================================================")
print(f"Proteins: {log2_x.shape[0]}")
print(f"Dose-defined samples: {log2_x.shape[1]}")
print(f"Residual missingness: {primary_missing_pct:.2f}%")
print("\nPrimary candidate: PG.Quantity -> log2 only")
print("Sensitivity: log2 -> sample-wise median normalization")
print(f"\nSample log2 median range: {median_range[0]:.4f} to {median_range[1]:.4f}")
print(f"Median |normalization shift|: {shift_abs_median:.4f}")
print(f"Maximum |normalization shift|: {shift_abs_max:.4f}")
print(f"\nComplete-case proteins for PCA: {complete_case_n}")
print("\nCandidate design matrices:")
print(design_summary.to_string(index=False))
print("\nPASS: diagnostics completed.")
print("No imputation, batch correction, or limma analysis was performed.")
