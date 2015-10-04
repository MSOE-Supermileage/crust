#!/usr/bin/env python3

import json
import os
import platform
import requests
import syslog


def get_private_ip():
    private_ip = '0.0.0.0'

    platforms = platform.system()
    if platforms == 'Linux':
        private_ip = os.system('hostname -i').
    else:
        pass

    return private_ip


def get_public_ip():
    public_ip = '0.0.0.0'

    r = requests.get('http://ipinfo.io/json')
    public_ip = r.json()['ip']

    return public_ip


def main():
    try:
        config = json.load(open('./config.json', 'rt'))
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
