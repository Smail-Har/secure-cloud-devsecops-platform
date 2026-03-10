output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = aws_subnet.public.id
}

output "security_group_id" {
  description = "ID of the EC2 security group"
  value       = aws_security_group.ec2.id
}

output "ec2_instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.main.id
}

output "ec2_public_ip" {
  description = "Public IP of the EC2 instance"
  value       = aws_instance.main.public_ip
}

output "encrypted_ebs_volume_id" {
  description = "ID of the additional encrypted EBS volume"
  value       = aws_ebs_volume.data.id
}

output "cloudwatch_log_groups" {
  description = "CloudWatch Log Groups created by this stack"
  value = {
    ec2_system    = aws_cloudwatch_log_group.ec2_system.name
    ec2_cloudinit = aws_cloudwatch_log_group.ec2_cloud_init.name
    vpc_flowlogs  = aws_cloudwatch_log_group.vpc_flow_logs.name
  }
}
