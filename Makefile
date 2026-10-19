SHELL := /usr/bin/env bash

.PHONY: setup verify help

setup: ## Run all setup scripts in order
	@if [[ -z "$(USERNAME)" || -z "$(REMOTE_USER)" || -z "$(REMOTE_HOST)" || -z "$(TIMEZONE)" || -z "$(HOSTNAME)" ]]; then \
		echo "Usage: make setup USERNAME=<user> REMOTE_USER=<remote-user> REMOTE_HOST=<host> TIMEZONE=<tz> HOSTNAME=<hostname>"; \
		exit 1; \
	fi
	sudo bash requirements.sh
	sudo bash scripts/01_create_user.sh "$(USERNAME)"
	bash scripts/02a_gen_ssh_keys.sh
	bash scripts/02b_deploy_key.sh "$(REMOTE_USER)" "$(REMOTE_HOST)"
	sudo bash scripts/03_configure_ufw.sh
	sudo bash scripts/04a_system_update.sh
	sudo bash scripts/04b_unattended_upgrades.sh
	sudo bash scripts/05_fail2ban.sh
	sudo bash scripts/06_server_config.sh "$(TIMEZONE)" "$(HOSTNAME)"
	sudo bash scripts/07_service_management.sh

verify: ## Verify firewall, fail2ban, and SSH service
	ufw status
	fail2ban-client status sshd
	systemctl is-active ssh

help: ## Show available targets
	@awk 'BEGIN {FS = ":.*## "; printf "Usage:\n  make <target>\n\nTargets:\n"} /^[a-zA-Z_-]+:.*## / {printf "  %-10s %s\n", $$1, $$2}' $(MAKEFILE_LIST)
