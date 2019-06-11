#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Please avoid running this script as root."
    exit 1
fi

## Functions

function os_version() {
    if [ -f /etc/os-release ]; then
        # freedesktop.org and systemd
        . /etc/os-release
        OS=$ID
        VER=$VERSION_ID
    elif type lsb_release >/dev/null 2>&1; then
        # linuxbase.org
        OS=$(lsb_release -si)
        VER=$(lsb_release -sr)
    elif [ -f /etc/lsb-release ]; then
        # For some versions of Debian/Ubuntu without lsb_release command
        . /etc/lsb-release
        OS=$DISTRIB_ID
        VER=$DISTRIB_RELEASE
    elif [ -f /etc/debian_version ]; then
        # Older Debian/Ubuntu/etc.
        OS=Debian
        VER=$(cat /etc/debian_version)
    elif [ -f /etc/SuSe-release ]; then
        # Older SuSE/etc.
        ...
    elif [ -f /etc/redhat-release ]; then
        # Older Red Hat, CentOS, etc.
        ...
    else
        # Fall back to uname, e.g. "Linux <version>", also works for BSD, etc.
        OS=$(uname -s)
        VER=$(uname -r)
    fi

    echo "$OS"
}

function system_update_pacman() {
    pacman -Syyu
}

function system_update_xbps() {
    xbps-install -Su
}

function install_packages_pacman() {
    pacman -Sy $@
}

function install_packages_xbps() {
    xbps-install -S $@
}

export OS=$(os_version)
export PACKAGECTL=""
case $OS in
    "arch" | "manjaro") PACKAGECTL="pacman" ;;
    "void") PACKAGECTL="xbps" ;;
    *) 
        echo "Only Arch and Voidlinux are supported"
        echo "Visit https://eivor.xyz/east to request support" ;;
esac

echo "Running as user: $USER."
echo "Detected OS: $OS"
read -p "Perform installation? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
echo "======================================="

export EAST_DIR=$( cd "$(dirname "$0")" ; pwd -P )

declare -a packages=({% for package in packages %}
                        "{{ package }}"{% endfor %}
                    )

echo "Performing a system udpate."
sudo bash -c "$(declare -f system_update_${PACKAGECTL}); system_update_${PACKAGECTL}"

{% if presync|length > 0 %}
echo "Executing {{presync|length}} pre-sync scripts..."
cd $EAST_DIR/._presync
(
    for f in *.sh; do
      echo ">>> $f"
      bash "$f" -H || exit $?
    done
)

if [[ "$?" -ne 0 ]]; then
    echo "A pre-install script has failed."
    exit 27
fi
{% endif %}

echo "Installing packages..."
sudo bash -c "$(declare -f install_packages_${PACKAGECTL}); install_packages_${PACKAGECTL} ${packages[@]}"

{% if postsync|length > 0 %}
echo "Executing {{postsync|length}} post-sync scripts..."
cd $EAST_DIR/._postsync
(
    for f in *.sh; do
      echo ">>> $f"
      bash "$f" -H || exit $?
    done
)

if [[ "$?" -ne 0 ]]; then
    echo "A post-install script has failed."
    exit 27
fi
{% endif %}

echo "Copying user configuration"
cd $EAST_DIR/._home
cp -r ./ $HOME
