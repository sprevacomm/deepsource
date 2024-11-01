resource "aws_kms_key" "redis_kms_key" {
  description = "Key for Redis ${var.base_name}"
}
resource "aws_kms_alias" "redis_kms_key" {
  name          = "alias/${var.base_name}-redis"
  target_key_id = aws_kms_key.redis_kms_key.id
}

resource "aws_security_group" "redis" {
  name   = "${var.base_name}-redis"
  vpc_id = var.vpc_id
  ingress {
    from_port   = 6379
    to_port     = 6380
    protocol    = "TCP"
    cidr_blocks = var.subnet_cidrs
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = var.subnet_cidrs
  }
}

resource "aws_elasticache_serverless_cache" "redis" {
  engine = "redis"
  name   = var.base_name
  cache_usage_limits {
    data_storage {
      maximum = 10
      unit    = "GB"
    }
    ecpu_per_second {
      maximum = 5000
    }
  }
  # daily_snapshot_time      = "09:00"
  description          = var.base_name
  kms_key_id           = aws_kms_key.redis_kms_key.arn
  major_engine_version = "7"
  # snapshot_retention_limit = 1
  security_group_ids = [aws_security_group.redis.id]
  subnet_ids         = var.subnet_ids
}
