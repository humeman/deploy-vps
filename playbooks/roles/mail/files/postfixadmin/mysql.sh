#!/bin/bash
set -e

if [ ! -f /state/mail/postfixadmin_database_created ]; then
mariadb --user=root <<EOF
    CREATE USER '{{ mail["postfixadmin"]["sql_user"] }}'@'127.0.0.1' IDENTIFIED BY '{{ mail["postfixadmin"]["sql_password"] }}';
    CREATE DATABASE {{ mail["postfixadmin"]["sql_db"] }};
    GRANT ALL PRIVILEGES ON {{ mail["postfixadmin"]["sql_db"] }}.* TO '{{ mail["postfixadmin"]["sql_user"] }}'@'127.0.0.1' WITH GRANT OPTION;
    FLUSH PRIVILEGES;
    exit
EOF

    touch /state/mail/postfixadmin_database_created
fi