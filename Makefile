NAME = inception
COMPOSE_DIR = srcs
COMPOSE = docker compose -f $(COMPOSE_DIR)/docker-compose.yml

DATA_DIR = /home/andcarva/data
MDB_DIR = $(DATA_DIR)/mariadb
WP_DIR  = $(DATA_DIR)/wordpress

all: up

up:
	@$(COMPOSE) up -d

build:
	@$(COMPOSE) up -d --build

down:
	@$(COMPOSE) down

stop:
	@$(COMPOSE) stop

restart:
	@$(COMPOSE) restart

logs:
	@$(COMPOSE) logs -f

ps:
	@$(COMPOSE) ps

# Removes containers + networks + named volumes - not bind-mount data dirs
clean: down
	@$(COMPOSE) down -v

# Full reset: removes bind-mount data too (DB + WP files)
fclean: clean reset-data

reset-data:
	@sudo rm -rf $(MDB_DIR) $(WP_DIR)
	@sudo mkdir -p $(MDB_DIR) $(WP_DIR)
	@sudo chown -R $$USER:$$USER $(MDB_DIR) $(WP_DIR)

re: fclean build

.PHONY: all up build down stop restart logs ps clean fclean re \
		reset-data