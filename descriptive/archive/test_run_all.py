"""Regression tests for visible subprocess failures; no scientific data used."""
import contextlib
import io
from pathlib import Path
import subprocess
import tempfile
import unittest

from run_all import run_step


class RunStepTests(unittest.TestCase):
    def test_success_is_logged_and_shown(self):
        with tempfile.TemporaryDirectory() as directory:
            script=Path(directory)/'success.py'
            script.write_text("print('completed')\n",encoding='utf-8')
            console,log=io.StringIO(),io.StringIO()
            with contextlib.redirect_stdout(console):run_step(script,log)
            self.assertEqual(console.getvalue(),log.getvalue())
            self.assertIn('completed',console.getvalue())

    def test_child_traceback_is_not_hidden(self):
        with tempfile.TemporaryDirectory() as directory:
            script=Path(directory)/'failure.py'
            script.write_text("raise ValueError('diagnostic marker')\n",encoding='utf-8')
            console,log=io.StringIO(),io.StringIO()
            with contextlib.redirect_stdout(console):
                with self.assertRaises(subprocess.CalledProcessError) as caught:
                    run_step(script,log)
            self.assertEqual(console.getvalue(),log.getvalue())
            self.assertIn('ValueError: diagnostic marker',console.getvalue())
            self.assertIn('ValueError: diagnostic marker',caught.exception.output)
            self.assertNotEqual(caught.exception.returncode,0)


if __name__=='__main__':unittest.main()
