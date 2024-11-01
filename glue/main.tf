resource "aws_iam_role" "glue_service_role" {
  name = "${var.base_name}-AWSGlueServiceRoleDefault"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "glue.amazonaws.com"
        }
      }
    ]
  })
  managed_policy_arns = [
    "arn:aws:iam::aws:policy/service-role/AWSGlueServiceRole",
    "arn:aws:iam::aws:policy/AmazonS3FullAccess"
  ]
}

resource "aws_s3_bucket" "glue_bucket" {
  bucket = lower("intellebridge-io-${var.base_name}-glue")

  force_destroy = true
}
