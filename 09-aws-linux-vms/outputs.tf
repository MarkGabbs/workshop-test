output "vpc_id" {
  description = "ID of the created VPC"
  value       = aws_vpc.main.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = aws_subnet.private.id
}

output "instance_ids" {
  description = "IDs of the EC2 instances"
  value       = aws_instance.linux[*].id
}

output "private_ips" {
  description = "Private IP addresses of the instances"
  value       = aws_instance.linux[*].private_ip
}

output "security_group_id" {
  description = "ID of the security group"
  value       = aws_security_group.private_vms.id
}
