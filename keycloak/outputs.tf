output "url" {
  description = "Url for Keycloak"
  value       = "https://${var.hostname}"
}

output "admin_password" {
  description = "Admin password for Keycloak"
  value       = random_password.this["adminPassword"].result
}
