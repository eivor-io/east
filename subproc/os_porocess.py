import subprocess


class SubprocessHandler:

    @staticmethod
    def execute_command(command: list) -> int:
        return subprocess.call(command)
