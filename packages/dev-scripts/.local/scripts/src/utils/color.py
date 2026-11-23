import re
from enum import Enum

CODE_RESET = "\x1b[0m"


class Color(Enum):
    RED = "\x1b[31m"
    GREEN = "\x1b[32m"
    YELLOW = "\x1b[33m"
    BLUE = "\x1b[34m"
    MAGENTA = "\x1b[35m"
    CYAN = "\x1b[36m"

    def colorize(self, text: str) -> str:
        if text == "":
            return text
        return f"{self.value}{text}{CODE_RESET}"


def colorlen(text: str) -> int:
    clean_text = re.sub(r"\x1b\[[0-9;]*m", "", text)
    return len(clean_text)


def red(text: str) -> str:
    return Color.RED.colorize(text)


def green(text: str) -> str:
    return Color.GREEN.colorize(text)


def yellow(text: str) -> str:
    return Color.YELLOW.colorize(text)


def blue(text: str) -> str:
    return Color.BLUE.colorize(text)


def magenta(text: str) -> str:
    return Color.MAGENTA.colorize(text)


def cyan(text: str) -> str:
    return Color.CYAN.colorize(text)
