output "db_endpoint" {
  description = "DB Endpoint"
  value       = aws_rds_cluster.db.endpoint
}

output "db_secret" {
  description = "DB Managed Secret"
  value       = aws_rds_cluster.db.master_user_secret
}

