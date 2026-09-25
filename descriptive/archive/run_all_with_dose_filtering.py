"""Compatibility entry point; all upstream workflow logic lives in run_all.py."""
import sys
from run_all import main

if __name__ == '__main__':
    sys.exit(main())
