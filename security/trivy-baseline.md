# Trivy Baseline and Remediation Tracking

This document captures baseline Trivy findings and remediation intent.

## Baseline Snapshot

- Date: 2026-03-11
- Scan target: `nginx-secure:<commit_sha>`
- Scanner policy: fail on `CRITICAL,HIGH`
- Initial result observed in CI: multiple `CRITICAL` and `HIGH` OS package findings

## Immediate Mitigation Applied

- Added Alpine package upgrade during image build:
  - `apk --no-cache upgrade --available`

## Remediation Process

1. Rebuild image with latest upstream base image.
2. Re-run Trivy scan in CI.
3. Track remaining findings by package and fix availability.
4. Prioritize `CRITICAL` fixes, then `HIGH`.
5. Add temporary exception only when no fix exists and business justification is documented.

## CVE Management Rules (Recommended)

- `CRITICAL`: patch immediately or block release
- `HIGH`: patch in next sprint or block release if internet-facing
- `MEDIUM/LOW`: track backlog with periodic review

## Evidence Links

- CI pipeline runs: GitHub Actions "DevSecOps Pipeline"
- Dockerfile hardening source: `docker/nginx-secure/Dockerfile`
