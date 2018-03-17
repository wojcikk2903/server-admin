#!/bin/bash
#This script updates the hosts file in /etc/ansible/hosts with a list of droplets from DigitalOcean
HOSTS_PATH="/etc/ansible/hosts"
echo -e "#this file is generated by script update_do_hosts.sh" > $HOSTS_PATH
#static row with backup server on OVH
echo "[backup]" >> $HOSTS_PATH
echo "backup01.prod.uk1.ovh.nclab.com" >> $HOSTS_PATH

echo "[production]" >> $HOSTS_PATH
doctl compute droplet list --no-header --tag-name production --format Name >> $HOSTS_PATH

echo "[development]" >> $HOSTS_PATH
doctl compute droplet list --no-header --tag-name development --format Name >> $HOSTS_PATH

