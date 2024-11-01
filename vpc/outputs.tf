output "public_subnets" {
  description = "List of public subnet IDs"
  value       = aws_subnet.public[*].id
}

output "public_subnet_cidrs" {
  description = "List of public subnet CIDRs"
  value       = aws_subnet.public[*].cidr_block
}

output "private_subnets" {
  description = "List of private subnet IDs"
  value       = aws_subnet.private[*].id
}

output "private_subnet_cidrs" {
  description = "List of private subnet CIDRs"
  value       = aws_subnet.private[*].cidr_block
}

output "vpc_id" {
  description = "The VPC ID"
  value       = aws_vpc.this.id
}

output "ec2_instance_connect_sg" {
  description = "EC2 Instance Connect Security Group"
  value       = aws_security_group.ec2_instance_connect.id
}

output "ec2_key_pair" {
  description = "EC2 Key Pair"
  value       = aws_key_pair.default.key_name
}
