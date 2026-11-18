#!/usr/bin/env python3

import re
import subprocess
import sys
from dataclasses import dataclass

from utils.common import Color, ColorText, ScriptError

CHAR_CHECK = "󰄬"
CHAR_CLOSE = "󰅖"
CHAR_ARROW_UP = "󱦲"
CHAR_ARROW_DOWN = "󱦳"


@dataclass
class Branch:
    name: str
    status: ColorText
    commit_time: ColorText


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
        raise ScriptError(result.returncode, "failed to get tracked remotes")

    remotes = set()
    for line in result.stdout.strip().split("\n"):
        remotes.add(line.strip())

    return remotes


def parse_branch_status(track: str, remote: str) -> ColorText:
    if remote == "":
        return ColorText("-", Color.NONE)
    if track == "":
        return ColorText(CHAR_CHECK, Color.GREEN)
    if track == "gone":
        return ColorText(CHAR_CLOSE, Color.RED)

    # The branch is diverged
    output = ""
    ahead_m = re.search(
        r"ahead (\d+)",
        track,
    )
    if ahead_m is not None:
        output += f"{CHAR_ARROW_UP}{ahead_m.group(1)}"

    behind_m = re.search(
        r"behind (\d+)",
        track,
    )
    if behind_m is not None:
        output += f"{CHAR_ARROW_DOWN}{behind_m.group(1)}"

    return ColorText(output, Color.YELLOW)


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
        raise ScriptError(result.returncode, "failed to get local branches")

    name_width = 1
    status_width = 1
    time_width = 1
    branches: list[Branch] = []
    for line in result.stdout.strip().split("\n"):
        head, name, commit_time, track, remote = line.strip().split("△", 5)

        # Skip current branch and tracked remotes
        if head != "" or (name in tracked_remotes) or (name == "origin"):
            continue

        status = parse_branch_status(track, remote)
        commit_time_view = ColorText(commit_time, Color.CYAN)

        branches.append(Branch(name, status, commit_time_view))
        name_width = max(name_width, len(name))
        time_width = max(time_width, len(commit_time))
        status_width = max(status_width, len(status.text))

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
    selected = select_branch("\n".join(branches))
    if selected is not None:
        status = switch_branch(selected)
        sys.exit(status)


if __name__ == "__main__":
    try:
        main()
    except ScriptError as e:
        sys.exit(f"Error: {e}")
