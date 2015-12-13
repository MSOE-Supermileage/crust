#!/usr/bin/env bash

DIRNAME=$(dirname $0)

# assert run as root, otherwise exit
if [ "$(id -u)" != "0" ]; then
	echo "Please run `$0` as root." 1>&2
	exit 1
fi

arch_install() {
 	local cmd=$1
    local package=$2

    if command -v $cmd &>/dev/null; then
        echo "Installing $package for $cmd"
        pacman -S $package
    else
        echo "$cmd already installed"
    fi
}

apt-get_install() {
    local cmd=$1
    local package=$2

    if command -v $cmd &>/dev/null; then
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
elif command -v pacman &>/dev/null; then
    # install packages for pacman based systems
    arch_install python3 python
    arch_install pip python-pip
else
    echo "Sorry, we do not support automatic package installation for your package manager."
    read -p "Do you want to continue anyway? " -n 1 -r
    echo
    if [[ $REPLY =~ ^[Nn]$ ]]; then
        exit 1
    fi
fi

# install required Python modules
pip install -r requirements.txt

# symlink the executable for the systemd service so that it can easily be found
mkdir -p /opt/crust
ln -vis $PWD/crust.py /opt/crust/crust.py
ln -vis $PWD/config.json /opt/crust/config.json

# symlink the systemd service file
ln -vis $PWD/crust.service /etc/systemd/system/crust.service
# make systemd aware of the new crust.service
systemctl daemon-reload

# start the new crust.service
systemctl enable crust.service
systemctl start crust.service

cat $DIRNAME/README.md | grep "Next,"
read $URL
echo
if [[ -z $URL ]]; then
	exit 0
fi

REPLACEME="https://hooks.slack.com/services/REPLACEME"
sed -i 's|'$REPLACEME'|'$URL'|g' $DIRNAME/config.json

