#!/bin/bash

echo "EAST install script"
echo "======================================="

declare -a packages=({% for package in packages %} "{{ package }}" {% endfor %})

for i in "${arr[@]}"; do
    echo i
done
