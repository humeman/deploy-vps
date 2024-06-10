<?php
$CONF['configured'] = true;
$CONF['database_type'] = 'mysqli';
$CONF['database_host'] = '127.0.0.1';
$CONF['database_port'] = '3306';
$CONF['database_user'] = '{{ mail["postfixadmin"]["sql_user"] }}';
$CONF['database_password'] = '{{ mail["postfixadmin"]["sql_password"] }}';
$CONF['database_name'] = '{{ mail["postfixadmin"]["sql_db"] }}';
$CONF['encrypt'] = 'dovecot:ARGON2I';
$CONF['dovecotpw'] = "/usr/bin/doveadm pw -r 5";
if(@file_exists('/usr/bin/doveadm')) { // @ to silence openbase_dir stuff; see https://github.com/postfixadmin/postfixadmin/issues/171
    $CONF['dovecotpw'] = "/usr/bin/doveadm pw -r 5"; # debian
}
$CONF['setup_password'] = '{{ pfa_hash_file_content.content | b64decode }}';
$CONF['password_validation'] = array(
    '/.{12}/'                => 'password_too_short 512',      # minimum length 5 characters
    '/([a-zA-Z].*){3}/'      => 'password_no_characters 3',  # must contain at least 3 characters
);