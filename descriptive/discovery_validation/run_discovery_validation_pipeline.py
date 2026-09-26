#!/usr/bin/env python3
"""Single-stage dispatcher for the prospective pipeline; never chains stages."""
from __future__ import annotations
import argparse, subprocess, sys
from pathlib import Path

BASE = Path(__file__).resolve().parent
CODE = BASE / "code"
STAGES = {
    "D01": [sys.executable, str(BASE / "D01_discovery_eligibility.py")],
    "D02": ["Rscript", str(CODE / "D02_discovery_primary.R")],
    "D03": ["Rscript", str(CODE / "D03_candidate_lock.R")],
    "D04": ["Rscript", str(CODE / "D04_dose_trajectory.R")],
    "D05": ["Rscript", str(CODE / "D05_environment_specific.R")],
    "D06": ["Rscript", str(CODE / "D06_environment_interaction.R")],
    "D07": ["Rscript", str(CODE / "D07_site_robustness.R")],
    "D08": [sys.executable, str(CODE / "D08_prepare_validation.py")],
    "D09": ["Rscript", str(CODE / "D09_evidence_layers.R")],
    "D10": ["Rscript", str(CODE / "D10_integrated_biology.R")],
}

def main() -> None:
    p = argparse.ArgumentParser(description="Run exactly one authorized prospective stage")
    p.add_argument("--stage", required=True, choices=STAGES)
    args = p.parse_args()
    if args.stage == "D08" and not (BASE / "VALIDATION_UNLOCKED.txt").is_file():
        raise SystemExit("VALIDATION_LOCKED: investigator-created VALIDATION_UNLOCKED.txt is required; no bypass exists")
    subprocess.run(STAGES[args.stage], cwd=BASE.parents[1], check=True)

if __name__ == "__main__": main()
