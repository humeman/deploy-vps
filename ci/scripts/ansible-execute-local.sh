#!/bin/bash

set -e

if [ -z "$(which ansible-playbook)" ]; then
    echo "ansible-playbook must be installed."
    exit 1
fi

if [ -z "$(which ansible-galaxy)" ]; then
    echo "ansible-galaxy must be installed."
    exit 1
fi

echo "-- Installing requrements from galaxy --"
ansible-galaxy install -r "${REPO_PATH}/playbooks/requirements.yml"

echo "-- Executing playbook with local config --"
ansible-playbook \
    -i inventory \
    -e @vault.yml \
    ${ONLY_DEPLOY:+-e "only_deploy=$ONLY_DEPLOY"} \
    "${REPO_PATH}/playbooks/main.yml"
