#Ansible
There are all scripts and playbooks for Ansible

###change_password_general.yaml
When you get a request to change user's password, run this playbook. It will ask you for username and hash of encrypted password

###change_root_password.ayml
An encrypted playbook will change root's password. First you have to create sha-512 hash by **mkpasswd -m sha-512 <password>** and insert it into playbook.


