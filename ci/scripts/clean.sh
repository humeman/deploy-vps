#!/bin/bash

set -e

# We will not rm -r here for safety reasons. Just remove any files we know we may have created.

if [ -f ".data/id_rsa" ]; then
    rm ".data/id_rsa"
fi

if [ -f ".data/inventory" ]; then
    rm ".data/inventory"
fi

if [ -f ".data/sudo" ]; then
    rm ".data/sudo"
fi

if [ -f ".data/vault_k" ]; then
    rm ".data/vault_k"
fi

if [ -f ".data/service.json" ]; then
    rm ".data/service.json"
fi