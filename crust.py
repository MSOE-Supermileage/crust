#!/usr/bin/env python3

import configparser
import json
import socket
import requests
import syslog


def get_private_ip():
    """Return the private IP address of this Pi, or 0.0.0.0 if the operation
    failed.

    The private IP is obtained by connecting to Google's DNS servers.
    """
    try:
        s = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
        s.connect(('8.8.8.8', 80))
        private_ip = s.getsockname()[0]
        s.close()
        return private_ip
    except OSError as err:
        syslog.syslog(syslog.LOG_ERR, str(err))
        return '0.0.0.0'


def get_public_ip():
    """Return the public IP address of this device, or 0.0.0.0 if the request
    failed.

    Since this Pi is assumed to be connected to the Internet, we request our
    IP address from http://ipinfo.io/. This is much simplier than using system
    commands.
    """
    try:
        return requests.get('http://ipinfo.io/ip').text.strip()
    except requests.exceptions.RequestException as err:
        syslog.syslog(syslog.LOG_ERR, str(err))
        return '0.0.0.0'


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

