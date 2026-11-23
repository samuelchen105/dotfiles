import re

from utils.color import green, red, yellow

CHAR_CHECK = "󰄬"
CHAR_CLOSE = "󰅖"
CHAR_ARROW_UP = "󱦲"
CHAR_ARROW_DOWN = "󱦳"


def parse_branch_status(track: str, remote: str) -> tuple[str, int]:
    if remote == "":
        return "-", 1
    if track == "":
        return green(CHAR_CHECK), len(CHAR_CHECK)
    if track == "gone":
        return red(CHAR_CLOSE), len(CHAR_CLOSE)

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

    return yellow(output), len(output)
