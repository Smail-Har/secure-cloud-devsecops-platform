# Quality Gates

This project enforces the following merge gates in CI:

## Required Gates

1. Terraform format check passes
2. Terraform validation passes
3. Ansible lint passes
4. Docker image build succeeds
5. Trivy scan reports no unfixed `CRITICAL` or `HIGH` vulnerabilities

## Gate Ownership

- IaC gates: platform/devops owner
- Configuration gates: systems/devops owner
- Container security gate: devsecops/security owner

## Break-Glass Guidance

- Do not bypass required checks in normal workflow.
- If an urgent exception is required:
  1. Add entry in `security/exceptions.md`
  2. Define expiry date and owner
  3. Open a remediation issue and link it in the exception
