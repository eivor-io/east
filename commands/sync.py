import yaml
import os
from cliff.command import Command


class SyncCommand(Command):
    command_name = "sync"

    def get_parser(self, prog_name):
        parser = super().get_parser(prog_name)
        parser.add_argument("eastfile", help="EAST configuratoin file.")

        return parser

    def take_action(self, parsed_args):
        eastfile_name = parsed_args.eastfile
        if not os.path.exists(eastfile_name) or not os.path.isfile(eastfile_name):
            raise ValueError(f"Bad EASTFile {eastfile_name}")

        with open(eastfile_name) as eastfile:
            try:
                east_config = yaml.safe_load(eastfile)
            except yaml.YAMLError as err:
                print(err)
                exit(1)

            if "packages" in east_config:
                print("Packages =========")
                for package in east_config["packages"]:
                    print(f"\t{package}")
