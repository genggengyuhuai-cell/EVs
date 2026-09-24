"""Nature figure conventions for the existing Python workflow, v2.2.

One figure per question; no composite canvas or cross-language rendering.
Only plotting helpers: no data loading, filtering, model fitting or file hashes.
"""
from pathlib import Path
import textwrap
import matplotlib.pyplot as plt

EXPOSURE_LABELS = {"control": "Control", "low": "Short exposure", "high": "Long exposure",
                   "unknown": "Unknown", "missing": "Missing"}
EXPOSURE_COLORS = {"control": "#595959", "low": "#3178A5", "high": "#C78132",
                   "unknown": "#A7ADB2", "missing": "#D8D8D8"}


def configure():
    plt.rcParams.update({
        "font.family": "sans-serif", "font.sans-serif": ["Arial", "Helvetica", "DejaVu Sans"],
        "font.size": 8, "axes.titlesize": 10, "axes.labelsize": 8,
        "xtick.labelsize": 7, "ytick.labelsize": 7, "legend.fontsize": 7,
        "svg.fonttype": "none", "pdf.fonttype": 42, "legend.frameon": False,
        "axes.spines.top": False, "axes.spines.right": False, "axes.linewidth": 0.6,
        "figure.facecolor": "white", "axes.facecolor": "white", "savefig.facecolor": "white",
    })


def new_figure(width_mm=170, height_mm=115):
    configure()
    return plt.subplots(figsize=(width_mm / 25.4, height_mm / 25.4), layout="constrained")


def save(fig, root, name, source=None):
    """Export a genuine standalone figure; never crop panels from a composite."""
    out = Path(root) / "figures_nature_v2.2"
    out.mkdir(parents=True, exist_ok=True)
    for ax in fig.axes:
        # Colorbar axes have no title or legend and remain part of their one plot.
        title = ax.get_title(loc="left") or ax.get_title()
        if title:
            ax.set_title("")  # Clear the original centered title before left alignment.
            ax.set_title(textwrap.fill(title, 65), loc="left", fontsize=10, pad=12)
        legend = ax.get_legend()
        if legend is not None:
            handles, labels = ax.get_legend_handles_labels()
            if labels:
                ax.legend(handles, labels, loc="upper center", bbox_to_anchor=(0.5, -0.20),
                          ncol=min(3, len(labels)), fontsize=7, frameon=False)
        for text in ax.get_xticklabels() + ax.get_yticklabels() + ax.texts:
            text.set_fontsize(max(6, text.get_fontsize()))
    for extension in ("pdf", "svg", "png"):
        fig.savefig(out / f"{name}.{extension}", dpi=600, bbox_inches="tight", pad_inches=0.08)
    if source is not None:
        source.to_csv(out / f"{name}_source.csv", index=False)
    plt.close(fig)


def save_series(figures, root, names, sources=None):
    if len(figures) != len(names):
        raise ValueError("Each standalone figure needs its own output name")
    if sources is not None and len(figures) != len(sources):
        raise ValueError("Each standalone figure needs matching source data")
    if sources is None:
        sources = [None] * len(figures)
    for fig, name, source in zip(figures, names, sources):
        save(fig, root, name, source)
