resource "helm_release" "ingress-nginx" {
  name       = "ingress-nginx"
  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.3"

  namespace        = "ingress-nginx"
  create_namespace = true

  values = [
    yamlencode({
      controller = {
        config = {
          "use-forwarded-headers" = "true"
        }
        ingressClassResource = {
          default = true
        }
        replicaCount = 2
        service = {
          type = "NodePort"
          nodePorts = {
            http = "30080"
            https = "30443"
          }
        }
        extraArgs = {
          "enable-ssl-passthrough" = true
        }
      }
    })
  ]
}