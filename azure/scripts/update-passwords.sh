#!/bin/bash

PASSWORD=$1

sed -e "s/PASSWORD/$PASSWORD/g" scripts/configure-systems.sh.bak > scripts/configure-systems.sh
chmod +x scripts/configure-systems.sh
sed -e "s/PASSWORD/$PASSWORD/g" playbooks/dc.yml.bak > playbooks/dc.yml
sed -e "s/PASSWORD/$PASSWORD/g" playbooks/wkstn.yml.bak > playbooks/wkstn.yml
sed -e "s/PASSWORD/$PASSWORD/g" playbooks/ubuntu.yml.bak > playbooks/ubuntu.yml
