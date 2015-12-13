#!/usr/bin/env bash

DIRNAME=$(dirname $0)
URL=$1

# assert run as root, otherwise exit
if [ "$(id -u)" != "0" ]; then
	echo "Please run `$0` as root." 1>&2
	exit 1
fi

function arch_install {
    local cmd=$1
    local package=$2

    if ! command -v $cmd &>/dev/null; then
        echo "Installing $package for $cmd"
        pacman -S $package
    else
        echo "$cmd already installed"
    fi
}

function apt-get_install {
    local cmd=$1
    local package=$2

    if ! command -v $cmd &>/dev/null; then
        echo "Installing $package for $cmd"
        apt-get install $package
    else
        echo "$cmd already installed"
    fi
}

# install required programs
if command -v apt-get &>/dev/null; then
    # install packages for apt-get based systems
    apt-get_install python3 python3
    apt-get_install pip3 python3-pip

    # install requiired python modules
    pip3 install -r requirements.txt
elif command -v pacman &>/dev/null; then
    # install packages for pacman based systems
    arch_install python3 python
    arch_install pip python-pip

    # install required python modules
    pip install -r requirements.txt
else
    echo "Sorry, we do not support automatic package installation for your package manager."
    read -p "Do you want to continue anyway? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    fi
fi

sed -i 's|replaceme|'$URL'|g' $DIRNAME/config.json

ln -vis $(readlink -f $DIRNAME)/crust.py /opt/crust/crust.py
ln -vis $(readlink -f $DIRNAME)/config.json /opt/crust/config.json

# copy the actual service
cp $DIRNAME/crust.service /etc/systemd/system/crust.service

# make systemd aware of the new crust.service
systemctl daemon-reload

# enable the new crust.service to be run on boot
systemctl enable crust.service

echo
if [[ -z $URL ]]; then
    exit 0;
fi

# start service with new config
systemctl start crust.service

