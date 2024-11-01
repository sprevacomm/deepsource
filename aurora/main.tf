resource "aws_rds_cluster" "db" {
  cluster_identifier          = var.db_name
  engine                      = var.db_engine
  engine_version              = var.db_engine_version
  database_name               = var.db_name
  master_username             = var.db_username
  manage_master_user_password = true
  skip_final_snapshot         = true
  vpc_security_group_ids      = [aws_security_group.database.id]
}

resource "aws_rds_cluster_instance" "todobackend_instances" {
  count              = var.db_instance_count
  identifier_prefix  = "${var.db_name}-"
  cluster_identifier = aws_rds_cluster.db.id
  instance_class     = var.db_instance_class
  engine             = var.db_engine
  engine_version     = var.db_engine_version
}

resource "aws_security_group" "database" {
  name        = "${var.db_name}-sg"
  description = "Database traffic"
  vpc_id      = data.aws_vpc.default.id
  tags = {
    Name = "${var.db_name}-sg"
  }
}

resource "aws_vpc_security_group_ingress_rule" "database" {
  security_group_id            = aws_security_group.database.id
  referenced_security_group_id = var.application_security_group_id
  from_port                    = 5432
  ip_protocol                  = "tcp"
  to_port                      = 5432
}

locals {
  database_secret = one(aws_rds_cluster.todobackend.master_user_secret[*].secret_arn)
}