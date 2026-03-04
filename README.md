# Inception

`Inception` is a Docker-based infrastructure project (42) that deploys a small web stack using **Docker Compose**:

- **Nginx** (HTTPS/TLS on port 443)
- **WordPress** (PHP-FPM)
- **MariaDB** (database)

All services run in isolated containers and communicate through a dedicated Docker network.

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
- Docker Compose plugin (`docker compose`)
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

## Persistent volumes (bind mounts)

Data is persisted on the host using bind mounts:

- MariaDB: `/home/andcarva/data/mariadb`
- WordPress files: `/home/andcarva/data/wordpress`

This means containers can be destroyed/rebuilt without losing data unless you explicitly delete these directories.

---

## Usage

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

### Full reset (also deletes bind mount data)
This wipes the database and WordPress files and starts fresh:
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
