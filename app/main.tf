data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}
data "aws_iam_policy_document" "app_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "s3:putobject",
      "s3:getobject",
      "s3:deleteobject",
      "s3:listbucket",
      "s3:getbucketlocation"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:getresourcepolicy",
      "secretsmanager:getsecretvalue",
      "secretsmanager:describesecret",
      "secretsmanager:listsecretversionids"
    ]
    resources = [
      "arn:aws:secretsmanager:${local.region}:${local.account_id}:secret:*"
    ]
  }

  statement {
    actions = [
      "cognito-idp:Admin*",
      "cognito-idp:Describe*",
      "cognito-idp:Get*",
      "cognito-idp:List*",
      "cognito-idp:Update*"
    ]
    resources = [
      "arn:aws:cognito-idp:${local.region}:${local.account_id}:userpool/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "secretsmanager:getrandompassword",
      "secretsmanager:listsecrets"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kms:decrypt",
      "kms:describekey",
      "kms:encrypt",
      "kms:reencrypt*",
      "kms:generatedatakey*"
    ]
    resources = [
      "arn:aws:kms:${local.region}:${local.account_id}:key/*"
    ]
  }
}

resource "aws_iam_policy" "app_policy" {
  name   = "${var.base_name}-${var.app_namespace}-${var.app_name}"
  policy = data.aws_iam_policy_document.app_policy_document.json
}

resource "aws_iam_role" "app" {
  name = "${var.base_name}-${var.app_namespace}-${var.app_name}"
  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRoleWithWebIdentity"
        Effect = "Allow"
        Principal = {
          Federated = var.cluster_oidc_arn
        }
        Condition = {
          StringLike = {
            (var.cluster_oidc_subject)  = "system:serviceaccount:${var.app_namespace}:${var.app_name}*"
            (var.cluster_oidc_audience) = "sts.amazonaws.com"
          }
        }
      },
    ]
  })
  managed_policy_arns = [
    aws_iam_policy.app_policy.arn,
    "arn:aws:iam::aws:policy/AmazonBedrockFullAccess",
  ]
}
