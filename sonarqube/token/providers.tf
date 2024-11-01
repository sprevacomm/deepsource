terraform {
  required_providers {
    sonarqube = {
      source  = "jdamata/sonarqube"
      version = "0.16.13"
    }
  }
}

provider "sonarqube" {
  user = "admin"
  pass = var.admin_password
  host = "https://${var.domain}"
  installed_edition = "Community"
  installed_version = "10.2.1"
}
