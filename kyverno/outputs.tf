output "namespace" {
  description = "The namespace where Kyverno is installed"
  value       = kubernetes_namespace.kyverno.metadata[0].name
}

output "service_account_name" {
  description = "Name of the Kyverno service account"
  value       = "kyverno-service-account"
}

output "role_arn" {
  description = "ARN of the IAM role created for Kyverno"
  value       = aws_iam_role.kyverno.arn
}

output "helm_release_name" {
  description = "Name of the Helm release"
  value       = helm_release.kyverno.name
}

output "policy_reporter_ui_service" {
  description = "Name of the Policy Reporter UI service"
  value       = var.policy_reporter_ui_enabled ? "policy-reporter-ui" : null
}

output "policy_reporter_role_arn" {
  description = "ARN of the IAM role created for Policy Reporter"
  value       = aws_iam_role.policy_reporter.arn
}

output "policy_reporter_helm_release_name" {
  description = "Name of the Policy Reporter Helm release"
  value       = helm_release.policy_reporter.name
}