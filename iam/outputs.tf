output "smtp_username" {
  description = "The SMTP username"
  value       = aws_iam_access_key.smtp.id
}

output "smtp_password" {
  description = "The SMTP password"
  value       = aws_iam_access_key.smtp.ses_smtp_password_v4
}

output "eks_access_role" {
  description = "The ARN of the EKS IAM role"
  value       = aws_iam_role.eks_access_role.arn
}

output "cognito_role" {
  description = "The ARN of the Cognito IAM role"
  value       = aws_iam_role.cognito_role.arn
}

output "lambda_exec_role" {
  description = "The ARN of the Lambda IAM role"
  value       = aws_iam_role.lambda_exec_role.arn
}
