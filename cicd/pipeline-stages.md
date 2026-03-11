# CI/CD Pipeline Stages

Workflow file: `.github/workflows/devsecops.yml`

## Stage 1: Checkout

- Pull repository contents for subsequent jobs.

## Stage 2: Terraform Checks

- `terraform fmt -check -recursive`
- `terraform init -backend=false`
- `terraform validate`

Goal: prevent broken or non-standard IaC from merging.

## Stage 3: Ansible Checks

- Install Python toolchain dependencies
- Install required collections (`community.general`, `community.docker`)
- `ansible-lint ansible/playbooks/*.yml`

Goal: ensure playbook quality, style, and best-practice compliance.

## Stage 4: Docker Build

- Build hardened NGINX image from `docker/nginx-secure`
- Load built image into local runner daemon

Goal: validate container build reproducibility.

## Stage 5: Trivy Security Scan

- Scan built image using pinned Trivy container
- Fail pipeline on `CRITICAL,HIGH`

Goal: block known high-impact vulnerabilities from passing CI.
