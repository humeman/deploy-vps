#!/bin/bash
set -e

# Partially sourced from https://github.com/pterodactyl-installer/pterodactyl-installer/blob/master/installers/panel.sh
if [ ! -f /state/pterodactyl/panel_setup ]; then
    cd /var/www/pterodactyl

    cp .env.example .env
    COMPOSER_ALLOW_SUPERUSER=1 composer install --no-dev --optimize-autoloader

    php artisan key:generate --force

    php artisan p:environment:setup \
        --author="{{ pterodactyl["user"]["email"] }}" \
        --url="https://{{ pterodactyl["panel_host"] }}" \
        --timezone="America/Chicago" \
        --cache="redis" \
        --session="redis" \
        --queue="redis" \
        --redis-host="localhost" \
        --redis-pass="null" \
        --redis-port="6379" \
        --settings-ui=true \
        --telemetry=false

    php artisan p:environment:database \
        --host="127.0.0.1" \
        --port="3306" \
        --database="{{ pterodactyl["sql"]["db"] }}" \
        --username="{{ pterodactyl["sql"]["user"] }}" \
        --password="{{ pterodactyl["sql"]["password"] }}"

    php artisan migrate --seed --force

    php artisan p:user:make \
        --email="{{ pterodactyl["user"]["email"] }}" \
        --username="{{ pterodactyl["user"]["username"] }}" \
        --name-first="{{ pterodactyl["user"]["first"] }}" \
        --name-last="{{ pterodactyl["user"]["last"] }}" \
        --password="{{ pterodactyl["user"]["password"] }}" \
        --admin=1

    touch /state/pterodactyl/panel_setup
fi

if [ ! -f /state/pterodactyl/data_chowned ]; then
    chown -R www-data:www-data /var/www/pterodactyl/*
fi