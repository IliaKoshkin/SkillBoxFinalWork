#!/bin/bash

set -e

usage=$(cat <<EOF01

NAME

    create_vm_in_cloud.sh script creates a VM in Yandex Cloud 

SYNOPSIS

    create_vm_in_cloud.sh [options]

DESCRIPTION

    The script creates a virtual machine on ubuntu-2004-lts in Yandex CLoud "cloud-ilkosh" (ID b1gdq6p61r5hrt6ajfp2) with defined RAM and CPU number.

	--memory - RAM size in GB,
	--name - VM name,
	--cpu - number of CPUs

EXAMPLES

    Create VM with name "server_01", RAM=2G, CPU number=2:

    	create_vm_in_cloud.sh --memory 2 --name server_01 --cpu 2

AUTHOR

   ilkosh


EOF01
)

yc_parameters=''

check_key_pair_exists() {
	if [ -f "/home/ilkosh/.ssh/yacloud_key_id_01.pub" ] && [ -f "/home/ilkosh/.ssh/yacloud_key_id_01"  ]; then
		true
	else
		echo "Not found valid key pair 'yacloud_key_id_01' and 'yacloud_key_id_01.pub' in ~/.ssh! Script terminated with error!"
		false
	fi
}

#exec yc with parameters to create VM
yc_command() {

	yc compute instance create $*

}


if [ $# -eq 0 ]; then
	echo "$usage"
	exit 0
fi

#check if valid key pair exists
if ! check_key_pair_exists; then
	exit 1
fi

#handle parameters
while [ -n "$1" ]
do
        case "$1" in
                --memory) memory="$2"
                shift;;
                --name) name="$2"
                shift;;
		--cpu) cpu_numb="$2"
		shift;;
        esac
        shift
done

#check if all necessary parameters were given
if [ -z "$name" ]; then
        echo 'Name of the VM  to be created must be declared!'
        exit 1
fi
#use default parameters for memory amd cpu if they were not given
if [ -z "$memory" ]; then
	memory=2
fi
if [ -z "$cpu_numb" ]; then
	cpu_numb=2
fi

yc_parameters=$(cat <<EOF02
--name ${name} \
--zone ru-central1-a \
--memory ${memory}G \
--cores ${cpu_numb} \
--network-interface subnet-name=default-ru-central1-a,nat-ip-version=ipv4 \
--create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2004-lts \
--ssh-key /home/ilkosh/.ssh/yacloud_key_id_01.pub
EOF02
)

while true; do
	read -p "$(echo -e "Create VM with command below?\n\n$yc_parameters\n\n(y/n?):")" answ
	if [ $answ = y ] || [ $answ = Y ] || [ $answ = n ] || [ $answ = N ]; then
		break
	fi
	echo "Invalid command! Must be Y, y, N or n. Try again."
done

if [ $answ = Y ] || [ $answ = y  ]; then
	echo "START CREATING VM..."

	yc_command "$yc_parameters"

	echo "VM "${name}" WAS CREATED SUCCESSFULLY!"
	echo "INFO ABOUT VM:"

	yc compute instance get ${name}
else
	echo "CANCELED"
fi

exit 0
