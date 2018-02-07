#/bin/sh
# Andrei-Bogdan Puiu (ap8415)
START     = System2.start
PEERS     = 5
MAX 	    = 1000
TIMEOUT   = 3000

PROJECT  = da347
NETWORK  = $(PROJECT)_network

LOCAL	 = mix run --no-halt -e $(START) $(PEERS) $(MAX) $(TIMEOUT) 0
COMPOSE = START=$(START) PEERS=$(PEERS) MAX=$(MAX) TIMEOUT=$(TIMEOUT) docker-compose --file docker-compose.yml -p $(PROJECT)

compile:
	mix compile

run:
	$(LOCAL)

clean:
	mix clean

build:
	$(COMPOSE) build

up:
	$(COMPOSE) up

down:
	$(COMPOSE) down
	make show

show:
	@echo ----------------------
	@make ps
	@echo ----------------------
	@make network

show2:
	@echo ----------------------
	@make ps2
	@echo ----------------------
	@make network

ps:
	docker ps -a --format 'table {{.Names}}\t{{.Image}}'

ps2:
	docker ps -a -s

network net:
	docker network ls

inspect:
	docker network inspect $(NETWORK)

netrm:
	docker network rm $(NETWORK)
conrm:
	docker rm $(ID)

kill:
	docker rm -f `docker ps -a -q`
	docker network rm $(NETWORK)
