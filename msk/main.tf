resource "aws_kms_key" "kafka_kms_key" {
  description = "Key for Kafka ${var.base_name}"
}
resource "aws_kms_alias" "kafka_kms_key" {
  name          = "alias/${var.base_name}-kafka"
  target_key_id = aws_kms_key.kafka_kms_key.id
}

resource "aws_cloudwatch_log_group" "kafka_log_group" {
  name = "kafka-${var.base_name}"
}
resource "aws_msk_configuration" "kafka_config" {
  kafka_versions = ["3.4.0"]
  name           = var.base_name

  #   server_properties = <<PROPERTIES
  # auto.create.topics.enable = true
  # delete.topic.enable = true
  # PROPERTIES  

  server_properties = <<PROPERTIES
allow.everyone.if.no.acl.found = false
delete.topic.enable = true
PROPERTIES
}

resource "aws_security_group" "kafka" {
  name   = "${var.base_name}-kafka"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
    # cidr_blocks = var.subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}
resource "aws_msk_cluster" "kafka" {
  cluster_name           = var.base_name
  kafka_version          = "3.4.0"
  number_of_broker_nodes = length(var.subnets)
  broker_node_group_info {
    instance_type = "kafka.t3.small"
    storage_info {
      ebs_storage_info {
        volume_size = 1000
      }
    }
    client_subnets  = var.subnets
    security_groups = [aws_security_group.kafka.id]
  }

  client_authentication {
    unauthenticated = false
    sasl {
      iam   = false
      scram = true
    }
  }

  encryption_info {
    encryption_in_transit {
      client_broker = "TLS"
    }
    encryption_at_rest_kms_key_arn = aws_kms_key.kafka_kms_key.arn
  }
  configuration_info {
    arn      = aws_msk_configuration.kafka_config.arn
    revision = aws_msk_configuration.kafka_config.latest_revision
  }
  open_monitoring {
    prometheus {
      jmx_exporter {
        enabled_in_broker = true
      }
      node_exporter {
        enabled_in_broker = true
      }
    }
  }
  logging_info {
    broker_logs {
      cloudwatch_logs {
        enabled   = true
        log_group = aws_cloudwatch_log_group.kafka_log_group.name
      }
    }
  }
}

resource "random_password" "kafka" {
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

resource "aws_secretsmanager_secret" "kafka" {
  name       = "AmazonMSK_${var.base_name}"
  kms_key_id = aws_kms_key.kafka_kms_key.arn
}

resource "aws_secretsmanager_secret_version" "kafka" {
  secret_id     = aws_secretsmanager_secret.kafka.id
  secret_string = jsonencode({ username = "kafka", password = random_password.kafka.result })
}

resource "aws_msk_scram_secret_association" "kafka" {
  cluster_arn     = aws_msk_cluster.kafka.arn
  secret_arn_list = [aws_secretsmanager_secret.kafka.arn]

  depends_on = [aws_secretsmanager_secret_version.kafka]
}
