#!/bin/bash

set -e

echo "-- Expanding host variables --"
SECRETS="SECRETS_$1"
JSON=$(echo "${!SECRETS}" | base64 --decode)

export SSH_USER=$(echo $JSON | jq -r '.user')
SSH_HOST=$(echo $JSON | jq -r '.host')
echo $JSON | jq -r '.sudo' > sudo
echo $JSON | jq -r '.key' | base64 --decode > id_rsa
chmod 0600 id_rsa

BUCKET=$(echo $JSON | jq -r '.bucket')
echo $JSON | jq -r '.sa' | base64 --decode > service.json

echo $JSON | jq -r '.vault_k' > vault_k

unset ${SECRETS}
unset JSON

echo "-- Creating inventory --"
cat << EOF > inventory
[servers]
${SSH_HOST} ansible_user=${SSH_USER} ansible_ssh_common_args='-o StrictHostKeyChecking=no'
EOF

echo "-- Authenticating SA --"
gcloud auth activate-service-account --key-file=service.json

echo "-- Downloading vault --"
gsutil cp gs://${BUCKET}/vault .

echo "-- Cleaning up --"
rm service.json
gcloud auth revoke --all
unset BUCKET
unset SSH_HOST

echo "-- Ready to go! --"