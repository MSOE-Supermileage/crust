#!/usr/bin/env python3

import configparser
import json
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

        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        private_ip = s.getsockname()[0]
        s.close()
        return private_ip
    else:
        pass


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
        # read off the crust config
        slack_section = 'slack-webhook'
        config = configparser.ConfigParser()
        config.read('/opt/crust/crust.conf')
        print('Read config file')
        url = config[slack_section]['webhook-url']

        # build the json object for post to slack
        payload = {}
        payload['username'] = config[slack_section]['username']
        payload['channel'] = config[slack_section]['channel']
        payload['text'] = 'Hostname: {hn}\nPublic IP: {pub}\nPrivate IP: {priv}'.format(
            hn=socket.gethostname(), pub=get_public_ip(), priv=get_private_ip())

        r = requests.post(url, data=json.dumps(payload))
    except KeyError as err:
        message = str(err)
        syslog.syslog(syslog.LOG_ERR, message)
        print(err)

if __name__ == '__main__':
    main()

