variable "namespace" {
  description = "Kubernetes namespace for Kyverno"
  type        = string
  default     = "kyverno"
}

variable "kyverno_chart_version" {
  description = "Version of Kyverno Helm chart to install"
  type        = string
  default     = "3.3.1"
}

variable "kyverno_app_version" {
  description = "Version of Kyverno admission controller container image to install"
  type        = string
  default     = "v1.13.0"
}

variable "replica_count" {
  description = "Number of admission controller replicas"
  type        = number
  default     = 1
}

variable "webhook_timeout" {
  description = "Timeout for admission webhook operations in seconds (under admissionController.webhooks.timeoutSeconds)"
  type        = number
  default     = 30  # Match values.yaml default
}

variable "log_level" {
  description = "Logging verbosity level for Kyverno (under features.logging.verbosity)"
  type        = string
  default     = "2"  # Changed from "INFO" as it expects a number in values.yaml
}

variable "enable_monitoring" {
  description = "Enable Prometheus monitoring via ServiceMonitor for admission controller"
  type        = bool
  default     = true
}

variable "cluster_name" {
  description = "Name of the EKS cluster"
  type        = string
}

variable "cluster_oidc_provider" {
  description = "OIDC provider URL for the EKS cluster"
  type        = string
}

variable "cluster_oidc_provider_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "policies" {
  description = "Map of Kyverno policies to apply"
  type        = map(string)
  default     = {}
}

variable "policy_reporter_chart_version" {
  description = "Version of Policy Reporter Helm chart to install"
  type        = string
  default     = "3.0.0-rc.7"
}

variable "policy_reporter_ui_enabled" {
  description = "Enable Policy Reporter UI"
  type        = bool
  default     = true
}

variable "policy_reporter_metrics_enabled" {
  description = "Enable Policy Reporter metrics"
  type        = bool
  default     = false
}

variable "background_scan_enabled" {
  description = "Enable background scanning for policy violations"
  type        = bool
  default     = true
}

variable "background_scan_workers" {
  description = "Number of background scan workers"
  type        = number
  default     = 2
}

variable "background_scan_interval" {
  description = "Interval between background scans"
  type        = string
  default     = "1h"
}