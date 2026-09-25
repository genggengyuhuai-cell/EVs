"""Canonical upstream entry: descriptive QC plus quantitative filtering only. No R analyses."""
from pathlib import Path
import hashlib
import importlib.metadata
import json
import platform
import subprocess
import sys
import time
from collections import deque

HERE=Path(__file__).resolve().parent
ROOT=HERE.parent

SCRIPTS=[
    'describe_proteomics.py',
    'detection_gradient.py',
    'design_composition.py',
    'complete_four_layers.py',
    'dose_quantitative_filtering.py'
]

# Explicit contracts from the active upstream plotting calls. Keep this list in
# sync when an active script intentionally changes an output filename.
FIGURE_OUTPUTS={
    'Figure_01_descriptive_protein_coverage': True,
    'Figure_01_descriptive_environment_coverage': True,
    'Figure_01_descriptive_region_coverage': True,
    'Figure_01_descriptive_sample_depth': True,
    'Figure_02_descriptive_matrix_missingness': True,
    'Figure_02_descriptive_protein_missingness': True,
    'Figure_02_descriptive_abundance_missingness': True,
    'Figure_03_detection_gradient_high_stress': True,
    'Figure_03_detection_gradient_high_temperature': True,
    'Figure_03_detection_gradient_group_threshold_counts': True,
    'Figure_03_detection_gradient_shared_coverage_condition': True,
    'Figure_03_detection_gradient_shared_coverage_group': True,
    'Figure_04_design_composition_region_exposure_counts': True,
    'Figure_04_design_composition_region_exposure_proportions': True,
    'Figure_04_design_composition_acquisition_date_proxy_exposure_counts': True,
    'Figure_04_design_composition_acquisition_date_proxy_exposure_proportions': True,
    'Figure_04_design_composition_environment_exposure_counts': True,
    'Figure_04_design_composition_environment_exposure_proportions': True,
    'Figure_04_design_composition_region_by_acquisition_date_proxy': True,
    'Figure6_coverage_other_levels': False,
    'Figure6_coverage_exposure': False,
    'Figure6_coverage_dates_2025': False,
    'Figure6_coverage_dates_2026': False,
    'Figure7_sample_depth_condition': False,
    'Figure7_missingness_condition': False,
    'Figure7_median_signal_condition': False,
    'Figure7_total_signal_condition': False,
    'Figure8_sample_depth_group': False,
    'Figure8_missingness_group': False,
    'Figure8_median_signal_group': False,
    'Figure8_total_signal_group': False,
    'Figure9_sample_depth_TREAT1_clean': False,
    'Figure9_missingness_TREAT1_clean': False,
    'Figure9_median_signal_TREAT1_clean': False,
    'Figure9_total_signal_TREAT1_clean': False,
    'Figure10_sample_depth_MS_batch_proxy': False,
    'Figure10_missingness_MS_batch_proxy': False,
    'Figure10_median_signal_MS_batch_proxy': False,
    'Figure10_total_signal_MS_batch_proxy': False,
    'Figure11_protein_detection_landscape': False,
    'Figure11_detection_breadth': False,
    'Figure11_core_definitions': False,
    'Figure11_abundance_missingness': False,
    'Figure11_detection_classes': False,
    'Quantitative_filter_sample_counts': True,
    'Quantitative_filter_proteins': True,
    'Quantitative_filter_missingness': True,
}

PACKAGES=[
    'numpy',
    'pandas',
    'matplotlib',
    'openpyxl'
]


def run_step(script, log):
    """Stream the real child traceback to the terminal and keep a UTF-8 log."""
    command=[
        sys.executable,
        '-X',
        'utf8',
        '-u',
        str(HERE/script)
    ]

    tail=deque(
        maxlen=40
    )

    with subprocess.Popen(
        command,
        cwd=ROOT,
        stdout=subprocess.PIPE,
        stderr=subprocess.STDOUT,
        text=True,
        encoding='utf-8',
        errors='replace'
    ) as process:

        for line in process.stdout:
            log.write(line)
            log.flush()

            print(
                line,
                end='',
                flush=True
            )

            tail.append(
                line
            )

        returncode=process.wait()

    if returncode:
        raise subprocess.CalledProcessError(
            returncode,
            command,
            output=''.join(
                tail
            )
        )


def main():

    for stream in (
        sys.stdout,
        sys.stderr
    ):
        if hasattr(
            stream,
            'reconfigure'
        ):
            stream.reconfigure(
                errors='backslashreplace'
            )

    versions={
        package:
            importlib.metadata.version(
                package
            )
        for package in PACKAGES
    }

    sources={}

    for name in [
        'processed.xlsx',
        'sample_mapping_FINAL.xlsx'
    ]:
        path=ROOT/'rawdata'/name

        if not path.is_file():
            raise FileNotFoundError(
                f'Required input: {path}'
            )

        sources[name]=hashlib.sha256(
            path.read_bytes()
        ).hexdigest()

    run={
        'python':
            sys.version,
        'platform':
            platform.platform(),
        'packages':
            versions,
        'source_sha256':
            sources,
        'scripts':
            SCRIPTS,
        'status':
            'running'
    }

    manifest=HERE/'reproduction_run.json'

    manifest.write_text(
        json.dumps(
            run,
            ensure_ascii=False,
            indent=2
        ),
        encoding='utf-8'
    )

    start=time.time()

    try:
        with (
            HERE/'reproduction_run.log'
        ).open(
            'w',
            encoding='utf-8'
        ) as log:

            for script in SCRIPTS:

                print(
                    f'Running {script}',
                    flush=True
                )

                log.write(
                    f'\nRunning {script}\n'
                )

                log.flush()

                run[
                    'current_script'
                ]=script

                run_step(
                    script,
                    log
                )

        figure_dir=HERE/'figures_nature_v2.2'

        for name, expects_source in FIGURE_OUTPUTS.items():
            for ext in [
                'pdf',
                'svg',
                'png'
            ]:
                path=figure_dir/f'{name}.{ext}'

                assert (
                    path.is_file()
                    and
                    path.stat().st_size>0
                ), (
                    f'Missing output: {path}'
                )

            if expects_source:
                source_path=figure_dir/f'{name}_source.csv'
                assert (
                    source_path.is_file()
                    and
                    source_path.stat().st_size>0
                ), (
                    f'Missing source-data output: {source_path}'
                )

        dose_outputs=[
            'dose_sample_counts.csv',
            'dose_protein_detection_rates.csv',
            'dose_filter_membership.csv',
            'dose_filter_threshold_requirements.csv',
            'dose_filter_summary.csv',
            'dose_defined_metadata.csv',
            'PRIMARY_dose_quantitative_proteins.csv',
            'PRIMARY_dose_quantitative_expression.csv.gz',
            'dose_quantitative_filtering_report.md'
        ]

        for threshold in [
            50,
            60,
            70,
            80
        ]:
            dose_outputs.extend([
                f'proteins_all_doses_ge{threshold}pct.csv',
                f'dose_expression_all_doses_ge{threshold}pct.csv.gz'
            ])

        for name in dose_outputs:
            path=HERE/name

            assert (
                path.is_file()
                and
                path.stat().st_size>0
            ), (
                f'Missing output: {path}'
            )

        run[
            'status'
        ]='PASS'

        run[
            'figure_count'
        ]=len(
            FIGURE_OUTPUTS
        )

        run[
            'dose_filtering_outputs'
        ]=dose_outputs

    except Exception as exc:

        run[
            'status'
        ]='FAIL'

        run[
            'error'
        ]=str(
            exc
        )

        if isinstance(
            exc,
            subprocess.CalledProcessError
        ):
            run[
                'error_output'
            ]=exc.output

        print(
            (
                f"FAILED: "
                f"{run.get('current_script', 'setup or output validation')}. "
                f"{exc}"
            ),
            file=sys.stderr
        )

        print(
            (
                f"Full log: "
                f"{HERE/'reproduction_run.log'}"
            ),
            file=sys.stderr
        )

        return 1

    finally:

        run[
            'elapsed_seconds'
        ]=round(
            time.time()-start,
            2
        )

        manifest.write_text(
            json.dumps(
                run,
                ensure_ascii=False,
                indent=2
            ),
            encoding='utf-8'
        )

    print(
        (
            f'PASS: standalone Nature-style figures rebuilt ({len(FIGURE_OUTPUTS)} outputs verified), '
            'with source tables/reports, '
            'plus dose-wise quantitative filtering outputs.'
        ),
        flush=True
    )

    return 0


if __name__=='__main__':
    sys.exit(
        main()
    )

