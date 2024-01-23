#!/bin/bash

set -e

. "${SCRIPT_PATH}/env-setup.sh" $1

echo "-- Installing requrements from galaxy --"
ansible-galaxy install -r "${REPO_PATH}/playbooks/requirements.yml"

echo "-- Checking playbook on environment $1 --"
ansible-playbook \
    -i ".data/inventory" \
    -e @.data/vault \
    --vault-password-file ".data/vault_k" \
    --private-key ".data/id_rsa" \
    --check \
    --diff \
    "${REPO_PATH}/playbooks/main.yml"