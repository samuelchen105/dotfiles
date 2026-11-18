#!/usr/bin/env python3

import os
import subprocess
import sys
from pathlib import Path

# Change to package dir
script_dir = Path(__file__).resolve().parent
os.chdir(f"{script_dir}/../packages")

# Run stow
result = subprocess.run(
    [
        "stow",
        f"--target={os.getenv('HOME')}",
        "-R",
        "fish",
        "starship",
        "dev-scripts",
    ],
    check=False,
)
sys.exit(result.returncode)
