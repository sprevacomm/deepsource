terraform {
  required_providers {
    bcrypt = {
      source  = "viktorradnai/bcrypt"
      version = ">= 0.1.2"
    }
  }
}

locals {
  domain            = var.domain
  oidc_issuer_url   = "https://${var.cluster_oidc_subject}"
}

resource "kubernetes_namespace" "argocd" {
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

resource "random_password" "password" {
  length      = 8
  lower       = true
  upper       = true
  numeric     = true
  special     = false
  min_lower   = 1
  min_numeric = 1
  min_upper   = 1

  lifecycle {
    ignore_changes = [
      length,
      lower,
    ]
  }
}

resource "bcrypt_hash" "argo_password" {
  cleartext = random_password.password.result
}

resource "helm_release" "argocd" {
  name             = "argocd"
  repository       = "https://argoproj.github.io/argo-helm"
  chart            = "argo-cd"
  version          = var.argocd_chart_version
  namespace        = kubernetes_namespace.argocd.metadata[0].name
  create_namespace = false
  wait             = false
  wait_for_jobs    = false

  values = [
    templatefile("${path.module}/values.yaml", {
      domain                   = var.domain
      argocd_role_arn          = aws_iam_role.argocd.arn
      server_replicas          = var.server_replicas
      repo_server_replicas     = var.repo_server_replicas
      controller_replicas      = var.controller_replicas
      applicationset_replicas  = var.applicationset_replicas
      server_resources         = var.server_resources
      repo_server_resources    = var.repo_server_resources
      controller_resources     = var.controller_resources
      applicationset_resources = var.applicationset_resources
      redis_resources          = var.redis_resources
    })
  ]

  set_sensitive {
    name  = "configs.secret.argocdServerAdminPassword"
    value = bcrypt_hash.argo_password.id
  }

  depends_on = [kubernetes_namespace.argocd]
}

# Create IAM role for ArgoCD
resource "aws_iam_role" "argocd" {
  name = "${var.cluster_name}-argocd"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_arn
        }
        Condition = {
          StringEquals = {
            "${var.cluster_oidc_subject}:sub" = "system:serviceaccount:${kubernetes_namespace.argocd.metadata[0].name}:argocd-server"
            "${var.cluster_oidc_subject}:aud" = var.cluster_oidc_audience
          }
        }
      }
    ]
  })
}

# Add policy for ArgoCD to access AWS resources
resource "aws_iam_role_policy" "argocd" {
  name = "${var.cluster_name}-argocd-policy"
  role = aws_iam_role.argocd.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ecr:GetAuthorizationToken",
          "ecr:BatchCheckLayerAvailability",
          "ecr:GetDownloadUrlForLayer",
          "ecr:GetRepositoryPolicy",
          "ecr:DescribeRepositories",
          "ecr:ListImages",
          "ecr:DescribeImages",
          "ecr:BatchGetImage",
          "s3:GetObject",
          "s3:ListBucket"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "kubernetes_secret" "git_creds" {
  metadata {
    name      = "git-creds"
    namespace = "argocd"
  }

  data = {
    username = var.argo_git_username
    password = var.argo_git_token
  }
}

resource "kubernetes_secret" "private_repo_creds" {
  metadata {
    name      = "private-repo-creds"
    namespace = "argocd"
    labels = {
      "argocd.argoproj.io/secret-type" = "repository"
    }
  }

  data = {
    type     = "git"
    url      = "https://github.com/IntelliBridge/rapid-cc-practice.git"
    username = var.argo_git_username
    password = var.argo_git_token
  }
}

resource "kubernetes_manifest" "parent_application" {
  manifest = {
    apiVersion = "argoproj.io/v1alpha1"
    kind       = "Application"
    metadata = {
      name      = "rapid-cc-applications"
      namespace = "argocd"
      finalizers = [
        "resources-finalizer.argocd.argoproj.io"
      ]
    }
    spec = {
      project = "default"
      source = {
        repoURL        = "https://github.com/IntelliBridge/rapid-cc-practice.git"
        targetRevision = var.argocd_target_revision
        path           = "iac/modules/argocd/applications"
      }
      destination = {
        server    = "https://kubernetes.default.svc"
        namespace = "argocd"
      }
      syncPolicy = {
        automated = {
          prune    = true
          selfHeal = true
        }
        syncOptions = [
          "CreateNamespace=true"
        ]
      }
    }
  }

  field_manager {
    name = "terraform"
    force_conflicts = true
  }

  depends_on = [
    kubernetes_secret.private_repo_creds
  ]
}