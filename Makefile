COMPOSE_CMD := docker compose

.PHONY: build up down ps logs terminal 

build:
	$(COMPOSE_CMD) build $(BUILD_ARG)

up: build
	$(COMPOSE_CMD) up -d

down:
	$(COMPOSE_CMD) down

ps:
	$(COMPOSE_CMD) ps

logs:
	$(COMPOSE_CMD) logs --follow --tail=100

terminal:
	$(COMPOSE_CMD) exec ngate sh -c 'bash'
