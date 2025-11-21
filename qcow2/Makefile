
# --- Настройки ---
ENV_FILE ?= .env
VM_NAME  := "Debian-Sakura-VM"

SSH_USER   := debian
SSH_PASS   := debian
SSH_HOST   := localhost
SSH_PORT   := 2222
REMOTE_PATH := /etc/ngate/credentials.env
REMOTE_SERVICE_FILE := /etc/systemd/system/ngate.service

SSH_OPTS := -p $(SSH_PORT) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
SCP_OPTS := -P $(SSH_PORT) -o StrictHostKeyChecking=no -o UserKnownHostsFile=/dev/null
SSHPASS_CMD := SSHPASS=$(SSH_PASS) sshpass -e

.PHONY: help run apply upload-config restart-service ssh clean stop

default: help

help:
	@echo "Доступные команды:"
	@echo "  make run             - Запустить VM (блокирует терминал)."
	@echo "  make apply           - Дождаться готовности VM, загрузить .env и запустить NGate"
	@echo "  make stop            - Корректно остановить VM."
	@echo "  make ssh             - Подключиться к VM по SSH."
	@echo "  make clean           - Удалить рабочие образы дисков VM для сброса."
	@echo ""
	@echo "Рабочий процесс: 1. make run  2. make apply  3. make stop"

run:
	nix run

apply: upload-config restart-service
	@echo "Конфигурация успешно применена"

upload-config:
	$(SSHPASS_CMD) scp $(SCP_OPTS) $(ENV_FILE) $(SSH_USER)@$(SSH_HOST):/tmp/credentials.env.tmp
	$(SSHPASS_CMD) ssh $(SSH_OPTS) $(SSH_USER)@$(SSH_HOST) 'sudo mkdir -p $(dir $(REMOTE_PATH)) && sudo mv /tmp/credentials.env.tmp $(REMOTE_PATH) && sudo chmod 600 $(REMOTE_PATH) && sudo chown root:root $(REMOTE_PATH)'

restart-service:
	@until $(SSHPASS_CMD) ssh $(SSH_OPTS) $(SSH_USER)@$(SSH_HOST) "[ -f $(REMOTE_SERVICE_FILE) ]"; do \
		echo "   ...VM еще настраивается, жду 3 сек..."; \
		sleep 3; \
	done
	$(SSHPASS_CMD) ssh $(SSH_OPTS) $(SSH_USER)@$(SSH_HOST) 'sudo systemctl daemon-reload && sudo systemctl restart ngate.service'
	@sleep 2
	$(SSHPASS_CMD) ssh $(SSH_OPTS) $(SSH_USER)@$(SSH_HOST) 'sudo systemctl status ngate.service --no-pager || true'

stop:
	@-pkill -f $(VM_NAME)

ssh:
	$(SSHPASS_CMD) ssh $(SSH_OPTS) $(SSH_USER)@$(SSH_HOST)

clean: stop
	rm -f debian-work.qcow2 seed.img