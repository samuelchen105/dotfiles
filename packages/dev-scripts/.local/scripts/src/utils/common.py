class ScriptError(Exception):
    def __init__(self, wrap_msg: str, code: int, stderr: str):
        full_msg = f"{wrap_msg} ({code}): {stderr.strip()}"
        super().__init__(full_msg)
        self.message = full_msg

    def __str__(self) -> str:
        return self.message
