resource "helm_release" "rancher" {
  name       = "rancher"
  repository = "https://releases.rancher.com/server-charts/latest"
  chart      = "rancher"
  version    = "2.7.9"
  wait       = false

  namespace        = "cattle-system"
  create_namespace = true

  set_sensitive {
    name  = "bootstrapPassword"
    value = "admin"
  }

  set {
    name  = "hostname"
    value = var.domain
  }
}
