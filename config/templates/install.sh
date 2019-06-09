#!/bin/bash

if [ "$EUID" -eq 0 ]; then
    echo "Please avoid running this script as root."
    exit 1
fi

echo "Running as user: $USER."
read -p "Perform installation? " -n 1 -r
echo    # (optional) move to a new line
if [[ ! $REPLY =~ ^[Yy]$ ]]
then
    [[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
fi
echo "======================================="

EAST_DIR=$(dirname "$BASH_SOURCE")

declare -a packages=({% for package in packages %}
                        "{{ package }}"
{% endfor %})

echo "Performing a system udpate."
sudo pacman -Syyu

{% if presync|length > 0 %}
echo "Executing {{presync|length}} pre-sync scripts..."
cd $EAST_DIR/._presync
for f in *.sh; do
  bash "$f" -H || break  # execute successfully or break
  # Or more explicitly: if this execution fails, then stop the `for`:
  # if ! bash "$f" -H; then break; fi
done
{% endif %}

echo "Installing packages..."
sudo pacman -Sy ${packages[@]}

{% if postsync|length > 0 %}
echo "Executing {{postsync|length}} post-sync scripts..."
cd $EAST_DIR/._postsync
for f in *.sh; do
  bash "$f" -H || break  # execute successfully or break
  # Or more explicitly: if this execution fails, then stop the `for`:
  # if ! bash "$f" -H; then break; fi
done
{% endif %}

echo "Copying user configuration"
cd $EAST_DIR/._home
cp -r ./ $HOME
