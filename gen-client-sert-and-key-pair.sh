#!/bin/bash

SEP="\n\n##################################################################################################\n\n"
CLIENT_NAME=$1
EASYRSA_IP='158.160.104.119'
OPENVPN_IP='158.160.37.149'
OPENVPN_KEY_PATH='/home/yc-user/.ssh/open-vpn-key'
EASYRSA_KEY_PATH='/home/yc-user/.ssh/easyRSA-key'

echo -e ${SEP}

echo -e 'CREATING '${CLIENT_NAME}'.req AND '${CLIENT_NAME}'.key'

cd ~/easy-rsa/
./easyrsa gen-req ${CLIENT_NAME} nopass

mkdir -p ~/client-configs/keys

cp pki/private/${CLIENT_NAME}.key ~/client-configs/keys

echo -e ${SEP}

echo -e 'SIGNING '${CLIENT_NAME}'.req'

scp -i ${OPENVPN_KEY_PATH} pki/reqs/${CLIENT_NAME}.req yc-user@${EASYRSA_IP}:/tmp/

ssh -i ${OPENVPN_KEY_PATH} yc-user@${EASYRSA_IP} <<ENDSSH

cd /home/yc-user/easy-rsa/

./easyrsa import-req '/tmp/${CLIENT_NAME}.req' ${CLIENT_NAME}
echo yes | ./easyrsa sign-req 'client' ${CLIENT_NAME}

scp -i ${EASYRSA_KEY_PATH} pki/issued/${CLIENT_NAME}.crt yc-user@${OPENVPN_IP}:/tmp

ENDSSH

echo -e ${SEP}

echo -e 'COPYING SIGNED '${CLIENT_NAME}'.req, ta.key AND ca.crt TO ~/clients-configs/keys/'

cp /tmp/${CLIENT_NAME}.crt ~/client-configs/keys/

cp ~/easy-rsa/ta.key ~/client-configs/keys/
sudo cp /etc/openvpn/server/ca.crt ~/client-configs/keys/

echo -e ${SEP}

echo -e 'END WORK OF SCRIPT'

echo -e ${SEP}

