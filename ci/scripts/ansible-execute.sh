#!/bin/bash

set -e

. main/ci/scripts/env-setup.sh $1

echo "-- Executing playbook on environment $1 --"
ansible-playbook \
    -i inventory \
    -u "${!SSH_USER}" \
    -e @vault \
    --vault-password-file vault_k \
    --private-key id_rsa \
    --become-password-file sudo \
    main/playbooks/main.yml