resource "kubernetes_namespace" "kyverno" {
  metadata {
    name = var.namespace
    labels = {
      "app.kubernetes.io/managed-by" = "terraform"
    }
  }
  lifecycle {
    ignore_changes = [ 
      metadata
    ]
  }
}

resource "helm_release" "kyverno" {
  name             = "kyverno"
  repository       = "https://kyverno.github.io/kyverno/"
  chart            = "kyverno"
  version          = var.kyverno_chart_version
  namespace        = kubernetes_namespace.kyverno.metadata[0].name
  create_namespace = false

  set {
    name  = "admissionController.container.image.tag"
    value = var.kyverno_app_version
  }

  set {
    name  = "admissionController.replicas"
    value = var.replica_count
  }

  set {
    name  = "admissionController.webhooks.timeoutSeconds"
    value = var.webhook_timeout
  }

  set {
    name  = "features.logging.verbosity"
    value = var.log_level
  }

  set {
    name  = "admissionController.serviceMonitor.enabled"
    value = var.enable_monitoring
  }

  set {
    name  = "admissionController.rbac.serviceAccount.name"
    value = "kyverno-service-account"
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.kyverno.arn
    type  = "string"
  }

  set {
    name  = "config.webhooks[0].name"
    value = "validate-resources"
  }

  set {
    name  = "config.webhooks[0].failurePolicy"
    value = "Fail"
  }

  set {
    name  = "admissionController.container.resources.limits.memory"
    value = "512Mi"
  }
  
  set {
    name  = "admissionController.container.resources.limits.cpu"
    value = "1000m"
  }

  set {
    name  = "webhooksCleanup.enabled" 
    value = "true"
  }

  set {
    name  = "features.backgroundScan.enabled"
    value = var.background_scan_enabled
  }

  set {
    name  = "features.backgroundScan.backgroundScanWorkers"
    value = var.background_scan_workers
  }

  set {
    name  = "features.backgroundScan.backgroundScanInterval"
    value = var.background_scan_interval
  }

  depends_on = [kubernetes_namespace.kyverno]
}

# Create IAM role for Kyverno
resource "aws_iam_role" "kyverno" {
  name = "${var.cluster_name}-kyverno"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_provider}:sub" = "system:serviceaccount:${kubernetes_namespace.kyverno.metadata[0].name}:kyverno-service-account"
          }
        }
      }
    ]
  })
} 

# Add basic IAM policy for Kyverno
resource "aws_iam_role_policy" "kyverno" {
  name = "${var.cluster_name}-kyverno-policy"
  role = aws_iam_role.kyverno.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.cluster_name}-kyverno/*",
          "arn:aws:s3:::${var.cluster_name}-kyverno"
        ]
      }
    ]
  })
}

# Create IAM role for Policy Reporter
resource "aws_iam_role" "policy_reporter" {
  name = "${var.cluster_name}-policy-reporter"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_provider_arn
        }
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_provider}:sub" = "system:serviceaccount:${kubernetes_namespace.kyverno.metadata[0].name}:policy-reporter"
          }
        }
      }
    ]
  })
}

# Add IAM policy for Policy Reporter
resource "aws_iam_role_policy" "policy_reporter" {
  name = "${var.cluster_name}-policy-reporter-policy"
  role = aws_iam_role.policy_reporter.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::${var.cluster_name}-policy-reporter/*",
          "arn:aws:s3:::${var.cluster_name}-policy-reporter"
        ]
      }
    ]
  })
}

# Add Kyverno Policy Reporter UI - requires portforward of svc/policy-reporter-ui to access
resource "helm_release" "policy_reporter" {
  name             = "policy-reporter"
  repository       = "https://kyverno.github.io/policy-reporter"
  chart            = "policy-reporter"
  version          = var.policy_reporter_chart_version
  namespace        = kubernetes_namespace.kyverno.metadata[0].name
  create_namespace = false

  set {
    name  = "ui.enabled"
    value = var.policy_reporter_ui_enabled
  }

  set {
    name  = "metrics.enabled"
    value = var.policy_reporter_metrics_enabled
  }

  set {
    name  = "ui.plugins.kyverno"
    value = true
  }

  set {
    name  = "kyvernoPlugin.enabled"
    value = true
  }

  set {
    name  = "serviceAccount.create"
    value = true
  }

  set {
    name  = "serviceAccount.annotations.eks\\.amazonaws\\.com/role-arn"
    value = aws_iam_role.policy_reporter.arn
    type  = "string"
  }

  depends_on = [helm_release.kyverno]
}