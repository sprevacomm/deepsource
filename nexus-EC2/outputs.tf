output "instance_id" {
  value       = aws_instance.nexus.id
  description = "ID of the EC2 instance"
}

output "instance_private_ip" {
  value       = aws_instance.nexus.private_ip
  description = "Private IP of the EC2 instance"
}

output "alb_dns_name" {
  value       = aws_lb.nexus.dns_name
  description = "DNS name of the Application Load Balancer"
}

output "target_group_arn" {
  value       = aws_lb_target_group.nexus.arn
  description = "ARN of the target group"
}

output "dns_name" {
  value       = aws_route53_record.nexus.fqdn
  description = "The fully qualified domain name of the Nexus instance"
}

output "admin_password" {
  description = "Admin password for Nexus"
  value       = random_password.admin_password.result
}
