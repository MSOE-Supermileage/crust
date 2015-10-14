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

apt-get_install() {
    local cmd=$1
    local package=$2

    if test "$(command -v $cmd)" == 0; then
        echo "Installing $package"
        sudo apt-get install $package
    else
        echo "$cmd already installed"
    fi
}

pip_install() {
    local pypi_package=$1
    sudo pip install $pypi_package
}

# install required programs
arch_install python3 python
arch_install pip python-pip
pip_install requests

# symlink the executable for the systemd service so that it can easily be found
sudo mkdir -p /opt/crust
sudo ln -vis $PWD/crust.py /opt/crust/crust.py
sudo ln -vis $PWD/config.json /opt/crust/config.json

# symlink the systemd service file
sudo ln -vis $PWD/crust.service /etc/systemd/system/crust.service
# make systemd aware of the new crust.service
systemctl daemon-reload
# start the new crust.service
systemctl start crust.service
