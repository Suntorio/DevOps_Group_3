<Ansible Task>
create 2 instances (terraform)
add instances' external ip-addresses to hosts
$ ansible-playbook playbook.yaml -i hosts --private-key=~/Documents/PASV_DevOps/SSH-Keys/lesson_7_ansible.pem -u ubuntu
$ terraform destroy