resource "helm_release" "sonarqube" {
  name          = "sonarqube"
  repository    = "https://SonarSource.github.io/helm-chart-sonarqube"
  chart         = "sonarqube"
  version       = "10.2.1+800"
  timeout       = 900
  wait          = true
  wait_for_jobs = true

  namespace        = "sonarqube"
  create_namespace = true

  set_sensitive {
    name  = "account.adminPassword"
    value = resource.random_password.password.result
  }

  set_sensitive {
    name  = "account.currentAdminPassword"
    value = "admin"
  }

  set {
    name  = "elasticsearch.bootstrapChecks"
    value = false
  }

  set {
    name  = "ingress.hosts[0].name"
    value = var.domain
  }

  set {
    name  = "ingress.enabled"
    value = true
  }

  set {
    name  = "resources.limits.cpu"
    value = "4"
  }

  set {
    name  = "resources.limits.memory"
    value = "6Gi"
  }

  set {
    name  = "resources.requests.cpu"
    value = "100m"
  }

  set {
    name  = "resources.requests.memory"
    value = "4Gi"
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

# Wait for SonarQube to respond to ping
resource "null_resource" "ping" {
  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    working_dir = path.module
    command     = <<EOT
      echo >&2 "Wait until SonarQube is ready"
      until curl -fSsL --connect-timeout 10 -u "admin:${nonsensitive(resource.random_password.password.result)}" "https://${var.domain}/api/system/status" | grep -q -w "UP"; do
        sleep 5
      done
      echo >&2 "SonarQube is ready"
    EOT
  }

  # Re-run this when there is a change to sonarqube values
  triggers = {
    vals_changed = helm_release.sonarqube.metadata[0].revision
  }

  depends_on = [helm_release.sonarqube]
}
