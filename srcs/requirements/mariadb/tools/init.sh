#!/bin/bash
set -e

DB_PASSWORD="$(cat /run/secrets/db_password)"
DB_ROOT_PASSWORD="$(cat /run/secrets/db_root_password)"
export DB_PASSWORD DB_ROOT_PASSWORD

mkdir -p /run/mysqld
chown -R mysql:mysql /var/lib/mysql
chown -R mysql:mysql /run/mysqld

# Initialize only when the MariaDB system database does not exist
if [ ! -d "/var/lib/mysql/mysql" ]; then
	echo "[mariadb] Initializing database..."

	mariadb-install-db \
		--user=mysql \
		--datadir=/var/lib/mysql

	echo "[mariadb] Creating database and user..."

	mariadbd \
		--bootstrap \
		--user=mysql \
		--datadir=/var/lib/mysql <<-EOSQL
			FLUSH PRIVILEGES;

			CREATE DATABASE IF NOT EXISTS \`${DB_NAME}\`;

			CREATE USER IF NOT EXISTS '${DB_USER}'@'%'
			IDENTIFIED BY '${DB_PASSWORD}';

			GRANT ALL PRIVILEGES
			ON \`${DB_NAME}\`.*
			TO '${DB_USER}'@'%';

			ALTER USER 'root'@'localhost'
			IDENTIFIED BY '${DB_ROOT_PASSWORD}';

			FLUSH PRIVILEGES;
	EOSQL

	touch /var/lib/mysql/.initialized
	chown mysql:mysql /var/lib/mysql/.initialized

	echo "[mariadb] Initialization complete."
else
	echo "[mariadb] Database already initialized, skipping setup."
fi

echo "[mariadb] Starting MariaDB..."

exec mariadbd \
	--user=mysql \
	--datadir=/var/lib/mysql