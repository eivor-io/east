import os
import yaml


class YamlConfig:
    __instance = None

    @staticmethod
    def get_instance(yaml_path: str):
        if YamlConfig.__instance is None:
            YamlConfig.__instance = YamlConfig(yaml_path)

        return YamlConfig.__instance

    def __init__(self, yaml_path: str):
        if not os.path.exists(yaml_path) or not os.path.isfile(yaml_path):
            raise ValueError(f"Bad EASTFile {yaml_path}")

        with open(yaml_path) as eastfile:
            try:
                self._config = yaml.safe_load(eastfile)
            except yaml.YAMLError as err:
                print(err)
                exit(1)

    def get_package_list(self) -> list:
        if not "packages" in self._config:
            return []

        return self._config["packages"]

    def get_config_files(self) -> list:
        if not "config" in self._config:
            return []

        return self._config["config"]

    def get_east_repo(self) -> str:
        if not "east_repo" in self._config:
            return None

        return self._config["east_repo"]

    def get_presync_hooks(self) -> list:
        if not "hooks" in self._config:
            return []

        hooks = self._config["hooks"]

        if not "presync" in hooks:
            return []

        return hooks["presync"]

    def get_postsync_hooks(self) -> list:
        if not "hooks" in self._config:
            return []

        hooks = self._config["hooks"]

        if not "postsync" in hooks:
            return []

        return hooks["postsync"]
