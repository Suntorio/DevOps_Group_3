#The script that take public IP from Terraform output and put it in ansible_inventory.ini  
#!/bin/bash
# Define the Ansible inventory file
#INVENTORY_FILE="../Ansible_homework_mine/ansible_inventory.ini"
INVENTORY_FILE="../Ansible_homework_mine/hosts"

# Run terraform output to get the instance's public IPs as a space-separated list
#PUBLIC_IPS=$(terraform output -json web-address_test_instance_public_ip | jq -r '. | sub("\""; "")')
PUBLIC_IPS=$(terraform output -raw web-address_test_instance_public_ip)

  echo "Made [$INVENTORY_FILE] empty"
  echo -n > $INVENTORY_FILE           # make the inventory file empty
  echo "Added [all] to [$INVENTORY_FILE]"
  echo "[all]" >> "$INVENTORY_FILE"   # add [all] to the inventory file
   
  for IP in $PUBLIC_IPS; do
    echo "$IP" >> "$INVENTORY_FILE"
    echo "Added $IP to [$INVENTORY_FILE]"
  done