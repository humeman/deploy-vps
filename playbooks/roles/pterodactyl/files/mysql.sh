#!/bin/bash
set -e

if [ ! -f /state/pterodactyl/database_created ]; then
mariadb --user=root <<EOF
    CREATE USER '{{ pterodactyl["sql"]["user"] }}'@'127.0.0.1' IDENTIFIED BY '{{ pterodactyl["sql"]["password"] }}';
    CREATE DATABASE {{ pterodactyl["sql"]["db"] }};
    GRANT ALL PRIVILEGES ON {{ pterodactyl["sql"]["db"] }}.* TO '{{ pterodactyl["sql"]["user"] }}'@'127.0.0.1' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    exit
EOF

    touch /state/pterodactyl/database_created
fi