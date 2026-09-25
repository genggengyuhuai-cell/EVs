"""Dependency-safe orchestration only; contains no scientific logic."""

from pathlib import Path
import shutil
import subprocess
import sys


SCRIPT_DIR = Path(__file__).resolve().parent
PIPELINE = (
    "01_describe_proteomics.py",
    "02_detection_gradient.py",
    "03_design_composition.py",
    "04_complete_four_layers.py",
    "05_dose_quantitative_filtering.py",
    "06_covariate_QC.R",
    "07_limma_dose_analysis.R",
    "08a_limma_core_figures.R",
    "08b_limma_robustness.R",
    "08c_run_replication.R",
    "09_detection_pattern_analysis.R",
    "08d_integrated_results.R",
    "10a_DEP_characterization.R",
    "10b_DEP_effect_size_summary.R",
    "11a_dose_pattern_classification.R",
    "11b_protein_clustering.R",
    "12_pattern_protein_annotation.R",
)


def command_for(script: Path) -> list[str]:
    if script.suffix.lower() == ".py":
        return [sys.executable, str(script)]
    rscript = shutil.which("Rscript")
    if rscript is None:
        raise RuntimeError("Rscript was not found on PATH.")
    return [rscript, "--vanilla", str(script)]


def main() -> int:
    for index, name in enumerate(PIPELINE, start=1):
        script = SCRIPT_DIR / name
        if not script.is_file():
            print(f"FAIL [{index}/{len(PIPELINE)}] missing script: {script}", flush=True)
            return 1
        print(f"START [{index}/{len(PIPELINE)}] {name}", flush=True)
        try:
            completed = subprocess.run(command_for(script), cwd=SCRIPT_DIR, check=False)
        except Exception as exc:
            print(f"FAIL  [{index}/{len(PIPELINE)}] {name}: {exc}", flush=True)
            return 1
        if completed.returncode != 0:
            print(f"FAIL  [{index}/{len(PIPELINE)}] {name} (exit status {completed.returncode})", flush=True)
            return completed.returncode or 1
        print(f"PASS  [{index}/{len(PIPELINE)}] {name}", flush=True)
    return 0


if __name__ == "__main__":
    sys.exit(main())
