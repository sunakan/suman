export ENTRYPOINT=terraform

.PHONY: all
all: ;

.env:
	cp env.sample .env
.PHONY: ash
ash: .env
	ENTRYPOINT="" docker-compose run --rm tf ash
.PHONY: v
v: .env
	docker-compose run --rm tf -v
.PHONY: init
init: .env
	docker-compose run --rm tf init
.PHONY: get
get: .env
	docker-compose run --rm tf get
.PHONY: fmt
fmt: .env
	docker-compose run --rm tf fmt -recursive
.PHONY: plan
plan: .env
	docker-compose run --rm tf plan ${ARGS}
.PHONY: apply
apply: .env
	docker-compose run --rm tf apply ${ARGS}
.PHONY: destroy
destroy: .env
	docker-compose run --rm tf destroy

test:
	bash ./test.sh
