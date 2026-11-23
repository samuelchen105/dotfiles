#!/usr/bin/env python3

import subprocess
import sys
from dataclasses import dataclass

from utils.color import cyan, red
from utils.common import ScriptError
from utils.git import parse_branch_status


@dataclass
class Branch:
    name: str
    status: str
    commit_time: str


def get_tracked_remotes() -> set[str]:
    result = subprocess.run(
        [
            "git",
            "for-each-ref",
            "--format=%(upstream:short)",
            "refs/heads",
        ],
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode != 0:
        raise ScriptError("get tracked remotes", result.returncode, result.stderr)

    remotes = set()
    for line in result.stdout.strip().split("\n"):
        remotes.add(line.strip())

    return remotes


def get_branches() -> list[str]:
    tracked_remotes = get_tracked_remotes()

    result = subprocess.run(
        [
            "git",
            "for-each-ref",
            "--sort=-committerdate",
            "--format=%(HEAD)△%(refname:short)△%(committerdate:relative)△%(upstream:track,nobracket)△%(upstream:remotename)",
            "refs/heads",
            "refs/remotes",
        ],
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode != 0:
        raise ScriptError("get branches", result.returncode, result.stderr)

    name_width = 1
    status_width = 1
    time_width = 1
    branches: list[Branch] = []
    for line in result.stdout.strip().split("\n"):
        head, name, commit_time, track, remote = line.strip().split("△", 5)

        # Skip current branch and tracked remotes
        if head != "" or (name in tracked_remotes) or (name == "origin"):
            continue

        status, status_len = parse_branch_status(track, remote)
        commit_time_view = cyan(commit_time)

        branches.append(Branch(name, status, commit_time_view))
        name_width = max(name_width, len(name))
        time_width = max(time_width, len(commit_time))
        status_width = max(status_width, status_len)

    outputs: list[str] = []
    for b in branches:
        outputs.append(
            f"{b.name:<{name_width}}\t{b.status:<{status_width}}\t{b.commit_time:<{time_width}}"
        )

    return outputs


def select_branch(input: str) -> str | None:
    result = subprocess.run(
        [
            "fzf",
            "--ansi",
            "--delimiter=\t",
            "--nth=1",
            "--with-nth=1,2,3",
            "--accept-nth=1",
            "--layout=reverse",
            "--border",
        ],
        input=input,
        capture_output=True,
        check=False,
        text=True,
    )
    output = result.stdout.strip()
    if result.returncode != 0 or output == "":
        return None
    return output


def switch_branch(branch: str) -> int:
    result = subprocess.run(
        [
            "git",
            "switch",
            branch,
        ],
        check=False,
    )
    return result.returncode


def main():
    branches = get_branches()
    if len(branches) == 0:
        print("No branches to switch")
        return

    selected = select_branch("\n".join(branches))
    if selected is not None:
        status = switch_branch(selected)
        sys.exit(status)


if __name__ == "__main__":
    try:
        main()
    except ScriptError as e:
        sys.exit(f"{red('ERR')} {e}")
