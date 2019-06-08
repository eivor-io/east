import os
from cliff.command import Command
from subproc.os_porocess import SubprocessHandler
from config.yaml_config import YamlConfig
import shutil


class SyncCommand(Command):
    command_name = "sync"

    def get_parser(self, prog_name):
        parser = super().get_parser(prog_name)
        parser.add_argument("eastfile", help="EAST configuratoin file.")
        parser.add_argument("-r", "--repo",
                            help="""URL of the Git repo to backup the config to.\n
            Required if east_repo is not specified in YAML config.""")

        return parser

    def take_action(self, parsed_args):
        eastfile_name = parsed_args.eastfile
        east_config = YamlConfig.get_instance(eastfile_name)

        repo_url = east_config.get_east_repo()
        if repo_url is None:
            repo_url = parsed_args.repo

        if not repo_url:
            print("Cannot find a Git repo URL in configuration.")
            exit(1)

        east_workdir = "._east"
        if not os.path.exists(east_workdir):
            os.makedirs(east_workdir)

        self._clone_git_repo(repo_url, f"{east_workdir}/repo")

        presync_hooks = east_config.get_presync_hooks()
        if len(presync_hooks) > 0:
            print(f"Executing presync scripts...")
            self._execute_scripts(presync_hooks)
            print("Done.")

        print("Cleaning up...")
        shutil.rmtree(east_workdir)

    def _clone_git_repo(self, repo: str, directory: str):
        git_clone_args = ["git", "clone", repo, directory]
        return_code = SubprocessHandler.execute_command(git_clone_args)
        if return_code != 0:
            print("Git clone failed")
            shutil.rmtree(directory)

    def _execute_scripts(self, hooks: list):
        for hook in hooks:
            script_file = os.path.expanduser(hook)

            print(f"====== {hook}")
            return_code = SubprocessHandler.execute_command([script_file])
            if return_code != 0:
                print(f"The hook {hook} did not finish successfully.")
                exit(return_code)
