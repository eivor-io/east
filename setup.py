from setuptools import setup

setup(
    name="east",
    description="Eivor Auto Setup Tool",
    version="0.1b",
    author="Jay Godara (https://jgodara.github.io)",
    entry_points={
        "console_scripts": [
            "east = east:main"
        ]
    }
)
