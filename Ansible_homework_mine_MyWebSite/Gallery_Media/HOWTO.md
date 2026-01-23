MY GOAL:
a. To build my private web site with gallery (photos and videos are about 50GB)
b. I want to do it with DevOps best practices based on AWS
b1. What is CloudFront?
c. My media files are going to be uploaded to S3 Bucket
d. I'm going to use Terraform and Ansible
e. Nginx web-server will be used on my EC2 instance
f. Elastic IP:
    * Running vs. Stopped: There is no longer a price "discount" for having the IP attached to a running instance. You pay the $0.005/hour regardless of the instance state.
    * EBS Costs: Remember that while your instance is stopped, you are still being charged for the EBS storage (disk) attached to that instance (usually ~$0.08–$0.10 per GB per month for gp3 volumes), in addition to the Elastic IP cost.
    * Release vs. Stop: If you don't need the static IP while the server is off, you should Disassociate and then Release the IP to stop the charges entirely. Simply stopping the  instance will not stop the IP billing.

Solution:  

1.  Deploy an instance with Terraform
    * Create an EC2
    * Request a new Elastic IP  
    * Assign the Elastic IP to the EC2
 
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