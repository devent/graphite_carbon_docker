REPOSITORY := erwinnttdata
NAME := graphine_carbon
VERSION ?= 0.9.15_001

build: _build ##@targets Builds the docker image.

rebuild: _rebuild ##@targets Builds the docker image anew.

clean: _clean ##@targets Removes the docker image.

deploy: _deploy ##@targets Deploys the docker image to the repository.

test-graphine:
	docker run -d -p "2003:2003" -p "2004:2004" -p "7002:7002" -p "8000:8000" --name $(NAME) $(REPOSITORY)/$(NAME):$(VERSION)

test-grafana:
	docker run -d -p "3000:3000" --link "$(NAME):graphine" --name "grafana" grafana/grafana

test-seyren:
	docker run -d --name "mongodb" mongo:3.0.1
	docker run -d -p "4000:8080" --name "seyren" --link "mongodb:mongodb" --link "$(NAME):graphine" -e "GRAPHITE_URL=http://graphine:8000" usman/docker-seyren

include Makefile.help
include Makefile.functions
include Makefile.image

.PHONY +: build rebuild clean deploy
