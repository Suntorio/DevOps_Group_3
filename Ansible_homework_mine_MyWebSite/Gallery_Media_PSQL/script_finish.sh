 #!/bin/bash
 
set -e  #stop running on any error
 
echo "Running Terraform destroy..."
terraform destroy -auto-approve

echo "💥 Destroyed."