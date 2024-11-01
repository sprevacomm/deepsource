# Get the VPC CIDR from the VPC id var.vpc_id
data "aws_vpc" "default" {
  id = var.vpc_id
}
resource "aws_kms_key" "rds_kms_key" {
  description = "Key for RDS ${var.identifier}"
}
resource "aws_kms_alias" "rds_kms_key" {
  name          = "alias/${var.identifier}-rds"
  target_key_id = aws_kms_key.rds_kms_key.id
}

locals {
  default_cidr_blocks = [data.aws_vpc.default.cidr_block]
  public_cidr_blocks  = ["0.0.0.0/0"]
  db_password         = var.db_password == "" ? "password123" : var.db_password
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.identifier}-security-group"
  description = "RDS instance ${var.identifier}"
  vpc_id      = var.vpc_id # Make sure to define this variable in your variables.tf or pass it as an input

  # Inbound rules - Adjust these as per your requirements
  # Example: Allow PostgreSQL traffic

  ingress {
    description = "PostgreSQL"
    from_port   = 5432 # Default port for PostgreSQL
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = local.default_cidr_blocks
  }

  # Outbound rules - Allowing all outbound traffic by default
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "rds-security-group-${var.identifier}"
  }
}

resource "aws_db_subnet_group" "my_subnet_group" {
  name       = lower("${var.identifier}-subnet") # Name for the DB subnet group
  subnet_ids = var.subnet_ids                    # Replace with your subnet IDs

  tags = {
    Name = "My RDS Subnet Group"
  }
}

resource "aws_db_instance" "default" {
  allocated_storage      = var.allocated_storage
  db_name                = var.db_name
  db_subnet_group_name   = aws_db_subnet_group.my_subnet_group.name
  engine                 = var.engine
  engine_version         = var.engine_version
  identifier             = var.identifier
  instance_class         = var.instance_class
  multi_az               = false
  parameter_group_name   = var.db_parameter_group
  publicly_accessible    = false
  skip_final_snapshot    = true
  storage_type           = var.storage_type
  storage_encrypted      = true
  kms_key_id             = aws_kms_key.rds_kms_key.arn
  username               = var.db_username
  password               = local.db_password
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
}
