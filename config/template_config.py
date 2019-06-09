from jinja2 import Environment, PackageLoader


class EastTemplateGenerator:

    def __init__(self, package_list, presync_hooks, postsync_hooks):
        self._packages = package_list
        self._presync = presync_hooks
        self._postsync = postsync_hooks

        self._jinja_env = Environment(
            loader=PackageLoader("config")
        )

    def generate_installation_script(self):
        return self._render_template("install.sh")

    def generate_readme(self):
        return self._render_template("README.md")

    def _render_template(self, template_name):
        template = self._jinja_env.get_template(template_name)
        return template.render(packages=self._packages,
                               presync=self._presync,
                               postsync=self._postsync)
