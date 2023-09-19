mkfile_path := $(abspath $(lastword $(MAKEFILE_LIST)))
current_dir := $(notdir $(patsubst %/,%,$(dir $(mkfile_path))))

.PHONY: dev
dev: ## Launch development environment
	docker-compose up

.PHONY: setup
setup: ## First startup setup
	docker-compose exec odoo sh -c 'odoo -i base -d odoo -r odoo -w odoo --db_host=db'

.PHONY: prune
prune: ## Purge the project
	docker-compose down
	docker volume rm "$(current_dir)_postgres"
	rm -rf ./odoo/data/filestore/*
	rm -rf ./odoo/data/sessions/*
	exit 1
	
