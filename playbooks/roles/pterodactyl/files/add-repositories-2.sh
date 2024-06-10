#!/bin/bash
set -e

if [ ! -f /state/pterodactyl/composer_setup ]; then
    curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
fi