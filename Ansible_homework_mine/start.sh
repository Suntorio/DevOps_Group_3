#!/bin/bash

set -e  #stop running on any error
 
echo "Running Terraform apply..."
terraform apply -auto-approve

echo "Waiting 5 seconds to ensure state is written..."
sleep 5

echo "Generating Ansible inventory..."
./generate_inventory_with_clean.sh

echo "Running Ansible playbook..."
ansible-playbook playbook_apache_ssl.yaml

echo "✅ Done."