#!/bin/bash

SEP="\n\n##################################################################################################\n\n"
EASYRSA_DIR='/home/yc-user/easy-rsa/'

echo -e ${SEP}

echo -e 'COPYING server.crt AND ca.crt TO /etc/openvpn\n\n'

sudo cp -p '/tmp/'{server.crt,ca.crt} '/etc/openvpn/server/'

echo -e ${SEP}

echo -e 'CREATING TLS-KEY\n\n'

cd ${EASYRSA_DIR}

openvpn --genkey --secret 'ta.key'

sudo cp -p 'ta.key' '/etc/openvpn/server/'

echo -e ${SEP}

echo -e 'END WORK OF SCRIPT'

echo -e ${SEP}
