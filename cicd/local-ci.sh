#!/usr/bin/env bash
set -euo pipefail

# Local CI helper script.
# Runs the same core checks as GitHub Actions where possible.

ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "${ROOT_DIR}"

echo "[1/5] Terraform format check"
terraform -chdir=terraform fmt -check -recursive

echo "[2/5] Terraform init (backend disabled)"
terraform -chdir=terraform init -backend=false

echo "[3/5] Terraform validate"
terraform -chdir=terraform validate

echo "[4/5] Ansible lint"
ansible-lint ansible/playbooks/*.yml

echo "[5/5] Docker build + Trivy scan"
IMAGE_TAG="nginx-secure:local"
docker build -t "${IMAGE_TAG}" docker/nginx-secure

docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:0.56.2 image \
  --severity CRITICAL,HIGH \
  --ignore-unfixed \
  --exit-code 1 \
  --pkg-types os,library \
  "${IMAGE_TAG}"

echo "All local CI checks passed."
