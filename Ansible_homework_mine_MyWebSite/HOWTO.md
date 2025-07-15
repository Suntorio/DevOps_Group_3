1.  Deploy an instance with Terraform

$ terraform init
$ terraform plan
$ terraform apply

2.  Ansible is an open-source automation tool used for configuration management, application deployment, and task automation.
    It simplifies IT automation by using a declarative approach, allowing users to define what needs to be done rather than how to do it.

Example:
*Create an inventory file (inventory.ini):
[web_servers]
server1 ansible_host=192.168.1.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa

*Run the playbook
$ ansible-playbook -i inventory.ini nginx_setup.yml
OR
$ ansible-playbook playbook.yaml -i hosts --private-key=~/Documents/PASV_DevOps/SSH-Keys/lesson_7_ansible.pem -u ubuntu #IT WORKS!
________________________________________________________________________________________
IF WE CREATE ansible.cfg then:
$ ansible-playbook playbook.yaml

04/16/2025 SUMMARY: WORKING APACHE SERVER WEBSITE WITH HTTPS (INSECURE)!

$$$ All files and folders on S3 Bucket are JUST LINKS to S3 Bucket storage! $$$