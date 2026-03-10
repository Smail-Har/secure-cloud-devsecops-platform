# Secure AWS Terraform Stack

This Terraform project creates a secure AWS baseline with:

- VPC
- Public subnet
- Security group
- EC2 instance
- Encrypted EBS (root + additional volume)
- CloudWatch logging (EC2 logs + VPC Flow Logs)

## Security Best Practices Included

- IMDSv2 enforced on EC2 (`http_tokens = required`)
- EBS encryption enabled with a customer-managed KMS key
- CloudWatch log groups encrypted with KMS and retention policy
- VPC Flow Logs enabled (`traffic_type = ALL`)
- Instance profile with least-privilege managed policies for SSM and CloudWatch Agent
- SSH disabled by default (prefer AWS Systems Manager Session Manager)
- Restricted outbound traffic to HTTPS only

## Usage

```bash
cd terraform
terraform init
terraform plan
terraform apply
```

## Optional Inputs

- `enable_ssh` (default: `false`)
- `ssh_allowed_cidr` (required only when `enable_ssh = true`)
- `key_name` (optional EC2 key pair)

Example:

```hcl
aws_region        = "us-east-1"
project_name      = "secure-devsecops"
enable_ssh        = true
ssh_allowed_cidr  = "203.0.113.10/32"
key_name          = "my-keypair"
```
