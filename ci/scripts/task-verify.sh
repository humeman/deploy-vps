#!/bin/bash

if [ -z "$ENV" ]; then
    echo "ENV must be defined."
    exit 1
fi

SECRETS="SECRETS_$ENV"
if [ -z "${!SECRETS}" ]; then
    echo "SECRETS_$ENV must be defined."
    exit 1
fi

if [ -z "$(which gsutil)" ]; then
    echo "gsutil must be installed."
    exit 1
fi

if [ -z "$(which ansible-playbook)" ]; then
    echo "ansible-playbook must be installed."
    exit 1
fi

if [ -z "$(which ansible-galaxy)" ]; then
    echo "ansible-galaxy must be installed."
    exit 1
fi

if [ -z "$(which jq)" ]; then
    echo "jq must be installed."
    exit 1
fi

if [ -z "$(which base64)" ]; then
    echo "base64 must be installed."
    exit 1
fi