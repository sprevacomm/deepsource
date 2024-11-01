output "userpool_id" {
  description = "The ID of the user pool"
  value       = aws_cognito_user_pool.userpool.id
}

output "app_client_id" {
  description = "The ID of the app client"
  value       = aws_cognito_user_pool_client.app.id
}

output "web_client_id" {
  description = "The ID of the web client"
  value       = aws_cognito_user_pool_client.web.id
}

output "app_client_secret" {
  description = "The secret of the app client"
  value       = aws_cognito_user_pool_client.app.client_secret
}

output "app_userpool_domain" {
  description = "The domain of the app user pool"
  value       = "https://${var.base_name}.auth.${local.region}.amazoncognito.com/login?redirect_uri=${var.app_url}&response_type=CODE&client_id=${aws_cognito_user_pool_client.app.id}&scope=aws.cognito.signin.user.admin+email+openid+profile"
}

output "web_userpool_domain" {
  description = "The domain of the web user pool"
  value       = "https://${var.base_name}.auth.${local.region}.amazoncognito.com/login?redirect_uri=${var.app_url}&response_type=CODE&client_id=${aws_cognito_user_pool_client.web.id}&scope=aws.cognito.signin.user.admin+email+openid+profile"
}

output "default_user_accounts" {
  description = "Cognito default user accounts"
  value = {
    for user in [aws_cognito_user.admin, aws_cognito_user.adjudicator, aws_cognito_user.analyst] :
    user.username => nonsensitive(user.password)
  }
}
