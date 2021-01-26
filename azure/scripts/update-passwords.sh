#!/bin/bash

PASSWORD=$1

sed -e "s/PASSWORD/$PASSWORD/g" scripts/configure-systems.sh.bak > scripts/configure-systems.sh
chmod +x scripts/configure-systems.sh
sed -e "s/PASSWORD/$PASSWORD/g" playbooks/dc.yml.bak > playbooks/dc.yml
sed -e "s/PASSWORD/$PASSWORD/g" playbooks/wkstn.yml.bak > playbooks/wkstn.yml
<<<<<<< HEAD
<<<<<<< HEAD
sed -e "s/PASSWORD/$PASSWORD/g" playbooks/ubuntu.yml.bak > playbooks/ubuntu.yml
=======
>>>>>>> a592c1fe94b3c53d3b11ab3004652420d0b80b6c
=======
>>>>>>> a592c1fe94b3c53d3b11ab3004652420d0b80b6c
