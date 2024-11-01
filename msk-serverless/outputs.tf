data "aws_msk_bootstrap_brokers" "kafka" {
  cluster_arn = aws_msk_serverless_cluster.kafka.arn
}

output "bootstrap_brokers" {
  value = data.aws_msk_bootstrap_brokers.kafka.bootstrap_brokers_sasl_iam
}
