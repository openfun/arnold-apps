# -- ARNOLD
ARNOLD_IMAGE_NAME      = fundocker/arnold
ARNOLD_IMAGE_TAG       = 5.24.0
ARNOLD_IMAGE           = $(ARNOLD_IMAGE_NAME):$(ARNOLD_IMAGE_TAG)
ANSIBLE_VAULT_PASSWORD = arnold

# -- k8s
K8S_DOMAIN ?= "$(shell hostname -I | awk '{print $$1}')"

# ==============================================================================
# RULES

default: help

.env: ## generate .env file
	@echo "Updating .env file..."
	@echo "export ANSIBLE_VAULT_PASSWORD=$(ANSIBLE_VAULT_PASSWORD)" > .env
	@echo "export ARNOLD_IMAGE=$(ARNOLD_IMAGE)" >> .env
	@echo "export ARNOLD_IMAGE_NAME=$(ARNOLD_IMAGE_NAME)" >> .env
	@echo "export ARNOLD_IMAGE_TAG=$(ARNOLD_IMAGE_TAG)" >> .env
	@echo "export K8S_AUTH_VERIFY_SSL=no" >> .env
	@echo "export K8S_DOMAIN=$(K8S_DOMAIN)" >> .env
	@echo "Done, update your environment using:\n\n$$ source .env"

cluster: ## start a local k8s cluster for development
	oc cluster up --server-loglevel=5 --public-hostname=$(K8S_DOMAIN)
	oc login https://$(K8S_DOMAIN):8443 -u developer -p developer --insecure-skip-tls-verify=true
.PHONY: cluster

status: ## get local k8s cluster status
	oc cluster status
.PHONY: status

stop: ## stop local k8s cluster
	oc cluster down
.PHONY: stop

# -- Misc
help:
	@grep -E '^[a-zA-Z0-9_-]+:.*?## .*$$' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}'
.PHONY: help
