output "bootstrap_brokers" {
  value = aws_msk_cluster.kafka.bootstrap_brokers_sasl_scram
}

output "secret_name" {
  value = aws_secretsmanager_secret.kafka.name
}
