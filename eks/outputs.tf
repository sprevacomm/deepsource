output "cluster_name" {
  description = "Cluster name"
  value       = aws_eks_cluster.this.name
}

output "cluster_endpoint" {
  description = "Cluster endpoint"
  value       = aws_eks_cluster.this.endpoint
}

output "cluster_ca_certificate" {
  description = "Certificate data required to communicate with the cluster"
  value       = base64decode(aws_eks_cluster.this.certificate_authority[0].data)
}

output "cluster_security_group_id" {
  description = "Cluster Secuirty Group ID"
  value       = aws_eks_cluster.this.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_arn" {
  description = "Cluster OIDC Provider ARN"
  value       = aws_iam_openid_connect_provider.this.arn
}

output "cluster_oidc_subject" {
  description = "Cluster OIDC Provider Subject"
  value       = local.oidc_subject
}

output "cluster_oidc_audience" {
  description = "Cluster OIDC Provider Audience"
  value       = local.oidc_audience
}

output "cluster_auto_scaling_group_name" {
  description = "Cluster Auto Scaling Group Name"
  value       = lookup(lookup(lookup(aws_eks_node_group.this, "resources")[0], "autoscaling_groups")[0], "name")
}
