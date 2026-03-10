# Secure Cloud DevSecOps Platform

This project demonstrates a real-world DevSecOps platform combining:

- Terraform Infrastructure as Code
- Ansible configuration management
- Docker container deployment
- Secure CI/CD pipelines
- Infrastructure and container security practices

## Architecture

The platform provisions secure AWS infrastructure using Terraform and configures instances using Ansible.

Key components:

- VPC with public and private subnets
- EC2 instance with hardened configuration
- Docker container running a secure NGINX service
- CI/CD pipeline with security scanning

## DevSecOps Workflow

1. Terraform provisions infrastructure
2. Ansible configures and hardens servers
3. Docker deploys the application
4. CI/CD pipeline runs security checks

## Security Features

- Least privilege IAM roles
- Encrypted storage
- Container vulnerability scanning
- Linux hardening
- Secure NGINX configuration

## Technologies

- Terraform
- Ansible
- Docker
- AWS
- GitHub Actions
- Trivy security scanning
