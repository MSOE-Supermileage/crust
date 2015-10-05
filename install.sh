#!/usr/bin/env bash
#
# NOTE: this script only works with the Arch Linux package manager

arch_install() {
    local cmd=$1
    local package=$2

    if test "$(command -v $cmd)" == 0; then
        echo "Installing $package"
        sudo pacman -S $package
    else
        echo "$cmd already installed"
    fi
}

pip_install() {
    local pypi_package=$1
    sudo pip install $pypi_package
}

arch_install python3 python
arch_install pip python-pip
pip_install requests

# symlink the file to the correct directory/setup systemd
