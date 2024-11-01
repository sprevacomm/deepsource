resource "helm_release" "cert-manager" {
  name          = "cert-manager"
  repository    = "https://charts.jetstack.io"
  chart         = "cert-manager"
  version       = "v1.13.1"
  timeout       = 900
  wait          = true
  wait_for_jobs = true

  namespace        = "cert-manager"
  create_namespace = true

  set {
    name  = "installCRDs"
    value = true
  }
}
