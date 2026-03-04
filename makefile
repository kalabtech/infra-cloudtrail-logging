# --- MULTIENV MAKEFILE ---
# --- VARIABLES ---
TF_DIR      = ./infra
DOCS_DIR    = ./docs/obsidian
MOD_DIR     = ./modules
ENV         ?= 
STATE_FILE  = $(ENV).tfplan
CURRENT_ENV_FILE := .current-env

define AWS_IDENTITY
	echo "-----------------------"
	echo "Current AWS Identity:"
	AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text
	echo "Environment: $(ENV)"
	echo "-----------------------"
endef

define TFPLAN_SUMMARY
	chmod +x scripts/tf-plan-summary.sh
	./scripts/tf-plan-summary.sh $(TF_DIR)/$(STATE_FILE)
	chmod -x scripts/tf-plan-summary.sh
endef


.PHONY: all verify-identity check-env init plan apply destroy resources show state checktf check security prec prec-all docs help

# Default action
all: security fmt check plan

## --- AWS ---
verify-identity: ## Shows actual AWS profile
	@$(AWS_IDENTITY)

check-env: ## Verify ENV matches initialized environment
	@if [ -z "$(ENV)" ]; then \
		echo "ERROR: ENV is required. Usage: make <target> ENV=dev"; \
		exit 1; \
	fi
	@if [ ! -f "$(CURRENT_ENV_FILE)" ]; then \
		echo "ERROR: Not initialized. Run make init ENV=$(ENV) first."; \
		exit 1; \
	fi
	@CURRENT=$$(cat $(CURRENT_ENV_FILE)); \
	if [ "$(ENV)" != "$$CURRENT" ]; then \
		echo "ERROR: Initialized on [$$CURRENT] but running on [$(ENV)]. Run make init ENV=$(ENV) first."; \
		exit 1; \
	fi

## --- TERRAFORM COMMANDS ---

init: ## Initialize backend — usage: make init ENV=dev
	@$(AWS_IDENTITY)
	@echo "Initializing [$(ENV)]..."
	@echo "$(ENV)" > $(CURRENT_ENV_FILE)
	@terraform -chdir=$(TF_DIR) init -backend-config=../backends/$(ENV).hcl -reconfigure

plan: check-env ## Generate execution plan — usage: make plan ENV=dev
	@$(AWS_IDENTITY)
	@echo "Generating plan [$(ENV)]..."
	@terraform -chdir=$(TF_DIR) plan -var-file=../environments/$(ENV).tfvars -out=$(STATE_FILE)		
	@$(TFPLAN_SUMMARY)

apply: check-env ## Apply changes — usage: make apply ENV=dev
	$(AWS_IDENTITY)
	@echo "Applying changes [$(ENV)]..."
	@terraform -chdir=$(TF_DIR) apply $(STATE_FILE)

destroy: check-env ## Destroy infrastructure — usage: make destroy ENV=dev
	$(AWS_IDENTITY)
	@echo "WARNING: Destroying [$(ENV)] infrastructure."
	@terraform -chdir=$(TF_DIR) destroy -var-file=../environments/$(ENV).tfvars

resources: ## List all tfstate resources — usage: make resources
	@$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) state list

show: ## Shows resources in tfstate — usage: make show RES=resource
	@$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) state show $(RES)

state: ## Shows tfstate — usage: make state
	@$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) state pull

output: ## Shows tfstate output — usage: make output
	@$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) output

## --- QUALITY AND SECURITY ---

checktf: ## Format and Validation Terraform code
	@echo "Formatting code..."
	@terraform fmt -recursive $(TF_DIR)
	@terraform fmt -recursive $(environments)
	@echo "Validating code..."
	@cd $(TF_DIR) && terraform validate

check: ## Linting and syntax validation
	@echo "Running TFLint..."
	@tflint --chdir=$(TF_DIR) --init
	@tflint --chdir=$(TF_DIR)

security: ## Security scanning
	@echo "Scanning for vulnerabilities..."
	@tfsec $(TF_DIR)
	@checkov -d $(TF_DIR) --quiet

## --- PRE-COMMIT ---

prec: ## Run pre-commit on staged files only (fast check)
	@echo "Running pre-commit on staged files..."
	@pre-commit run

prec-all: ## Run pre-commit on all files (deep check)
	@echo "Running pre-commit on all files..."
	@pre-commit run --all-files

## --- DOCUMENTATION (OBSIDIAN) ---

docs: ## Generate automatic Markdown documentation for Obsidian
	@mkdir -p $(DOCS_DIR)
	@echo "Updating Obsidian documentation..."
	@terraform-docs markdown table $(TF_DIR) > $(DOCS_DIR)/infrastructure-$(ENV).md
	@echo "Documentation updated at $(DOCS_DIR)/infrastructure-$(ENV).md"

## --- UTILITIES ---

help: ## Show this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
