#!/bin/sh

SERVER="$1"
METADATA="$2"
HOST="$3"

if [ -z "$SERVER" ]; then
    echo "Server address is missing"
    exit 1
fi

if [ -z "$METADATA" ]; then
    echo "Host metadata is missing"
    exit 1
fi

if [ -z "$HOST" ]; then
    MACHINEID=$(cat /etc/machine-id)
    HOST="$METADATA-$MACHINEID"
fi

sed -i "s/^Server\=.*/Server\=$SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^ServerActive\=.*/ServerActive\=$SERVER/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^Hostname\=.*/Hostname\=$HOST/" /etc/zabbix/zabbix_agentd.conf
sed -i "s/^HostMetadata\=.*/HostMetadata\=$METADATA/" /etc/zabbix/zabbix_agentd.conf

if [ -f "/etc/zabbix/$HOST.conf" ]; then
    cat "/etc/zabbix/$HOST.conf" >> /etc/zabbix/zabbix_agentd.conf
fi

if [ "$MONITOR_DC" = "true" ]; then
  cp /root/zabbix_module_docker.so /usr/lib/modules-load.d/
  cat <<EOF > /etc/zabbix/zabbix_agentd.conf.d/docker-module.conf
LoadModulePath=/usr/lib/modules-load.d/
LoadModule=zabbix_module_docker.so
AllowRoot=1
EOF
fi

exec /usr/bin/supervisord
