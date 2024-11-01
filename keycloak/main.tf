resource "random_password" "this" {
  for_each    = toset(["adminPassword", "postgresPassword", "password"])
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

resource "helm_release" "keycloak" {
  name       = "keycloak"
  repository = "https://charts.bitnami.com/bitnami"
  chart      = "keycloak"
  version    = "22.2.4"
  wait       = false

  namespace        = "keycloak"
  create_namespace = true
  
    set {
    name  = "networkPolicy.enabled"
    value = "false"
  }

    set {
    name  = "postgresql.networkPolicy.enabled"
    value = "false"
  }
  
  values = [
    <<-EOT
auth:
  adminUser: admin
  adminPassword: ${random_password.this["adminPassword"].result}
service:
  type: ClusterIP
ingress:
  enabled: true
  ingressClassName: nginx
  hostname: ${var.hostname}
  path: /
  pathType: Prefix
  annotations:
    nginx.ingress.kubernetes.io/ssl-redirect: "false"
    nginx.ingress.kubernetes.io/backend-protocol: "HTTP"
extraEnvVars:
  - name: KEYCLOAK_PROXY_ADDRESS_FORWARDING
    value: "true"
  - name: KEYCLOAK_FRONTEND_URL
    value: "https://${var.hostname}/auth"
  - name: PROXY_ADDRESS_FORWARDING
    value: "true"
proxyAddressForwarding: true
proxy: edge
postgresql:
  enabled: true
  networkPolicy:
    enabled: false
  auth:
    postgresPassword: ${random_password.this["postgresPassword"].result}
    password: ${random_password.this["password"].result}
EOT
  ]
}
