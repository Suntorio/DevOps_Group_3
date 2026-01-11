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

Let's Encrypt Certification
1. $ sudo apt update
2. $ sudo apt install certbot python3-certbot-apache
3. $ sudo certbot --apache
Account registered.
Please enter the domain name(s) you would like on your certificate (comma and/or
space separated) (Enter 'c' to cancel): alex-tech.us
Requesting a certificate for alex-tech.us

Successfully received certificate.
Certificate is saved at: /etc/letsencrypt/live/alex-tech.us/fullchain.pem
Key is saved at:         /etc/letsencrypt/live/alex-tech.us/privkey.pem
This certificate expires on 2025-10-21.
These files will be updated when the certificate renews.
Certbot has set up a scheduled task to automatically renew this certificate in the background.

Deploying certificate
Successfully deployed certificate for alex-tech.us to /etc/apache2/sites-available/000-default-le-ssl.conf
Congratulations! You have successfully enabled HTTPS on https://alex-tech.us

GITHUB TEST!