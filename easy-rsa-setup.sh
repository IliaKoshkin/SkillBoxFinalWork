#!/bin/bash

set -e

sudo apt install easy-rsa

cp -p /tmp/vars /usr/share/easy-rsa/

/usr/share/easy-rsa/easyrsa init-pki
/usr/share/easy-rsa/easyrsa build-ca nopass

exit 0

