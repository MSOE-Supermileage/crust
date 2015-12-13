# crust

> Pies are defined by their crust.
>
> —Wikipedia

The easiest way to connect to a headless [Raspberry Pi](https://www.raspberrypi.org/) is with SSH. However, if one does not have access to the network to view the IP address of the Pi, it is quite challenging to find its IP address.

To solve this problem, this script will post a message in a [Slack](https://slack.com/) channel with the Pi's public and private IP address. It will post the message whenever the it makes a network connection.

## Requirements

- Python 3
- [Requests](http://requests.readthedocs.org/)
- [systemd](http://freedesktop.org/wiki/Software/systemd/) (for auto-running at network online)

## Install

Run `install.sh`:

```bash
git clone https://github.com/MSOE-Supermileage/crust.git
cd crust
./install.sh
```

Next, go to the "Configure Integrations" page for the Slack team. Switch to the "Configured Integrations" tab. Select "Incoming Hooks" and the one that says "Posts to #pie-crust as crust". Copy the Webhook URL, under Integration Settings, and paste it into `"webhook-url"` in `config.json`.

