#!/bin/bash

# Variables
RESOURCE_GROUP=$1
WORKID=$(jq -r '.resources[] | select(.type == "azurerm_log_analytics_workspace") .instances[].attributes.workspace_id' terraform.tfstate)
WORKKEY=$(jq -r '.resources[] | select(.type == "azurerm_log_analytics_workspace") .instances[].attributes.primary_shared_key' terraform.tfstate)
TOKEN=$(pwsh -c '(New-AzWvdRegistrationInfo -ResourceGroupName cent -HostPoolName cent-pool -ExpirationTime $((get-date).ToUniversalTime().AddHours(2).ToString("yyyy-MM-ddTHH:mm:ss.fffffffZ"))).Token' | grep -v VERBOSE | tr -d '\n')

# Enable WinRM on all Windows systems
for VM in $(az vm list | jq -r '.[] | select(.osProfile.windowsConfiguration != null) .name'); do
  az vm run-command invoke -g $RESOURCE_GROUP -n $VM --command-id RunPowerShellScript --scripts "Invoke-Expression ((New-Object System.Net.Webclient).DownloadString('https://raw.githubusercontent.com/ansible/ansible/devel/examples/scripts/ConfigureRemotingForAnsible.ps1'))" 1>/dev/null
done

# Configure AD
cat << EOF > ad-hosts
[hosts:children]
ad

[ad]
EOF

AD=$(az vm list -g $RESOURCE_GROUP | jq -r '.[] | select(.storageProfile.imageReference.offer == "WindowsServer") .name')
az vm show -d -g $RESOURCE_GROUP -n $AD --query publicIps -o tsv >> ad-hosts
cat << 'EOF' >> ad-hosts
[ad:vars]
ansible_connection=winrm
ansible_ssh_port=5986
ansible_ssh_user=adminuser
ansible_ssh_pass=P@$$w0rd1234!
ansible_winrm_transport=basic
ansible_winrm_server_cert_validation=ignore
EOF
sed -e "s/DOMAIN/$RESOURCE_GROUP/g" playbooks/dc.yml.bak > playbooks/dc.yml
sed -i "s@WORKID@$WORKID@g" playbooks/dc.yml
sed -i "s@WORKKEY@$WORKKEY@g" playbooks/dc.yml
sed -i "s@TOKEN@$REGTOKEN@g" playbooks/dc.yml 
docker run --rm -v "${PWD}":/work ansible ansible-playbook -i ad-hosts playbooks/dc.yml

# Configure Workstations
cat << EOF > wkstn-hosts
[hosts:children]
wkstn

[wkstn]
EOF

WKSTNS=$(az vm list -g $RESOURCE_GROUP | jq -r '.[] | select(.storageProfile.imageReference.offer == "Windows-10") .name')
for WKSTN in $WKSTNS; do
  az vm show -d -g $RESOURCE_GROUP -n $WKSTN --query publicIps -o tsv >> wkstn-hosts
done

cat << 'EOF' >> wkstn-hosts
[wkstn:vars]
ansible_connection=winrm
ansible_ssh_port=5986
ansible_ssh_user=adminuser
ansible_ssh_pass=P@$$w0rd1234!
ansible_winrm_transport=basic
ansible_winrm_server_cert_validation=ignore
EOF

DNSADDR=$(az vm show -d -g $RESOURCE_GROUP -n $AD --query privateIps -o tsv)
sed -e "s/DOMAIN/$RESOURCE_GROUP/g" playbooks/wkstn.yml.bak > playbooks/wkstn.yml
sed -i "s/DNSADDR/$DNSADDR/g" playbooks/wkstn.yml
sed -i "s@WORKID@$WORKID@g" playbooks/wkstn.yml
sed -i "s@WORKKEY@$WORKKEY@g" playbooks/wkstn.yml
sed -i "s@TOKEN@$REGTOKEN@g" playbooks/wkstn.yml 
docker run --rm -v "${PWD}":/work ansible ansible-playbook -i wkstn-hosts playbooks/wkstn.yml
