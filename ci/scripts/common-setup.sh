#!/bin/bash

set -e

echo "-- Installing Ansible --"
sudo apt update
sudo apt install -y software-properties-common
sudo add-apt-repository --yes --update ppa:ansible/ansible
sudo apt install ansible

echo "-- Creating Ansible inventory file --"
cat << EOF > hosts
[servers]
node1 ansible_host=${SECRET_SSH_HOST_1}

[all:vars]
ansible_python_interpreter=/usr/bin/python3
EOF

echo "-- Writing SSH key --"
echo "${SSH_KEY}" > id_rsa

echo "-- Ready to go! --"