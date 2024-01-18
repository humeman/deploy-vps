#!/bin/bash

mariadb --user=root <<EOF
  SELECT GROUP_CONCAT(QUOTE(user),'@',QUOTE(host)) INTO @accounts FROM mysql.user WHERE user = 'root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
  EXECUTE IMMEDIATE CONCAT('DROP USER ', @accounts);

  SELECT GROUP_CONCAT(QUOTE(user),'@',QUOTE(host)) INTO @accounts1 FROM mysql.user WHERE user IN ('', ' ');
  EXECUTE IMMEDIATE CONCAT('DROP USER ', @accounts1);

  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
EOF