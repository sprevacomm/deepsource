
resource "sonarqube_user_token" "jenkins" {
  login_name = "admin"
  name       = "jenkins-token"
}

resource "aws_secretsmanager_secret" "sonarqube_jenkins_token" {
  name                    = "${var.base_name}/sonarqube/jenkins-token"
  description             = "SonarQube Jenkins token for ${var.base_name}"
  recovery_window_in_days = 0
}

resource "aws_secretsmanager_secret_version" "sonarqube_jenkins_token" {
  secret_id     = aws_secretsmanager_secret.sonarqube_jenkins_token.id
  secret_string = sonarqube_user_token.jenkins.token

  lifecycle {
    ignore_changes = [secret_string]
  }
}
