output "address" {
  description = "The address of the RDS instance"
  value       = aws_db_instance.default.address
}

output "endpoint" {
  description = "The connection endpoint"
  value       = aws_db_instance.default.endpoint
}

output "password" {
  description = "The password for the master DB user"
  sensitive   = true
  value       = local.db_password
}

output "port" {
  description = "The port on which the RDS instance is accessible"
  value       = aws_db_instance.default.port
}

output "username" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.default.username
}

output "db_name" {
  description = "The username for the RDS instance"
  value       = aws_db_instance.default.db_name
}
