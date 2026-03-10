variable "aws_region" {
  description = "AWS region to deploy resources in"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name used in resource naming and tagging"
  type        = string
  default     = "secure-devsecops"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.10.0.0/16"
}

variable "public_subnet_cidr" {
  description = "CIDR block for the public subnet"
  type        = string
  default     = "10.10.1.0/24"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "t3.micro"
}

variable "associate_public_ip" {
  description = "Whether to assign a public IP to the EC2 instance"
  type        = bool
  default     = true
}

variable "enable_ssh" {
  description = "Enable inbound SSH access. Keep false and use SSM for better security."
  type        = bool
  default     = false
}

variable "ssh_allowed_cidr" {
  description = "CIDR allowed for SSH when enable_ssh is true"
  type        = string
  default     = null
  nullable    = true
}

variable "key_name" {
  description = "Optional EC2 key pair name. Leave null when using SSM only."
  type        = string
  default     = null
  nullable    = true
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 20
}

variable "data_volume_size" {
  description = "Additional encrypted EBS data volume size in GiB"
  type        = number
  default     = 20
}

variable "log_retention_days" {
  description = "Retention period in days for CloudWatch log groups"
  type        = number
  default     = 30
}

variable "tags" {
  description = "Additional tags applied to all resources"
  type        = map(string)
  default     = {}
}
