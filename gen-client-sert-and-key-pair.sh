#!/bin/bash

set -e

SEP="\n\n##################################################################################################\n\n"
CLIENT_NAME=$1
EASYRSA_DIR='/usr/share/easy-rsa'
EASYRSA_IP='158.160.104.119'
OPENVPN_IP='158.160.37.149'
OPENVPN_KEY_PATH='/home/yc-user/.ssh/open-vpn-key'
EASYRSA_KEY_PATH='/home/yc-user/.ssh/easyRSA-key'

echo -e ${SEP}

echo -e 'CREATING '${CLIENT_NAME}'.req AND '${CLIENT_NAME}'.key'

cd ${EASYRSA_DIR}
./easyrsa gen-req ${CLIENT_NAME} nopass

mkdir -p ~/client-configs/keys

sudo cp ${EASYRSA_DIR}/pki/private/${CLIENT_NAME}.key ~/client-configs/keys

echo -e ${SEP}

echo -e 'SIGNING '${CLIENT_NAME}'.req'

scp -i ${OPENVPN_KEY_PATH} ${EASYRSA_DIR}/pki/reqs/${CLIENT_NAME}.req yc-user@${EASYRSA_IP}:/tmp/

ssh -i ${OPENVPN_KEY_PATH} yc-user@${EASYRSA_IP} <<ENDSSH

cd /usr/share/easy-rsa/

./easyrsa import-req '/tmp/${CLIENT_NAME}.req' ${CLIENT_NAME}
echo yes | ./easyrsa sign-req 'client' ${CLIENT_NAME}

scp -i ${EASYRSA_KEY_PATH} /usr/share/easy-rsa/pki/issued/${CLIENT_NAME}.crt yc-user@${OPENVPN_IP}:/tmp

ENDSSH

echo -e ${SEP}

echo -e 'COPYING SIGNED '${CLIENT_NAME}'.req, ta.key AND ca.crt TO ~/clients-configs/keys/'

cp /tmp/${CLIENT_NAME}.crt ~/client-configs/keys/

cp ${EASYRSA_DIR}/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/server/ca.crt ~/client-configs/keys/

echo -e ${SEP}

echo -e 'END WORK OF SCRIPT'

echo -e ${SEP}

exit 0
