#!/bin/bash

PROMETH_DIR='/etc/prometheus/'
PROMETH_RULES='rules.yml'

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

new_rule=`cat << EOF

- name: ${client}
  rules:
  - alert: CPU_Load_Average
    expr: node_load5{instance="${host_address}:9100",job="${client}"} > (count (node_cpu_seconds_total{instance="${host_address}:9100",job="${client}",mode="idle"})) * 0.85
    labels:
      severity: 'critical'
    annotations:
      summary: 'Load Average 5m > 0.85 * CPU numbers'
  - alert: ${client} Instance UP/DOWN
    expr: up{instance="${host_address}:9100",job="${client}"} != 1
    labels:
      severity: 'critical'
    annotations:
      summary: '${client} is DOWN'
  - alert: Memory
    expr: (node_memory_MemTotal_bytes{instance="${host_address}:9100",job="${client}"} - node_memory_MemAvailable_bytes{instance="${host_address}:9100",job="${client}"}) / node_memory_MemTotal_bytes{instance="${host_address}:9100",job="${client}"} * 100 > 85
    for: 1m
    labels:
      severity: 'critical'
    annotations:
      summary: 'Available memory < 15% for more than 1 min'
EOF`

#add new rules to rules.yml
echo -e "$new_rule" | sudo tee -a ${PROMETH_DIR}${PROMETH_RULES}

#check if script waas executed without errors
if [ $? == 0  ]; then
	echo 'Script ended work successfully.'
	exit 0
else
	echo 'Script terminated with errors.'
	exit 1
fi
