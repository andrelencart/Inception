#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

if [ ! -d "/var/lib/mysql/mysql" ]; then
	mariadb-install-db --user=mysql --datadir=/var/lib/mysql

	mysqld_safe --skip-networking &
	pid="$!"

	while ! mariadb-admin ping --silent; do sleep 1; done

	 mariadb -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${MYSQL_DATABASE}\`;
    CREATE USER IF NOT EXISTS '${MYSQL_USER}'@'%' IDENTIFIED BY '${MYSQL_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${MYSQL_DATABASE}\`.* TO '${MYSQL_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${MYSQL_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

  echo "[mariadb] Shutting down temporary server..."
  mariadb-admin -u root -p"${MYSQL_ROOT_PASSWORD}" shutdown

  wait "$pid" || true
fi

echo "[mariadb] Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql