# -- ARNOLD
ANSIBLE_VAULT_PASSWORD = arnold

# -- k8s
K3D_CLUSTER_NAME ?= arnold-apps
K8S_DOMAIN ?= "$(shell hostname -I | awk '{print $$1}')"

# ==============================================================================
# RULES

default: help

# Files rules
bin/arnold:
	curl -Lo "${PWD}/bin/arnold" "https://raw.githubusercontent.com/openfun/arnold/master/bin/arnold"
	chmod +x "${PWD}/bin/arnold"

bin/init-cluster:
	curl -Lo "${PWD}/bin/init-cluster" "https://raw.githubusercontent.com/openfun/arnold/master/bin/init-cluster"
	chmod +x "${PWD}/bin/init-cluster"

.env: ## generate .env file
	@echo "Updating .env file..."
	@echo "alias arnold='bin/arnold -v ${PWD}/apps:/app/apps'" > .env
	@echo "export ANSIBLE_VAULT_PASSWORD=$(ANSIBLE_VAULT_PASSWORD)" >> .env
	@echo "export K8S_CONTEXT=k3d-$(K3D_CLUSTER_NAME)" >> .env
	@echo "export ARNOLD_IMAGE_TAG=master" >> .env
	@echo "Done, update your environment using: 'source .env'"

# PHONY rules

bootstrap: \
	.env \
	install
bootstrap: ## bootstrap the project
.PHONY: bootstrap

clean: ## remove temporary files and downloaded binaries
	rm -f .env bin/arnold bin/init-cluster
.PHONY: clean

cluster: \
	install
cluster: ## start a local k8s cluster for development
	# Bootstrap the k3d cluster with the following specific settings :
	# - use standard HTTP and HTTPS ports
	# - pre-provision 5 volumes instead of 100
	MINIMUM_AVAILABLE_RWX_VOLUME=5 \
	K3D_BIND_HOST_PORT_HTTP=80 \
	K3D_BIND_HOST_PORT_HTTPS=443 \
	  bin/init-cluster $(K3D_CLUSTER_NAME)
.PHONY: cluster

install: \
	bin/arnold \
	bin/init-cluster
install: ## install Arnold's dependencies
.PHONY: install

status: ## get local k8s cluster status
	k3d cluster list "$(K3D_CLUSTER_NAME)"
.PHONY: status

stop: ## stop local k8s cluster
	k3d cluster stop "$(K3D_CLUSTER_NAME)"
.PHONY: stop

update: \
	clean \
	bin/arnold \
	bin/init-cluster
update: ## update arnold's dependencies
.PHONY: update

# -- Misc
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
