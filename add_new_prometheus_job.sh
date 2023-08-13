#!/bin/bash

PROMETH_DIR='/etc/prometheus/'
PROMETH_CONF='prometheus.yml'

#read script parameters
while [ -n "$1" ]
do
	case "$1" in
		--client) client="$2"
		shift;;
		--ip) host_address="$2"
		shift;;
	esac
	shift
done

#check if all necessary parameters were given
if [ -z "$client" ] || [ -z "$host_address" ]; then
	echo 'Invalid input parameters! Script terminated.'
	exit 1
fi

new_job=`cat << EOF

  - job_name: ${client}
    static_configs:
      - targets: ['${host_address}']
EOF`

#add new job to prometheus.yml
echo -e "$new_job" | sudo tee -a ${PROMETH_DIR}${PROMETH_CONF}

#check if script waas executed without errors
if [ $? == 0  ]; then
	echo 'Script ended work successfully.'
	exit 0
else
	echo 'Script terminated with errors.'
	exit 1
fi
