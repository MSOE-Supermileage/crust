#!/usr/bin/env python3

try: import simplejson as json
except: import json
import platform
import requests
import subprocess
import syslog
import socket


def get_private_ip():
    """Return the private IP address of this Pi.

    The method for obtaining the private IP addresses, using `hostname` returns
    a space-separated list of private IP addresses for each network interface.
    """
    private_ip = '0.0.0.0'

    platforms = platform.system()
    if platforms == 'Linux':
        #proc = subprocess.call(['hostname', '-i'],
        #                      stdout=subprocess.PIPE,
        #                      universal_newlines=True)
        #private_ip = proc.stdout
        # don't modify /etc/hosts
        private_ip = socket.gethostbyname(socket.gethostname())
    else:
        pass

    return private_ip


def get_public_ip():
    """Return the public IP address of this device.

    Since this Pi is assumed to be connected to the Internet, we request our
    IP address from http://ipinfo.io/. This is much simplier than using system
    commands.
    """
    public_ip = '0.0.0.0'

    r = requests.get('http://ipinfo.io/json')
    public_ip = r.json()['ip']

    return public_ip


def main():
    try:
        config = json.load(open('/opt/crust/config.json', 'rt'))
        url = config['webhook-url']
        payload = config['payload']

        payload['text'] = 'Public IP: {pub}\nPrivate IP: {priv}'.format(
            pub=get_public_ip(), priv=get_private_ip())

        r = requests.post(url, data=json.dumps(payload))
    except json.JSONDecodeError as err:
        message = 'Could not parse {file} as JSON. Failed at {pos}.'.format(
            file=err.doc, pos=err.pos)
        syslog.syslog(syslog.LOG_ERR, message)


if __name__ == '__main__':
    main()
