# Architecture Overview

This project demonstrates a security-first DevSecOps reference architecture for AWS.

## Pipeline Flow

```mermaid
flowchart LR
    A([Push / PR]) --> B[Gitleaks\nSecrets Scan]
    B --> C[Terraform\nfmt · init · validate]
    C --> D[Checkov\nIaC Scan]
    D --> E[Ansible\nLint]
    E --> F[Docker\nBuild]
    F --> G[Trivy\nCVE Scan]
    G --> H{Pass?}
    H -- Yes --> I([Merge allowed])
    H -- No  --> J([Pipeline fails])

    style B fill:#e74c3c,color:#fff
    style D fill:#e67e22,color:#fff
    style G fill:#e74c3c,color:#fff
```

## AWS Deployment

```mermaid
graph TD
    subgraph AWS["AWS Account"]
        subgraph VPC["VPC + Public Subnet"]
            EC2["EC2 Ubuntu\n(IMDSv2 enforced)"]
            EC2 --> Docker["Docker"]
            Docker --> NGINX["NGINX\nnon-root 101:101"]
        end
        EC2 <-->|"No SSH\n(port 22 closed)"| SSM["SSM Session Manager"]
        EC2 --> CW["CloudWatch Logs\n(KMS encrypted)"]
        EBS["EBS Volume\n(KMS encrypted)"] --- EC2
        FL["VPC Flow Logs"] --> CW
    end

    style AWS fill:#1a1a2e,color:#eee
    style VPC fill:#16213e,color:#eee
```

## Scope

- Provision cloud infrastructure with Terraform
- Harden hosts and deploy runtime with Ansible
- Build and run a hardened NGINX container with Docker
- Enforce automated checks in GitHub Actions
- Scan container vulnerabilities with Trivy

## Logical Flow

1. Terraform provisions AWS baseline resources (VPC, subnet, EC2, SG, KMS, CloudWatch).
2. Ansible configures Docker, applies host hardening, and deploys NGINX container.
3. CI pipeline validates Terraform, lints Ansible, builds Docker image, and runs Trivy scan.

## Security-by-Design Controls

- IAM least privilege roles for EC2 and logging
- IMDSv2 required on EC2 instance
- Encrypted EBS and CloudWatch logs with KMS CMK
- VPC flow logs for network observability
- Non-root container runtime for NGINX
- Fail-on-severity policy in vulnerability scan

## Deployment Model

- Single-account reference deployment
- Public subnet demo footprint for portfolio simplicity
- Production extension path:
  - private subnets
  - NAT egress controls
  - WAF/TLS ingress
  - remote Terraform state with locking
