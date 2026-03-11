# ADR-001: CI Security Gates

- Status: Accepted
- Date: 2026-03-11

## Context

The project requires a practical CI pipeline for a DevSecOps portfolio that validates infrastructure, configuration management, and container security.

## Decision

Implement a single GitHub Actions workflow that enforces mandatory checks:

1. Terraform checks (`fmt`, `init -backend=false`, `validate`)
2. Ansible lint checks (`ansible-lint` on playbooks)
3. Docker image build (`docker/nginx-secure`)
4. Trivy vulnerability scan with fail gate on `CRITICAL,HIGH`

Trivy is executed through a pinned container image to avoid setup instability in hosted runners.

## Consequences

- Pros:
  - Clear and reproducible quality gate
  - Fast feedback on IaC/config/container security regressions
  - Portfolio-ready demonstration of shift-left security
- Cons:
  - Occasional pipeline failures due to newly disclosed CVEs
  - Requires regular maintenance of base images and dependencies

## Follow-ups

- Add SARIF export and GitHub Security tab integration
- Add IaC static security scanners (Checkov/tfsec)
- Define exception process for temporary CVE acceptance
