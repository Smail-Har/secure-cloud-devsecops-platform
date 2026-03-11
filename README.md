# Secure Cloud DevSecOps Platform

[![DevSecOps Pipeline](https://github.com/Smail-Har/secure-cloud-devsecops-platform/actions/workflows/devsecops.yml/badge.svg)](https://github.com/Smail-Har/secure-cloud-devsecops-platform/actions/workflows/devsecops.yml)

> A reference architecture and portfolio project demonstrating end-to-end DevSecOps practices on AWS — from infrastructure provisioning to container hardening and automated security checks.

---

## Table of Contents

1. [Project Overview](#project-overview)
2. [Objectives](#objectives)
3. [Architecture Overview](#architecture-overview)
4. [Project Structure](#project-structure)
5. [DevSecOps Workflow](#devsecops-workflow)
6. [Security Practices Implemented](#security-practices-implemented)
7. [Technologies Used](#technologies-used)
8. [How to Use Locally](#how-to-use-locally)
9. [Future Improvements](#future-improvements)
10. [Author](#author)

---

## Project Overview

**secure-cloud-devsecops-platform** is a portfolio-grade reference project that integrates industry-standard DevSecOps tooling into a single, cohesive platform. It covers the full lifecycle of a secure cloud deployment:

- Infrastructure as Code with Terraform
- Server configuration management and OS hardening with Ansible
- Containerised application delivery via a hardened Docker/NGINX setup
- Continuous security validation through a GitHub Actions CI pipeline with Trivy scanning

> **Note:** This project is designed as a reference architecture and learning resource. Basic local validation (Terraform syntax checks, Ansible linting, Docker builds) does not require a live AWS account.

---

## Objectives

- Demonstrate security-first thinking at every layer of the stack
- Provide a realistic, end-to-end DevSecOps workflow that can serve as a template for production workloads
- Show how open-source tooling (Terraform, Ansible, Docker, Trivy) can be combined into an automated security pipeline
- Serve as a portfolio reference for DevSecOps engineering practices

---

## Architecture Overview

```
┌─────────────────────────────────────────────────────┐
│                    AWS Account                      │
│                                                     │
│  ┌──────────────────────────────────────────────┐   │
│  │                    VPC                       │   │
│  │  ┌──────────────────────────────────────┐    │   │
│  │  │          Public Subnet               │    │   │
│  │  │  ┌───────────────────────────────┐   │    │   │
│  │  │  │  EC2 Instance (Ubuntu)        │   │    │   │
│  │  │  │  ├─ Docker                    │   │    │   │
│  │  │  │  │   └─ NGINX (hardened)      │   │    │   │
│  │  │  │  ├─ CloudWatch Agent          │   │    │   │
│  │  │  │  └─ SSM Agent (no SSH)        │   │    │   │
│  │  │  └───────────────────────────────┘   │    │   │
│  │  │  Security Group: 443 out / deny in   │    │   │
│  │  └──────────────────────────────────────┘    │   │
│  │  VPC Flow Logs → CloudWatch Logs (KMS)       │   │
│  └──────────────────────────────────────────────┘   │
│  KMS CMK — EBS encryption + CloudWatch encryption   │
└─────────────────────────────────────────────────────┘
```

**Key design decisions:**

| Decision | Rationale |
|---|---|
| IMDSv2 enforced | Prevents SSRF-based metadata credential theft |
| SSM instead of SSH | Eliminates inbound port 22 attack surface |
| Customer-managed KMS key | Full audit control over encryption lifecycle |
| VPC Flow Logs | Full network visibility for incident response |
| Non-root Docker container | Reduces blast radius of container compromise |

---

## Project Structure

```
secure-cloud-devsecops-platform/
│
├── .github/
│   └── workflows/
│       └── devsecops.yml          # GitHub Actions CI/CD pipeline
│
├── terraform/
│   ├── versions.tf                # Provider and Terraform version pinning
│   ├── variables.tf               # All configurable inputs
│   ├── main.tf                    # VPC, subnet, SG, EC2, EBS, CloudWatch, KMS
│   ├── outputs.tf                 # Resource identifiers and log group names
│   ├── user_data.sh.tpl           # EC2 bootstrap: installs CloudWatch Agent
│   └── modules/                   # Reserved for reusable module extraction
│
├── ansible/
│   ├── inventory/
│   │   └── hosts.ini              # Example inventory (one Ubuntu server)
│   ├── playbooks/
│   │   ├── install-docker.yml     # Installs Docker from official APT repo
│   │   ├── hardening.yml          # SSH hardening, fail2ban, UFW firewall
│   │   └── deploy-nginx.yml       # Deploys hardened NGINX as Docker container
│   └── roles/
│       └── common/                # Reserved for shared role tasks
│
├── docker/
│   └── nginx-secure/
│       ├── Dockerfile             # Minimal Alpine image, non-root runtime
│       └── nginx.conf             # Hardened NGINX config with security headers
│
├── docs/
│   ├── architecture.md            # Mermaid diagrams + deployment model
│   ├── threat-model.md            # Assets, threats, mitigations
│   └── adr-001-ci-security-gates.md  # Architecture Decision Record
├── security/
│   ├── security-controls.md       # Full controls register by layer
│   ├── trivy-baseline.md          # CVE baseline and remediation log
│   └── exceptions.md             # Exception register
├── cicd/
│   ├── pipeline-stages.md         # Stage-by-stage pipeline reference
│   ├── quality-gates.md           # Merge gates and break-glass guidance
│   └── local-ci.sh               # Bash script: full local CI run
├── Makefile                       # make build / lint / scan / checkov
└── README.md
```

---

## DevSecOps Workflow

Every push or pull request triggers the **GitHub Actions pipeline** defined in `.github/workflows/devsecops.yml`. The pipeline runs the following stages in sequence:

```
┌──────────┐  ┌──────────┐  ┌────────────────────┐  ┌──────────┐  ┌────────────────┐
│ Checkout │─▶│ Gitleaks │─▶│ Terraform + Checkov│─▶│ Ansible  │─▶│ Docker + Trivy │
└──────────┘  └──────────┘  └────────────────────┘  │ Lint     │  └────────────────┘
              • secrets         • fmt -check          └──────────┘  • docker build
              • full history    • init · validate     • ansible-    • Trivy CVE scan
              • exit 1          • Checkov IaC scan      lint        • fail HIGH/CRIT
```

### Stage details

**Terraform checks**
```bash
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

**Ansible lint**
```bash
ansible-galaxy collection install community.general community.docker
ansible-lint ansible/playbooks/*.yml
```

**Docker build + Trivy scan**
```bash
# Build the hardened NGINX image
docker build -t nginx-secure:${{ github.sha }} docker/nginx-secure/

# Scan for unfixed CRITICAL and HIGH CVEs (same policy as CI)
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:0.56.2 image \
  --severity CRITICAL,HIGH \
  --ignore-unfixed \
  --exit-code 1 \
  --pkg-types os,library \
  nginx-secure:${{ github.sha }}
```

---

## Security Practices Implemented

### Infrastructure (Terraform)
- **IMDSv2 required** — blocks SSRF attacks against EC2 metadata endpoint
- **EBS encryption at rest** using a customer-managed KMS key with automatic key rotation
- **CloudWatch log groups encrypted** with the same CMK; explicit key policy scoped to the Logs service principal
- **VPC Flow Logs** capturing all traffic (`ALL`) for audit and incident response
- **Least-privilege IAM roles** — EC2 instance profile grants only `CloudWatchAgentServerPolicy` and `AmazonSSMManagedInstanceCore`
- **No inbound SSH** — instance is managed exclusively via AWS Systems Manager Session Manager

### OS hardening (Ansible)
- Disable root SSH login (`PermitRootLogin no`)
- Disable password authentication (`PasswordAuthentication no`)
- Install and enable `fail2ban` for brute-force protection
- UFW firewall with default-deny inbound, allow only OpenSSH / HTTP / HTTPS
- Full system package upgrade on first run

### Container security (Docker + NGINX)
- Base image: `nginx:1.27-alpine` (minimal attack surface)
- Container runs as unprivileged user `101:101` (not root)
- Default NGINX config removed; only the hardened config is present
- NGINX security headers:
  - `X-Content-Type-Options: nosniff`
  - `X-Frame-Options: DENY`
  - `Content-Security-Policy` with strict allowlist
  - `Referrer-Policy: strict-origin-when-cross-origin`
  - `Permissions-Policy` disabling camera / microphone / geolocation
- Server version disclosure disabled (`server_tokens off`)
- Timeouts and body size limits to reduce abuse surface
- Hidden file access blocked (dotfiles)

### CI/CD pipeline (GitHub Actions)
- Pinned action versions (no floating `@main`)
- `permissions: contents: read` — minimal GITHUB_TOKEN scope
- Trivy scan runs in a pinned container image and fails the pipeline on unfixed CRITICAL or HIGH CVEs
- Docker layer cache via GitHub Actions cache backend

---

## Technologies Used

| Tool | Version | Purpose |
|---|---|---|
| Terraform | ≥ 1.5 | AWS infrastructure provisioning |
| AWS Provider | ~5.0 | VPC, EC2, EBS, IAM, CloudWatch, KMS |
| Ansible | Latest stable | Server configuration and OS hardening |
| ansible-lint | ≥ 24 | Ansible best-practice enforcement |
| Docker | Latest | Container runtime |
| NGINX | 1.27-alpine | Hardened web server / reverse proxy |
| GitHub Actions | — | CI/CD orchestration |
| Trivy | 0.56.2 (container image) | Container vulnerability scanning |
| Checkov | Latest (bridgecrew/checkov-action@v12) | Terraform IaC misconfiguration scanning |
| Gitleaks | v8.21.2 (container image) | Secrets and credential detection in git history |
| Python | 3.12 | Ansible toolchain runtime |

---

## How to Use Locally

> No AWS account is required for local validation steps.

### Prerequisites

```bash
# Install Terraform (https://developer.hashicorp.com/terraform/install)
terraform -version   # >= 1.5.0

# Install Ansible and ansible-lint
pip install -r requirements-dev.txt
ansible-galaxy collection install community.general community.docker

# Install Docker (https://docs.docker.com/engine/install/)
docker info
```

### Quick start with Make

The `Makefile` reproduces the full CI pipeline locally:

```bash
make          # full sequence: tf-check → lint → build → scan
make tf-check # terraform fmt + init + validate
make lint     # ansible-lint on all playbooks
make build    # docker build nginx-secure:local
make scan     # Trivy CVE scan (mirrors CI policy)
make checkov  # Checkov IaC scan on terraform/ (informational)
make clean    # remove local docker image
```

### Step by step

#### 1 — Validate Terraform

```bash
cd terraform/
terraform fmt -check -recursive
terraform init -backend=false
terraform validate
```

#### 2 — Lint Ansible playbooks

```bash
ansible-lint ansible/playbooks/*.yml
```

#### 3 — Build and test the NGINX container

```bash
docker build -t nginx-secure:local docker/nginx-secure/

# Run locally and verify
docker run --rm -p 8080:80 nginx-secure:local
curl -I http://localhost:8080
```

#### 4 — Run a Trivy security scan

```bash
docker run --rm \
  -v /var/run/docker.sock:/var/run/docker.sock \
  aquasec/trivy:0.56.2 image \
  --severity CRITICAL,HIGH \
  --ignore-unfixed \
  --exit-code 1 \
  --pkg-types os,library \
  nginx-secure:local
```

#### 5 — Provision on AWS (optional)

```bash
cd terraform/
# Configure AWS credentials before this step
terraform init
terraform plan
terraform apply
```

---

## Future Improvements

- [ ] Add a private subnet and NAT Gateway for a fully private EC2 instance
- [ ] Extract Terraform resources into reusable modules under `terraform/modules/`
- [ ] Add HTTPS/TLS termination to the NGINX container with Let's Encrypt or ACM
- [ ] Add a `.checkov.yaml` config to suppress accepted exceptions and switch Checkov to `soft_fail: false`
- [ ] Add **OWASP ZAP** or **Nikto** dynamic scan stage to the pipeline
- [ ] Configure remote Terraform state in S3 with DynamoDB locking
- [ ] Add Ansible Vault integration for secrets management
- [ ] Extend the pipeline with SBOM (Software Bill of Materials) generation via Trivy
- [ ] Add **Semgrep** SAST scan for Ansible playbooks and configuration files

---

## Author

Built and maintained as a DevSecOps portfolio reference project.  
Contributions, questions, and feedback are welcome via GitHub Issues or Pull Requests.

---

*This project is for educational and portfolio purposes. Review all configurations before using in a production environment.*
