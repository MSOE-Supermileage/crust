#!/usr/bin/env bash

arch_install() {
    local cmd=$1
    local package=$2

    if command -v $cmd &>/dev/null; then
        echo "Installing $package"
        sudo pacman -S $package
    else
        echo "$cmd already installed"
    fi
}

apt-get_install() {
    local cmd=$1
    local package=$2

    if command -v $cmd &>/dev/null; then
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
if command -v apt-get &>/dev/null; then
    # install packages for apt-get based systems
    apt-get_install python3 python3
    apt-get_install pip python-pip
elif command -v pacman &>/dev/null; then
    # install packages for pacman based systems
    arch_install python3 python
    arch_install pip python-pip
else
    echo "Sorry, we do not support automatic pacakge installion for your package manager"
    read -p "Do you want to continue anyway? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    fi
fi
# install required Python modules
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
