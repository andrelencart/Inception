#!/bin/bash
set -e

echo "[wordpress] Starting WordPress setup..."

mkdir -p /run/php

echo "[wordpress] Waiting for MariaDB..."
until mysql -h mariadb -u"${DB_USER}" -p "${DB_PASSWORD}" -e "SELECT 1;" >/dev/null 2?&1; do 
	sleep 2
done

echo "[wordpress] MariaDB is up!"

cd /var/www/html

if [! -f wp-config.php]; then
	echo "[wordpress] Downloading WordPress core.."
	wp core download --allow-root

	echo "[wordpress] Creating wp-config.php..."
	wp config create \
		--allow-root \
		--dbname="${DB_NAME}" \
		--dbuser="${DB_USER}" \
		--dbpass="${DB_PASS}" \
		--dbhost="mariadb" \
		--path="/var/www/html"

	echo "[wordpress] Instaling WordPress..."
	wp core install \
		--allow-root \
		--url="${DOMAIN_NAME}" \
		--title="${WP_TITLE}" \
		--admin_user="${WP_ADMIN_USER}" \
		--admin_password="${WP_ADMIN_PASSWORD}" \
		--skip-email
	
	echo "[wordpress] WordPress installed"
else
	echo "[wordpress] 