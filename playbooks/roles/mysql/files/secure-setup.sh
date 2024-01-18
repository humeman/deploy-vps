#!/bin/bash

mariadb --user=root <<EOF
  SELECT GROUP_CONCAT(QUOTE(user),'@',QUOTE(host)) INTO @accounts FROM mysql.user WHERE user = 'root' AND host NOT IN ('localhost', '127.0.0.1', '::1');
  DELIMITER //
  IF (@accounts IS NOT NULL) THEN
    BEGIN
      EXECUTE IMMEDIATE CONCAT('DROP USER ', @accounts);
    END;
  END IF //

  SELECT GROUP_CONCAT(QUOTE(user),'@',QUOTE(host)) INTO @accounts1 FROM mysql.user WHERE user IN ('', ' ');
  IF (LENGTH(@accounts1) > 0) THEN
    BEGIN
      EXECUTE IMMEDIATE CONCAT('DROP USER ', @accounts1);
    END;
  END IF //

  DELIMITER ;

  DROP DATABASE IF EXISTS test;
  DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';
  FLUSH PRIVILEGES;
EOF