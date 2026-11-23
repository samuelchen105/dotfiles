#!/usr/bin/env python3

import argparse
import os
import subprocess
import sys
from pathlib import Path

parser = argparse.ArgumentParser()
parser.add_argument("-d", "--delete", action="store_true", help="Unstow the package")
parser.add_argument("packages", nargs=argparse.REMAINDER)
args = parser.parse_args()

# Change to package dir
script_dir = Path(__file__).resolve().parent
os.chdir(f"{script_dir}/../packages")

# Run stow
cmd = ["stow", f"--target={os.getenv('HOME')}"]

if args.delete:
    cmd.append("-D")
else:
    cmd.append("-R")

cmd.extend(args.packages)

result = subprocess.run(
    cmd,
    check=False,
)
sys.exit(result.returncode)
