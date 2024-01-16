#!/bin/bash

set -e

echo "-- Expanding host variables --"
export SSH_USER="SSH_USER_$1"
export SSH_KEY="SSH_KEY_$1"
export SSH_HOST="SSH_HOST_$1"
export SSH_SUDO="SSH_SUDO_$1"
export ANSIBLE_VAULT_K="ANSIBLE_VAULT_K_$1"
export SA="SA_$1"
export BUCKET="BUCKET_$1"

echo "-- Writing keys --"
echo "${!SSH_KEY}" > id_rsa
chmod 0600 id_rsa
echo "${!SSH_SUDO}" > sudo
echo "${!ANSIBLE_VAULT_K}" > vault_k

echo "-- Creating inventory --"
cat << EOF > inventory
[servers]
${!SSH_HOST} ansible_user=${!SSH_USER} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "-- Authenticating SA --"
echo "${!SA}" > service.json
gcloud auth activate-service-account --key-file=service.json

echo "-- Downloading vault --"
gsutil cp gs://${!BUCKET}/vault .

echo "-- Cleaning up --"
rm service.json
gcloud auth revoke --all
unset ${SA}
unset ${BUCKET}
unset ${ANSIBLE_VAULT_K}
unset ${SSH_KEY}
unset ${SSH_SUDO}

echo "-- Ready to go! --"