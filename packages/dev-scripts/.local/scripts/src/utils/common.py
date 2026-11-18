from enum import Enum


class ScriptError(Exception):
    def __init__(self, code: int, message: str):
        super().__init__(message)
        self.code = code
        self.message = message

    def __str__(self) -> str:
        return f"{self.message} ({self.code})"


COLOR_RESET_CODE = "\x1b[0m"


class Color(Enum):
    NONE = ""
    RED = "\x1b[31m"
    GREEN = "\x1b[32m"
    YELLOW = "\x1b[33m"
    BLUE = "\x1b[34m"
    MAGENTA = "\x1b[35m"
    CYAN = "\x1b[36m"

    def colorize(self, text: str) -> str:
        if self == Color.NONE:
            return text
        return f"{self.value}{text}{COLOR_RESET_CODE}"


class ColorText:
    def __init__(self, text: str, color: Color):
        self.text = text
        self.color = color

    def __str__(self) -> str:
        return self.color.colorize(self.text)

    def __format__(self, format_spec: str) -> str:
        output = format(self.text, format_spec)
        return self.color.colorize(output)
