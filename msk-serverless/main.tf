resource "aws_security_group" "kafka" {
  name   = "${var.base_name}-kafka-serverless"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 0
    to_port     = 9092
    protocol    = "TCP"
    cidr_blocks = var.private_subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "aws_msk_serverless_cluster" "kafka" {
  cluster_name = "${var.base_name}-serverless"

  vpc_config {
    subnet_ids         = var.private_subnets
    security_group_ids = [aws_security_group.kafka.id]
  }

  client_authentication {
    sasl {
      iam {
        enabled = true
      }
    }
  }
}
