#!/bin/bash

RG=$(grep org_name variables.tf -A2 | tail -1 | cut -d '"' -f2)
IPADDR=$(az network public-ip show --resource-group $RG --name ad_pubip | jq -r .ipAddress)
jq -n '{"ip":"'$IPADDR'"}'
