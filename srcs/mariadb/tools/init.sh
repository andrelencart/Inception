#!/bin/bash
set -e

mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

# Initialize if marker is missing OR mysql system database directory is missing
if [ ! -f "/var/lib/mysql/.initialized" ] || [ ! -d "/var/lib/mysql/mysql" ]; then
  echo "[mariadb] Initializing database..."
  mariadb-install-db --user=mysql --datadir=/var/lib/mysql

  echo "[mariadb] Starting temporary server..."
  mysqld_safe --skip-networking &
  pid="$!"

  while ! mariadb-admin ping --silent; do sleep 1; done

  echo "[mariadb] Creating database and user..."
  mariadb -u root <<-EOSQL
    CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;
    CREATE USER IF NOT EXISTS '${DB_USER}'@'%' IDENTIFIED BY '${DB_PASSWORD}';
    GRANT ALL PRIVILEGES ON \`${DB_NAME}\`.* TO '${DB_USER}'@'%';
    ALTER USER 'root'@'localhost' IDENTIFIED BY '${DB_ROOT_PASSWORD}';
    FLUSH PRIVILEGES;
EOSQL

  echo "[mariadb] Shutting down temporary server..."
  mariadb-admin -u root -p"${DB_ROOT_PASSWORD}" shutdown

  wait "$pid" || true

  touch /var/lib/mysql/.initialized
  echo "[mariadb] Initialization complete."
else
  echo "[mariadb] Database already initialized, skipping setup."
fi

echo "[mariadb] Starting MariaDB..."
exec mysqld --user=mysql --datadir=/var/lib/mysql