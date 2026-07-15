# DEV_DOC.md

## Developer documentation

This document explains how a developer can set up, build, launch, and maintain the Inception project.

## Project overview

Inception is a Docker Compose infrastructure project that runs three services:

* **Nginx** with TLS, exposed only on port `443`.
* **WordPress** with PHP-FPM, running without Nginx.
* **MariaDB**, running as the database service.

Each service has its own Dockerfile and runs in its own container.

The containers communicate through a dedicated Docker network named `inception`.

## Repository structure

Expected project structure:

```text
.
├── Makefile
├── README.md
├── USER_DOC.md
├── DEV_DOC.md
└── srcs
    ├── docker-compose.yml
    ├── .env
    ├── nginx
    ├── wordpress
    └── mariadb
```

## Prerequisites

The development environment needs:

* A Linux virtual machine
* Docker
* Docker Compose (`docker compose` or the Docker Compose plugin)
* `make`
* `sudo` access

Check Docker:

```bash
docker --version
docker compose --version
```

## Environment setup

Create the persistent data directories on the host:

```bash
mkdir -p /home/andcarva/data/mariadb
mkdir -p /home/andcarva/data/wordpress
```
These directories are also created by `make reset-data`, `make fclean`, or `make re`.

Create or update the `.env` file inside `srcs/`.

Example variables:

```env
DOMAIN_NAME=andcarva.42.fr

DB_NAME=wordpress
DB_USER=the_database_user
DB_PASSWORD=change_this_password
DB_ROOT_PASSWORD=change_this_root_password

WP_TITLE=Inception
WP_ADMIN_USER=the_wp_admin_user
WP_ADMIN_PASSWORD=change_this_admin_password
WP_ADMIN_EMAIL=andcarva@student.42.fr

WP_USER=the_wp_user
WP_USER_EMAIL=user@student.42.fr
WP_USER_PASSWORD=change_this_user_password
```

The WordPress administrator username must not contain `admin`, `Admin`, `administrator`, or `Administrator`.

The `.env` file must not be committed to Git.

## Domain configuration

The project domain must point to the local machine.

For local testing, add this line to `/etc/hosts`:

```bash
echo "127.0.0.1 andcarva.42.fr" | sudo tee -a /etc/hosts
```

The website should then be reachable at:

```text
https://andcarva.42.fr
```

## Building and launching

From the root of the repository, build and start the project with:

```bash
make build
```

Or start existing images and containers with:

```bash
make up
```

The Makefile is responsible for using Docker Compose to build and launch the application.

## Managing the stack (Makefile Usage)

Show running containers:

```bash
make ps
```

View logs:

```bash
make logs
```

Stop containers:

```bash
make stop
```

Stop and remove containers and networks:

```bash
make down
```

Clean Docker resources used by the project:

```bash
make clean
```

Fully reset the project, including persistent data:

```bash
make fclean
```

Rebuild from scratch:

```bash
make re
```

## Docker Compose services

The Compose file defines three services:

### mariadb

The `mariadb` service stores the WordPress database.

It uses the `mariadb_data` volume mounted at:

```text
/var/lib/mysql
```

### wordpress

The `wordpress` service runs WordPress with PHP-FPM.

It uses the `wordpress_data` volume mounted at:

```text
/var/www/html
```

It connects to MariaDB using the Docker service name:

```text
mariadb
```

### nginx

The `nginx` service is the only public entrypoint.

It exposes:

```text
443:443
```

It forwards PHP requests to the WordPress container through FastCGI:

```text
wordpress:9000
```

## Docker network

All services are connected to the custom Docker network:

```text
inception
```

This allows containers to communicate using service names instead of IP addresses.

The host network is not used.

## Persistent data

Persistent data is stored under:

```text
/home/andcarva/data
```

MariaDB data:

```text
/home/andcarva/data/mariadb
```

WordPress files:

```text
/home/andcarva/data/wordpress
```

The Docker volumes are used to preserve data when containers are removed or rebuilt.

## Checking WordPress

Check whether WordPress is installed:

```bash
docker exec -it wordpress sh -lc 'cd /var/www/html && wp core is-installed --allow-root'
```

List WordPress users:

```bash
docker exec -it wordpress sh -lc 'cd /var/www/html && wp user list --allow-root'
```

There should be at least two users:

* One administrator
* One non-administrator user

## Checking MariaDB

Check available databases:

```bash
docker exec -it mariadb sh -lc 'mysql -u"root" -p"/home/andcarva/Documents/Inception/secrets/db_root_password.txt" -e "SHOW DATABASES;"'
```

Check WordPress tables:

```bash
docker exec -it mariadb sh -lc 'mysql -u"$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SHOW TABLES;"'
```

## Checking Nginx and HTTPS

Test HTTPS:

```bash
curl -kI https://andcarva.42.fr
```

Test HTTP:

```bash
curl -kI http://andcarva.42.fr
```


The Nginx container must be the only entrypoint into the infrastructure through port `443`.

## Checking SSL/TLS certificate

```bash
openssl s_client \
  -connect andcarva.42.fr:443 \
  -servername andcarva.42.fr \
  -tls1_2 </dev/null 2>/dev/null \
  | grep -E 'Protocol|Cipher is|Cipher    '
  ```

## Security notes

No passwords should be written directly inside Dockerfiles.

Credentials should be provided using environment variables from `.env` or local secret files.

Sensitive files must not be committed to Git.

Before submission, check tracked files:

```bash
git ls-files | grep -E '(\.env|password|secret|credential)'
```

If this command shows sensitive files, remove them from Git tracking before submission.

## Common troubleshooting

If containers do not start, check logs:

```bash
make logs
```

If the website does not resolve, check `/etc/hosts`.

If WordPress cannot connect to the database, verify the database credentials in `.env`.

If data does not persist, verify that the directories under `/home/andcarva/data` exist and that Docker has permission to use them.
