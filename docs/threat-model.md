# Threat Model (Lightweight)

This document captures key threats and current mitigations for the reference platform.

## Assets

- Infrastructure state and configuration
- EC2 host and runtime services
- Container image and dependencies
- CI pipeline execution context

## Threats and Mitigations

| Threat | Risk | Current Mitigation | Gap / Next Step |
|---|---|---|---|
| Exposed SSH brute force | Host compromise | Password auth disabled, root login disabled, fail2ban, UFW | Prefer SSM-only access in all environments |
| Metadata credential theft (SSRF) | IAM credential leak | IMDSv2 enforced | Add egress filtering and app-layer SSRF protections |
| Container breakout impact | Privilege escalation | Container runs as non-root | Add read-only rootfs and dropped Linux capabilities at runtime |
| Vulnerable base packages | RCE / DoS | Trivy scan in CI with fail gate | Add image update cadence and CVE SLA tracking |
| Infra misconfiguration drift | Security regression | Terraform validation + code review | Add policy-as-code (Checkov/tfsec/OPA) |
| CI supply chain risk | Pipeline compromise | Pinned action versions, minimal permissions | Add artifact signing and provenance attestation |

## Assumptions

- Repository access is controlled via GitHub RBAC.
- AWS credentials are managed outside the repository.
- This project is a reference architecture, not a fully isolated production landing zone.
