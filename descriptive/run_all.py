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

        figure_names=[
            'Figure1_protein_coverage',
            'Figure2_missingness',
            'Figure3_detection_gradient',
            'Figure4_TREAT1_composition',
            'Figure5_group_run_date',
            'Figure6_coverage_other_levels',
            'Figure7_sample_depth_condition',
            'Figure8_sample_depth_group',
            'Figure9_sample_depth_TREAT1_clean',
            'Figure10_sample_depth_MS_batch_proxy',
            'Figure11_protein_detection_landscape'
        ]

        for name in figure_names:
            for ext in [
                'pdf',
                'svg',
                'png'
            ]:
                path=HERE/'figures_nature_v2.2'/f'{name}.{ext}'

                assert (
                    path.is_file()
                    and
                    path.stat().st_size>0
                ), (
                    f'Missing output: {path}'
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
            figure_names
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
            'PASS: standalone Nature-style figures rebuilt (11 anchor outputs verified), '
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

