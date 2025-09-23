# Makefile for foton_contacts Redmine plugin management

# Variables
PLUGIN_NAME = foton_contacts
# Assumes docker compose is running in the parent directory
DOCKER_EXEC = docker compose exec redmine

.PHONY: all install upgrade uninstall help

all: install

install: ## Installs or upgrades the plugin by running database migrations.
	@echo "--> Installing/upgrading $(PLUGIN_NAME) plugin..."
	@$(DOCKER_EXEC) bundle exec rake redmine:plugins:migrate NAME=$(PLUGIN_NAME)
	@echo "--> Migration complete."

upgrade: install ## Alias for the install target.

uninstall: ## Uninstalls the plugin by reverting database migrations. WARNING: This is destructive.
	@echo "--> Uninstalling $(PLUGIN_NAME) plugin..."
	@echo "--> WARNING: This will remove all of the plugin's tables and data from the database."
	@$(DOCKER_EXEC) bundle exec rake redmine:plugins:migrate NAME=$(PLUGIN_NAME) VERSION=0
	@echo "--> Uninstallation complete. You can now safely remove the plugin directory."

help: ## Displays help for all available commands.
	@echo "Usage: make [target]"
	@echo ""
	@echo "Available targets:"
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%%-15s\033[0m %%s\n", $$1, $$2}'
