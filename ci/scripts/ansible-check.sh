#!/bin/bash

set -e

. main/ci/scripts/env-setup.sh $1

echo "-- Checking playbook on environment $1 --"
ansible-playbook \
    -i inventory \
    -u "${!SSH_USER}" \
    -e @vault \
    --vault-password-file vault_k \
    --private-key id_rsa \
    --become-user root \
    --become-password-file sudo \
    --check \
    --diff \
    pr/playbooks/main.yml