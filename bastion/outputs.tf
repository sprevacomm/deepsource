output "security_group" {
  description = "The security group ID"
  value       = aws_security_group.bastion
}

output "instance_id" {
  description = "The instance ID"
  value       = aws_instance.bastion.id
}
