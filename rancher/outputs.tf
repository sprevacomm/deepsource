output "url" {
  value = "https://${jsondecode(helm_release.rancher.metadata[0].values).hostname}"
}
