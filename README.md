# Eivor Auto Setup Tool (EAST)

EAST is meant to provide an easy way to keep user configuration synced up between devices. This tool could be used by people to who like to distro-hop or perform fresh installation of their favourite distributions.

EAST can be used to bootstrap the installation of the packages you need and the deployment of your personal configuration files.

## Installation

> You will need Python >= 3 to install EAST.

1. Clone this repo
2. `pip3 install .`

## Usage

EAST is configred using a YAML file. This file has all the information about what packages should be installed, what configuration files should be synced, and what pre/post-installation scripts it should execute if required.

My config file looks like this:

```yaml
packages:
  - wget
  - vim
  - xorg-server
  - xorg-server-common
  - xorg-xinit
  - xcompmgr
  - python-pip
  - lightdm
  - lightdm-gtk-greeter
  - lightdm-gtk-greeter-settings
  - pulseaudio
  - pulsemixer
  - i3-gaps
  - i3blocks
  - openssh
  - cronie
  - bash-completion
  - neomutt
  - nitrogen
  - linux-headers
  - xfce4-terminal
  - firefox
  - scrot
  - dunst

config:
  - ~/.config/dconf
  - ~/.config/dunst
  - ~/.config/fontconfig
  - ~/.config/gtk*
  - ~/.config/i3*
  - ~/.local/bin/*
  - ~/.themes
  - ~/.icons
  - ~/.bashrc
  - ~/.profile
  - ~/.xsession
  - ~/.Xresources

hooks:
  presync:
    - ~/.east/east-presync.sh
  postsync:
    - ~/.east/east-postsync.sh
```

### Syncing

For now, EAST syncs to a Git repository. You can either specify the target repo by using the `-r your_repo_url` switch, or by adding the following content to your EAST config file.

```yaml
east_repo:
  your_repo_url
```

Then, to sync:

```shell
# Syncing with -r switch
$ east sync ./eastconf.yaml -r your_repo_url

# Syncing with repo in EAST conf
$ east sync ./eastconf.yaml
```

### Installing generated config
EAST will generate an installer script that you can execute to install your config on any system in one go.
Just clone the repo and:

```shell
$ chmod +x ./install.sh && ./install.sh
```

---

## TODO list

- *The current version of EAST supports only Arch* : I'm trying to add support for Ubuntu using `launchpadlib`, but for now, it's a case for contributions welcome.

- *Better CLI Experience*: Improved logging, colors, and error handling.
