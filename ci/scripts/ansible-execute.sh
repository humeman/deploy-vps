#!/bin/bash

set -e

. main/ci/scripts/env-setup.sh $1

echo "-- Executing playbook on environment $1 --"
ansible-playbook -i "${!SSH_HOST}" -u "${!SSH_USER}" --private-key id_rsa --become-password-file sudo pr/ansible/main.yml