mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))
ifeq (, $(shell which docker-compose > /dev/null 2>&1 && echo 1))
    dc := docker compose 
else
    dc := docker-compose
endif

.PHONY: dev
dev: ## Launch development environment
	$(dc) up

.PHONY: setup
setup: ## First startup setup
	$(dc) exec odoo sh -c 'odoo -i base -d odoo -r odoo -w odoo --db_host=db'

.PHONY: prune
prune: ## Purge the project
	$(dc) down
	docker volume rm "$(current_dir)_postgres"
	rm -rf ./odoo/data/filestore/*
	rm -rf ./odoo/data/sessions/*
	exit 1
	
