# Security Controls Implemented

This file tracks security controls currently implemented in the repository.

## Infrastructure Controls

- Enforced IMDSv2 on EC2 instance metadata
- Encrypted EBS root/data volumes using KMS CMK
- Encrypted CloudWatch log groups with KMS CMK
- VPC Flow Logs enabled for network visibility
- Least-privilege IAM instance profile for SSM and CloudWatch Agent

## Host Hardening Controls

- Disable root SSH login
- Disable SSH password authentication
- Install and enable fail2ban
- UFW default deny inbound policy
- Allowlist only OpenSSH, HTTP, HTTPS
- Regular package upgrades in hardening playbook

## Container Controls

- NGINX container runs as non-root user
- Hardened custom `nginx.conf` with security headers
- Hidden files blocked in NGINX rules
- Base image package upgrades during build

## CI/CD Controls

- Pinned GitHub Action versions
- Read-only default workflow permissions
- Terraform format and validation checks
- Ansible lint checks
- Trivy scan gate on high-impact vulnerabilities

## Planned Controls

- SBOM generation and signing
- IaC policy-as-code checks
- Runtime read-only filesystem and dropped capabilities
- Automated exception approvals with expiry dates
