.PHONY: help up down build logs restart shell ps dev-up dev-down dev-build dev-logs dev-restart dev-shell dev-ps backend-shell gateway-shell mongo-shell prod-up prod-down prod-build prod-logs prod-restart clean clean-all clean-volumes status health backup restore dev-backup dev-restore prod-backup prod-restore

# Default to development mode
MODE ?= dev
# Get all arguments after the command
ARGS := $(wordlist 2,$(words $(MAKECMDGOALS)),$(MAKECMDGOALS))
# Reset MAKECMDGOALS so that it's not passed to sub-makes
MAKECMDGOALS= 

# Set compose file and env file based on mode
ifeq ($(MODE),prod)
	COMPOSE_FILE = docker/compose.production.yaml
	ENV_FILE = .env.production
else
	COMPOSE_FILE = docker/compose.development.yaml
	ENV_FILE = .env.development
endif

# Base docker-compose command
DC = docker-compose --project-name cuet-cse-fest-devops-hackathon-preli --env-file $(ENV_FILE) -f $(COMPOSE_FILE)

help:
	@echo "Usage: make [command]"
	@echo ""
	@echo "Docker Services:"
	@echo "  up             - Start services (e.g., make up, make up MODE=prod ARGS=\"--build\")"
	@echo "  down           - Stop services (e.g., make down, make down MODE=prod ARGS=\"--volumes\")"
	@echo "  build          - Build containers (e.g., make build, make build MODE=prod)"
	@echo "  logs           - View logs (e.g., make logs, make logs gateway, make logs MODE=prod backend)"
	@echo "  restart        - Restart services (e.g., make restart, make restart MODE=prod)"
	@echo "  shell          - Open shell in container (e.g., make shell backend, make shell MODE=prod gateway)"
	@echo "  ps             - Show running containers (e.g., make ps, make ps MODE=prod)"
	@echo ""
	@echo "Development Aliases:"
	@echo "  dev-up         - Start development environment"
	@echo "  dev-down       - Stop development environment"
	@echo "  dev-build      - Build development containers"
	@echo "  dev-logs       - View development logs"
	@echo "  dev-restart    - Restart development services"
	@echo "  dev-shell      - Open shell in backend container"
	@echo "  backend-shell  - Alias for dev-shell"
	@echo "  gateway-shell  - Open shell in gateway container"
	@echo "  mongo-shell    - Open MongoDB shell"
	@echo ""
	@echo "Production Aliases:"
	@echo "  prod-up        - Start production environment"
	@echo "  prod-down      - Stop production environment"
	@echo "  prod-build     - Build production containers"
	@echo "  prod-logs      - View production logs"
	@echo "  prod-restart   - Restart production services"
	@echo ""
	@echo "Cleanup:"
	@echo "  clean          - Remove containers and networks (dev and prod)"
	@echo "  clean-all      - Remove containers, networks, volumes, and images"
	@echo "  clean-volumes  - Remove all volumes"
	@echo ""
	@echo "Backup & Restore:"
	@echo "  dev-backup     - Backup development database to backup/dev"
	@echo "  dev-restore    - Restore development database from backup/dev"
	@echo "  prod-backup    - Backup production database to backup/prod"
	@echo "  prod-restore   - Restore production database from backup/prod"
	@echo ""
	@echo "Utilities:"
	@echo "  status         - Alias for ps"
	@echo "  health         - Check service health"

# Docker Services
up:
	@$(DC) up -d $(ARGS)

down:
	@$(DC) down $(ARGS)

build:
	@$(DC) build $(ARGS)

logs:
	@$(DC) logs -f $(ARGS)

restart:
	@$(DC) restart $(ARGS)

shell:
	@$(DC) exec $(firstword $(ARGS) backend) bash

ps:
	@$(DC) ps

# Development Aliases
dev-up:
	@make up MODE=dev

dev-down:
	@make down MODE=dev

dev-build:
	@make build MODE=dev

dev-logs:
	@make logs MODE=dev $(ARGS)

dev-restart:
	@make restart MODE=dev

dev-shell:
	@make shell MODE=dev backend

backend-shell: dev-shell

gateway-shell:
	@make shell MODE=dev gateway

mongo-shell:
	@make shell MODE=dev mongo mongosh --username ${MONGO_INITDB_ROOT_USERNAME} --password ${MONGO_INITDB_ROOT_PASSWORD}

# Production Aliases
prod-up:
	@make up MODE=prod

prod-down:
	@make down MODE=prod

prod-build:
	@make build MODE=prod

prod-logs:
	@make logs MODE=prod $(ARGS)

prod-restart:
	@make restart MODE=prod

# Cleanup
clean:
	@docker-compose -f docker/compose.development.yaml down
	@docker-compose -f docker/compose.production.yaml down

clean-all:
	@docker-compose -f docker/compose.development.yaml down --volumes --rmi all
	@docker-compose -f docker/compose.production.yaml down --volumes --rmi all

clean-volumes:
	@docker volume rm `docker volume ls -q | grep 'cuet-cse-fest-devops-hackathon-preli'` || true

# Backup & Restore
dev-backup:
	@mkdir -p backup/dev
	@echo "Backing up development database (ecom-dev)..."
	@docker-compose --project-name cuet-cse-fest-devops-hackathon-preli --env-file .env.development -f docker/compose.development.yaml exec -T mongo sh -c 'mongodump --username "$$MONGO_INITDB_ROOT_USERNAME" --password "$$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db ecom-dev --out /backup/dump'
	@echo "Backup completed to backup/dev/dump"

dev-restore:
	@echo "Restoring development database (ecom-dev) from backup/dev..."
	@docker-compose --project-name cuet-cse-fest-devops-hackathon-preli --env-file .env.development -f docker/compose.development.yaml exec -T mongo sh -c 'mongorestore --username "$$MONGO_INITDB_ROOT_USERNAME" --password "$$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --drop /backup/dump'
	@echo "Restore completed from backup/dev/dump"

prod-backup:
	@mkdir -p backup/prod
	@echo "Backing up production database (ecom-prod)..."
	@docker-compose --project-name cuet-cse-fest-devops-hackathon-preli --env-file .env.production -f docker/compose.production.yaml exec -T mongo sh -c 'mongodump --username "$$MONGO_INITDB_ROOT_USERNAME" --password "$$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --db ecom-prod --out /backup/dump'
	@echo "Backup completed to backup/prod/dump"

prod-restore:
	@echo "Restoring production database (ecom-prod) from backup/prod..."
	@docker-compose --project-name cuet-cse-fest-devops-hackathon-preli --env-file .env.production -f docker/compose.production.yaml exec -T mongo sh -c 'mongorestore --username "$$MONGO_INITDB_ROOT_USERNAME" --password "$$MONGO_INITDB_ROOT_PASSWORD" --authenticationDatabase admin --drop /backup/dump'
	@echo "Restore completed from backup/prod/dump"

# Utilities
status: ps

health:
	@echo "Checking gateway health..."
	@curl -s http://localhost:5921/health || echo "Gateway health check failed"
	@echo "\nChecking backend health via gateway..."
	@curl -s http://localhost:5921/api/health || echo "Backend health check failed"
	@echo ""