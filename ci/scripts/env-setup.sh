#!/bin/bash

set -e

echo "-- Expanding host variables --"
export SSH_USER="SSH_USER_$1"
export SSH_KEY="SSH_KEY_$1"
export SSH_HOST="SSH_HOST_$1"
export SSH_SUDO="SSH_SUDO_$1"

echo "-- Writing keys --"
echo "${!SSH_KEY}" > id_rsa
echo "${!SSH_SUDO}" > sudo

echo "-- Ready to go! --"