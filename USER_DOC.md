# USER_DOC.md

## User documentation

This document explains how an end user or administrator can use the Inception stack.

## Services provided by the stack

This project provides a small WordPress website infrastructure using Docker Compose.

The stack contains three services:

* **Nginx**: the only public entrypoint. It listens on port `443` and serves the website through HTTPS.
* **WordPress**: runs WordPress with PHP-FPM. It handles the website application.
* **MariaDB**: stores the WordPress database.

The containers communicate through a dedicated Docker network called `inception`.

## Starting the project

From the root of the repository, run:

```bash
make up
```

To rebuild the images and start the project, run:

```bash
make build
```

## Stopping the project

To stop the containers without deleting them, run:

```bash
make stop
```

To stop and remove the containers and network, run:

```bash
make down
```

## Accessing the website

The website is available through HTTPS:

```text
https://andcarva.42.fr
```

If the domain does not resolve inside the virtual machine, add it to `/etc/hosts`:

```bash
echo "127.0.0.1 andcarva.42.fr" | sudo tee -a /etc/hosts
```
If accessing the site from outside the VM, replace `127.0.0.1` with the VM IP address.

If a self-signed certificate is used, the browser may show a warning. This is expected for this project.

## Accessing the WordPress administration panel

The WordPress administration panel is available at:

```text
https://andcarva.42.fr/wp-admin
```

The administrator credentials are configured in the `.env` file using:

```env
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=
```

The administrator username must not contain `admin`, `Admin`, `administrator`, or `Administrator`.

## Locating and managing credentials

Runtime configuration is stored in the `.env` file used by Docker Compose.

Important variables include:

```env
DOMAIN_NAME=

DB_NAME=
DB_USER=
DB_PASSWORD=
DB_ROOT_PASSWORD=

WP_TITLE=
WP_ADMIN_USER=
WP_ADMIN_PASSWORD=
WP_ADMIN_EMAIL=

WP_USER=
WP_USER_EMAIL=
WP_USER_PASSWORD=
```

Credentials must not be committed to Git. The `.env` file and any secrets or password files should remain local and should be ignored by Git.

## Checking that services are running

To check the container status, run:

```bash
make ps
```

Or use Docker Compose directly:

```bash
cd srcs
docker-compose ps
```

Expected running containers:

* `nginx`
* `wordpress`
* `mariadb`

## Checking logs

To view logs for all services, run:

```bash
make logs
```

To view logs for a specific service, run:

```bash
docker logs nginx
docker logs wordpress
docker logs mariadb
```

## Testing the website

To test HTTPS from the command line, run:

```bash
curl -kI https://andcarva.42.fr
```

A successful response should show an HTTP status from Nginx/WordPress.

## Checking WordPress installation

To check that WordPress is installed and that users exist, run:

```bash
docker exec -it wordpress sh -lc 'cd /var/www/html && wp core is-installed --allow-root && wp user list --allow-root'
```

## Checking the database

To check that MariaDB is reachable and that the WordPress database exists, run:

```bash
docker exec -it mariadb sh -lc 'mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;"'
```

To check WordPress tables:

```bash
docker exec -it mariadb sh -lc 'mysql -u"$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SHOW TABLES;"'
```

## Persistent data

Project data is stored under:

```text
/home/andcarva/data
```

MariaDB database data is stored in:

```text
/home/andcarva/data/mariadb
```

WordPress website files are stored in:

```text
/home/andcarva/data/wordpress
```

This allows containers to be removed and rebuilt without losing the website or database data, unless the persistent data directories are explicitly deleted.

## Full reset

To fully reset the project and delete persistent data, run:

```bash
make fclean
```

Then rebuild and start the project:

```bash
make build
```

Or run:

```bash
make re
```
