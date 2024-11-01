output "argocd_url" {
  description = "URL for ArgoCD"
  value       = "https://argocd.${var.domain}"
}

output "argocd_admin_password" {
  description = "Admin password for ArgoCD"
  value       = nonsensitive(random_password.password.result)
  sensitive   = false
}