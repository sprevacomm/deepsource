output "jenkins_token_arn" {
  value = aws_secretsmanager_secret.sonarqube_jenkins_token.arn
}

output "jenkins_token" {
  value = sonarqube_user_token.jenkins.token
}
