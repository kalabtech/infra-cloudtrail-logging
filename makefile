# =============================================================================
# MAKEFILE — multienv (dev/prod with environment protection)
#
# Usage:
#   make init ENV=dev        → initialize backend for dev
#   make plan ENV=dev        → plan changes for dev
#   make apply ENV=dev       → apply changes for dev
#   make resources ENV=dev   → list resources in dev state
# =============================================================================

# --- VARIABLES ---
TF_DIR      = ./infra
DOCS_DIR    = ./docs/obsidian
MOD_DIR     = ./modules
ENV         ?=
STATE_FILE  = $(ENV).tfplan
CURRENT_ENV_FILE := .current-env

# --- HELPERS ---
define AWS_IDENTITY
	@echo "-----------------------"
	@echo "Current AWS Identity:"
	@AWS_PAGER="" aws sts get-caller-identity --query "Arn" --output text
	@echo "Environment: $(ENV)"
	@echo "-----------------------"
endef

define TFPLAN_SUMMARY
	@chmod u+x scripts/tf-plan-summary.sh
	@./scripts/tf-plan-summary.sh $(TF_DIR)/$(STATE_FILE)
	@chmod u-x scripts/tf-plan-summary.sh
endef

# --- GUARDS ---
# Verifies ENV is set and matches the initialized environment.
# Prevents plan on dev → apply on prod mistakes.
check-env:
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

# Only checks that ENV is provided (for init, which creates .current-env)
require-env:
	@if [ -z "$(ENV)" ]; then \
		echo "ERROR: ENV is required. Usage: make <target> ENV=dev"; \
		exit 1; \
	fi

.PHONY: all verify-identity check-env require-env init plan apply destroy \
        resources show state output checktf check security prec prec-all docs help

# Default action
all: security checktf plan

# =============================================================================
# AWS
# =============================================================================

verify-identity: require-env ## Shows actual AWS profile — make verify-identity ENV=dev
	$(AWS_IDENTITY)

# =============================================================================
# TERRAFORM COMMANDS
# =============================================================================

init: require-env ## Initialize backend — make init ENV=dev
	$(AWS_IDENTITY)
	@echo "Initializing [$(ENV)]..."
	@echo "$(ENV)" > $(CURRENT_ENV_FILE)
	@terraform -chdir=$(TF_DIR) init -backend-config=../backends/$(ENV).hcl -reconfigure

plan: check-env ## Generate execution plan — make plan ENV=dev
	$(AWS_IDENTITY)
	@echo "Generating plan [$(ENV)]..."
	@terraform -chdir=$(TF_DIR) plan -var-file=../environments/$(ENV).tfvars -out=$(STATE_FILE)
	$(TFPLAN_SUMMARY)

apply: check-env ## Apply changes — make apply ENV=dev
	$(AWS_IDENTITY)
	@echo "Applying changes [$(ENV)]..."
	@terraform -chdir=$(TF_DIR) apply $(STATE_FILE)

destroy: check-env ## Destroy infrastructure — make destroy ENV=dev
	$(AWS_IDENTITY)
	@echo "WARNING: Destroying [$(ENV)] infrastructure."
	@terraform -chdir=$(TF_DIR) destroy -var-file=../environments/$(ENV).tfvars

resources: check-env ## List all tfstate resources — make resources ENV=dev
	$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) state list

show: check-env ## Show resource in tfstate — make show ENV=dev RES=aws_iam_policy.x
	$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) state show $(RES)

state: check-env ## Pull tfstate — make state ENV=dev
	$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) state pull

output: check-env ## Show tfstate outputs — make output ENV=dev
	$(AWS_IDENTITY)
	@terraform -chdir=$(TF_DIR) output -json | jq '.'

# =============================================================================
# QUALITY AND SECURITY
# =============================================================================

checktf: ## Format and validate Terraform code
	@echo "Formatting code..."
	@terraform fmt -recursive $(TF_DIR)
	@terraform fmt -recursive $(MOD_DIR)
	@echo "Validating code..."
	@cd $(TF_DIR) && terraform validate

check: ## Linting and syntax validation
	@echo "Running TFLint..."
	@tflint --chdir=$(TF_DIR) --init
	@tflint --chdir=$(TF_DIR)

security: ## Security scan infra and modules
	@echo "Scanning for vulnerabilities..."
	@tfsec $(TF_DIR)
	@tfsec $(MOD_DIR)
	@echo "tfsec done... next checkov"
	@checkov -d $(TF_DIR) --quiet
	@checkov -d $(MOD_DIR) --quiet

# =============================================================================
# PRE-COMMIT
# =============================================================================

prec: ## Run pre-commit on staged files
	@pre-commit run

prec-all: ## Run pre-commit on all files
	@pre-commit run --all-files

# =============================================================================
# DOCUMENTATION
# =============================================================================

docs: check-env ## Generate Markdown docs for Obsidian — make docs ENV=dev
	@mkdir -p $(DOCS_DIR)
	@echo "Updating Obsidian documentation..."
	@terraform-docs markdown table $(TF_DIR) > $(DOCS_DIR)/infrastructure-$(ENV).md
	@echo "Documentation updated at $(DOCS_DIR)/infrastructure-$(ENV).md"

# =============================================================================
# UTILITIES
# =============================================================================

help: ## Show this help menu
	@grep -E '^[a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-15s\033[0m %s\n", $$1, $$2}'
