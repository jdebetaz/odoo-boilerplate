mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
DOCKER_COMPOSE := $(shell command -v docker-compose 2> /dev/null)

ifeq ($(DOCKER_COMPOSE),)
	DOCKER_COMPOSE := docker compose
endif

.DEFAULT_GOAL := help
.SILENT: help
help: ## Show help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'

.SILENT: dev
dev: ## Launch development environment
	$(DOCKER_COMPOSE) up

.SILENT: setup
setup: ## First startup setup
	sudo chmod -R 0777 ./odoo/data
	$(DOCKER_COMPOSE) exec odoo sh -c 'odoo -i base -d odoo -r odoo -w odoo --db_host=db'

.SILENT: prune
prune: ## Purge the project
	$(DOCKER_COMPOSE) down
	docker volume rm "$(current_dir)_postgres"
	$(RM) -rf ./odoo/data/filestore/*
	$(RM) -rf ./odoo/data/sessions/*

.SILENT: shell
shell: ## Open a shell in the odoo container
	$(DOCKER_COMPOSE) exec odoo sh

.SILENT: db-import
db-import: ## Import a database dump
	$(eval DUMP=$(shell ls -t ./odoo/dump/ | head -1))
	echo Import du dump : $(DUMP)
	$(DOCKER_COMPOSE) exec db sh -c 'pg_restore -U odoo -d odoo /tmp/$(DUMP)'
	@echo Import du dump : $(DUMP) terminé
	
.ONESHELL: