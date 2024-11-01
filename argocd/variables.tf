variable "namespace" {
  description = "Kubernetes namespace for ArgoCD"
  type        = string
  default     = "argocd"
}

variable "argocd_chart_version" {
  description = "Version of ArgoCD Helm Chart to install"
  type = string
  default = "7.6.12"
}

variable "argo_git_username" {
  description = "GitHub username for repository access"
  type        = string
  sensitive   = true
}

variable "argo_git_token" {
  description = "GitHub Personal Access Token"
  type        = string
  sensitive   = true
}

variable "argocd_target_revision" {
  description = "Target revision for ArgoCD application (branch, tag, or commit)"
  type        = string
  default     = "iac/RAPCON-302" # Spatnode security branch
}

variable "domain" {
  description = "Domain name for ArgoCD"
  type        = string
}

variable "cluster_name" {
  description = "Cluster Name"
  type        = string
}

variable "cluster_oidc_subject" {
  description = "The OIDC subject from the EKS cluster"
  type        = string
}

variable "cluster_oidc_audience" {
  description = "The OIDC audience from the EKS cluster"
  type        = string
}

variable "cluster_oidc_arn" {
  description = "ARN of the OIDC provider for the EKS cluster"
  type        = string
}

variable "server_replicas" {
  description = "Number of ArgoCD server replicas"
  type        = number
  default     = 1
}

variable "repo_server_replicas" {
  description = "Number of ArgoCD repo server replicas"
  type        = number
  default     = 1
}

variable "controller_replicas" {
  description = "Number of ArgoCD application controller replicas"
  type        = number
  default     = 1
}

variable "applicationset_replicas" {
  description = "Number of ApplicationSet controller replicas"
  type        = number
  default     = 1
}

variable "server_resources" {
  description = "Resource limits and requests for ArgoCD server"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "repo_server_resources" {
  description = "Resource limits and requests for ArgoCD repo server"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "controller_resources" {
  description = "Resource limits and requests for ArgoCD application controller"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "applicationset_resources" {
  description = "Resource limits and requests for ApplicationSet controller"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "500m"
      memory = "1Gi"
    }
    requests = {
      cpu    = "250m"
      memory = "512Mi"
    }
  }
}

variable "redis_resources" {
  description = "Resource limits and requests for Redis"
  type = object({
    limits = object({
      cpu    = string
      memory = string
    })
    requests = object({
      cpu    = string
      memory = string
    })
  })
  default = {
    limits = {
      cpu    = "300m"
      memory = "512Mi"
    }
    requests = {
      cpu    = "100m"
      memory = "256Mi"
    }
  }
}