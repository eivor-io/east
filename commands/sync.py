import glob
import os
import shutil

import errno

from datetime import datetime

from cliff.command import Command

from config.yaml_config import YamlConfig
from config.template_config import EastTemplateGenerator
from subproc.os_porocess import SubprocessHandler


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

        east_workdir = "/tmp/._east"
        if not os.path.exists(east_workdir):
            os.makedirs(east_workdir)

        east_repo_dir = f"{east_workdir}/repo"
        if os.path.exists(east_repo_dir):
            shutil.rmtree(east_repo_dir)

        self._clone_git_repo(repo_url, east_repo_dir)

        print("Cleaning up cloned repo, just in case...")
        for file in os.listdir(east_repo_dir):
            _f = f"{east_repo_dir}/{file}"

            # FIXME Should be a clean way of doing this.
            if file != ".git":
                print(f"\t == {file}")
                os.remove(_f) if os.path.isfile(_f) else shutil.rmtree(_f)

        presync_hooks = east_config.get_presync_hooks()
        postsync_hooks = east_config.get_postsync_hooks()

        print("Copying user configuration...")
        config_files = east_config.get_config_files()
        for _f in config_files:
            print(f"\t == {_f}")
            conf_file = os.path.expanduser(_f)
            self._copy_config_files(conf_file, east_repo_dir)
        print("Done.")

        if len(presync_hooks) > 0:
            presync_hook_dir = f"{east_repo_dir}/._presync"
            self._copy_files(presync_hooks, presync_hook_dir)

        if len(postsync_hooks) > 0:
            postsync_hook_dir = f"{east_repo_dir}/._postsync"
            self._copy_files(postsync_hooks, postsync_hook_dir)

        print("Generating installation script...")
        packages = east_config.get_package_list()
        installer = EastTemplateGenerator(
            packages,
            presync_hooks,
            postsync_hooks)

        with open(f"{east_repo_dir}/install.sh", "w") as install_file:
            install_file.write(installer.generate_installation_script())

        print("Generating README")
        with open(f"{east_repo_dir}/README.md", "w") as readme_file:
            readme_file.write(installer.generate_readme())

        print("Pushing changes...")
        os.chdir(east_repo_dir)
        SubprocessHandler.execute_command(["git", "add", "."])
        SubprocessHandler.execute_command(
            ["git", "commit", "-m", f"Config: {datetime.now()}"])
        SubprocessHandler.execute_command(["git", "push"])

        print("Cleaning up...")
        shutil.rmtree(east_workdir)

    def _clone_git_repo(self, repo: str, directory: str):
        git_clone_args = ["git", "clone", repo, directory]
        return_code = SubprocessHandler.execute_command(git_clone_args)
        if return_code != 0:
            print("Git clone failed!!")
            shutil.rmtree(directory)

    def _copy_config_files(self, src, dst):
        # FIXME WTF BUCK!
        home_dir = os.path.expanduser("~")
        for glob_match in glob.glob(src):
            subdir = glob_match.replace(home_dir, "")
            dst_dir = f"{dst}/._home{subdir}"
            if os.path.isfile(glob_match):
                try:
                    shutil.copy2(glob_match, dst_dir)
                except IOError as e:
                    if e.errno != errno.ENOENT:
                        raise
                    # try creating parent directories
                    os.makedirs(os.path.dirname(dst_dir))
                    shutil.copy2(glob_match, dst_dir)
            else:
                shutil.copytree(glob_match, dst_dir)

    def _copy_files(self, src, dst):
        os.makedirs(dst)
        for file in src:
            shutil.copy2(os.path.expanduser(file), dst)
