#!/usr/bin/env python3

import argparse
import subprocess
import sys
from dataclasses import dataclass

from utils.color import colorlen, cyan, green, magenta, red, yellow
from utils.common import ScriptError


@dataclass
class Commit:
    hash: str
    message: str
    author: str
    tags: str
    refs: str


@dataclass
class GitRef:
    name: str
    has_local: bool
    has_remote: bool


def parse_decorations(decorations: str) -> tuple[str, str]:
    tags: list[str] = []
    refMap: dict[str, GitRef] = {}

    for decoration in decorations.split(","):
        d = decoration.strip()
        if d == "" or d == "origin/HEAD":
            continue

        if d.startswith("HEAD ->"):
            refMap["HEAD"] = GitRef("HEAD", False, False)
            continue

        if d.startswith("tag: "):
            tags.append(yellow(d.removeprefix("tag: ")))
            continue

        is_remote = False
        if d.startswith("origin/"):
            d = d.removeprefix("origin/")
            is_remote = True

        if d in refMap:
            if is_remote:
                refMap[d].has_remote = True
            else:
                refMap[d].has_local = True
        else:
            refMap[d] = GitRef(d, (not is_remote), is_remote)

    refs: list[str] = []
    for ref in refMap.values():
        if ref.has_local and ref.has_remote:
            refs.append(magenta(ref.name))
        elif ref.has_local:
            refs.append(green(ref.name))
        elif ref.has_remote:
            refs.append(red(ref.name))
        else:
            refs.append(cyan(ref.name))

    return ", ".join(tags), ", ".join(refs)


def git_log(n: int | None) -> list[str]:
    args = [
        "git",
        "log",
        "--pretty=%h△%s△%aN△%D",
        "--first-parent",
    ]
    if n is not None:
        args.append(f"-{n}")

    result = subprocess.run(
        args,
        capture_output=True,
        check=False,
        text=True,
    )
    if result.returncode != 0:
        raise ScriptError("git log", result.returncode, result.stderr)

    logs: list[Commit] = []
    hash_width = 0
    msg_width = 0
    author_width = 0
    tags_width = 0
    refs_width = 0
    for line in result.stdout.strip().split("\n"):
        hash, msg, author, decorations = line.strip().split("△", 4)
        tags, refs = parse_decorations(decorations)

        logs.append(Commit(hash, msg, author, tags, refs))
        hash_width = max(hash_width, len(hash))
        msg_width = max(msg_width, len(msg))
        author_width = max(author_width, len(author))
        tags_width = max(tags_width, colorlen(tags))
        refs_width = max(refs_width, colorlen(refs))

    outputs: list[str] = []
    for log in logs:
        output = f"{yellow(log.hash):<{hash_width}}\t{log.message:<{msg_width}}\t{log.author:<{author_width}}"
        if tags_width > 0:
            output += f"\t{log.tags:<{tags_width}}"
        if refs_width > 0:
            output += f"\t{log.refs}"

        outputs.append(output)
    return outputs


def page(input: str):
    result = subprocess.run(
        [
            "less",
            "-R",
            "-F",
            "-~",
            "--mouse",
        ],
        input=input,
        check=False,
        text=True,
    )
    if result.returncode != 0:
        raise ScriptError("less", result.returncode, result.stderr)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "-n",
        "--number",
        type=int,
        help=" Limit the output to the first <number> commits that would be shown.",
    )
    parser.add_argument("packages", nargs=argparse.REMAINDER)
    args = parser.parse_args()

    logs = git_log(args.number)
    page("\n".join(logs))


if __name__ == "__main__":
    try:
        main()
    except ScriptError as e:
        sys.exit(f"{red('ERR')} {e}")
