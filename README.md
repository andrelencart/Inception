*This project has been created as part of the 42 curriculum by andcarva.*

# Inception

## Description

Inception is a system administration project that builds a small Docker-based infrastructure. It runs three services in separate containers:

- Nginx, used as the only public entrypoint through HTTPS on port 443.
- WordPress with PHP-FPM, used to serve the website.
- MariaDB, used as the WordPress database.

The goal is to understand how to build custom Docker images, connect containers through a private Docker network, persist data with Docker volumes, and configure a secure web stack using TLS.

## Project description

This project uses Docker Compose to build and start all services. Each service has its own Dockerfile and its own container.

The request flow is:

1. The client connects to `https://andcarva.42.fr`.
2. Nginx receives the HTTPS request on port 443.
3. PHP requests are forwarded to the WordPress container through FastCGI.
4. WordPress communicates with MariaDB through the Docker network.
5. WordPress files and database data are persisted using Docker volumes.

### Virtual Machines vs Docker

A virtual machine virtualizes a full operating system, including its own kernel. Docker containers share the host kernel and isolate only the application environment. Containers are lighter, faster to start, and easier to reproduce, while virtual machines provide stronger isolation but use more resources.

### Secrets vs Environment Variables

Environment variables are simple to use and are loaded by Docker Compose through the `.env` file. They are useful for configuration values such as domain names and database names.

Secrets are safer for sensitive values such as passwords because they are stored separately and are not exposed as plainly as environment variables. For this project, confidential files must not be committed to the Git repository.

### Docker Network vs Host Network

A Docker network isolates the containers from the host and allows services to communicate using service names such as `mariadb` and `wordpress`.

The host network would remove this isolation and expose services more directly. This project uses a dedicated Docker network so that only Nginx is reachable from outside the infrastructure.

### Docker Volumes vs Bind Mounts

Docker volumes are managed by Docker and are used to persist container data safely. Bind mounts directly map a host path into a container.

This project uses Docker named volumes for the WordPress files and MariaDB database, with data stored under `/home/andcarva/data` on the host machine.

---

## Architecture

**Request flow:**

1. Client connects to `https://<DOMAIN_NAME>:443`
2. **Nginx** terminates TLS and serves the WordPress site
3. For `.php` requests, Nginx forwards execution to **PHP-FPM** (WordPress container)
4. WordPress connects to **MariaDB** to store/retrieve data

---

## Repository structure

- `Makefile` — helper commands to build/run/reset the stack
- `srcs/docker-compose.yml` — Compose definition
- `srcs/nginx/` — Nginx image (TLS + reverse proxy + FastCGI config)
- `srcs/wordpress/` — WordPress + PHP-FPM image and bootstrap scripts
- `srcs/mariadb/` — MariaDB image and initialization

---

## Requirements

- Docker
Docker Compose (`docker-compose` or the Docker Compose plugin)
- `sudo` access (used by `make reset-data` / `make fclean`)

---

## Environment variables

This project uses an `.env` file (loaded by Compose) to configure the containers.

At minimum you’ll need values for:

### MariaDB
- `DB_NAME`
- `DB_USER`
- `DB_PASSWORD`
- `DB_ROOT_PASSWORD`

### WordPress
- `WP_TITLE`
- `WP_ADMIN_USER`
- `WP_ADMIN_PASSWORD`
- `WP_ADMIN_EMAIL`

Optional (second user):
- `WP_USER`
- `WP_USER_EMAIL`
- `WP_USER_PASSWORD`

### Nginx / domain
- `DOMAIN_NAME` (example: `andcarva.42.fr`)

> Note: if you use a self-signed certificate, your browser will show a warning. This is expected.

---

## Persistent volumes

Data is persisted using Docker named volumes backed by storage under `/home/andcarva/data` on the host:

- MariaDB database: `/home/andcarva/data/mariadb`
- WordPress website files: `/home/andcarva/data/wordpress`

This means containers can be destroyed and rebuilt without losing data unless these directories or the Docker volumes are explicitly removed.

---

## Instructions

### Start the stack
```bash
make up
```

### Build and start (rebuild images)
```bash
make build
```

### View logs
```bash
make logs
```

### Check container status
```bash
make ps
```

### Stop containers
```bash
make stop
```

### Stop and remove containers/networks
```bash
make down
```

---

## Cleaning / Resetting

### Remove containers + networks + named volumes
```bash
make clean
```

### Full reset (also deletes persistent volume data)
This wipes the database and WordPress files stored under `/home/andcarva/data` and starts fresh:
```bash
make fclean
make build
```

Or in one command:
```bash
make re
```

---

## Testing

### Check WordPress is installed (inside container)
```bash
docker exec -it wordpress sh -lc 'cd /var/www/html && wp core is-installed --allow-root && wp user list --allow-root'
```

### Check MariaDB connection and WordPress tables
```bash
docker exec -it mariadb sh -lc 'mysql -u"$DB_USER" -p"$DB_PASSWORD" -e "SHOW DATABASES;"'
docker exec -it mariadb sh -lc 'mysql -u"$DB_USER" -p"$DB_PASSWORD" -D "$DB_NAME" -e "SHOW TABLES;"'
```

### Test HTTPS (self-signed)
```bash
curl -kI https://$DOMAIN_NAME
```

If your VM doesn’t resolve `$DOMAIN_NAME`, add it to `/etc/hosts`:
```bash
echo "127.0.0.1 $DOMAIN_NAME" | sudo tee -a /etc/hosts
```

---

## Notes

- Nginx listens on **443** and proxies PHP execution to WordPress via FastCGI (`wordpress:9000`).
- WordPress uses MariaDB as its backend database.
- The stack runs on a custom Docker network called `inception`.

---

## Resources

- Docker documentation
- Docker Compose documentation
- Nginx documentation
- WordPress CLI documentation
- MariaDB documentation
- PHP-FPM documentation


### AI usage

AI was used as a review assistant to compare the project against the subject requirements, identify missing documentation sections, and suggest improvements to the README and configuration files.

All final changes were reviewed, tested, and understood before being kept in the project.