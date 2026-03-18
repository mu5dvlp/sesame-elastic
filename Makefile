.PHONY: help build clean lint format test \
        tf-init tf-validate tf-fmt tf-plan tf-apply tf-destroy \
        ansible-setup

STAGE        ?= dev
TF_DIR        = terraform/stages/$(STAGE)
ANSIBLE_DIR   = ansible
DIST_DIR      = dist
LAMBDA_ZIP    = $(DIST_DIR)/lambda.zip
SRC_DIR       = src

help: ## Show this help
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) \
		| awk 'BEGIN {FS = ":.*?## "}; {printf "  \033[36m%-18s\033[0m %s\n", $$1, $$2}'

# ---------------------------------------------------------------------------
# Lambda
# ---------------------------------------------------------------------------
build: ## Package src/ into dist/lambda.zip
	mkdir -p $(DIST_DIR)
	cd $(SRC_DIR) && zip -r ../$(LAMBDA_ZIP) . -x "**/__pycache__/*" -x "**/*.pyc"
	@echo "Built $(LAMBDA_ZIP)"

clean: ## Remove dist/
	rm -rf $(DIST_DIR)
	@echo "Cleaned $(DIST_DIR)"

# ---------------------------------------------------------------------------
# Python
# ---------------------------------------------------------------------------
lint: ## Run ruff linter
	uv run ruff check $(SRC_DIR)

format: ## Run ruff formatter
	uv run ruff format $(SRC_DIR)

test: ## Run pytest
	uv run pytest

# ---------------------------------------------------------------------------
# Terraform (STAGE=dev by default)
# ---------------------------------------------------------------------------
tf-init: ## terraform init
	terraform -chdir=$(TF_DIR) init

tf-validate: build ## terraform validate (builds Lambda zip first)
	terraform -chdir=$(TF_DIR) validate

tf-fmt: ## terraform fmt (recursive)
	terraform -chdir=$(TF_DIR) fmt -recursive

tf-plan: build ## terraform plan (builds Lambda zip first)
	terraform -chdir=$(TF_DIR) plan

tf-apply: build ## terraform apply (builds Lambda zip first)
	terraform -chdir=$(TF_DIR) apply

tf-destroy: ## terraform destroy
	terraform -chdir=$(TF_DIR) destroy

# ---------------------------------------------------------------------------
# Ansible
# ---------------------------------------------------------------------------
ansible-setup: ## Provision EC2 with Ansible (reads EIP from terraform output)
	$(eval EC2_IP := $(shell terraform -chdir=$(TF_DIR) output -raw ec2_public_ip))
	@echo "Provisioning $(EC2_IP) ..."
	ANSIBLE_CONFIG=$(ANSIBLE_DIR)/ansible.cfg \
	ansible-playbook \
		--inventory "$(EC2_IP)," \
		--extra-vars "elk_version=$(shell terraform -chdir=$(TF_DIR) output -raw elk_version 2>/dev/null || echo 8.11.0)" \
		$(ANSIBLE_DIR)/site.yml
