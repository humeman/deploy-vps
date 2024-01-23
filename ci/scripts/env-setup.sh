#!/bin/bash

set -e

if [ -z "${1}" ]; then
    echo "Required parameter: env (DEV or PROD)"
    exit 1
fi

echo "-- Expanding host variables --"
if [ ! -d ".data" ]; then
    mkdir ".data"
fi

SECRETS="SECRETS_$1"
if [ -z "${!SECRETS}" ]; then
    echo "Secrets are unset: $SECRETS"
    exit 1
fi
JSON=$(echo "${!SECRETS}" | base64 --decode)

SSH_USER=$(echo $JSON | jq -r '.user')
SSH_HOST=$(echo $JSON | jq -r '.host')
SSH_SUDO=$(echo $JSON | jq -r '.sudo')
echo $JSON | jq -r '.key' | base64 --decode > ".data/id_rsa"
echo "" >> ".data/id_rsa"
chmod 0600 ".data/id_rsa"

BUCKET=$(echo $JSON | jq -r '.bucket')
if [ "${AUTH_GCLOUD:-0}" -eq "1" ]; then
    echo $JSON | jq -r '.sa' | base64 --decode > ".data/service.json"
fi

echo $JSON | jq -r '.vault_k' > ".data/vault_k"

unset ${SECRETS}
unset JSON

echo "-- Creating inventory --"
cat << EOF > ".data/inventory"
[servers]
${SSH_HOST} ansible_user=${SSH_USER} ansible_become_password=${SSH_SUDO} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF
unset SSH_HOST
unset SSH_SUDO
unset SSH_USER

if [ "${AUTH_GCLOUD:-0}" -eq "1" ]; then
    echo "-- Authenticating SA --"
    gcloud auth activate-service-account --key-file=.data/service.json
    rm ".data/service.json"
fi

echo "-- Downloading vault --"
gsutil cp gs://${BUCKET}/${REPO_NAME}/vault .data/
if [ "${AUTH_GCLOUD:-0}" -eq "1" ]; then
    gcloud auth revoke --all
fi
unset BUCKET

echo "-- Ready to go! --"