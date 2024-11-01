data "aws_caller_identity" "current" {}
data "aws_region" "current" {}

locals {
  account_id = data.aws_caller_identity.current.account_id
  region     = data.aws_region.current.name
}

resource "aws_cognito_user_pool" "userpool" {
  name                     = var.base_name
  username_attributes      = ["email"]
  auto_verified_attributes = ["email"]

  admin_create_user_config {
    allow_admin_create_user_only = false
    invite_message_template {
      email_message = "Your username is {username} and temporary password is {####}"
      email_subject = "Registration confirmation"
      sms_message   = "Your username is {username} and temporary password is {####}"
    }
  }

  password_policy {
    minimum_length                   = 8
    require_lowercase                = true
    require_numbers                  = true
    require_symbols                  = false
    require_uppercase                = true
    temporary_password_validity_days = 7
  }

  verification_message_template {
    email_subject        = "Please verify your account"
    email_message        = "Your code is {####}"
    default_email_option = "CONFIRM_WITH_CODE"
    sms_message          = "Your temporary password is {####}"
  }

  email_configuration {
    email_sending_account = "COGNITO_DEFAULT"
  }

  mfa_configuration = "OFF"

  sms_authentication_message = "Your temporary password is {####}"
  sms_configuration {
    external_id    = "PublicExternalSmsId"
    sns_caller_arn = var.cognito_role
  }

  lambda_config {
    post_confirmation = var.cognito_signup_lambda_arn
  }

  username_configuration {
    case_sensitive = false
  }

  schema {
    name                = "given_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }

  schema {
    name                = "family_name"
    attribute_data_type = "String"
    mutable             = true
    required            = true
  }
}

resource "aws_cognito_user_pool_client" "app" {
  name                                 = "app"
  generate_secret                      = true
  user_pool_id                         = aws_cognito_user_pool.userpool.id
  allowed_oauth_flows                  = ["code"]
  explicit_auth_flows                  = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  read_attributes                      = ["given_name", "family_name", "email"]
  write_attributes                     = ["given_name", "family_name"]
  supported_identity_providers         = ["COGNITO"]
  refresh_token_validity               = 1
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_client" "web" {
  name                                 = "web"
  generate_secret                      = false
  user_pool_id                         = aws_cognito_user_pool.userpool.id
  allowed_oauth_flows                  = ["code"]
  explicit_auth_flows                  = ["ALLOW_ADMIN_USER_PASSWORD_AUTH", "ALLOW_CUSTOM_AUTH", "ALLOW_REFRESH_TOKEN_AUTH", "ALLOW_USER_PASSWORD_AUTH", "ALLOW_USER_SRP_AUTH"]
  allowed_oauth_scopes                 = ["email", "openid", "profile", "aws.cognito.signin.user.admin"]
  callback_urls                        = var.callback_urls
  logout_urls                          = var.logout_urls
  read_attributes                      = ["given_name", "family_name", "email"]
  write_attributes                     = ["given_name", "family_name"]
  supported_identity_providers         = ["COGNITO"]
  refresh_token_validity               = 1
  allowed_oauth_flows_user_pool_client = true
}

resource "aws_cognito_user_pool_domain" "this" {
  domain       = var.base_name
  user_pool_id = aws_cognito_user_pool.userpool.id
}

# IAM role and policy for Admin - S3 Object Management and Lambda Execute
resource "aws_iam_role" "admin_role" {
  name = "${var.base_name}-admin_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action = "sts:AssumeRole",
        Effect = "Allow",
        Principal = {
          Federated = "cognito-identity.amazonaws.com"
        },
      },
    ],
  })
}

resource "aws_iam_policy" "admin_policy" {
  name        = "${aws_iam_role.admin_role.name}-lambda-invoke"
  description = "Policy to allow read access to S3 and execution of a Lambda function"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Action   = ["lambda:InvokeFunction"],
        Effect   = "Allow",
        Resource = "*"
      },
    ],
  })
}

resource "aws_iam_role_policy_attachment" "admin_attach" {
  role       = aws_iam_role.admin_role.name
  policy_arn = aws_iam_policy.admin_policy.arn
}

resource "aws_cognito_user_group" "admin" {
  name         = "Admin"
  user_pool_id = aws_cognito_user_pool.userpool.id
  role_arn     = aws_iam_role.admin_role.arn
}

resource "aws_cognito_user_group" "edit" {
  name         = "Edit"
  user_pool_id = aws_cognito_user_pool.userpool.id
}

resource "aws_cognito_user_group" "read_only" {
  name         = "Read-Only"
  user_pool_id = aws_cognito_user_pool.userpool.id
}

resource "aws_cognito_user" "admin" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = "admin@example.com"
  password     = "Password123"

  attributes = {
    given_name     = "Admin"
    family_name    = "User"
    email          = "admin@example.com"
    email_verified = true
  }

  lifecycle {
    ignore_changes = [
      attributes,
    ]
  }

  depends_on = [aws_cognito_user_pool.userpool]
}

resource "aws_cognito_user" "analyst" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = "analyst@example.com"
  password     = "Password123"

  attributes = {
    given_name     = "Analyst"
    family_name    = "User"
    email          = "analyst@example.com"
    email_verified = true
  }

  lifecycle {
    ignore_changes = [
      attributes,
    ]
  }

  depends_on = [aws_cognito_user_pool.userpool]
}

resource "aws_cognito_user" "adjudicator" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = "adjudicator@example.com"
  password     = "Password123"

  attributes = {
    given_name     = "Adjudicator"
    family_name    = "User"
    email          = "adjudicator@example.com"
    email_verified = true
  }

  lifecycle {
    ignore_changes = [
      attributes,
    ]
  }

  depends_on = [aws_cognito_user_pool.userpool]
}

resource "aws_cognito_user_in_group" "admin_membership" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = aws_cognito_user.admin.username
  group_name   = aws_cognito_user_group.admin.name

  depends_on = [aws_cognito_user.admin]
}

resource "aws_cognito_user_in_group" "analyst_membership" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = aws_cognito_user.analyst.username
  group_name   = aws_cognito_user_group.read_only.name

  depends_on = [aws_cognito_user.analyst]
}

resource "aws_cognito_user_in_group" "adjudicator_membership" {
  user_pool_id = aws_cognito_user_pool.userpool.id
  username     = aws_cognito_user.adjudicator.username
  group_name   = aws_cognito_user_group.edit.name

  depends_on = [aws_cognito_user.adjudicator]
}
