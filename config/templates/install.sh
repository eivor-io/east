#!/bin/bash

if [ "$EUID" -ne 0 ]; then
    echo "This script should be run as root."
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

{% include 'larbs_functions.sh' %}

## Used by archlinux.
function install_packages_pacman() {
    pacman --noconfirm -S $@
}

function install_packages_xbps() {
    xbps-install -Syf $@
}

export OS=$(os_version)
export PACKAGECTL=""
case $OS in
    "arch" | "manjaro") 
        PACKAGECTL="pacman" 
        pacman -S --noconfirm --needed dialog ;;
    "void") 
        PACKAGECTL="xbps" 
        xbps-install -Syf dialog ;;
    *)
        echo "Only Arch and Voidlinux are supported"
        echo "Visit https://eivor.xyz/east to request support" ;;
esac

export EAST_DIR=$( cd "$(dirname "$0")" ; pwd -P )

dialog --title "EAST Installation Script" --msgbox "Installing for OS ${OS}\\n\\nBase directory: ${EAST_DIR}" 10 60

getuserandpass || error "Cannot get username and password."

usercheck || error "Cannot check for $name's validatity"

preinstallmsg || error "User exited."

adduserandpass || error "Error adding username and/or password."

export EAST_USER="$name"
export home="/home/$EAST_USER"
export deu="sudo -u $EAST_USER"

declare -a packages=({% for package in packages %}
                        "{{ package }}"{% endfor %}
                    )

echo "Performing a system udpate."
system_update_${PACKAGECTL}

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
install_packages_${PACKAGECTL} ${packages[@]}

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

putfiles "$EAST_DIR/._home" "/home/$name"
