variable "app_name" {
  description = "Name of the application"
  type        = string
}

variable "app_namespace" {
  description = "Namespace for the application"
  type        = string
}

variable "base_name" {
  description = "Base Name"
  type        = string
}

variable "cluster_oidc_arn" {
  description = "Cluster OIDC Provider ARN"
  type        = string
}

variable "cluster_oidc_subject" {
  description = "Cluster OIDC Provider Subject"
  type        = string
}

variable "cluster_oidc_audience" {
  description = "Cluster OIDC Provider Audience"
  type        = string
}
