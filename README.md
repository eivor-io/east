# Eivor Auto Setup Tool (EAST)

EAST is meant to provide an easy way to keep user configuration synced up between devices. This tool could be used by people to who like to distro-hop or perform fresh installation of their favourite distributions.

EAST can be used to bootstrap the installation of the packages you need and the deployment of your personal configuration files.

## Installation

> You will need Python >= 3 to install EAST.

1. Clone this repo
2. `pip3 install .`

## Usage

EAST is configred using a YAML file. This file has all the information about what packages should be installed, what configuration files should be synced, and what post-installation scripts it should execute if required.

eastconf.yaml:

```yml
packages:
  - lightdm
  - lightdm-gtk-greeter-settings
  - i3-gaps
  - i3blocks

config:
  - ~/.zshrc
  - ~/.xsession
  - ~/.local/bin
  - ~/.config/i3

hooks:
  presync:
  postsync:
    - ~/.local/.bins/east-postinstall
```

All set. Just run `east sync ./eastconf.yaml` and EAST will generate a link to a shell script that can be used to install your full configuration on any distribution.
