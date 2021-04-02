#!/bin/bash

while [[ $(ADPASS=$(echo "Y" | gcloud compute reset-windows-password ad --zone=us-central1-a | grep password | awk '{print $2}')) -ne 1 ]]; do
  sleep 5
done
