#!/bin/bash

set -e

SEP="\n\n##################################################################################################\n\n"

EASYRSA_DIR='/home/yc-user/easy-rsa/'
EASYRSA_SCRIPT=${EASYRSA_DIR}'easyrsa'
PKI_DIR=${EASYRSA_DIR}'pki/'
OPENVPN_DIR='/etc/openvpn/'
CA_IP='158.160.104.119'
KEY='/home/yc-user/.ssh/open-vpn-key'

echo -e ${SEP}

echo -e 'CREATING A PRIVATE KEY FOR THE SERVER AND A CERTIFICATE REQUEST FILE\n\n'

cd ${EASYRSA_DIR}

${EASYRSA_SCRIPT} gen-req server nopass

echo -e ${SEP}

echo -e 'COPYING THE SERVER KEY TO THE /etc/openvpn DIR\n\n'

sudo cp -p ${PKI_DIR}'private/server.key' ${OPENVPN_DIR}'/server/'

echo -e ${SEP}

echo -e 'TRANSFERING THE server.req TO CA\n\n'

sudo scp -i ${KEY} ${PKI_DIR}'reqs/server.req' 'yc-user@'${CA_IP}':/tmp'

echo -e ${SEP}

echo -e 'END WORK OF SCRIPT'

echo -e ${SEP}

exit 0

