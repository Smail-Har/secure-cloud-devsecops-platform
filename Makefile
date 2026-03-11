# ──────────────────────────────────────────────────────────────────────────────
# Makefile — Local CI helpers for secure-cloud-devsecops-platform
#
# Reproduces the GitHub Actions pipeline locally so you can iterate quickly
# before pushing. Requires: terraform, ansible-lint, docker.
#
# Usage:
#   make            # run the full local CI sequence
#   make build      # build the hardened NGINX image only
#   make lint       # ansible-lint only
#   make tf-check   # terraform fmt + init + validate only
#   make checkov    # Checkov IaC scan on terraform/
#   make scan       # Trivy CVE scan on the built image
#   make clean      # remove the local Docker image
# ──────────────────────────────────────────────────────────────────────────────

.PHONY: all build lint tf-check checkov scan clean help

COMMIT_SHA  ?= local
NGINX_IMAGE  = nginx-secure:$(COMMIT_SHA)
TRIVY_IMAGE  = aquasec/trivy:0.56.2

## all: Run the full local CI sequence (tf-check → lint → build → scan)
all: tf-check lint build scan

## tf-check: Validate Terraform (format, init, validate)
tf-check:
	@echo "==> Terraform: format check"
	terraform -chdir=terraform fmt -check -recursive
	@echo "==> Terraform: init (no backend)"
	terraform -chdir=terraform init -backend=false
	@echo "==> Terraform: validate"
	terraform -chdir=terraform validate

## checkov: Scan Terraform code with Checkov (informational, does not fail)
checkov:
	docker run --rm \
	  -v "$(PWD)/terraform:/tf:ro" \
	  bridgecrew/checkov:latest \
	  -d /tf \
	  --framework terraform \
	  --compact \
	  --soft-fail

## lint: Run ansible-lint on all playbooks
lint:
	@echo "==> Ansible: lint"
	ansible-lint ansible/playbooks/*.yml

## build: Build the hardened NGINX Docker image
build:
	@echo "==> Docker: build $(NGINX_IMAGE)"
	docker build -t $(NGINX_IMAGE) docker/nginx-secure/

## scan: Scan the built image for CVEs with Trivy (mirrors CI policy)
scan: build
	@echo "==> Trivy: scanning $(NGINX_IMAGE)"
	docker run --rm \
	  -v /var/run/docker.sock:/var/run/docker.sock \
	  $(TRIVY_IMAGE) image \
	  --severity CRITICAL,HIGH \
	  --ignore-unfixed \
	  --exit-code 1 \
	  --pkg-types os,library \
	  $(NGINX_IMAGE)

## clean: Remove the local Docker image
clean:
	docker rmi -f $(NGINX_IMAGE) 2>/dev/null || true

## help: List available targets with descriptions
help:
	@grep -E '^## ' Makefile | sed 's/^## /  make /'
