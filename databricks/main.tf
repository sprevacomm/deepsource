# Get the current AWS region
data "aws_region" "current" {}

# Get the current AWS account ID
data "aws_caller_identity" "current" {}

data "databricks_aws_assume_role_policy" "this" {
  provider    = databricks.mws
  external_id = var.databricks_account_id
}

data "databricks_aws_crossaccount_policy" "this" {
  provider    = databricks.mws
  policy_type = "customer"
}

data "databricks_aws_bucket_policy" "this" {
  bucket = aws_s3_bucket.databricks.bucket
}

locals {
  region              = data.aws_region.current.name
  account_id          = data.aws_caller_identity.current.account_id
  root_bucket_name    = "${var.base_name}-databricks-root"
  assume_role_policy  = data.databricks_aws_assume_role_policy.this.json
  crossaccount_policy = data.databricks_aws_crossaccount_policy.this.json
  bucket_policy       = data.databricks_aws_bucket_policy.this.json

  databricks_user_policy_arns = [
    "arn:aws:iam::aws:policy/AmazonMSKFullAccess",
    "arn:aws:iam::aws:policy/AmazonRDSDataFullAccess",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess",
    "arn:aws:iam::aws:policy/AWSLambda_FullAccess"
  ]
}

resource "aws_iam_user" "databricks" {
  name = "${var.base_name}-databricks"
}

resource "aws_iam_user_policy_attachment" "databricks" {
  for_each   = toset(local.databricks_user_policy_arns)
  user       = aws_iam_user.databricks.name
  policy_arn = each.value
}

resource "aws_iam_role" "databricks" {
  name               = "${var.base_name}-databricks"
  assume_role_policy = local.assume_role_policy

  managed_policy_arns = [
    aws_iam_policy.databricks.arn
  ]
}

resource "aws_iam_policy" "databricks" {
  name   = "${var.base_name}-databricks"
  policy = local.crossaccount_policy
}

resource "aws_s3_bucket" "databricks" {
  bucket        = local.root_bucket_name
  force_destroy = true
}

resource "aws_s3_bucket_server_side_encryption_configuration" "root_storage_bucket" {
  bucket = aws_s3_bucket.databricks.bucket

  rule {
    apply_server_side_encryption_by_default {
      sse_algorithm = "AES256"
    }
  }
}

resource "aws_s3_bucket_versioning" "root_bucket_versioning" {
  bucket = aws_s3_bucket.databricks.bucket
  versioning_configuration {
    status = "Disabled"
  }
}
resource "aws_s3_bucket_policy" "databricks-cross-account" {
  bucket = aws_s3_bucket.databricks.id
  policy = local.bucket_policy
}

resource "aws_security_group" "databricks" {
  name   = "${var.base_name}-databricks"
  vpc_id = var.vpc_id
  # apparently the databricks control plain modifies these rules
  lifecycle {
    ignore_changes = [
      ingress,
      egress
    ]
  }
  ingress {
    from_port = 443
    to_port   = 443
    protocol  = "TCP"
    self      = true
  }

  ingress {
    from_port = 3306
    to_port   = 3306
    protocol  = "TCP"
    self      = true
  }

  ingress {
    from_port = 6666
    to_port   = 6666
    protocol  = "TCP"
    self      = true
  }

  ingress {
    from_port = 2443
    to_port   = 2443
    protocol  = "TCP"
    self      = true
  }

  ingress {
    from_port = 8443
    to_port   = 8445
    protocol  = "TCP"
    self      = true
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
}

resource "time_sleep" "wait" {
  depends_on = [
    aws_iam_role.databricks
  ]
  create_duration = "10s"
}

resource "databricks_mws_credentials" "this" {
  provider         = databricks.mws
  role_arn         = aws_iam_role.databricks.arn
  credentials_name = "${var.base_name}-creds"
  depends_on       = [time_sleep.wait]
}

resource "databricks_mws_networks" "this" {
  provider           = databricks.mws
  account_id         = var.databricks_account_id
  network_name       = "${var.base_name}-network"
  security_group_ids = [aws_security_group.databricks.id]
  subnet_ids         = var.subnet_ids
  vpc_id             = var.vpc_id
}

resource "databricks_mws_storage_configurations" "this" {
  provider                   = databricks.mws
  account_id                 = var.databricks_account_id
  bucket_name                = aws_s3_bucket.databricks.id
  storage_configuration_name = "${var.base_name}-storage"
}

resource "databricks_mws_workspaces" "this" {
  provider       = databricks.mws
  account_id     = var.databricks_account_id
  aws_region     = local.region
  workspace_name = var.base_name

  credentials_id           = databricks_mws_credentials.this.credentials_id
  storage_configuration_id = databricks_mws_storage_configurations.this.storage_configuration_id
  network_id               = databricks_mws_networks.this.network_id

  token {
    comment = "Terraform-rapid-cc"
  }
}
