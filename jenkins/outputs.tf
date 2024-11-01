output "admin_password" {
  description = "Admin password for Jenkins"
  value       = random_password.password.result
}

output "base_image" {
  description = "Jenkins agent image"
  value       = "${docker_image.base.name}@${docker_image.base.image_id}"
}

output "base_image_repo_digest" {
  description = "Jenkins agent image"
  value       = docker_image.base.repo_digest
}

output "base_registry_image" {
  description = "Jenkins agent registry image"
  value       = "${docker_registry_image.base.name}@${docker_registry_image.base.sha256_digest}"
}
