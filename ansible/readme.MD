# Ansible
There are all scripts and playbooks for Ansible

### change_password_general.yaml
When you get a request to change user's password, run this playbook. It will ask you for username and hash of encrypted password

### change_root_password.ayml
An encrypted playbook will change root's password. First you have to create sha-512 hash by **mkpasswd -m sha-512 <password>** and insert it into playbook.

### default_config.yaml
This playbook will run initial config for a new droplet. It will set SSH server, timezone, remove UFW firewall,install basic SW and utilities and primarily add all NCLab users with their SSH pubkeys.

### disable_user.yaml
This playbook will disable user's login to all servers, remove SSH pubkey from his home and from lab's + root's home directories. 

### nclab_passwd.sh
This script is located on pass.nclab.com where you can run it as nclab_passwd command. It will verify your old password and from the new one it will make sha-512 hash and save it to the /tmp . All administrators will get email with password's change request.

### sshd_config_template
This file is used as template for default_config.yaml playbook

### update_do_hosts.sh
The script will update /etc/ansible/hosts with names of all droplets from Digial Ocean. You need for execute and DO API key.



