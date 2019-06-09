from jinja2 import Environment, PackageLoader


class InstallationScriptGenerator:

    def __init__(self, package_list):
        self._packages = package_list

        self._jinja_env = Environment(
            loader=PackageLoader("config", package_path="scripts")
        )

    def generate_script(self):
        template = self._jinja_env.get_template("install.sh")
        return template.render(packages=self._packages)
