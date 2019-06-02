import sys

from cliff.app import App
from cliff.commandmanager import CommandManager

from commands.sync import SyncCommand


class East(App):
    def __init__(self):
        super().__init__(
            description="Eivor Auto Setup Tool",
            version="0.1b",
            command_manager=CommandManager("east"),
            deferred_help=True
        )

    def initialize_app(self, argv):
        commands = [SyncCommand]

        for command in commands:
            self.command_manager.add_command(command.command_name, command)


def main(argv=sys.argv[1:]):
    east_app = East()
    return east_app.run(argv)


if __name__ == "__main__":
    main()
