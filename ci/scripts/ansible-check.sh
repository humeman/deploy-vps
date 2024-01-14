#!/bin/bash

ansible-playbook -i hosts -u ${SSH_USER} pr/ansible/main.yml