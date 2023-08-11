#!/bin/bash

set -e

sudo apt install openvpn

sudo cp -p /tmp/server.conf /etc/openvpn/server/server.conf

exit 0
