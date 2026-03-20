.PHONY: help build clean lint format test \
        tf-init tf-validate tf-fmt tf-plan tf-apply tf-destroy \
        ansible-setup \
        ec2-start ec2-stop ec2-status

STAGE        ?= dev
TF_DIR        = terraform/stages/$(STAGE)
ANSIBLE_DIR   = ansible
DIST_DIR      = dist
LAMBDA_ZIP    = $(DIST_DIR)/lambda.zip
SRC_DIR       = src
AWS_PROFILE  ?= $(shell grep -E '^aws_profile' $(TF_DIR)/terraform.tfvars 2>/dev/null | sed 's/^[^"]*"\([^"]*\)".*/\1/')

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
	@uv run ruff check $(SRC_DIR)

format: ## Run ruff formatter
	@uv run ruff format $(SRC_DIR)

test: ## Run pytest
	@uv run pytest

# ---------------------------------------------------------------------------
# Terraform (STAGE=dev by default)
# ---------------------------------------------------------------------------
tf-init: ## terraform init
	@terraform -chdir=$(TF_DIR) init

tf-validate: build ## terraform validate (builds Lambda zip first)
	@terraform -chdir=$(TF_DIR) validate

tf-fmt: ## terraform fmt (recursive)
	@terraform -chdir=$(TF_DIR) fmt -recursive

tf-plan: build ## terraform plan (builds Lambda zip first)
	@terraform -chdir=$(TF_DIR) plan

tf-apply: build ## terraform apply (builds Lambda zip first)
	@terraform -chdir=$(TF_DIR) apply

tf-destroy: ## terraform destroy
	@terraform -chdir=$(TF_DIR) destroy

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

# ---------------------------------------------------------------------------
# EC2 on/off
# ---------------------------------------------------------------------------
ec2-start: ## Start EC2 instance
	$(eval INSTANCE_ID := $(shell terraform -chdir=$(TF_DIR) output -raw ec2_instance_id))
	@echo "Starting $(INSTANCE_ID) ..."
	@AWS_PROFILE=$(AWS_PROFILE) aws ec2 start-instances --instance-ids $(INSTANCE_ID)
	@echo "Waiting for running state ..."
	@AWS_PROFILE=$(AWS_PROFILE) aws ec2 wait instance-running --instance-ids $(INSTANCE_ID)
	@echo "EC2 is running."

ec2-stop: ## Stop EC2 instance
	$(eval INSTANCE_ID := $(shell terraform -chdir=$(TF_DIR) output -raw ec2_instance_id))
	@echo "Stopping $(INSTANCE_ID) ..."
	@AWS_PROFILE=$(AWS_PROFILE) aws ec2 stop-instances --instance-ids $(INSTANCE_ID)
	@echo "Waiting for stopped state ..."
	@AWS_PROFILE=$(AWS_PROFILE) aws ec2 wait instance-stopped --instance-ids $(INSTANCE_ID)
	@echo "EC2 is stopped."

ec2-status: ## Show EC2 instance state
	$(eval INSTANCE_ID := $(shell terraform -chdir=$(TF_DIR) output -raw ec2_instance_id))
	@AWS_PROFILE=$(AWS_PROFILE) aws ec2 describe-instance-status \
		--instance-ids $(INSTANCE_ID) \
		--include-all-instances \
		--query 'InstanceStatuses[0].InstanceState.Name' \
		--output text

# ---------------------------------------------------------------------------
# Utility
# ---------------------------------------------------------------------------
myip:
	@echo ""
	@curl -s https://ipinfo.io/ip
	@echo ""
