#!/bin/bash
set -e

echo "[wordpress] Starting WordPress setup..."

mkdir -p /run/php

echo "[wordpress] Waiting for MariaDB..."
until mysql -h mariadb -u"${DB_USER}" -p"${DB_PASSWORD}" -e "SELECT 1;" >/dev/null 2>&1; do
  sleep 2
done
echo "[wordpress] MariaDB is up!"

cd /var/www/html

if [ ! -f wp-load.php ]; then
	echo "[wordpress] Downloading WordPress core..."
	wp core download --allow-root
fi

if [ ! -f wp-config.php ]; then
	echo "[wordpress] Creating wp-config.php..."
	wp config create \
		--allow-root \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASSWORD}" \
		--dbhost="mariadb" \
		--path="/var/www/html"
fi
if ! wp core is-installed --allow-root --path="/var/www/html" >/dev/null 2>&1; then
	echo "[wordpress] Installing WordPress..."
	echo "[wordpress] WP_ADMIN_EMAIL=[$WP_ADMIN_EMAIL]"

	wp core install \
		--allow-root \
		--url="${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--admin_email="${WP_ADMIN_EMAIL}" \
		--skip-email

	echo "[wordpress] Creating second user..."
	wp user create \
		--allow-root \
		"${WP_USER}" "${WP_USER_EMAIL}" \
		--user_pass="${WP_USER_PASSWORD}" \
		--role=author || true

	echo "[wordpress] WordPress installed"
else
	echo "[wordpress] WordPress already installed, skipping install"
fi

chown -R www-data:www-data /var/www/html

echo "[wordpress] Starting php-fpm..."
exec php-fpm7.4 -F