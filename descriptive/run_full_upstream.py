"""Future full-upstream entry point; explicit whitelist, no dynamic discovery.

Sequence:
    run_all.py
    normalization_design_diagnostics.py
    dose_restricted_detection.py

This wrapper does not clean or delete outputs. Existing output-directory
guards in the called scripts remain authoritative.
"""
from pathlib import Path
import subprocess
import sys


HERE = Path(__file__).resolve().parent
UPSTREAM_SCRIPTS = (
    "run_all.py",
    "normalization_design_diagnostics.py",
    "dose_restricted_detection.py",
)


def main():
    for script_name in UPSTREAM_SCRIPTS:
        script_path = HERE / script_name
        if not script_path.is_file():
            raise FileNotFoundError(f"Whitelisted upstream script is missing: {script_path}")
        print(f"Running {script_name}", flush=True)
        subprocess.run(
            [sys.executable, "-X", "utf8", "-u", str(script_path)],
            cwd=HERE,
            check=True,
        )
    return 0


if __name__ == "__main__":
    sys.exit(main())
