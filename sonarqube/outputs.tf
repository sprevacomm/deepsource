output "admin_password" {
  description = "Admin password for SonarQube"
  value       = random_password.password.result
}
